defmodule Tesk.Adapters.CaptureTest do
  use ExUnit.Case, async: true

  import Tesk.Assertions

  setup :clear_tasks

  test "captures every task invocation" do
    assert {:ok, pid1} = Tesk.start(Mod, :one, [1])
    assert {:ok, pid2} = Tesk.start_link(Mod, :two, [2])
    assert {:ok, pid3} = Tesk.Supervisor.start_child(nil, Mod, :three, [3])

    assert pid1 == self()
    assert pid2 == self()
    assert pid3 == self()

    assert_task_count 3
    assert_task {Mod, :one, [1]}
    assert_task {Mod, _, [2]}
    assert list_tasks() == [{Mod, :one, [1]}, {Mod, :two, [2]}, {Mod, :three, [3]}]
  end

  test "tasks captured in another process are not visible from the current process" do
    assert {:ok, pid} = Tesk.start(Mod, :fun, [:current])

    spawn(fn ->
      Tesk.start(Mod, :fun, [:async])
      refute_task {Mod, :fun, [:current]}
      send(pid, {:tasks, list_tasks()})
    end)

    assert_receive {:tasks, [{Mod, :fun, [:async]}]}
    refute_task {Mod, :fun, [:async]}
    assert list_tasks() == [{Mod, :fun, [:current]}]
  end
end
