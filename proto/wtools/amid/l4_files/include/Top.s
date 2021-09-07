( function _Top_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );
  _.include( 'wFilesBasic' );

  /* l7_provider */

  _.include( 'wFilesHttp' );

  if( Config.interpreter === 'njs' )
  _.include( 'wFilesNpm' );
  if( Config.interpreter === 'njs' )
  _.include( 'wFilesGit' );

  require( './Operator.s' );

  /* l8_filter */

  require( '../l8_filter/Image.s' );

  require( './Reroot.s' ); /* qqq : split module */

  /* l9 */

  require( '../l9/Namespace.s' );

  _.assert( _.path.currentAtBeginGet() !== undefined );

  module[ 'exports' ] = _;
}

})();
