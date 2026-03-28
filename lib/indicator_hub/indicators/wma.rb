# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Weighted Moving Average (WMA).
    # WMA is a moving average that assigns more weight to recent data points 
    # and less weight to past data points.
    class WMA
      # Calculates the Weighted Moving Average.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The WMA period (default: 20).
      # @return [Array<Float, nil>] The calculated WMA values.
      def self.calculate(data, period: 20)
        period = period.to_i
        Validation.validate_numeric_data(data)
        return Array.new(data.size, nil) if data.size < period

        output = []
        period_values = []

        data.each do |v|
          period_values << v
          if period_values.size == period
            output << CalculationHelpers.wma(period_values)
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
