defmodule JAPI.Router do
  use Plug.Router
  use Plug.ErrorHandler


  plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["application/json"],
  json_decoder: Jason

  plug(:match)
  plug(:dispatch)

  # Welcome route
  get("/api", do: send_resp(conn, 200, "Welcome"))

  # Handle dynamic route /starve/:number
  get "/api/login/:email/:password" do

    nombre = conn.body_params["nombre"]
    password = conn.body_params["password"]

    # Try to parse the number and handle errors

    send_resp(conn, 200, "Starve number received: #{nombre}")

  end

  post "/api/add_user" do
    # Extract data from JSON body
    nombre = conn.body_params["nombre"]
    password = conn.body_params["password"]

    # Insert data into MongoDB
    case Mongo.insert_one(:mongo, "users", %{nombre: nombre, password: password}) do
      {:ok, result} ->
        send_resp(conn, 201, "User created with ID: #{result.inserted_id}")

      {:error, reason} ->
        send_resp(conn, 500, "Failed to create user: #{inspect(reason)}")
    end
  end

  get "/api/users" do
    # Fetch users from MongoDB
    users = Mongo.find(:mongo, "users", %{}) |> Enum.to_list()
    send_resp(conn, 200, Jason.encode!(users))
  end

#Parametros se usan body por cierto get no tiene body jajaja
  post "/api/register" do

    nombre = conn.body_params["nombre"]
    password = conn.body_params["password"]


    # Try to parse the number and handle errors

    send_resp(conn, 200, "Starve number received: #{nombre}, and #{password}")

  end

  # Handle unmatched routes
  match(_, do: send_resp(conn, 404, "Oops!"))
end
