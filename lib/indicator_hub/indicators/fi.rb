# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Force Index (FI)
    class FI
      def self.calculate(data)
        output = []
        prev_close = nil

        data.each do |v|
          if prev_close.nil?
            output << nil
          else
            output << (v[:close] - prev_close) * v[:volume]
          end
          prev_close = v[:close]
        end
        output
      end
    end
  end
end
