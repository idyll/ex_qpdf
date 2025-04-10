# ExQPDF

An Elixir wrapper for the [QPDF](https://github.com/qpdf/qpdf) library, a content-preserving PDF document transformer. This library allows you to get information about PDF files and detect if a PDF requires a password.

## Prerequisites

ExQPDF requires the QPDF command-line tool to be installed on your system.

### Installing QPDF

ExQPDF requires the QPDF command-line tool to be available in your system PATH.

#### macOS

Using Homebrew:
```bash
brew install qpdf
```

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install qpdf
```

#### Fedora/RHEL/CentOS
```bash
# Fedora
sudo dnf install qpdf

# RHEL/CentOS with EPEL
sudo yum install epel-release
sudo yum install qpdf
```

#### Arch Linux
```bash
sudo pacman -S qpdf
```

#### Windows
Options for Windows users:

1. **Using Chocolatey**:
   ```powershell
   choco install qpdf
   ```

2. **Using Scoop**:
   ```powershell
   scoop install qpdf
   ```

3. **Manual Installation**:
   - Download the latest release from [QPDF releases](https://github.com/qpdf/qpdf/releases)
   - Extract the zip file
   - Add the bin directory to your PATH

#### Verifying Installation

To verify that QPDF is installed correctly, run:
```bash
qpdf --version
```

This should display the installed version of QPDF.

## Installation

Add `ex_qpdf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_qpdf, "~> 0.1.2"}
  ]
end
```

After adding the dependency, run:

```
mix deps.get
```

## Usage

### Checking if a PDF requires a password

```elixir
# Check if a PDF requires a password
case ExQPDF.password_required?("path/to/document.pdf") do
  {:ok, true} -> 
    IO.puts("This PDF is password-protected")
  {:ok, false} -> 
    IO.puts("This PDF is not password-protected")
  {:error, reason} -> 
    IO.puts("Error checking PDF: #{reason}")
end
```

### Getting PDF information

```elixir
# Get information about a non-protected PDF
{:ok, info} = ExQPDF.info("path/to/document.pdf")
IO.puts("Page count: #{info.page_count}")

# Get information about a password-protected PDF
{:ok, info} = ExQPDF.info("path/to/protected.pdf", password: "secret")
IO.inspect(info)
```

### Opening a PDF for further operations

```elixir
# Open a PDF for further operations
case ExQPDF.open("path/to/document.pdf") do
  {:ok, handle} -> 
    # Use the handle for further operations (future functionality)
    IO.inspect(handle)
  {:error, reason} -> 
    IO.puts("Failed to open PDF: #{reason}")
end

# Open a password-protected PDF
{:ok, handle} = ExQPDF.open("path/to/protected.pdf", password: "secret")
```

## Features

- Check if a PDF requires a password
- Get basic information about PDF files (password status, page count)
- Open PDFs with password support for future operations

## Roadmap

- PDF transformation operations (merge, split)
- Page extraction
- Metadata modification
- Direct access to QPDF's advanced features

## License

Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Attribution

ExQPDF is a wrapper around the [QPDF library](https://github.com/qpdf/qpdf).

QPDF is copyright (c) 2005-2021 Jay Berkenbilt, 2022-2025 Jay Berkenbilt and Manfred Holger

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Versions of QPDF prior to version 7 were released under the terms of version 2.0 of the Artistic License. For more information, please see the [QPDF repository](https://github.com/qpdf/qpdf).

