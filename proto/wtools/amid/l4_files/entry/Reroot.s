( function _Reroot_s_()
{

'use strict';

/**
 * Experimental. File filter to change the root of the file system virtually.
  @module Tools/mid/FilesReroot
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );
  require( '../include/Reroot.s' )
  module[ 'exports' ] = _;
}

})();
