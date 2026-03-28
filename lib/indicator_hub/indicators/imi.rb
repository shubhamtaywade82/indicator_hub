# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Intraday Momentum Index (IMI).
    # IMI is a technical indicator that combines candlestick analysis with
    # the Relative Strength Index (RSI).
    class IMI
      # Calculates the Intraday Momentum Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The IMI period (default: 14).
      # @return [Array<Float, nil>] The calculated IMI values.
      def self.calculate(data, period: 14)
        output = []

        data.each_with_index do |_val, i|
          if i < period - 1
            output << nil
            next
          end

          slice = data[(i - period + 1)..i]
          gsum = 0.0
          lsum = 0.0

          slice.each do |d|
            if d[:close] > d[:open]
              gsum += (d[:close] - d[:open])
            elsif d[:close] < d[:open]
              lsum += (d[:open] - d[:close])
            end
          end

          if (gsum + lsum).zero?
            output << 0.0
          else
            imi = 100.0 * gsum / (gsum + lsum)
            output << imi
          end
        end

        output
      end
    end
  end
end
