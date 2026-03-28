# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Negative Volume Index (NVI).
    # NVI is a technical indicator used to identify market trends based on
    # days when volume decreases.
    class NVI
      # Calculates the Negative Volume Index.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @return [Array<Float>] The calculated NVI values.
      def self.calculate(data)
        nvi_cumulative = 1_000.00
        output = []

        # We need at least two points to calculate change
        return [] if data.empty?

        data[0]
        output << nvi_cumulative # Start with default of 1_000 for the first point

        (1...data.length).each do |i|
          v = data[i]
          prev_v = data[i - 1]

          volume_change = ((v[:volume] - prev_v[:volume]) / prev_v[:volume].to_f)

          if volume_change.negative?
            price_change = ((v[:close] - prev_v[:close]) / prev_v[:close].to_f) * 100.00
            nvi_cumulative += price_change
          end

          output << nvi_cumulative
        end

        output
      end
    end
  end
end
