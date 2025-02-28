defmodule Zukini.Blog do
  require IEx

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
      :last_updated,
      :audience,
      :body,
      :related_topics,
      :related_systems,
      :related_logs,
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
      {date_str, _slug} = path |> Path.basename() |> String.split_at(10)

      date = Date.from_iso8601!(date_str)

      struct!(
        __MODULE__,
        [path: path, body: body, date: date] ++ Map.to_list(attrs)
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
  defp all_topics, do: @topics

  def build_topics(posts) do
    topic_index =
      for post <- posts,
          topic <- post.topics || [],
          reduce: %{} do
        acc -> Map.update(acc, topic, [post], &[post | &1])
      end

    written_data =
      Enum.map(all_topics(), fn e ->
        {Path.basename(e.path, ".html"), e}
      end)
      |> Enum.into(%{})

    Map.to_list(topic_index)
    |> Enum.map(fn {key, posts} ->
      topic =
        Map.get(written_data, key, %Topic{
          title: key,
          path: "topics/#{key}.html"
        })

      {systems, logs} =
        posts
        |> Enum.split_with(fn
          %System{} -> true
          %Log{} -> false
        end)

      %Topic{
        topic
        | related_systems: systems,
          related_logs: logs
      }
    end)
  end

  def handle_reload() do
    Mix.Shell.cmd("mix site.build", &IO.puts/1)
  end
end
