defmodule Tesk.Assertions do
  @moduledoc """
  ExUnit assertions for tasks captured by `Tesk.Adapters.Capture`.

  ## Example

      defmodule MyApp.SignupTest do
        use ExUnit.Case, async: true

        import Tesk.Assertions

        setup :clear_tasks

        test "enqueues a welcome email" do
          user = %{id: 42}
          user_id = user.id

          MyApp.signup(user)

          assert_task_count 1

          # assert_task/1 (and refute_task/1) support pattern
          # matching on captured tasks:
          assert_task {MyApp.Mailer, :send_welcome, [42]}
          assert_task {MyApp.Mailer, :send_welcome, _}
          assert_task {MyApp.Mailer, :send_welcome, [^user_id]}
        end
      end

  """

  import ExUnit.Assertions, only: [assert: 1]

  @doc """
  Clears captured tasks for the current process.

  Can also be used as an ExUnit setup callback (`setup :clear_tasks`),
  in which case the test context is accepted and discarded.
  """
  @spec clear_tasks(map) :: :ok
  def clear_tasks(_context \\ %{}), do: Tesk.Adapters.Capture.clear_tasks()

  @doc """
  Returns captured tasks for the current process,
  in the order they were captured.
  """
  @spec list_tasks :: list({module, atom, [term]})
  defdelegate list_tasks, to: Tesk.Adapters.Capture

  @doc """
  Asserts the current process has captured exactly `expected_count` tasks.
  """
  def assert_task_count(expected_count) do
    assert length(list_tasks()) == expected_count
  end

  @doc """
  Asserts that some captured task matches the given `pattern`.
  """
  defmacro assert_task(pattern) do
    expr = Macro.escape({:assert_task, [], [pattern]}, prune_metadata: true)

    quote do
      tasks = Tesk.Assertions.list_tasks()

      unless Enum.any?(tasks, &match?(unquote(pattern), &1)) do
        raise ExUnit.AssertionError,
          message: "no captured task matched the given pattern",
          expr: unquote(expr),
          right: tasks
      end
    end
  end

  @doc """
  Refutes that any captured task matches the given `pattern`.
  """
  defmacro refute_task(pattern) do
    expr = Macro.escape({:refute_task, [], [pattern]}, prune_metadata: true)

    quote do
      tasks = Tesk.Assertions.list_tasks()

      case Enum.find(tasks, &match?(unquote(pattern), &1)) do
        nil ->
          :ok

        matched ->
          raise ExUnit.AssertionError,
            message: "unexpected task was captured matching the given pattern",
            expr: unquote(expr),
            right: matched
      end
    end
  end
end
