(function _FilesRoutines_s_() {

'use strict';

var _global = _global_;
var _ = _global_.wTools;
var FileRecord = _.FileRecord;
var Self = _global_.wTools.files = _global_.wTools.files || Object.create( null );

_.assert( _.routineIs( _.FileRecord ) );

// --
//
// --

/**
 * Creates RegexpObject based on passed path, array of paths, or RegexpObject.
   Paths turns into regexps and adds to 'includeAny' property of result Object.
   Methods adds to 'excludeAny' property the next paths by default :
   'node_modules',
   '.unique',
   '.git',
   '.svn',
   /(^|\/)\.(?!$|\/|\.)/, // any hidden paths
   /(^|\/)-(?!$|\/)/,
 * @example :
 * var paths =
    {
      includeAny : [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
      includeAll : [ 'index.js' ],
      excludeAny : [ 'Gruntfile.js', 'gulpfile.js' ],
      excludeAll : [ 'package.json', 'bower.json' ]
    };
   var regObj = regexpMakeSafe( paths );
 //  {
 //    includeAny :
 //      [
 //        /foo\/bar/,
 //        /foo2\/bar2\/baz/,
 //        /some\.txt/
 //      ],
 //    includeAll :
 //      [
 //        /index\.js/
 //      ],
 //    excludeAny :
 //      [
 //        /Gruntfile\.js/,
 //        /gulpfile\.js/,
 //        /node_modules/,
 //        /\.unique/,
 //        /\.git/,
 //        /\.svn/,
 //        /(^|\/)\.(?!$|\/|\.)/,
 //        /(^|\/)-(?!$|\/)/
 //      ],
 //    excludeAll : [ /package\.json/, /bower\.json/ ]
 //  }
 * @param {string|string[]|RegexpObject} [mask]
 * @returns {RegexpObject}
 * @throws {Error} if passed more than one argument.
 * @see {@link wTools~RegexpObject} RegexpObject
 * @method regexpMakeSafe
 * @memberof wTools
 */

function regexpMakeSafe( mask )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

  var mask = _.regexpMakeObject( mask || Object.create( null ), 'includeAny' );
  var excludeMask = _.regexpMakeObject
  ({
    excludeAny :
    [
      'node_modules',
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
  });

  mask = _.RegexpObject.shrink( mask,excludeMask );

  return mask;
}

//

/**
 * Return o for file red/write. If `filePath is an object, method returns it. Method validate result option
    properties by default parameters from invocation context.
 * @param {string|Object} filePath
 * @param {Object} [o] Object with default o parameters
 * @returns {Object} Result o
 * @private
 * @throws {Error} If arguments is missed
 * @throws {Error} If passed extra arguments
 * @throws {Error} If missed `PathFiile`
 * @method _fileOptionsGet
 * @memberof wTools
 */

function _fileOptionsGet( filePath,o )
{
  var o = o || {};

  if( _.objectIs( filePath ) )
  {
    o = filePath;
  }
  else
  {
    o.filePath = filePath;
  }

  if( !o.filePath )
  throw _.err( '_fileOptionsGet :','expects "o.filePath"' );

  _.assertMapHasOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

//

/**
 * Returns path/stats associated with file with newest modified time.
 * @example
 * var fs = require('fs');

   var path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   buffer = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { filePath : path2, data : buffer } );


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

function filesNewer( dst,src )
{
  var odst = dst;
  var osrc = src;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( _.fileStatIs( src ) )
  src = { stat : src };
  else if( _.strIs( src ) )
  src = { stat : _.fileProvider.fileStat( src ) };
  else if( !_.objectIs( src ) )
  throw _.err( 'unknown src type' );

  if( _.fileStatIs( src ) )
  dst = { stat : dst };
  else if( _.strIs( dst ) )
  dst = { stat : _.fileProvider.fileStat( dst ) };
  else if( !_.objectIs( dst ) )
  throw _.err( 'unknown dst type' );


  var timeSrc = _.entityMax( [ src.stat.mtime/* , src.stat.birthtime */ ] ).value;
  var timeDst = _.entityMax( [ dst.stat.mtime/* , dst.stat.birthtime */ ] ).value;

  // When mtime of the file is changed by fileTimeSet( fs.utime ), there is difference between passed and setted value.
  // if( _.numbersAreEquivalent.call( { accuracy : 500 }, timeSrc.getTime(), timeDst.getTime() ) )
  // return null;

  if( timeSrc > timeDst )
  return osrc;
  else if( timeSrc < timeDst )
  return odst;

  return null;
}

  //

/**
 * Returns path/stats associated with file with older modified time.
 * @example
 * var fs = require('fs');

 var path1 = 'tmp/sample/file1',
 path2 = 'tmp/sample/file2',
 buffer = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

 wTools.fileWrite( { filePath : path1, data : buffer } );
 setTimeout( function()
 {
   wTools.fileWrite( { filePath : path2, data : buffer } );

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

function filesOlder( dst,src )
{

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

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

     wTools.fileWrite( { filePath : path, data : textData1 } );
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

function filesSpectre( src )
{

  _.assert( arguments.length === 1, 'filesSpectre :','expect single argument' );

  src = _.fileProvider.fileRecord( src );
  var read = src.read;

  if( !read )
  read = _.FileProvider.HardDrive().fileRead
  ({
    filePath : src.absolute,
    // silent : 1,
    // returnRead : 1,
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

     wTools.fileWrite( { filePath : path1, data : textData1 } );
     wTools.fileWrite( { filePath : path2, data : textData1 } );
     var similarity = wTools.filesSimilarity( path1, path2 ); // 1
   * @param {string} src1 path string 1
   * @param {string} src2 path string 2
   * @param {Object} [o]
   * @param {Function} [onReady]
   * @returns {number}
   * @method filesSimilarity
   * @memberof wTools
   */

function filesSimilarity( o )
{

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( filesSimilarity,o );

  o.src1 = _.fileProvider.fileRecord( o.src1 );
  o.src2 = _.fileProvider.fileRecord( o.src2 );

  // if( !o.src1.latters )
  var latters1 = _.files.filesSpectre( o.src1 );

  // if( !o.src2.latters )
  var latters2 = _.files.filesSpectre( o.src2 );

  var result = _.strLattersSpectresSimilarity( latters1,latters2 );

  return result;
}

filesSimilarity.defaults =
{
  src1 : null,
  src2 : null,
}

//

function filesShadow( shadows,owners )
{

  for( var s = 0 ; s < shadows.length ; s++ )
  {
    var shadow = shadows[ s ];
    shadow = _.objectIs( shadow ) ? shadow.relative : shadow;

    for( var o = 0 ; o < owners.length ; o++ )
    {

      var owner = owners[ o ];

      owner = _.objectIs( owner ) ? owner.relative : owner;

      if( _.strBegins( shadow,_.path.prefixGet( owner ) ) )
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

function fileReport( file )
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

function nodeJsIsSameOrNewer( src )
{
  _.assert( arguments.length === 1 );
  _.assert( _.longIs( src ) );
  _.assert( src.length === 3 );
  _.assert( !!_global.process );

  var parsed = /^v(\d+).(\d+).(\d+)/.exec( _global.process.version );
  for( var i = 1; i < 4; i++ )
  {
    if( parsed[ i ] < src[ i - 1 ] )
    return false;

    if( parsed[ i ] > src[ i - 1 ] )
    return true;
  }

  return true;
}

//
//
// /* !!! remove the routine later */
//
// var routineForPreAndBody = _.routineExtend( null, _.routineForPreAndBody );
// var defaults = routineForPreAndBody.defaults;
//
// defaults.bodyProperties =
// {
//   defaults : null,
//   paths : null,
//   having : null,
// }
//
// function routineForPreAndBody()
// {
//   return _.routineForPreAndBody.apply( _, arguments );
// }
//
// var defaults = routineForPreAndBody.defaults = Object.create( _.routineForPreAndBody.defaults );
//
// defaults. = ;

// --
// declare
// --

var Proto =
{

  regexpMakeSafe : regexpMakeSafe,

  _fileOptionsGet : _fileOptionsGet,

  filesNewer : filesNewer,
  filesOlder : filesOlder,

  filesSpectre : filesSpectre,
  filesSimilarity : filesSimilarity,

  // filesAreUpToDate : filesAreUpToDate,

  filesShadow : filesShadow,

  fileReport : fileReport,

  // fileStatIs : fileStatIs,

  nodeJsIsSameOrNewer : nodeJsIsSameOrNewer,

  // routineForPreAndBody : routineForPreAndBody,

}

_.mapExtend( Self, Proto );
// _.mapExtend( _, Proto ); // xxx

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
