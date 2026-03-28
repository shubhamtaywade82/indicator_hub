# frozen_string_literal: true

require "indicator_hub"

RSpec.describe IndicatorHub do
  let(:data) { [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20] }
  let(:hash_data) { data.map { |v| { close: v.to_f } } }

  let(:large_data) { Array.new(100) { |i| 10.0 + Math.sin(i).abs * 10.0 } }

  describe ".sma" do
    it "calculates simple moving average correctly" do
      result = IndicatorHub.sma(data, period: 5)
      expect(result[4]).to eq(12.0) # (10+11+12+13+14)/5 = 60/5 = 12
      expect(result[5]).to eq(13.0) # (11+12+13+14+15)/5 = 65/5 = 13
    end

    it "handles hash data" do
      result = IndicatorHub.sma(hash_data, period: 5)
      expect(result[4]).to eq(12.0)
    end
  end

  describe ".ema" do
    it "calculates exponential moving average correctly" do
      # For first period, EMA = SMA
      result = IndicatorHub.ema(data, period: 5)
      expect(result[4]).to eq(12.0)

      # Subsequent: (15 - 12) * (2/6) + 12 = 3 * 0.3333 + 12 = 1 + 12 = 13
      expect(result[5]).to be_within(0.01).of(13.0)
    end
  end

  describe ".rsi" do
    let(:rsi_data) do
      [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08, 45.89, 46.03, 45.61, 46.28, 46.28, 46.00]
    end

    it "calculates relative strength index" do
      result = IndicatorHub.rsi(rsi_data, period: 14)
      expect(result.size).to eq(rsi_data.size)
      expect(result.last).to be_between(0, 100)
    end
  end

  describe ".bb" do
    it "calculates bollinger bands" do
      result = IndicatorHub.bb(data, period: 5)
      expect(result[4]).to have_key(:upper)
      expect(result[4]).to have_key(:middle)
      expect(result[4]).to have_key(:lower)
      expect(result[4][:middle]).to eq(12.0)
    end
  end

  describe ".macd" do
    it "calculates macd" do
      result = IndicatorHub.macd(data, fast_period: 2, slow_period: 5, signal_period: 3)
      expect(result.last).to have_key(:macd)
      expect(result.last).to have_key(:signal)
      expect(result.last).to have_key(:histogram)
    end
  end

  describe ".wma" do
    it "calculates weighted moving average" do
      result = IndicatorHub.wma(data, period: 5)
      expect(result[4]).to be > 0
    end
  end

  describe ".vwap" do
    let(:ohlcv_data) do
      [
        { high: 11, low: 9, close: 10, volume: 100 },
        { high: 12, low: 10, close: 11, volume: 200 }
      ]
    end

    it "calculates vwap" do
      result = IndicatorHub.vwap(ohlcv_data)
      expect(result.size).to eq(2)
      expect(result.last).to be > 10
    end
  end

  describe ".ichimoku" do
    let(:ohlcv_data) do
      Array.new(100) { { high: 12, low: 10, close: 11, volume: 100 } }
    end

    it "calculates ichimoku" do
      result = IndicatorHub.ichimoku(ohlcv_data)
      expect(result.last).to have_key(:tenkan_sen)
      expect(result.last).to have_key(:kijun_sen)
      expect(result.last).to have_key(:senkou_span_a)
    end
  end

  describe "Additional Indicators" do
    let(:ohlcv_data) do
      Array.new(100) { |i| { open: 10 + i, high: 12 + i, low: 9 + i, close: 11 + i, volume: 1000 + (i * 10) } }
    end

    it "calculates adi" do
      result = IndicatorHub.adi(ohlcv_data)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates adtv" do
      result = IndicatorHub.adtv(ohlcv_data, period: 20)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates adx" do
      result = IndicatorHub.adx(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates ao" do
      result = IndicatorHub.ao(ohlcv_data)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates atr" do
      result = IndicatorHub.atr(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates cci" do
      result = IndicatorHub.cci(ohlcv_data, period: 20)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates cmf" do
      result = IndicatorHub.cmf(ohlcv_data, period: 20)
      expect(result.size).to eq(100)
      expect(result.last).to be_a(Numeric)
    end

    it "calculates cmo" do
      result = IndicatorHub.cmo(large_data, period: 14)
      expect(result.size).to eq(100)
    end

    it "calculates cr" do
      result = IndicatorHub.cr(ohlcv_data, period: 20)
      expect(result.size).to eq(100)
    end

    it "calculates dc" do
      result = IndicatorHub.dc(ohlcv_data, period: 20)
      expect(result.last).to have_key(:upper)
      expect(result.last).to have_key(:middle)
      expect(result.last).to have_key(:lower)
    end

    it "calculates dlr" do
      result = IndicatorHub.dlr(data)
      expect(result.size).to eq(data.size)
    end

    it "calculates dpo" do
      result = IndicatorHub.dpo(data, period: 5)
      expect(result.size).to eq(data.size)
    end

    it "calculates dr" do
      result = IndicatorHub.dr(data)
      expect(result.size).to eq(data.size)
    end

    it "calculates envelopes_ema" do
      result = IndicatorHub.envelopes_ema(ohlcv_data, period: 20)
      expect(result.last).to have_key(:upper)
      expect(result.last).to have_key(:lower)
    end

    it "calculates eom" do
      result = IndicatorHub.eom(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
    end

    it "calculates fi" do
      result = IndicatorHub.fi(ohlcv_data, period: 13)
      expect(result.size).to eq(100)
    end

    it "calculates imi" do
      result = IndicatorHub.imi(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
    end

    it "calculates kc" do
      result = IndicatorHub.kc(ohlcv_data, period: 20)
      expect(result.last).to have_key(:upper)
      expect(result.last).to have_key(:middle)
      expect(result.last).to have_key(:lower)
    end

    it "calculates kst" do
      result = IndicatorHub.kst(ohlcv_data)
      expect(result.last).to have_key(:kst)
      expect(result.last).to have_key(:signal)
    end

    it "calculates mfi" do
      result = IndicatorHub.mfi(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
    end

    it "calculates mi" do
      result = IndicatorHub.mi(ohlcv_data, period: 25)
      expect(result.size).to eq(100)
    end

    it "calculates nvi" do
      result = IndicatorHub.nvi(ohlcv_data)
      expect(result.size).to eq(100)
    end

    it "calculates obv" do
      result = IndicatorHub.obv(ohlcv_data)
      expect(result.size).to eq(100)
    end

    it "calculates obv_mean" do
      result = IndicatorHub.obv_mean(ohlcv_data, period: 10)
      expect(result.size).to eq(100)
    end

    it "calculates pivot_points" do
      result = IndicatorHub.pivot_points(ohlcv_data)
      expect(result.last).to have_key(:p)
      expect(result.last).to have_key(:r1)
      expect(result.last).to have_key(:s1)
    end

    it "calculates price_channel" do
      result = IndicatorHub.price_channel(ohlcv_data, period: 20)
      expect(result.last).to have_key(:upper)
      expect(result.last).to have_key(:lower)
    end

    it "calculates qstick" do
      result = IndicatorHub.qstick(ohlcv_data, period: 10)
      expect(result.size).to eq(100)
    end

    it "calculates rmi" do
      result = IndicatorHub.rmi(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
    end

    it "calculates roc" do
      result = IndicatorHub.roc(data, period: 5)
      expect(result.size).to eq(data.size)
    end

    it "calculates so" do
      result = IndicatorHub.so(ohlcv_data)
      expect(result.last).to have_key(:k)
      expect(result.last).to have_key(:d)
    end

    it "calculates trix" do
      result = IndicatorHub.trix(data, period: 5)
      expect(result.size).to eq(data.size)
    end

    it "calculates tsi" do
      result = IndicatorHub.tsi(data)
      expect(result.size).to eq(data.size)
    end

    it "calculates uo" do
      result = IndicatorHub.uo(ohlcv_data)
      expect(result.size).to eq(100)
    end

    it "calculates vi" do
      result = IndicatorHub.vi(ohlcv_data, period: 14)
      expect(result.last).to have_key(:plus_vi)
      expect(result.last).to have_key(:minus_vi)
    end

    it "calculates volume_oscillator" do
      result = IndicatorHub.volume_oscillator(ohlcv_data, short_period: 5, long_period: 10)
      expect(result.size).to eq(100)
    end

    it "calculates vpt" do
      result = IndicatorHub.vpt(ohlcv_data)
      expect(result.size).to eq(100)
    end

    it "calculates wilders_smoothing" do
      result = IndicatorHub.wilders_smoothing(data, period: 5)
      expect(result.size).to eq(data.size)
    end

    it "calculates wr" do
      result = IndicatorHub.wr(ohlcv_data, period: 14)
      expect(result.size).to eq(100)
    end
  end
end
