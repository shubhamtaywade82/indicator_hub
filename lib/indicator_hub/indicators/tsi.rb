# frozen_string_literal: true

require_relative "../calculation_helpers"
require_relative "ema"

module IndicatorHub
  module Indicators
    # True Strength Index (TSI).
    # TSI is a technical momentum oscillator used to identify trends and reversals.
    class TSI
      # Calculates the True Strength Index.
      # @param data [Array<Numeric>] The input data points.
      # @param fast_period [Integer] Fast EMA period (default: 13).
      # @param slow_period [Integer] Slow EMA period (default: 25).
      # @return [Array<Float, nil>] The calculated TSI values.
      def self.calculate(data, fast_period: 13, slow_period: 25)
        fast_period = fast_period.to_i
        slow_period = slow_period.to_i
        
        return [] if data.size < 2
        
        # 1. Momentum and absolute momentum
        momentum = []
        abs_momentum = []
        
        (1...data.size).each do |i|
          m = data[i] - data[i - 1]
          momentum << m
          abs_momentum << m.abs
        end
        
        # 2. First EMA (slow_period)
        ema1_m = EMA.calculate(momentum, period: slow_period)
        ema1_abs_m = EMA.calculate(abs_momentum, period: slow_period)
        
        # 3. Second EMA (fast_period)
        ema1_m_filtered = ema1_m.compact
        ema1_abs_m_filtered = ema1_abs_m.compact
        
        ema2_m = EMA.calculate(ema1_m_filtered, period: fast_period)
        ema2_abs_m = EMA.calculate(ema1_abs_m_filtered, period: fast_period)
        
        # Align results back to original data size
        # momentum size is (data.size - 1)
        # ema1 has (slow_period - 1) nils
        # ema2 has (fast_period - 1) additional nils
        # total nils in ema2 relative to momentum: (slow_period - 1) + (fast_period - 1)
        # relative to original data: 1 + (slow_period - 1) + (fast_period - 1) = slow_period + fast_period - 1
        
        offset = slow_period + fast_period - 1
        output = Array.new(data.size, nil)
        
        ema2_m_compact = ema2_m.compact
        ema2_abs_m_compact = ema2_abs_m.compact
        
        ema2_m_compact.each_with_index do |v, i|
          if offset + i < data.size
            div = ema2_abs_m_compact[i]
            output[offset + i] = div.zero? ? 0.0 : 100.0 * (v / div.to_f)
          end
        end
        
        output
      end
    end
  end
end
