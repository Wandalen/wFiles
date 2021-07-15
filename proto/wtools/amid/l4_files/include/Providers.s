( function _Top_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );
  _.include( 'wFilesBasic' );

  /* l7_provider */

  require( './Http.s' );

  if( Config.interpreter === 'njs' )
  require( './Npm.ss' );
  if( Config.interpreter === 'njs' )
  require( './Git.ss' );

  module[ 'exports' ] = _;
}

})();
