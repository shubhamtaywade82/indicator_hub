# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Donchian Channel (DC)
    class DC
      def self.calculate(data, period: 20)
        output = []

        data.each_with_index do |_, i|
          if i < period - 1
            output << { upper: nil, middle: nil, lower: nil }
          else
            period_data = data[(i - period + 1)..i]
            highs = period_data.map { |v| (v[:high] || v["high"]).to_f }
            lows = period_data.map { |v| (v[:low] || v["low"]).to_f }
            
            upper = highs.max
            lower = lows.min
            
            output << {
              upper: upper,
              middle: (upper + lower) / 2.0,
              lower: lower
            }
          end
        end
        output
      end
    end
  end
end
