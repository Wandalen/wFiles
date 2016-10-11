(function _Files_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  require( './FilePath.ss' );
  if( !wTools.FileRecord )
  require( './FileRecord.s' );
  require( './FilesRoutines.ss' );

  require( './provider/Abstract.s' );
  require( './provider/AdvancedMixin.s' );
  require( './provider/FileProviderCachingFiles.s' );
  require( './provider/FileProviderHardDrive.ss' );
  require( './provider/FileProviderReroot.s' );
  require( './provider/FileProviderSimpleStructure.s' );
  require( './provider/FileProviderUrl.s' );

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
