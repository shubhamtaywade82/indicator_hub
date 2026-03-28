# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Cumulative Return (CR).
    # CR is a measure of the total return on an investment over a set period of time.
    class CR
      # Calculates the Cumulative Return.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The period (default: 1).
      # @return [Array<Float>] The calculated CR values.
      def self.calculate(data, period: 1)
        return [] if data.empty?
        
        start_price = data.first.to_f
        return Array.new(data.size, 0.0) if start_price.zero?

        data.map do |v|
          (v.to_f - start_price) / start_price
        end
      end
    end
  end
end
