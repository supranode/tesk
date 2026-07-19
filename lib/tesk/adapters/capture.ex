defmodule Tesk.Adapters.Capture do
  @moduledoc """
  Test adapter that captures task invocations on the calling process
  instead of executing them.

  See `Tesk.Assertions` for assertions and helpers around captured
  tasks.

  The `supervisor` and `options` arguments passed to
  `Tesk.Supervisor.start_child/5` are ignored by this adapter.

  Because no new process is spawned, the returned pid is the calling
  process (`self()`). Code that monitors or links the returned pid
  will reference the caller, not an independent task.
  """

  @behaviour Tesk.Adapter

  @key :"$Tesk"

  # See `Tesk.Assertions.clear_tasks() for more information.
  @doc false
  @spec clear_tasks :: :ok
  def clear_tasks do
    Process.put(@key, [])
    :ok
  end

  # See `Tesk.Assertions.list_tasks() for more information.
  @doc false
  @spec list_tasks :: list({module, atom, [term]})
  def list_tasks do
    @key
    |> Process.get([])
    |> Enum.reverse()
  end

  @impl Tesk.Adapter
  def start(module, function, args), do: capture_task(module, function, args)

  @impl Tesk.Adapter
  def start_link(module, function, args), do: capture_task(module, function, args)

  @impl Tesk.Adapter
  def start_child(_, module, function, args, _), do: capture_task(module, function, args)

  defp capture_task(module, function, args) do
    Process.put(@key, [{module, function, args} | Process.get(@key, [])])
    {:ok, self()}
  end
end
