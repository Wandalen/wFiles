( function _Imap_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );

  _.include( 'wFiles' );
  _.include( 'wCensorBasic' );
  _.include( 'wResolver' );

  require( '../l7_provider/Imap.ss' );

  module[ 'exports' ] = _;
}

})();
