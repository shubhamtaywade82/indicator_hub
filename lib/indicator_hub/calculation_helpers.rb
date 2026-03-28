# frozen_string_literal: true

module IndicatorHub
  # Calculation helpers for technical analysis math
  module CalculationHelpers
    def self.sum(data)
      data.inject(0.0, :+)
    end

    def self.average(data)
      return 0.0 if data.empty?
      sum(data) / data.size.to_f
    end

    def self.mean(data)
      average(data)
    end

    def self.sample_variance(data)
      return 0.0 if data.size <= 1
      m = mean(data)
      sum_sq_diff = data.inject(0.0) { |accum, i| accum + (i - m)**2 }
      sum_sq_diff / (data.size - 1).to_f
    end

    def self.standard_deviation(data)
      Math.sqrt(sample_variance(data))
    end

    def self.mean_absolute_deviation(data)
      return 0.0 if data.empty?
      m = mean(data)
      sum_abs_diff = data.inject(0.0) { |accum, i| accum + (i - m).abs }
      sum_abs_diff / data.size.to_f
    end

    # Wilder's Smoothing for RSI
    def self.wilder_smoothing(prev_avg, current, period)
      ((prev_avg * (period - 1)) + current) / period.to_f
    end

    def self.true_range(current_high, current_low, previous_close)
      [
        (current_high - current_low),
        (current_high - previous_close).abs,
        (current_low - previous_close).abs
      ].max
    end

    def self.typical_price(high, low, close)
      (high + low + close) / 3.0
    end

    def self.ema(current_value, data, period, prev_value)
      if prev_value.nil?
        average(data)
      else
        (current_value - prev_value) * (2.0 / (period + 1.0)) + prev_value
      end
    end

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

  module Validation
    class Error < StandardError; end

    def self.validate_numeric_data(data)
      unless data.all? { |v| v.is_a?(Numeric) }
        raise Error, "Invalid Data. Input must be numeric."
      end
    end

    def self.validate_length(data, size)
      if data.size < size
        raise Error, "Not enough data for that period. Expected at least #{size}, got #{data.size}."
      end
    end
  end
end
