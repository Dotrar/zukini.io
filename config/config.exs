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
