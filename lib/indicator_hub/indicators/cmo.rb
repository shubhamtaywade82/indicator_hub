# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Chande Momentum Oscillator (CMO)
    class CMO
      def self.calculate(data, period: 9)
        output = []
        
        data.each_with_index do |val, i|
          if i < period
            output << nil
            next
          end

          up_sum = 0.0
          down_sum = 0.0

          (1..period).each do |j|
            curr = data[i - period + j]
            prev = data[i - period + j - 1]
            diff = curr - prev
            if diff > 0
              up_sum += diff
            else
              down_sum += diff.abs
            end
          end

          if (up_sum + down_sum) == 0
            output << 0.0
          else
            cmo = 100.0 * (up_sum - down_sum) / (up_sum + down_sum)
            output << cmo
          end
        end

        output
      end
    end
  end
end
