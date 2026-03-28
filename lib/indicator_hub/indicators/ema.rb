# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Exponential Moving Average (EMA).
    # EMA is a type of moving average that places a greater weight and significance
    # on the most recent data points.
    class EMA
      # Calculates the Exponential Moving Average.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The EMA period (default: 20).
      # @return [Array<Float, nil>] The calculated EMA values.
      def self.calculate(data, period: 20)
        period = period.to_i
        Validation.validate_numeric_data(data)
        return Array.new(data.size, nil) if data.size < period

        period_values = []
        previous_ema = nil
        output = []

        data.each do |v|
          period_values << v

          if period_values.size == period
            ema = CalculationHelpers.ema(v, period_values, period, previous_ema)
            previous_ema = ema
            output << ema
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
