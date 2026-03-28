# frozen_string_literal: true

require_relative "ema"

module IndicatorHub
  module Indicators
    # Envelopes EMA
    class EnvelopesEMA
      def self.calculate(data, period: 20, percentage: 5)
        # Ensure we're working with numbers, if not, something upstream went wrong,
        # but EMA.calculate will catch it if it expects only numbers.
        ema_values = EMA.calculate(data, period: period)
        
        output = []
        ema_values.each do |ema|
          if ema.nil?
            output << { upper: nil, middle: nil, lower: nil }
          else
            upper = ema * (1 + percentage / 100.0)
            lower = ema * (1 - percentage / 100.0)
            output << { upper: upper, middle: ema, lower: lower }
          end
        end

        output
      end
    end
  end
end
