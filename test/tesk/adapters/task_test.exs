defmodule Tesk.Adapters.TaskTest do
  use ExUnit.Case, async: true

  defmodule Echo do
    def echo(pid) do
      send(pid, {:echo, self()})

      receive do
        :stop -> :ok
      end
    end
  end

  test "Tesk.start/3 starts an unlinked Task" do
    assert {:ok, pid} = Tesk.start(Echo, :echo, [self()])
    assert_receive {:echo, ^pid}

    {:links, links} = Process.info(self(), :links)
    refute pid in links

    send(pid, :stop)
  end

  test "Tesk.start_link/3 starts a Task linked to the calling process" do
    assert {:ok, pid} = Tesk.start_link(Echo, :echo, [self()])
    assert_receive {:echo, ^pid}

    {:links, links} = Process.info(self(), :links)
    assert pid in links

    send(pid, :stop)
  end

  test "Tesk.Supervisor.start_child/5 starts a Task under the given supervisor" do
    supervisor = start_supervised!({Task.Supervisor, []})

    assert {:ok, pid} = Tesk.Supervisor.start_child(supervisor, Echo, :echo, [self()])
    assert_receive {:echo, ^pid}

    {:links, links} = Process.info(self(), :links)
    refute pid in links

    send(pid, :stop)
  end

  test "Tesk.Supervisor.start_child/5 forwards options to Task.Supervisor" do
    supervisor = start_supervised!({Task.Supervisor, []})

    assert {:ok, pid} =
             Tesk.Supervisor.start_child(
               supervisor,
               Echo,
               :echo,
               [self()],
               restart: :transient,
               shutdown: :brutal_kill
             )

    assert_receive {:echo, ^pid}
    assert {_, :transient, :brutal_kill, _, _} = :sys.get_state(supervisor).children[pid]

    send(pid, :stop)
  end
end
