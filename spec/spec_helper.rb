require "bundler/setup"
require "tracing-matchers"
require "sidekiq/testing"
require "sidekiq-opentracing"
require "pry"

# patch the test tracer to accept and ignore the :ignore_active_scope argument. This is ugly but necessary
# to avoid forking and updating the test-tracer gem to handle the latest version of OpenTracing
module TestTracerUpdates
  def start_span(operation_name, child_of: nil, references: nil, start_time: Time.now, tags: nil, ignore_active_scope: false)
    super(operation_name, child_of: child_of, references: references, start_time: start_time, tags: tags)
  end
end
Test::Tracer.prepend TestTracerUpdates

Sidekiq::Testing.fake!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end

