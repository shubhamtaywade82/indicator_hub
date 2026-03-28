# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Daily Return (DR).
    # DR is the percentage change in price from one day to the next.
    class DR
      # Calculates the Daily Return.
      # @param data [Array<Numeric>] The input data points.
      # @return [Array<Float, nil>] The calculated DR values.
      def self.calculate(data)
        output = []
        prev_price = nil

        data.each do |v|
          output << if prev_price.nil?
                      nil
                    else
                      (v.to_f / prev_price) - 1.0
                    end
          prev_price = v
        end
        output
      end
    end
  end
end
