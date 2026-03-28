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

## Usage

### Simple Price Array

```ruby
require 'indicator_hub'

data = [10.0, 11.0, 12.0, 13.0, 14.0, 15.0]

# Simple Moving Average
sma = IndicatorHub.sma(data, period: 5)
# => [nil, nil, nil, nil, 12.0, 13.0]

# Relative Strength Index
rsi = IndicatorHub.rsi(data, period: 5)
```

### OHLCV Data (Hashes)

```ruby
data = [
  { date: "2023-01-01", open: 10, high: 12, low: 9, close: 11 },
  { date: "2023-01-02", open: 11, high: 13, low: 10, close: 12 },
  # ...
]

# Calculate SMA on the 'close' field
sma = IndicatorHub.sma(data, period: 2, field: :close)
```

### Supported Indicators

- `IndicatorHub.sma(data, period: 20)`
- `IndicatorHub.ema(data, period: 20)`
- `IndicatorHub.rsi(data, period: 14)`
- `IndicatorHub.macd(data, fast_period: 12, slow_period: 26, signal_period: 9)`
- `IndicatorHub.bb(data, period: 20, standard_deviations: 2)`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shubhamtaywade/indicator_hub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
