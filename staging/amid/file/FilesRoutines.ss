(function _FilesRoutines_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  require( './provider/PathMixin.ss' );
  require( './FileRecord.s' );

  require( './provider/FileProviderHardDrive.ss' );

}

var Path = require( 'path' );
var File = require( 'fs-extra' );

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;
var fileProvider = _.FileProvider.HardDrive();

//

/*

problems :

  !!! naming problem : fileStore / fileDirectory / fileAny

*/

// --
//
// --

/**
 * Return o for file red/write. If `pathFile is an object, method returns it. Method validate result option
    properties by default parameters from invocation context.
 * @param {string|Object} pathFile
 * @param {Object} [o] Object with default o parameters
 * @returns {Object} Result o
 * @private
 * @throws {Error} If arguments is missed
 * @throws {Error} If passed extra arguments
 * @throws {Error} If missed `PathFiile`
 * @method _fileOptionsGet
 * @memberof wTools
 */

var _fileOptionsGet = function( pathFile,o )
{
  var o = o || {};

  if( _.objectIs( pathFile ) )
  {
    o = pathFile;
  }
  else
  {
    o.pathFile = pathFile;
  }

  if( !o.pathFile )
  throw _.err( '_fileOptionsGet :','expects "o.pathFile"' );

  _.assertMapHasOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

// --
//
// --

/**
 * Returns path/stats associated with file with newest modified time.
 * @example
 * var fs = require('fs');

   var path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { pathFile : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { pathFile : path2, data : buffer } );


     var newer = wTools.filesNewer( path1, path2 );
     // 'tmp/sample/file2'
   }, 100);
 * @param {string|File.Stats} dst first file path/stat
 * @param {string|File.Stats} src second file path/stat
 * @returns {string|File.Stats}
 * @throws {Error} if type of one of arguments is not string/file.Stats
 * @method filesNewer
 * @memberof wTools
 */

var filesNewer = function( dst,src )
{
  var odst = dst;
  var osrc = src;

  _.assert( arguments.length === 2 );

  if( src instanceof File.Stats )
  src = { stat : src };
  else if( _.strIs( src ) )
  src = { stat : File.statSync( src ) };
  else if( !_.objectIs( src ) )
  throw _.err( 'unknown src type' );

  if( dst instanceof File.Stats )
  dst = { stat : dst };
  else if( _.strIs( dst ) )
  dst = { stat : File.statSync( dst ) };
  else if( !_.objectIs( dst ) )
  throw _.err( 'unknown dst type' );

  if( src.stat.mtime > dst.stat.mtime )
  return osrc;
  else if( src.stat.mtime < dst.stat.mtime )
  return odst;
  else
  return null;

}

  //

/**
 * Returns path/stats associated with file with older modified time.
 * @example
 * var fs = require('fs');

 var path1 = 'tmp/sample/file1',
 path2 = 'tmp/sample/file2',
 buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

 wTools.fileWrite( { pathFile : path1, data : buffer } );
 setTimeout( function()
 {
   wTools.fileWrite( { pathFile : path2, data : buffer } );

   var newer = wTools.filesOlder( path1, path2 );
   // 'tmp/sample/file1'
 }, 100);
 * @param {string|File.Stats} dst first file path/stat
 * @param {string|File.Stats} src second file path/stat
 * @returns {string|File.Stats}
 * @throws {Error} if type of one of arguments is not string/file.Stats
 * @method filesOlder
 * @memberof wTools
 */

var filesOlder = function( dst,src )
{

  _.assert( arguments.length === 2 );

  var result = filesNewer( dst,src );

  if( result === dst )
  return src;
  else if( result === src )
  return dst;
  else
  return null;

}

//

  /**
   * Returns spectre of file content.
   * @example
   * var path = '/home/tmp/sample/file1',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

     wTools.fileWrite( { pathFile : path, data : textData1 } );
     var spectre = wTools.filesSpectre( path );
     //{
     //   L : 1,
     //   o : 4,
     //   r : 3,
     //   e : 5,
     //   m : 3,
     //   ' ' : 7,
     //   i : 6,
     //   p : 2,
     //   s : 4,
     //   u : 2,
     //   d : 2,
     //   l : 2,
     //   t : 5,
     //   a : 2,
     //   ',' : 1,
     //   c : 3,
     //   n : 2,
     //   g : 1,
     //   '.' : 1,
     //   length : 56
     // }
   * @param {string|wFileRecord} src absolute path or FileRecord instance
   * @returns {Object}
   * @throws {Error} If count of arguments are different from one.
   * @throws {Error} If `src` is not absolute path or FileRecord.
   * @method filesSpectre
   * @memberof wTools
   */

var filesSpectre = function( src )
{

  _.assert( arguments.length === 1, 'filesSpectre :','expect single argument' );

  src = FileRecord( src );
  var read = src.read;

  if( !read )
  read = _.FileProvider.HardDrive().fileRead
  ({
    pathFile : src.absolute,
    silent : 1,
    returnRead : 1,
  });

  return _.strLattersSpectre( read );
}

//

  /**
   * Compares specters of two files. Returns the rational number between 0 and 1. For the same specters returns 1. If
      specters do not have the same letters, method returns 0.
   * @example
   * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

     wTools.fileWrite( { pathFile : path1, data : textData1 } );
     wTools.fileWrite( { pathFile : path2, data : textData1 } );
     var similarity = wTools.filesSimilarity( path1, path2 ); // 1
   * @param {string} src1 path string 1
   * @param {string} src2 path string 2
   * @param {Object} [o]
   * @param {Function} [onReady]
   * @returns {number}
   * @method filesSimilarity
   * @memberof wTools
   */

var filesSimilarity = function filesSimilarity( o )
{

  _.assert( arguments.length === 1 );
  _.routineOptions( filesSimilarity,o );

  o.src1 = FileRecord( o.src1 );
  o.src2 = FileRecord( o.src2 );

  if( !o.src1.latters )
  o.src1.latters = _.filesSpectre( o.src1 );

  if( !o.src2.latters )
  o.src2.latters = _.filesSpectre( o.src2 );

  var result = _.lattersSpectreComparison( o.src1.latters,o.src2.latters );

  return result;
}

filesSimilarity.defaults =
{
  src1 : null,
  src2 : null,
}

//

  /**
   * Returns sum of sizes of files in `paths`.
   * @example
   * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     textData2 = 'Aenean non feugiat mauris';

     wTools.fileWrite( { pathFile : path1, data : textData1 } );
     wTools.fileWrite( { pathFile : path2, data : textData2 } );
     var size = wTools.filesSize( [ path1, path2 ] );
     console.log(size); // 81
   * @param {string|string[]} paths path to file or array of paths
   * @param {Object} [o] additional o
   * @param {Function} [o.onBegin] callback that invokes before calculation size.
   * @param {Function} [o.onEnd] callback.
   * @returns {number} size in bytes
   * @method filesSize
   * @memberof wTools
   */

var filesSize = function( paths,o )
{
  var result = 0;
  var o = o || {};
  var paths = _.arrayAs( paths );

  if( o.onBegin ) o.onBegin.call( this,null );

  if( o.onEnd ) throw 'Not implemented';

  for( var p = 0 ; p < paths.length ; p++ )
  {
    result += fileSize( paths[ p ] );
  }

  return result;
}

//

  /**
   * Return file size in bytes. For symbolic links return false. If onEnd callback is defined, method returns instance
      of wConsequence.
   * @example
   * var path = 'tmp/fileSize/data4',
       bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ), // size 4
       bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ); // size 3

     wTools.fileWrite( { pathFile : path, data : bufferData1 } );

     var size1 = wTools.fileSize( path );
     console.log(size1); // 4

     var con = wTools.fileSize( {
       pathFile : path,
       onEnd : function( size )
       {
         console.log( size ); // 7
       }
     } );

     wTools.fileWrite( { pathFile : path, data : bufferData2, append : 1 } );

   * @param {string|Object} o o object or path string
   * @param {string} o.pathFile path to file
   * @param {Function} [o.onBegin] callback that invokes before calculation size.
   * @param {Function} o.onEnd this callback invoked in end of current js event loop and accepts file size as
      argument.
   * @returns {number|boolean|wConsequence}
   * @throws {Error} If passed less or more than one argument.
   * @throws {Error} If passed unexpected parameter in o.
   * @throws {Error} If pathFile is not string.
   * @method fileSize
   * @memberof wTools
   */

var fileSize = function( o )
{
  var o = o || {};

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( o,fileSize.defaults );
  _.mapComplement( o,fileSize.defaults );
  _.assert( _.strIs( o.pathFile ) );

  if( fileProvider.fileIsSoftLink( o.pathFile ) )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  // synchronization

  if( o.onEnd ) return _.timeOut( 0, function()
  {
    var onEnd = o.onEnd;
    delete o.onEnd;
    onEnd.call( this,fileSize.call( this,o ) );
  });

  if( o.onBegin ) o.onBegin.call( this,null );

  var stat = File.statSync( o.pathFile );

  return stat.size;
}

fileSize.defaults =
{
  pathFile : null,
  onBegin : null,
  onEnd : null,
}

//

  /**
   * Returns true if any file from o.dst is newer than other any from o.src.
   * @example :
   * wTools.filesIsUpToDate
   * ({
   *   src : [ 'foo/file1.txt', 'foo/file2.txt' ],
   *   dst : [ 'bar/file1.txt', 'bar/file2.txt' ],
   * });
   * @param {Object} o
   * @param {string[]} o.src array of paths
   * @param {Object} [o.srcOptions]
   * @param {string[]} o.dst array of paths
   * @param {Object} [o.dstOptions]
   * @param {boolean} [o.usingLogging=true] turns on/off logging
   * @returns {boolean}
   * @throws {Error} If passed object has unexpected parameter.
   * @method filesIsUpToDate
   * @memberof wTools
   */

var filesIsUpToDate = function( o )
{

  _.assert( arguments.length === 1 );
  _.assert( !o.newer || _.dateIs( o.newer ) );
  _.routineOptions( filesIsUpToDate,o );

  if( o.srcOptions || o.dstOptions )
  throw _.err( 'not tested' );

  var srcFiles = FileRecord.prototype.fileRecordsFiltered( o.src,o.srcOptions );

  if( !srcFiles.length )
  {
    if( o.usingLogging )
    logger.log( 'Nothing to parse' );
    return true;
  }

  var srcNewest = _.entityMax( srcFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /**/

  var dstFiles = FileRecord.prototype.fileRecordsFiltered( o.dst,o.dstOptions );

  if( !dstFiles.length )
  {
    return false;
  }

  var dstOldest = _.entityMin( dstFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /**/

  if( o.newer )
  {
    if( !( o.newer.getTime() <= dstOldest.stat.mtime.getTime() ) )
    return false;
  }

  if( srcNewest.stat.mtime.getTime() <= dstOldest.stat.mtime.getTime() )
  {

    if( o.usingLogging )
    logger.log( 'Up to date' );
    return true;

  }

  return false;
}

filesIsUpToDate.defaults =
{
  src : null,
  srcOptions : null,
  dst : null,
  dstOptions : null,
  usingLogging : 1,
  newer : null,
}

//

var filesShadow = function( shadows,owners )
{

  for( var s = 0 ; s < shadows.length ; s++ )
  {
    var shadow = shadows[ s ];
    shadow = _.objectIs( shadow ) ? shadow.relative : shadow;

    for( var o = 0 ; o < owners.length ; o++ )
    {

      var owner = owners[ o ];

      owner = _.objectIs( owner ) ? owner.relative : owner;

      if( _.strBegins( shadow,_.pathPrefix( owner ) ) )
      {
        //logger.log( '?',shadow,'shadowed by',owner );
        shadows.splice( s,1 );
        s -= 1;
        break;
      }

    }

  }

}

//

var fileReport = function( file )
{
  var report = '';

  var file = _.FileRecord( file );

  var fileTypes = {};

  if( file.stat )
  {
    fileTypes.isFile = file.stat.isFile();
    fileTypes.isDirectory = file.stat.isDirectory();
    fileTypes.isBlockDevice = file.stat.isBlockDevice();
    fileTypes.isCharacterDevice = file.stat.isCharacterDevice();
    fileTypes.isSymbolicLink = file.stat.isSymbolicLink();
    fileTypes.isFIFO = file.stat.isFIFO();
    fileTypes.isSocket = file.stat.isSocket();
  }

  report += _.toStr( file,{ levels : 2, wrap : 0 } );
  report += '\n';
  report += _.toStr( file.stat,{ levels : 2, wrap : 0 } );
  report += '\n';
  report += _.toStr( fileTypes,{ levels : 2, wrap : 0 } );

  return report;
}

//

var fileStatIs = function fileStatIs( src )
{
  if( src instanceof File.Stats )
  return true;
  return false;
}

// --
// prototype
// --

var Proto =
{

  _fileOptionsGet : _fileOptionsGet,

  filesNewer : filesNewer,
  filesOlder : filesOlder,

  filesSpectre : filesSpectre,
  filesSimilarity : filesSimilarity,

  filesSize : filesSize,
  fileSize : fileSize,

  filesIsUpToDate : filesIsUpToDate,

  filesShadow : filesShadow,

  fileReport : fileReport,

  fileStatIs : fileStatIs,

}

_.mapExtend( Self,Proto );

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
