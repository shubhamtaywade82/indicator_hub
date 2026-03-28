# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Williams %R (WR).
    # WR is a momentum indicator that measures overbought and oversold levels.
    class WR
      # Calculates the Williams %R.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The WR period (default: 14).
      # @return [Array<Float, nil>] The calculated Williams %R values.
      def self.calculate(data, period: 14)
        output = []
        
        data.each_with_index do |val, i|
          if i < period - 1
            output << nil
            next
          end

          slice = data[(i - period + 1)..i]
          highest_high = slice.map { |d| d[:high] }.max
          lowest_low = slice.map { |d| d[:low] }.min

          # WR = (highest_high - close) / (highest_high - lowest_low) * -100
          wr = (highest_high - val[:close]) / (highest_high - lowest_low).to_f * -100
          output << wr
        end

        output
      end
    end
  end
end
