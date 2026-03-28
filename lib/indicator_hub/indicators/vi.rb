# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Vortex Indicator (VI).
    # VI is a technical indicator consisting of two lines that identify
    # positive and negative trend movement.
    class VI
      # Calculates the Vortex Indicator.
      # @param data [Array<Hash>] Array of OHLCV hashes.
      # @param period [Integer] The VI period (default: 14).
      # @return [Array<Hash>] The calculated VI values { plus_vi: Float, minus_vi: Float }.
      def self.calculate(data, period: 14)
        output = []
        pos_vms = []
        neg_vms = []
        trs = []

        data.each_with_index do |val, i|
          if i.zero?
            output << { plus_vi: nil, minus_vi: nil }
            next
          end

          prev = data[i - 1]
          pos_vm = (val[:high] - prev[:low]).abs
          neg_vm = (val[:low] - prev[:high]).abs
          tr = CalculationHelpers.true_range(val[:high], val[:low], prev[:close])

          pos_vms << pos_vm
          neg_vms << neg_vm
          trs << tr

          if pos_vms.size >= period
            sum_pos = CalculationHelpers.sum(pos_vms.last(period))
            sum_neg = CalculationHelpers.sum(neg_vms.last(period))
            sum_tr = CalculationHelpers.sum(trs.last(period))

            output << {
              plus_vi: (sum_pos / sum_tr.to_f),
              minus_vi: (sum_neg / sum_tr.to_f)
            }
          else
            output << { plus_vi: nil, minus_vi: nil }
          end
        end

        output
      end
    end
  end
end
