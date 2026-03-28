# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Money Flow Index (MFI).
    # MFI is a technical oscillator that uses price and volume for identifying 
    # overbought or oversold signals in an asset.
    class MFI
      # Calculates the Money Flow Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The MFI period (default: 14).
      # @return [Array<Float, nil>] The calculated MFI values.
      def self.calculate(data, period: 14)
        return Array.new(data.size, nil) if data.size <= period

        output = []
        typical_prices = []
        raw_money_flows = []
        
        data.each_with_index do |v, i|
          typical_price = (v[:high] + v[:low] + v[:close]) / 3.0
          typical_prices << typical_price
          
          if i == 0
            raw_money_flows << 0.0
            output << nil
            next
          end

          money_flow = typical_price * v[:volume]
          if typical_price > typical_prices[i - 1]
            raw_money_flows << money_flow
          elsif typical_price < typical_prices[i - 1]
            raw_money_flows << -money_flow
          else
            raw_money_flows << 0.0
          end

          if raw_money_flows.size > period
            current_flows = raw_money_flows.last(period)
            pos_flow = current_flows.select { |f| f.positive? }.sum
            neg_flow = current_flows.select { |f| f.negative? }.sum.abs

            if neg_flow == 0
              mfi = 100.0
            else
              mfr = pos_flow / neg_flow
              mfi = 100.0 - (100.0 / (1.0 + mfr))
            end
            output << mfi
          else
            output << nil
          end
        end

        output
      end
    end
  end
end
