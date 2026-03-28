# frozen_string_literal: true

require_relative "indicator_hub/version"
require_relative "indicator_hub/calculation_helpers"
require_relative "indicator_hub/series"
require_relative "indicator_hub/indicators/adi"
require_relative "indicator_hub/indicators/adtv"
require_relative "indicator_hub/indicators/adx"
require_relative "indicator_hub/indicators/ao"
require_relative "indicator_hub/indicators/atr"
require_relative "indicator_hub/indicators/bb"
require_relative "indicator_hub/indicators/cci"
require_relative "indicator_hub/indicators/cmf"
require_relative "indicator_hub/indicators/cmo"
require_relative "indicator_hub/indicators/cr"
require_relative "indicator_hub/indicators/dc"
require_relative "indicator_hub/indicators/dlr"
require_relative "indicator_hub/indicators/dpo"
require_relative "indicator_hub/indicators/dr"
require_relative "indicator_hub/indicators/ema"
require_relative "indicator_hub/indicators/envelopes_ema"
require_relative "indicator_hub/indicators/eom"
require_relative "indicator_hub/indicators/fi"
require_relative "indicator_hub/indicators/ichimoku"
require_relative "indicator_hub/indicators/imi"
require_relative "indicator_hub/indicators/kc"
require_relative "indicator_hub/indicators/kst"
require_relative "indicator_hub/indicators/macd"
require_relative "indicator_hub/indicators/mfi"
require_relative "indicator_hub/indicators/mi"
require_relative "indicator_hub/indicators/nvi"
require_relative "indicator_hub/indicators/obv_mean"
require_relative "indicator_hub/indicators/obv"
require_relative "indicator_hub/indicators/pivot_points"
require_relative "indicator_hub/indicators/price_channel"
require_relative "indicator_hub/indicators/qstick"
require_relative "indicator_hub/indicators/rmi"
require_relative "indicator_hub/indicators/roc"
require_relative "indicator_hub/indicators/rsi"
require_relative "indicator_hub/indicators/sma"
require_relative "indicator_hub/indicators/so"
require_relative "indicator_hub/indicators/trix"
require_relative "indicator_hub/indicators/tsi"
require_relative "indicator_hub/indicators/uo"
require_relative "indicator_hub/indicators/vi"
require_relative "indicator_hub/indicators/volume_oscillator"
require_relative "indicator_hub/indicators/vpt"
require_relative "indicator_hub/indicators/vwap"
require_relative "indicator_hub/indicators/wilders_smoothing"
require_relative "indicator_hub/indicators/wma"
require_relative "indicator_hub/indicators/wr"

# Base module for IndicatorHub technical analysis library.
module IndicatorHub
  # Generic error class for all IndicatorHub errors.
  class Error < StandardError; end

  # Main API for technical analysis indicators

  # Group 1: Single Series Indicators (Usually :close)

  # Calculates the Simple Moving Average (SMA).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The SMA period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated SMA values.
  def self.sma(data, period: 20, field: :close)
    Indicators::SMA.new(data, period: period, field: field).calculate
  end

  # Calculates the Exponential Moving Average (EMA).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The EMA period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated EMA values.
  def self.ema(data, period: 20, field: :close)
    Indicators::EMA.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the Weighted Moving Average (WMA).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The WMA period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated WMA values.
  def self.wma(data, period: 20, field: :close)
    Indicators::WMA.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the Relative Strength Index (RSI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The RSI period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated RSI values.
  def self.rsi(data, period: 14, field: :close)
    Indicators::RSI.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the Chande Momentum Oscillator (CMO).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The CMO period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated CMO values.
  def self.cmo(data, period: 14, field: :close)
    Indicators::CMO.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the Daily Log Return (DLR).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated DLR values.
  def self.dlr(data, field: :close)
    Indicators::DLR.calculate(normalize_series(data, field))
  end

  # Calculates the Detrended Price Oscillator (DPO).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The DPO period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated DPO values.
  def self.dpo(data, period: 20, field: :close)
    Indicators::DPO.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the Daily Return (DR).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated DR values.
  def self.dr(data, field: :close)
    Indicators::DR.calculate(normalize_series(data, field))
  end

  # Calculates the Rate of Change (ROC).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The ROC period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated ROC values.
  def self.roc(data, period: 12, field: :close)
    Indicators::ROC.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the TRIX (Triple Exponential Average).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The TRIX period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated TRIX values.
  def self.trix(data, period: 15, field: :close)
    Indicators::TRIX.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the True Strength Index (TSI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param fast_period [Integer] The fast TSI period.
  # @param slow_period [Integer] The slow TSI period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated TSI values.
  def self.tsi(data, fast_period: 13, slow_period: 25, field: :close)
    Indicators::TSI.calculate(normalize_series(data, field), fast_period: fast_period, slow_period: slow_period)
  end

  # Calculates Wilder's Smoothing.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The smoothing period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated values.
  def self.wilders_smoothing(data, period: 14, field: :close)
    Indicators::WildersSmoothing.calculate(normalize_series(data, field), period: period)
  end

  # Group 2: OHLCV Indicators

  # Calculates the Accumulation/Distribution Index (ADI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @return [Array<Float, nil>] The calculated ADI values.
  def self.adi(data)
    Indicators::ADI.calculate(normalize_ohlcv(data))
  end

  # Calculates the Average Daily Trading Volume (ADTV).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The ADTV period.
  # @return [Array<Float, nil>] The calculated ADTV values.
  def self.adtv(data, period: 20)
    Indicators::ADTV.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Average Directional Index (ADX).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The ADX period.
  # @return [Array<Float, nil>] The calculated ADX values.
  def self.adx(data, period: 14)
    Indicators::ADX.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Awesome Oscillator (AO).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param short_period [Integer] The short AO period.
  # @param long_period [Integer] The long AO period.
  # @return [Array<Float, nil>] The calculated AO values.
  def self.ao(data, short_period: 5, long_period: 34)
    Indicators::AO.calculate(normalize_ohlcv(data), short_period: short_period, long_period: long_period)
  end

  # Calculates the Average True Range (ATR).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The ATR period.
  # @return [Array<Float, nil>] The calculated ATR values.
  def self.atr(data, period: 14)
    Indicators::ATR.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates Bollinger Bands (BB).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The BB period.
  # @param standard_deviations [Numeric] The number of standard deviations.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated BB values.
  def self.bb(data, period: 20, standard_deviations: 2, field: :close)
    Indicators::BB.calculate(normalize_series(data, field), period: period, standard_deviations: standard_deviations)
  end

  # Calculates the Commodity Channel Index (CCI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The CCI period.
  # @return [Array<Float, nil>] The calculated CCI values.
  def self.cci(data, period: 20)
    Indicators::CCI.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Chaikin Money Flow (CMF).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The CMF period.
  # @return [Array<Float, nil>] The calculated CMF values.
  def self.cmf(data, period: 20)
    Indicators::CMF.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the CR Indicator.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The CR period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated CR values.
  def self.cr(data, period: 20, field: :close)
    Indicators::CR.calculate(normalize_series(data, field), period: period)
  end

  # Calculates the Donchian Channel (DC).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The DC period.
  # @return [Array<Float, nil>] The calculated DC values.
  def self.dc(data, period: 20)
    Indicators::DC.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates Envelopes using EMA.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The EMA period.
  # @param percentage [Numeric] The envelope percentage.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated envelope values.
  def self.envelopes_ema(data, period: 20, percentage: 2.5, field: :close)
    Indicators::EnvelopesEMA.calculate(normalize_series(data, field), period: period, percentage: percentage)
  end

  # Calculates Ease of Movement (EOM).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The EOM period.
  # @return [Array<Float, nil>] The calculated EOM values.
  def self.eom(data, period: 14)
    Indicators::EOM.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Force Index (FI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The FI period.
  # @return [Array<Float, nil>] The calculated FI values.
  def self.fi(data, period: 13)
    Indicators::FI.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Ichimoku Cloud.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param low_period [Integer] The low period.
  # @param medium_period [Integer] The medium period.
  # @param high_period [Integer] The high period.
  # @return [Array<Float, nil>] The calculated Ichimoku values.
  def self.ichimoku(data, low_period: 9, medium_period: 26, high_period: 52)
    Indicators::Ichimoku.calculate(normalize_ohlcv(data), low_period: low_period, medium_period: medium_period,
                                                          high_period: high_period)
  end

  # Calculates the Intraday Momentum Index (IMI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The IMI period.
  # @return [Array<Float, nil>] The calculated IMI values.
  def self.imi(data, period: 14)
    Indicators::IMI.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates Keltner Channels (KC).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The KC period.
  # @param multiplier [Numeric] The multiplier for the channel width.
  # @return [Array<Float, nil>] The calculated KC values.
  def self.kc(data, period: 20, multiplier: 1.5)
    Indicators::KC.calculate(normalize_ohlcv(data), period: period, multiplier: multiplier)
  end

  # Calculates the Know Sure Thing (KST) oscillator.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param r1 [Integer] ROC period 1.
  # @param r2 [Integer] ROC period 2.
  # @param r3 [Integer] ROC period 3.
  # @param r4 [Integer] ROC period 4.
  # @param s1 [Integer] Smoothing period 1.
  # @param s2 [Integer] Smoothing period 2.
  # @param s3 [Integer] Smoothing period 3.
  # @param s4 [Integer] Smoothing period 4.
  # @param signal [Integer] Signal line period.
  # @return [Array<Float, nil>] The calculated KST values.
  def self.kst(data, r1: 10, r2: 15, r3: 20, r4: 30, s1: 10, s2: 10, s3: 10, s4: 15, signal: 9)
    Indicators::KST.calculate(normalize_series(data, :close), r1: r1, r2: r2, r3: r3, r4: r4, s1: s1, s2: s2, s3: s3,
                                                              s4: s4, signal: signal)
  end

  # Calculates the Moving Average Convergence Divergence (MACD).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param fast_period [Integer] The fast MACD period.
  # @param slow_period [Integer] The slow MACD period.
  # @param signal_period [Integer] The signal line period.
  # @param field [Symbol] The field to use if data is an array of hashes.
  # @return [Array<Float, nil>] The calculated MACD values.
  def self.macd(data, fast_period: 12, slow_period: 26, signal_period: 9, field: :close)
    Indicators::MACD.calculate(normalize_series(data, field), fast_period: fast_period, slow_period: slow_period,
                                                              signal_period: signal_period)
  end

  # Calculates the Money Flow Index (MFI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The MFI period.
  # @return [Array<Float, nil>] The calculated MFI values.
  def self.mfi(data, period: 14)
    Indicators::MFI.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Mass Index (MI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The MI period.
  # @return [Array<Float, nil>] The calculated MI values.
  def self.mi(data, period: 25)
    Indicators::MI.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Negative Volume Index (NVI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @return [Array<Float, nil>] The calculated NVI values.
  def self.nvi(data)
    Indicators::NVI.calculate(normalize_ohlcv(data))
  end

  # Calculates the On-Balance Volume (OBV).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @return [Array<Float, nil>] The calculated OBV values.
  def self.obv(data)
    Indicators::OBV.calculate(normalize_ohlcv(data))
  end

  # Calculates the Mean of On-Balance Volume (OBV Mean).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The OBV Mean period.
  # @return [Array<Float, nil>] The calculated OBV Mean values.
  def self.obv_mean(data, period: 10)
    Indicators::OBVMean.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates Pivot Points.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @return [Array<Float, nil>] The calculated pivot points.
  def self.pivot_points(data)
    Indicators::PivotPoints.calculate(normalize_ohlcv(data))
  end

  # Calculates the Price Channel.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The price channel period.
  # @return [Array<Float, nil>] The calculated price channel values.
  def self.price_channel(data, period: 20)
    Indicators::PriceChannel.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the QStick indicator.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The QStick period.
  # @return [Array<Float, nil>] The calculated QStick values.
  def self.qstick(data, period: 10)
    Indicators::QStick.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Range Momentum Index (RMI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The RMI period.
  # @param momentum_period [Integer] The momentum period.
  # @return [Array<Float, nil>] The calculated RMI values.
  def self.rmi(data, period: 14, momentum_period: 5)
    Indicators::RMI.calculate(normalize_series(data, :close), period: period, momentum_period: momentum_period)
  end

  # Calculates the Stochastic Oscillator (SO).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param k_period [Integer] The %K period.
  # @param d_period [Integer] The %D period.
  # @return [Array<Float, nil>] The calculated SO values.
  def self.so(data, k_period: 14, d_period: 3)
    Indicators::SO.calculate(normalize_ohlcv(data), k_period: k_period, d_period: d_period)
  end

  # Calculates the Ultimate Oscillator (UO).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param short_period [Integer] The short UO period.
  # @param medium_period [Integer] The medium UO period.
  # @param long_period [Integer] The long UO period.
  # @return [Array<Float, nil>] The calculated UO values.
  def self.uo(data, short_period: 7, medium_period: 14, long_period: 28)
    Indicators::UO.calculate(normalize_ohlcv(data), short_period: short_period, medium_period: medium_period,
                                                    long_period: long_period)
  end

  # Calculates the Vortex Indicator (VI).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The VI period.
  # @return [Array<Float, nil>] The calculated VI values.
  def self.vi(data, period: 14)
    Indicators::VI.calculate(normalize_ohlcv(data), period: period)
  end

  # Calculates the Volume Oscillator.
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param short_period [Integer] The short oscillator period.
  # @param long_period [Integer] The long oscillator period.
  # @return [Array<Float, nil>] The calculated volume oscillator values.
  def self.volume_oscillator(data, short_period: 20, long_period: 60)
    Indicators::VolumeOscillator.calculate(normalize_ohlcv(data), short_period: short_period, long_period: long_period)
  end

  # Calculates the Volume Price Trend (VPT).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @return [Array<Float, nil>] The calculated VPT values.
  def self.vpt(data)
    Indicators::VPT.calculate(normalize_ohlcv(data))
  end

  # Calculates the Volume Weighted Average Price (VWAP).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @return [Array<Float, nil>] The calculated VWAP values.
  def self.vwap(data)
    Indicators::VWAP.calculate(normalize_ohlcv(data))
  end

  # Calculates Williams %R (WR).
  # @param data [Array<Hash, Numeric>] The input data (array of hashes or numbers).
  # @param period [Integer] The WR period.
  # @return [Array<Float, nil>] The calculated WR values.
  def self.wr(data, period: 14)
    Indicators::WR.calculate(normalize_ohlcv(data), period: period)
  end

  # ---- Private helpers ----

  # Normalizes data to a numeric array using Series.
  # @param data [Array] Raw input data.
  # @param field [Symbol] The field to extract.
  # @return [Array<Float>] Normalized numeric array.
  def self.normalize_series(data, field = :close)
    Series.new(data).to_a(field: field)
  end
  private_class_method :normalize_series

  # Normalizes data to OHLCV hash array using Series.
  # @param data [Array] Raw input data.
  # @return [Array<Hash>] Normalized OHLCV array.
  def self.normalize_ohlcv(data)
    Series.new(data).to_ohlc
  end
  private_class_method :normalize_ohlcv
end
