defmodule Tesk.Adapters.Inline do
  @moduledoc """
  Adapter that executes tasks synchronously (inlined) in the calling process.

  Useful when side effects are required, particularly useful
  in integration tests that require deterministic execution order.

  The `supervisor` and `options` arguments passed to
  `Tesk.Supervisor.start_child/5` are ignored.

  Because no new process is spawned, the returned pid is the calling
  process (`self()`). Code that monitors or links the returned pid
  will reference the caller, not an independent task.
  """

  @behaviour Tesk.Adapter

  @impl Tesk.Adapter
  def start(module, function, args), do: inline_task(module, function, args)

  @impl Tesk.Adapter
  def start_link(module, function, args), do: inline_task(module, function, args)

  @impl Tesk.Adapter
  def start_child(_, module, function, args, _opts), do: inline_task(module, function, args)

  defp inline_task(module, function, args) do
    apply(module, function, args)
    {:ok, self()}
  end
end
