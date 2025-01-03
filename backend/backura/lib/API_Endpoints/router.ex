defmodule JAPI.Router do
  use Plug.Router
  use Plug.ErrorHandler

  # Apply CORSPlug globally
  plug CORSPlug,
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    headers: ["Content-Type", "Authorization"]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["application/json"],
    json_decoder: Jason

  plug(:match)
  plug(:dispatch)

  # Welcome route
  get("/api", do: send_resp(conn, 200, "Welcome"))

  # Login route
  get "/api/login/:email/:password" do
    email = conn.params["email"]
    password = conn.params["password"]

    # Query the MongoDB database
    cursor = Mongo.find(:mongo, "usuarios", %{"password" => password, "mail" => email})
    transformed_users =
      cursor.docs
      |> Enum.map(fn user ->
        Map.update!(user, "_id", fn %BSON.ObjectId{value: value} ->
          # Encode the ObjectId value to a lower-case hex string
          Base.encode16(value, case: :lower)
        end)
      end)

    # Convert to JSON and send response
    json_response = Jason.encode!(transformed_users)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json_response)
  end

  # Register route
  post "/api/register" do
    name = conn.body_params["name"]
    password = conn.body_params["password"]
    username = conn.body_params["username"]
    last_name = conn.body_params["last_name"]
    mail = conn.body_params["mail"]
    date = Date.utc_today()

    case Mongo.insert_one(:mongo, "usuarios", %{
           name: name,
           password: password,
           username: username,
           last_name: last_name,
           user_created: Date.to_string(date),
           proyectos: [],
           mail: mail
         }) do
      {:ok, _result} ->
        send_resp(conn, 201, "User created")

      {:error, reason} ->
        send_resp(conn, 500, "Failed to create user: #{inspect(reason)}")
    end
  end

  # Fetch all users
  get "/api/users" do
    cursor = Mongo.find(:mongo, "usuarios", %{})
    transformed_users =
      cursor.docs
      |> Enum.map(fn user ->
        Map.update!(user, "_id", fn %BSON.ObjectId{value: value} ->
          Base.encode16(value, case: :lower)
        end)
      end)

    json_response = Jason.encode!(transformed_users)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json_response)
  end

  # Preflight CORS requests
  options _ do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-methods", "GET,POST,PUT,DELETE,OPTIONS")
    |> put_resp_header("access-control-allow-headers", "Content-Type, Authorization")
    |> send_resp(204, "")
  end

  # Handle unmatched routes
  match(_, do: send_resp(conn, 404, "Oops!"))
end
