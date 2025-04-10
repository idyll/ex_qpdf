# ExQPDF Implementation Todo

## Project Setup
- [x] Review QPDF library documentation and capabilities
- [x] Ensure QPDF is properly installed in the development environment
- [x] Add any necessary dependencies to `mix.exs`
- [x] Create folder structure for modular organization

## Core Functionality
- [x] Create module for executing QPDF commands
  - [x] Implement function to safely execute shell commands
  - [x] Add error handling for command execution
  - [x] Create helper functions for common QPDF options

- [x] Implement password detection functionality
  - [x] Create function to check if a PDF requires a password
  - [x] Add proper error handling for missing files and other errors

- [x] Implement general PDF information extraction
  - [x] Add metadata extraction capabilities
  - [x] Extract page count and other basic information
  - [x] Format information into a structured data format

## API Design
- [x] Implement basic API functions:
  - [x] `password_required?/1` - Determine if PDF requires a password
  - [x] `info/1` - Get general information about a PDF
  - [x] `open/2` - Open a PDF (with password option if needed)

## Testing
- [x] Create test directory structure
  - [x] Add sample PDFs for testing (with and without passwords)

- [x] Write test cases
  - [x] Test password detection functionality
  - [x] Test metadata extraction
  - [x] Test error handling

## Documentation
- [x] Update module documentation
- [x] Add function documentation with examples
- [x] Create README with installation and usage instructions
- [x] Add license information

## Completed Enhancements
- [x] Extract more detailed metadata (author, creation date, etc.)
  - [x] Implement `metadata/2` function to extract comprehensive PDF information
  - [x] Add proper date formatting for PDF date strings
  - [x] Add tests for metadata extraction

## Planned Enhancements
### PDF Splitting
- [ ] Implement maximum page chunk splitting
  - [ ] Create `split_by_max_pages/3` function that splits PDF into chunks of specified max size
  - [ ] Ensure proper file naming for split files (e.g., original_name_part1.pdf, original_name_part2.pdf)
  - [ ] Handle edge cases (documents smaller than max pages)
  - [ ] Add support for custom output directory

- [ ] Implement first X pages extraction
  - [ ] Create `first_pages/3` function that extracts only the first N pages 
  - [ ] Handle edge cases (when N > total pages, just return the whole document)
  - [ ] Add support for custom output filename

### PDF Merging
- [ ] Implement PDF merging capability
  - [ ] Create `merge/2` function that combines multiple PDFs in specified order
  - [ ] Support both paths and handles as input
  - [ ] Handle password-protected PDFs in the merge list
  - [ ] Add proper error handling for invalid files

### Page Extraction
- [ ] Implement single page extraction
  - [ ] Create `extract_page/3` function to extract a specific page
  - [ ] Add proper error handling for out-of-range page numbers
  - [ ] Provide informative errors when requested page doesn't exist
  - [ ] Support custom output filename

### Other Enhancements
- [ ] Add PDF linearization support
- [ ] Improve error messages and debugging capabilities
- [ ] Add custom error types for better error handling
- [ ] Support for more QPDF features (encryption, decryption, etc.)
