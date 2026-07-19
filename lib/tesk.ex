defmodule Tesk do
  @moduledoc """
  `Tesk` lets you verify task invocations during tests
  without executing them asynchronously.

  To support this, the `Tesk` module implements the
  task-spawning functions from `Task` (`start/3` and
  `start_link/3`).

  Functions such as `Task.async/3` are intentionally not implemented,
  since awaiting a task is usually part of the logic under test
  and should behave normally.

  Use `Tesk` wherever you would use `Task.start/3` or
  `Task.start_link/3`:

      Tesk.start(MyApp.Mailer, :send_welcome, [user.id])
      Tesk.start_link(MyApp.Indexer, :reindex, [doc.id])

  The behavior of `Tesk` depends on the configured adapter.
  In tests, the `Tesk.Adapters.Capture` adapter captures task
  invocations for assertions, which can be verified using
  `Tesk.Assertions`. The `Tesk.Adapters.Inline` adapter executes
  tasks synchronously. See "Adapters" below for more information.

  `Tesk` also provides the `Tesk.Supervisor` module,
  which implements the corresponding task-spawning functions from
  `Task.Supervisor` (`start_child/5`):

      Tesk.Supervisor.start_child(
        MyApp.TaskSupervisor,
        MyApp.Mailer,
        :send_welcome,
        [user.id]
      )

  See `Tesk.Supervisor` for more information.

  ## Adapters

  By default, `Tesk` uses `Tesk.Adapters.Task`, which delegates
  directly to `Task` and `Task.Supervisor`.

  In tests, adapters can change how tasks are executed:

    * `Tesk.Adapters.Capture` - captures `{module, function, args}` calls
      for assertions. See `Tesk.Assertions` for more information.

    * `Tesk.Adapters.Inline` - runs tasks synchronously in the
      caller process.

  ## Configuration

  Adapters are resolved at compile time, ensuring task behavior cannot
  be changed at runtime.

  They can be configured with:

    * `:adapter` - default adapter.

    * `:adapters` - overrides for specific `module`, `{module, function}`,
      or `{module, function, arity}`

  Example:

      # config/test.exs
      config :tesk,
        adapter: Tesk.Adapters.Capture,
        adapters: %{
          MyApp.Mailer => Tesk.Adapters.Inline,
          {MyApp.Indexer, :reindex} => Tesk.Adapters.Inline,
          {MyApp.Resizer, :resize, 2} => Tesk.Adapters.Inline
        }

  Resolution proceeds from most specific to least specific:
  `{module, function, arity}`, `{module, function}`, `module`,
  and finally the default adapter.
  """

  @adapter Application.compile_env(:tesk, :adapter, Tesk.Adapters.Task)
  @adapters Application.compile_env(:tesk, :adapters, %{})

  @doc """
  Returns the default adapter.
  """
  @spec adapter() :: module
  def adapter, do: @adapter

  @doc """
  Returns the adapter that will be used for the given `module`,
  `{module, function}`, or `{module, function, arity}`.

  See the module documentation for resolution order.
  """
  @spec adapter(module | {module, atom} | mfa) :: module
  def adapter({module, function, arity})
      when is_atom(module) and is_atom(function) and is_integer(arity) and arity >= 0 do
    Map.get_lazy(@adapters, {module, function, arity}, fn -> adapter({module, function}) end)
  end

  def adapter({module, function}) when is_atom(module) and is_atom(function) do
    Map.get_lazy(@adapters, {module, function}, fn -> adapter(module) end)
  end

  def adapter(module) when is_atom(module) do
    Map.get(@adapters, module, adapter())
  end

  @doc """
  Equivalent of `Task.start/3`.

  See the module documentation for more information.
  """
  @spec start(module, atom, [term]) :: {:ok, pid}
  def start(module, function, args)
      when is_atom(module) and is_atom(function) and is_list(args) do
    Tesk.adapter({module, function, length(args)}).start(module, function, args)
  end

  @doc """
  Equivalent of `Task.start_link/3`.

  See the module documentation for more information.
  """
  @spec start_link(module, atom, [term]) :: {:ok, pid}
  def start_link(module, function, args)
      when is_atom(module) and is_atom(function) and is_list(args) do
    Tesk.adapter({module, function, length(args)}).start_link(module, function, args)
  end
end
