module Translations exposing (..)

import Dict


type Language
    = En
    | Pt


type Key
    = AllPostsLoaded
    | AutoLogout
    | AutoLogoutHint
    | BuyMePizza
    | ClearPost
    | CredentialsIncorrect
    | Credits
    | DecryptError
    | DeleteConfirm
    | Description
    | EncryptError
    | English
    | ForbiddenArea
    | InputEmpty
    | InvalidInputs
    | InviteCode
    | InviteCodeInvalid
    | InviteCountError
    | InviteError
    | InviteFetchError
    | InviteGenerate
    | InviteHelp
    | InvitePending
    | InviteUsed
    | Language
    | Loading
    | LoadMorePosts
    | Login
    | LoginError
    | Logout
    | LogoutSuccess
    | No
    | NoPost
    | Portuguese
    | PostsNoMore
    | PostAbout
    | PostEncrypted
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
    | Settings
    | SettingsNotice
    | Tagline
    | Theme
    | ThemeDark
    | ThemeLight
    | ThemeTatty
    | ToPost
    | UnexpectedRegisterError
    | UnknownError
    | Username
    | UsernameEmpty
    | UsernameInvalid
    | UsernameInUse
    | UserNotFound
    | Yes


type alias Helper =
    Key -> String


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


keyFromString : String -> Key
keyFromString key =
    case key of
        "ALL_POSTS_LOADED" ->
            AllPostsLoaded

        "AUTO_LOGOUT" ->
            AutoLogout

        "AUTO_LOGOUT_HINT" ->
            AutoLogoutHint

        "BUY_ME_PIZZA" ->
            BuyMePizza

        "CLEAR_POST" ->
            ClearPost

        "CREDENTIALS_INCORRECT" ->
            CredentialsIncorrect

        "CREDITS" ->
            Credits

        "DECRYPT_ERROR" ->
            DecryptError

        "DELETE_CONFIRM" ->
            DeleteConfirm

        "DESCRIPTION" ->
            Description

        "ENCRYPT_ERROR" ->
            EncryptError

        "ENGLISH" ->
            English

        "FORBIDDEN_AREA" ->
            ForbiddenArea

        "INPUT_EMPTY" ->
            InputEmpty

        "INVALID_INPUTS" ->
            InvalidInputs

        "INVITE_CODE" ->
            InviteCode

        "INVITE_CODE_INVALID" ->
            InviteCodeInvalid

        "INVITE_COUNT_ERROR" ->
            InviteCountError

        "INVITE_ERROR" ->
            InviteError

        "INVITE_FETCH_ERROR" ->
            InviteFetchError

        "INVITE_GENERATE" ->
            InviteGenerate

        "INVITE_HELP" ->
            InviteHelp

        "INVITE_PENDING" ->
            InvitePending

        "INVITE_USED" ->
            InviteUsed

        "LANGUAGE" ->
            Language

        "LOADING" ->
            Loading

        "LOAD_MORE_POSTS" ->
            LoadMorePosts

        "LOGIN" ->
            Login

        "LOGIN_ERROR" ->
            LoginError

        "LOGOUT" ->
            Logout

        "LOGOUT_SUCCESS" ->
            LogoutSuccess

        "NO" ->
            No

        "NO_POST" ->
            NoPost

        "PORTUGUESE" ->
            Portuguese

        "POSTS_NO_MORE" ->
            PostsNoMore

        "POST_ABOUT" ->
            PostAbout

        "POST_ENCRYPTED" ->
            PostEncrypted

        "POST_ERROR" ->
            PostError

        "POST_FETCH_ERROR" ->
            PostFetchError

        "POST_NEW" ->
            PostNew

        "PRIVATE_KEY" ->
            PrivateKey

        "PRIVATE_KEY_NOTICE" ->
            PrivateKeyNotice

        "PRIVATE_KEY_SHORT" ->
            PrivateKeyShort

        "PRIVATE_KEY_WS" ->
            PrivateKeyWs

        "REGISTER" ->
            Register

        "REGISTER_ERROR" ->
            RegisterError

        "REGISTER_NEW" ->
            RegisterNew

        "REGISTER_SUCCESS" ->
            RegisterSuccess

        "REQUEST_ERROR" ->
            RequestError

        "SETTINGS" ->
            Settings

        "SETTINGS_NOTICE" ->
            SettingsNotice

        "TAGLINE" ->
            Tagline

        "THEME" ->
            Theme

        "THEME_DARK" ->
            ThemeDark

        "THEME_LIGHT" ->
            ThemeLight

        "THEME_TATTY" ->
            ThemeTatty

        "TO_POST" ->
            ToPost

        "UNEXPECTED_REGISTER_ERROR" ->
            UnexpectedRegisterError

        "UNKNOWN_ERROR" ->
            UnknownError

        "USERNAME" ->
            Username

        "USERNAME_EMPTY" ->
            UsernameEmpty

        "USERNAME_INVALID" ->
            UsernameInvalid

        "USERNAME_IN_USE" ->
            UsernameInUse

        "USER_NOT_FOUND" ->
            UserNotFound

        "YES" ->
            Yes

        _ ->
            UnknownError


keyToString : Key -> String
keyToString key =
    case key of
        AllPostsLoaded ->
            "ALL_POSTS_LOADED"

        AutoLogout ->
            "AUTO_LOGOUT"

        AutoLogoutHint ->
            "AUTO_LOGOUT_HINT"

        BuyMePizza ->
            "BUY_ME_PIZZA"

        ClearPost ->
            "CLEAR_POST"

        CredentialsIncorrect ->
            "CREDENTIALS_INCORRECT"

        Credits ->
            "CREDITS"

        DecryptError ->
            "DECRYPT_ERROR"

        DeleteConfirm ->
            "DELETE_CONFIRM"

        Description ->
            "DESCRIPTION"

        EncryptError ->
            "ENCRYPT_ERROR"

        English ->
            "ENGLISH"

        ForbiddenArea ->
            "FORBIDDEN_AREA"

        InputEmpty ->
            "INPUT_EMPTY"

        InvalidInputs ->
            "INVALID_INPUTS"

        InviteCode ->
            "INVITE_CODE"

        InviteCodeInvalid ->
            "INVITE_CODE_INVALID"

        InviteCountError ->
            "INVITE_COUNT_ERROR"

        InviteError ->
            "INVITE_ERROR"

        InviteFetchError ->
            "INVITE_FETCH_ERROR"

        InviteGenerate ->
            "INVITE_GENERATE"

        InviteHelp ->
            "INVITE_HELP"

        InvitePending ->
            "INVITE_PENDING"

        InviteUsed ->
            "INVITE_USED"

        Language ->
            "LANGUAGE"

        Loading ->
            "LOADING"

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

        No ->
            "NO"

        NoPost ->
            "NO_POST"

        Portuguese ->
            "PORTUGUESE"

        PostsNoMore ->
            "POSTS_NO_MORE"

        PostAbout ->
            "POST_ABOUT"

        PostEncrypted ->
            "POST_ENCRYPTED"

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

        Settings ->
            "SETTINGS"

        SettingsNotice ->
            "SETTINGS_NOTICE"

        Tagline ->
            "TAGLINE"

        Theme ->
            "THEME"

        ThemeDark ->
            "THEME_DARK"

        ThemeLight ->
            "THEME_LIGHT"

        ThemeTatty ->
            "THEME_TATTY"

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

        Yes ->
            "YES"


translate : Language -> Key -> String
translate lang key =
    let
        langString =
            lang |> languageToString

        keyString =
            key |> keyToString
    in
    Dict.get keyString phrases
        |> (\maybePhrases -> Maybe.andThen (Dict.get langString) maybePhrases)
        |> (\maybePhrase -> Maybe.withDefault keyString maybePhrase)


phrases : Dict.Dict String (Dict.Dict String String)
phrases =
    Dict.fromList
        [ ( "ALL_POSTS_LOADED"
          , Dict.fromList
                [ ( "en", "All posts loaded" )
                , ( "pt", "Todos os posts carregados" )
                ]
          )
        , ( "AUTO_LOGOUT"
          , Dict.fromList
                [ ( "en", "Auto logout" ), ( "pt", "Logout automático" ) ]
          )
        , ( "AUTO_LOGOUT_HINT"
          , Dict.fromList
                [ ( "en"
                  , "Activating this setting will log you out anytime you change tabs in your browser."
                  )
                , ( "pt"
                  , "Ao ativar esta configuração você fará logout sempre que mudar de aba no seu navegador."
                  )
                ]
          )
        , ( "BUY_ME_PIZZA"
          , Dict.fromList
                [ ( "en", "buy me a pizza 🍕" )
                , ( "pt", "me compre uma pizza 🍕" )
                ]
          )
        , ( "CLEAR_POST"
          , Dict.fromList [ ( "en", "Clear post" ), ( "pt", "Cancelar post" ) ]
          )
        , ( "CREDENTIALS_INCORRECT"
          , Dict.fromList
                [ ( "en"
                  , "Username or private key incorrect. Please, try again"
                  )
                , ( "pt"
                  , "Nome de usuário ou chave privada incorretos. Por favor, tente novamente"
                  )
                ]
          )
        , ( "CREDITS"
          , Dict.fromList
                [ ( "en", "created with ❤️ by" )
                , ( "pt", "criado com amor ❤️ por" )
                ]
          )
        , ( "DECRYPT_ERROR"
          , Dict.fromList
                [ ( "en", "There was an error during decryption" )
                , ( "pt", "Ocorreu um erro no processo de descriptografia" )
                ]
          )
        , ( "DELETE_CONFIRM"
          , Dict.fromList
                [ ( "en"
                  , "Are you sure you want to delete this post? This action is final."
                  )
                , ( "pt"
                  , "Você tem certeza que deseja apagar este post? Esta ação é final."
                  )
                ]
          )
        , ( "DESCRIPTION"
          , Dict.fromList
                [ ( "en"
                  , "Capsulen is a compact journaling application inspired by microblogs. It encrypts all your data in the browser before persisting it on the server, ensuring that only the individual with the private key can access the contents of the journal."
                  )
                , ( "pt"
                  , "Capsulen é um aplicativo de diário compacto inspirado em microblogs. Ele criptografa todos os seus dados no navegador antes de persisti-los no servidor, garantindo que apenas a pessoa com a chave privada possa acessar o conteúdo do diário."
                  )
                ]
          )
        , ( "ENCRYPT_ERROR"
          , Dict.fromList
                [ ( "en", "There was an error during encryption" )
                , ( "pt", "Ocorreu um error no processo de criptografia" )
                ]
          )
        , ( "ENGLISH"
          , Dict.fromList [ ( "en", "English" ), ( "pt", "Inglês" ) ]
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
        , ( "INVITE_CODE"
          , Dict.fromList
                [ ( "en", "Invite code" ), ( "pt", "Código de convite" ) ]
          )
        , ( "INVITE_CODE_INVALID"
          , Dict.fromList
                [ ( "en", "This invite code looks invalid." )
                , ( "pt", "Este código de convite parece incorreto." )
                ]
          )
        , ( "INVITE_COUNT_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "You have already created the maximum of pending invites."
                  )
                , ( "pt", "Você já criou o máximo de convites pendentes." )
                ]
          )
        , ( "INVITE_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error while creating your invite. Please, try again."
                  )
                , ( "pt"
                  , "Ocorreu um erro ao criar seu convite. Por favor, tente novamente."
                  )
                ]
          )
        , ( "INVITE_FETCH_ERROR"
          , Dict.fromList
                [ ( "en"
                  , "There was an error while fetching your invites. Please, try again."
                  )
                , ( "pt"
                  , "Ocorreu um erro ao resgatar seus convites. Por favor, tente novamente."
                  )
                ]
          )
        , ( "INVITE_GENERATE"
          , Dict.fromList
                [ ( "en", "Generate invite code" ), ( "pt", "Gerar convite" ) ]
          )
        , ( "INVITE_HELP"
          , Dict.fromList
                [ ( "en"
                  , "The only way to create new accounts is with invite codes. You can generate new invite codes here and share as you please. You can only have 3 pending invite codes at a time. Share your codes responsibly."
                  )
                , ( "pt"
                  , "A única forma de criar novas contas é através de convites. Você pode gerar novos convites aqui e compartilhar como e com quem quiser. Você só pode ter 3 convites pendentes ao mesmo tempo. Compartilhe seus convites com responsabilidade."
                  )
                ]
          )
        , ( "INVITE_PENDING"
          , Dict.fromList [ ( "en", "Pending" ), ( "pt", "Pendente" ) ]
          )
        , ( "INVITE_USED"
          , Dict.fromList [ ( "en", "Used" ), ( "pt", "Usado" ) ]
          )
        , ( "LANGUAGE"
          , Dict.fromList [ ( "en", "Language" ), ( "pt", "Idioma" ) ]
          )
        , ( "LOADING"
          , Dict.fromList [ ( "en", "Loading" ), ( "pt", "Carregando" ) ]
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
        , ( "NO", Dict.fromList [ ( "en", "No" ), ( "pt", "Não" ) ] )
        , ( "NO_POST"
          , Dict.fromList [ ( "en", "No posts" ), ( "pt", "Sem posts" ) ]
          )
        , ( "PORTUGUESE"
          , Dict.fromList [ ( "en", "Portuguese" ), ( "pt", "Português" ) ]
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
        , ( "POST_ENCRYPTED"
          , Dict.fromList
                [ ( "en", "This post is encrypted" )
                , ( "pt", "Este post está criptografado" )
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
        , ( "SETTINGS"
          , Dict.fromList [ ( "en", "Settings" ), ( "pt", "Configurações" ) ]
          )
        , ( "SETTINGS_NOTICE"
          , Dict.fromList
                [ ( "en"
                  , "All settings are stored in browser. This means your changes won't be carried to other browsers or computers."
                  )
                , ( "pt"
                  , "Todas as configurações são guardadas no seu navegador. Isto significa que as alterações não serão replicadas em outros navegadores ou computadores."
                  )
                ]
          )
        , ( "TAGLINE"
          , Dict.fromList
                [ ( "en", "“Journaling made safe and simple”" )
                , ( "pt", "“Um diário seguro e simples”" )
                ]
          )
        , ( "THEME"
          , Dict.fromList
                [ ( "en", "Color theme" ), ( "pt", "Esquema de cores" ) ]
          )
        , ( "THEME_DARK", Dict.fromList [ ( "en", "Dark" ), ( "pt", "Dark" ) ] )
        , ( "THEME_LIGHT"
          , Dict.fromList [ ( "en", "Light" ), ( "pt", "Light" ) ]
          )
        , ( "THEME_TATTY"
          , Dict.fromList [ ( "en", "Tatty" ), ( "pt", "Tatty" ) ]
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
        , ( "YES", Dict.fromList [ ( "en", "Yes" ), ( "pt", "Sim" ) ] )
        ]