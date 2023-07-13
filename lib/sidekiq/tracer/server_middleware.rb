# frozen_string_literal: true

module Sidekiq
  module Tracer
    class ServerMiddleware
      include Commons

      attr_reader :tracer, :active_span, :after_trace

      def initialize(tracer, active_span, after_trace)
        @tracer = tracer
        @active_span = active_span
        @after_trace = after_trace
      end

      # rubocop:disable Metrics/MethodLength
      def call(_worker, job, _queue)
        tracer.start_active_span(operation_name(job),
                                 ignore_active_scope: true,
                                 tags: tags(job, "consumer")) do |scope|
          begin
            yield
          rescue StandardError => e
            tag_errors(scope.span, e) if scope.span
            raise
          ensure
            after_trace&.call(scope.span) if scope.span
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def tag_errors(span, error)
        span.set_tag("error", true)
        span.log_kv(**{ event: "error", 'error.object': error })
      end
    end
  end
end
