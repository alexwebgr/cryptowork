require 'dotenv/load'
require 'sinatra'
require "sinatra/reloader" if development?
require_relative 'crypto_work_service'

get '/', provides: 'html' do
  erb :index
end

get '/list_tickers', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).list_tickers
end

get '/list_tickers_filtered', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).list_tickers_filtered(params['fields'].split(',')).to_json
end

get '/convert_to', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).convert_to(params['tc'])
end

get '/compare', provides: :json do
  CryptoWorkService.new(params['tickers'].split(',')).compare_to(params['tc']).to_json
end

