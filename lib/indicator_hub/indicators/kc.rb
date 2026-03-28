# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Keltner Channel (KC).
    # KC is a volatility-based technical indicator composed of three separate lines.
    class KC
      # Calculates the Keltner Channel.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The KC period (default: 20).
      # @param multiplier [Float] The ATR multiplier (default: 1.5).
      # @return [Array<Hash, nil>] The calculated KC values { upper: Float, middle: Float, lower: Float }.
      def self.calculate(data, period: 20, multiplier: 1.5)
        output = []
        typical_prices = []
        trading_ranges = []

        data.each do |v|
          tp = (v[:high] + v[:low] + v[:close]) / 3.0
          tr = v[:high] - v[:low]

          typical_prices << tp
          trading_ranges << tr

          if typical_prices.size == period
            mb = CalculationHelpers.average(typical_prices)
            tra = CalculationHelpers.average(trading_ranges)

            output << {
              upper: mb + (tra * multiplier),
              middle: mb,
              lower: mb - (tra * multiplier)
            }
            typical_prices.shift
            trading_ranges.shift
          else
            output << nil
          end
        end
        output
      end
    end
  end
end
