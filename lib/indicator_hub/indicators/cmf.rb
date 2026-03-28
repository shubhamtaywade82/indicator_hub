# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Chaikin Money Flow (CMF).
    # CMF measures the amount of Money Flow Volume over a specific period.
    class CMF
      # Calculates the Chaikin Money Flow.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The period for CMF (default: 20).
      # @return [Array<Float, nil>] The calculated CMF values.
      def self.calculate(data, period: 20)
        period = period.to_i
        return Array.new(data.size, nil) if data.size < period

        output = []
        period_volumes = []
        period_mf_volumes = []

        data.each do |v|
          high = v[:high]
          low = v[:low]
          close = v[:close]
          volume = v[:volume]

          multiplier = if high == low
                         0.0
                       else
                         ((close - low) - (high - close)) / (high - low).to_f
                       end
          mf_volume = multiplier * volume

          period_volumes << volume
          period_mf_volumes << mf_volume

          if period_volumes.size == period
            volume_sum = CalculationHelpers.sum(period_volumes)
            mf_volume_sum = CalculationHelpers.sum(period_mf_volumes)
            
            output << (volume_sum.zero? ? 0.0 : mf_volume_sum / volume_sum.to_f)

            period_volumes.shift
            period_mf_volumes.shift
          else
            output << nil
          end
        end
        output
      end
    end
  end
end
