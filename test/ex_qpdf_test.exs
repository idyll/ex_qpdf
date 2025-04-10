defmodule ExQPDFTest do
  use ExUnit.Case
  # Enable doctests now that they use non-existent files that will be handled properly
  doctest ExQPDF

  @samples_dir Path.join(__DIR__, "samples")
  @open_pdf Path.join(@samples_dir, "example.pdf")
  @encrypted_pdf Path.join(@samples_dir, "password_required.pdf")
  @locked_pdf Path.join(@samples_dir, "locked.pdf")

  # Mocked tests for edge cases and error handling
  describe "password_required?/1 (mocked tests)" do
    import Mock

    test "returns error when file doesn't exist" do
      assert {:error, _} = ExQPDF.password_required?("non_existing_file.pdf")
    end

    test "returns error on unexpected QPDF output" do
      with_mock System,
        cmd: fn "qpdf", ["--check", _path], _opts ->
          {"Error: some other error", 1}
        end do
        assert {:error, _} = ExQPDF.password_required?("fake_path.pdf")
      end
    end
  end

  # Real file tests
  describe "password_required?/1 (with real files)" do
    test "returns false for PDF with no password" do
      assert {:ok, false} = ExQPDF.password_required?(@open_pdf)
    end

    test "returns true for password-encrypted PDF" do
      assert {:ok, true} = ExQPDF.password_required?(@encrypted_pdf)
    end

    test "returns false for PDF with only owner password" do
      assert {:ok, false} = ExQPDF.password_required?(@locked_pdf)
    end
  end

  describe "info/1 (with real files)" do
    test "gets info for PDF with no password" do
      assert {:ok, info} = ExQPDF.info(@open_pdf)
      assert info.password_required == false
      assert is_integer(info.page_count)
      assert info.page_count > 0
    end

    test "gets info for PDF with only owner password" do
      assert {:ok, info} = ExQPDF.info(@locked_pdf)
      assert info.password_required == false
      assert is_integer(info.page_count)
      assert info.page_count > 0
    end

    test "fails to get info for password-encrypted PDF without password" do
      assert {:ok, info} = ExQPDF.info(@encrypted_pdf)
      assert info.password_required == true
      refute Map.has_key?(info, :page_count)
    end

    test "gets info for password-encrypted PDF with correct password" do
      # The password for example_encrypted.pdf is "open"
      password = "open"
      assert {:ok, info} = ExQPDF.info(@encrypted_pdf, password: password)
      assert info.password_required == false
      assert is_integer(info.page_count)
      assert info.page_count > 0
    end
  end

  describe "open/2 (with real files)" do
    test "successfully opens PDF with no password" do
      assert {:ok, handle} = ExQPDF.open(@open_pdf)
      assert handle.path == @open_pdf
      assert handle.password == nil
    end
  
    test "successfully opens PDF with only owner password" do
      assert {:ok, handle} = ExQPDF.open(@locked_pdf)
      assert handle.path == @locked_pdf
      assert handle.password == nil
    end
  
    test "fails to open password-encrypted PDF without password" do
      assert {:error, _} = ExQPDF.open(@encrypted_pdf)
    end
  
    test "successfully opens password-encrypted PDF with correct password" do
      # The password for example_encrypted.pdf is "open"
      password = "open"
      assert {:ok, handle} = ExQPDF.open(@encrypted_pdf, password: password)
      assert handle.path == @encrypted_pdf
      assert handle.password == password
    end
  end

  describe "metadata/2 (with real files)" do
    test "extracts metadata from PDF with no password" do
      assert {:ok, metadata} = ExQPDF.metadata(@open_pdf)
    
      # Basic PDF information
      assert metadata.password_required == false
      assert metadata.page_count > 0
      assert is_binary(metadata.version)
    
      # Document metadata - validate structure but not exact content
      # since it may vary between test environments
      assert is_map(metadata)
    
      # Check for common metadata fields
      # Not all PDFs will have all fields, so we don't assert specific values
      assert Map.has_key?(metadata, :title)
      assert Map.has_key?(metadata, :author)
      assert Map.has_key?(metadata, :creator)
      assert Map.has_key?(metadata, :producer)
    end
  
    test "returns limited info for password-protected PDF without password" do
      assert {:ok, metadata} = ExQPDF.metadata(@encrypted_pdf)
      assert metadata.password_required == true
    
      # No detailed metadata should be available without the password
      refute Map.has_key?(metadata, :title)
      refute Map.has_key?(metadata, :author)
    end
  
    test "extracts metadata from password-protected PDF with correct password" do
      password = "open"
      assert {:ok, metadata} = ExQPDF.metadata(@encrypted_pdf, password: password)
    
      # Basic PDF information
      assert metadata.password_required == false
      assert metadata.page_count > 0
      assert is_binary(metadata.version)
    
      # For encrypted PDFs
      assert metadata.encrypted == true
    
      # Document metadata structure should be present
      assert is_map(metadata)
    end
  end
end
