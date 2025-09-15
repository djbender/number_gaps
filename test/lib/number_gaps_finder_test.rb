require "minitest/autorun"
require "csv"
require "tempfile"
require_relative "../../lib/number_gaps_finder"

class NumberGapsFinderTest < Minitest::Test
  def setup
    @temp_file = Tempfile.new(["test_data", ".csv"])
  end

  def teardown
    @temp_file.close
    @temp_file.unlink
  end

  def create_csv_file(data, headers: false)
    CSV.open(@temp_file.path, "w") do |csv|
      data.each { |row| csv << row }
    end
    @temp_file.rewind
    @temp_file.path
  end

  def test_finds_no_gaps_in_consecutive_sequence
    file_path = create_csv_file([["1"], ["2"], ["3"], ["4"], ["5"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_empty gaps
  end

  def test_finds_single_gap_in_sequence
    file_path = create_csv_file([["1"], ["2"], ["4"], ["5"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end

  def test_finds_multiple_gaps_in_sequence
    file_path = create_csv_file([["1"], ["2"], ["5"], ["6"], ["9"], ["10"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 2, gaps.length

    # First gap: 3-4
    assert_equal 3, gaps[0].f
    assert_equal 4, gaps[0].l

    # Second gap: 7-8
    assert_equal 7, gaps[1].f
    assert_equal 8, gaps[1].l
  end

  def test_finds_large_gap_in_sequence
    file_path = create_csv_file([["1"], ["2"], ["10"], ["11"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 9, gaps.first.l
  end

  def test_handles_empty_rows_by_skipping_them
    file_path = create_csv_file([["1"], [], ["2"], [], ["3"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_empty gaps
  end

  def test_handles_non_numeric_characters_by_stripping_them
    file_path = create_csv_file([["YOSE 001"], ["YOSE 002"], ["YOSE 004"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end

  def test_works_with_different_column_positions
    file_path = create_csv_file([
      ["name", "1", "data"],
      ["name", "2", "data"],
      ["name", "4", "data"]
    ])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 2)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end

  def test_handles_csv_with_headers
    file_path = create_csv_file([
      ["Number", "Description"],
      ["1", "First"],
      ["2", "Second"],
      ["4", "Fourth"]
    ])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1, headers: true)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end

  def test_handles_single_row_without_gaps
    file_path = create_csv_file([["42"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_empty gaps
  end

  def test_handles_sequence_starting_from_zero
    file_path = create_csv_file([["0"], ["1"], ["3"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 2, gaps.first.f
    assert_equal 2, gaps.first.l
  end

  def test_handles_mixed_alphanumeric_data
    file_path = create_csv_file([["ABC123"], ["DEF124"], ["GHI126"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 125, gaps.first.f
    assert_equal 125, gaps.first.l
  end

  def test_handles_completely_non_numeric_data_as_zeros
    file_path = create_csv_file([["ABC"], ["DEF"], ["GHI"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_empty gaps
  end

  def test_handles_large_numbers
    file_path = create_csv_file([["999998"], ["999999"], ["1000001"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 1000000, gaps.first.f
    assert_equal 1000000, gaps.first.l
  end

  def test_handles_negative_looking_numbers_strips_minus_sign
    file_path = create_csv_file([["-1"], ["-2"], ["-4"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end

  def test_handles_decimal_looking_numbers_strips_decimal_point
    file_path = create_csv_file([["1.0"], ["2.0"], ["4.0"]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    # "1.0" becomes "10", "2.0" becomes "20", "4.0" becomes "40"
    # So we expect gaps between 10-19 and 21-39
    assert_equal 2, gaps.length
    assert_equal 11, gaps.first.f
    assert_equal 19, gaps.first.l
    assert_equal 21, gaps[1].f
    assert_equal 39, gaps[1].l
  end

  def test_raises_error_for_non_existent_file
    assert_raises(Errno::ENOENT) do
      NumberGapsFinder::Runner.run!(file: "/non/existent/file.csv", column: 1)
    end
  end

  def test_handles_file_with_only_empty_rows
    file_path = create_csv_file([[""], [nil], [""]])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_empty gaps
  end

  def test_handles_complex_formatted_numbers
    file_path = create_csv_file([
      ["ID-001-A"],
      ["ID-002-B"],
      ["ID-004-C"]
    ])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 1)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end

  def test_handles_wide_csv_with_many_columns
    file_path = create_csv_file([
      ["col1", "col2", "1", "col4", "col5"],
      ["col1", "col2", "2", "col4", "col5"],
      ["col1", "col2", "4", "col4", "col5"]
    ])
    gaps = NumberGapsFinder::Runner.run!(file: file_path, column: 3)

    assert_equal 1, gaps.length
    assert_equal 3, gaps.first.f
    assert_equal 3, gaps.first.l
  end
end
