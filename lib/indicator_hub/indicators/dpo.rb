# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Detrended Price Oscillator (DPO)
    class DPO
      def self.calculate(data, period: 20)
        output = []
        midpoint = (period / 2) + 1
        
        data.each_with_index do |v, i|
          if i < (period + midpoint - 2)
            output << nil
          else
            sma_range = data[(i - midpoint - period + 2)..(i - midpoint + 1)]
            sma = CalculationHelpers.average(sma_range)
            output << (v - sma)
          end
        end
        output
      end
    end
  end
end
