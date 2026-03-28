# frozen_string_literal: true

require "indicator_hub"

RSpec.describe IndicatorHub do
  let(:data) { [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20] }
  let(:hash_data) { data.map { |v| { close: v.to_f } } }

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
    let(:rsi_data) { [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08, 45.89, 46.03, 45.61, 46.28, 46.28, 46.00] }
    
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
end
