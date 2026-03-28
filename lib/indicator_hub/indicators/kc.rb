# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Keltner Channel (KC)
    class KC
      def self.calculate(data, period: 10)
        output = []
        typical_prices = []
        trading_ranges = []

        data.each do |v|
          tp = (v[:high] + v[:low] + v[:close]) / 3.0
          tr = v[:high] - v[:low]
          
          typical_prices << tp
          trading_ranges << tr
          
          if typical_prices.size == period
            mb = CalculationHelpers.average(typical_prices)
            tra = CalculationHelpers.average(trading_ranges)
            
            output << {
              upper: mb + tra,
              middle: mb,
              lower: mb - tra
            }
            typical_prices.shift
            trading_ranges.shift
          else
            output << nil
          end
        end
        output
      end
    end
  end
end
