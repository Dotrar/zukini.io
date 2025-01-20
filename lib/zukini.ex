defmodule Zukini do
  alias Zukini.Blog
  use Phoenix.Component

  embed_templates("templates/*")
  @output_dir "./site"
  File.mkdir_p!(@output_dir)

  def build() do
    posts = Blog.all_posts()
    render_file("index.html", index(%{posts: posts}))

    for post <- posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

      IO.inspect(post.body)
      render_file(post.path, post(%{post: post}))
    end

    :ok
  end

  def render_file(path, rendered) do
    safe = Phoenix.HTML.Safe.to_iodata(rendered)
    output = Path.join([@output_dir, path])
    File.write!(output, safe)
  end
end
