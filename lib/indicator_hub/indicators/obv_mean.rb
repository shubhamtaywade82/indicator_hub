# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # On-Balance Volume Mean (OBV Mean).
    # OBV Mean is the average of the On-Balance Volume over a specified period.
    class OBVMean
      # Calculates the On-Balance Volume Mean.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The OBV Mean period (default: 10).
      # @return [Array<Float, nil>] The calculated OBV Mean values.
      def self.calculate(data, period: 10)
        current_obv = 0.0
        obvs = []
        output = []
        prior_close = nil

        data.each do |v|
          volume = v[:volume]
          close = v[:close]

          unless prior_close.nil?
            if close > prior_close
              current_obv += volume
            elsif close < prior_close
              current_obv -= volume
            end
            obvs << current_obv
          end

          prior_close = close

          if obvs.size >= period
            output << IndicatorHub::CalculationHelpers.average(obvs.last(period))
          else
            output << nil
          end
        end

        output
      end
    end
  end
end
