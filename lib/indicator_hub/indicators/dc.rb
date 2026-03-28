# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Donchian Channel (DC)
    class DC
      def self.calculate(data, period: 20)
        output = []
        period_values = []

        data.each do |v|
          period_values << v
          if period_values.size == period
            upper = period_values.max
            lower = period_values.min
            output << {
              upper: upper,
              middle: (upper + lower) / 2.0,
              lower: lower
            }
            period_values.shift
          else
            output << nil
          end
        end
        output
      end
    end
  end
end
