# frozen_string_literal: true

require_relative "../calculation_helpers"
require_relative "sma"

module IndicatorHub
  module Indicators
    # Know Sure Thing (KST).
    # KST is a momentum oscillator based on the smoothed rate-of-change of four
    # different timeframes.
    class KST
      # Calculates the Know Sure Thing.
      # @param data [Array<Numeric, Hash>] Array of prices or OHLCV hashes.
      # @param r1 [Integer] ROC period 1 (default: 10).
      # @param r2 [Integer] ROC period 2 (default: 15).
      # @param r3 [Integer] ROC period 3 (default: 20).
      # @param r4 [Integer] ROC period 4 (default: 30).
      # @param s1 [Integer] SMA period 1 (default: 10).
      # @param s2 [Integer] SMA period 2 (default: 10).
      # @param s3 [Integer] SMA period 3 (default: 10).
      # @param s4 [Integer] SMA period 4 (default: 15).
      # @param signal [Integer] Signal line period (default: 9).
      # @return [Array<Hash>] The calculated KST values { kst: Float, signal: Float }.
      def self.calculate(data, r1: 10, r2: 15, r3: 20, r4: 30, s1: 10, s2: 10, s3: 10, s4: 15, signal: 9)
        # Use close prices for KST
        closes = data.map do |v|
          if v.is_a?(Hash)
            (v[:close] || v["close"]).to_f
          else
            v.to_f
          end
        end

        kst_values = []
        closes.each_with_index do |_, i|
          rcma1 = calculate_rcma(closes, i, r1, s1)
          rcma2 = calculate_rcma(closes, i, r2, s2)
          rcma3 = calculate_rcma(closes, i, r3, s3)
          rcma4 = calculate_rcma(closes, i, r4, s4)

          if rcma1 && rcma2 && rcma3 && rcma4
            kst = (1.0 * rcma1) + (2.0 * rcma2) + (3.0 * rcma3) + (4.0 * rcma4)
            kst_values << kst
          else
            kst_values << nil
          end
        end

        # Calculate signal line (SMA of KST)
        valid_kst = kst_values.compact
        if valid_kst.size >= signal
          signal_line_valid = CalculationHelpers.sma(valid_kst, signal)
          lead_nils_count = kst_values.count(nil)
          full_signal_line = Array.new(lead_nils_count, nil) + signal_line_valid
        else
          full_signal_line = Array.new(kst_values.size, nil)
        end

        kst_values.zip(full_signal_line).map do |kst, sig|
          { kst: kst, signal: sig }
        end
      end

      def self.calculate_rcma(data, index, roc, sma)
        # ROC = (Price(t) - Price(t-roc)) / Price(t-roc) * 100
        # RCMA = SMA of ROC over 'sma' periods
        return nil if index < (roc + sma)

        roc_data = []
        ((index - sma + 1)..index).each do |i|
          current_price = data[i]
          past_price = data[i - roc]
          return nil if past_price.nil? || past_price.zero?

          roc_data << ((current_price - past_price) / past_price.to_f * 100.0)
        end
        CalculationHelpers.average(roc_data)
      end
      private_class_method :calculate_rcma
    end
  end
end
