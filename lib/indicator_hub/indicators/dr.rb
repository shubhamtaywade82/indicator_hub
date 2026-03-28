# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Daily Return (DR)
    class DR
      def self.calculate(data)
        output = []
        prev_price = nil

        data.each do |v|
          if prev_price.nil?
            output << nil
          else
            output << (v.to_f / prev_price.to_f) - 1.0
          end
          prev_price = v
        end
        output
      end
    end
  end
end
