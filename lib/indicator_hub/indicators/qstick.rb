module IndicatorHub
  module Indicators
    # QStick.
    # QStick is a technical indicator that identifies the trend of a security's 
    # price by calculating the moving average of the difference between open and close.
    class QStick
      include CalculationHelpers

      # Calculates the QStick.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The QStick period (default: 10).
      # @return [Array<Float, nil>] The calculated QStick values.
      def self.calculate(data, period: 10)
        return [] if data.length < period

        opens = data.map { |d| d[:open] }
        closes = data.map { |d| d[:close] }
        
        diffs = closes.zip(opens).map { |c, o| c - o }

        results = []
        (0...data.length).each do |i|
          if i < period - 1
            results << nil
          else
            current_diffs = diffs[i - period + 1..i]
            results << (current_diffs.sum.to_f / period).round(4)
          end
        end
        results
      end
    end
  end
end
