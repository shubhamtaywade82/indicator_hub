# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Rate of Change (ROC).
    # ROC is a momentum oscillator that measures the percentage change in price
    # between the current price and the price a certain number of periods ago.
    class ROC
      include CalculationHelpers

      # Calculates the Rate of Change.
      # @param prices [Array<Numeric>] Array of prices.
      # @param period [Integer] The ROC period (default: 12).
      # @return [Array<Float, nil>] The calculated ROC values.
      def self.calculate(prices, period: 12)
        return Array.new(prices.length, nil) if prices.length < period

        results = []
        (0...prices.length).each do |i|
          if i < period
            results << nil
          else
            current_price = prices[i]
            lookback_price = prices[i - period]

            results << if lookback_price.zero?
                         0.0
                       else
                         (((current_price - lookback_price).to_f / lookback_price) * 100).round(4)
                       end
          end
        end
        results
      end
    end
  end
end
