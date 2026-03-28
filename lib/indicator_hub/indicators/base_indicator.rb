# frozen_string_literal: true

require_relative '../validation'
require_relative '../series'
require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Abstract base class for all technical analysis indicators.
    # Implements common initialization, data normalization, and validation logic.
    class BaseIndicator
      # @return [Series] The normalized series data.
      attr_reader :data
      # @return [Hash] The configuration options for the indicator.
      attr_reader :options

      # Initializes a new indicator instance.
      # @param data [Array, Series] The input data series.
      # @param options [Hash] Configuration options (e.g., period, field).
      def initialize(data, options = {})
        @data = data.is_a?(Series) ? data : Series.new(data)
        @options = options
        validate!
      end

      # Abstract method to be implemented by concrete indicator classes.
      # @raise [NotImplementedError] if not overridden.
      def calculate
        raise NotImplementedError, "#{self.class} must implement #calculate"
      end

      # Returns the data normalized as a simple numeric array.
      # @return [Array<Float>]
      def numeric_data
        data.to_a(field: options[:field] || :close)
      end

      # Returns the data normalized as an OHLCV hash array.
      # @return [Array<Hash>]
      def ohlc_data
        data.to_ohlc
      end

      private

      # Validates options, numeric integrity, and minimum data length.
      # @raise [Validation::Error] if validation fails.
      def validate!
        Validation.validate_options(options, self.class.valid_options)
        Validation.validate_numeric_data(numeric_data)
        Validation.validate_length(numeric_data, self.class.min_data_size(options))
      end

      # Defines the list of valid option keys for this indicator.
      # @return [Array<Symbol>]
      def self.valid_options
        [:field]
      end

      # Defines the minimum number of data points required for calculation.
      # @param options [Hash] The current indicator options.
      # @return [Integer]
      def self.min_data_size(_options)
        1
      end
    end
  end
end
