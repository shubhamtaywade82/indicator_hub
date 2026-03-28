# frozen_string_literal: true

require_relative "../calculation_helpers"
require_relative "ema"

module IndicatorHub
  module Indicators
    # Triple Exponential Average (TRIX).
    # TRIX is a momentum oscillator that shows the percent rate-of-change of a
    # triple exponentially smoothed moving average.
    class TRIX
      # Calculates the Triple Exponential Average.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The TRIX period (default: 15).
      # @return [Array<Float, nil>] The calculated TRIX values.
      def self.calculate(data, period: 15)
        period = period.to_i

        # EMA1 = EMA(price, n)
        ema1 = EMA.calculate(data, period: period)

        # Filter out nils for next EMA
        ema1_filtered = ema1.compact
        ema2 = EMA.calculate(ema1_filtered, period: period)

        # EMA2 filtered
        ema2_filtered = ema2.compact
        ema3 = EMA.calculate(ema2_filtered, period: period)

        # Now we need to align them back to the original data size
        # ema1 has (period - 1) nils at the start
        # ema2 has (period - 1) additional nils
        # ema3 has (period - 1) additional nils
        # Total nils at start of ema3 (aligned to data): 3 * (period - 1)

        full_ema3 = Array.new(data.size, nil)
        ema3_compact = ema3.compact

        offset = 3 * (period - 1)
        ema3_compact.each_with_index do |v, i|
          full_ema3[offset + i] = v if offset + i < data.size
        end

        output = Array.new(data.size, nil)
        (1...data.size).each do |i|
          output[i] = (full_ema3[i] - full_ema3[i - 1]) / full_ema3[i - 1].to_f if full_ema3[i] && full_ema3[i - 1]
        end

        output
      end
    end
  end
end
