module IndicatorHub
  module Indicators
    # Relative Momentum Index (RMI).
    # RMI is a variation of the RSI that uses momentum instead of price change.
    class RMI
      include CalculationHelpers

      # Calculates the Relative Momentum Index.
      # @param data [Array<Numeric, Hash>] Array of prices or OHLCV hashes.
      # @param period [Integer] RMI smoothing period (default: 14).
      # @param momentum_period [Integer] Momentum period (default: 5).
      # @return [Array<Float, nil>] The calculated RMI values.
      def self.calculate(data, period: 14, momentum_period: 5)
        prices = data.is_a?(Array) && data.first.is_a?(Hash) ? data.map { |d| d[:close] } : data
        return Array.new(prices.length, nil) if prices.length < momentum_period + period

        ups = []
        downs = []

        # Calculate momentum changes
        (momentum_period...prices.length).each do |i|
          change = prices[i] - prices[i - momentum_period]
          ups << (change > 0 ? change : 0)
          downs << (change < 0 ? change.abs : 0)
        end

        # Wilder's smoothing on ups and downs
        avg_ups = WildersSmoothing.calculate(ups, period: period)
        avg_downs = WildersSmoothing.calculate(downs, period: period)

        results = Array.new(momentum_period, nil)
        (0...avg_ups.length).each do |i|
          if avg_ups[i].nil? || avg_downs[i].nil?
            results << nil
          elsif avg_downs[i] == 0
            results << 100.0
          else
            rs = avg_ups[i].to_f / avg_downs[i]
            results << (100.0 - (100.0 / (1.0 + rs))).round(4)
          end
        end
        results
      end
    end
  end
end
