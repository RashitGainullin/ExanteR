#' @rdname settings
#' @export
ExanteR_settings = function( settings = NULL ){

  if( is.list( settings ) ) {

    if( !is.null( names( settings ) ) ) x = lapply( seq_along( settings ), function( i ) assign( names( settings )[i], settings[[i]], envir = .settings ) )

    return( message('') )
  }
  if( is.vector( settings, mode = 'character' ) ) {

    return( mget( settings, envir = .settings ) )

  }
  if( is.null( settings ) ) {

    return( mget( ls( envir = .settings ), envir = .settings ) )

  }
  stop( 'settings can be NULL, named list or character vector' )

}
#' @rdname settings
#' @export
ExanteR_settings_defaults = function() {

  .settings$exante_storage = paste( path.expand('~') , 'Market Data', 'exante', sep = '/' )

  .settings$exante_verbose = FALSE
  .settings$exante_storage_from = '2015-01-01'

  .settings$exante_symbols = c( 'GAZP.MOEX', 'AAPL.NASDAQ' )

}
.settings <- new.env()

ExanteR_settings_defaults()

