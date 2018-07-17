(function _FileTop_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileMid.s' );

  var _global = _global_; var _ = _global_.wTools;

  require( './fprovider/mFindMixin.s' );
  require( './fprovider/mSecondaryMixin.s' );
  require( './fprovider/pExtract.s' );

  if( Config.platform === 'nodejs' )
  {
    require( './fprovider/pHardDrive.ss' );
    require( './fprovider/pUrl.ss' );
  }

  require( './fprovider/rHub.s' );

  try { require( './hfilter/Caching.s' ); } catch( err ) {}
  try { require( './hfilter/CachingContent.s' ); } catch( err ) {}
  try { require( './hfilter/CachingFolders.s' ); } catch( err ) {}
  try { require( './hfilter/Reroot.s' ); } catch( err ) {}

  _.files.pathCurrentAtBegin = _.pathCurrent();

}

var _global = _global_; var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var Self = _global_.wTools;

// --
// define class
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
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
