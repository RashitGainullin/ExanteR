# ExanteR

Exante is a R package that allows you to load market data of wide range of assets from different exchanges (ex. NASDAQ, NYSE, MICEX etc.).  

Full list of available companies with available market data can be found here:
```
https://docs.google.com/spreadsheets/d/1dafZyAr7GW99bBmxYi0Ea-WEZCHAycx2TZpJiHdTtc4/edit?usp=sharing
```
 
Prerequisites: ```QuantTools``` package
 
1) You need to generate API keys for demo account at the website: https://developers.exante.eu/ 
 
2) Install package using devtools: 
```
 devtools::install_github("rashitgainullin/ExanteR")
 ```
3) Load AAPL 1min candles from NASDAQ exchange since "2018-01-01":

```
library(ExanteR)
self = Exante$new()
self$appid = "application_id"
self$key = "key"
self$get_candles(symbol = 'AAPL.NASDAQ',from = '2018-01-01',to = '2018-12-12','1min')
```

4) If you need to store market data at you local computer:
```
library( QuantTools )
symbols = c( 'AAPL.NASDAQ', 'FB.NASDAQ' ) 
path = paste( '~' , 'Market Data', 'exante', sep = '/' ) 
start_date = '2015-01-01'

settings <- list( exante_storage = path, exante_storage_from = start_date, exante_symbols = symbols ) 
ExanteR_settings( settings )
store_exante_data( )
```

5) Collect market data from local storage:
```
get_exante_data('AAPL.NASDAQ','2018-01-01','2018-12-12','1min')
```
