# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Intraday Momentum Index (IMI)
    class IMI
      def self.calculate(data, period: 14)
        output = []
        
        data.each_with_index do |val, i|
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

          if (gsum + lsum) == 0
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
