module IndicatorHub
  module Indicators
    class WildersSmoothing
      include CalculationHelpers

      # Wilders Smoothing
      # @param prices [Array] Array of prices
      # @param period [Integer] The period for the smoothing
      # @return [Array<Float, nil>] An array of Wilders Smoothing values
      def self.calculate(prices, period: 14)
        return Array.new(prices.length, nil) if prices.length < period

        results = Array.new(period - 1, nil)
        
        # First Wilder's is a simple average of the first 'period' values
        initial_sma = prices.first(period).sum.to_f / period
        results << initial_sma.round(4)
        
        wilders = initial_sma
        alpha = 1.0 / period

        prices.drop(period).each do |price|
          wilders = (price - wilders) * alpha + wilders
          results << wilders.round(4)
        end

        results
      end
    end
  end
end
