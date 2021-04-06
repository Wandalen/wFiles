( function _Git_ss_()
{

'use strict';

/**
 * File provider implements strategy for module files to access files over git.
  @module Tools/mid/FilesGit
*/

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../node_modules/Tools' );
  require( '../include/Git.ss' )
  module[ 'exports' ] = _;
}

})();
