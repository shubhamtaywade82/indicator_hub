# frozen_string_literal: true

require_relative "../calculation_helpers"

module IndicatorHub
  module Indicators
    # Vortex Indicator (VI)
    class VI
      def self.calculate(data, period: 14)
        output = []
        pos_vms = []
        neg_vms = []
        trs = []

        data.each_with_index do |val, i|
          if i == 0
            output << { positive_vi: nil, negative_vi: nil }
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
              positive_vi: (sum_pos / sum_tr.to_f),
              negative_vi: (sum_neg / sum_tr.to_f)
            }
          else
            output << { positive_vi: nil, negative_vi: nil }
          end
        end

        output
      end
    end
  end
end
