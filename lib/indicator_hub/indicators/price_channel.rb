module IndicatorHub
  module Indicators
    class PriceChannel
      include CalculationHelpers

      # Price Channel
      # @param data [Array<Hash>] Array of OHLC data
      # @param period [Integer] The period for the price channel
      # @return [Array<Hash>] An array containing the upper and lower price channel values
      def self.calculate(data, period: 20)
        return [] if data.length < period

        highs = data.map { |d| d[:high] }
        lows = data.map { |d| d[:low] }

        results = []
        (0...data.length).each do |i|
          if i < period - 1
            results << { upper: nil, lower: nil }
          else
            current_highs = highs[i - period + 1..i]
            current_lows = lows[i - period + 1..i]
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
