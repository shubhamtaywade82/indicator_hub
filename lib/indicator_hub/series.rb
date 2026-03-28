# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

module IndicatorHub
  # Data structure for handling OHLCV and series data.
  # Provides normalization and sorting capabilities for financial time series data.
  class Series
    extend T::Sig

    # @return [Array<T.any(Hash, Numeric)>] The raw input data
    sig { returns(T::Array[T.any(T::Hash[T.untyped, T.untyped], Numeric)]) }
    attr_reader :data

    # Initializes a new Series object.
    #
    # @param data [Array<T.any(Hash, Numeric)>] The input data, either an array of numbers or hashes
    sig { params(data: T.any(T::Array[T.any(T::Hash[T.untyped, T.untyped], Numeric)], T::Hash[T.untyped, T.untyped], Numeric)).void }
    def initialize(data)
      @data = Array(data)
    end

    # Normalizes input data into an array of floats.
    #
    # @param field [Symbol, String] The field to extract from the hash data (default: :close)
    # @return [Array<Float>] An array of floating point numbers extracted from the data
    sig { params(field: T.any(Symbol, String)).returns(T::Array[Float]) }
    def to_a(field: :close)
      return T.cast(data, T::Array[Float]) if data.all? { |v| v.is_a?(Numeric) }
      
      data.map do |v| 
        next 0.0 unless v.is_a?(Hash)
        (v[field] || v[field.to_sym] || v[field.to_s]).to_f 
      end.compact
    end

    # Normalizes input data into an array of OHLCV hashes.
    #
    # @return [Array<Hash{Symbol => Float}>] An array of hashes containing open, high, low, close, and volume
    sig { returns(T::Array[T::Hash[Symbol, Float]]) }
    def to_ohlc
      data.map do |v|
        next { open: 0.0, high: 0.0, low: 0.0, close: 0.0, volume: 0.0 } unless v.is_a?(Hash)
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
    # @return [Array<T.any(Hash, Numeric)>] The sorted data
    sig { returns(T::Array[T.any(T::Hash[T.untyped, T.untyped], Numeric)]) }
    def sorted_data
      return data unless data.first.is_a?(Hash) && (data.first[:date] || data.first["date"] || data.first[:date_time] || data.first["date_time"])
      data.sort_by { |v| v[:date] || v["date"] || v[:date_time] || v["date_time"] }
    end
  end
end
