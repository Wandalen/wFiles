( function _FilesArchive_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFilesArchive( o )
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

Self.nameShort = 'FilesArchive';

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
//
// function _storageSave( o )
// {
//   var archive = this;
//   var fileProvider = archive.fileProvider;
//
//   _.assert( arguments.length === 1 );
//
//   if( archive.verbosity >= 3 )
//   logger.log( '+ saving archive',o.archiveFilePath );
//
//   var map = archive.fileMap;
//   if( o.splitting )
//   {
//     var archiveDirPath = _.pathDir( o.archiveFilePath );
//     map = Object.create( null );
//     for( var m in archive.fileMap )
//     {
//       if( _.strBegins( m,archiveDirPath ) )
//       map[ m ] = archive.fileMap[ m ];
//     }
//   }
//
//   fileProvider.fileWriteJson
//   ({
//     filePath : o.archiveFilePath,
//     data : map,
//     pretty : 1,
//     sync : 1,
//   });
//
// }
//
// _storageSave.defaults =
// {
//   archiveFilePath : null,
//   splitting : 0,
// }
//
// //
//
// function storageSave()
// {
//   var archive = this;
//   var fileProvider = archive.fileProvider;
//   var archiveFilePath = _.pathsJoin( archive.trackPath , archive.storageFileName );
//
//   _.assert( arguments.length === 0 );
//
//   if( _.arrayIs( archiveFilePath ) )
//   for( var p = 0 ; p < archiveFilePath.length ; p++ )
//   archive._storageSave
//   ({
//     archiveFilePath : archiveFilePath[ p ],
//     splitting : 1,
//   })
//   else
//   archive._storageSave
//   ({
//     archiveFilePath : archiveFilePath,
//     splitting : 0,
//   });
//
// }
//
// //
//
// function storageLoad( archiveDirPath )
// {
//   var archive = this;
//   var fileProvider = archive.fileProvider;
//   var archiveFilePath = _.pathJoin( archiveDirPath , archive.storageFileName );
//
//   _.assert( arguments.length === 1 );
//
//   if( !fileProvider.fileStat( archiveFilePath ) )
//   return false;
//
//   for( var f = 0 ; f < archive.loadedStorages.length ; f++ )
//   {
//     var loadedArchive = archive.loadedStorages[ f ];
//     if( _.strBegins( archiveDirPath,loadedArchive.dirPath ) && ( archiveFilePath !== loadedArchive.filePath ) )
//     return false;
//   }
//
//   if( archive.verbosity >= 3 )
//   logger.log( '. loading archive',archiveFilePath );
//   var mapExtend = fileProvider.fileReadJson( archiveFilePath );
//   _.mapExtend( archive.fileMap,mapExtend );
//
//   archive.loadedStorages.push({ dirPath : archiveDirPath, filePath : archiveFilePath });
//
//   return true;
// }

//

function filesUpdate()
{
  var archive = this;
  var fileProvider = archive.fileProvider;
  var time = _.timeNow();

  var fileMapOld = archive.fileMap;
  archive.fileAddedMap = Object.create( null );
  archive.fileRemovedMap = null;
  archive.fileModifiedMap = Object.create( null );
  archive.fileHashMap = null;

  _.assert( _.strIsNotEmpty( archive.trackPath ) || _.strsAreNotEmpty( archive.trackPath ) );

  var globIn = _.strJoin( archive.trackPath, '/**' );
  if( archive.verbosity >= 3 )
  logger.log( 'filesUpdate globIn',globIn );

  /* */

  var fileMapNew = Object.create( null );
  function onFile( record,op )
  {
    var d = null;
    var isDir = record.stat.isDirectory();

    // if( _.strHas( record.relative,'StringTools2.test.s' ) )
    // debugger;

    if( isDir )
    if( archive.fileMapAutoLoading )
    archive.storageLoad( record.absolute );

    if( archive.verbosity >= 5 )
    logger.log( 'investigating ' + record.absolute );

    if( fileMapOld[ record.absolute ] )
    {
      d = _.mapExtend( null,fileMapOld[ record.absolute ] );
      delete fileMapOld[ record.absolute ];
      // debugger;
      var same = true
      same = same && d.mtime === record.stat.mtime.getTime();
      // same = same && d.ctime === record.stat.ctime.getTime();
      same = same && d.birthtime === record.stat.birthtime.getTime();
      same = same && ( isDir || d.size === record.stat.size );
      if( same && archive.comparingRelyOnHardLinks && !isDir )
      {
        if( d.nlink === 1 )
        debugger;
        same = d.nlink === record.stat.nlink;
      }

      if( same )
      {
        fileMapNew[ d.absolutePath ] = d;
        return d;
      }
      else
      {
        if( archive.verbosity >= 3 )
        logger.log( 'change ' + record.absolute );
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
    d.ctime = record.stat.ctime.getTime();
    d.birthtime = record.stat.birthtime.getTime();
    d.absolutePath = record.absolute;
    if( !isDir )
    {
      d.size = record.stat.size;
      if( archive.maxSize === null || record.stat.size <= archive.maxSize )
      d.hash = fileProvider.fileHash( record.absolute );
      d.hash2 = _.statsHash2Get( record.stat );
      d.nlink = record.stat.nlink;
    }

    fileMapNew[ d.absolutePath ] = d;
    return d;
  }

  /* */

  archive.mask = _.regexpMakeObject( archive.mask );

  debugger;
  var files = fileProvider.filesFind
  ({
    globIn : globIn,
    maskAll : archive.mask,
    onUp : onFile,
    includingTerminals : 1,
    includingDirectories : 1,
    recursive : 1,
  });
  debugger;

  archive.fileRemovedMap = fileMapOld;
  archive.fileMap = fileMapNew;

  if( archive.fileMapAutosaving )
  archive.storageSave();

  if( archive.verbosity >= 5 )
  {
    logger.log( 'fileAddedMap',archive.fileAddedMap );
    logger.log( 'fileRemovedMap',archive.fileRemovedMap );
    logger.log( 'fileModifiedMap',archive.fileModifiedMap );
  }
  else if( archive.verbosity >= 4 )
  {
    logger.log( 'fileAddedMap', _.entityLength( archive.fileAddedMap ) );
    logger.log( 'fileRemovedMap', _.entityLength( archive.fileRemovedMap ) );
    logger.log( 'fileModifiedMap', _.entityLength( archive.fileModifiedMap ) );
  }

  if( archive.verbosity >= 3 )
  {
    logger.log( _.entityLength( fileMapNew ),'file(s)' );
    logger.log( _.timeSpent( 'Spent',time ) );
  }

  return archive;
}

//

function filesHashMapForm()
{
  var archive = this;

  _.assert( !archive.fileHashMap );

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

function filesLinkSame( o )
{
  var archive = this;
  var provider = archive.fileProvider;
  var fileHashMap = archive.filesHashMapForm();
  var o = _.routineOptions( filesLinkSame,arguments );

  for( var f in fileHashMap )
  {
    var files = fileHashMap[ f ];

    // if( _.strHas( files[ 0 ],'StringTools2.test.s' ) )
    // debugger;

    if( files.length < 2 )
    continue;

    if( o.consideringFileName )
    {
      var byName = {};
      _.entityFilter( files,function( path )
      {
        var name = _.pathNameWithExtension( path );
        if( byName[ name ] )
        byName[ name ].push( path );
        else
        byName[ name ] = [ path ];
      });
      for( var name in byName )
      provider.linkHard({ dstPath : byName[ name ], verbosity : archive.verbosity });
    }
    else
    {
      // console.log( 'archive.verbosity',archive.verbosity );
      provider.linkHard({ dstPath : files, verbosity : archive.verbosity });
    }

  }

  return archive;
}

filesLinkSame.defaults =
{
  consideringFileName : 0,
}

//

function restoreLinksBegin()
{
  var archive = this;
  var provider = archive.fileProvider;

  archive.filesUpdate();

}

//

function restoreLinksEnd()
{
  var archive = this;
  var provider = archive.fileProvider;
  var fileMap1 = _.mapExtend( null, archive.fileMap );
  var fileHashMap = archive.filesHashMapForm();
  var restored = 0;

  archive.filesUpdate();

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

    var newest = filesWithHash[ 0 ];
    var mostLinked = _.entityMax( filesWithHash,( e ) => e.nlink ).element;

    if( mostLinked.absolutePath !== newest.absolutePath )
    {
      var read = provider.fileRead( newest.absolutePath );
      provider.fileWrite( mostLinked.absolutePath,read );
    }

    /* use old file descriptors */

    filesWithHash = _.entityFilter( filesWithHash,( e ) => fileMap1[ e.absolutePath ] );
    mostLinked = fileMap1[ mostLinked.absolutePath ];

    /* verbosity */

    if( archive.verbosity >= 3 )
    logger.log( 'modified',_.toStr( _.entitySelect( filesWithHash,'*.absolutePath' ),{ levels : 2 } ) );

    /*  */

    var srcPath = mostLinked.absolutePath;
    var srcFile = mostLinked;
    linkedMap[ srcPath ] = srcFile;
    for( var last = 0 ; last < filesWithHash.length ; last++ )
    {
      var dstPath = filesWithHash[ last ].absolutePath;
      if( srcFile.absolutePath === dstPath )
      continue;
      if( linkedMap[ dstPath ] )
      continue;
      var dstFile = filesWithHash[ last ];
      /* if this files where linked before changes, relink them */
      if( srcFile.hash2 === dstFile.hash2 )
      {
        debugger;
        restored += 1;
        provider.linkHard({ dstPath : dstPath, srcPath : srcPath, verbosity : archive.verbosity });
        linkedMap[ dstPath ] = filesWithHash[ last ];
      }
    }

  }

  if( archive.verbosity >= 2 )
  logger.log( 'Restored',restored,'links' );
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
var mask =
{
  excludeAny :
  [
    /(\W|^)node_modules(\W|$)/,
    /\.unique$/,
    /\.git$/,
    /\.svn$/,
    /\.hg$/,
    /\.tmp($|\/)/,
    /(^|\/)\.(?!$|\/)/,
  ],
};

var Composes =
{
  verbosity : 2,

  trackPath : null,

  comparingRelyOnHardLinks : 0,
  replacingByNewest : 1,
  maxSize : null,

  // dependencyMap : Object.create( null ),
  fileByHashMap : Object.create( null ),

  fileMap : Object.create( null ),
  fileAddedMap : Object.create( null ),
  fileRemovedMap : Object.create( null ),
  fileModifiedMap : Object.create( null ),

  fileHashMap : null,

  fileMapAutosaving : 0,
  fileMapAutoLoading : 1,

  mask : mask,

  storageFileName : '.warchive',

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
  dependencyMap : 'dependencyMap',
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

  filesUpdate : filesUpdate,
  filesHashMapForm : filesHashMapForm,
  filesLinkSame : filesLinkSame,

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
_.FileStorage.mixin( Self );
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
