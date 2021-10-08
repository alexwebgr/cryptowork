require 'uri'
require 'net/http'
require 'json'

class CryptoWorkService
  NOMICS_API_KEY = ENV['NOMICS_API_KEY']
  BASE_URL = 'https://api.nomics.com'
  API_VERSION = 'v1'
  ENDPOINTS = {
    :currencies => 'currencies/ticker'
  }

  private

  attr_reader :tickers

  def initialize(tickers)
    @tickers = tickers
  end

  def make_call(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    res.body
  end

  public

  def currencies(convert_to = nil)
    endpoint = [BASE_URL, API_VERSION, ENDPOINTS[:currencies]].join('/')
    params = {
      key: NOMICS_API_KEY,
      ids: tickers.join(',')
    }

    params[:convert] = convert_to unless convert_to.nil?

    [endpoint, URI.encode_www_form(params)].join('?')
  end

  def list_tickers
    make_call(currencies)
  end

  # fields: Array, an array of fields we expect to see in the response. e.g. [circulating_supply, max_supply, name, symbol, price]
  def list_tickers_filtered(fields)
    JSON.parse(list_tickers).map do |list_ticker|
      list_ticker.slice(*fields)
    end

  rescue JSON::ParserError => e
    # log the error to the error monitoring app like rollbar
    p e.message
    { error: e.message }
  end

  # target_currency: String, the currency id we want to convert the prices to, like EUR
  def convert_to(target_currency)
    make_call(currencies(target_currency))
  end

  # source_currency: String, the currency id we want to compare, like BTC
  # target_currency: String, the currency id we want to against, like ETH

  def compare_to(target_currency)
    source = CryptoWorkService.new([tickers[0]]).list_tickers_filtered(['price'])
    target = CryptoWorkService.new([target_currency]).list_tickers_filtered(['price'])

    { message: "1#{tickers[0]} is worth #{source[0]['price'].to_f / target[0]['price'].to_f}#{target_currency}" }
  end
end