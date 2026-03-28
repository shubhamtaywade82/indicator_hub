module IndicatorHub
  module Indicators
    class SO
      include CalculationHelpers

      # Stochastic Oscillator
      # @param highs [Array] Array of high prices
      # @param lows [Array] Array of low prices
      # @param closes [Array] Array of close prices
      # @param k_period [Integer] Period for %K calculation (default 14)
      # @param k_slowing [Integer] Smoothing for %K (default 3 for slow, 1 for fast)
      # @param d_period [Integer] Period for %D calculation (default 3)
      # @return [Hash] A hash containing %K and %D values
      def self.calculate(highs, lows, closes, k_period = 14, k_slowing = 3, d_period = 3)
        return nil if highs.length < k_period + k_slowing + d_period - 2

        fast_ks = []
        (k_period - 1...highs.length).each do |i|
          current_highs = highs[i - k_period + 1..i]
          current_lows = lows[i - k_period + 1..i]
          
          hh = current_highs.max
          ll = current_lows.min
          
          if hh == ll
            fast_ks << 100.0
          else
            fast_ks << ((closes[i] - ll) / (hh - ll) * 100.0)
          end
        end

        # Slow %K is SMA of fast %K
        slow_ks = []
        if k_slowing > 1
          (k_slowing - 1...fast_ks.length).each do |i|
            slow_ks << (fast_ks[i - k_slowing + 1..i].sum / k_slowing)
          end
        else
          slow_ks = fast_ks
        end

        # %D is SMA of slow %K
        ds = []
        (d_period - 1...slow_ks.length).each do |i|
          ds << (slow_ks[i - d_period + 1..i].sum / d_period)
        end

        {
          k: slow_ks.last&.round(4),
          d: ds.last&.round(4)
        }
      end
    end
  end
end
