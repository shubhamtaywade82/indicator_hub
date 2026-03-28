# frozen_string_literal: true

require_relative "ema"

module IndicatorHub
  module Indicators
    # Force Index (FI).
    # FI is an oscillator that uses price and volume to assess the power behind
    # a move and identify potential turning points.
    class FI
      # Calculates the Force Index.
      # @param data [Array<Numeric, Hash>] Array of prices or OHLCV hashes.
      # @param period [Integer] The FI period (default: 13).
      # @return [Array<Float, nil>] The calculated FI values.
      def self.calculate(data, period: 13)
        return [] if data.empty?

        raw_fi = []
        prev_close = nil

        data.each do |v|
          if v.is_a?(Hash)
            close = (v[:close] || v["close"]).to_f
            volume = (v[:volume] || v["volume"]).to_f
          else
            close = v.to_f
            volume = 1.0
          end

          if prev_close.nil?
            # First data point has no previous close to calculate force index
          else
            raw_fi << ((close - prev_close) * volume)
          end
          prev_close = close
        end

        return Array.new(data.size, nil) if raw_fi.empty?

        ema_fi = EMA.calculate(raw_fi, period: period)
        [nil] + ema_fi
      end
    end
  end
end
