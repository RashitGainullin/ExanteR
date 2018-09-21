#' @rdname get_exante_data
#' @export
get_exante_data = function( symbol, from = NULL, to = format( Sys.Date() ), period ) {

    require(data.table)
    require(QuantTools)

    data_dir = .settings$exante_storage

    if( data_dir == '' ) stop( paste0('please set storage path via ExanteR_settings( \'', source, '_storage\', \'/storage/path/\' )
                                      use store_', source, '_data to add some data into the storage' ) )

    if( period == '1min' ) {

      months_available = gsub( '.rds', '', list.files( paste( data_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}.rds' ) )

      months_to_load = sort( months_available[ months_available %bw% substr( c( from, to ), 1, 7 ) ] )

      if( length( months_to_load ) == 0 ) return( NULL )
      data = vector( length( months_to_load ), mode = 'list' )
      names( data ) = months_to_load

      for( month in months_to_load ) data[[ month ]] = readRDS( file = paste0( data_dir, '/' , symbol, '/', month, '.rds' ) )

      data = rbindlist( data )#[ as.Date( time ) %bw% as.Date( c( from, to ) )  ]

      time_range = as.POSIXct( format( as.Date( c( from, to ) ) + c( 0, 1 ) ), 'UTC' )

      time = NULL
      if( !is.null( data ) ) data = data[ time > time_range[1] & time < time_range[2] ]

      return( data )

    }
    if( is.null( data ) ) return( NULL )

    switch( period,
            '1min'  = { n =  1; units = 'mins' },
            '5min'  = { n =  5; units = 'mins' },
            '10min' = { n = 10; units = 'mins' },
            '15min' = { n = 15; units = 'mins' },
            '30min' = { n = 30; units = 'mins' },
            'hour'  = { n =  1; units = 'hour' },
            'day'   = { n =  1; units = 'days' }
    )

    open = high = low = close = volume = NULL
    data = data[ , list( open = open[1], high = max( high ), low = min( low ), close = close[.N], volume = sum( volume ) ), by = list( time = ceiling_POSIXct( time, n, units ) ) ]
    if( period == 'day' ) {

      data[, time := as.Date( time ) - 1 ]
      setnames( data, 'time', 'date' )

    }
    return( data )
  }
