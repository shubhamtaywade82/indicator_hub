# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Mass Index (MI).
    # MI is a technical indicator used to predict trend reversals by analyzing
    # the narrowing and widening of the trading range.
    class MI
      # Calculates the Mass Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param ema_period [Integer] The EMA period (default: 9).
      # @param period [Integer] The summation period (default: 25).
      # @return [Array<Float, nil>] The calculated MI values.
      def self.calculate(data, ema_period: 9, period: 25)
        high_low_diffs = data.map do |v|
          if v.is_a?(Hash)
            ((v[:high] || v["high"]).to_f - (v[:low] || v["low"]).to_f)
          else
            0.0
          end
        end

        # First EMA
        single_ema_values = calculate_ema(high_low_diffs, ema_period)

        # Second EMA (EMA of the first EMA)
        valid_single_emas = single_ema_values.compact
        if valid_single_emas.size >= ema_period
          double_ema_valid_values = calculate_ema(valid_single_emas, ema_period)
          # Re-align double_ema_values with single_ema_values
          lead_nils = single_ema_values.size - valid_single_emas.size
          double_ema_values = Array.new(lead_nils, nil) + double_ema_valid_values
        else
          double_ema_values = Array.new(single_ema_values.size, nil)
        end

        ratios = []
        single_ema_values.each_with_index do |s_ema, i|
          d_ema = double_ema_values[i]
          ratios << (s_ema / d_ema if s_ema && d_ema && d_ema != 0)
        end

        output = []
        current_ratios = []
        ratios.each do |ratio|
          if ratio.nil?
            output << nil
          else
            current_ratios << ratio
            current_ratios.shift if current_ratios.size > period

            output << (current_ratios.sum if current_ratios.size == period)
          end
        end

        output
      end

      def self.calculate_ema(data, period)
        output = []
        period_values = []
        previous_ema = nil

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
