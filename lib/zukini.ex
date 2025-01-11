defmodule Zukini do
  alias Zukini.Blog
  use Phoenix.Component
  import Phoenix.HTML

  @output_dir "./site"
  File.mkdir_p!(@output_dir)

  def post(assigns) do
    ~H"""
    <.layout>
      <%= raw @post.body %>
    </.layout>
    """
  end

  def index(assigns) do
    ~H"""
    <.layout>
      <h1> Web</h1>
      <ul>
        <li :for={post <- @posts}>
          <a href={post.path}> <%= post.title %> </a>
        </li>
      </ul>
    </.layout>
    """
  end

  def layout(assigns) do
    ~H"""
    <html>
    <head>
    <link rel="stylesheet" href="/assets/app.css" />
    <script type="text/javascript" src="/assets/app.js" />
    </head>

      <body>
        <%= render_slot(@inner_block)%>
      </body>
    </html>
    """
  end

  def build() do
    posts = Blog.all_posts()
    render_file("index.html", index(%{posts: posts}))

    for post <- posts do
      dir = Path.dirname(post.path)

      if dir != "." do
        File.mkdir_p!(Path.join([@output_dir, dir]))
      end

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
