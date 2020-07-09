(function _Http_s_() {

'use strict';

/**
 * File provider implements strategy for module files to access files over HTTP / HTTPS protocol.
  @module Tools/mid/FilesHttp
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );
  require( '../include/Http.s' )
  module[ 'exports' ] = _;
}

})();
