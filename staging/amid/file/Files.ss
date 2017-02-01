(function _Files_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  require( './provider/PathMixin.ss' );
  if( !wTools.FileRecord )
  require( './FileRecord.s' );
  require( './FilesRoutines.ss' );

  require( './provider/Abstract.s' );
  require( './provider/AdvancedMixin.s' );
  require( './provider/FileProviderHardDrive.ss' );
  require( './provider/FileProviderSimpleStructure.s' );
  require( './provider/FileProviderUrl.ss' );
  require( './provider/FileProviderUrl.js' );

  require( './wrap/FileProviderCachingFiles.s' );
  require( './wrap/FileProviderReroot.s' );

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
