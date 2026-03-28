module IndicatorHub
  module Indicators
    class ROC
      include CalculationHelpers

      # Rate Of Change (ROC)
      # @param prices [Array] Array of prices
      # @param period [Integer] The period for the ROC
      # @return [Array<Float, nil>] An array of ROC values
      def self.calculate(prices, period: 12)
        return Array.new(prices.length, nil) if prices.length < period

        results = []
        (0...prices.length).each do |i|
          if i < period
            results << nil
          else
            current_price = prices[i]
            lookback_price = prices[i - period]
            
            if lookback_price == 0
              results << 0.0
            else
              results << (((current_price - lookback_price).to_f / lookback_price) * 100).round(4)
            end
          end
        end
        results
      end
    end
  end
end
