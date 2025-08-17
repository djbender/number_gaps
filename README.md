# Number Gaps Finder

[![CI](https://github.com/djbender/number_gaps/actions/workflows/ci.yml/badge.svg)](https://github.com/djbender/number_gaps/actions/workflows/ci.yml)

A Rails 8 web application that analyzes CSV files to identify gaps in sequential number data. Upload a CSV file, specify which column contains numbers, and the app will find missing numbers in the sequence.

## Features

- **CSV Upload**: Upload CSV files with optional header support
- **Column Selection**: Choose which column (1-20) contains the sequential numbers
- **Gap Detection**: Identifies missing numbers in sequences
- **Formatted Output**: Results show gap ranges with zero-padding based on largest number
- **Error Handling**: Graceful handling of malformed files and processing errors

## Requirements

- Ruby 3.4.5
- PostgreSQL (for error tracking only)
- Rails 8.0.2+

## Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Database setup:**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

3. **Start the server:**
   ```bash
   bin/rails server
   ```

   The application will be available at http://localhost:3000

## Usage

1. Navigate to the homepage
2. Upload a CSV file using the form
3. Select the column index containing sequential numbers (1-based)
4. Specify whether your CSV has headers
5. Click "Find Gaps" to analyze

### Example

For a CSV with numbers: 1, 2, 5, 6, 10
The app will identify gaps: 3-4, 7-9

## Algorithm

The gap detection uses a single-pass algorithm that:
- Processes CSV data row by row
- Strips non-numeric characters from fields (handles formatted numbers like "YOSE 120196")
- Assumes numbers are in sequential order
- Identifies ranges of missing consecutive numbers
- Zero-pads output based on the largest number's digit count

## Development

### Running Tests

```bash
bin/rails test                                    # Run all tests
bin/rails test test/controllers/                  # Run controller tests
bin/rails test test/lib/                          # Run library tests
```

### Code Quality

```bash
bin/rubocop                          # Ruby style checking
bin/brakeman                         # Security vulnerability scanning
```

### Project Structure

- `app/controllers/number_gaps_controller.rb` - Web interface controller
- `lib/number_gaps_finder/` - Core gap detection algorithm
  - `runner.rb` - Main algorithm implementation
  - `gap.rb` - Data structure for number ranges
- `app/views/number_gaps/` - Upload form and results views

## Deployment

The application supports multiple deployment methods:

- **Heroku**: Configured with `app.json` # untested
- **Docker**: Production-ready `Dockerfile` with Thruster
- **Dokku**: Supports postdeploy database migrations

## Database Configuration

- Uses PostgreSQL with minimal database requirements
- Separate error tracking database via `solid_errors` gem
- Test environment runs database-free for faster testing

## Limitations

- Assumes chronological order in CSV data
- No validation for column bounds
- Doesn't detect duplicate numbers
- Empty cells become 0, potentially creating false gaps
- No validation for non-sequential starting points
