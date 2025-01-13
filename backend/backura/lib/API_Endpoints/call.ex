defmodule JAPI do
  use Application
  require Logger

  def start(_type, _args) do
    # Fetch MongoDB connection string from the environment or hardcoded
    mongo_url = "mongodb+srv://juwugroup:oI4BxejVG6C4tscB@juwura.jxug5.mongodb.net/?retryWrites=true&w=majority&appName=Juwura"

    port = Application.get_env(:japi, :cowboy_port, 8080)

    children = [
      # Start MongoDB connection with proper SSL options
      {Mongo,
       [
         name: :mongo,
         url: mongo_url,
         ssl: true,
         ssl_opts: [

          versions: [:"tlsv1.2", :"tlsv1.3"],
          verify: :verify_peer,
          cacerts: :certifi.cacerts()
        ]
       ]},

      # HTTP server with Cowboy
      {Plug.Cowboy, scheme: :http, plug: JAPI.Router, options: [port: port]}
    ]

    Logger.info("Starting application on port #{port}")
    Supervisor.start_link(children, strategy: :one_for_one, name: JAPI.Supervisor)
  end
end
