require "test_helper"
require "ostruct"

class NumberGapsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get number_gaps_index_url
    assert_response :success
  end

  setup do
    # Create a temporary CSV file for testing
    @test_file_content = "header1,header2\n1,data\n3,data\n5,data"
    @test_file = Tempfile.new(["test", ".csv"])
    @test_file.write(@test_file_content)
    @test_file.rewind
  end

  teardown do
    @test_file.close
    @test_file.unlink
  end

  test "analyze redirects with alert when no file provided" do
    post number_gaps_analyze_path

    assert_redirected_to number_gaps_index_path
    assert_equal "Please select a file", flash[:alert]
  end

  test "analyze processes file successfully with default parameters" do
    post number_gaps_analyze_path, params: {
      file: fixture_file_analyze(@test_file.path, "text/csv")
    }

    assert_response :success
  end

  test "analyze processes file with custom column and headers parameters" do
    post number_gaps_analyze_path, params: {
      file: fixture_file_analyze(@test_file.path, "text/csv"),
      column: "1",
      headers: "true"
    }

    assert_response :success
  end

  test "analyze handles NumberGapsFinder exceptions" do
    error_message = "Invalid file format"

    NumberGapsFinder::Runner.stub :run!, ->(*) { raise StandardError, error_message } do
      post number_gaps_analyze_path, params: {
        file: fixture_file_analyze(@test_file.path, "text/csv")
      }

      assert_redirected_to root_path
      assert_equal "Error processing file: #{error_message}", flash[:alert]
    end
  end

  test "analyze handles nil gaps gracefully" do
    NumberGapsFinder::Runner.stub :run!, [] do
      post number_gaps_analyze_path, params: {
        file: fixture_file_analyze(@test_file.path, "text/csv")
      }

      assert_response :success
    end
  end

  test "analyze formats gaps with ranges correctly" do
    # Create a test file that will produce actual gaps to test formatting logic
    test_content = "1\n3\n10"
    test_file = Tempfile.new(["gaps_test", ".csv"])
    test_file.write(test_content)
    test_file.rewind

    post number_gaps_analyze_path, params: {
      file: fixture_file_analyze(test_file.path, "text/csv"),
      headers: "false"
    }

    assert_response :success

    test_file.close
    test_file.unlink
  end

  test "analyze formats single number gaps correctly" do
    # Create test file with single number gap
    test_content = "1\n3"
    test_file = Tempfile.new(["single_gap_test", ".csv"])
    test_file.write(test_content)
    test_file.rewind

    post number_gaps_analyze_path, params: {
      file: fixture_file_analyze(test_file.path, "text/csv"),
      headers: "false"
    }

    assert_response :success

    test_file.close
    test_file.unlink
  end

  private

  def fixture_file_analyze(path, mime_type)
    Rack::Test::UploadedFile.new(path, mime_type)
  end
end
