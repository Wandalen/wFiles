(function _Top_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( './Mid.s' );

  debugger;

  /* l7_provider */

  require( './Extract.s' );
  if( Config.interpreter === 'njs' )
  require( './HardDrive.ss' );
  require( './Http.s' );

  // xxx
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

  // /* l5 */
  //
  // require( './l7_provider/Extract.s' );
  //
  // if( Config.interpreter === 'njs' )
  // require( './l7_provider/HardDrive.ss' );
  // if( Config.interpreter === 'njs' )
  // require( './l7_provider/Http.ss' );
  //
  // if( Config.interpreter === 'njs' )
  // require( './l7_provider/Git.ss' );
  // if( Config.interpreter === 'njs' )
  // require( './l7_provider/Npm.ss' );
  //
  // if( Config.interpreter === 'browser' )
  // require( './l7_provider/Http.js' );
  // if( Config.interpreter === 'browser' )
  // require( './l7_provider/HtmlDocument.js' );
  //
  // /* l7 */
  //
  // require( './l7/System.s' );
  //
  // /* l8 */
  //
  // try { if( Config.interpreter === 'njs' ) require( './l8_filter/Caching.s' ); } catch( err ) {}
  // try { if( Config.interpreter === 'njs' ) require( './l8_filter/CachingContent.s' ); } catch( err ) {}
  // try { if( Config.interpreter === 'njs' ) require( './l8_filter/CachingFolders.s' ); } catch( err ) {}
  // try { require( './l8_filter/Reroot.s' ); } catch( err ) {}
  //
  // require( './l8_filter/Image.s' );
  //
  // _.path.currentAtBegin = _.path.current();

  debugger;

  module[ 'exports' ] = _;
}

})();
