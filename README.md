# IndicatorHub

IndicatorHub is a unified, clean, and idiomatic Ruby gem for technical analysis. It aggregates and optimizes the core math from multiple popular technical analysis gems into a single, high-performance, pure Ruby library.

## Key Features

- **Unified API**: Calculate SMA, EMA, RSI, MACD, and Bollinger Bands through a single entry point.
- **Data Agnostic**: Supports simple price arrays or complex OHLCV hash data.
- **Pure Ruby**: Zero dependencies by default (math implementations are self-contained).
- **Optional Performance**: Can optionally leverage `talib_ffi` for high-performance calculations if the C-library is available on the system.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'indicator_hub'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself:

```bash
$ gem install indicator_hub
```

## Usage Guide

IndicatorHub works in two common modes:

- Standalone Ruby scripts, services, and CLIs
- Rails applications using ActiveRecord models or service objects

The API accepts either:

- A simple numeric series like `[100.5, 101.2, 99.8]`
- An OHLCV series like `[{ timestamp:, open:, high:, low:, close:, volume: }]`

Most moving averages and momentum indicators work with a numeric series. Indicators that depend on high, low, or volume expect OHLCV hashes.

## Using In Standalone Ruby Apps

Install the gem:

```bash
gem install indicator_hub
```

Then require and use it:

```ruby
require "indicator_hub"

closes = [100.0, 101.5, 102.2, 101.8, 103.4, 104.1]

sma = IndicatorHub.sma(closes, period: 3)
ema = IndicatorHub.ema(closes, period: 3)
rsi = IndicatorHub.rsi(closes, period: 5)

puts sma.inspect
puts ema.inspect
puts rsi.inspect
```

Example with OHLCV candles:

```ruby
require "indicator_hub"

candles = [
  { timestamp: 1704067200, open: 100.0, high: 103.0, low: 99.0, close: 102.0, volume: 1200.0 },
  { timestamp: 1704153600, open: 102.0, high: 104.0, low: 101.0, close: 103.0, volume: 1500.0 },
  { timestamp: 1704240000, open: 103.0, high: 105.0, low: 100.0, close: 101.0, volume: 1700.0 }
]

atr = IndicatorHub.atr(candles, period: 2)
adx = IndicatorHub.adx(candles, period: 2)
vwap = IndicatorHub.vwap(candles)

puts atr.inspect
puts adx.inspect
puts vwap.inspect
```

## Using In Rails Apps

Add the gem to your `Gemfile`:

```ruby
gem "indicator_hub"
```

Then run:

```bash
bundle install
```

In Rails, you usually call IndicatorHub from:

- a model method
- a query/service object
- a background job
- a controller or API serializer

Example `PriceBar` model usage:

```ruby
# app/models/price_bar.rb
class PriceBar < ApplicationRecord
  scope :chronological, -> { order(:traded_at) }

  def self.to_indicator_series(limit: 200)
    chronological.limit(limit).map do |bar|
      {
        timestamp: bar.traded_at.to_i,
        open: bar.open,
        high: bar.high,
        low: bar.low,
        close: bar.close,
        volume: bar.volume
      }
    end
  end
end
```

Example service object:

```ruby
# app/services/indicator_snapshot.rb
class IndicatorSnapshot
  def initialize(scope = PriceBar.all)
    @scope = scope
  end

  def call(limit: 200)
    candles = @scope.order(:traded_at).limit(limit).map do |bar|
      {
        open: bar.open,
        high: bar.high,
        low: bar.low,
        close: bar.close,
        volume: bar.volume
      }
    end

    {
      sma_20: IndicatorHub.sma(candles, period: 20, field: :close).last,
      ema_20: IndicatorHub.ema(candles, period: 20, field: :close).last,
      rsi_14: IndicatorHub.rsi(candles, period: 14, field: :close).last,
      macd: IndicatorHub.macd(candles).last,
      atr_14: IndicatorHub.atr(candles, period: 14).last
    }
  end
end
```

Example from Rails console:

```ruby
bars = PriceBar.order(:traded_at).last(100).map do |bar|
  {
    open: bar.open,
    high: bar.high,
    low: bar.low,
    close: bar.close,
    volume: bar.volume
  }
end

IndicatorHub.bb(bars, period: 20, field: :close).last
IndicatorHub.macd(bars, field: :close).last
IndicatorHub.vwap(bars).last
```

## Data Formats

### Numeric Series

Use this for indicators based on one field, usually close:

```ruby
closes = [100.0, 101.2, 102.8, 103.1]

IndicatorHub.sma(closes, period: 3)
IndicatorHub.ema(closes, period: 3)
IndicatorHub.rsi(closes, period: 14)
IndicatorHub.macd(closes)
```

### Hash Series With `field:`

If you already have hashes and want a single-field indicator:

```ruby
rows = [
  { open: 100.0, close: 101.0 },
  { open: 101.0, close: 103.0 },
  { open: 103.0, close: 102.0 }
]

IndicatorHub.sma(rows, period: 2, field: :close)
IndicatorHub.ema(rows, period: 2, field: :open)
```

### OHLCV Series

Use this for indicators that need candle ranges or volume:

```ruby
rows = [
  { timestamp: 1704067200, open: 100.0, high: 103.0, low: 99.0, close: 101.0, volume: 1000.0 },
  { timestamp: 1704153600, open: 101.0, high: 104.0, low: 100.0, close: 103.0, volume: 1200.0 }
]

IndicatorHub.atr(rows, period: 14)
IndicatorHub.adx(rows, period: 14)
IndicatorHub.mfi(rows, period: 14)
IndicatorHub.vwap(rows)
```

`timestamp` is recommended for real market data feeds. The indicator methods only use OHLCV values for calculations, so extra keys like `timestamp`, `symbol`, or `open_interest` are safe to keep in your source payloads.

## Provider Payload Examples

### Delta Exchange Response

The `delta_exchange` gem returns the parsed API response envelope from `/v2/history/candles`. In practice, you extract `result` and normalize `time` to `timestamp` if you want a consistent candle shape in your app:

```ruby
payload = {
  "success" => true,
  "result" => [
    {
      "time" => 1704067200,
      "open" => 100.0,
      "high" => 103.0,
      "low" => 99.0,
      "close" => 101.0,
      "volume" => 1200.0
    }
  ]
}

candles = payload["result"].map do |row|
  {
    timestamp: row["time"],
    open: row["open"],
    high: row["high"],
    low: row["low"],
    close: row["close"],
    volume: row["volume"]
  }
end

IndicatorHub.atr(candles, period: 14)
IndicatorHub.rsi(candles, period: 14, field: :close)
```

### DhanHQ Client Response

The `dhanhq-client` gem already normalizes historical responses into an array of candle hashes in `DhanHQ::Models::HistoricalData.daily` and `DhanHQ::Models::HistoricalData.intraday`.

```ruby
candles = DhanHQ::Models::HistoricalData.intraday(
  security_id: "13",
  exchange_segment: DhanHQ::Constants::ExchangeSegment::IDX_I,
  instrument: DhanHQ::Constants::InstrumentType::INDEX,
  interval: "5",
  from_date: "2024-08-14",
  to_date: "2024-08-14"
)

# candles.first
# => {
#      timestamp: 2024-08-14 09:15:00 +0530,
#      open: 3750.0,
#      high: 3757.9,
#      low: 3746.1,
#      close: 3751.25,
#      volume: 53629
#    }

IndicatorHub.macd(candles, field: :close)
IndicatorHub.vwap(candles)
IndicatorHub.obv(candles)
```

If you are working with Dhan's raw API payload before `dhanhq-client` normalizes it, then yes, you would first zip the parallel arrays into candle hashes.

### Normalizing In One Helper

For app code, it is usually better to normalize provider responses in one place:

```ruby
module CandleNormalizer
  module_function

  def from_delta(payload)
    payload.fetch("result", []).map do |row|
      {
        timestamp: row["time"],
        open: row["open"],
        high: row["high"],
        low: row["low"],
        close: row["close"],
        volume: row["volume"]
      }
    end
  end

  def from_dhanhq(payload)
    payload.fetch("close", []).each_index.map do |i|
      {
        timestamp: payload["timestamp"][i],
        open: payload["open"][i],
        high: payload["high"][i],
        low: payload["low"][i],
        close: payload["close"][i],
        volume: payload["volume"][i]
      }
    end
  end
end
```

## Warm-Up Values And `nil` Results

Most indicators need a minimum lookback window before they can return a value. Because of that, the first values are often `nil`.

Example:

```ruby
IndicatorHub.sma([1, 2, 3, 4, 5], period: 3)
# => [nil, nil, 2.0, 3.0, 4.0]
```

In Rails or reporting code, it is common to use the latest non-`nil` value:

```ruby
latest_rsi = IndicatorHub.rsi(closes, period: 14).compact.last
```

## Common Patterns

Latest value only:

```ruby
latest_ema = IndicatorHub.ema(closes, period: 20).compact.last
```

Latest MACD snapshot:

```ruby
latest_macd = IndicatorHub.macd(closes).last
# => { macd:, signal:, histogram: }
```

Multiple indicators from the same candle set:

```ruby
indicators = {
  sma_20: IndicatorHub.sma(candles, period: 20, field: :close).last,
  rsi_14: IndicatorHub.rsi(candles, period: 14, field: :close).last,
  atr_14: IndicatorHub.atr(candles, period: 14).last,
  obv: IndicatorHub.obv(candles).last
}
```

## Tips For Production Use

- Always sort your data chronologically before calculating indicators.
- Pass enough history for the indicator lookback plus warm-up.
- Use `field: :close` explicitly when your source objects contain multiple price fields.
- For API responses, prefer returning the latest computed point instead of the full series unless you need charting data.
- VWAP in this gem is cumulative over the provided dataset, so if you need session-based VWAP, pass one session at a time.

## API Reference By Indicator Category

### Single-Series Indicators

These work with:

- numeric arrays like `[100.0, 101.2, 102.4]`
- hash arrays with `field:` like `[{ close: 100.0 }, { close: 101.2 }]`

Methods:

- `IndicatorHub.sma(data, period: 20, field: :close)`
- `IndicatorHub.ema(data, period: 20, field: :close)`
- `IndicatorHub.wma(data, period: 20, field: :close)`
- `IndicatorHub.rsi(data, period: 14, field: :close)`
- `IndicatorHub.cmo(data, period: 14, field: :close)`
- `IndicatorHub.dlr(data, field: :close)`
- `IndicatorHub.dpo(data, period: 20, field: :close)`
- `IndicatorHub.dr(data, field: :close)`
- `IndicatorHub.roc(data, period: 12, field: :close)`
- `IndicatorHub.trix(data, period: 15, field: :close)`
- `IndicatorHub.tsi(data, fast_period: 13, slow_period: 25, field: :close)`
- `IndicatorHub.wilders_smoothing(data, period: 14, field: :close)`
- `IndicatorHub.cr(data, period: 20, field: :close)`
- `IndicatorHub.envelopes_ema(data, period: 20, percentage: 2.5, field: :close)`
- `IndicatorHub.macd(data, fast_period: 12, slow_period: 26, signal_period: 9, field: :close)`
- `IndicatorHub.rmi(data, period: 14, momentum_period: 5)`

### OHLCV Indicators

These expect candle hashes with `open`, `high`, `low`, `close`, and optionally `volume` where required:

```ruby
[
  { open: 100.0, high: 103.0, low: 99.0, close: 101.0, volume: 1200.0 }
]
```

Methods:

- `IndicatorHub.adi(data)`
- `IndicatorHub.adtv(data, period: 20)`
- `IndicatorHub.adx(data, period: 14)`
- `IndicatorHub.ao(data, short_period: 5, long_period: 34)`
- `IndicatorHub.atr(data, period: 14)`
- `IndicatorHub.cci(data, period: 20)`
- `IndicatorHub.cmf(data, period: 20)`
- `IndicatorHub.dc(data, period: 20)`
- `IndicatorHub.eom(data, period: 14)`
- `IndicatorHub.fi(data, period: 13)`
- `IndicatorHub.ichimoku(data, low_period: 9, medium_period: 26, high_period: 52)`
- `IndicatorHub.imi(data, period: 14)`
- `IndicatorHub.kc(data, period: 20, multiplier: 1.5)`
- `IndicatorHub.mfi(data, period: 14)`
- `IndicatorHub.mi(data, period: 25)`
- `IndicatorHub.nvi(data)`
- `IndicatorHub.obv(data)`
- `IndicatorHub.obv_mean(data, period: 10)`
- `IndicatorHub.pivot_points(data)`
- `IndicatorHub.price_channel(data, period: 20)`
- `IndicatorHub.qstick(data, period: 10)`
- `IndicatorHub.so(data, k_period: 14, k_slowing: 3, d_period: 3)`
- `IndicatorHub.uo(data, short_period: 7, medium_period: 14, long_period: 28)`
- `IndicatorHub.vi(data, period: 14)`
- `IndicatorHub.volume_oscillator(data, short_period: 20, long_period: 60)`
- `IndicatorHub.vpt(data)`
- `IndicatorHub.vwap(data)`
- `IndicatorHub.wr(data, period: 14)`

### Indicators Returning Hashes

These return structured values instead of a plain numeric series:

- `IndicatorHub.bb` returns `{ upper:, middle:, lower: }`
- `IndicatorHub.macd` returns `{ macd:, signal:, histogram: }`
- `IndicatorHub.dc` returns `{ upper:, middle:, lower: }`
- `IndicatorHub.envelopes_ema` returns `{ upper:, middle:, lower: }`
- `IndicatorHub.ichimoku` returns `{ tenkan_sen:, kijun_sen:, senkou_span_a:, senkou_span_b:, chikou_span: }`
- `IndicatorHub.kc` returns `{ upper:, middle:, lower: }`
- `IndicatorHub.kst` returns `{ kst:, signal: }`
- `IndicatorHub.pivot_points` returns `{ p:, s1:, s2:, s3:, r1:, r2:, r3: }`
- `IndicatorHub.price_channel` returns `{ upper:, lower: }`
- `IndicatorHub.so` returns `{ k:, d: }`
- `IndicatorHub.vi` returns `{ plus_vi:, minus_vi: }`

## Basic Examples

```ruby
require 'indicator_hub'

data = [10.0, 11.0, 12.0, 13.0, 14.0, 15.0]

# Simple Moving Average
sma = IndicatorHub.sma(data, period: 5)
# => [nil, nil, nil, nil, 12.0, 13.0]

# Relative Strength Index
rsi = IndicatorHub.rsi(data, period: 5)
```

OHLCV data:

```ruby
data = [
  { timestamp: 1704067200, open: 10, high: 12, low: 9, close: 11, volume: 1000 },
  { timestamp: 1704153600, open: 11, high: 13, low: 10, close: 12, volume: 1200 },
  # ...
]

# Calculate SMA on the 'close' field
sma = IndicatorHub.sma(data, period: 2, field: :close)

# Calculate ATR from OHLCV candles
atr = IndicatorHub.atr(data, period: 14)
```

### Supported Indicators

- `IndicatorHub.sma(data, period: 20)`
- `IndicatorHub.ema(data, period: 20)`
- `IndicatorHub.rsi(data, period: 14)`
- `IndicatorHub.macd(data, fast_period: 12, slow_period: 26, signal_period: 9)`
- `IndicatorHub.bb(data, period: 20, standard_deviations: 2)`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shubhamtaywade/indicator_hub.

## Release Process

CI:

- GitHub Actions runs on `main`, `master`, and pull requests
- The CI workflow tests Ruby `3.2.0` and `3.3.4`
- Each CI run executes `bundle exec rake` and verifies the gem builds successfully

CD:

- Releases are triggered by pushing a tag like `v0.1.0`
- The release workflow validates that the tag matches `IndicatorHub::VERSION`
- It runs the full test/lint suite, builds the gem, and publishes to RubyGems

Required GitHub Actions secrets:

- `RUBYGEMS_API_KEY`
- `RUBYGEMS_OTP_SECRET`

Typical release steps:

```bash
# 1. Update version
# lib/indicator_hub/version.rb

# 2. Update changelog
# CHANGELOG.md

# 3. Commit changes
git add .
git commit -m "Release v0.1.0"

# 4. Create and push tag
git tag v0.1.0
git push origin main --tags
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
