# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # On-balance Volume (OBV)
    class OBV
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
