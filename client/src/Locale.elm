module Locale exposing (Locale, fromString, getPhrase)

import Dict


type Locale
    = PT
    | EN


fromString : String -> Locale
fromString locale =
    case locale of
        "pt" ->
            PT

        "en" ->
            EN

        _ ->
            EN


type alias Phrase =
    { pt : String
    , en : String
    }


type alias Phrases =
    Dict.Dict String Phrase


getPhrase : Locale -> String -> String
getPhrase locale phraseKey =
    let
        mapFn : Phrase -> String
        mapFn =
            case locale of
                PT ->
                    .pt

                EN ->
                    .en
    in
    phrases
        |> Dict.get phraseKey
        |> Maybe.map mapFn
        |> Maybe.withDefault phraseKey


phrases : Phrases
phrases =
    [ ( "CREDENTIALS_INCORRECT"
      , { pt = "Nome de usuário ou chave privada incorretos. Por favor, tente novamente"
        , en = "Username or private key incorrect. Please, try again"
        }
      )
    , ( "FORBIDDEN_AREA"
      , { pt = "Você precisa ter feito login para acessar esta página"
        , en = "You need to be logged in to see this page. Please"
        }
      )
    , ( "INPUT_EMPTY"
      , { pt = "Este campo não pode ficar vazio"
        , en = "This field can't be empty"
        }
      )
    , ( "INVALID_INPUTS"
      , { pt = "Um ou mais campos estão incorretos. Verifique as mensagens no formulário e tente novamente"
        , en = "One or more inputs are invalid. Check the messages in the form to fix and try again"
        }
      )
    , ( "LOAD_MORE_POSTS"
      , { pt = "Carregar mais postagens"
        , en = "Load more posts"
        }
      )
    , ( "LOGIN"
      , { pt = "Login"
        , en = "Login"
        }
      )
    , ( "LOGIN_ERROR"
      , { pt = "Houve um erro ao tentar acessar sua conta. Por favor, tente novamente"
        , en = "There was an error trying to log you in. Please, try again"
        }
      )
    , ( "TO_POST"
      , { pt = "Postar"
        , en = "Post"
        }
      )
    , ( "POST_ABOUT"
      , { pt = "Sobre o que você quer escrever?"
        , en = "What do you want to write about?"
        }
      )
    , ( "POST_FETCH_ERROR"
      , { pt = "Houve um erro ao buscar seus posts. Por favor, tente novamente"
        , en = "There was an error fetching your posts. Please, try again"
        }
      )
    , ( "POST_ERROR"
      , { pt = "Houve um error ao salvar sua postagem. Por favor, tente novamente"
        , en = "There was an error saving your post. Please, try again"
        }
      )
    , ( "POST_NEW"
      , { pt = "Novo post adicionado"
        , en = "New post added"
        }
      )
    , ( "POSTS_NO_MORE"
      , { pt = "Não há mais postagems a serem carregadas"
        , en = "There are no more posts to load"
        }
      )
    , ( "PRIVATE_KEY"
      , { pt = "Chave privada"
        , en = "Private key"
        }
      )
    , ( "PRIVATE_KEY_NOTICE"
      , { pt = "Sua chave privada nunca será enviada pela rede"
        , en = "Your private key will never be sent over the network"
        }
      )
    , ( "PRIVATE_KEY_SHORT"
      , { pt = "Chave privada precisa ter mais que 4 caracteres"
        , en = "Private key must have more than 4 characters"
        }
      )
    , ( "PRIVATE_KEY_WS"
      , { pt = "Evite espaços no início e final de sua chave privada"
        , en = "Avoid spaces at the beginning and end of the private key"
        }
      )
    , ( "REGISTER"
      , { pt = "Registrar conta"
        , en = "Register"
        }
      )
    , ( "REGISTER_ERROR"
      , { pt = "Houve um error ao registrar sua conta. Por favor, tente novamente"
        , en = "There was an error registering your account. Please, try again"
        }
      )
    , ( "REGISTER_NEW"
      , { pt = "Registrar nova conta"
        , en = "Register new account"
        }
      )
    , ( "REGISTER_SUCCESS"
      , { pt = "Registro realizado com sucesso! Você pode acessar sua conta agora"
        , en = "Registration successful! Please log in now"
        }
      )
    , ( "REQUEST_ERROR"
      , { pt = "Ocorreu um erro ao realizar esta requisição. Por favor, tente novamente"
        , en = "There was an error processing your request. Please, try again"
        }
      )
    , ( "UNKNOWN_ERROR"
      , { pt = "Erro desconhecido"
        , en = "Unknown error"
        }
      )
    , ( "UNEXPECTED_REGISTER_ERROR"
      , { pt = "Erro inexperado ao lidar com seu pedido de registro"
        , en = "Unexpected error while handling your registration request"
        }
      )
    , ( "USER_NOT_FOUND"
      , { pt = "Usuário não encontrado"
        , en = "User not found"
        }
      )
    , ( "USERNAME"
      , { pt = "Nome de usuário"
        , en = "Username"
        }
      )
    , ( "USERNAME_EMPTY"
      , { pt = "Nome de usuário não pode ficar vazio"
        , en = "Username can't be empty"
        }
      )
    , ( "USERNAME_INVALID"
      , { pt = "Nome de usuário pode conter apenas letras, números e underscoders (_)"
        , en = "Username must contain only letters, numbers and underscores (_)"
        }
      )
    , ( "USERNAME_IN_USE"
      , { pt = "Nome de usuário já cadastrado. Escolha um diferente e tente novamente"
        , en = "Username is already in use. Please, pick a different username"
        }
      )
    ]
        |> Dict.fromList
