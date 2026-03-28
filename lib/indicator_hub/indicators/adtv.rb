# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Average Daily Trading Volume (ADTV).
    # ADTV is the average number of shares traded within a day in a given stock.
    class ADTV
      # Calculates the Average Daily Trading Volume.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The period for calculating the average (default: 20).
      # @return [Array<Float, nil>] The calculated ADTV values.
      def self.calculate(data, period: 20)
        output = []
        volumes = data.map { |v| v[:volume] }

        (period - 1).upto(volumes.size - 1) do |i|
          window = volumes[(i - period + 1)..i]
          output << CalculationHelpers.average(window)
        end

        Array.new(data.size - output.size, nil) + output
      end
    end
  end
end
