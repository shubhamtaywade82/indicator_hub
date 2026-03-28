# frozen_string_literal: true

require_relative 'ema'

module IndicatorHub
  module Indicators
    # Moving Average Convergence Divergence (MACD)
    class MACD
      def self.calculate(data, fast_period: 12, slow_period: 26, signal_period: 9)
        fast_ema = EMA.calculate(data, period: fast_period)
        slow_ema = EMA.calculate(data, period: slow_period)

        macd_line = []
        data.each_with_index do |_, i|
          if fast_ema[i] && slow_ema[i]
            macd_line << fast_ema[i] - slow_ema[i]
          else
            macd_line << nil
          end
        end

        # Signal Line is EMA of MACD line (ignoring initial nil values)
        compact_macd = macd_line.compact
        compact_signal = EMA.calculate(compact_macd, period: signal_period)
        
        # Re-align signal line with original data
        signal_line = Array.new(macd_line.size - compact_signal.size, nil) + compact_signal
        
        output = []
        data.each_with_index do |_, i|
          histogram = (macd_line[i] && signal_line[i]) ? (macd_line[i] - signal_line[i]) : nil
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
