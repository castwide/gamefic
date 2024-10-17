# frozen_string_literal: true

module Gamefic
  class Response
    class Request
      attr_reader :response, :results

      def initialize(response, results)
        @response = response
        @results = results
      end

      def verb
        response.verb
      end

      def arguments
        results.map(&:match)
      end

      def precision
        response.precision
      end

      def strictness
        results.sum(&:strictness)
      end

      def valid?
        @valid ||= (response.queries.length == results.length) &&
                   results.none?(&:nil?) &&
                   (results.empty? || results.last.remainder.empty?)
      end

      # @param response [Response]
      # @param params [Array<Object>]
      def self.from_params(actor, response, params)
        results = response.queries.zip(params).each_with_object([]) do |parts, matches|
          query, param = parts
          if query.accept?(actor, param)
            matches.push Query::Result.new(param, '')
          else
            matches.push nil
          end
        end
        (params.length - response.queries.length).times { results.push nil }
        Request.new(response, results)
      end
    end
  end
end
