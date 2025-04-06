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
      :path,
      :url
    ]

    def build(filename, attrs, body) do
      path = Path.rootname(filename) <> ".html"
      url = Path.join(["/", path])

      for_file_attrs(attrs, filename)
      |> check_non_empty_list(:topics)
      |> check_date_defined(:date)

      struct!(
        __MODULE__,
        [path: path, body: body, url: url] ++ Map.to_list(attrs)
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
      :path,
      :url
    ]

    def build(filepath, attrs, body) do
      path = Path.rootname(filepath) <> ".html"
      url = Path.join(["/", path])

      for_file_attrs(attrs, filepath)
      |> check_date_defined(:last_updated)

      struct!(
        __MODULE__,
        [path: path, body: body, url: url] ++ Map.to_list(attrs)
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
      :path,
      :url
    ]

    def build(filename, attrs, body) do
      path = Path.rootname(filename) <> ".html"
      url = Path.join(["/", path])
      {date_str, _slug} = path |> Path.basename() |> String.split_at(10)

      date = Date.from_iso8601!(date_str)

      struct!(
        __MODULE__,
        [path: path, body: body, date: date, url: url] ++ Map.to_list(attrs)
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

  defp reverse_chronological(data, term \\ :date) when is_atom(term) do
    data
    |> Enum.sort(&(Date.compare(Map.get(&1, term), Map.get(&2, term)) != :lt))
  end

  def all_systems, do: reverse_chronological(@systems)
  def all_logs, do: reverse_chronological(@logs)
  defp written_topics, do: @topics

  @doc """
  This function will take the combination of all the written topics
  as well as all the inferred topics from various log and system posts
  """
  def build_topics(posts) do
    topic_index =
      for post <- posts,
          topic <- post.topics || [],
          reduce: %{} do
        acc -> Map.update(acc, topic, [post], &[post | &1])
      end

    written_data =
      Enum.map(written_topics(), fn e ->
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
