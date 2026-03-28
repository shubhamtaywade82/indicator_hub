# frozen_string_literal: true

require_relative 'base_indicator'

module IndicatorHub
  module Indicators
    # Simple Moving Average (SMA).
    # SMA is a basic technical indicator that calculates the average price over a 
    # specified number of periods.
    class SMA < BaseIndicator
      # Calculates the Simple Moving Average.
      # @return [Array<Float, nil>] The calculated SMA values.
      def calculate
        period = options[:period] || 20
        CalculationHelpers.sma(numeric_data, period)
      end

      # Defines the list of valid option keys for this indicator.
      # @return [Array<Symbol>]
      def self.valid_options
        [:field, :period]
      end

      # Defines the minimum number of data points required for calculation.
      # @param options [Hash] The current indicator options.
      # @return [Integer]
      def self.min_data_size(options)
        options[:period] || 20
      end
    end
  end
end
