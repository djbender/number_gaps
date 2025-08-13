# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8 web application that analyzes CSV files to find gaps in sequential number data. Users upload CSV files, specify which column contains numbers, and the app identifies missing numbers in the sequence.

## Development Commands

### Setup
```bash
bundle install
bin/rails db:create
bin/rails db:migrate
```

### Running the Application
```bash
bin/rails server  # Development server on port 3000
```

### Testing
```bash
bin/rails test                                    # Run all tests
bin/rails test test/controllers/                  # Run controller tests
bin/rails test test/controllers/number_gaps_controller_test.rb  # Single test file
```

### Code Quality
```bash
bin/rubocop                          # Ruby style checking
bin/brakeman                         # Security vulnerability scanning
```

## Architecture

### Core Algorithm
The gap detection logic is centralized in `lib/number_gaps_finder/` with two key components:
- `NumberGapsFinder::Runner` - Main algorithm that processes CSV data in a single pass
- `Gap` class - Data structure representing number ranges (first, last)

The algorithm assumes:
- Numbers are in sequential order in the CSV
- Column selection is 1-based (user-facing) but converted to 0-based internally
- Non-numeric characters are stripped from fields using `delete("^0-9")`

### Web Interface
- Single controller: `NumberGapsController`
- Two actions: `index` (upload form) and `analyze` (process CSV and display results)
- Views use Rails form helpers with multipart file uploads
- Error handling redirects to root with flash messages

### Data Processing
- CSV parsing handles headers optionally
- Empty rows are skipped automatically
- Numbers are extracted by stripping non-digits, which handles formatted numbers like "YOSE 120196"
- Output formatting includes zero-padding based on the largest number's digit count

## Key Edge Cases to Consider

The current algorithm has several limitations:
- **Column bounds**: No validation if specified column exists
- **Unsorted data**: Assumes chronological order in CSV
- **Duplicate detection**: Doesn't identify repeated numbers
- **Zero-only fields**: Empty cells become 0, potentially creating false gaps
- **Non-sequential starting points**: Doesn't validate if sequence should start from 1

## Database Configuration

Uses PostgreSQL with a unique setup:
- Separate database for error tracking: `solid_errors` gem with dedicated schema
- Error database configured via `db/errors_schema.rb`
- Main application is database-less (no models or migrations in standard locations)
- **Test environment**: ActiveRecord and SolidErrors are completely disabled - no database required for testing

## Deployment

Supports multiple deployment methods:
- **Heroku**: `app.json` with health checks and postdeploy migrations
- **Docker**: Production-ready Dockerfile with Thruster for asset serving
- **Dokku**: Configured with postdeploy database migrations
- Uses Ruby 3.4.5 as specified in `.ruby-version`
