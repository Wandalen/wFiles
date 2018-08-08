(function _UseMid_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './UseBase.s' );
  var _global = _global_;
  var _ = _global_.wTools;

  _.assert( !!_.FieldsStack );

  if( !_global_.wTools.FileStat )
  require( './base/FileStat.s' );
  if( !_global_.wTools.FileRecord )
  require( './base/FileRecord.s' );
  if( !_global_.wTools.FileRecordContext )
  require( './base/FileRecordContext.s' );
  if( !_global_.wTools.FileRecordFilter )
  require( './base/FileRecordFilter.s' );

  require( './base/FileRoutines.s' );

  require( './fprovider/aAbstract.s' );
  require( './fprovider/aPartial.s' );

  require( './base/Path.s' );
  if( Config.platform === 'nodejs' )
  require( './base/Path.ss' );

  if( !_global_.wTools.FileProvider.Find )
  require( './fprovider/mFindMixin.s' );

  if( !_global_.wTools.FileProvider.Secondary )
  require( './fprovider/mSecondaryMixin.s' );

}
var _global = _global_;
var _ = _global_.wTools;
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

Self.FileProvider = Self.FileProvider || Object.create( null );
Self.FileFilter = Self.FileFilter || Object.create( null );

_.files = _.mapExtend( _.files || Object.create( null ),Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
