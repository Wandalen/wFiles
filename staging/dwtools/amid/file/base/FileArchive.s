( function _FileArchive_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFileArchive( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  {
    _.assert( arguments.length === 1 );
    return o;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileArchive';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.instanceInit( self );
  Object.preventExtensions( self )

  if( o )
  self.copy( o );

}

//

function contentUpdate( head,data )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var head = _.FileRecord.from( head );
  var dependency = self._dependencyFor( head );

  dependency.info.hash = self._hashFor( data );

  return dependency;
}

//

function statUpdate( head,stat )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var head = _.FileRecord.from( head );
  var dependency = self._dependencyFor( head );

  dependency.info.mtime = stat.mtime;
  dependency.info.ctime = stat.ctime;
  dependency.info.birthtime = stat.birthtime;
  dependency.info.size = stat.size;

  return dependency;
}

//

function dependencyAdd( head,tails )
{
  var self = this;

  _.assert( arguments.length === 2 );

  head = _.FileRecord.from( head );
  tails = _.FileRecord.manyFrom( tails );

  var dependency = self._dependencyFor( head );

  _.arrayAppendArray( dependency.tails , _.entitySelect( tails,'*.relative' ) );

  return dependency;
}

//

function _dependencyFor( head )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( head instanceof _.FileRecord );

  var dependency = self.dependencyMap[ head.relative ];
  if( !dependency )
  {
    dependency = self.dependencyMap[ head.relative ] = Object.create( null );
    dependency.head = head.relative;
    dependency.tails = [];
    dependency.info = Object.create( null );
    dependency.info.hash = null;
    dependency.info.size = null;
    dependency.info.mtime = null;
    dependency.info.ctime = null;
    dependency.info.birthtime = null;
    Object.preventExtensions( dependency );
  }

  return dependency;
}

//

function _hashFor( src )
{

  var result;
  var crypto = require( 'crypto' );
  var md5sum = crypto.createHash( 'md5' );

  try
  {
    md5sum.update( src );
    result = md5sum.digest( 'hex' );
  }
  catch( err )
  {
    throw _.err( err );
  }

  return result;
}

//

function archiveUpdateFileMap()
{
  var self = this;
  var fileProvider = self.fileProvider;
  var time = _.timeNow();
  var foundArchiveFiles = [];

  var fileMapOld = self.fileMap;
  self.fileAddedMap = Object.create( null );
  self.fileRemovedMap = null;
  self.fileModifiedMap = Object.create( null );
  self.fileHashMap = null;

  _.assert( _.strIsNotEmpty( self.trackPath ) || _.strsIsNotEmpty( self.trackPath ) );

  var glob = _.strJoin( self.trackPath, '/**' );
  // if( self.verbosity )
  // debugger;
  if( self.verbosity )
  logger.log( 'archiveUpdateFileMap glob',glob );

  /* */

  function onFileTerminal( d,record,op )
  {
    var d;
    var isDir = record.stat.isDirectory();

    if( fileMapOld[ record.absolute ] )
    {
      d = _.mapExtend( null,fileMapOld[ record.absolute ] );
      delete fileMapOld[ record.absolute ];
      var same = d.mtime === record.stat.mtime.getTime() && d.birthtime === record.stat.birthtime.getTime() && ( isDir || d.size === record.stat.size );
      if( same && self.trackingHardLinks && !isDir )
      same = d.nlink === record.stat.nlink;

      if( same )
      {
        return d;
      }
      else
      {
        self.fileModifiedMap[ record.absolute ] = _.mapExtend( null,d );
      }
    }
    else
    {
      d = Object.create( null );
      self.fileAddedMap[ record.absolute ] = d;
    }

    d.mtime = record.stat.mtime.getTime();
    d.birthtime = record.stat.birthtime.getTime();
    d.absolutePath = record.absolute;
    if( !isDir )
    {
      d.size = record.stat.size;
      d.hash = fileProvider.fileHash( record.absolute );
      d.hash2 = _.statsHash2Get( record.stat );
      d.nlink = record.stat.nlink;
    }
    return d;
  }

  /* */

  function onFileDir( d,record,op )
  {
    var archiveMapPath = _.pathJoin( record.absolute , self.archiveFileName );
    if( fileProvider.fileStat( archiveMapPath ) )
    {
      var mapExtend = fileProvider.fileReadJson( archiveMapPath );
      _.mapExtend( fileMapOld,mapExtend );
      foundArchiveFiles.push( archiveMapPath );
    }
    return onFileTerminal( d,record,op );
  }

  /* */

  var excludeMask = _.regexpMakeObject
  ({
    excludeAny :
    [
      'node_modules',
      '.unique',
      '.git',
      '.svn',
      '.hg',
      /\.tmp(?=$|\/|\.)/,
      /(^|\/)\.(?!$|\/|\.)/,
    ],
  });

  var fileMapNew = _.FileProvider.SimpleStructure.filesTreeRead
  ({
    srcProvider : fileProvider,
    glob : glob,
    asFlatMap : 1,
    readingTerminals : 0,
    maskAll : excludeMask,
    onFileTerminal : onFileTerminal,
    onFileDir : onFileDir,
  });

  self.fileRemovedMap = fileMapOld;
  self.fileMap = fileMapNew;

  if( self.fileMapAutosaving )
  {
    var archiveFilePath = _.pathJoin( self.trackPath , self.archiveFileName );
    fileProvider.fileWriteJson
    ({
      filePath : archiveFilePath,
      data : self.fileMap,
      pretty : 1,
    });
  }

  if( self.verbosity > 2 )
  {
    logger.log( 'fileAddedMap',self.fileAddedMap );
    logger.log( 'fileRemovedMap',self.fileRemovedMap );
    logger.log( 'fileModifiedMap',self.fileModifiedMap );
  }
  else if( self.verbosity > 1 )
  {
    logger.log( 'fileAddedMap', _.entityLength( self.fileAddedMap ) );
    logger.log( 'fileRemovedMap', _.entityLength( self.fileRemovedMap ) );
    logger.log( 'fileModifiedMap', _.entityLength( self.fileModifiedMap ) );
  }

  if( self.verbosity )
  {
    logger.log( _.entityLength( fileMapNew ),'file(s)' );
    logger.log( _.timeSpent( 'Spent',time ) );
  }

  return self;
}

//

function fileHashMapForm()
{
  var self = this;

  self.fileHashMap = Object.create( null );

  for( var f in self.fileMap )
  {
    var file = self.fileMap[ f ];
    if( file.hash )
    if( self.fileHashMap[ file.hash ] )
    self.fileHashMap[ file.hash ].push( file.absolutePath );
    else
    self.fileHashMap[ file.hash ] = [ file.absolutePath ];
  }

  // debugger;
  // for( var h in self.fileHashMap )
  // logger.log( self.fileHashMap[ h ].length, _.toStr( self.fileHashMap[ h ],{ levels : 3, wrap : 0 } ) );

  return self.fileHashMap;
}

//

function restoreLinksBegin()
{
  var archive = this;
  var provider = archive.fileProvider;

  archive.archiveUpdateFileMap();

}

//

function restoreLinksEnd()
{
  var archive = this;
  var provider = archive.fileProvider;
  var fileMap1 = _.mapExtend( null,archive.fileMap );
  var fileHashMap = archive.fileHashMapForm();

  _.assert( archive.fileMap,'restoreLinksBegin should be called before calling restoreLinksEnd' );

  archive.archiveUpdateFileMap();

  var fileMap2 = _.mapExtend( null,archive.fileMap );
  var fileModifiedMap = archive.fileModifiedMap;

  for( var f in fileModifiedMap )
  if( fileModifiedMap[ f ].hash !== undefined )
  debugger;

  for( var f in fileModifiedMap )
  if( fileModifiedMap[ f ].hash !== undefined )
  provider.fileTouch( f );

  for( var f in fileModifiedMap )
  {
    var modified = fileModifiedMap[ f ];
    var filesWithHash = fileHashMap[ modified.hash ];

    if( modified.hash === undefined )
    continue;

    filesWithHash = _.entityFilter( filesWithHash,( e ) => fileMap2[ e ] ? fileMap1[ e ] : undefined );

    // qqq
    // filesWithHash.sort( function( e1,e2 )
    // {
    //   return e1.hash2-e2.hash2
    // });

    filesWithHash.sort( ( e1,e2 ) => e1.hash2-e2.hash2 );

    if( archive.verbosity > 1 )
    logger.log( 'modified',_.entitySelect( filesWithHash,'*.absolutePath' ) );

    var first = 0;
    var hash2 = null;
    for( var last = 0 ; last < filesWithHash.length ; last++ )
    {
      var file = filesWithHash[ last ];
      if( hash2 === null )
      hash2 = file.hash2;
      if( hash2 !== file.hash2 )
      {
        if( last - first > 1 )
        {
          debugger;
          var filePaths = _.entitySelect( filesWithHash.slice( first,last ), '*.absolutePath' );
          provider.linkHard({ filePaths : filePaths });
        }
        first = last;
      }
    }

    debugger;
    var filePaths = _.entitySelect( filesWithHash.slice( first,last ), '*.absolutePath' );
    provider.linkHard({ filePaths : filePaths });
    debugger;

  }

}

// --
//
// --

function _verbositySet( val )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( !_.numberIs( val ) )
  val = val ? 1 : 0;
  if( val < 0 )
  val = 0;

  self[ verbositySymbol ] = val;
}

// --
//
// --

var verbositySymbol = Symbol.for( 'verbosity' );

var Composes =
{
  verbosity : 2,

  trackPath : null,
  trackingHardLinks : 0,

  dependencyMap : Object.create( null ),
  fileByHashMap : Object.create( null ),

  fileMap : Object.create( null ),
  fileAddedMap : Object.create( null ),
  fileRemovedMap : Object.create( null ),
  fileModifiedMap : Object.create( null ),

  fileHashMap : null,

  fileMapAutosaving : 0,

  archiveFileName : '.warchive',
}

var Aggregates =
{
}

var Associates =
{
  fileProvider : null,
}

var Restricts =
{
}

var Statics =
{
}

var Forbids =
{
}

var Accessors =
{
  verbosity : 'verbosity',
}

// --
// prototype
// --

var Proto =
{

  init : init,

  contentUpdate : contentUpdate,
  statUpdate : statUpdate,

  dependencyAdd : dependencyAdd,
  _dependencyFor : _dependencyFor,

  _hashFor : _hashFor,

  archiveUpdateFileMap : archiveUpdateFileMap,

  fileHashMapForm : fileHashMapForm,

  restoreLinksBegin : restoreLinksBegin,
  restoreLinksEnd : restoreLinksEnd,

  //

  _verbositySet : _verbositySet,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.Copyable.mixin( Self );
_global_[ Self.name ] = _[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
