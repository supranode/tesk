# Tesk

`Tesk` lets you verify task invocations during tests without executing them asynchronously.

To support this, the `Tesk` module implements the task-spawning functions from `Task` (`start/3` and `start_link/3`).

Functions such as `Task.async/3` are intentionally not implemented, since awaiting a task is usually part of the logic under test and should behave normally.

## Installation

Add `:tesk` to your project's dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tesk, "~> 1.0.0"}
  ]
end
```

And fetch your project's dependencies `mix deps.get`.

## Usage

Use `Tesk` wherever you would use `Task.start/3` or `Task.start_link/3`:

```elixir
Tesk.start(MyApp.Mailer, :send_welcome, [user.id])
Tesk.start_link(MyApp.Indexer, :reindex, [doc.id])
```

The behavior of `Tesk` depends on the configured adapter. In tests, the `Tesk.Adapters.Capture` adapter captures  tasks invocations for assertions, which can be verified using `Tesk.Assertions`. The `Tesk.Adapters.Inline` adapter executes tasks synchronously. See "Adapters" and "Assertions" below for more information.

`Tesk` also provides the `Tesk.Supervisor` module, which implements the corresponding task-spawning functions from `Task.Supervisor` (`start_child/5`):

```elixir
Tesk.Supervisor.start_child(
  MyApp.TaskSupervisor,
  MyApp.Mailer,
  :send_welcome,
  [user.id]
)
```

See `Tesk.Supervisor` for more information.

### Adapters

By default, `Tesk` uses `Tesk.Adapters.Task`, which delegates
directly to `Task` and `Task.Supervisor`.

In tests, adapters can change how tasks are executed:

  * `Tesk.Adapters.Capture` - captures `{module, function, args}` calls
    for assertions. See `Tesk.Assertions` for more information.

  * `Tesk.Adapters.Inline` - runs tasks synchronously in the
    caller process.

### Assertions

With `Tesk.Adapters.Capture` configured, use `Tesk.Assertions` to
make assertions about captured tasks:

```elixir
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
```

### Configuration

Adapters are resolved at compile time, ensuring task behavior cannot
be changed at runtime.

They can be configured with:

  * `:adapter` - default adapter.

  * `:adapters` - overrides for specific `module`, `{module, function}`,
    or `{module, function, arity}`.

Example:

```elixir
# config/test.exs
config :tesk,
  adapter: Tesk.Adapters.Capture,
  adapters: %{
    MyApp.Mailer => Tesk.Adapters.Inline,
    {MyApp.Indexer, :reindex} => Tesk.Adapters.Inline,
    {MyApp.Resizer, :resize, 2} => Tesk.Adapters.Inline
  }
```

Resolution proceeds from most specific to least specific:
`{module, function, arity}`, `{module, function}`, `module`, and
finally the default adapter.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/supranode/tesk.

## Copyright and License

Tesk source code is licensed under the [MIT License](LICENSE).
