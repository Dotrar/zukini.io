defmodule Zukini.Post do

  defstruct [
    :title,
    :body,
    :description,
    :tags,
    :date,
    :path
  ]

  def build(filename, attrs, body) do
    path = Path.rootname(filename)
    [section] = path |> Path.split() |> Enum.take(1)

    struct!(__MODULE__, [path: path] ++ Map.to_list(attrs))
    end
  
end
