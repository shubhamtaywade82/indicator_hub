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
    # @return [Float] The MAD of the elements.
    sig { params(data: T::Array[Numeric]).returns(Float) }
    def self.mean_absolute_deviation(data)
      return 0.0 if data.empty?
      m = mean(data)
      sum_abs_diff = data.inject(0.0) { |accum, i| accum + (i - m).abs }
      sum_abs_diff / data.size.to_f
    end

    # Wilder's Smoothing for RSI.
    # @param prev_avg [Float] The previous average.
    # @param current [Float] The current value.
    # @param period [Integer] The smoothing period.
    # @return [Float] The smoothed value.
    sig { params(prev_avg: Float, current: Float, period: Integer).returns(Float) }
    def self.wilder_smoothing(prev_avg, current, period)
      ((prev_avg * (period - 1)) + current) / period.to_f
    end

    # Calculates the True Range (TR).
    # @param current_high [Float] The high price of the current period.
    # @param current_low [Float] The low price of the current period.
    # @param previous_close [Float] The close price of the previous period.
    # @return [Float] The calculated True Range.
    sig { params(current_high: Float, current_low: Float, previous_close: Float).returns(Float) }
    def self.true_range(current_high, current_low, previous_close)
      [
        (current_high - current_low),
        (current_high - previous_close).abs,
        (current_low - previous_close).abs
      ].max
    end

    # Calculates the Typical Price.
    # @param high [Float] The high price.
    # @param low [Float] The low price.
    # @param close [Float] The close price.
    # @return [Float] (high + low + close) / 3.0
    sig { params(high: Float, low: Float, close: Float).returns(Float) }
    def self.typical_price(high, low, close)
      (high + low + close) / 3.0
    end

    # Calculates the Exponential Moving Average (EMA).
    # @param current_value [Float] The current data point.
    # @param data [Array<Float>] Historical data (used for seed calculation).
    # @param period [Integer] The EMA period.
    # @param prev_value [Float, nil] The previous EMA value.
    # @return [Float] The calculated EMA value.
    sig { params(current_value: Float, data: T::Array[Float], period: Integer, prev_value: T.nilable(Float)).returns(Float) }
    def self.ema(current_value, data, period, prev_value)
      if prev_value.nil?
        average(data)
      else
        (current_value - prev_value) * (2.0 / (period + 1.0)) + prev_value
      end
    end

    # Calculates the Weighted Moving Average (WMA) of the data.
    # @param data [Array<Float>] The input data array.
    # @return [Float] The WMA of the data.
    sig { params(data: T::Array[Float]).returns(Float) }
    def self.wma(data)
      return 0.0 if data.empty?
      divisor = (data.size * (data.size + 1) / 2.0)
      sum = 0.0
      data.each_with_index do |v, i|
        sum += v * (i + 1) / divisor
      end
      sum
    end
  end

  # Helper module for validating input data and formats.
  module Validation
    extend T::Sig
    # Error raised when data validation fails.
    class Error < StandardError; end

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
