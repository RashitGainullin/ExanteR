#' Exante
#' @description Exante API wrapper.
#' @docType class
#' @name Exante
#' @usage NULL
#' @format NULL
# @param name folder name to write logs to
#' @section Methods:
#' See Exante API documentaion for details.Exante = R6::R6Class( 'Exante', lock_objects = F )
#' \describe{
#'   \item{\code{initialize( flog )}}{Initialization. \link{FLog} instance is optional.}
#'   \item{\code{try_request( request )}}{Main method to handle all exceptions during request.}
#'   \item{\code{get( url )}}{GET request wrapper.}
#'   \item{\code{get_candles( symbol, limit = 1000, from = NULL, end = NULL, timeframe = '1m' )}}{Get candles.}
#'   \item{\code{get_ticker_description( symbol, exchange )}}{Get information about particular symbol.}
#'   \item{\code{get_exchanges( )}}{Get own available exchanges.}
#'   \item{\code{get_exchange_description( symbol, from, to, period = '1min' )}}{Get information about particular exchange}
#'   \item{\code{get_transactions(  )}}{Get all transaction.}
#'   \item{\code{get_accounts( account_id, currency )}}{Get all accounts.}
#'   \item{\code{get_account_summary( account_id, currency )}}{Get all summary from account.}
#'   \item{\code{get_orders(  )}}{Get last traded orders.}
#'   \item{\code{get_orders_history(  )}}{Get all traded orders.}
#' }
#' @export
Exante = R6::R6Class( 'Exante', lock_objects = F )

Exante$set( 'public', 'initialize', function( flog = NULL ) {

  self$account_info = list()
  self$timeout = 60
  self$flog$message = base::message
  #check if keys exist
  self$file = 'data/keys.rds'
  if( !file.exists( self$file ) ) message('file with keys not found')

} )


Exante$set( 'public', 'get', function( request, api_type = 'md' ) {

  url = paste0( "https://api-demo.exante.eu/",api_type,"/1.0/",request)
  request = function() httr::GET( url,  httr::timeout( self$timeout ),authenticate(  readRDS( self$file )[1] , readRDS( self$file )[2] ) )

  request

} )

Exante$set( 'public', 'get_ticker_description', function( symbol, exchange ) {

  #example of tickers: "OSIS.NASDAQ", "AAPL.NASDAQ"
  res = self$get( paste0( "symbols/",symbol,".",exchange))
  res = self$try_request( res )
  data.table( t(httr::content( res ) ) )

})

Exante$set( 'public', 'get_exchanges', function( ) {

  res = self$get( paste0( "exchanges" ))
  res = self$try_request( res )
  x = httr::content( res )
  for(i in 1:length(x)) x[[i]][sapply(x[[i]], is.null)] <- NA
  description = rbindlist( lapply( 1:length(x), function(i) data.table( t(  unlist( x[[i]] ) ) ) ) )
  description
})

Exante$set( 'public', 'get_exchange_description', function( exchange ) {

  #example of exchange: "NASDAQ"
  res = self$get( paste0( "exchanges/",exchange))
  res = self$try_request( res )

  x = httr::content( res )
  for(i in 1:length(x)) x[[i]][sapply(x[[i]], is.null)] <- NA

  description = rbindlist( lapply( 1:length(x), function(i) data.table( t(  unlist( x[[i]][-1] ) ) ) ) )
  description = data.table( rbindlist( lapply( 1:length(x), function(i) data.table( ( x[[i]][1] ) ) ) ),description)
  setnames(description,'V1','optionData')
  description

})

Exante$set( 'public', 'get_candles', function( symbol, limit, from, to, period = '1min' ) {

  from = as.integer( fasttime::fastPOSIXct( from ) ) * 1000
  to   = as.integer( fasttime::fastPOSIXct(   to ) ) * 1000

  valid_timeframe = c( '1min' = 60, '5min' = 300, '10min' = 600, '15min' = 900, 'hour' = 3600, '6hour' = 21600, 'day' = 86400 )
  timeframe = valid_timeframe[ period ]
  res = self$get( paste0( "ohlc/",symbol,"/",timeframe,'?from=',from,'&to=',to,'&size=',limit))

  x = self$try_request( res )

  candles = rbindlist( lapply( httr::content( x ) ,setDT) )
  candles[,.(
    time = as.POSIXct(timestamp/1000,origin = '1970-01-01',tz = 'UTC'),
    open,high,low,close
  )]

})

Exante$set( 'public', 'get_transactions', function(  ) {

  res = self$get( paste0( "transactions"))
  res = self$try_request( res )
  rbindlist( lapply( httr::content( res ) ,setDT) )

})

Exante$set( 'public', 'get_accounts', function(  ) {

  res = self$get( paste0( "accounts/"))
  res = self$try_request( res )
  rbindlist( lapply( httr::content( res ) ,setDT) )

})

Exante$set( 'public', 'get_account_summary', function( account_id, currency = "USD" ) {

  res = self$get( paste0( "summary/",account_id,"/",currency))
  res = self$try_request( res )
  req =  httr::content( res )
  self$account_info[[account_id]] = list()
  self$account_info[[account_id]][['general_info']] <- data.table(account_id,rbindlist( lapply( req$currencies ,setDT) ) )
  req$currencies = NULL
  self$account_info[[account_id]][[currency]] <- data.table(t(req))

})

Exante$set( 'public', 'get_orders_history', function(  ) {

  #NOT COMPLETED
  res = self$get( paste0( "stream/orders"),api_type = 'trade')
  self$res = self$try_request( res )

})

Exante$set( 'public', 'get_orders', function(  ) {

  #NOT COMPLETED
  res = self$get( paste0( "orders"),api_type = 'trade')
  res = self$try_request( res )

})

Exante$set( 'public', 'get_trades_history', function(  ) {

  #NOT COMPLETED
  res = self$get( paste0( "stream/trades"),api_type = 'trade')
  res = self$try_request( res )

})

Exante$set( 'public', 'try_request', function( request ) {

  self$time_sent = Sys.time()


  self$response = request()
  h = httr::headers( self$response )
  c = httr::content( self$response )



  if( typeof( c ) == "character" ) {

    self$flog$message( c )
    break

  }
  self$time_response  = as.POSIXct( h$date, format = '%a, %d %B %Y %H:%M:%S GMT', tz = 'UTC' )
  self$time_processed = Sys.time()
  self$response

} )
