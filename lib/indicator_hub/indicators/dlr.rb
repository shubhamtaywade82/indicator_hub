# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Daily Log Return (DLR)
    class DLR
      def self.calculate(data)
        output = []
        prev_price = nil

        data.each do |v|
          if prev_price.nil?
            output << nil
          else
            output << Math.log(v.to_f / prev_price.to_f)
          end
          prev_price = v
        end
        output
      end
    end
  end
end
