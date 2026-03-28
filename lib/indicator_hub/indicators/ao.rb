# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Awesome Oscillator (AO).
    # AO is used to measure market momentum. It calculates the difference
    # between a 34-period and 5-period Simple Moving Average of the bar's midpoints.
    class AO
      # Calculates the Awesome Oscillator.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param short_period [Integer] The short SMA period (default: 5).
      # @param long_period [Integer] The long SMA period (default: 34).
      # @return [Array<Float, nil>] The calculated AO values.
      def self.calculate(data, short_period: 5, long_period: 34)
        midpoints = data.map { |v| (v[:high] + v[:low]) / 2.0 }
        output = []

        midpoints.each_with_index do |_, i|
          if i < long_period - 1
            output << nil
            next
          end

          short_window = midpoints[(i - short_period + 1)..i]
          long_window = midpoints[(i - long_period + 1)..i]

          short_sma = CalculationHelpers.average(short_window)
          long_sma = CalculationHelpers.average(long_window)

          output << (short_sma - long_sma)
        end

        output
      end
    end
  end
end
