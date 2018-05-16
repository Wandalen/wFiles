(function _FileTop_s_() {

'use strict';

// console.log( '_FileTop_s_:begin' );

if( typeof module !== 'undefined' )
{

  require( './FileMid.s' );

  var _ = _global_.wTools;

  // require( './fprovider/aAbstract.s' );
  // require( './fprovider/aPartial.s' );

  // require( './FilesRoutines.ss' );
  _.includeAny( __dirname + '/base/FilesRoutines.ss','' );

  _.includeAny( __dirname + '/fprovider/mPathMixin.ss','' );
  // require( './fprovider/mPathMixin.ss' );
  require( './fprovider/mFindMixin.s' );
  require( './fprovider/mSecondaryMixin.s' );

  require( './fprovider/pExtract.s' );
  // require( './fprovider/pHardDrive.ss' );
  _.includeAny( __dirname + '/fprovider/pHardDrive.ss','' );
  // require( './fprovider/pUrl.ss' );
  _.includeAny( __dirname + '/fprovider/pUrl.ss','' );
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

  _.files.pathCurrentAtBegin = _.pathCurrent();

}

var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var Self = _global_.wTools;

// --
// prototype
// --

var Proto =
{
}

//

_.mapExtend( Self,Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
