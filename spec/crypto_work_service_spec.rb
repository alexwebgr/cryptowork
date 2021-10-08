require_relative 'spec_helper'
require 'dotenv/load'
require_relative '../app/crypto_work_service'

RSpec.describe CryptoWorkService, type: :service do
  include_context("nomics_helper")

  describe '#list_tickers' do
    describe 'when an array of valid tickers is provided' do
      let(:valid_tickers) { %w[BTC XRP ETH] }

      it 'returns an array with the full payload' do
        expected_response = file_fixture('nomics_valid_response_currencies_tickers.json').read

        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker?ids=#{valid_tickers.join(',')}&key=#{described_class::NOMICS_API_KEY}").
          to_return(status: 200, body: expected_response)

        expect(described_class.new(valid_tickers).list_tickers).to eq expected_response
      end
    end

    describe 'when the ticker is invalid' do
      let(:invalid_tickers) { %w[invalid] }

      it 'returns an empty array' do
        expected_response = []
        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker?ids=#{invalid_tickers.join(',')}&key=#{described_class::NOMICS_API_KEY}").
          to_return(status: 200, body: expected_response)

        expect(described_class.new(invalid_tickers).list_tickers).to eq expected_response
      end
    end


    describe 'when the key is missing' do
      let(:valid_tickers) { %w[BTC XRP ETH] }

      it 'returns an error' do
        expected_response = "Authentication failed. We couldn't find an API key in the request. See our documentation at docs.nomics.com for details.\n"
        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker").
          with(
            query: hash_including({ids: valid_tickers.join(',')})
          ).
          to_return(status: 401, body: expected_response)

        expect(described_class.new(valid_tickers).list_tickers).to eq expected_response
      end
    end
  end

  describe '#list_tickers_filtered' do
    describe 'when an array of valid tickers is provided and a list of fields' do
      let(:valid_tickers) { %w[BTC XRP ETH] }
      let(:fields) { %w[symbol name circulating_supply price max_supply] }

      it 'returns an array with the full payload' do
        expected_response = file_fixture('nomics_valid_response_currencies_tickers_filtered.json').read

        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker?ids=#{valid_tickers.join(',')}&key=#{described_class::NOMICS_API_KEY}").
          to_return(status: 200, body: expected_response)

        expect(described_class.new(valid_tickers).list_tickers_filtered(fields).to_json).to eq expected_response
      end
    end

    describe 'when the usage quota has been reached' do
      let(:valid_tickers) { %w[BTC XRP ETH] }
      let(:fields) { %w[symbol name circulating_supply price max_supply] }

      it 'returns an array with the full payload' do
        expected_response = file_fixture('quota_error.txt').read

        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker?ids=#{valid_tickers.join(',')}&key=#{described_class::NOMICS_API_KEY}").
          to_return(status: 429, body: expected_response)

        expect(described_class.new(valid_tickers).list_tickers_filtered(fields)).to eq({ error: "809: unexpected token at '#{expected_response}'" })
      end
    end
  end

  describe '#convert_to' do
    describe 'when a target currency is provided' do
      let(:valid_tickers) { %w[BTC XRP ETH] }
      let(:target_currency) { 'EUR' }

      it 'returns an array with the full payload with the price converted to the target currency' do
        expected_response = file_fixture('nomics_valid_response_currencies_tickers_convert_to_eur.json').read

        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker?ids=#{valid_tickers.join(',')}&key=#{described_class::NOMICS_API_KEY}&convert=#{target_currency}").
          to_return(status: 200, body: expected_response)

        expect(described_class.new(valid_tickers).convert_to(target_currency)).to eq expected_response
      end
    end
  end

  describe '#compare_to' do
    describe 'when a target currency is provided' do
      let(:valid_tickers) { %w[BTC] }
      let(:target_currency) { 'ETH' }

      it 'returns the exchange rate between the currencies' do
        btc = file_fixture('nomics_valid_response_currencies_tickers_compare.json').read

        stub_request(:get, "https://api.nomics.com/v1/currencies/ticker?ids=BTC,ETH&key=#{described_class::NOMICS_API_KEY}").
          to_return(status: 200, body: btc)

        expect(described_class.new(valid_tickers).compare_to(target_currency)).to eq({:message=>"1BTC is worth 15.185177018117594ETH"})
      end
    end
  end
end