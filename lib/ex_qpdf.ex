defmodule ExQPDF do
  @moduledoc """
  An Elixir wrapper for the QPDF library.

  QPDF is a command-line program and C++ library for structural, content-preserving
  transformations on PDF files. ExQPDF provides a simple interface to some of its
  functionality, focusing on retrieving PDF information and handling password-protected files.

  ## Features

  * Check if a PDF requires a password to open
  * Get information about PDF files (page count, etc.)
  * Open PDFs with or without passwords for future operations

  ## Requirements

  This library requires the QPDF command-line tool to be installed on your system.
  See the README for installation instructions for various platforms.

  ## Examples

  Check if a PDF requires a password:

      path = "/path/to/document.pdf"
      case ExQPDF.password_required?(path) do
        {:ok, true} -> "Password required"
        {:ok, false} -> "No password required"
        {:error, reason} -> "Error: \#{reason}"
      end

  Get information about a PDF:

      # For a PDF without password protection
      {:ok, info} = ExQPDF.info("/path/to/document.pdf")
      "Page count: \#{info.page_count}"

      # For a password-protected PDF
      {:ok, info} = ExQPDF.info("/path/to/protected.pdf", password: "secret")
      "Page count: \#{info.page_count}"
  """

  @doc """
  Checks if a PDF file requires a password to open.

  ## Parameters
    - `path` - Path to the PDF file

  ## Returns
    - `{:ok, true}` - The PDF is password-protected
    - `{:ok, false}` - The PDF is not password-protected
    - `{:error, reason}` - An error occurred

  ## Examples

      # If the file doesn't exist, an error is returned
      iex> ExQPDF.password_required?("non_existent_file.pdf")
      {:error, "File not found: non_existent_file.pdf"}

  """
  @spec password_required?(String.t()) :: {:ok, boolean()} | {:error, String.t()}
  def password_required?(path) when is_binary(path) do
    case File.exists?(path) do
      true ->
        case System.cmd("qpdf", ["--check", path], stderr_to_stdout: true) do
          {_output, 0} ->
            # PDF is fine and not encrypted
            {:ok, false}

          {output, 2} ->
            # Exit code 2 can be due to password or other errors
            if String.contains?(output, "invalid password") do
              {:ok, true}
            else
              {:error, "PDF check failed but not due to password protection: #{output}"}
            end

          {output, 3} ->
            # Exit code 3 means warnings - check if the file is accessible without password
            if String.contains?(output, "Supplied password is user password") ||
                 String.contains?(output, "operation succeeded with warnings") do
              # The file has warnings but isn't password-protected
              {:ok, false}
            else
              # There are warnings and we can't determine password status
              {:error, "PDF check had warnings: #{output}"}
            end

          {output, _} ->
            # Handle other exit codes
            if String.contains?(output, "invalid password") do
              {:ok, true}
            else
              {:error, "Error checking PDF: #{output}"}
            end
        end

      false ->
        {:error, "File not found: #{path}"}
    end
  end

  @doc """
  Gets general information about a PDF file.

  ## Parameters
    - `path` - Path to the PDF file
    - `opts` - Options including:
      - `:password` - Password for protected PDFs

  ## Returns
    - `{:ok, info}` - A map containing file information
    - `{:error, reason}` - An error occurred

  ## Examples

      # If the file doesn't exist, an error is returned
      iex> ExQPDF.info("non_existent_file.pdf")
      {:error, "File not found: non_existent_file.pdf"}

      # With optional password parameter
      iex> ExQPDF.info("non_existent_file.pdf", password: "secret")
      {:error, "File not found: non_existent_file.pdf"}

  """
  @spec info(String.t(), keyword()) :: {:ok, map()} | {:error, String.t()}
  def info(path, opts \\ []) when is_binary(path) do
    password = Keyword.get(opts, :password)

    case File.exists?(path) do
      true ->
        args = build_args_with_password(["--json", "--json-key=pages", path], password)

        case System.cmd("qpdf", args, stderr_to_stdout: true) do
          {output, 0} ->
            info = %{
              password_required: false
            }

            case Jason.decode(output) do
              {:ok, json} ->
                page_count = json["pages"] |> length()
                {:ok, Map.put(info, :page_count, page_count)}

              {:error, _} ->
                {:ok, info}
            end

          {output, 2} ->
            if String.contains?(output, "invalid password") do
              {:ok, %{password_required: true}}
            else
              {:error, "PDF check failed: #{output}"}
            end

          {output, _} ->
            {:error, "Error checking PDF: #{output}"}
        end

      false ->
        {:error, "File not found: #{path}"}
    end
  end

  @doc """
  Opens a PDF file, allowing operations that might require a password.

  ## Parameters
    - `path` - Path to the PDF file
    - `opts` - Options including:
      - `:password` - Password for protected PDFs

  ## Returns
    - `{:ok, pdf_handle}` - A handle for further operations
    - `{:error, reason}` - An error occurred

  ## Examples

      # If the file doesn't exist, an error is returned
      iex> ExQPDF.open("non_existent_file.pdf")
      {:error, "File not found: non_existent_file.pdf"}

      # With optional password parameter
      iex> ExQPDF.open("non_existent_file.pdf", password: "secret")
      {:error, "File not found: non_existent_file.pdf"}

  """
  @spec open(String.t(), keyword()) :: {:ok, ExQPDF.Handle.t()} | {:error, String.t()}
  def open(path, opts \\ []) when is_binary(path) do
    password = Keyword.get(opts, :password)

    case File.exists?(path) do
      true ->
        args = build_args_with_password(["--check", path], password)

        case System.cmd("qpdf", args, stderr_to_stdout: true) do
          {_, 0} ->
            {:ok, %ExQPDF.Handle{path: path, password: password}}

          {output, 2} ->
            if String.contains?(output, "invalid password") do
              {:error, "Invalid password for PDF"}
            else
              {:error, "PDF check failed: #{output}"}
            end

          {output, _} ->
            {:error, "Error checking PDF: #{output}"}
        end

      false ->
        {:error, "File not found: #{path}"}
    end
  end

  @doc """
  Extracts metadata from a PDF file.

  This function extracts metadata such as title, author, creation date, and more from a PDF file.
  For password-protected PDFs, a password can be provided.

  ## Parameters
    - `path` - Path to the PDF file
    - `opts` - Options including:
      - `:password` - Password for protected PDFs

  ## Returns
    - `{:ok, metadata}` - A map containing metadata information
    - `{:error, reason}` - An error occurred

  ## Examples

      # If the file doesn't exist, an error is returned
      iex> ExQPDF.metadata("non_existent_file.pdf")
      {:error, "File not found: non_existent_file.pdf"}

  """
  @spec metadata(String.t(), keyword()) :: {:ok, map()} | {:error, String.t()}
  def metadata(path, opts \\ []) when is_binary(path) do
    password = Keyword.get(opts, :password)

    case File.exists?(path) do
      true ->
        args = build_args_with_password(["--json", path], password)

        case System.cmd("qpdf", args, stderr_to_stdout: true) do
          {output, 0} ->
            case Jason.decode(output) do
              {:ok, json} ->
                # Extract metadata from JSON
                metadata = extract_metadata(json)
                {:ok, metadata}

              {:error, _} ->
                {:error, "Failed to parse QPDF output"}
            end

          {output, 2} ->
            if String.contains?(output, "invalid password") do
              {:ok, %{password_required: true}}
            else
              {:error, "PDF check failed: #{output}"}
            end

          {output, _} ->
            {:error, "Error processing PDF: #{output}"}
        end

      false ->
        {:error, "File not found: #{path}"}
    end
  end

  # Private helpers

  defp build_args_with_password(args, nil), do: args

  defp build_args_with_password(args, password) do
    ["--password=#{password}" | args]
  end

  defp extract_metadata(json) do
    # Start with basic info
    metadata = %{
      password_required: false,
      page_count: length(json["pages"] || []),
      encrypted: json["encrypt"]["encrypted"] || false
    }

    # Add PDF version if available
    metadata =
      if json["qpdf"] && length(json["qpdf"]) > 0 do
        qpdf_info = Enum.at(json["qpdf"], 0)
        Map.put(metadata, :version, qpdf_info["pdfversion"])
      else
        metadata
      end

    # Find the trailer info object reference
    trailer_info =
      if json["qpdf"] && length(json["qpdf"]) > 1 do
        qpdf_objects = Enum.at(json["qpdf"], 1)
        trailer = qpdf_objects["trailer"]

        get_in(trailer, ["value", "/Info"])
        |> extract_object_reference()
      end

    # If Info object exists, extract standard metadata fields
    info_metadata =
      if trailer_info && json["qpdf"] && length(json["qpdf"]) > 1 do
        qpdf_objects = Enum.at(json["qpdf"], 1)
        info_obj = qpdf_objects["obj:#{trailer_info}"]["value"]

        if info_obj do
          %{
            title: clean_string(info_obj["/Title"]),
            author: clean_string(info_obj["/Author"]),
            creator: clean_string(info_obj["/Creator"]),
            producer: clean_string(info_obj["/Producer"]),
            creation_date: parse_pdf_date(clean_string(info_obj["/CreationDate"])),
            modification_date: parse_pdf_date(clean_string(info_obj["/ModDate"]))
          }
        else
          %{}
        end
      else
        %{}
      end

    # Merge basic info and document info
    Map.merge(metadata, info_metadata)
  end

  defp extract_object_reference(nil), do: nil

  defp extract_object_reference(ref) when is_binary(ref) do
    ref
  end

  defp clean_string(nil), do: nil
  defp clean_string("u:" <> str), do: str
  defp clean_string(str) when is_binary(str), do: str
  defp clean_string(_), do: nil

  defp parse_pdf_date(nil), do: nil

  defp parse_pdf_date("D:" <> date_string) do
    # Handle different PDF date formats
    # Basic format: D:YYYYMMDDHHmmSSZ or D:YYYYMMDDHHmmSSZHH'mm'

    # First, try to extract the basic date parts
    year = String.slice(date_string, 0, 4)
    month = String.slice(date_string, 4, 2)
    day = String.slice(date_string, 6, 2)

    # Extract time if available
    hour = if String.length(date_string) >= 8, do: String.slice(date_string, 8, 2), else: "00"
    minute = if String.length(date_string) >= 10, do: String.slice(date_string, 10, 2), else: "00"
    second = if String.length(date_string) >= 12, do: String.slice(date_string, 12, 2), else: "00"

    # Extract timezone if available
    timezone =
      if String.length(date_string) > 14 do
        tz_part = String.slice(date_string, 14..-1//1)
        " (#{tz_part})"
      else
        ""
      end

    # Format the date in a human-readable format
    "#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}#{timezone}"
  end

  defp parse_pdf_date(date_string), do: date_string
end
