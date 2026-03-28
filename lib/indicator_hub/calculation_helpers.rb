# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

module IndicatorHub
  # Calculation helpers for technical analysis math.
  # Provides common mathematical functions used in various indicator calculations.
  module CalculationHelpers
    extend T::Sig

    # Sums up the given numerical data.
    # @param data [Array<Numeric>] The input data array.
    # @return [Float] The sum of all elements.
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.sum(data)
      data.inject(0.0, :+)
    end

    # Calculates the arithmetic mean (average) of the data.
    # @param data [Array<Numeric>] The input data array.
    # @return [Float] The average of the elements.
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.average(data)
      return 0.0 if data.empty?
      sum(data) / data.size.to_f
    end

    # @see average
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.mean(data)
      average(data)
    end

    # Calculates the sample variance of the data.
    # @param data [Array<Numeric>] The input data array.
    # @return [Float] The sample variance.
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.sample_variance(data)
      return 0.0 if data.size <= 1
      m = mean(data)
      sum_sq_diff = data.inject(0.0) { |accum, i| accum + (i - m)**2 }
      sum_sq_diff / (data.size - 1).to_f
    end

    # Calculates the standard deviation of the data.
    # @param data [Array<Numeric>] The input data array.
    # @return [Float] The standard deviation.
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.standard_deviation(data)
      Math.sqrt(sample_variance(data))
    end

    # Calculates the mean absolute deviation (MAD) of the data.
    # @param data [Array<Numeric>] The input data array.
    # @param mean [Float] The mean of the data.
    # @return [Float] The MAD of the elements.
    sig { params(data: T::Array[Numeric], mean: Float).returns(Float) }
    def self.mean_absolute_deviation(data, mean)
      return 0.0 if data.empty?
      sum_abs_diff = data.inject(0.0) { |accum, i| accum + (i - mean).abs }
      sum_abs_diff / data.size.to_f
    end

    # Wilder's Smoothing for RSI.
    # @param prev_avg [Numeric] The previous average.
    # @param current [Numeric] The current value.
    # @param period [Integer] The smoothing period.
    # @return [Float] The smoothed value.
    sig { params(prev_avg: Numeric, current: Numeric, period: Integer).returns(Float) }
    def self.wilder_smoothing(prev_avg, current, period)
      ((prev_avg.to_f * (period - 1)) + current.to_f) / period.to_f
    end

    # Calculates the True Range (TR).
    # @param current_high [Numeric] The high price of the current period.
    # @param current_low [Numeric] The low price of the current period.
    # @param previous_close [Numeric] The close price of the previous period.
    # @return [Float] The calculated True Range.
    sig { params(current_high: Numeric, current_low: Numeric, previous_close: Numeric).returns(Float) }
    def self.true_range(current_high, current_low, previous_close)
      [
        (current_high.to_f - current_low.to_f),
        (current_high.to_f - previous_close.to_f).abs,
        (current_low.to_f - previous_close.to_f).abs
      ].max.to_f
    end

    # Calculates the Typical Price.
    # @param high [Numeric] The high price.
    # @param low [Numeric] The low price.
    # @param close [Numeric] The close price.
    # @return [Float] (high + low + close) / 3.0
    sig { params(high: Numeric, low: Numeric, close: Numeric).returns(Float) }
    def self.typical_price(high, low, close)
      (high.to_f + low.to_f + close.to_f) / 3.0
    end

    # Calculates the Exponential Moving Average (EMA).
    # @param current_value [Numeric] The current data point.
    # @param data [Array<Numeric>] Historical data (used for seed calculation).
    # @param period [Integer] The EMA period.
    # @param prev_value [Numeric, nil] The previous EMA value.
    # @return [Float] The calculated EMA value.
    sig { params(current_value: Numeric, data: T::Array[Numeric], period: Integer, prev_value: T.nilable(Numeric)).returns(Float) }
    def self.ema(current_value, data, period, prev_value)
      if prev_value.nil?
        average(data)
      else
        (current_value.to_f - prev_value.to_f) * (2.0 / (period + 1.0)) + prev_value.to_f
      end
    end

    # Calculates the Weighted Moving Average (WMA) of the data.
    # @param data [Array<Numeric>] The input data array.
    # @return [Float] The WMA of the data.
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.wma(data)
      return 0.0 if data.empty?
      divisor = (data.size * (data.size + 1) / 2.0)
      sum = 0.0
      data.each_with_index do |v, i|
        sum += v.to_f * (i + 1) / divisor
      end
      sum
    end

    # Calculates the maximum value in a sliding window.
    # @param data [Array<Numeric>] The input data array.
    # @param period [Integer] The window period.
    # @return [Array<Float, nil>]
    sig { params(data: T::Array[Numeric], period: Integer).returns(T::Array[T.nilable(Float)]) }
    def self.max(data, period)
      output = []
      window = []
      data.each do |v|
        window << v.to_f
        if window.size == period
          output << window.max
          window.shift
        else
          output << nil
        end
      end
      output
    end

    # Calculates the minimum value in a sliding window.
    # @param data [Array<Numeric>] The input data array.
    # @param period [Integer] The window period.
    # @return [Array<Float, nil>]
    sig { params(data: T::Array[Numeric], period: Integer).returns(T::Array[T.nilable(Float)]) }
    def self.min(data, period)
      output = []
      window = []
      data.each do |v|
        window << v.to_f
        if window.size == period
          output << window.min
          window.shift
        else
          output << nil
        end
      end
      output
    end

    # Simple Moving Average for numeric arrays.
    # @param data [Array<Numeric, nil>] The input data array.
    # @param period [Integer] The window period.
    # @return [Array<Float, nil>]
    sig { params(data: T::Array[T.nilable(Numeric)], period: Integer).returns(T::Array[T.nilable(Float)]) }
    def self.sma(data, period)
      output = []
      window = []
      data.each do |v|
        if v.nil?
          output << nil
          next
        end
        window << v.to_f
        if window.size == period
          output << average(window)
          window.shift
        else
          output << nil
        end
      end
      output
    end
  end

  # Helper module for validating input data and formats.
  module Validation
    extend T::Sig
    # Error raised when data validation fails.
    class Error < StandardError; end

    # Validates that the provided options are within the allowed set.
    # @param options [Hash] The options to validate.
    # @param valid_options [Array<Symbol>] The list of allowed option keys.
    # @raise [Validation::Error] if an invalid option is found.
    sig { params(options: T::Hash[Symbol, T.untyped], valid_options: T::Array[Symbol]).void }
    def self.validate_options(options, valid_options)
      raise Error, "Options must be a hash." unless options.is_a?(Hash)
      
      invalid_keys = options.keys - valid_options
      unless invalid_keys.empty?
        raise Error, "Invalid options: #{invalid_keys.join(', ')}. Valid options are: #{valid_options.join(', ')}"
      end
    end

    # Validates that all elements in the data array are numeric.
    # @param data [Array] The data to validate.
    # @raise [Validation::Error] if any element is not numeric.
    sig { params(data: T::Array[T.untyped]).void }
    def self.validate_numeric_data(data)
      unless data.all? { |v| v.is_a?(Numeric) }
        raise Error, "Invalid Data. Input must be numeric."
      end
    end

    # Validates that the data has at least a certain length.
    # @param data [Array] The data to validate.
    # @param size [Integer] The minimum required size.
    # @raise [Validation::Error] if data is too short.
    sig { params(data: T::Array[T.untyped], size: Integer).void }
    def self.validate_length(data, size)
      if data.size < size
        raise Error, "Not enough data for that period. Expected at least #{size}, got #{data.size}."
      end
    end
  end
end
