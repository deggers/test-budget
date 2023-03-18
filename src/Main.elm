port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- 2. This is needed because our port takes a JavaScript value as its first argument.
import Json.Encode as E
import Json.Decode as D

-- 3. A port for saving our model to localStorage.
port setStorage : E.Value -> Cmd msg

-- MODEL

type alias Model =
    { balance : Float
    , transaction : Float
    }


initialModel : E.Value -> ( Model, Cmd Msg )
initialModel flags =
    (
        case D.decodeValue decoder flags of
        Ok model -> model
        Err _ -> { balance = 0, transaction = 0 }
    ,
        Cmd.none
    )

-- JSON ENCODE/DECODE


encode : Model -> E.Value
encode model =
  E.object
    [ ("balance", E.float model.balance)
    , ("transaction", E.float model.transaction)
    ]


decoder : D.Decoder Model
decoder =
  D.map2 Model
    (D.field "balance" D.float)
    (D.field "transaction" D.float)

-- UPDATE

type Msg
    = AddTransaction
    | UpdateTransaction String


update :Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTransaction ->
           ( { model | balance = model.balance + model.transaction, transaction = 0 }
           , Cmd.none
           )

        UpdateTransaction value ->
           ( { model | transaction = Maybe.withDefault 0 (String.toFloat value) }
           , Cmd.none
           )


--
updateAndSave : Msg -> Model -> ( Model, Cmd Msg )
updateAndSave msg oldModel =
  let
    ( newModel, cmds ) = update msg oldModel
  in
  ( newModel
  , Cmd.batch [ setStorage (encode newModel), cmds ]
  )



-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Budget Keeper" ]
        , p [] [ text "Current Balance:" ]
        , p [] [ text (String.fromFloat model.balance) ]
        , p [] [ text "Transaction Amount:" ]
        , input [ type_ "number",value (String.fromFloat model.transaction), onInput UpdateTransaction ] []
        , button [ onClick AddTransaction ] [ text "Add Transaction" ]
        ]


-- PROGRAM

main : Program E.Value Model Msg
main =
    Browser.element
        { init = initialModel
        , view = view
        , update = updateAndSave
        , subscriptions = \_ -> Sub.none
        }
