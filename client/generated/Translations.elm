module Translations exposing (..)

import Dict


type Language
    = De
    | En
    | Es
    | Fr
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
    | French
    | German
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
    | Spanish
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
        "de" ->
            De

        "en" ->
            En

        "es" ->
            Es

        "fr" ->
            Fr

        "pt" ->
            Pt

        _ ->
            De


languageToString : Language -> String
languageToString language =
    case language of
        De ->
            "de"

        En ->
            "en"

        Es ->
            "es"

        Fr ->
            "fr"

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

        "FRENCH" ->
            French

        "GERMAN" ->
            German

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

        "SPANISH" ->
            Spanish

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

        French ->
            "FRENCH"

        German ->
            "GERMAN"

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

        Spanish ->
            "SPANISH"

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
                [ ( "de", "Alle Beiträge geladen" )
                , ( "en", "All posts loaded" )
                , ( "es", "Todas las publicaciones cargadas" )
                , ( "fr", "Toutes les publications chargées" )
                , ( "pt", "Todos os posts carregados" )
                ]
          )
        , ( "AUTO_LOGOUT"
          , Dict.fromList
                [ ( "de", "Automatischer Logout" )
                , ( "en", "Auto logout" )
                , ( "es", "Cierre de sesión automático" )
                , ( "fr", "Déconnexion automatique" )
                , ( "pt", "Logout automático" )
                ]
          )
        , ( "AUTO_LOGOUT_HINT"
          , Dict.fromList
                [ ( "de"
                  , "Das Aktivieren dieser Einstellung meldet Sie automatisch ab, wenn Sie die Registerkarten in Ihrem Browser ändern."
                  )
                , ( "en"
                  , "Activating this setting will log you out anytime you change tabs in your browser."
                  )
                , ( "es"
                  , "Activar esta configuración cerrará tu sesión cada vez que cambies de pestaña en tu navegador."
                  )
                , ( "fr"
                  , "L'activation de ce paramètre vous déconnectera à chaque fois que vous changerez d'onglet dans votre navigateur."
                  )
                , ( "pt"
                  , "Ao ativar esta configuração você fará logout sempre que mudar de aba no seu navegador."
                  )
                ]
          )
        , ( "BUY_ME_PIZZA"
          , Dict.fromList
                [ ( "de", "kauf mir eine Pizza 🍕" )
                , ( "en", "buy me a pizza 🍕" )
                , ( "es", "cómprame una pizza 🍕" )
                , ( "fr", "achète-moi une pizza 🍕" )
                , ( "pt", "me compre uma pizza 🍕" )
                ]
          )
        , ( "CLEAR_POST"
          , Dict.fromList
                [ ( "de", "Beitrag löschen" )
                , ( "en", "Clear post" )
                , ( "es", "Limpiar publicación" )
                , ( "fr", "Effacer la publication" )
                , ( "pt", "Limpar post" )
                ]
          )
        , ( "CREDENTIALS_INCORRECT"
          , Dict.fromList
                [ ( "de"
                  , "Benutzername oder privater Schlüssel falsch. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "Username or private key incorrect. Please try again."
                  )
                , ( "es"
                  , "Nombre de usuario o clave privada incorrectos. Por favor, inténtelo de nuevo."
                  )
                , ( "fr"
                  , "Nom d'utilisateur ou clé privée incorrects. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Nome de usuário ou chave privada incorretos. Por favor, tente novamente."
                  )
                ]
          )
        , ( "CREDITS"
          , Dict.fromList
                [ ( "de", "erstellt mit ❤️ von" )
                , ( "en", "created with ❤️ by" )
                , ( "es", "creado con ❤️ por" )
                , ( "fr", "créé avec ❤️ par" )
                , ( "pt", "criado com amor ❤️ por" )
                ]
          )
        , ( "DECRYPT_ERROR"
          , Dict.fromList
                [ ( "de", "Es gab einen Fehler während der Entschlüsselung" )
                , ( "en", "There was an error during decryption" )
                , ( "es", "Hubo un error durante el descifrado" )
                , ( "fr", "Une erreur s'est produite pendant le décryptage" )
                , ( "pt", "Ocorreu um erro no processo de descriptografia" )
                ]
          )
        , ( "DELETE_CONFIRM"
          , Dict.fromList
                [ ( "de"
                  , "Möchten Sie diesen Beitrag wirklich löschen? Diese Aktion ist endgültig."
                  )
                , ( "en"
                  , "Are you sure you want to delete this post? This action is final."
                  )
                , ( "es"
                  , "¿Estás seguro de que quieres eliminar esta publicación? Esta acción es definitiva."
                  )
                , ( "fr"
                  , "Êtes-vous sûr de vouloir supprimer cette publication ? Cette action est définitive."
                  )
                , ( "pt"
                  , "Você tem certeza que deseja apagar este post? Esta ação é final."
                  )
                ]
          )
        , ( "DESCRIPTION"
          , Dict.fromList
                [ ( "de"
                  , "Capsulen ist eine kompakte Tagebuchanwendung, die von Microblogs inspiriert wurde. Es verschlüsselt alle Ihre Daten im Browser, bevor es sie auf dem Server persistiert, und stellt sicher, dass nur die Person mit dem privaten Schlüssel auf den Inhalt des Tagebuchs zugreifen kann."
                  )
                , ( "en"
                  , "Capsulen is a compact journaling application inspired by microblogs. It encrypts all your data in the browser before persisting it on the server, ensuring that only the individual with the private key can access the contents of the journal."
                  )
                , ( "es"
                  , "Capsulen es una aplicación compacta de diario inspirada en microblogs. Encripta todos tus datos en el navegador antes de persistirlos en el servidor, asegurando que solo la persona con la clave privada pueda acceder al contenido del diario."
                  )
                , ( "fr"
                  , "Capsulen est une application de journal compacte inspirée des microblogs. Il chiffre toutes vos données dans le navigateur avant de les persister sur le serveur, garantissant que seule la personne avec la clé privée peut accéder au contenu du journal."
                  )
                , ( "pt"
                  , "Capsulen é um aplicativo de diário compacto inspirado em microblogs. Ele criptografa todos os seus dados no navegador antes de persisti-los no servidor, garantindo que apenas a pessoa com a chave privada possa acessar o conteúdo do diário."
                  )
                ]
          )
        , ( "ENCRYPT_ERROR"
          , Dict.fromList
                [ ( "de", "Es gab einen Fehler während der Verschlüsselung" )
                , ( "en", "There was an error during encryption" )
                , ( "es", "Hubo un error durante el cifrado" )
                , ( "fr", "Une erreur s'est produite pendant le chiffrement" )
                , ( "pt", "Ocorreu um error no processo de criptografia" )
                ]
          )
        , ( "ENGLISH"
          , Dict.fromList
                [ ( "de", "Englisch" )
                , ( "en", "English" )
                , ( "es", "Inglés" )
                , ( "fr", "Anglais" )
                , ( "pt", "Inglês" )
                ]
          )
        , ( "FORBIDDEN_AREA"
          , Dict.fromList
                [ ( "de"
                  , "Sie müssen angemeldet sein, um diese Seite zu sehen. Bitte melden Sie sich an."
                  )
                , ( "en"
                  , "You need to be logged in to see this page. Please log in."
                  )
                , ( "es"
                  , "Necesitas iniciar sesión para ver esta página. Por favor, inicia sesión."
                  )
                , ( "fr"
                  , "Vous devez être connecté pour voir cette page. Veuillez vous connecter."
                  )
                , ( "pt"
                  , "Você precisa ter feito login para acessar esta página."
                  )
                ]
          )
        , ( "FRENCH"
          , Dict.fromList
                [ ( "de", "Französisch" )
                , ( "en", "French" )
                , ( "es", "Francés" )
                , ( "fr", "Français" )
                , ( "pt", "Francês" )
                ]
          )
        , ( "GERMAN"
          , Dict.fromList
                [ ( "de", "Deutsch" )
                , ( "en", "German" )
                , ( "es", "Alemán" )
                , ( "fr", "Allemand" )
                , ( "pt", "Alemão" )
                ]
          )
        , ( "INPUT_EMPTY"
          , Dict.fromList
                [ ( "de", "Dieses Feld darf nicht leer sein." )
                , ( "en", "This field can't be empty." )
                , ( "es", "Este campo no puede estar vacío." )
                , ( "fr", "Ce champ ne peut pas être vide." )
                , ( "pt", "Este campo não pode ficar vazio." )
                ]
          )
        , ( "INVALID_INPUTS"
          , Dict.fromList
                [ ( "de"
                  , "Ein oder mehrere Eingaben sind ungültig. Überprüfen Sie die Meldungen im Formular und versuchen Sie es erneut."
                  )
                , ( "en"
                  , "One or more inputs are invalid. Check the messages in the form to fix and try again."
                  )
                , ( "es"
                  , "Uno o más campos son inválidos. Verifique los mensajes en el formulario para corregirlo e inténtelo de nuevo."
                  )
                , ( "fr"
                  , "Une ou plusieurs entrées sont invalides. Vérifiez les messages dans le formulaire pour corriger et réessayer."
                  )
                , ( "pt"
                  , "Um ou mais campos estão incorretos. Verifique as mensagens no formulário e tente novamente."
                  )
                ]
          )
        , ( "INVITE_CODE"
          , Dict.fromList
                [ ( "de", "Einladungscode" )
                , ( "en", "Invite code" )
                , ( "es", "Código de invitación" )
                , ( "fr", "Code d'invitation" )
                , ( "pt", "Código de convite" )
                ]
          )
        , ( "INVITE_CODE_INVALID"
          , Dict.fromList
                [ ( "de", "Dieser Einladungscode sieht ungültig aus." )
                , ( "en", "This invite code looks invalid." )
                , ( "es", "Este código de invitación parece inválido." )
                , ( "fr", "Ce code d'invitation semble invalide." )
                , ( "pt", "Este código de convite parece incorreto." )
                ]
          )
        , ( "INVITE_COUNT_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Sie haben bereits das Maximum an ausstehenden Einladungen erstellt."
                  )
                , ( "en"
                  , "You have already created the maximum of pending invites."
                  )
                , ( "es"
                  , "Ya has creado el máximo de invitaciones pendientes."
                  )
                , ( "fr"
                  , "Vous avez déjà créé le maximum d'invitations en attente."
                  )
                , ( "pt", "Você já criou o máximo de convites pendentes." )
                ]
          )
        , ( "INVITE_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Beim Erstellen Ihrer Einladung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error while creating your invite. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al crear tu invitación. Por favor, inténtalo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors de la création de votre invitation. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Ocorreu um erro ao criar seu convite. Por favor, tente novamente."
                  )
                ]
          )
        , ( "INVITE_FETCH_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Beim Abrufen Ihrer Einladungen ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error while fetching your invites. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al recuperar tus invitaciones. Por favor, inténtalo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors de la récupération de vos invitations. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Ocorreu um erro ao resgatar seus convites. Por favor, tente novamente."
                  )
                ]
          )
        , ( "INVITE_GENERATE"
          , Dict.fromList
                [ ( "de", "Einladungscode generieren" )
                , ( "en", "Generate invite code" )
                , ( "es", "Generar código de invitación" )
                , ( "fr", "Générer un code d'invitation" )
                , ( "pt", "Gerar convite" )
                ]
          )
        , ( "INVITE_HELP"
          , Dict.fromList
                [ ( "de"
                  , "Die einzige Möglichkeit, neue Konten zu erstellen, besteht darin, Einladungscodes zu verwenden. Sie können hier neue Einladungscodes generieren und sie nach Belieben teilen. Sie können gleichzeitig nur 3 ausstehende Einladungscodes haben, und wenn sie nicht verwendet werden, werden sie nach 1 Tag gelöscht. Teilen Sie Ihre Codes verantwortungsbewusst."
                  )
                , ( "en"
                  , "The only way to create new accounts is with invite codes. You can generate new invite codes here and share as you please. You can only have 3 pending invite codes at a time and if not used, they will be deleted after 1 day. Share your codes responsibly."
                  )
                , ( "es"
                  , "La única forma de crear nuevas cuentas es con códigos de invitación. Puedes generar nuevos códigos de invitación aquí y compartirlos como desees. Solo puedes tener 3 códigos de invitación pendientes a la vez y, si no se utilizan, se eliminarán después de 1 día. Comparte tus códigos de manera responsable."
                  )
                , ( "fr"
                  , "La seule façon de créer de nouveaux comptes est avec des codes d'invitation. Vous pouvez générer de nouveaux codes d'invitation ici et les partager comme bon vous semble. Vous ne pouvez avoir que 3 codes d'invitation en attente à la fois et s'ils ne sont pas utilisés, ils seront supprimés après 1 jour. Partagez vos codes de manière responsable."
                  )
                , ( "pt"
                  , "A única forma de criar novas contas é através de convites. Você pode gerar novos convites aqui e compartilhar como e com quem quiser. Você só pode ter 3 convites pendentes ao mesmo tempo e se não usados eles serão deletados depois de 1 dia. Compartilhe seus convites com responsabilidade."
                  )
                ]
          )
        , ( "INVITE_PENDING"
          , Dict.fromList
                [ ( "de", "Ausstehend" )
                , ( "en", "Pending" )
                , ( "es", "Pendiente" )
                , ( "fr", "En attente" )
                , ( "pt", "Pendente" )
                ]
          )
        , ( "INVITE_USED"
          , Dict.fromList
                [ ( "de", "Verwendet" )
                , ( "en", "Used" )
                , ( "es", "Usado" )
                , ( "fr", "Utilisé" )
                , ( "pt", "Usado" )
                ]
          )
        , ( "LANGUAGE"
          , Dict.fromList
                [ ( "de", "Sprache" )
                , ( "en", "Language" )
                , ( "es", "Idioma" )
                , ( "fr", "Langue" )
                , ( "pt", "Idioma" )
                ]
          )
        , ( "LOADING"
          , Dict.fromList
                [ ( "de", "Laden" )
                , ( "en", "Loading" )
                , ( "es", "Cargando" )
                , ( "fr", "Chargement" )
                , ( "pt", "Carregando" )
                ]
          )
        , ( "LOAD_MORE_POSTS"
          , Dict.fromList
                [ ( "de", "Mehr Beiträge laden" )
                , ( "en", "Load more posts" )
                , ( "es", "Cargar más publicaciones" )
                , ( "fr", "Charger plus de publications" )
                , ( "pt", "Carregar mais postagens" )
                ]
          )
        , ( "LOGIN"
          , Dict.fromList
                [ ( "de", "Anmelden" )
                , ( "en", "Login" )
                , ( "es", "Iniciar sesión" )
                , ( "fr", "Connexion" )
                , ( "pt", "Entrar" )
                ]
          )
        , ( "LOGIN_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Es gab einen Fehler beim Versuch, sich anzumelden. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error trying to log you in. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al intentar iniciar sesión. Por favor, inténtelo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors de la tentative de connexion. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Houve um erro ao tentar acessar sua conta. Por favor, tente novamente."
                  )
                ]
          )
        , ( "LOGOUT"
          , Dict.fromList
                [ ( "de", "Abmelden" )
                , ( "en", "Logout" )
                , ( "es", "Cerrar sesión" )
                , ( "fr", "Déconnexion" )
                , ( "pt", "Sair" )
                ]
          )
        , ( "LOGOUT_SUCCESS"
          , Dict.fromList
                [ ( "de", "Bis bald!" )
                , ( "en", "See you soon!" )
                , ( "es", "¡Hasta pronto!" )
                , ( "fr", "À bientôt !" )
                , ( "pt", "Até breve!" )
                ]
          )
        , ( "NO"
          , Dict.fromList
                [ ( "de", "Nein" )
                , ( "en", "No" )
                , ( "es", "No" )
                , ( "fr", "Non" )
                , ( "pt", "Não" )
                ]
          )
        , ( "NO_POST"
          , Dict.fromList
                [ ( "de", "Keine Beiträge" )
                , ( "en", "No posts" )
                , ( "es", "No hay publicaciones" )
                , ( "fr", "Pas de publications" )
                , ( "pt", "Sem posts" )
                ]
          )
        , ( "PORTUGUESE"
          , Dict.fromList
                [ ( "de", "Portugiesisch" )
                , ( "en", "Portuguese" )
                , ( "es", "Portugués" )
                , ( "fr", "Portugais" )
                , ( "pt", "Português" )
                ]
          )
        , ( "POSTS_NO_MORE"
          , Dict.fromList
                [ ( "de", "Es gibt keine weiteren Beiträge zum Laden" )
                , ( "en", "There are no more posts to load" )
                , ( "es", "No hay más publicaciones para cargar" )
                , ( "fr", "Il n'y a plus de publications à charger" )
                , ( "pt", "Não há mais postagens a serem carregadas" )
                ]
          )
        , ( "POST_ABOUT"
          , Dict.fromList
                [ ( "de", "Worüber möchtest du schreiben?" )
                , ( "en", "What do you want to write about?" )
                , ( "es", "¿Sobre qué quieres escribir?" )
                , ( "fr", "De quoi voulez-vous écrire ?" )
                , ( "pt", "Sobre o que você quer escrever?" )
                ]
          )
        , ( "POST_ENCRYPTED"
          , Dict.fromList
                [ ( "de", "Dieser Beitrag ist verschlüsselt" )
                , ( "en", "This post is encrypted" )
                , ( "es", "Esta publicación está cifrada" )
                , ( "fr", "Cette publication est chiffrée" )
                , ( "pt", "Este post está criptografado" )
                ]
          )
        , ( "POST_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Es gab einen Fehler beim Speichern Ihres Beitrags. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error saving your post. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al guardar tu publicación. Por favor, inténtalo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors de l'enregistrement de votre publication. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Houve um erro ao salvar sua postagem. Por favor, tente novamente."
                  )
                ]
          )
        , ( "POST_FETCH_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Es gab einen Fehler beim Abrufen Ihrer Beiträge. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error fetching your posts. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al recuperar tus publicaciones. Por favor, inténtalo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors de la récupération de vos publications. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Houve um erro ao buscar seus posts. Por favor, tente novamente."
                  )
                ]
          )
        , ( "POST_NEW"
          , Dict.fromList
                [ ( "de", "Neuer Beitrag hinzugefügt" )
                , ( "en", "New post added" )
                , ( "es", "Nueva publicación añadida" )
                , ( "fr", "Nouvelle publication ajoutée" )
                , ( "pt", "Novo post adicionado" )
                ]
          )
        , ( "PRIVATE_KEY"
          , Dict.fromList
                [ ( "de", "Privater Schlüssel" )
                , ( "en", "Private key" )
                , ( "es", "Clave privada" )
                , ( "fr", "Clé privée" )
                , ( "pt", "Chave privada" )
                ]
          )
        , ( "PRIVATE_KEY_NOTICE"
          , Dict.fromList
                [ ( "de"
                  , "Ihr privater Schlüssel wird niemals über das Netzwerk gesendet"
                  )
                , ( "en"
                  , "Your private key will never be sent over the network"
                  )
                , ( "es", "Tu clave privada nunca se enviará por la red" )
                , ( "fr"
                  , "Votre clé privée ne sera jamais envoyée sur le réseau"
                  )
                , ( "pt", "Sua chave privada nunca será enviada pela rede" )
                ]
          )
        , ( "PRIVATE_KEY_SHORT"
          , Dict.fromList
                [ ( "de"
                  , "Der private Schlüssel muss mehr als 4 Zeichen haben"
                  )
                , ( "en", "Private key must have more than 4 characters" )
                , ( "es", "La clave privada debe tener más de 4 caracteres" )
                , ( "fr", "La clé privée doit contenir plus de 4 caractères" )
                , ( "pt", "Chave privada precisa ter mais que 4 caracteres" )
                ]
          )
        , ( "PRIVATE_KEY_WS"
          , Dict.fromList
                [ ( "de"
                  , "Vermeiden Sie Leerzeichen am Anfang und Ende des privaten Schlüssels"
                  )
                , ( "en"
                  , "Avoid spaces at the beginning and end of the private key"
                  )
                , ( "es"
                  , "Evita espacios al principio y al final de la clave privada"
                  )
                , ( "fr"
                  , "Évitez les espaces au début et à la fin de la clé privée"
                  )
                , ( "pt"
                  , "Evite espaços no início e final de sua chave privada"
                  )
                ]
          )
        , ( "REGISTER"
          , Dict.fromList
                [ ( "de", "Registrieren" )
                , ( "en", "Register" )
                , ( "es", "Registrarse" )
                , ( "fr", "S'inscrire" )
                , ( "pt", "Registrar conta" )
                ]
          )
        , ( "REGISTER_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Es gab einen Fehler bei der Registrierung Ihres Kontos. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error registering your account. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al registrar tu cuenta. Por favor, inténtalo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors de l'inscription de votre compte. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Houve um erro ao registrar sua conta. Por favor, tente novamente."
                  )
                ]
          )
        , ( "REGISTER_NEW"
          , Dict.fromList
                [ ( "de", "Neues Konto registrieren" )
                , ( "en", "Register new account" )
                , ( "es", "Registrar nueva cuenta" )
                , ( "fr", "Inscrire un nouveau compte" )
                , ( "pt", "Registrar nova conta" )
                ]
          )
        , ( "REGISTER_SUCCESS"
          , Dict.fromList
                [ ( "de"
                  , "Registrierung erfolgreich! Bitte melden Sie sich jetzt an."
                  )
                , ( "en", "Registration successful! Please log in now." )
                , ( "es", "¡Registro exitoso! Por favor, inicia sesión ahora." )
                , ( "fr"
                  , "Inscription réussie ! Veuillez vous connecter maintenant."
                  )
                , ( "pt"
                  , "Registro realizado com sucesso! Você pode acessar sua conta agora."
                  )
                ]
          )
        , ( "REQUEST_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Es gab einen Fehler bei der Verarbeitung Ihrer Anfrage. Bitte versuchen Sie es erneut."
                  )
                , ( "en"
                  , "There was an error processing your request. Please try again."
                  )
                , ( "es"
                  , "Hubo un error al procesar tu solicitud. Por favor, inténtalo de nuevo."
                  )
                , ( "fr"
                  , "Une erreur s'est produite lors du traitement de votre demande. Veuillez réessayer."
                  )
                , ( "pt"
                  , "Ocorreu um erro ao realizar esta requisição. Por favor, tente novamente."
                  )
                ]
          )
        , ( "SETTINGS"
          , Dict.fromList
                [ ( "de", "Einstellungen" )
                , ( "en", "Settings" )
                , ( "es", "Configuración" )
                , ( "fr", "Paramètres" )
                , ( "pt", "Configurações" )
                ]
          )
        , ( "SETTINGS_NOTICE"
          , Dict.fromList
                [ ( "de"
                  , "Alle Einstellungen werden im Browser gespeichert. Das bedeutet, dass Ihre Änderungen nicht auf andere Browser oder Computer übertragen werden."
                  )
                , ( "en"
                  , "All settings are stored in the browser. This means your changes won't be carried to other browsers or computers."
                  )
                , ( "es"
                  , "Todas las configuraciones se almacenan en el navegador. Esto significa que tus cambios no se transferirán a otros navegadores o computadoras."
                  )
                , ( "fr"
                  , "Tous les paramètres sont stockés dans le navigateur. Cela signifie que vos modifications ne seront pas transférées vers d'autres navigateurs ou ordinateurs."
                  )
                , ( "pt"
                  , "Todas as configurações são guardadas no seu navegador. Isto significa que as alterações não serão replicadas em outros navegadores ou computadores."
                  )
                ]
          )
        , ( "SPANISH"
          , Dict.fromList
                [ ( "de", "Spanisch" )
                , ( "en", "Spanish" )
                , ( "es", "Español" )
                , ( "fr", "Espagnol" )
                , ( "pt", "Espanhol" )
                ]
          )
        , ( "TAGLINE"
          , Dict.fromList
                [ ( "de", "„Tagebuchführung sicher und einfach gemacht“" )
                , ( "en", "“Journaling made safe and simple”" )
                , ( "es", "“Llevar un diario seguro y simple”" )
                , ( "fr", "“Tenir un journal en toute sécurité et simplicité”" )
                , ( "pt", "“Um diário seguro e simples”" )
                ]
          )
        , ( "THEME"
          , Dict.fromList
                [ ( "de", "Farbschema" )
                , ( "en", "Color theme" )
                , ( "es", "Tema de color" )
                , ( "fr", "Thème de couleur" )
                , ( "pt", "Esquema de cores" )
                ]
          )
        , ( "THEME_DARK"
          , Dict.fromList
                [ ( "de", "Dunkel" )
                , ( "en", "Dark" )
                , ( "es", "Oscuro" )
                , ( "fr", "Sombre" )
                , ( "pt", "Escuro" )
                ]
          )
        , ( "THEME_LIGHT"
          , Dict.fromList
                [ ( "de", "Hell" )
                , ( "en", "Light" )
                , ( "es", "Claro" )
                , ( "fr", "Clair" )
                , ( "pt", "Claro" )
                ]
          )
        , ( "THEME_TATTY"
          , Dict.fromList
                [ ( "de", "Tatty" )
                , ( "en", "Tatty" )
                , ( "es", "Tatty" )
                , ( "fr", "Tatty" )
                , ( "pt", "Tatty" )
                ]
          )
        , ( "TO_POST"
          , Dict.fromList
                [ ( "de", "Beitrag" )
                , ( "en", "Post" )
                , ( "es", "Publicar" )
                , ( "fr", "Publier" )
                , ( "pt", "Postar" )
                ]
          )
        , ( "UNEXPECTED_REGISTER_ERROR"
          , Dict.fromList
                [ ( "de"
                  , "Unerwarteter Fehler bei der Bearbeitung Ihrer Registrierungsanfrage"
                  )
                , ( "en"
                  , "Unexpected error while handling your registration request"
                  )
                , ( "es"
                  , "Error inesperado al manejar tu solicitud de registro"
                  )
                , ( "fr"
                  , "Erreur inattendue lors du traitement de votre demande d'inscription"
                  )
                , ( "pt"
                  , "Erro inesperado ao lidar com seu pedido de registro"
                  )
                ]
          )
        , ( "UNKNOWN_ERROR"
          , Dict.fromList
                [ ( "de", "Unbekannter Fehler" )
                , ( "en", "Unknown error" )
                , ( "es", "Error desconocido" )
                , ( "fr", "Erreur inconnue" )
                , ( "pt", "Erro desconhecido" )
                ]
          )
        , ( "USERNAME"
          , Dict.fromList
                [ ( "de", "Benutzername" )
                , ( "en", "Username" )
                , ( "es", "Nombre de usuario" )
                , ( "fr", "Nom d'utilisateur" )
                , ( "pt", "Nome de usuário" )
                ]
          )
        , ( "USERNAME_EMPTY"
          , Dict.fromList
                [ ( "de", "Benutzername darf nicht leer sein" )
                , ( "en", "Username can't be empty" )
                , ( "es", "El nombre de usuario no puede estar vacío" )
                , ( "fr", "Le nom d'utilisateur ne peut pas être vide" )
                , ( "pt", "Nome de usuário não pode ficar vazio" )
                ]
          )
        , ( "USERNAME_INVALID"
          , Dict.fromList
                [ ( "de"
                  , "Benutzername darf nur Buchstaben, Zahlen und Unterstriche (_) enthalten"
                  )
                , ( "en"
                  , "Username must contain only letters, numbers and underscores (_)"
                  )
                , ( "es"
                  , "El nombre de usuario debe contener solo letras, números y guiones bajos (_)"
                  )
                , ( "fr"
                  , "Le nom d'utilisateur ne peut contenir que des lettres, des chiffres et des traits de soulignement (_)"
                  )
                , ( "pt"
                  , "Nome de usuário pode conter apenas letras, números e underscoders (_)"
                  )
                ]
          )
        , ( "USERNAME_IN_USE"
          , Dict.fromList
                [ ( "de"
                  , "Benutzername wird bereits verwendet. Bitte wählen Sie einen anderen Benutzernamen"
                  )
                , ( "en"
                  , "Username is already in use. Please, pick a different username"
                  )
                , ( "es"
                  , "El nombre de usuario ya está en uso. Por favor, elige un nombre de usuario diferente"
                  )
                , ( "fr"
                  , "Le nom d'utilisateur est déjà utilisé. Veuillez choisir un nom d'utilisateur différent"
                  )
                , ( "pt"
                  , "Nome de usuário já cadastrado. Escolha um diferente e tente novamente"
                  )
                ]
          )
        , ( "USER_NOT_FOUND"
          , Dict.fromList
                [ ( "de", "Benutzer nicht gefunden" )
                , ( "en", "User not found" )
                , ( "es", "Usuario no encontrado" )
                , ( "fr", "Utilisateur introuvable" )
                , ( "pt", "Usuário não encontrado" )
                ]
          )
        , ( "YES"
          , Dict.fromList
                [ ( "de", "Ja" )
                , ( "en", "Yes" )
                , ( "es", "Sí" )
                , ( "fr", "Oui" )
                , ( "pt", "Sim" )
                ]
          )
        ]