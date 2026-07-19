defmodule TeskTest do
  use ExUnit.Case, async: true

  test "adapter/0 returns the configured default" do
    assert Tesk.adapter() == Tesk.Adapters.Capture
  end

  test "adapter/1 returns the module override when set" do
    assert Tesk.adapter(TeskTest.ModuleOverride) == Tesk.Adapters.Inline
  end

  test "adapter/1 applies the module override to any function/arity in the module" do
    assert Tesk.adapter({TeskTest.ModuleOverride, :anything, 7}) == Tesk.Adapters.Inline
  end

  test "adapter/1 returns the function override when set" do
    assert Tesk.adapter({TeskTest.FunctionOverride, :run}) == Tesk.Adapters.Inline
  end

  test "adapter/1 applies function override to any arity of the function" do
    assert Tesk.adapter({TeskTest.FunctionOverride, :run, 99}) == Tesk.Adapters.Inline
  end

  test "adapter/1 only applies function override to matching function" do
    assert Tesk.adapter({TeskTest.FunctionOverride, :other, 1}) == Tesk.Adapters.Capture
    assert Tesk.adapter(TeskTest.FunctionOverride) == Tesk.Adapters.Capture
  end

  test "adapter/1 returns the arity-specific override when set" do
    assert Tesk.adapter({TeskTest.ArityOverride, :variadic, 1}) == Tesk.Adapters.Inline
  end

  test "adapter/1 only applies arity-specific override to matching function/arity" do
    assert Tesk.adapter({TeskTest.ArityOverride, :variadic, 2}) == Tesk.Adapters.Capture
    assert Tesk.adapter({TeskTest.ArityOverride, :other, 1}) == Tesk.Adapters.Capture
  end

  test "adapter/1 falls back to the default when no override is set" do
    assert Tesk.adapter(TeskTest.NoOverride) == Tesk.Adapters.Capture
  end
end
