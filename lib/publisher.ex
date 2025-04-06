defmodule Zukini.Publisher do
  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {from, paths} = Zukini.Publisher.__extract__(__MODULE__, opts)

      for path <- paths do
        @external_resource Path.relative_to_cwd(path)
      end
    end
  end

  @doc false
  def __extract__(module, opts) do
    root = Keyword.fetch!(opts, :root)

    for type <- Keyword.fetch!(opts, :types) do
      builder = Keyword.fetch!(type, :build)
      from = Keyword.fetch!(type, :from)
      as = Keyword.fetch!(type, :as)

      paths = (root <> from) |> Path.wildcard() |> Enum.sort()

      entries =
        for path <- paths do
          case parse_contents!(path, File.read!(path)) do
            {attrs, body} ->
              body =
                path
                |> Path.extname()
                |> String.downcase()
                |> convert_body(body, opts)

              # remove the start of the path
              path = Path.split(path) |> tl() |> Path.join()

              builder.build(path, attrs, body)

            _ ->
              nil
          end
        end
        |> Enum.filter(fn e -> not is_nil(e) end)

      Module.put_attribute(module, as, entries)
      {from, paths}
    end
    |> Enum.unzip()
  end

  defp parse_contents!(path, contents) do
    case parse_contents(path, contents) do
      {:ok, attrs, body} ->
        {attrs, body}

      {:warn, message} ->
        IO.puts("WARN: #{message}")

      {:error, message} ->
        raise """
        #{message}

        Each entry must have a map with attributes, followed by --- and a body. For example:

            %{
              title: "Hello World"
            }
            ---
            Hello world!

        """
    end
  end

  defp parse_contents(path, contents) do
    case :binary.split(contents, ["\n---\n", "\r\n---\r\n"]) do
      [_] ->
        {:error, "could not find separator --- in #{inspect(path)}"}

      [code, body] ->
        case Code.eval_string(code, []) do
          {%{} = attrs, _} ->
            {:ok, attrs, body}

          {other, _} ->
            {:error,
             "expected attributes for #{inspect(path)} to return a map, got: #{inspect(other)}"}
        end

      [_code, _draft, _body] ->
        {:warn, "#{inspect(path)} has a draft section, skipping.."}
    end
  end

  defp convert_body(extname, body, opts) when extname in [".md", ".markdown"] do
    earmark_opts = Keyword.get(opts, :earmark_options, %Earmark.Options{})
    body |> Earmark.as_html!(earmark_opts)
  end

  defp convert_body(_extname, body, _opts) do
    body
  end
end
