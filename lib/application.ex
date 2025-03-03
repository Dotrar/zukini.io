defmodule Zukini.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [Zukini.Devserver]
    opts = [strategy: :one_for_one, name: Zukini.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
