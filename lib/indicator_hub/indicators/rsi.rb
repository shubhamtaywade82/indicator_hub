# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Relative Strength Index (RSI).
    # RSI is a momentum oscillator that measures the speed and change of price movements.
    # It oscillates between 0 and 100. Traditionally, RSI is considered overbought when
    # above 70 and oversold when below 30.
    class RSI
      # Calculates the Relative Strength Index.
      # @param data [Array<Numeric>] The input data points.
      # @param period [Integer] The RSI period (default: 14).
      # @return [Array<Float, nil>] The calculated RSI values.
      def self.calculate(data, period: 14)
        return [] if data.size < period

        output = []
        gains = []
        losses = []
        prev_price = data.first

        avg_gain = nil
        avg_loss = nil

        data.each_with_index do |price, index|
          if index.zero?
            output << nil
            next
          end

          change = price - prev_price
          gains << (change.positive? ? change : 0.0)
          losses << (change.negative? ? change.abs : 0.0)

          if gains.size == period
            if avg_gain.nil?
              # Initial average gain/loss is SMA
              avg_gain = CalculationHelpers.average(gains)
              avg_loss = CalculationHelpers.average(losses)
            else
              # Subsequent use Wilder's Smoothing
              avg_gain = CalculationHelpers.wilder_smoothing(avg_gain, gains.last, period)
              avg_loss = CalculationHelpers.wilder_smoothing(avg_loss, losses.last, period)
            end

            if avg_loss.zero?
              rsi = avg_gain.zero? ? 0.0 : 100.0
            else
              rs = avg_gain / avg_loss
              rsi = 100.0 - (100.0 / (1.0 + rs))
            end
            output << rsi
            gains.shift
            losses.shift
          else
            output << nil
          end

          prev_price = price
        end
        output
      end
    end
  end
end
