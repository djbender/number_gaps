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
    @test_file = Tempfile.new([ "test", ".csv" ])
    @test_file.write(@test_file_content)
    @test_file.rewind
  end

  teardown do
    @test_file.close
    @test_file.unlink
  end

  test "analyze redirects with alert when no file provided" do
    skip
    post number_gaps_analyze_path

    assert_response 400, "Please select a file"
    assert_equal "Please select a file", flash[:alert]
  end

  test "analyze processes file successfully with default parameters" do
    skip
    # Mock the NumberGapsFinder service
    mock_gaps = [
      OpenStruct.new(l: 2, digits: [ 2 ]),
      OpenStruct.new(l: 4, digits: [ 4 ])
    ]

    NumberGapsFinder::Runner.stub(:run!, mock_gaps) do
      post number_gaps_analyze_path, params: {
        file: fixture_file_analyze(@test_file.path, "text/csv"),
        column: 1,
        headers: false
      }

      assert_response :success
      assert_template :results
    end
  end

  test "analyze processes file with custom column and headers parameters" do
    skip
    mock_gaps = [ OpenStruct.new(l: 10, digits: [ 1, 0 ]) ]
    captured_args = nil

    NumberGapsFinder::Runner.stub :run!, ->(args) {
      captured_args = args
      mock_gaps
    } do
      post number_gaps_analyze_path, params: {
        file: fixture_file_analyze(@test_file.path, "text/csv"),
        column: "2",
        headers: "false"
      }

      assert_response :success

      # Verify the service was called with correct parameters
      assert_equal 2, captured_args[:column]
      assert_equal false, captured_args[:headers]
      assert_kind_of Tempfile, captured_args[:file]
    end
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

  private

  def fixture_file_analyze(path, mime_type)
    Rack::Test::UploadedFile.new(path, mime_type)
  end
end
