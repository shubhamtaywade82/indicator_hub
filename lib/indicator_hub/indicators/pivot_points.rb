module IndicatorHub
  module Indicators
    class PivotPoints
      include CalculationHelpers

      # Pivot Points
      # @param data [Array<Hash>] OHLC data
      # @return [Array<Hash>] An array of hashes containing the pivot point, supports, and resistances
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
