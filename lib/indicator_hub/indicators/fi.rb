# frozen_string_literal: true

require_relative "ema"

module IndicatorHub
  module Indicators
    # Force Index (FI)
    class FI
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
            raw_fi << (close - prev_close) * volume
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
