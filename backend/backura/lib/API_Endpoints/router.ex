defmodule JAPI.Router do
  use Plug.Router
  use Plug.ErrorHandler


  plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["application/json"],
  json_decoder: Jason

  plug(:match)
  plug(:dispatch)

  # Welcome these are the main routes for vscode use Ctrl+G and lines here are the lines
  # Line 20 Welcome
  # Line 24 Login
  # Line
  
  
  
  get("/api", do: send_resp(conn, 200, "Welcome"))


  
  get "/api/login/:email/:password" do

    email = conn.params["email"]
    password = conn.params["password"]
    
    # Fetch users as a stream
    cursor = Mongo.find(:mongo, "usuarios", %{"password" => password, "mail" => email})
    users =
      for doc <- cursor.docs, into: [] do
        doc
      end
      transformed_users = Enum.map(cursor.docs, fn user ->
        Map.update!(user, "_id", fn %BSON.ObjectId{value: value} ->
          # Encode the ObjectId value to a lower-case hex string
          Base.encode16(value, case: :lower)
        end)
      end)
      
      # Convert the transformed data into JSON
    json_response = Jason.encode!(transformed_users)

    # Send the response
    conn
    |> put_resp_content_type("application/json")  
    |> send_resp(200, json_response)
    

  end

  post "/api/register" do
    # Extract data from JSON body
    name = conn.body_params["name"]
    password = conn.body_params["password"]
    username = conn.body_params["username"]
    last_name = conn.body_params["last_name"]
    mail = conn.body_params["mail"]
    date = Date.utc_today()

    # Insert data into MongoDB
    case Mongo.insert_one(:mongo, "usuarios", %{name: name, password: password, username: username, last_name: last_name, user_created: Date.to_string(date), proyectos: [], mail: mail}) do
      {:ok, result} ->
        send_resp(conn, 201, "User created")

      {:error, reason} ->
        send_resp(conn, 500, "Failed to create user: #{inspect(reason)}")
    end
  end

  get "/api/users" do
    # Fetch users as a stream
    cursor = Mongo.find(:mongo, "usuarios", %{})
    users =
      for doc <- cursor.docs, into: [] do
        doc
      end
      transformed_users = Enum.map(cursor.docs, fn user ->
        Map.update!(user, "_id", fn %BSON.ObjectId{value: value} ->
          # Encode the ObjectId value to a lower-case hex string
          Base.encode16(value, case: :lower)
        end)
      end)
      
      # Convert the transformed data into JSON
    json_response = Jason.encode!(transformed_users)

    # Send the response
    conn
    |> put_resp_content_type("application/json")  
    |> send_resp(200, json_response)  
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
