defmodule Zukini.Blog do
  defmodule Checks do
    def for_file_attrs(attrs, filename) do
      is_index = Path.basename(filename, ".md") == "_index"

      Map.update(attrs, :filename, filename, fn _ -> filename end)
      |> Map.update(:is_index, is_index, fn _ -> is_index end)
    end

    def check_non_empty_list(%{filename: fname, is_index: false} = attrs, key) do
      case Map.get(attrs, key) do
        nil ->
          IO.inspect(attrs)
          IO.puts("#{fname} does not have #{key} defined")

        [] ->
          IO.puts("#{fname} has an empty #{key} list, find atleast one!")

        _ ->
          nil
      end

      attrs
    end

    def check_non_empty_list(%{is_index: true} = attrs, _) do
      attrs
    end

    def check_date_defined(%{is_index: false, filename: fname} = attrs, field) do
      case Map.get(attrs, field, nil) do
        nil ->
          IO.puts("#{fname} does not specify a date field #{field}")

        %{__struct__: Date} ->
          nil

        _ ->
          IO.puts("#{fname} is something other than a date! got:")
          IO.inspect(attrs)
      end

      attrs
    end

    def check_date_defined(%{is_index: true} = attrs, _) do
      attrs
    end
  end

  defmodule System do
    import Zukini.Blog.Checks

    defstruct [
      :title,
      :description,
      :topics,
      :date,
      :body,
      :path
    ]

    def build(filename, attrs, body) do
      path = Path.rootname(filename) <> ".html"

      for_file_attrs(attrs, filename)
      |> check_non_empty_list(:topics)
      |> check_date_defined(:date)

      struct!(
        __MODULE__,
        [path: path, body: body] ++ Map.to_list(attrs)
      )
    end
  end

  defmodule Topic do
    import Zukini.Blog.Checks

    defstruct [
      :title,
      :description,
      :related,
      :last_updated,
      :audience,
      :body,
      :path
    ]

    def build(filepath, attrs, body) do
      path = Path.rootname(filepath) <> ".html"

      for_file_attrs(attrs, filepath)
      |> check_date_defined(:last_updated)

      struct!(
        __MODULE__,
        [path: path, body: body] ++ Map.to_list(attrs)
      )
    end
  end

  defmodule Log do
    import Zukini.Blog.Checks

    defstruct [
      :title,
      :description,
      :topics,
      :date,
      :body,
      :path
    ]

    def build(filename, attrs, body) do
      path = Path.rootname(filename) <> ".html"

      for_file_attrs(attrs, filename)
      |> check_date_defined(:date)

      struct!(
        __MODULE__,
        [path: path, body: body] ++ Map.to_list(attrs)
      )
    end
  end

  use Zukini.Publisher,
    root: "./posts/",
    types: [
      [build: System, from: "systems/**/*.md", as: :systems],
      [build: Topic, from: "topics/**/*.md", as: :topics],
      [build: Log, from: "logs/**/*.md", as: :logs]
    ]

  def all_systems, do: @systems
  def all_logs, do: @logs
  def all_topics, do: @topics
end
