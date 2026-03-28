# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Accumulation/Distribution Index (ADI).
    # ADI uses volume and price to assess whether a stock is being accumulated or distributed.
    class ADI
      # Calculates the Accumulation/Distribution Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @return [Array<Float, nil>] The calculated ADI values.
      def self.calculate(data)
        ad = 0.0
        output = []

        data.each do |values|
          high = values[:high]
          low = values[:low]
          close = values[:close]
          volume = values[:volume]

          clv = if high == low
                  0.0
                else
                  ((close - low) - (high - close)) / (high - low).to_f
                end

          ad += (clv * volume)
          output << ad
        end

        output
      end
    end
  end
end
