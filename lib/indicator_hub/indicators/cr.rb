# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Cumulative Return (CR)
    class CR
      def self.calculate(data)
        return [] if data.empty?
        
        start_price = data.first.to_f
        return Array.new(data.size, 0.0) if start_price.zero?

        data.map do |v|
          (v.to_f - start_price) / start_price
        end
      end
    end
  end
end
