defmodule AdventOfCode2017.Mixfile do
  use Mix.Project

  def project do
    [
      app: :advent_of_code_2017,
      version: "1.0.0",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dogma, "~> 0.1", only: :dev},
    ]
  end
end
