# frozen_string_literal: true

require_relative "../calculation_helpers"
require_relative "ema"

module IndicatorHub
  module Indicators
    # True Strength Index (TSI)
    class TSI
      def self.calculate(data, low_period: 13, high_period: 25)
        low_period = low_period.to_i
        high_period = high_period.to_i
        
        return [] if data.size < 2
        
        # 1. Momentum and absolute momentum
        momentum = []
        abs_momentum = []
        
        (1...data.size).each do |i|
          m = data[i][:close] - data[i - 1][:close]
          momentum << m
          abs_momentum << m.abs
        end
        
        # 2. First EMA (high_period)
        ema1_m = EMA.calculate(momentum, period: high_period)
        ema1_abs_m = EMA.calculate(abs_momentum, period: high_period)
        
        # 3. Second EMA (low_period)
        ema1_m_filtered = ema1_m.compact
        ema1_abs_m_filtered = ema1_abs_m.compact
        
        ema2_m = EMA.calculate(ema1_m_filtered, period: low_period)
        ema2_abs_m = EMA.calculate(ema1_abs_m_filtered, period: low_period)
        
        # Align results back to original data size
        # momentum size is (data.size - 1)
        # ema1 has (high_period - 1) nils
        # ema2 has (low_period - 1) additional nils
        # total nils in ema2 relative to momentum: (high_period - 1) + (low_period - 1)
        # relative to original data: 1 + (high_period - 1) + (low_period - 1) = high_period + low_period - 1
        
        offset = high_period + low_period - 1
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
