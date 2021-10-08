require 'dotenv/load'
require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'crypto_work_service'

get '/', provides: 'html' do
  erb :index
end

# tickers: a comma separated string, are the currencies we are interested in
# create an array for the tickers params as requested
get '/list_tickers', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).list_tickers
end

# fields: a comma separated string, are the fields we want to keep
get '/list_tickers_filtered', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).list_tickers_filtered(params['fields'].split(',')).to_json
end

# tc: String, the currency id we want to convert the prices to, like EUR
get '/convert_to', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).convert_to(params['tc'])
end

# tc: String, the currency id we want to compare against the first ticker, like ETH
get '/compare', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).compare_to(params['tc']).to_json
end

