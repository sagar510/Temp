require 'rspec/core/formatters/base_text_formatter'
require 'simplecov'

class CoverageFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :start, :stop, :message, :dump_failures
  
  def initialize(output)
    super(output)
    @test_failed = false
    @coverage_failed = false
  end

  def stop(notification)
    print_coverage_report
    exit_status = determine_exit_status(notification)
    dump_failures(notification) if @test_failed
    puts "Test execution completed."
    @covered_percent = SimpleCov.result.covered_percent
    puts "Coverage Percentage value: #{@covered_percent}%"
    ENV['COVERAGE_PERCENT'] = @covered_percent.to_s
    exit(exit_status)
  end

  def covered_percent
    @covered_percent
  end

  private

  def print_coverage_report
    if ENV.key?("COVERAGE")
      coverage_result = SimpleCov.result
      covered_percent = coverage_result.covered_percent
      output.puts "Coverage report: #{covered_percent}%"
    end
  end

  def determine_exit_status(notification)
    exit_status = 0

    if notification.failed_examples.any?
      @test_failed = true
    end

    if ENV.key?("COVERAGE")
      coverage_result = SimpleCov.result
      covered_percent = coverage_result.covered_percent
      min_coverage_threshold = 5

      if covered_percent < min_coverage_threshold
        @coverage_failed = true
      end
    end

    if @test_failed || @coverage_failed
      exit_status = 1
    end

    exit_status
  end
end
