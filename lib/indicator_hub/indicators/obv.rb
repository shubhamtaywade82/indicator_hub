# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # On-Balance Volume (OBV).
    # OBV is a technical momentum indicator that uses volume flow to predict 
    # changes in stock price.
    class OBV
      # Calculates the On-Balance Volume.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @return [Array<Float>] The calculated OBV values.
      def self.calculate(data)
        current_obv = 0.0
        output = []
        return [] if data.empty?

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
          end

          output << current_obv
          prior_close = close
        end

        output
      end
    end
  end
end
