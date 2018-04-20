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
  var archive = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.instanceInit( archive );
  Object.preventExtensions( archive )

  if( o )
  archive.copy( o );

}

//

function contentUpdate( head,data )
{
  var archive = this;

  _.assert( arguments.length === 2 );

  var head = _.FileRecord.from( head );
  var dependency = archive._dependencyFor( head );

  dependency.info.hash = archive._hashFor( data );

  return dependency;
}

//

function statUpdate( head,stat )
{
  var archive = this;

  _.assert( arguments.length === 2 );

  var head = _.FileRecord.from( head );
  var dependency = archive._dependencyFor( head );

  dependency.info.mtime = stat.mtime;
  dependency.info.ctime = stat.ctime;
  dependency.info.birthtime = stat.birthtime;
  dependency.info.size = stat.size;

  return dependency;
}

//

function dependencyAdd( head,tails )
{
  var archive = this;

  _.assert( arguments.length === 2 );

  head = _.FileRecord.from( head );
  tails = _.FileRecord.manyFrom( tails );

  var dependency = archive._dependencyFor( head );

  _.arrayAppendArray( dependency.tails , _.entitySelect( tails,'*.relative' ) );

  return dependency;
}

//

function _dependencyFor( head )
{
  var archive = this;

  _.assert( arguments.length === 1 );
  _.assert( head instanceof _.FileRecord );

  var dependency = archive.dependencyMap[ head.relative ];
  if( !dependency )
  {
    dependency = archive.dependencyMap[ head.relative ] = Object.create( null );
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
  var archive = this;
  var fileProvider = archive.fileProvider;
  var time = _.timeNow();
  var foundArchiveFiles = [];

  var fileMapOld = archive.fileMap;
  archive.fileAddedMap = Object.create( null );
  archive.fileRemovedMap = null;
  archive.fileModifiedMap = Object.create( null );
  archive.fileHashMap = null;

  _.assert( _.strIsNotEmpty( archive.trackPath ) || _.strsIsNotEmpty( archive.trackPath ) );

  var glob = _.strJoin( archive.trackPath, '/**' );
  if( archive.verbosity )
  logger.log( 'archiveUpdateFileMap glob',glob );

  /* */

  function onFile( d,record,op )
  {
    var d;
    var isDir = record.stat.isDirectory();

    if( fileMapOld[ record.absolute ] )
    {
      d = _.mapExtend( null,fileMapOld[ record.absolute ] );
      delete fileMapOld[ record.absolute ];
      var same = d.mtime === record.stat.mtime.getTime() && d.birthtime === record.stat.birthtime.getTime() && ( isDir || d.size === record.stat.size );
      if( same && archive.comparingRelyOnHardLinks && !isDir )
      {
        if( d.nlink === 1 )
        debugger;
        same = d.nlink === record.stat.nlink;
      }

      if( same )
      {
        return d;
      }
      else
      {
        // archive.fileModifiedMap[ record.absolute ] = _.mapExtend( null,d );
        archive.fileModifiedMap[ record.absolute ] = d;
        d = _.mapExtend( null,d );
      }
    }
    else
    {
      d = Object.create( null );
      archive.fileAddedMap[ record.absolute ] = d;
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
    var archiveMapPath = _.pathJoin( record.absolute , archive.archiveFileName );
    if( fileProvider.fileStat( archiveMapPath ) )
    {
      var mapExtend = fileProvider.fileReadJson( archiveMapPath );
      _.mapExtend( fileMapOld,mapExtend );
      foundArchiveFiles.push( archiveMapPath );
    }
    return onFile( d,record,op );
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
    onFileTerminal : onFile,
    onFileDir : onFileDir,
  });

  archive.fileRemovedMap = fileMapOld;
  archive.fileMap = fileMapNew;

  if( archive.fileMapAutosaving )
  {
    var archiveFilePath = _.pathJoin( archive.trackPath , archive.archiveFileName );
    fileProvider.fileWriteJson
    ({
      filePath : archiveFilePath,
      data : archive.fileMap,
      pretty : 1,
    });
  }

  if( archive.verbosity > 2 )
  {
    logger.log( 'fileAddedMap',archive.fileAddedMap );
    logger.log( 'fileRemovedMap',archive.fileRemovedMap );
    logger.log( 'fileModifiedMap',archive.fileModifiedMap );
  }
  else if( archive.verbosity > 1 )
  {
    logger.log( 'fileAddedMap', _.entityLength( archive.fileAddedMap ) );
    logger.log( 'fileRemovedMap', _.entityLength( archive.fileRemovedMap ) );
    logger.log( 'fileModifiedMap', _.entityLength( archive.fileModifiedMap ) );
  }

  if( archive.verbosity )
  {
    logger.log( _.entityLength( fileMapNew ),'file(s)' );
    logger.log( _.timeSpent( 'Spent',time ) );
  }

  return archive;
}

//

function fileHashMapForm()
{
  var archive = this;

  archive.fileHashMap = Object.create( null );

  for( var f in archive.fileMap )
  {
    var file = archive.fileMap[ f ];
    if( file.hash )
    if( archive.fileHashMap[ file.hash ] )
    archive.fileHashMap[ file.hash ].push( file.absolutePath );
    else
    archive.fileHashMap[ file.hash ] = [ file.absolutePath ];
  }

  // debugger;
  // for( var h in archive.fileHashMap )
  // logger.log( archive.fileHashMap[ h ].length, _.toStr( archive.fileHashMap[ h ],{ levels : 3, wrap : 0 } ) );

  return archive.fileHashMap;
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

  archive.archiveUpdateFileMap();

  _.assert( archive.fileMap,'restoreLinksBegin should be called before calling restoreLinksEnd' );

  var fileMap2 = _.mapExtend( null,archive.fileMap );
  var fileModifiedMap = archive.fileModifiedMap;
  var linkedMap = Object.create( null );

  /* */

  for( var f in fileModifiedMap )
  {
    var modified = fileModifiedMap[ f ];
    var filesWithHash = fileHashMap[ modified.hash ];

    if( linkedMap[ f ] )
    continue;

    if( modified.hash === undefined )
    continue;

    /* remove removed files and use old file descriptors */

    filesWithHash = _.entityFilter( filesWithHash,( e ) => fileMap2[ e ] ? fileMap2[ e ] : undefined );

    /* find newest file */

    if( archive.replacingByNewest )
    filesWithHash.sort( ( e1,e2 ) => e2.mtime-e1.mtime );
    else
    filesWithHash.sort( ( e1,e2 ) => e1.mtime-e2.mtime );

    /* use old file descriptors */

    filesWithHash = _.entityFilter( filesWithHash,( e ) => fileMap1[ e.absolutePath ] );

    /* verbosity */

    if( archive.verbosity > 1 )
    logger.log( 'modified',_.entitySelect( filesWithHash,'*.absolutePath' ) );

    /*  */

    var first = 0;
    var srcPath = filesWithHash[ first ].absolutePath;
    var srcFile = filesWithHash[ first ];
    linkedMap[ srcPath ] = filesWithHash[ first ];
    for( var last = 1 ; last < filesWithHash.length ; last++ )
    {
      var dstPath = filesWithHash[ last ].absolutePath;
      if( linkedMap[ dstPath ] )
      continue;
      var dstFile = filesWithHash[ last ];
      /* if this files where linked before changes, relink them */
      if( srcFile.hash2 === dstFile.hash2 )
      {
        provider.linkHard({ dstPath : dstPath, srcPath : srcPath });
        linkedMap[ dstPath ] = filesWithHash[ last ];
      }
    }

  }

}

// --
//
// --

function _verbositySet( val )
{
  var archive = this;

  _.assert( arguments.length === 1 );

  if( !_.numberIs( val ) )
  val = val ? 1 : 0;
  if( val < 0 )
  val = 0;

  archive[ verbositySymbol ] = val;
}

// --
//
// --

var verbositySymbol = Symbol.for( 'verbosity' );

var Composes =
{
  verbosity : 2,

  trackPath : null,

  comparingRelyOnHardLinks : 0,
  replacingByNewest : 1,

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
