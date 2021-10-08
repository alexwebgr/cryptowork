# CryptoWork

Retrieve cryptocurrency exchange rates 

### Features

* Retrieve a list of cryptocurrencies given set of tickers. e.g.['BTC', 'XRP', 'ETH']
* Retrieve a list of specific cryptocurrencies and specific values based on the ticker and any
  other dynamic params e.g. [circulating_supply, max_supply, name, symbol, price] for [ETH, BTC]
* Retrieve a specific cryptocurrency to specific fiat. e.g. BTC in ZAR or ETH in USD
* Calculate the price of one cryptocurrency from another, in relation to their dollar value e.g. 1BTC = 100USD, 1ETH = 50USD, therefore 1ETH == 0.5BTC

### Installation locally 

* Ensure you have ruby 3.0.0 install locally preferably by using a ruby version manager like rbenv
* Run `bundle install` to install the dependencies
* Run `ruby app/app.rb` to start the server and navigate to the url that will appear in the terminal
* Run the tests with `bundle exec rspec`. A coverage report will also be generated under `coverage/index.html`.
