defmodule Zukini.Blog do
  alias Zukini.Post

  use NimblePublisher,
  build: Post,
  from: "./posts/**/*.md",
  as: :posts,
  highlighters: [ :makeup_elixir]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  def all_posts, do: @posts
  
end
