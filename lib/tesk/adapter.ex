defmodule Tesk.Adapter do
  @moduledoc """
  Behaviour defining the execution interface for tasks.

  Adapters implement this behaviour to customize how tasks are executed,
  particularly in tests.
  """

  @doc """
  Equivalent of `Task.start/3`.
  """
  @callback start(module, atom, [term]) :: {:ok, pid}

  @doc """
  Equivalent of `Task.start_link/3`.
  """
  @callback start_link(module, atom, [term]) :: {:ok, pid}

  @doc """
  Equivalent of `Task.Supervisor.start_child/5`.
  """
  @callback start_child(
              Supervisor.supervisor(),
              module,
              atom,
              [term],
              Task.Supervisor.start_child_opts()
            ) :: DynamicSupervisor.on_start_child()
end
