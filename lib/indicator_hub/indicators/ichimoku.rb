# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Ichimoku Cloud.
    # The Ichimoku Cloud is a collection of technical indicators that show
    # support and resistance levels, as well as momentum and trend direction.
    class Ichimoku
      # Calculates the Ichimoku Cloud components.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param low_period [Integer] Tenkan-sen period (default: 9).
      # @param medium_period [Integer] Kijun-sen period (default: 26).
      # @param high_period [Integer] Senkou Span B period (default: 52).
      # @return [Array<Hash, nil>] The calculated Ichimoku components.
      def self.calculate(data, low_period: 9, medium_period: 26, high_period: 52)
        # Expects array of hashes with :high, :low, :close
        output = []

        data.each_with_index do |_, index|
          if index < high_period + medium_period - 2
            output << nil
            next
          end

          tenkan_sen = calculate_midpoint(index, low_period, data)
          kijun_sen = calculate_midpoint(index, medium_period, data)
          senkou_span_a = calculate_senkou_span_a(index, low_period, medium_period, data)
          senkou_span_b = calculate_senkou_span_b(index, medium_period, high_period, data)
          chikou_span = calculate_chikou_span(index, medium_period, data)

          output << {
            tenkan_sen: tenkan_sen,
            kijun_sen: kijun_sen,
            senkou_span_a: senkou_span_a,
            senkou_span_b: senkou_span_b,
            chikou_span: chikou_span
          }
        end
        output
      end

      def self.calculate_midpoint(index, period, data)
        start_idx = [0, index - period + 1].max
        period_data = data[start_idx..index]
        highs = period_data.map { |d| d[:high] }
        lows = period_data.map { |d| d[:low] }
        (highs.max + lows.min) / 2.0
      end

      def self.calculate_senkou_span_a(index, low_period, medium_period, data)
        mp_ago_index = index - (medium_period - 1)
        return nil if mp_ago_index.negative?

        t_sen = calculate_midpoint(mp_ago_index, low_period, data)
        k_sen = calculate_midpoint(mp_ago_index, medium_period, data)
        (t_sen + k_sen) / 2.0
      end

      def self.calculate_senkou_span_b(index, medium_period, high_period, data)
        mp_ago_index = index - (medium_period - 1)
        return nil if mp_ago_index.negative?

        calculate_midpoint(mp_ago_index, high_period, data)
      end

      def self.calculate_chikou_span(index, medium_period, data)
        mp_ago_index = index - (medium_period - 1)
        return nil if mp_ago_index.negative?

        data[mp_ago_index][:close]
      end
    end
  end
end
