(function _UseMid_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './UseBase.s' );
  var _global = _global_;
  var _ = _global_.wTools;

  _.assert( !!_.FieldsStack );

  _.assert( !_.FileRecord );
  _.assert( !_.FileRecordFactory );
  _.assert( !_.FileRecordFilter );
  _.assert( !_.FileStat );

  require( './l1/Encoders.s' );

  // if( !_global_.wTools.FileStat )
  require( './l1/FileStat.s' );
  // if( !_global_.wTools.FileRecord )
  require( './l1/FileRecord.s' );
  // if( !_global_.wTools.FileRecordFactory )
  require( './l1/FileRecordFactory.s' );
  // if( !_global_.wTools.FileRecordFilter )
  require( './l1/FileRecordFilter.s' );

  require( './l1/FileRoutines.s' );

  require( './l1/Path.s' );
  if( Config.platform === 'nodejs' )
  require( './l1/Path.ss' );

  /* */

  require( './l2/Abstract.s' );
  require( './l2/Partial.s' );
  if( !_global_.wTools.FileProvider.Find )
  require( './l3/FindMixin.s' );
  if( !_global_.wTools.FileProvider.Secondary )
  require( './l3/SecondaryMixin.s' );

}

var _global = _global_;
var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var Self = _global_.wTools;

// --
// declare
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
{ /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
