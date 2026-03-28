# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Ease of Movement (EOM)
    class EOM
      def self.calculate(data, period: 14)
        output = []
        emv_values = []
        prev_v = nil

        data.each do |v|
          if prev_v.nil?
            output << nil
            prev_v = v
            next
          end

          distance_moved = ((v[:high] + v[:low]) / 2.0) - ((prev_v[:high] + prev_v[:low]) / 2.0)
          
          range = (v[:high] - v[:low])
          box_ratio = range == 0 ? 0 : (v[:volume] / 100_000_000.0) / range

          emv = box_ratio == 0 ? 0 : distance_moved / box_ratio
          emv_values << emv
          
          if emv_values.size == period
            output << CalculationHelpers.average(emv_values)
            emv_values.shift
          else
            output << nil
          end
          
          prev_v = v
        end
        output
      end
    end
  end
end
