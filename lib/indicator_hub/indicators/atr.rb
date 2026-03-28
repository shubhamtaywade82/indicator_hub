# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Average True Range (ATR).
    # ATR is a volatility indicator that shows how much an asset moves, on average, during a given time frame.
    class ATR
      # Calculates the Average True Range.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The period for ATR (default: 14).
      # @return [Array<Float, nil>] The calculated ATR values.
      def self.calculate(data, period: 14)
        output = []
        tr_values = []
        prev_close = nil
        current_atr = nil

        data.each_with_index do |v, i|
          tr = if i.zero?
                 v[:high] - v[:low]
               else
                 CalculationHelpers.true_range(v[:high], v[:low], prev_close)
               end

          tr_values << tr
          prev_close = v[:close]

          if tr_values.size < period
            output << nil
          elsif tr_values.size == period
            current_atr = CalculationHelpers.average(tr_values)
            output << current_atr
          else
            current_atr = CalculationHelpers.wilder_smoothing(current_atr, tr, period)
            output << current_atr
          end
        end

        output
      end
    end
  end
end
