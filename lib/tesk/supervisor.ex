defmodule Tesk.Supervisor do
  @moduledoc """
  Adapter-aware counterpart to `Task.Supervisor`.

  Requires a running `Task.Supervisor`, which is passed to
  `Tesk.Supervisor.start_child/5`. See `Task.Supervisor`
  for how to set it up.

  See the `Tesk` module documentation for more information.
  """

  @doc """
  Equivalent of `Task.Supervisor.start_child/5`.

  See the `Tesk` module documentation for more information.
  """
  @spec start_child(Supervisor.supervisor(), module, atom, list, keyword) ::
          DynamicSupervisor.on_start_child()
  def start_child(supervisor, module, function, args, options \\ [])
      when is_atom(module) and is_atom(function) and is_list(args) and is_list(options) do
    Tesk.adapter({module, function, length(args)}).start_child(
      supervisor,
      module,
      function,
      args,
      options
    )
  end
end
