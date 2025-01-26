defmodule Zukini do
  alias Zukini.Blog
  use Phoenix.Component
  import Phoenix.HTML

  embed_templates("templates/*")
  @output_dir "./site"
  File.mkdir_p!(@output_dir)

  def build() do
    File.rm_rf!(Path.join(@output_dir, "/*"))

    systems = Blog.all_systems()
    logs = Blog.all_logs()
    all_posts = logs ++ systems
    topics = Blog.build_topics(all_posts)

    for dir <- ~w(topics systems logs) do
      File.mkdir_p!(Path.join([@output_dir, dir]))
    end

    # index files
    render_file("index.html", index(%{systems: systems, logs: logs}))
    render_file("systems/index.html", systems_index(%{systems: systems}))
    render_file("logs/index.html", logs_index(%{logs: logs}))

    for post <- all_posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      render_file(post.path, post(%{post: post}))
    end

    for topic <- topics do
      render_file(topic.path, topic(%{topic: topic}))
    end

    :ok
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    IO.puts("wrote : #{output}")
    File.write!(output, safe)
  end
end
