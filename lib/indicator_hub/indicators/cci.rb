# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Commodity Channel Index (CCI).
    # CCI measures the current price level relative to an average price level over a given period of time.
    class CCI
      # Calculates the Commodity Channel Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The period for CCI (default: 20).
      # @param constant [Float] The constant used for scaling (default: 0.015).
      # @return [Array<Float, nil>] The calculated CCI values.
      def self.calculate(data, period: 20, constant: 0.015)
        tp_values = data.map { |v| (v[:high] + v[:low] + v[:close]) / 3.0 }
        output = []

        tp_values.each_with_index do |tp, i|
          if i < period - 1
            output << nil
            next
          end

          window = tp_values[(i - period + 1)..i]
          sma = CalculationHelpers.average(window)
          mad = CalculationHelpers.mean_absolute_deviation(window, sma)

          if mad.zero?
            output << 0.0
          else
            cci = (tp - sma) / (constant * mad)
            output << cci
          end
        end

        output
      end
    end
  end
end
