import Config

# Add configuration that is only needed when running on the host here.
config :up_tally_firmware,
  indicators: %{
    default: %{}
  }

  config :up_tally, UpTallyWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 4000],
  secret_key_base: "s/uv2XKCfFxIg3+cAJ2zc8V818qPDL54XA2BCaZTZgC9pX0S9oyelDfDoySVxtAl",
  render_errors: [
    formats: [html: UpTallyWeb.ErrorHTML, json: UpTallyWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: UpTally.PubSub,
  live_view: [signing_salt: "ajODyH4+"],
  check_origin: false,
  server: true,
  code_reloader: false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :mfa]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :up_tally, data_dest: "./"

config :up_tally, UpTallyWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :up_tally,
  ecto_repos: [UpTally.Repo]

config :up_tally, UpTally.Repo,
  database: "./#{Mix.env()}.sqlite3",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")
