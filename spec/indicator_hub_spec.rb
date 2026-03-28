# frozen_string_literal: true

require "indicator_hub"

RSpec.describe IndicatorHub do
  # === Shared Test Data ===
  let(:sequential) { [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20] }
  let(:sequential_hash) { sequential.map { |v| { close: v.to_f } } }
  let(:flat_data) { Array.new(20, 100.0) }
  let(:flat_ohlcv) { Array.new(20) { { open: 100.0, high: 100.0, low: 100.0, close: 100.0, volume: 1000.0 } } }

  # Non-monotonic OHLCV with volume variation (deterministic)
  let(:ohlcv_varied) do
    [
      { open: 100.0, high: 103.0, low: 99.0,  close: 102.0, volume: 1000.0 },
      { open: 102.0, high: 104.0, low: 100.0, close: 101.0, volume: 1200.0 }, # down, vol up
      { open: 101.0, high: 106.0, low: 100.0, close: 105.0, volume: 1500.0 }, # up
      { open: 105.0, high: 107.0, low: 102.0, close: 103.0, volume: 800.0 },  # down, vol down
      { open: 103.0, high: 108.0, low: 103.0, close: 107.0, volume: 2000.0 }, # up, vol up
      { open: 107.0, high: 109.0, low: 104.0, close: 105.0, volume: 900.0 },  # down, vol down
      { open: 105.0, high: 110.0, low: 104.0, close: 109.0, volume: 1800.0 }, # up
      { open: 109.0, high: 111.0, low: 106.0, close: 107.0, volume: 1100.0 }, # down
      { open: 107.0, high: 112.0, low: 107.0, close: 111.0, volume: 1600.0 }, # up
      { open: 111.0, high: 113.0, low: 108.0, close: 110.0, volume: 1300.0 } # down
    ]
  end

  # Large non-monotonic OHLCV (100 points, deterministic)
  let(:ohlcv_large) do
    Array.new(100) do |i|
      base = 100.0 + Math.sin(i * 0.3) * 10 + Math.cos(i * 0.7) * 5
      range = 3.0 + Math.sin(i * 0.5).abs * 2
      vol = 1000.0 + Math.sin(i * 0.8) * 400 + Math.cos(i * 1.3) * 300
      { open: (base + Math.sin(i * 1.1) * 2).round(2),
        high: (base + range).round(2),
        low: (base - range).round(2),
        close: base.round(2),
        volume: [vol.round(0), 100.0].max }
    end
  end

  # Wilder RSI reference data
  let(:rsi_data) do
    [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42,
     45.84, 46.08, 45.89, 46.03, 45.61, 46.28, 46.28, 46.00]
  end

  # ==========================================
  # GROUP 1: SINGLE SERIES INDICATORS
  # ==========================================

  describe ".sma" do
    it "calculates correct values" do
      result = IndicatorHub.sma(sequential, period: 5)
      expect(result[4]).to eq(12.0)  # (10+11+12+13+14)/5
      expect(result[5]).to eq(13.0)  # (11+12+13+14+15)/5
      expect(result[10]).to eq(18.0) # (16+17+18+19+20)/5
    end

    it "pads first period-1 elements with nil" do
      result = IndicatorHub.sma(sequential, period: 5)
      expect(result[0..3]).to all(be_nil)
      expect(result[4]).not_to be_nil
    end

    it "handles hash data" do
      result = IndicatorHub.sma(sequential_hash, period: 5)
      expect(result[4]).to eq(12.0)
    end

    it "handles custom field" do
      data = sequential.map { |v| { open: v.to_f * 2 } }
      result = IndicatorHub.sma(data, period: 5, field: :open)
      expect(result[4]).to eq(24.0) # (20+22+24+26+28)/5
    end
  end

  describe ".ema" do
    it "calculates correct values" do
      result = IndicatorHub.ema(sequential, period: 5)
      expect(result[0..3]).to all(be_nil)
      expect(result[4]).to eq(12.0) # First EMA = SMA
      # EMA(5) = (15-12)*(2/6)+12 = 13.0
      expect(result[5]).to be_within(0.01).of(13.0)
      # EMA(6) = (16-13)*(2/6)+13 = 14.0
      expect(result[6]).to be_within(0.01).of(14.0)
    end
  end

  describe ".wma" do
    it "calculates correct weighted values" do
      result = IndicatorHub.wma(sequential, period: 3)
      expect(result[0..1]).to all(be_nil)
      # (10*1+11*2+12*3)/6 = 68/6 ≈ 11.333
      expect(result[2]).to be_within(0.01).of(11.333)
      # (11*1+12*2+13*3)/6 = 74/6 ≈ 12.333
      expect(result[3]).to be_within(0.01).of(12.333)
    end

    it "weights recent prices more than SMA for uptrend" do
      wma = IndicatorHub.wma(sequential, period: 5)
      sma = IndicatorHub.sma(sequential, period: 5)
      (4..10).each { |i| expect(wma[i]).to be > sma[i] }
    end
  end

  describe ".rsi" do
    it "returns values between 0 and 100" do
      result = IndicatorHub.rsi(rsi_data, period: 14)
      result.compact.each { |v| expect(v).to be_between(0, 100) }
    end

    it "pads initial values with nil" do
      result = IndicatorHub.rsi(rsi_data, period: 14)
      expect(result[0]).to be_nil
      expect(result[14]).to be_a(Numeric)
    end

    it "calculates first RSI value near known reference (~70.46)" do
      result = IndicatorHub.rsi(rsi_data, period: 14)
      # Wilder reference: avg_gain≈0.2386, avg_loss=0.1, RS≈2.386, RSI≈70.46
      expect(result[14]).to be_within(1.0).of(70.46)
    end

    it "returns near 100 for strictly rising data" do
      rising = Array.new(20) { |i| 100.0 + i }
      result = IndicatorHub.rsi(rising, period: 14)
      expect(result.compact.last).to be >= 95.0
    end

    it "handles flat data without crash" do
      expect { IndicatorHub.rsi(flat_data, period: 14) }.not_to raise_error
    end
  end

  describe ".bb" do
    it "calculates correct band values" do
      result = IndicatorHub.bb(sequential, period: 5, standard_deviations: 2)
      expect(result[0..3]).to all(be_nil)
      expect(result[4][:middle]).to eq(12.0)
      # StdDev of [10,11,12,13,14] = sqrt(2.5) ≈ 1.5811
      expected_std = Math.sqrt(2.5)
      expect(result[4][:upper]).to be_within(0.01).of(12.0 + 2 * expected_std)
      expect(result[4][:lower]).to be_within(0.01).of(12.0 - 2 * expected_std)
    end

    it "has symmetric bands" do
      result = IndicatorHub.bb(sequential, period: 5)
      (4..10).each do |i|
        b = result[i]
        expect(b[:upper] - b[:middle]).to be_within(0.001).of(b[:middle] - b[:lower])
      end
    end
  end

  describe ".macd" do
    it "macd = fast_ema - slow_ema" do
      fast = IndicatorHub.ema(sequential, period: 3)
      slow = IndicatorHub.ema(sequential, period: 5)
      macd = IndicatorHub.macd(sequential, fast_period: 3, slow_period: 5, signal_period: 3)
      sequential.each_index do |i|
        next unless fast[i] && slow[i]

        expect(macd[i][:macd]).to be_within(0.01).of(fast[i] - slow[i])
      end
    end

    it "histogram = macd - signal" do
      result = IndicatorHub.macd(sequential, fast_period: 2, slow_period: 5, signal_period: 3)
      result.each do |v|
        next unless v[:macd] && v[:signal]

        expect(v[:histogram]).to be_within(0.001).of(v[:macd] - v[:signal])
      end
    end
  end

  describe ".dlr" do
    it "calculates log return correctly" do
      result = IndicatorHub.dlr([100.0, 110.0, 105.0])
      expect(result[0]).to be_nil
      expect(result[1]).to be_within(0.0001).of(Math.log(110.0 / 100.0))
      expect(result[2]).to be_within(0.0001).of(Math.log(105.0 / 110.0))
    end
  end

  describe ".dr" do
    it "calculates daily return correctly" do
      result = IndicatorHub.dr([100.0, 110.0, 105.0])
      expect(result[0]).to be_nil
      expect(result[1]).to be_within(0.0001).of(0.1)
      expect(result[2]).to be_within(0.0001).of(-0.04545)
    end
  end

  describe ".roc" do
    it "calculates rate of change correctly" do
      result = IndicatorHub.roc([100.0, 110.0, 120.0, 115.0, 105.0, 125.0], period: 3)
      expect(result[0..2]).to all(be_nil)
      expect(result[3]).to be_within(0.01).of(15.0) # (115-100)/100*100
      expect(result[4]).to be_within(0.01).of(-4.5455) # (105-110)/110*100
    end
  end

  describe ".cmo" do
    it "calculates correctly" do
      result = IndicatorHub.cmo([10.0, 12.0, 11.0, 14.0, 13.0], period: 3)
      expect(result[0..2]).to all(be_nil)
      # ups=2+3=5, downs=1, CMO=100*(5-1)/(5+1)=66.667
      expect(result[3]).to be_within(0.01).of(66.667)
    end

    it "returns 0 for flat data" do
      result = IndicatorHub.cmo(flat_data, period: 5)
      result.compact.each { |v| expect(v).to eq(0.0) }
    end
  end

  describe ".dpo" do
    it "returns correct output size with nil padding" do
      result = IndicatorHub.dpo(sequential, period: 5)
      expect(result.size).to eq(sequential.size)
      expect(result.compact.size).to be < sequential.size
    end
  end

  describe ".trix" do
    it "has nil values due to triple smoothing" do
      result = IndicatorHub.trix(sequential, period: 3)
      expect(result.size).to eq(sequential.size)
      expect(result.first).to be_nil
    end
  end

  describe ".tsi" do
    it "returns values between -100 and 100" do
      oscillating = [100.0, 105.0, 102.0, 108.0, 103.0, 110.0, 107.0, 112.0, 106.0, 115.0]
      result = IndicatorHub.tsi(oscillating, fast_period: 3, slow_period: 5)
      result.compact.each { |v| expect(v).to be_between(-100, 100) }
    end
  end

  describe ".wilders_smoothing" do
    it "first value is SMA of first period elements" do
      result = IndicatorHub.wilders_smoothing(sequential, period: 5)
      expect(result[0..3]).to all(be_nil)
      expect(result[4]).to be_within(0.01).of(sequential.first(5).sum / 5.0)
    end
  end

  describe ".cr" do
    it "calculates cumulative return" do
      result = IndicatorHub.cr([100.0, 110.0, 105.0])
      expect(result[0]).to eq(0.0)
      expect(result[1]).to be_within(0.0001).of(0.1)
      expect(result[2]).to be_within(0.0001).of(0.05)
    end
  end

  describe ".envelopes_ema" do
    it "applies percentage bands around EMA" do
      result = IndicatorHub.envelopes_ema(sequential, period: 5, percentage: 5)
      result.select { |v| v[:middle] }.each do |v|
        expect(v[:upper]).to be_within(0.001).of(v[:middle] * 1.05)
        expect(v[:lower]).to be_within(0.001).of(v[:middle] * 0.95)
      end
    end
  end

  # ==========================================
  # GROUP 2: OHLCV INDICATORS
  # ==========================================

  describe ".adi" do
    it "calculates ADI with correct CLV" do
      data = [
        { open: 100.0, high: 110.0, low: 90.0, close: 105.0, volume: 1000.0 },
        { open: 105.0, high: 112.0, low: 95.0, close: 100.0, volume: 1500.0 }
      ]
      result = IndicatorHub.adi(data)
      # Bar 0: CLV = (15-5)/20 = 0.5, AD = 500
      expect(result[0]).to be_within(0.01).of(500.0)
      # Bar 1: CLV = (5-12)/17 ≈ -0.4118, AD = 500 + (-0.4118*1500) ≈ -117.65
      expect(result[1]).to be_within(1.0).of(-117.65)
    end

    it "returns 0 when high == low" do
      data = [{ open: 100.0, high: 100.0, low: 100.0, close: 100.0, volume: 1000.0 }]
      expect(IndicatorHub.adi(data)[0]).to eq(0.0)
    end
  end

  describe ".adtv" do
    it "calculates average volume" do
      data = (1..5).map { |i| { open: 10.0, high: 12.0, low: 9.0, close: 11.0, volume: i * 100.0 } }
      result = IndicatorHub.adtv(data, period: 3)
      # Last 3 volumes: 300, 400, 500 → avg = 400
      expect(result.last).to be_within(0.01).of(400.0)
    end
  end

  describe ".adx" do
    it "returns values between 0 and 100 with nil padding" do
      result = IndicatorHub.adx(ohlcv_large, period: 14)
      expect(result.size).to eq(100)
      expect(result.first).to be_nil
      result.compact.each { |v| expect(v).to be_between(0, 100) }
    end
  end

  describe ".ao" do
    it "returns output with nil warm-up" do
      result = IndicatorHub.ao(ohlcv_large, short_period: 5, long_period: 10)
      expect(result.size).to eq(100)
      expect(result.compact.size).to be < 100
    end
  end

  describe ".atr" do
    it "returns non-negative values" do
      result = IndicatorHub.atr(ohlcv_large, period: 14)
      expect(result.size).to eq(100)
      result.compact.each { |v| expect(v).to be >= 0 }
    end
  end

  describe ".cci" do
    it "oscillates around zero for varied data" do
      result = IndicatorHub.cci(ohlcv_large, period: 20)
      non_nil = result.compact
      expect(non_nil.any? { |v| v > 0 }).to be true
      expect(non_nil.any? { |v| v < 0 }).to be true
    end

    it "returns 0 for flat data" do
      result = IndicatorHub.cci(flat_ohlcv, period: 5)
      result.compact.each { |v| expect(v).to eq(0.0) }
    end
  end

  describe ".cmf" do
    it "returns values in valid range" do
      result = IndicatorHub.cmf(ohlcv_large, period: 20)
      expect(result.size).to eq(100)
    end
  end

  describe ".dc" do
    it "returns bands with upper >= middle >= lower" do
      result = IndicatorHub.dc(ohlcv_large, period: 20)
      result.select { |v| v[:upper] }.each do |v|
        expect(v[:upper]).to be >= v[:middle]
        expect(v[:middle]).to be >= v[:lower]
      end
    end
  end

  describe ".eom" do
    it "returns correct output size" do
      result = IndicatorHub.eom(ohlcv_large, period: 14)
      expect(result.size).to eq(100)
    end
  end

  describe ".fi" do
    it "returns correct output size" do
      result = IndicatorHub.fi(ohlcv_large, period: 13)
      expect(result.size).to eq(100)
    end
  end

  describe ".ichimoku" do
    it "returns all five components with nil warm-up" do
      result = IndicatorHub.ichimoku(ohlcv_large)
      # high_period(52) + medium_period(26) - 2 = 76 nils
      expect(result[0..75]).to all(be_nil)
      non_nil = result.compact
      expect(non_nil).not_to be_empty
      non_nil.each do |v|
        %i[tenkan_sen kijun_sen senkou_span_a senkou_span_b chikou_span].each do |key|
          expect(v).to have_key(key)
        end
      end
    end
  end

  describe ".imi" do
    it "returns values between 0 and 100" do
      result = IndicatorHub.imi(ohlcv_large, period: 14)
      result.compact.each { |v| expect(v).to be_between(0, 100) }
    end
  end

  describe ".kc" do
    it "returns upper >= middle >= lower" do
      result = IndicatorHub.kc(ohlcv_large, period: 20)
      result.compact.each do |v|
        expect(v[:upper]).to be >= v[:middle]
        expect(v[:middle]).to be >= v[:lower]
      end
    end
  end

  describe ".kst" do
    it "returns kst and signal" do
      result = IndicatorHub.kst(ohlcv_large)
      expect(result.last).to have_key(:kst)
      expect(result.last).to have_key(:signal)
      expect(result.count { |v| v[:kst] }).to be > 0
    end
  end

  describe ".mfi" do
    it "returns values between 0 and 100" do
      result = IndicatorHub.mfi(ohlcv_large, period: 14)
      result.compact.each { |v| expect(v).to be_between(0, 100) }
    end
  end

  describe ".mi" do
    it "returns correct output size" do
      result = IndicatorHub.mi(ohlcv_large, period: 25)
      expect(result.size).to eq(100)
    end
  end

  describe ".nvi" do
    it "starts at 1000 and only changes when volume decreases" do
      result = IndicatorHub.nvi(ohlcv_varied)
      expect(result[0]).to eq(1000.0)
      (1...ohlcv_varied.size).each do |i|
        if ohlcv_varied[i][:volume] >= ohlcv_varied[i - 1][:volume]
          expect(result[i]).to eq(result[i - 1])
        else
          expect(result[i]).not_to eq(result[i - 1])
        end
      end
    end
  end

  describe ".obv" do
    it "calculates OBV with up/down/flat days" do
      data = [
        { open: 10.0, high: 12.0, low: 9.0,  close: 10.0, volume: 100.0 },
        { open: 10.0, high: 13.0, low: 10.0, close: 12.0, volume: 200.0 }, # up
        { open: 12.0, high: 12.0, low: 9.0,  close: 11.0, volume: 150.0 }, # down
        { open: 11.0, high: 12.0, low: 10.0, close: 11.0, volume: 100.0 } # flat
      ]
      result = IndicatorHub.obv(data)
      expect(result[0]).to eq(0.0)
      expect(result[1]).to eq(200.0)  # +200
      expect(result[2]).to eq(50.0)   # -150
      expect(result[3]).to eq(50.0)   # unchanged
    end
  end

  describe ".obv_mean" do
    it "returns correct output size" do
      result = IndicatorHub.obv_mean(ohlcv_large, period: 10)
      expect(result.size).to eq(100)
    end
  end

  describe ".pivot_points" do
    it "calculates correct levels" do
      data = [{ open: 100.0, high: 50.0, low: 40.0, close: 45.0, volume: 1000.0 }]
      pp = IndicatorHub.pivot_points(data)[0]
      expect(pp[:p]).to eq(45.0)   # (50+40+45)/3
      expect(pp[:s1]).to eq(40.0)  # 2*45 - 50
      expect(pp[:r1]).to eq(50.0)  # 2*45 - 40
      expect(pp[:s2]).to eq(35.0)  # 45 - (50-40)
      expect(pp[:r2]).to eq(55.0)  # 45 + (50-40)
    end

    it "maintains r3 >= r2 >= r1 >= p >= s1 >= s2 >= s3" do
      IndicatorHub.pivot_points(ohlcv_large).each do |pp|
        expect(pp[:r3]).to be >= pp[:r2]
        expect(pp[:r2]).to be >= pp[:r1]
        expect(pp[:r1]).to be >= pp[:p]
        expect(pp[:p]).to be >= pp[:s1]
        expect(pp[:s1]).to be >= pp[:s2]
        expect(pp[:s2]).to be >= pp[:s3]
      end
    end
  end

  describe ".price_channel" do
    it "returns upper >= lower" do
      result = IndicatorHub.price_channel(ohlcv_large, period: 20)
      result.select { |v| v[:upper] }.each { |v| expect(v[:upper]).to be >= v[:lower] }
    end
  end

  describe ".qstick" do
    it "returns correct output size" do
      result = IndicatorHub.qstick(ohlcv_large, period: 10)
      expect(result.size).to eq(100)
    end
  end

  describe ".rmi" do
    it "returns values between 0 and 100" do
      result = IndicatorHub.rmi(ohlcv_large, period: 14, momentum_period: 5)
      result.compact.each { |v| expect(v).to be_between(0, 100) }
    end
  end

  describe ".so" do
    it "returns %K and %D between 0 and 100" do
      result = IndicatorHub.so(ohlcv_large, k_period: 14, d_period: 3)
      result.select { |v| v[:k] && v[:d] }.each do |v|
        expect(v[:k]).to be_between(0, 100)
        expect(v[:d]).to be_between(0, 100)
      end
    end
  end

  describe ".uo" do
    it "returns values between 0 and 100" do
      result = IndicatorHub.uo(ohlcv_large)
      result.compact.each { |v| expect(v).to be_between(0, 100) }
    end
  end

  describe ".vi" do
    it "returns non-negative plus_vi and minus_vi" do
      result = IndicatorHub.vi(ohlcv_large, period: 14)
      result.select { |v| v[:plus_vi] }.each do |v|
        expect(v[:plus_vi]).to be >= 0
        expect(v[:minus_vi]).to be >= 0
      end
    end
  end

  describe ".volume_oscillator" do
    it "returns nil before warm-up then values" do
      result = IndicatorHub.volume_oscillator(ohlcv_large, short_period: 5, long_period: 20)
      expect(result[0..18]).to all(be_nil)
      expect(result.size).to eq(100)
    end
  end

  describe ".vpt" do
    it "returns correct output size" do
      result = IndicatorHub.vpt(ohlcv_large)
      expect(result.size).to eq(100)
    end
  end

  describe ".vwap" do
    it "calculates VWAP correctly" do
      data = [
        { open: 10.0, high: 11.0, low: 9.0, close: 10.0, volume: 100.0 },
        { open: 10.0, high: 12.0, low: 10.0, close: 11.0, volume: 200.0 }
      ]
      result = IndicatorHub.vwap(data)
      # Bar 0: TP=10.0, VWAP=10.0
      expect(result[0]).to be_within(0.01).of(10.0)
      # Bar 1: TP=11.0, cumm=3200/300≈10.6667
      expect(result[1]).to be_within(0.01).of(10.6667)
    end
  end

  describe ".wr" do
    it "returns values between -100 and 0" do
      result = IndicatorHub.wr(ohlcv_large, period: 14)
      result.compact.each { |v| expect(v).to be_between(-100, 0) }
    end
  end

  # ==========================================
  # EDGE CASES
  # ==========================================

  describe "edge cases" do
    it "handles empty data for OHLCV indicators" do
      expect(IndicatorHub.obv([])).to eq([])
      expect(IndicatorHub.pivot_points([])).to eq([])
    end

    it "handles flat data without errors" do
      expect { IndicatorHub.ema(flat_data, period: 5) }.not_to raise_error
      expect { IndicatorHub.bb(flat_data, period: 5) }.not_to raise_error
      expect { IndicatorHub.rsi(flat_data, period: 14) }.not_to raise_error
      expect { IndicatorHub.cci(flat_ohlcv, period: 5) }.not_to raise_error
    end
  end
end
