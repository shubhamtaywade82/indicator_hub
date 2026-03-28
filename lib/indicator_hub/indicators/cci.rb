# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Commodity Channel Index (CCI)
    class CCI
      def self.calculate(data, period: 20, constant: 0.015)
        tp_values = data.map { |v| (v[:high] + v[:low] + v[:close]) / 3.0 }
        output = []

        tp_values.each_with_index do |tp, i|
          if i < period - 1
            output << nil
            next
          end

          window = tp_values[(i - period + 1)..i]
          period_sma = CalculationHelpers.average(window)
          mad = CalculationHelpers.mean_absolute_deviation(window)
          
          if mad == 0
            output << 0.0
          else
            cci = (tp - period_sma) / (constant * mad)
            output << cci
          end
        end

        output
      end
    end
  end
end
