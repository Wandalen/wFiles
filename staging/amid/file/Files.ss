(function _Files_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );

  var _ = wTools;

  if( !wTools.FileRecord )
  require( './FileRecord.s' );
  if( !wTools.FileRecordOptions )
  require( './FileRecordOptions.s' );

  require( './provider/Path.ss' );
  require( './FilesRoutines.ss' );

  require( './provider/Abstract.s' );
  require( './provider/AdvancedMixin.s' );
  require( './provider/FileProviderSimpleStructure.s' );

  require( './provider/FileProviderHardDrive.ss' );
  require( './provider/FileProviderUrl.ss' );
  // require( './provider/FileProviderUrl.js' );

  _.includeAny( './wrap/FileProviderCachingFiles.s','' );
  _.includeAny( './wrap/FileProviderCaching.s','' );
  _.includeAny( './wrap/FileProviderReroot.s','' );

}

var Path = require( 'path' );
var File = require( 'fs-extra' );

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

// --
// prototype
// --

var Proto =
{
}

_.mapExtend( Self,Proto );

Self.FileProvider = Self.FileProvider || {};
wTools.files = _.mapExtend( wTools.files || {},Proto );
wTools.files.usingReadOnly = 0;
wTools.files.pathCurrentAtBegin = _.pathCurrent();

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
