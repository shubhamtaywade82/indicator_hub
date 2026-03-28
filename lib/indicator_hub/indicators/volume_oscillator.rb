# frozen_string_literal: true

require_relative '../calculation_helpers'

module IndicatorHub
  module Indicators
    # Volume Oscillator.
    # Volume Oscillator measures the difference between a fast and slow volume 
    # moving average.
    class VolumeOscillator
      # Calculates the Volume Oscillator.
      # @param data [Array<Numeric, Hash>] Array of volumes or OHLCV hashes.
      # @param short_period [Integer] Short SMA period (default: 20).
      # @param long_period [Integer] Long SMA period (default: 60).
      # @return [Array<Float, nil>] The calculated Volume Oscillator values.
      def self.calculate(data, short_period: 20, long_period: 60)
        # Handle OHLC data by extracting volume
        numeric_data = if data.is_a?(Array) && data.first.is_a?(Hash)
                         data.map { |d| d[:volume] }
                       else
                         data
                       end

        Validation.validate_numeric_data(numeric_data)
        
        output = []
        short_period_values = []
        long_period_values = []

        numeric_data.each do |v|
          short_period_values << v
          long_period_values << v

          short_period_values.shift if short_period_values.size > short_period
          long_period_values.shift if long_period_values.size > long_period

          if long_period_values.size == long_period
            short_sma = CalculationHelpers.average(short_period_values)
            long_sma = CalculationHelpers.average(long_period_values)
            
            vo = if long_sma.zero?
                   0.0
                 else
                   ((short_sma - long_sma) / long_sma.to_f) * 100.0
                 end
            output << vo.round(2)
          else
            output << nil
          end
        end
        output
      end
    end
  end
end
