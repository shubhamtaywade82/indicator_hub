# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Know Sure Thing (KST)
    class KST
      def self.calculate(data, roc1: 10, roc2: 15, roc3: 20, roc4: 30, sma1: 10, sma2: 10, sma3: 10, sma4: 15)
        output = []
        # The lookback required is based on the largest (roc + sma)
        max_lookback = [roc1 + sma1, roc2 + sma2, roc3 + sma3, roc4 + sma4].max
        
        data.each_with_index do |_, i|
          if i < max_lookback - 2
            output << nil
          else
            rcma1 = calculate_rcma(data, i, roc1, sma1)
            rcma2 = calculate_rcma(data, i, roc2, sma2)
            rcma3 = calculate_rcma(data, i, roc3, sma3)
            rcma4 = calculate_rcma(data, i, roc4, sma4)

            if rcma1 && rcma2 && rcma3 && rcma4
              kst = (1 * rcma1) + (2 * rcma2) + (3 * rcma3) + (4 * rcma4)
              output << kst
            else
              output << nil
            end
          end
        end
        output
      end

      private

      def self.calculate_rcma(data, index, roc, sma)
        return nil if index < (roc + sma - 2)
        
        roc_data = []
        (index - sma + 1..index).each do |i|
          last_price = data[i]
          starting_price = data[i - roc + 1]
          return nil if starting_price.nil? || starting_price == 0
          
          roc_data << (last_price - starting_price) / starting_price.to_f * 100.0
        end
        CalculationHelpers.average(roc_data)
      end
    end
  end
end
