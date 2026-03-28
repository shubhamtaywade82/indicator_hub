# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Average Directional Index (ADX).
    # ADX is used to quantify trend strength. It is calculated based on the 
    # moving average of price range expansion over a given period of time.
    class ADX
      # Calculates the Average Directional Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The period for ADX calculation (default: 14).
      # @return [Array<Float, nil>] The calculated ADX values.
      def self.calculate(data, period: 14)
        output = []
        plus_dm = []
        minus_dm = []
        tr = []

        data.each_with_index do |val, i|
          if i == 0
            plus_dm << 0.0
            minus_dm << 0.0
            tr << (val[:high] - val[:low])
            next
          end

          prev = data[i - 1]
          high_diff = val[:high] - prev[:high]
          low_diff = prev[:low] - val[:low]

          if high_diff > low_diff && high_diff > 0
            plus_dm << high_diff
          else
            plus_dm << 0.0
          end

          if low_diff > high_diff && low_diff > 0
            minus_dm << low_diff
          else
            minus_dm << 0.0
          end

          tr << CalculationHelpers.true_range(val[:high], val[:low], prev[:close])
        end

        smoothed_plus_dm = smooth(plus_dm, period)
        smoothed_minus_dm = smooth(minus_dm, period)
        smoothed_tr = smooth(tr, period)

        dx_values = []
        smoothed_plus_dm.each_with_index do |s_plus, i|
          s_minus = smoothed_minus_dm[i]
          s_tr = smoothed_tr[i]

          plus_di = 100.0 * (s_plus / s_tr)
          minus_di = 100.0 * (s_minus / s_tr)
          
          dx = 100.0 * (plus_di - minus_di).abs / (plus_di + minus_di)
          dx_values << dx
        end

        # ADX is SMA of DX for the first period, then smoothed
        adx = 0.0
        dx_values.each_with_index do |dx, i|
          if i < period - 1
            output << nil
          elsif i == period - 1
            adx = CalculationHelpers.average(dx_values[0..i])
            output << adx
          else
            adx = (adx * (period - 1) + dx) / period.to_f
            output << adx
          end
        end

        # Prepend nil for the initial period where TR/DM are being calculated
        Array.new(period - 1, nil) + output
      end

      def self.smooth(data, period)
        smoothed = []
        current_sum = 0.0
        
        data.each_with_index do |val, i|
          if i < period - 1
            current_sum += val
          elsif i == period - 1
            current_sum += val
            smoothed << current_sum
          else
            prev_smoothed = smoothed.last
            new_smoothed = prev_smoothed - (prev_smoothed / period.to_f) + val
            smoothed << new_smoothed
          end
        end
        smoothed
      end
    end
  end
end
