# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Average True Range (ATR)
    class ATR
      def self.calculate(data, period: 14)
        output = []
        tr_values = []
        prev_close = nil
        current_atr = nil

        data.each_with_index do |v, i|
          if i == 0
            tr = v[:high] - v[:low]
          else
            tr = CalculationHelpers.true_range(v[:high], v[:low], prev_close)
          end
          
          tr_values << tr
          prev_close = v[:close]

          if tr_values.size < period
            output << nil
          elsif tr_values.size == period
            current_atr = CalculationHelpers.average(tr_values)
            output << current_atr
          else
            current_atr = CalculationHelpers.wilder_smoothing(current_atr, tr, period)
            output << current_atr
          end
        end

        output
      end
    end
  end
end
