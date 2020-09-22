( function _Http_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );

  // _.include( 'wFilesBasic' );
  if( Config.interpreter === 'browser' )
  require( '../l7_provider/Http.js' );
  if( Config.interpreter === 'njs' )
  require( '../l7_provider/Http.ss' );

  module[ 'exports' ] = _;
}

})();
