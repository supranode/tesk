import Config

config :tesk,
  adapter: Tesk.Adapters.Capture,
  adapters: %{
    # Used by test/tesk_test.exs to verify Tesk.adapter/1 resolution.
    TeskTest.ModuleOverride => Tesk.Adapters.Inline,
    {TeskTest.FunctionOverride, :run} => Tesk.Adapters.Inline,
    {TeskTest.ArityOverride, :variadic, 1} => Tesk.Adapters.Inline,

    # Used by test/tesk/adapters/inline_test.exs.
    Tesk.Adapters.InlineTest.Echo => Tesk.Adapters.Inline,

    # Used by test/tesk/adapters/task_test.exs.
    Tesk.Adapters.TaskTest.Echo => Tesk.Adapters.Task
  }
