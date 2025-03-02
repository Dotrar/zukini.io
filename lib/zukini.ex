defmodule Zukini do
  alias Zukini.Blog
  use Phoenix.Component
  import Phoenix.HTML

  embed_templates("templates/*")
  @output_dir "./site"
  @image_assets "./assets/img"
  File.mkdir_p!(@output_dir)

  def build() do
    IO.puts("Removing dir and rebuilding.........")
    File.rm_rf!(Path.join(@output_dir, "/*"))

    IO.puts("Copying image asset files.......")

    image_assets_dest = Path.join(@output_dir, @image_assets)
    File.mkdir_p!(image_assets_dest)

    File.cp_r!(@image_assets, image_assets_dest)
    |> Enum.each(fn p -> IO.puts("-> #{p}") end)

    systems = Blog.all_systems()
    logs = Blog.all_logs()
    all_posts = logs ++ systems
    topics = Blog.build_topics(all_posts)

    for dir <- ~w(topics systems logs) do
      File.mkdir_p!(Path.join([@output_dir, dir]))
    end

    recent_logs =
      logs
      |> Enum.take(5)

    recent_systems =
      systems
      |> Enum.take(3)

    # index files
    render_file("index.html", index(%{systems: recent_systems, logs: recent_logs}))
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
    File.write!(output, safe)
    IO.puts("wrote : #{output}")
  end
end
