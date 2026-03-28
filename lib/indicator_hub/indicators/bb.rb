# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Bollinger Bands (BB)
    class BB
      def self.calculate(data, period: 20, standard_deviations: 2)
        return [] if data.size < period

        period_values = []
        output = []

        data.each do |v|
          period_values << v
          if period_values.size == period
            mb = CalculationHelpers.average(period_values)
            sd = CalculationHelpers.standard_deviation(period_values)
            ub = mb + (standard_deviations * sd)
            lb = mb - (standard_deviations * sd)
            
            output << {
              upper: ub,
              middle: mb,
              lower: lb
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
