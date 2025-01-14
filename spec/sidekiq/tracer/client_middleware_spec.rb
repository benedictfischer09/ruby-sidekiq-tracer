# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sidekiq::Tracer::ClientMiddleware do
  let(:tracer) { Test::Tracer.new }

  describe "pushing to the queue" do
    before do
      Sidekiq::Tracer.instrument_client(tracer: tracer)
      schedule_test_job
    end

    it "still enqueues job to the queue" do
      expect(TestJob.jobs.size).to eq(1)
    end
  end

  describe "auto-instrumentation" do
    before do
      Sidekiq::Tracer.instrument_client(tracer: tracer)
      schedule_test_job
    end

    it "creates a new span" do
      expect(tracer).to have_spans
    end

    it "sets operation_name to job name" do
      expect(tracer).to have_span("TestJob")
    end

    it "sets standard OT tags" do
      [
        %w[component Sidekiq],
        ["span.kind", "producer"]
      ].each do |key, value|
        expect(tracer).to have_span.with_tag(key, value)
      end
    end

    it "sets Sidekiq specific OT tags" do
      [
        ["sidekiq.queue", "default"],
        ["sidekiq.retry", "true"],
        ["sidekiq.args", "value1, value2, 1"],
        ["sidekiq.jid", /\S+/]
      ].each do |key, value|
        expect(tracer).to have_span.with_tag(key, value)
      end
    end
  end

  describe "span context injection" do
    before do
      Sidekiq::Tracer.instrument_client(tracer: tracer)
      schedule_test_job
    end

    it "injects span context to enqueued job" do
      enqueued_span = tracer.finished_spans.last

      job = TestJob.jobs.last
      carrier = job["Trace-Context"]
      extracted_span_context = tracer.extract(OpenTracing::FORMAT_TEXT_MAP, carrier)

      expect(enqueued_span.context).to eq(extracted_span_context)
    end
  end

  def schedule_test_job
    TestJob.perform_async("value1", "value2", 1)
  end

  # rubocop:disable RSpec/LeakyConstantDeclaration
  class TestJob
    include Sidekiq::Worker

    def perform(*args); end
  end
  # rubocop:enable RSpec/LeakyConstantDeclaration
end
