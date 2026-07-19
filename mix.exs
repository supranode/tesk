defmodule Tesk.MixProject do
  use Mix.Project

  @version "1.0.0"
  @scm_url "https://github.com/supranode/tesk"

  def project do
    [
      app: :tesk,
      version: @version,
      description: description(),
      elixir: "~> 1.16",
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def cli do
    [
      default_env: :local,
      preferred_envs: [docs: :docs]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40.3", only: :docs}
    ]
  end

  defp description do
    """
    The testable version of Elixir's Task, allowing verification of task invocations
    during tests without requiring asynchronous execution.
    """
  end

  defp package do
    [
      maintainers: ["Fernando Tapia Rico"],
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url},
      files: ~w(.formatter.exs mix.exs README.md lib)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "Tesk",
      source_url: @scm_url,
      groups_for_modules: [
        Behaviors: [
          Tesk.Adapter
        ],
        Adapters: [
          Tesk.Adapters.Capture,
          Tesk.Adapters.Inline,
          Tesk.Adapters.Task
        ]
      ]
    ]
  end
end
