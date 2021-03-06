defmodule PhoenixBackendWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_backend

  alias Vapor.Provider.{Dotenv, Env}

  def init(_, config) do
    providers = [
      %Dotenv{},
      %Env{bindings: [
        port: "PORT",
        secret: "PHOENIX_SECRET"
      ]},
    ]

    translations = [
      port: fn s -> String.to_integer(s) end,
    ]

    runtime_config = Vapor.load!(providers, translations)

    config =
      config
      |> Keyword.put(:http, [:inet6, port: runtime_config.port])
      |> Keyword.put(:url, [host: "backend", port: runtime_config.port])
      |> Keyword.put(:secret_key_base, runtime_config.secret)

    {:ok, config}
  end

  socket "/socket", PhoenixBackendWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :phoenix_backend,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_phoenix_backend_key",
    signing_salt: "8SDXnm6o"

  plug PhoenixBackendWeb.Router
end
