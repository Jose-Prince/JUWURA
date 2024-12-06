defmodule Example.Plug.VerifyRequest do
  import Plug.Conn

  # Initialize options (fields and paths)
  def init(options), do: options

  # Handle incoming connections
  def call(conn, opts) do
    # Extract options
    fields = Keyword.get(opts, :fields, [])
    paths = Keyword.get(opts, :paths, [])

    # Check if the current request path is one of the monitored paths
    if conn.request_path in paths do
      # Validate fields in the request body (example logic)
      case validate_fields(conn, fields) do
        :ok -> conn
        {:error, message} -> send_resp(conn, 400, message) |> halt()
      end
    else
      conn
    end
  end

  defp validate_fields(conn, fields) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, _conn} ->
        params = Plug.Conn.Query.decode(body)

        missing_fields =
          Enum.filter(fields, fn field ->
            !Map.has_key?(params, field)
          end)

        if missing_fields == [], do: :ok, else: {:error, "Missing fields: #{Enum.join(missing_fields, ", ")}"}

      {:error, reason} ->
        {:error, "Failed to read request body: #{reason}"}
    end
  end
end
