# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Volume-Price Trend (VPT).
    # VPT is a technical indicator that combines price and volume to confirm 
    # the strength of a price trend or signal its reversal.
    class VPT
      # Calculates the Volume-Price Trend.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @return [Array<Float, nil>] The calculated VPT values.
      def self.calculate(data)
        output = []
        prev_vpt = 0.0
        
        data.each_with_index do |val, i|
          if i == 0
            output << nil
            next
          end

          prev = data[i - 1]
          # VPT = prev_vpt + (volume * (close - prev_close) / prev_close)
          vpt = prev_vpt + (val[:volume] * (val[:close] - prev[:close]) / prev[:close].to_f)
          output << vpt
          prev_vpt = vpt
        end

        output
      end
    end
  end
end
