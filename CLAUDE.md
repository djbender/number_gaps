# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8 web application that analyzes CSV files to find gaps in sequential number data. Users upload CSV files, specify which column contains numbers, and the app identifies missing numbers in the sequence.

## Development Commands

### Setup
```bash
bundle install --jobs $(nproc)
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
bin/rails test test/lib/                          # Run library tests
bin/rails test test/controllers/number_gaps_controller_test.rb  # Single test file
bin/rails test test/lib/number_gaps_finder_test.rb             # Core algorithm tests
bin/rails test test/lib/number_gaps_finder/gap_test.rb         # Gap class tests
```

### Code Quality
```bash
bin/standardrb                       # Ruby style checking
bin/brakeman                         # Security vulnerability scanning
```

## Architecture

### Core Algorithm
The gap detection logic is centralized in `lib/number_gaps_finder/` with two key components:
- `NumberGapsFinder::Runner` - Main algorithm that processes CSV data in a single pass
- `Gap` class - Data structure representing number ranges with `f` (first) and `l` (last) attributes

The algorithm flow:
1. Iterates through CSV rows, skipping empty ones
2. Extracts numbers from specified column using `delete("^0-9")`
3. Tracks sequence continuity by comparing `current` with `last.succ`
4. Creates `Gap` objects for missing ranges between `last.succ` and `current.pred`
5. Returns array of gaps for formatting

Key assumptions:
- Numbers are in sequential order in the CSV
- Column selection is 1-based (user-facing) but converted to 0-based internally
- Non-numeric characters are stripped from fields using `delete("^0-9")`

### Web Interface
- Single controller: `NumberGapsController`
- Two actions: `index` (upload form) and `analyze` (process CSV and display results)
- Routes: `GET /number_gaps/index` (root), `POST /number_gaps/analyze`
- Views use Rails form helpers with multipart file uploads
- Error handling redirects to root with flash messages
- SolidErrors engine mounted at `/solid_errors` (disabled in test environment)

### Data Processing
- CSV parsing handles headers optionally via boolean parameter
- Empty rows are skipped automatically using `row.compact.empty?`
- Numbers are extracted by stripping non-digits, which handles formatted numbers like "YOSE 120196"
- Output formatting includes zero-padding based on the largest number's digit count via `sprintf("%0#{@precision}d", val)`
- Gap ranges displayed as single numbers or "first-last" format

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
- **Heroku**: `app.json` with health checks and postdeploy migrations # untested
- **Docker**: Production-ready Dockerfile with Thruster for asset serving
- **Dokku**: Configured with postdeploy database migrations via `nginx.conf.sigil`
- Uses Ruby 4.0.1 as specified in `.ruby-version`

### Health Checks
- Rails health check available at `/up` endpoint
- Returns 200 if app boots without exceptions, otherwise 500
- Useful for load balancers and uptime monitoring

## File Structure

Key files and directories:
- `app/controllers/number_gaps_controller.rb` - Main controller handling uploads and analysis
- `app/views/number_gaps/` - Upload form (`index.html.erb`) and results (`analyze.html.erb`)
- `lib/number_gaps_finder.rb` - Main module requiring Gap class
- `lib/number_gaps_finder/gap.rb` - Gap data structure with `f`, `l` attributes and utility methods
- `test/` - Comprehensive test suite covering controllers and library logic
- `config/routes.rb` - Application routing configuration
- `Dockerfile` - Production container configuration
- `app.json` - Heroku deployment configuration
- `nginx.conf.sigil` - Dokku nginx configuration
