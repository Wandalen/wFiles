( function _Top_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( './Mid.s' );

  /* l7_provider */

  require( './Extract.s' );
  if( Config.interpreter === 'njs' )
  require( './HardDrive.ss' );
  require( './Http.s' );

  if( Config.interpreter === 'njs' )
  require( './Npm.ss' );
  if( Config.interpreter === 'njs' )
  require( './Git.ss' );

  /* l8_filter */

  require( '../l8_filter/Image.s' );

  require( './Reroot.s' ); /* qqq : split module */

  /* l9 */

  require( '../l9/Namespace.s' );

  _.assert( _.path.currentAtBegin !== undefined );

  module[ 'exports' ] = _;
}

})();
