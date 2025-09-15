require 'minitest'
require 'net/http'
require 'json'

class LizardReporter < Minitest::StatisticsReporter
  def report
    super
    send_to_lizard if configured?
  end

  def before_test(_); end
  def after_test(_); end
  def before_suite(_); end
  def after_suite(_); end

  private

  def configured?
    ENV['LIZARD_API_KEY'] && ENV['LIZARD_URL']
  end

  def send_to_lizard
    payload = {
      test_run: {
        commit_sha: ENV['GITHUB_SHA'] || `git rev-parse HEAD`.strip,
        branch: ENV['GITHUB_REF_NAME'] || `git branch --show-current`.strip,
        ruby_specs: count,
        js_specs: 0,
        runtime: total_time,
        coverage: extract_coverage,
        ran_at: Time.current.iso8601
      }
    }

    uri = URI("#{ENV['LIZARD_URL']}/api/v1/test_runs")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['LIZARD_API_KEY']}"
    request['Accept'] = request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    response = http.request(request)
    if response.code.to_i === 400...500
      puts "❌ Lizard API error (#{response.code}): #{response.body}"
    else
      puts "📊 Sent test results to Lizard: #{response.code}"
    end
  rescue => e
    puts "❌ Failed to send to Lizard: #{e.message}"
    puts e.backtrace.first(5) # Add backtrace for debugging
  end

  def extract_coverage
    return SimpleCov.result.covered_percent if defined?(SimpleCov) && SimpleCov.result
    0.0
  end
end
