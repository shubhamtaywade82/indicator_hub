# frozen_string_literal: true

module IndicatorHub
  # Data structure for handling OHLCV and series data
  class Series
    attr_reader :data

    def initialize(data)
      @data = Array(data)
    end

    # Normalizes input data into an array of floats
    def to_a(field: :close)
      return data if data.all? { |v| v.is_a?(Numeric) }
      data.map { |v| (v[field] || v[field.to_sym] || v[field.to_s]).to_f }.compact
    end

    def to_ohlc
      data.map do |v|
        {
          open: (v[:open] || v["open"]).to_f,
          high: (v[:high] || v["high"]).to_f,
          low: (v[:low] || v["low"]).to_f,
          close: (v[:close] || v["close"]).to_f,
          volume: (v[:volume] || v["volume"]).to_f
        }
      end
    end

    # Returns chronologically sorted data if it has dates
    def sorted_data
      return data unless data.first.is_a?(Hash) && (data.first[:date] || data.first["date"] || data.first[:date_time] || data.first["date_time"])
      data.sort_by { |v| v[:date] || v["date"] || v[:date_time] || v["date_time"] }
    end
  end
end
