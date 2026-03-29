# frozen_string_literal: true

require "date"
require "indicator_hub"

module RealisticFixtureReference # rubocop:disable Metrics/ModuleLength
  module_function

  def market_data(length = 140)
    prev_close = 100.0
    start_date = Date.new(2024, 1, 2)

    Array.new(length) do |i|
      regime_drift =
        case i
        when 0...35 then 0.35
        when 35...70 then -0.18
        when 70...105 then 0.42
        else -0.08
        end

      gap = if (i % 17).zero?
              ((i / 17).odd? ? -1.35 : 1.6)
            else
              Math.sin(i * 0.21) * 0.45
            end

      intraday_move = regime_drift + (Math.sin(i * 0.37) * 1.1) + (Math.cos(i * 0.11) * 0.4)
      open = (prev_close + gap).round(4)
      close = (open + intraday_move).round(4)
      high = ([open, close].max + 0.8 + (Math.sin(i * 0.19).abs * 1.3)).round(4)
      low = ([open, close].min - 0.75 - (Math.cos(i * 0.23).abs * 1.1)).round(4)
      volume = (900_000 + (Math.sin(i * 0.41) * 250_000) + (Math.cos(i * 0.17) * 180_000) + ((i % 29).zero? ? 600_000 : 0)).round
      volume = [volume, 50_000].max.to_f

      prev_close = close

      {
        date: (start_date + i).iso8601,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      }
    end
  end

  def closes(data)
    data.map { |v| v[:close] }
  end

  def average(values)
    return 0.0 if values.empty?

    values.sum(0.0) / values.length.to_f
  end

  def sample_stddev(values)
    return 0.0 if values.length <= 1

    mean = average(values)
    variance = values.sum(0.0) { |v| (v - mean)**2 } / (values.length - 1).to_f
    Math.sqrt(variance)
  end

  def mean_absolute_deviation(values, mean)
    return 0.0 if values.empty?

    values.sum(0.0) { |v| (v - mean).abs } / values.length.to_f
  end

  def wilder_smoothing(prev_avg, current, period)
    ((prev_avg * (period - 1)) + current) / period.to_f
  end

  def true_range(high, low, prev_close)
    [
      high - low,
      (high - prev_close).abs,
      (low - prev_close).abs
    ].max.to_f
  end

  def typical_price(bar)
    (bar[:high] + bar[:low] + bar[:close]) / 3.0
  end

  def sma(values, period)
    window = []
    values.map do |value|
      if value.nil?
        nil
      else
        window << value.to_f
        if window.length == period
          result = average(window)
          window.shift
          result
        end
      end
    end
  end

  def ema(values, period)
    return Array.new(values.length, nil) if values.length < period

    multiplier = 2.0 / (period + 1.0)
    output = []
    window = []
    prev_ema = nil

    values.each do |value|
      window << value.to_f
      if window.length < period
        output << nil
      elsif window.length == period && prev_ema.nil?
        prev_ema = average(window)
        output << prev_ema
        window.shift
      else
        prev_ema = ((value.to_f - prev_ema) * multiplier) + prev_ema
        output << prev_ema
        window.shift
      end
    end

    output
  end

  def wma(values, period)
    return Array.new(values.length, nil) if values.length < period

    divisor = period * (period + 1) / 2.0
    window = []
    values.map do |value|
      window << value.to_f
      next unless window.length == period

      result = window.each_with_index.sum(0.0) { |v, idx| v * (idx + 1) } / divisor
      window.shift
      result
    end
  end

  def wilders(values, period)
    return Array.new(values.length, nil) if values.length < period

    output = []
    window = []
    prev = nil

    values.each do |value|
      window << value.to_f
      if window.length < period
        output << nil
      elsif prev.nil?
        prev = average(window)
        output << prev
        window.shift
      else
        prev = wilder_smoothing(prev, value.to_f, period)
        output << prev
        window.shift
      end
    end

    output
  end

  def rsi(values, period)
    return [] if values.length < period

    gains = []
    losses = []
    output = [nil]
    avg_gain = nil
    avg_loss = nil

    (1...values.length).each do |i|
      change = values[i] - values[i - 1]
      gains << [change, 0.0].max
      losses << [-change, 0.0].max

      if gains.length == period
        if avg_gain.nil?
          avg_gain = average(gains)
          avg_loss = average(losses)
        else
          avg_gain = wilder_smoothing(avg_gain, gains.last, period)
          avg_loss = wilder_smoothing(avg_loss, losses.last, period)
        end

        output << if avg_loss.zero?
                    avg_gain.zero? ? 0.0 : 100.0
                  else
                    rs = avg_gain / avg_loss
                    100.0 - (100.0 / (1.0 + rs))
                  end

        gains.shift
        losses.shift
      else
        output << nil
      end
    end

    output
  end

  def cmo(values, period)
    changes = values.each_cons(2).map { |a, b| b - a }
    output = [nil]

    changes.each_index do |idx|
      if idx + 1 < period
        output << nil
        next
      end

      slice = changes[(idx - period + 1)..idx]
      up = slice.sum(0.0) { |v| v.positive? ? v : 0.0 }
      down = slice.sum(0.0) { |v| v.negative? ? v.abs : 0.0 }
      denominator = up + down
      output << (denominator.zero? ? 0.0 : 100.0 * (up - down) / denominator)
    end

    output
  end

  def dlr(values)
    [nil] + values.each_cons(2).map { |a, b| Math.log(b / a) }
  end

  def dr(values)
    [nil] + values.each_cons(2).map { |a, b| (b / a) - 1.0 }
  end

  def roc(values, period)
    values.each_with_index.map do |value, idx|
      if idx < period
        nil
      else
        ((value - values[idx - period]) / values[idx - period]) * 100.0
      end
    end
  end

  def dpo(values, period)
    midpoint = (period / 2) + 1
    values.each_with_index.map do |value, idx|
      if idx < (period + midpoint - 2)
        nil
      else
        window = values[(idx - midpoint - period + 2)..(idx - midpoint + 1)]
        value - average(window)
      end
    end
  end

  def trix(values, period)
    ema1 = ema(values, period)
    ema2 = ema(ema1.compact, period)
    ema3 = ema(ema2.compact, period)
    aligned = Array.new(values.length, nil)
    offset = 3 * (period - 1)
    ema3.compact.each_with_index do |value, idx|
      aligned[offset + idx] = value if (offset + idx) < aligned.length
    end

    output = Array.new(values.length, nil)
    (1...values.length).each do |idx|
      next unless aligned[idx] && aligned[idx - 1]

      output[idx] = ((aligned[idx] - aligned[idx - 1]) / aligned[idx - 1]) * 100.0
    end
    output
  end

  def tsi(values, fast_period, slow_period)
    momentum = values.each_cons(2).map { |a, b| b - a }
    abs_momentum = momentum.map(&:abs)

    ema1_m = ema(momentum, slow_period)
    ema1_abs = ema(abs_momentum, slow_period)
    ema2_m = ema(ema1_m.compact, fast_period)
    ema2_abs = ema(ema1_abs.compact, fast_period)

    output = Array.new(values.length, nil)
    offset = slow_period + fast_period - 1

    ema2_m.compact.each_with_index do |value, idx|
      next unless (offset + idx) < output.length

      denom = ema2_abs.compact[idx]
      output[offset + idx] = denom.zero? ? 0.0 : 100.0 * (value / denom)
    end

    output
  end

  def cr(values)
    start = values.first.to_f
    values.map { |v| start.zero? ? 0.0 : (v.to_f - start) / start }
  end

  def bb(values, period, standard_deviations)
    window = []
    values.map do |value|
      window << value.to_f
      next unless window.length == period

      middle = average(window)
      spread = sample_stddev(window)
      result = {
        upper: middle + (standard_deviations * spread),
        middle: middle,
        lower: middle - (standard_deviations * spread)
      }
      window.shift
      result
    end
  end

  def macd(values, fast_period, slow_period, signal_period)
    fast = ema(values, fast_period)
    slow = ema(values, slow_period)
    macd_line = values.each_index.map { |idx| fast[idx] && slow[idx] ? fast[idx] - slow[idx] : nil }
    signal = Array.new(values.length, nil)
    signal_values = ema(macd_line.compact, signal_period)
    signal[(values.length - signal_values.length)...] = signal_values

    values.each_index.map do |idx|
      {
        macd: macd_line[idx],
        signal: signal[idx],
        histogram: macd_line[idx] && signal[idx] ? macd_line[idx] - signal[idx] : nil
      }
    end
  end

  def adi(data)
    running = 0.0
    data.map do |bar|
      clv = if bar[:high] == bar[:low]
              0.0
            else
              ((bar[:close] - bar[:low]) - (bar[:high] - bar[:close])) / (bar[:high] - bar[:low])
            end
      running += clv * bar[:volume]
      running
    end
  end

  def adtv(data, period)
    sma(data.map { |bar| bar[:volume] }, period)
  end

  def atr(data, period)
    trs = data.each_with_index.map do |bar, idx|
      if idx.zero?
        bar[:high] - bar[:low]
      else
        true_range(bar[:high], bar[:low], data[idx - 1][:close])
      end
    end
    wilders(trs, period)
  end

  def adx(data, period) # rubocop:disable Metrics/AbcSize
    plus_dm = []
    minus_dm = []
    trs = []

    data.each_with_index do |bar, idx|
      if idx.zero?
        plus_dm << 0.0
        minus_dm << 0.0
        trs << (bar[:high] - bar[:low])
        next
      end

      prev = data[idx - 1]
      high_diff = bar[:high] - prev[:high]
      low_diff = prev[:low] - bar[:low]

      plus_dm << (high_diff > low_diff && high_diff.positive? ? high_diff : 0.0)
      minus_dm << (low_diff > high_diff && low_diff.positive? ? low_diff : 0.0)
      trs << true_range(bar[:high], bar[:low], prev[:close])
    end

    smooth = lambda do |values|
      smoothed = []
      current_sum = 0.0
      values.each_with_index do |value, idx|
        if idx < period - 1
          current_sum += value
        elsif idx == period - 1
          current_sum += value
          smoothed << current_sum
        else
          smoothed << (smoothed.last - (smoothed.last / period.to_f) + value)
        end
      end
      smoothed
    end

    sm_plus = smooth.call(plus_dm)
    sm_minus = smooth.call(minus_dm)
    sm_tr = smooth.call(trs)

    dxs = sm_plus.each_index.map do |idx|
      plus_di = 100.0 * (sm_plus[idx] / sm_tr[idx])
      minus_di = 100.0 * (sm_minus[idx] / sm_tr[idx])
      100.0 * (plus_di - minus_di).abs / (plus_di + minus_di)
    end

    output = []
    adx_value = nil
    dxs.each_with_index do |dx, idx|
      if idx < period - 1
        output << nil
      elsif idx == period - 1
        adx_value = average(dxs[0..idx])
        output << adx_value
      else
        adx_value = ((adx_value * (period - 1)) + dx) / period.to_f
        output << adx_value
      end
    end

    Array.new(period - 1, nil) + output
  end

  def ao(data, short_period, long_period)
    midpoints = data.map { |bar| (bar[:high] + bar[:low]) / 2.0 }
    short = sma(midpoints, short_period)
    long = sma(midpoints, long_period)
    data.each_index.map { |idx| short[idx] && long[idx] ? short[idx] - long[idx] : nil }
  end

  def cci(data, period)
    tps = data.map { |bar| typical_price(bar) }
    data.each_index.map do |idx|
      if idx < period - 1
        nil
      else
        window = tps[(idx - period + 1)..idx]
        avg = average(window)
        mad = mean_absolute_deviation(window, avg)
        mad.zero? ? 0.0 : (tps[idx] - avg) / (0.015 * mad)
      end
    end
  end

  def cmf(data, period)
    output = []
    volumes = []
    mf_volumes = []

    data.each do |bar|
      multiplier = if bar[:high] == bar[:low]
                     0.0
                   else
                     ((bar[:close] - bar[:low]) - (bar[:high] - bar[:close])) / (bar[:high] - bar[:low])
                   end
      volumes << bar[:volume]
      mf_volumes << (multiplier * bar[:volume])

      if volumes.length == period
        output << (mf_volumes.sum / volumes.sum)
        volumes.shift
        mf_volumes.shift
      else
        output << nil
      end
    end

    output
  end

  def dc(data, period)
    data.each_index.map do |idx|
      if idx < period - 1
        { upper: nil, middle: nil, lower: nil }
      else
        window = data[(idx - period + 1)..idx]
        high = window.max_by { |bar| bar[:high] }[:high]
        low = window.min_by { |bar| bar[:low] }[:low]
        { upper: high, middle: (high + low) / 2.0, lower: low }
      end
    end
  end

  def envelopes_ema(values, period, percentage)
    ema(values, period).map do |mid|
      if mid.nil?
        { upper: nil, middle: nil, lower: nil }
      else
        pct = percentage / 100.0
        { upper: mid * (1.0 + pct), middle: mid, lower: mid * (1.0 - pct) }
      end
    end
  end

  def eom(data, period)
    output = []
    emv_values = []
    prev = nil

    data.each do |bar|
      if prev.nil?
        output << nil
        prev = bar
        next
      end

      distance = ((bar[:high] + bar[:low]) / 2.0) - ((prev[:high] + prev[:low]) / 2.0)
      range = bar[:high] - bar[:low]
      box_ratio = range.zero? ? 0.0 : (bar[:volume] / 100_000_000.0) / range
      emv = box_ratio.zero? ? 0.0 : distance / box_ratio
      emv_values << emv

      if emv_values.length == period
        output << average(emv_values)
        emv_values.shift
      else
        output << nil
      end

      prev = bar
    end

    output
  end

  def fi(data, period)
    raw = []
    data.each_cons(2) do |prev, bar|
      raw << ((bar[:close] - prev[:close]) * bar[:volume])
    end
    [nil] + ema(raw, period)
  end

  def ichimoku(data, low_period, medium_period, high_period)
    midpoint = lambda do |end_idx, period|
      start_idx = [0, end_idx - period + 1].max
      window = data[start_idx..end_idx]
      (window.max_by { |bar| bar[:high] }[:high] + window.min_by { |bar| bar[:low] }[:low]) / 2.0
    end

    data.each_index.map do |idx|
      if idx < high_period + medium_period - 2
        nil
      else
        shifted_idx = idx - (medium_period - 1)
        tenkan = midpoint.call(idx, low_period)
        kijun = midpoint.call(idx, medium_period)
        senkou_a = (midpoint.call(shifted_idx, low_period) + midpoint.call(shifted_idx, medium_period)) / 2.0
        senkou_b = midpoint.call(shifted_idx, high_period)
        chikou = data[shifted_idx][:close]

        {
          tenkan_sen: tenkan,
          kijun_sen: kijun,
          senkou_span_a: senkou_a,
          senkou_span_b: senkou_b,
          chikou_span: chikou
        }
      end
    end
  end

  def imi(data, period)
    data.each_index.map do |idx|
      if idx < period - 1
        nil
      else
        window = data[(idx - period + 1)..idx]
        gains = window.sum(0.0) { |bar| bar[:close] > bar[:open] ? bar[:close] - bar[:open] : 0.0 }
        losses = window.sum(0.0) { |bar| bar[:close] < bar[:open] ? bar[:open] - bar[:close] : 0.0 }
        total = gains + losses
        total.zero? ? 0.0 : 100.0 * gains / total
      end
    end
  end

  def kc(data, period, multiplier)
    typicals = []
    ranges = []
    data.map do |bar|
      typicals << typical_price(bar)
      ranges << (bar[:high] - bar[:low])
      next unless typicals.length == period

      mid = average(typicals)
      avg_range = average(ranges)
      result = { upper: mid + (avg_range * multiplier), middle: mid, lower: mid - (avg_range * multiplier) }
      typicals.shift
      ranges.shift
      result
    end
  end

  def kst(values, r1:, r2:, r3:, r4:, s1:, s2:, s3:, s4:, signal:)
    rcma = lambda do |index, roc_period, sma_period|
      return nil if index < (roc_period + sma_period)

      roc_values = ((index - sma_period + 1)..index).map do |i|
        past = values[i - roc_period]
        return nil if past.nil? || past.zero?

        ((values[i] - past) / past) * 100.0
      end
      average(roc_values)
    end

    kst_values = values.each_index.map do |idx|
      a = rcma.call(idx, r1, s1)
      b = rcma.call(idx, r2, s2)
      c = rcma.call(idx, r3, s3)
      d = rcma.call(idx, r4, s4)
      a && b && c && d ? a + (2.0 * b) + (3.0 * c) + (4.0 * d) : nil
    end

    lead_nils = kst_values.count(nil)
    signal_line = if kst_values.compact.length >= signal
                    Array.new(lead_nils, nil) + sma(kst_values.compact, signal)
                  else
                    Array.new(values.length, nil)
                  end

    values.each_index.map do |idx|
      { kst: kst_values[idx], signal: signal_line[idx] }
    end
  end

  def mfi(data, period)
    return Array.new(data.length, nil) if data.length <= period

    tps = []
    raw_flows = []
    output = []

    data.each_with_index do |bar, idx|
      tp = typical_price(bar)
      tps << tp
      if idx.zero?
        raw_flows << 0.0
        output << nil
        next
      end

      money_flow = tp * bar[:volume]
      raw_flows << if tp > tps[idx - 1]
                     money_flow
                   elsif tp < tps[idx - 1]
                     -money_flow
                   else
                     0.0
                   end

      if raw_flows.length > period
        window = raw_flows.last(period)
        pos = window.select(&:positive?).sum
        neg = window.select(&:negative?).sum.abs
        output << (neg.zero? ? 100.0 : 100.0 - (100.0 / (1.0 + (pos / neg))))
      else
        output << nil
      end
    end

    output
  end

  def mi(data, ema_period, period)
    ranges = data.map { |bar| bar[:high] - bar[:low] }
    ema1 = ema(ranges, ema_period)
    ema2 = ema(ema1.compact, ema_period)
    aligned_ema2 = Array.new(ema1.length - ema2.length, nil) + ema2
    ratios = ema1.each_index.map do |idx|
      a = ema1[idx]
      b = aligned_ema2[idx]
      a && b && !b.zero? ? a / b : nil
    end

    output = []
    running = []
    ratios.each do |ratio|
      if ratio.nil?
        output << nil
      else
        running << ratio
        running.shift if running.length > period
        output << (running.length == period ? running.sum : nil)
      end
    end
    output
  end

  def nvi(data)
    return [] if data.empty?

    output = [1000.0]
    current = 1000.0

    data.each_cons(2) do |prev, bar|
      current *= 1.0 + ((bar[:close] - prev[:close]) / prev[:close]) if bar[:volume] < prev[:volume]
      output << current
    end

    output
  end

  def obv(data)
    current = 0.0
    output = []

    data.each_with_index do |bar, idx|
      if idx.positive?
        prev_close = data[idx - 1][:close]
        current += bar[:volume] if bar[:close] > prev_close
        current -= bar[:volume] if bar[:close] < prev_close
      end
      output << current
    end
    output
  end

  def obv_mean(data, period)
    obv_values = obv(data)
    output = []
    rolling = []

    data.each_index do |idx|
      rolling << obv_values[idx] if idx.positive?
      output << (rolling.length >= period ? average(rolling.last(period)) : nil)
    end

    output
  end

  def pivot_points(data)
    data.map do |bar|
      p = ((bar[:high] + bar[:low] + bar[:close]) / 3.0).round(4)
      {
        p: p,
        s1: ((2 * p) - bar[:high]).round(4),
        s2: (p - (bar[:high] - bar[:low])).round(4),
        s3: (bar[:low] - (2 * (bar[:high] - p))).round(4),
        r1: ((2 * p) - bar[:low]).round(4),
        r2: (p + (bar[:high] - bar[:low])).round(4),
        r3: (bar[:high] + (2 * (p - bar[:low]))).round(4)
      }
    end
  end

  def price_channel(data, period)
    data.each_index.map do |idx|
      if idx < period - 1
        { upper: nil, lower: nil }
      else
        window = data[(idx - period + 1)..idx]
        {
          upper: window.max_by { |bar| bar[:high] }[:high],
          lower: window.min_by { |bar| bar[:low] }[:low]
        }
      end
    end
  end

  def qstick(data, period)
    diffs = data.map { |bar| bar[:close] - bar[:open] }
    data.each_index.map do |idx|
      if idx < period - 1
        nil
      else
        (diffs[(idx - period + 1)..idx].sum / period.to_f).round(4)
      end
    end
  end

  def rmi(values, period, momentum_period)
    return Array.new(values.length, nil) if values.length < momentum_period + period

    ups = []
    downs = []
    (momentum_period...values.length).each do |idx|
      change = values[idx] - values[idx - momentum_period]
      ups << [change, 0.0].max
      downs << [-change, 0.0].max
    end

    avg_ups = wilders(ups, period)
    avg_downs = wilders(downs, period)

    output = Array.new(momentum_period, nil)
    avg_ups.each_index do |idx|
      if avg_ups[idx].nil? || avg_downs[idx].nil?
        output << nil
      elsif avg_downs[idx].zero?
        output << 100.0
      else
        rs = avg_ups[idx] / avg_downs[idx]
        output << (100.0 - (100.0 / (1.0 + rs))).round(4)
      end
    end
    output
  end

  def so(data, k_period, k_slowing, d_period)
    highs = data.map { |bar| bar[:high] }
    lows = data.map { |bar| bar[:low] }
    closes = data.map { |bar| bar[:close] }

    fast_k = data.each_index.map do |idx|
      if idx < k_period - 1
        nil
      else
        hh = highs[(idx - k_period + 1)..idx].max
        ll = lows[(idx - k_period + 1)..idx].min
        hh == ll ? 100.0 : ((closes[idx] - ll) / (hh - ll) * 100.0)
      end
    end

    slow_k = if k_slowing > 1
               fast_k.each_index.map do |idx|
                 if idx < (k_period - 1) + (k_slowing - 1)
                   nil
                 else
                   average(fast_k[(idx - k_slowing + 1)..idx])
                 end
               end
             else
               fast_k
             end

    d_values = slow_k.each_index.map do |idx|
      warmup = (k_period - 1) + (k_slowing > 1 ? k_slowing - 1 : 0) + (d_period - 1)
      if idx < warmup
        nil
      else
        average(slow_k[(idx - d_period + 1)..idx])
      end
    end

    data.each_index.map do |idx|
      { k: slow_k[idx]&.round(4), d: d_values[idx]&.round(4) }
    end
  end

  def uo(data, short_period, medium_period, long_period)
    bp = []
    tr = []
    (1...data.length).each do |idx|
      bar = data[idx]
      prev_close = data[idx - 1][:close]
      min_low_close = [bar[:low], prev_close].min
      max_high_close = [bar[:high], prev_close].max
      bp << (bar[:close] - min_low_close)
      tr << (max_high_close - min_low_close)
    end

    output = Array.new(data.length, nil)
    ((long_period - 1)...bp.length).each do |idx|
      avg_short = bp[(idx - short_period + 1)..idx].sum / tr[(idx - short_period + 1)..idx].sum
      avg_medium = bp[(idx - medium_period + 1)..idx].sum / tr[(idx - medium_period + 1)..idx].sum
      avg_long = bp[(idx - long_period + 1)..idx].sum / tr[(idx - long_period + 1)..idx].sum
      output[idx + 1] = 100.0 * ((4.0 * avg_short) + (2.0 * avg_medium) + avg_long) / 7.0
    end
    output
  end

  def vi(data, period)
    output = [{ plus_vi: nil, minus_vi: nil }]
    pos_vm = []
    neg_vm = []
    trs = []

    (1...data.length).each do |idx|
      bar = data[idx]
      prev = data[idx - 1]
      pos_vm << (bar[:high] - prev[:low]).abs
      neg_vm << (bar[:low] - prev[:high]).abs
      trs << true_range(bar[:high], bar[:low], prev[:close])

      if pos_vm.length >= period
        sum_tr = trs.last(period).sum
        output << {
          plus_vi: pos_vm.last(period).sum / sum_tr,
          minus_vi: neg_vm.last(period).sum / sum_tr
        }
      else
        output << { plus_vi: nil, minus_vi: nil }
      end
    end

    output
  end

  def volume_oscillator(data, short_period, long_period)
    volumes = data.map { |bar| bar[:volume] }
    short_window = []
    long_window = []

    volumes.map do |volume|
      short_window << volume
      long_window << volume
      short_window.shift if short_window.length > short_period
      long_window.shift if long_window.length > long_period

      next unless long_window.length == long_period

      short_avg = average(short_window)
      long_avg = average(long_window)
      (long_avg.zero? ? 0.0 : (((short_avg - long_avg) / long_avg) * 100.0)).round(2)
    end
  end

  def vpt(data)
    output = [nil]
    current = 0.0
    data.each_cons(2) do |prev, bar|
      current += bar[:volume] * ((bar[:close] - prev[:close]) / prev[:close])
      output << current
    end
    output
  end

  def vwap(data)
    cum_volume = 0.0
    cum_value = 0.0
    data.map do |bar|
      tp = typical_price(bar)
      cum_volume += bar[:volume]
      cum_value += tp * bar[:volume]
      cum_volume.positive? ? (cum_value / cum_volume) : 0.0
    end
  end

  def wr(data, period)
    data.each_index.map do |idx|
      if idx < period - 1
        nil
      else
        window = data[(idx - period + 1)..idx]
        highest_high = window.max_by { |bar| bar[:high] }[:high]
        lowest_low = window.min_by { |bar| bar[:low] }[:low]
        ((highest_high - data[idx][:close]) / (highest_high - lowest_low)) * -100.0
      end
    end
  end
end

# rubocop:disable RSpec/SpecFilePathFormat, RSpec/ExampleLength, RSpec/NoExpectationExample
RSpec.describe IndicatorHub do
  let(:market_data) { RealisticFixtureReference.market_data }
  let(:closes) { RealisticFixtureReference.closes(market_data) }

  def expect_numeric_series_close(actual, expected, tolerance: 1e-6)
    expect(actual.length).to eq(expected.length)

    actual.zip(expected).each_with_index do |(a, e), idx|
      if e.nil?
        expect(a).to be_nil, "expected nil at index #{idx}, got #{a.inspect}"
      else
        expect(a).not_to be_nil, "expected numeric at index #{idx}"
        expect(a).to be_within(tolerance).of(e), "mismatch at index #{idx}"
      end
    end
  end

  def expect_hash_series_close(actual, expected, keys:, tolerance: 1e-6)
    expect(actual.length).to eq(expected.length)

    actual.zip(expected).each_with_index do |(a, e), idx|
      if e.nil?
        expect(a).to be_nil, "expected nil hash at index #{idx}, got #{a.inspect}"
        next
      end

      expect(a).to be_a(Hash), "expected hash at index #{idx}, got #{a.inspect}"
      keys.each do |key|
        if e[key].nil?
          expect(a[key]).to be_nil, "expected #{key} nil at index #{idx}, got #{a[key].inspect}"
        else
          expect(a[key]).not_to be_nil, "expected #{key} numeric at index #{idx}"
          expect(a[key]).to be_within(tolerance).of(e[key]), "mismatch for #{key} at index #{idx}"
        end
      end
    end
  end

  def check_numeric_cases(cases)
    cases.each do |test_case|
      expect_numeric_series_close(test_case[:actual], test_case[:expected], tolerance: test_case.fetch(:tolerance, 1e-6))
    end
  end

  def check_hash_cases(cases)
    cases.each do |test_case|
      expect_hash_series_close(
        test_case[:actual],
        test_case[:expected],
        keys: test_case[:keys],
        tolerance: test_case.fetch(:tolerance, 1e-6)
      )
    end
  end

  def kst_defaults
    {
      r1: 10,
      r2: 15,
      r3: 20,
      r4: 30,
      s1: 10,
      s2: 10,
      s3: 10,
      s4: 15,
      signal: 9
    }
  end

  context "with realistic fixture coverage" do
    it "matches independent references for single-series indicators on realistic closes" do
      check_numeric_cases([
                            { actual: described_class.sma(closes, period: 10), expected: RealisticFixtureReference.sma(closes, 10) },
                            { actual: described_class.ema(closes, period: 10), expected: RealisticFixtureReference.ema(closes, 10) },
                            { actual: described_class.wma(closes, period: 10), expected: RealisticFixtureReference.wma(closes, 10) },
                            { actual: described_class.rsi(closes, period: 14), expected: RealisticFixtureReference.rsi(closes, 14), tolerance: 1e-5 },
                            { actual: described_class.cmo(closes, period: 14), expected: RealisticFixtureReference.cmo(closes, 14), tolerance: 1e-5 },
                            { actual: described_class.dlr(closes), expected: RealisticFixtureReference.dlr(closes), tolerance: 1e-8 },
                            { actual: described_class.dpo(closes, period: 20), expected: RealisticFixtureReference.dpo(closes, 20), tolerance: 1e-8 },
                            { actual: described_class.dr(closes), expected: RealisticFixtureReference.dr(closes), tolerance: 1e-8 },
                            { actual: described_class.roc(closes, period: 12), expected: RealisticFixtureReference.roc(closes, 12), tolerance: 1e-3 },
                            { actual: described_class.trix(closes, period: 9), expected: RealisticFixtureReference.trix(closes, 9), tolerance: 1e-5 },
                            { actual: described_class.tsi(closes, fast_period: 13, slow_period: 25),
                              expected: RealisticFixtureReference.tsi(closes, 13, 25), tolerance: 1e-5 },
                            { actual: described_class.wilders_smoothing(closes, period: 14), expected: RealisticFixtureReference.wilders(closes, 14),
                              tolerance: 1e-4 },
                            { actual: described_class.cr(closes), expected: RealisticFixtureReference.cr(closes), tolerance: 1e-8 }
                          ])
    end

    it "matches independent references for hash-based core indicators on realistic OHLCV" do
      check_hash_cases([
                         { actual: described_class.bb(market_data, period: 20), expected: RealisticFixtureReference.bb(closes, 20, 2),
                           keys: %i[upper middle lower], tolerance: 1e-5 },
                         { actual: described_class.macd(closes), expected: RealisticFixtureReference.macd(closes, 12, 26, 9),
                           keys: %i[macd signal histogram], tolerance: 1e-5 },
                         { actual: described_class.dc(market_data, period: 20), expected: RealisticFixtureReference.dc(market_data, 20),
                           keys: %i[upper middle lower], tolerance: 1e-5 },
                         { actual: described_class.envelopes_ema(closes, period: 20, percentage: 2.5),
                           expected: RealisticFixtureReference.envelopes_ema(closes, 20, 2.5), keys: %i[upper middle lower], tolerance: 1e-5 }
                       ])

      check_numeric_cases([
                            { actual: described_class.adi(market_data), expected: RealisticFixtureReference.adi(market_data), tolerance: 1e-5 },
                            { actual: described_class.adtv(market_data, period: 20), expected: RealisticFixtureReference.adtv(market_data, 20),
                              tolerance: 1e-5 },
                            { actual: described_class.adx(market_data, period: 14), expected: RealisticFixtureReference.adx(market_data, 14),
                              tolerance: 1e-5 },
                            { actual: described_class.ao(market_data), expected: RealisticFixtureReference.ao(market_data, 5, 34), tolerance: 1e-5 },
                            { actual: described_class.atr(market_data, period: 14), expected: RealisticFixtureReference.atr(market_data, 14),
                              tolerance: 1e-5 },
                            { actual: described_class.cci(market_data, period: 20), expected: RealisticFixtureReference.cci(market_data, 20),
                              tolerance: 1e-5 },
                            { actual: described_class.cmf(market_data, period: 20), expected: RealisticFixtureReference.cmf(market_data, 20),
                              tolerance: 1e-5 },
                            { actual: described_class.eom(market_data, period: 14), expected: RealisticFixtureReference.eom(market_data, 14),
                              tolerance: 1e-5 },
                            { actual: described_class.fi(market_data, period: 13), expected: RealisticFixtureReference.fi(market_data, 13),
                              tolerance: 1e-5 }
                          ])
    end

    it "matches independent references for advanced OHLCV indicators on realistic OHLCV" do
      check_hash_cases([
                         { actual: described_class.ichimoku(market_data), expected: RealisticFixtureReference.ichimoku(market_data, 9, 26, 52),
                           keys: %i[tenkan_sen kijun_sen senkou_span_a senkou_span_b chikou_span], tolerance: 1e-5 },
                         { actual: described_class.kc(market_data, period: 20, multiplier: 1.5),
                           expected: RealisticFixtureReference.kc(market_data, 20, 1.5), keys: %i[upper middle lower], tolerance: 1e-5 },
                         { actual: described_class.kst(market_data), expected: RealisticFixtureReference.kst(closes, **kst_defaults),
                           keys: %i[kst signal], tolerance: 1e-5 },
                         { actual: described_class.pivot_points(market_data), expected: RealisticFixtureReference.pivot_points(market_data),
                           keys: %i[p s1 s2 s3 r1 r2 r3], tolerance: 1e-5 },
                         { actual: described_class.price_channel(market_data, period: 20),
                           expected: RealisticFixtureReference.price_channel(market_data, 20), keys: %i[upper lower], tolerance: 1e-5 },
                         { actual: described_class.so(market_data, k_period: 14, k_slowing: 3, d_period: 3),
                           expected: RealisticFixtureReference.so(market_data, 14, 3, 3), keys: %i[k d], tolerance: 1e-5 },
                         { actual: described_class.vi(market_data, period: 14), expected: RealisticFixtureReference.vi(market_data, 14),
                           keys: %i[plus_vi minus_vi], tolerance: 1e-5 }
                       ])

      check_numeric_cases([
                            { actual: described_class.imi(market_data, period: 14), expected: RealisticFixtureReference.imi(market_data, 14),
                              tolerance: 1e-5 },
                            { actual: described_class.mfi(market_data, period: 14), expected: RealisticFixtureReference.mfi(market_data, 14),
                              tolerance: 1e-5 },
                            { actual: described_class.mi(market_data, period: 25), expected: RealisticFixtureReference.mi(market_data, 9, 25),
                              tolerance: 1e-5 },
                            { actual: described_class.nvi(market_data), expected: RealisticFixtureReference.nvi(market_data), tolerance: 1e-5 },
                            { actual: described_class.obv(market_data), expected: RealisticFixtureReference.obv(market_data), tolerance: 1e-5 },
                            { actual: described_class.obv_mean(market_data, period: 10),
                              expected: RealisticFixtureReference.obv_mean(market_data, 10), tolerance: 1e-5 },
                            { actual: described_class.qstick(market_data, period: 10), expected: RealisticFixtureReference.qstick(market_data, 10),
                              tolerance: 1e-5 },
                            { actual: described_class.rmi(closes, period: 14, momentum_period: 5),
                              expected: RealisticFixtureReference.rmi(closes, 14, 5), tolerance: 2e-3 },
                            { actual: described_class.uo(market_data), expected: RealisticFixtureReference.uo(market_data, 7, 14, 28),
                              tolerance: 1e-5 },
                            { actual: described_class.volume_oscillator(market_data),
                              expected: RealisticFixtureReference.volume_oscillator(market_data, 20, 60), tolerance: 1e-5 },
                            { actual: described_class.vpt(market_data), expected: RealisticFixtureReference.vpt(market_data), tolerance: 1e-5 },
                            { actual: described_class.vwap(market_data), expected: RealisticFixtureReference.vwap(market_data), tolerance: 1e-5 },
                            { actual: described_class.wr(market_data, period: 14), expected: RealisticFixtureReference.wr(market_data, 14),
                              tolerance: 1e-5 }
                          ])
    end
  end
end

# rubocop:enable RSpec/SpecFilePathFormat, RSpec/ExampleLength, RSpec/NoExpectationExample
