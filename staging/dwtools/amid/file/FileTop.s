(function _FileTop_s_() {

'use strict';

// console.log( '_FileTop_s_:begin' );

if( typeof module !== 'undefined' )
{

  require( './FileMid.s' );

  var _ = _global_.wTools;

  if( Config.server )
  {
    require( './fprovider/mPathMixin.ss' );
  }

  require( './fprovider/mFindMixin.s' );
  require( './fprovider/mSecondaryMixin.s' );

  require( './fprovider/pExtract.s' );

  if( Config.server )
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
