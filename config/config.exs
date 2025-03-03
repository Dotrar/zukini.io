import Config

config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(app.js --bundle --target=es2017 
      --outdir=../site/assets
      --external:/fonts/* 
      --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" => Path.expand("../deps", __DIR__)
    }
  ]

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../site/assets/app.css
      ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :zukini, Zukini.Devserver,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [
    # esbuild: {Esbuild, :install_and_run, [:zukini, ~w(--sourcemap=inline --watch)]},
    # tailwind: {Tailwind, :install_and_run, [:zukini, ~w(--watch)]}
  ]
