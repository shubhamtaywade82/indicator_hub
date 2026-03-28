# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Detrended Price Oscillator (DPO).
    # DPO is an indicator that attempts to eliminate trend from price in order to
    # make it easier to identify cycles.
    class DPO
      # Calculates the Detrended Price Oscillator.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The DPO period (default: 20).
      # @return [Array<Float, nil>] The calculated DPO values.
      def self.calculate(data, period: 20)
        output = []
        midpoint = (period / 2) + 1

        data.each_with_index do |v, i|
          if i < (period + midpoint - 2)
            output << nil
          else
            sma_range = data[(i - midpoint - period + 2)..(i - midpoint + 1)]
            sma = CalculationHelpers.average(sma_range)
            output << (v - sma)
          end
        end
        output
      end
    end
  end
end
