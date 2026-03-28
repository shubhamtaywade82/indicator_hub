module IndicatorHub
  module Indicators
    class QStick
      include CalculationHelpers

      # QStick
      # @param data [Array<Hash>] Array of OHLC data
      # @param period [Integer] The period for the QStick
      # @return [Array<Float, nil>] An array of QStick values
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
