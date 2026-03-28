# frozen_string_literal: true

require_relative "indicator_hub/version"
require_relative "indicator_hub/calculation_helpers"
require_relative "indicator_hub/series"
require_relative "indicator_hub/indicators/sma"
require_relative "indicator_hub/indicators/ema"
require_relative "indicator_hub/indicators/wma"
require_relative "indicator_hub/indicators/rsi"
require_relative "indicator_hub/indicators/macd"
require_relative "indicator_hub/indicators/bb"
require_relative "indicator_hub/indicators/vwap"
require_relative "indicator_hub/indicators/ichimoku"

module IndicatorHub
  class Error < StandardError; end

  # Main API for technical analysis indicators
  
  def self.sma(data, period: 20, field: :close)
    series = Series.new(data)
    Indicators::SMA.calculate(series.to_a(field: field), period: period)
  end

  def self.ema(data, period: 20, field: :close)
    series = Series.new(data)
    Indicators::EMA.calculate(series.to_a(field: field), period: period)
  end

  def self.wma(data, period: 20, field: :close)
    series = Series.new(data)
    Indicators::WMA.calculate(series.to_a(field: field), period: period)
  end

  def self.rsi(data, period: 14, field: :close)
    series = Series.new(data)
    Indicators::RSI.calculate(series.to_a(field: field), period: period)
  end

  def self.macd(data, fast_period: 12, slow_period: 26, signal_period: 9, field: :close)
    series = Series.new(data)
    Indicators::MACD.calculate(series.to_a(field: field), 
                               fast_period: fast_period, 
                               slow_period: slow_period, 
                               signal_period: signal_period)
  end

  def self.bb(data, period: 20, standard_deviations: 2, field: :close)
    series = Series.new(data)
    Indicators::BB.calculate(series.to_a(field: field), 
                             period: period, 
                             standard_deviations: standard_deviations)
  end

  def self.vwap(data)
    series = Series.new(data)
    Indicators::VWAP.calculate(series.to_ohlc)
  end

  def self.ichimoku(data, low_period: 9, medium_period: 26, high_period: 52)
    series = Series.new(data)
    Indicators::Ichimoku.calculate(series.to_ohlc, 
                                   low_period: low_period, 
                                   medium_period: medium_period, 
                                   high_period: high_period)
  end
end
