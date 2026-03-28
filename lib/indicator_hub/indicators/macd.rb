# frozen_string_literal: true

require_relative "ema"

module IndicatorHub
  module Indicators
    # Moving Average Convergence Divergence (MACD).
    # MACD is a trend-following momentum indicator that shows the relationship
    # between two moving averages of a security’s price.
    class MACD
      # Calculates the Moving Average Convergence Divergence.
      # @param data [Array<Numeric>] The input data points.
      # @param fast_period [Integer] The fast EMA period (default: 12).
      # @param slow_period [Integer] The slow EMA period (default: 26).
      # @param signal_period [Integer] The signal EMA period (default: 9).
      # @return [Array<Hash, nil>] The calculated MACD components (macd, signal, histogram).
      def self.calculate(data, fast_period: 12, slow_period: 26, signal_period: 9)
        fast_ema = EMA.calculate(data, period: fast_period)
        slow_ema = EMA.calculate(data, period: slow_period)

        macd_line = []
        data.each_with_index do |_, i|
          macd_line << (fast_ema[i] - slow_ema[i] if fast_ema[i] && slow_ema[i])
        end

        # Signal Line is EMA of MACD line (ignoring initial nil values)
        compact_macd = macd_line.compact
        compact_signal = EMA.calculate(compact_macd, period: signal_period)

        # Re-align signal line with original data
        signal_line = Array.new(macd_line.size - compact_signal.size, nil) + compact_signal

        output = []
        data.each_with_index do |_, i|
          histogram = macd_line[i] && signal_line[i] ? (macd_line[i] - signal_line[i]) : nil
          output << {
            macd: macd_line[i],
            signal: signal_line[i],
            histogram: histogram
          }
        end
        output
      end
    end
  end
end
