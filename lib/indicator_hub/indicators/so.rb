# frozen_string_literal: true

module IndicatorHub
  module Indicators
    # Stochastic Oscillator (SO).
    # SO is a momentum indicator comparing a particular closing price of a
    # security to a range of its prices over a certain period of time.
    class SO
      include CalculationHelpers

      # Calculates the Stochastic Oscillator.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param k_period [Integer] Period for %K calculation (default: 14).
      # @param k_slowing [Integer] Smoothing for %K (default: 3).
      # @param d_period [Integer] Period for %D calculation (default: 3).
      # @return [Array<Hash>] The calculated SO values { k: Float, d: Float }.
      def self.calculate(data, k_period: 14, k_slowing: 3, d_period: 3)
        highs = data.map { |d| d[:high] }
        lows = data.map { |d| d[:low] }
        closes = data.map { |d| d[:close] }

        fast_ks = []
        data.each_with_index do |_, i|
          if i < k_period - 1
            fast_ks << nil
          else
            current_highs = highs[(i - k_period + 1)..i]
            current_lows = lows[(i - k_period + 1)..i]

            hh = current_highs.max
            ll = current_lows.min

            fast_ks << if hh == ll
                         100.0
                       else
                         ((closes[i] - ll) / (hh - ll) * 100.0)
                       end
          end
        end

        # Slow %K is SMA of fast %K
        slow_ks = []
        if k_slowing > 1
          fast_ks.each_with_index do |_, i|
            if i < (k_period - 1) + (k_slowing - 1)
              slow_ks << nil
            else
              period_values = fast_ks[(i - k_slowing + 1)..i]
              slow_ks << (period_values.sum / k_slowing.to_f)
            end
          end
        else
          slow_ks = fast_ks
        end

        # %D is SMA of slow %K
        ds = []
        slow_ks.each_with_index do |_, i|
          if i < (k_period - 1) + (k_slowing > 1 ? (k_slowing - 1) : 0) + (d_period - 1)
            ds << nil
          else
            period_values = slow_ks[(i - d_period + 1)..i]
            ds << (period_values.sum / d_period.to_f)
          end
        end

        data.map.with_index do |_, i|
          {
            k: slow_ks[i]&.round(4),
            d: ds[i]&.round(4)
          }
        end
      end
    end
  end
end
