#' @rdname store_exante_data
#' @export
store_exante_data = function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  save_dir = .settings$exante_storage
  symbols = .settings$exante_symbols

  if( save_dir == '' ) stop( 'please set storage path via ExanteR_settings( \'exante_storage\', \'/storage/path/\' ) ' )
  if( is.null( symbols ) ) stop( 'please set symbols vector via ExanteR_settings( \'exante_symbols\', c( \'symbol_1\', ...,\'symbol_n\' ) ) ' )

  from_is_null = is.null( from )

  for( symbol in symbols ) {

    if( verbose ) message( symbol )
    # minutes
    if( verbose ) message( 'minutes:' )

    if( from_is_null ) from = NULL
    dates_available = gsub( '.rds', '-01', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}.rds' ) )
    if( is.null( from ) && length( dates_available ) == 0 ) {

      from = .settings$exante_storage_from
      if( from == '' ) stop( 'please set Exante storage start date via ExanteR_settings( \'exante_storage_from\', \'YYYYMMDD\' )' )
      message( 'not found in storage, \ntrying to download since storage start date' )

    }
    if( is.null( from ) && to >= max( dates_available ) ) {

      from = max( dates_available )
      message( paste( 'dates to be added:', from, '-', to ) )

    }

    from = as.Date( from )
    to   = as.Date( to )
    exante = Exante$new()

    require(httr)
    require(data.table)

    data.table( from = as.Date( unique( format( seq( from, to, 1 ), '%Y-%m-01' ) ) ) )[, to := shift( from - 1, type = 'lead', fill = to ) ][, {

      month = format( from, '%Y-%m' )

      mins = exante$get_candles( symbol, limit = 9999999, from, to, period = '1min' )

      if( !is.null( mins ) ) {

        dir.create( paste0( save_dir, '/' , symbol ), recursive = TRUE, showWarnings = FALSE )

        saveRDS( mins, file = paste0( save_dir, '/' , symbol, '/', month, '.rds' ) )

        if( verbose ) message( paste( month,  'saved' ) )

      } else {

        if( verbose ) message( paste( month,  'not available' ) )

      }

    }, by = from ]

  }

}
