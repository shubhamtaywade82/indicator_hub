# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Pivot Points.
    # Pivot Points are used to identify potential support and resistance levels.
    class PivotPoints
      include CalculationHelpers

      # Calculates the Pivot Points.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @return [Array<Hash>] The calculated Pivot Points values { p: Float, s1: Float, s2: Float, s3: Float, r1: Float, r2: Float, r3: Float }.
      def self.calculate(data)
        return [] unless data.is_a?(Array) && !data.empty?

        data.map do |bar|
          high = bar[:high]
          low = bar[:low]
          close = bar[:close]

          p = ((high + low + close) / 3.0).round(4)

          s1 = ((2 * p) - high).round(4)
          s2 = (p - (high - low)).round(4)
          s3 = (low - (2 * (high - p))).round(4)

          r1 = ((2 * p) - low).round(4)
          r2 = (p + (high - low)).round(4)
          r3 = (high + (2 * (p - low))).round(4)

          {
            p: p,
            s1: s1,
            s2: s2,
            s3: s3,
            r1: r1,
            r2: r2,
            r3: r3
          }
        end
      end
    end
  end
end
