# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Ultimate Oscillator (UO).
    # UO is a technical indicator that combines price action over three
    # different timeframes into a single momentum oscillator.
    class UO
      # Calculates the Ultimate Oscillator.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param short_period [Integer] Short period (default: 7).
      # @param medium_period [Integer] Medium period (default: 14).
      # @param long_period [Integer] Long period (default: 28).
      # @param short_weight [Float] Short period weight (default: 4.0).
      # @param medium_weight [Float] Medium period weight (default: 2.0).
      # @param long_weight [Float] Long period weight (default: 1.0).
      # @return [Array<Float, nil>] The calculated UO values.
      def self.calculate(data, short_period: 7, medium_period: 14, long_period: 28,
                         short_weight: 4.0, medium_weight: 2.0, long_weight: 1.0)
        short_period = short_period.to_i
        medium_period = medium_period.to_i
        long_period = long_period.to_i

        return [] if data.size < 2

        bp = []
        tr = []

        (1...data.size).each do |i|
          v = data[i]
          prev_close = data[i - 1][:close]

          min_low_p_close = [v[:low], prev_close].min
          max_high_p_close = [v[:high], prev_close].max

          bp << (v[:close] - min_low_p_close)
          tr << (max_high_p_close - min_low_p_close)
        end

        sum_weights = short_weight + medium_weight + long_weight
        output = Array.new(data.size, nil)

        # We need long_period elements in bp/tr to start
        # bp/tr have size data.size - 1
        (long_period - 1...bp.size).each do |i|
          avg7 = sum_last(bp, i, short_period) / sum_last(tr, i, short_period).to_f
          avg14 = sum_last(bp, i, medium_period) / sum_last(tr, i, medium_period).to_f
          avg28 = sum_last(bp, i, long_period) / sum_last(tr, i, long_period).to_f

          uo = 100.0 * ((short_weight * avg7) + (medium_weight * avg14) + (long_weight * avg28)) / sum_weights
          output[i + 1] = uo
        end

        output
      end

      def self.sum_last(array, index, period)
        start = index - period + 1
        sum = 0.0
        (start..index).each { |j| sum += array[j] }
        sum
      end
    end
  end
end
