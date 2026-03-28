# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Volume Weighted Average Price (VWAP)
    class VWAP
      def self.calculate(data)
        # Expects array of hashes with :high, :low, :close, :volume
        output = []
        cumm_volume = 0.0
        cumm_volume_x_typical_price = 0.0

        data.each do |v|
          tp = CalculationHelpers.typical_price(v[:high], v[:low], v[:close])
          vol = v[:volume].to_f
          cumm_volume_x_typical_price += vol * tp
          cumm_volume += vol
          
          vwap = cumm_volume > 0 ? (cumm_volume_x_typical_price / cumm_volume) : 0.0
          output << vwap
        end
        output
      end
    end
  end
end
