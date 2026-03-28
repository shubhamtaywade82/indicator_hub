# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Relative Strength Index (RSI)
    class RSI
      def self.calculate(data, period: 14)
        return [] if data.size < period

        output = []
        gains = []
        losses = []
        prev_price = data.first
        
        avg_gain = nil
        avg_loss = nil

        data.each_with_index do |price, index|
          if index == 0
            output << nil
            next
          end

          change = price - prev_price
          gains << (change > 0 ? change : 0.0)
          losses << (change < 0 ? change.abs : 0.0)

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

            rs = avg_loss == 0 ? 0 : (avg_gain / avg_loss)
            rsi = 100.0 - (100.0 / (1.0 + rs))
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
