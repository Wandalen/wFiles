(function _FileMid_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );

  var _ = wTools;

  if( !wTools.FileRecord )
  require( './FileRecord.s' );
  if( !wTools.FileRecordOptions )
  require( './FileRecordOptions.s' );

  require( './Path.ss' );
  require( './FilesRoutines.ss' );

  require( './aprovider/Abstract.s' );
  require( './aprovider/AdvancedMixin.s' );
  require( './aprovider/SimpleStructure.s' );

  require( './aprovider/HardDrive.ss' );
  require( './aprovider/Url.ss' );
  // require( './aprovider/Url.js' );

  _.includeAny( './filter/CachingContent.s','' );
  _.includeAny( './filter/Caching.s','' );
  _.includeAny( './filter/Reroot.s','' );

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

_.mapExtend( Self,Proto );

Self.FileProvider = Self.FileProvider || Object.create( null );
Self.FileFilter = Self.FileFilter || Object.create( null );

wTools.files = _.mapExtend( wTools.files || Object.create( null ),Proto );
wTools.files.usingReadOnly = 0;
wTools.files.pathCurrentAtBegin = _.pathCurrent();

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
