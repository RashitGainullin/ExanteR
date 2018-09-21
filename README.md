# ExanteR

Exante is a R package that allow you to load market data of wide range of assets from different exchanges (ex. NASDAQ, NYSE, MICEX etc.).  
 
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
