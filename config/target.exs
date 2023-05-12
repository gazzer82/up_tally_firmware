import Config

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

# Use shoehorn to start the main application. See the shoehorn
# library documentation for more control in ordering how OTP
# applications are started and handling failures.

config :shoehorn, init: [:nerves_runtime, :nerves_pack]

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

# Advance the system clock on devices without real-time clocks.
config :nerves, :erlinit, update_clock: true

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :static, address: "192.168.10.25", netmask: "255.255.255.0"}
     }}
    # {"wlan0",
    #  %{
    #    type: VintageNetWiFi,
    #    vintage_net_wifi: %{
    #      networks: [
    #        %{
    #          key_mgmt: :wpa_psk,
    #          ssid: "The Jeanne's",
    #          psk: "3q9qiwKArYXE"
    #        }
    #      ]
    #    },
    #    ipv4: %{method: :dhcp}
    #  }}
  ]

config :mdns_lite,
  # The `hosts` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".  The `"nerves"` host causes mdns_lite
  # to advertise "nerves.local" for convenience. If more than one Nerves device
  # is on the network, it is recommended to delete "nerves" from the list
  # because otherwise any of the devices may respond to nerves.local leading to
  # unpredictable behavior.

  hosts: [:hostname, "uptally"],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
config :up_tally, UpTallyWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 80],
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

config :up_tally, data_dest: "/root"

config :up_tally, UpTallyWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :up_tally_firmware,
  indicators: %{
    default: %{red: "red:indicator-1", green: "green:indicator-1", blue: "blue:indicator-1"},
    rgb2: %{red: "red:indicator-2", green: "green:indicator-2", blue: "blue:indicator-2"},
    phycore: %{green: "phycore-green"}
  }

config :up_tally,
  ecto_repos: [UpTally.Repo]

config :up_tally, UpTally.Repo,
  database: "/root/#{Mix.env()}.sqlite3",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

# Do not print debug messages in production
# config :logger, level: :info

# Delux.render(%{
#   default: Delux.Effects.cycle([:red, :black], 1),
#   rgb2: Delux.Effects.cycle([:blue, :black], 1)
# })
