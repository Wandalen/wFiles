( function _Extract_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );

  // _.include( 'wFilesBasic' );
  require( '../l7_provider/Extract.s' );

  module[ 'exports' ] = _;
}

})();
