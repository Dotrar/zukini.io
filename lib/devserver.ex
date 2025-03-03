defmodule Zukini.Devserver do
  use Phoenix.Endpoint, otp_app: :zukini
  alias Plug.Conn

  plug(:redirect_index)

  plug(Plug.Static,
    at: "/",
    from: "./site/"
  )

  defp redirect_index(%Conn{path_info: segments} = conn, _opts) do
    filepath = Enum.join(["./site", segments], "/")

    case File.dir?(filepath) do
      true ->
        conn
        |> put_resp_header("location", Enum.join([segments, "index.html"], "/"))
        |> send_resp(301, "")
        |> halt

      false ->
        conn
    end
  end
end
