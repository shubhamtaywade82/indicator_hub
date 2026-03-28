# frozen_string_literal: true

module IndicatorHub
  # Robust validation for technical analysis data and options.
  module Validation
    # Error class for validation failures.
    class Error < StandardError; end

    # Validates that the provided options are within the allowed set.
    # @param options [Hash] The options to validate.
    # @param valid_options [Array<Symbol>] The list of allowed option keys.
    # @raise [Validation::Error] if an invalid option is found.
    def self.validate_options(options, valid_options)
      raise Error, "Options must be a hash." unless options.is_a?(Hash)
      
      invalid_keys = options.keys - valid_options
      unless invalid_keys.empty?
        raise Error, "Invalid options: #{invalid_keys.join(', ')}. Valid options are: #{valid_options.join(', ')}"
      end
    end

    # Validates that all data points in the numeric array are numbers.
    # @param data [Array<Numeric>] The data to validate.
    # @raise [Validation::Error] if non-numeric data is found.
    def self.validate_numeric_data(data)
      unless data.all? { |v| v.is_a?(Numeric) }
        raise Error, "Invalid Data. Input must be numeric."
      end
    end

    # Validates that the data set meets the minimum required length.
    # @param data [Array] The data to validate.
    # @param required_size [Integer] The minimum length required.
    # @raise [Validation::Error] if the data is too short.
    def self.validate_length(data, required_size)
      if data.size < required_size
        raise Error, "Not enough data. Expected at least #{required_size}, got #{data.size}."
      end
    end
  end
end
