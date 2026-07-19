defmodule Tesk.Adapters.InlineTest do
  use ExUnit.Case, async: true

  defmodule Echo do
    def echo(pid), do: send(pid, {:echo, self()})
  end

  test "Tesk.start/3 executes the task synchronously (inlined) in the calling process" do
    assert {:ok, pid} = Tesk.start(Echo, :echo, [self()])
    assert pid == self()
    assert_received {:echo, ^pid}
  end

  test "Tesk.start_link/3 executes the task synchronously (inlined) in the " <>
         "calling process" do
    assert {:ok, pid} = Tesk.start_link(Echo, :echo, [self()])
    assert pid == self()
    assert_received {:echo, ^pid}
  end

  test "Tesk.Supervisor.start_child/5 executes the task synchronously (inlined) " <>
         "in the calling process" do
    assert {:ok, pid} = Tesk.Supervisor.start_child(nil, Echo, :echo, [self()])
    assert pid == self()
    assert_received {:echo, ^pid}
  end
end
