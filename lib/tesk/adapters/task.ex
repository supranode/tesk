defmodule Tesk.Adapters.Task do
  @moduledoc """
  Adapter that executes tasks using `Task` and `Task.Supervisor`.
  """

  @behaviour Tesk.Adapter

  @impl Tesk.Adapter
  def start(module, function, args), do: Task.start(module, function, args)

  @impl Tesk.Adapter
  def start_link(module, function, args), do: Task.start_link(module, function, args)

  @impl Tesk.Adapter
  def start_child(supervisor, module, function, args, options),
    do: Task.Supervisor.start_child(supervisor, module, function, args, options)
end
