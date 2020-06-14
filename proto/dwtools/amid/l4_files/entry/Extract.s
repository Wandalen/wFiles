(function _Extract_s_() {

'use strict';

/**
 * File provider implements strategy for module files to access files in JS structure.
  @module Tools/mid/FilesExtract
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../dwtools/Tools.s' );
  require( '../include/Extract.s' )
  module[ 'exports' ] = _;
}

})();
