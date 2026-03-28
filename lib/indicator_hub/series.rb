# frozen_string_literal: true

module IndicatorHub
  # Data structure for handling OHLCV and series data.
  # Provides normalization and sorting capabilities for financial time series data.
  #
  # @example Using a hash array
  #   data = [{close: 100.0, open: 98.0}, {close: 101.0, open: 100.0}]
  #   series = IndicatorHub::Series.new(data)
  #   series.to_a(field: :close) #=> [100.0, 101.0]
  #
  class Series
    # @return [Array<Hash, Numeric>] The raw input data
    attr_reader :data

    # Initializes a new Series object.
    #
    # @param data [Array<Hash, Numeric>] The input data, either an array of numbers or hashes
    def initialize(data)
      @data = Array(data)
    end

    # Normalizes input data into an array of floats.
    #
    # @param field [Symbol, String] The field to extract from the hash data (default: :close)
    # @return [Array<Float>] An array of floating point numbers extracted from the data
    def to_a(field: :close)
      return data if data.all? { |v| v.is_a?(Numeric) }
      data.map { |v| (v[field] || v[field.to_sym] || v[field.to_s]).to_f }.compact
    end

    # Normalizes input data into an array of OHLCV hashes.
    #
    # @return [Array<Hash>] An array of hashes containing open, high, low, close, and volume
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

    # Returns chronologically sorted data if it has date or time fields.
    #
    # @return [Array<Hash, Numeric>] The sorted data
    def sorted_data
      return data unless data.first.is_a?(Hash) && (data.first[:date] || data.first["date"] || data.first[:date_time] || data.first["date_time"])
      data.sort_by { |v| v[:date] || v["date"] || v[:date_time] || v["date_time"] }
    end
  end
end
