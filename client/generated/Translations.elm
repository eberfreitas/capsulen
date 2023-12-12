module Translations exposing (..)

import Dict


type Language
    = En
    | Pt


type Key
    = CredentialsIncorrect
    | ForbiddenArea
    | InputEmpty
    | InvalidInputs
    | LoadMorePosts
    | Login
    | LoginError
    | Logout
    | LogoutSuccess
    | PostsNoMore
    | PostAbout
    | PostError
    | PostFetchError
    | PostNew
    | PrivateKey
    | PrivateKeyNotice
    | PrivateKeyShort
    | PrivateKeyWs
    | Register
    | RegisterError
    | RegisterNew
    | RegisterSuccess
    | RequestError
    | Tagline
    | ToPost
    | UnexpectedRegisterError
    | UnknownError
    | Username
    | UsernameEmpty
    | UsernameInvalid
    | UsernameInUse
    | UserNotFound


languageFromString : String -> Language
languageFromString language =
    case language of
        "en" ->
            En

        "pt" ->
            Pt

        _ ->
            En


languageToString : Language -> String
languageToString language =
    case language of
        En ->
            "en"

        Pt ->
            "pt"


keyToString : Key -> String
keyToString key =
    case key of
        CredentialsIncorrect ->
            "CREDENTIALS_INCORRECT"

        ForbiddenArea ->
            "FORBIDDEN_AREA"

        InputEmpty ->
            "INPUT_EMPTY"

        InvalidInputs ->
            "INVALID_INPUTS"

        LoadMorePosts ->
            "LOAD_MORE_POSTS"

        Login ->
            "LOGIN"

        LoginError ->
            "LOGIN_ERROR"

        Logout ->
            "LOGOUT"

        LogoutSuccess ->
            "LOGOUT_SUCCESS"

        PostsNoMore ->
            "POSTS_NO_MORE"

        PostAbout ->
            "POST_ABOUT"

        PostError ->
            "POST_ERROR"

        PostFetchError ->
            "POST_FETCH_ERROR"

        PostNew ->
            "POST_NEW"

        PrivateKey ->
            "PRIVATE_KEY"

        PrivateKeyNotice ->
            "PRIVATE_KEY_NOTICE"

        PrivateKeyShort ->
            "PRIVATE_KEY_SHORT"

        PrivateKeyWs ->
            "PRIVATE_KEY_WS"

        Register ->
            "REGISTER"

        RegisterError ->
            "REGISTER_ERROR"

        RegisterNew ->
            "REGISTER_NEW"

        RegisterSuccess ->
            "REGISTER_SUCCESS"

        RequestError ->
            "REQUEST_ERROR"

        Tagline ->
            "TAGLINE"

        ToPost ->
            "TO_POST"

        UnexpectedRegisterError ->
            "UNEXPECTED_REGISTER_ERROR"

        UnknownError ->
            "UNKNOWN_ERROR"

        Username ->
            "USERNAME"

        UsernameEmpty ->
            "USERNAME_EMPTY"

        UsernameInvalid ->
            "USERNAME_INVALID"

        UsernameInUse ->
            "USERNAME_IN_USE"

        UserNotFound ->
            "USER_NOT_FOUND"


translate : Language -> Key -> String
translate lang key =
    let
        langString =
            lang |> languageToString

        keyString =
            key |> keyToString
    in
    Dict.get langString phrases
        |> (\maybePhrases -> Maybe.andThen (Dict.get keyString) maybePhrases)
        |> (\maybePhrase -> Maybe.withDefault keyString maybePhrase)


translateUnsafe : Language -> String -> String
translateUnsafe lang key =
    let
        langString =
            lang |> languageToString
    in
    Dict.get langString phrases
        |> (\maybePhrases -> Maybe.andThen (Dict.get key) maybePhrases)
        |> (\maybePhrase -> Maybe.withDefault key maybePhrase)


phrases : Dict.Dict String (Dict.Dict String String)
phrases =
    Dict.fromList
        [ ( "CREDENTIALS_INCORRECT"
          , Dict.fromList
                [ ( "en"
                  , "Username or private key incorrect. Please, try again"
                  )
                , ( "pt"
                  , "Nome de usuário ou chave privada incorretos. Por favor, tente novamente"
                  )
                ]
          )
        , ( "FORBIDDEN_AREA"
          , Dict.fromList
                [ ( "en", "You need to be logged in to see this page. Please" )
                , ( "pt"
                  , "Você precisa ter feito login para acessar esta página"
                  )
                ]
          )
        , ( "INPUT_EMPTY"
          , Dict.fromList
                [ ( "en", "This field can't be empty" )
                , ( "pt", "Este campo não pode ficar vazio" )
                ]
          )
        , ( "INVALID_INPUTS"
          , Dict.fromList
                [ ( "en"
                  , "One or more inputs are invalid. Check the messages in the form to fix and try again"
                  )
                , ( "pt"
                  , "Um ou mais campos estão incorretos. Verifique as mensagens no formulário e tente novamente"
                  )
                ]
          )
        , ( "LOAD_MORE_POSTS"
          , Dict.fromList
                [ ( "en", "Load more posts" )
                , ( "pt", "Carregar mais postagens" )
                ]
          )
        , ( "LOGIN", Dict.fromList [ ( "en", "Login" ), ( "pt", "Login" ) ] )
        , ( "LOGIN_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error trying to log you in. Please, try again"
                  )
                , ( "pt"
                  , "Houve um erro ao tentar acessar sua conta. Por favor, tente novamente"
                  )
                ]
          )
        , ( "LOGOUT", Dict.fromList [ ( "en", "Logout" ), ( "pt", "Sair" ) ] )
        , ( "LOGOUT_SUCCESS"
          , Dict.fromList [ ( "en", "See you soon!" ), ( "pt", "Até breve!" ) ]
          )
        , ( "POSTS_NO_MORE"
          , Dict.fromList
                [ ( "en", "There are no more posts to load" )
                , ( "pt", "Não há mais postagems a serem carregadas" )
                ]
          )
        , ( "POST_ABOUT"
          , Dict.fromList
                [ ( "en", "What do you want to write about?" )
                , ( "pt", "Sobre o que você quer escrever?" )
                ]
          )
        , ( "POST_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error saving your post. Please, try again"
                  )
                , ( "pt"
                  , "Houve um error ao salvar sua postagem. Por favor, tente novamente"
                  )
                ]
          )
        , ( "POST_FETCH_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error fetching your posts. Please, try again"
                  )
                , ( "pt"
                  , "Houve um erro ao buscar seus posts. Por favor, tente novamente"
                  )
                ]
          )
        , ( "POST_NEW"
          , Dict.fromList
                [ ( "en", "New post added" ), ( "pt", "Novo post adicionado" ) ]
          )
        , ( "PRIVATE_KEY"
          , Dict.fromList [ ( "en", "Private key" ), ( "pt", "Chave privada" ) ]
          )
        , ( "PRIVATE_KEY_NOTICE"
          , Dict.fromList
                [ ( "en"
                  , "Your private key will never be sent over the network"
                  )
                , ( "pt", "Sua chave privada nunca será enviada pela rede" )
                ]
          )
        , ( "PRIVATE_KEY_SHORT"
          , Dict.fromList
                [ ( "en", "Private key must have more than 4 characters" )
                , ( "pt", "Chave privada precisa ter mais que 4 caracteres" )
                ]
          )
        , ( "PRIVATE_KEY_WS"
          , Dict.fromList
                [ ( "en"
                  , "Avoid spaces at the beginning and end of the private key"
                  )
                , ( "pt"
                  , "Evite espaços no início e final de sua chave privada"
                  )
                ]
          )
        , ( "REGISTER"
          , Dict.fromList [ ( "en", "Register" ), ( "pt", "Registrar conta" ) ]
          )
        , ( "REGISTER_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error registering your account. Please, try again"
                  )
                , ( "pt"
                  , "Houve um error ao registrar sua conta. Por favor, tente novamente"
                  )
                ]
          )
        , ( "REGISTER_NEW"
          , Dict.fromList
                [ ( "en", "Register new account" )
                , ( "pt", "Registrar nova conta" )
                ]
          )
        , ( "REGISTER_SUCCESS"
          , Dict.fromList
                [ ( "en", "Registration successful! Please log in now" )
                , ( "pt"
                  , "Registro realizado com sucesso! Você pode acessar sua conta agora"
                  )
                ]
          )
        , ( "REQUEST_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error processing your request. Please, try again"
                  )
                , ( "pt"
                  , "Ocorreu um erro ao realizar esta requisição. Por favor, tente novamente"
                  )
                ]
          )
        , ( "TAGLINE"
          , Dict.fromList
                [ ( "en", "“Journaling made safe and simple”" )
                , ( "pt", "“Um diário seguro e simples”" )
                ]
          )
        , ( "TO_POST", Dict.fromList [ ( "en", "Post" ), ( "pt", "Postar" ) ] )
        , ( "UNEXPECTED_REGISTER_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "Unexpected error while handling your registration request"
                  )
                , ( "pt"
                  , "Erro inexperado ao lidar com seu pedido de registro"
                  )
                ]
          )
        , ( "UNKNOWN_ERROR"
          , Dict.fromList
                [ ( "en", "Unknown error" ), ( "pt", "Erro desconhecido" ) ]
          )
        , ( "USERNAME"
          , Dict.fromList [ ( "en", "Username" ), ( "pt", "Nome de usuário" ) ]
          )
        , ( "USERNAME_EMPTY"
          , Dict.fromList
                [ ( "en", "Username can't be empty" )
                , ( "pt", "Nome de usuário não pode ficar vazio" )
                ]
          )
        , ( "USERNAME_INVALID"
          , Dict.fromList
                [ ( "en"
                  , "Username must contain only letters, numbers and underscores (_)"
                  )
                , ( "pt"
                  , "Nome de usuário pode conter apenas letras, números e underscoders (_)"
                  )
                ]
          )
        , ( "USERNAME_IN_USE"
          , Dict.fromList
                [ ( "en"
                  , "Username is already in use. Please, pick a different username"
                  )
                , ( "pt"
                  , "Nome de usuário já cadastrado. Escolha um diferente e tente novamente"
                  )
                ]
          )
        , ( "USER_NOT_FOUND"
          , Dict.fromList
                [ ( "en", "User not found" )
                , ( "pt", "Usuário não encontrado" )
                ]
          )
        ]