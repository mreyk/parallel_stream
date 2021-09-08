defmodule ParallelStream.Mixfile do
  use Mix.Project

  def project do
    [
      app: :parallel_stream,
      version: "1.0.6",
      elixir: "~> 1.12",
      deps: deps(),
      package: package(),
      docs: &docs/0,
      name: "Parallel Stream",
      consolidate_protocols: true,
      source_url: "https://github.com/beatrichartz/parallel_stream",
      description: "Parallel stream operations for Elixir",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test]
    ]
  end

  defp package do
    [
      maintainers: ["Beat Richartz"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/beatrichartz/parallel_stream"}
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.14.2", only: :test},
      {:ex_doc, "~> 0.25.2", only: :docs},
      {:inch_ex, "~> 2.0.0", only: :docs},
      {:earmark, "~> 1.4.15", only: :docs},
      {:benchfella, "~> 0.3.5", only: [:bench]}
    ]
  end

  defp docs do
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])

    [
      source_ref: ref,
      main: "overview"
    ]
  end
end
