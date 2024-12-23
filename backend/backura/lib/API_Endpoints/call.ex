defmodule JAPI do
  use Application
  require Logger

  def start(_type, _args) do
    # MongoDB URL from the environment or default
    mongo_url = System.get_env("MONGO_URL") || "mongodb://35.169.88.222:27017/juwura"
    # Cowboy port (default to 8080)
    port = Application.get_env(:example, :cowboy_port, 8080)

    # Log MongoDB connection URL
    Logger.info("Connecting to MongoDB at #{mongo_url}")

    # Start the MongoDB connection using the correct API
    {:ok, top} = Mongo.start_link(url: "mongodb://35.169.88.222:27017/juwura")

    children = [
      # MongoDB connection as a supervised process
      {Mongo, [name: :mongo, url: mongo_url]},

      # Cowboy HTTP server running the JAPI.Router on the specified port
      Plug.Adapters.Cowboy.child_spec(:http, JAPI.Router, [], port: port)
    ]

    # Start the supervisor with the children
    Logger.info("Started application on port #{port}")
    Supervisor.start_link(children, strategy: :one_for_one, name: JAPI.Supervisor)
  end
end
