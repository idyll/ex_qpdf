defmodule ExQPDF.Handle do
  @moduledoc """
  A handle to a PDF file that has been successfully opened.

  This struct contains information about a PDF file and is used for operations
  that require continued access to the same file.
  """

  @type t :: %__MODULE__{
          path: String.t(),
          password: String.t() | nil
        }

  defstruct [:path, :password]
end
