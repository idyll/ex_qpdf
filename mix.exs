defmodule ExQPDF.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/idyll/ex_qpdf"
  @description """
  An Elixir wrapper for the QPDF library, providing a simple interface for working with PDF files.
  Supports password detection, metadata extraction, and more.
  """

  def project do
    [
      app: :ex_qpdf,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: @description,
      package: package(),
      docs: docs(),
      name: "ExQPDF",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "ex_qpdf",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "QPDF" => "https://github.com/qpdf/qpdf"
      },
      maintainers: ["Mark Madsen"]
    ]
  end

  defp docs do
    [
      main: "ExQPDF",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"],
      groups_for_modules: [
        Core: [
          ExQPDF
        ],
        Structs: [
          ExQPDF.Handle
        ]
      ]
    ]
  end
end
