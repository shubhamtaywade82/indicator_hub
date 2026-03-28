# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Price Channel.
    # Price Channel is a technical indicator that identifies the high and low
    # prices over a specified period.
    class PriceChannel
      include CalculationHelpers

      # Calculates the Price Channel.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The Price Channel period (default: 20).
      # @return [Array<Hash>] The calculated Price Channel values { upper: Float, lower: Float }.
      def self.calculate(data, period: 20)
        return [] if data.length < period

        highs = data.map { |d| d[:high] }
        lows = data.map { |d| d[:low] }

        results = []
        (0...data.length).each do |i|
          if i < period - 1
            results << { upper: nil, lower: nil }
          else
            current_highs = highs[(i - period + 1)..i]
            current_lows = lows[(i - period + 1)..i]
            results << {
              upper: current_highs.max,
              lower: current_lows.min
            }
          end
        end
        results
      end
    end
  end
end
