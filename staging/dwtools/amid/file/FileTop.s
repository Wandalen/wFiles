(function _FileTop_s_() {

'use strict';

// console.log( '_FileTop_s_:begin' );

if( typeof module !== 'undefined' )
{

  require( './FileMid.s' );

  var _ = wTools;

  // require( './fprovider/aAbstract.s' );
  // require( './fprovider/aPartial.s' );

  require( './FilesRoutines.ss' );

  require( './fprovider/mPathMixin.ss' );
  require( './fprovider/mFindMixin.s' );
  require( './fprovider/mSecondaryMixin.s' );

  require( './fprovider/pSimpleStructure.s' );
  require( './fprovider/pHardDrive.ss' );
  require( './fprovider/pUrl.ss' );
  // require( './fprovider/Url.js' );

  require( './fprovider/rHub.s' );

  // _.includeAny( './hfilter/CachingContent.s','' );
  // _.includeAny( './hfilter/Caching.s','' );
  // _.includeAny( './hfilter/Reroot.s','' );

  try { require( './hfilter/Caching.s' ); } catch( err ) {}
  try { require( './hfilter/CachingContent.s' ); } catch( err ) {}
  try { require( './hfilter/CachingFolders.s' ); } catch( err ) {}
  try { require( './hfilter/Reroot.s' ); } catch( err ) {}
  try { require( './hfilter/Archive.s' ); } catch( err ) {}

  // var Path = require( 'path' );
  // var File = require( 'fs-extra' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

// --
// prototype
// --

var Proto =
{
}

//

_.mapExtend( Self,Proto );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

// console.log( '_FileTop_s_:begin' );

})();
