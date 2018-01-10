(function _FileMid_s_() {

'use strict';

// console.log( '_FileMid_s_:begin' );

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );

  var _ = wTools;

  _.assert( _global_.wFieldsStack );
  // console.log( '_FileMid_s_',_global_.wFieldsStack );

  if( !wTools.FileStat )
  require( './base/FileStat.s' );
  if( !wTools.FileRecord )
  require( './base/FileRecord.s' );
  if( !wTools.FileRecordOptions )
  require( './base/FileRecordOptions.s' );

  require( './base/Path.ss' );
  require( './base/FileArchive.s' );

  require( './fprovider/aAbstract.s' );
  require( './fprovider/aPartial.s' );

  if( !wTools.FileProvider.Path )
  require( './fprovider/mPathMixin.ss' );

  if( !wTools.FileProvider.Find )
  require( './fprovider/mFindMixin.s' );

  if( !wTools.FileProvider.Secondary )
  require( './fprovider/mSecondaryMixin.s' );

  // require( './fprovider/mPathMixin.ss' );
  // require( './fprovider/mFindMixin.s' );
  // require( './fprovider/mSecondaryMixin.s' );

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

Self.FileProvider = Self.FileProvider || Object.create( null );
Self.FileFilter = Self.FileFilter || Object.create( null );

wTools.files = _.mapExtend( wTools.files || Object.create( null ),Proto );
// wTools.files.usingReadOnly = 0;
wTools.files.pathCurrentAtBegin = _.pathCurrent();

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
