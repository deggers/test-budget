module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL

type alias Model =
    { balance : Float
    , transaction : Float
    }


initialModel : Model
initialModel =
    { balance = 0
    , transaction = 0
    }


-- UPDATE

type Msg
    = AddTransaction
    | UpdateTransaction String


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddTransaction ->
            { model | balance = model.balance + model.transaction, transaction = 0 }

        UpdateTransaction value ->
            { model | transaction = Maybe.withDefault 0 (String.toFloat value) }


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

main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
