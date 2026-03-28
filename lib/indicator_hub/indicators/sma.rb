# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Simple Moving Average (SMA).
    # SMA is a basic technical indicator that calculates the average price over a 
    # specified number of periods.
    class SMA
      # Calculates the Simple Moving Average.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The SMA period (default: 20).
      # @return [Array<Float, nil>] The calculated SMA values.
      def self.calculate(data, period: 20)
        period = period.to_i
        Validation.validate_numeric_data(data)
        return Array.new(data.size, nil) if data.size < period

        output = []
        period_values = []

        data.each do |v|
          period_values << v
          if period_values.size == period
            output << CalculationHelpers.average(period_values)
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
