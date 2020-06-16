( function _Namespace_s_()
{

'use strict';

/**
 * @namespace Tools.files
 * @module Tools/mid/Files
 */

/**
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

let _global = _global_;
let _ = _global_.wTools;
let Self = _.files = _.files || Object.create( null );

_.FileProvider = _.files.FileProvider = _.FileProvider || _.files.FileProvider || Object.create( null );
_.FileFilter = _.files.FileFilter = _.FileFilter || _.files.FileFilter || Object.create( null );
_.files.ReadEncoders = _.files.ReadEncoders || Object.create( null ); /* xxx : rename */
_.files.WriteEncoders = _.files.WriteEncoders || Object.create( null );

// --
// implementation
// --

/**
 * @description Creates RegexpObject based on passed path, array of paths, or RegexpObject.
 * Paths turns into regexps and adds to 'includeAny' property of result Object.
 * Methods adds to 'excludeAny' property the next paths by default :
 * 'node_modules',
 * '.unique',
 * '.git',
 * '.svn',
 * /(^|\/)\.(?!$|\/|\.)/, // any hidden paths
 * /(^|\/)-(?!$|\/)/,
 * @example
 * let paths =
 *  {
 *    includeAny : [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
 *    includeAll : [ 'index.js' ],
 *    excludeAny : [ 'Gruntfile.js', 'gulpfile.js' ],
 *    excludeAll : [ 'package.json', 'bower.json' ]
 *  };
 * let regObj = regexpAllSafe( paths );
 *
 * @param {string|string[]|RegexpObject} [mask]
 * @returns {RegexpObject}
 * @throws {Error} if passed more than one argument.
 * @see {@link wTools~RegexpObject} RegexpObject
 * @function regexpAllSafe
 * @namespace wTools.files
 * @module Tools/mid/Files
 */

function regexpAllSafe( mask )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let excludeMask = _.RegexpObject
  ({
    excludeAny :
    [
      // /(\W|^)node_modules(\W|$)/,
      // /\.unique(?:$|\/)/,
      // /\.git(?:$|\/)/,
      // /\.svn(?:$|\/)/,
      // /\.hg(?:$|\/)/,
      // /\.DS_Store(?:$|\/)/,
      // /\.tmp(?:$|\/)/,
      /\.(?:unique|git|svn|hg|DS_Store|tmp)(?:$|\/)/,
      /(^|\/)-/,
    ],
  });

  if( mask )
  {
    mask = _.RegexpObject( mask || Object.create( null ), 'includeAny' );
    excludeMask = excludeMask.and( mask );
  }

  return excludeMask;
}

//

function regexpTerminalSafe( mask )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let excludeMask = _.RegexpObject
  ({
    excludeAny :
    [
    ],
  });

  if( mask )
  {
    mask = _.RegexpObject( mask || Object.create( null ), 'includeAny' );
    excludeMask = excludeMask.and( mask );
  }

  return excludeMask;
}

//

function regexpDirSafe( mask )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let excludeMask = _.RegexpObject
  ({
    excludeAny :
    [
      /(^|\/)\.(?!$|\/|\.)/,
      // /(^|\/)-/,
    ],
  });

  if( mask )
  {
    mask = _.RegexpObject( mask || Object.create( null ), 'includeAny' );
    excludeMask = excludeMask.and( mask );
  }

  return excludeMask;
}

//

function filterSafer( filter )
{
  _.assert( filter === null || _.mapIs( filter ) || filter instanceof _.FileRecordFilter );

  filter = filter || Object.create( null );

  filter.maskAll = _.files.regexpAllSafe( filter.maskAll );
  filter.maskTerminal = _.files.regexpTerminalSafe( filter.maskTerminal );
  filter.maskDirectory = _.files.regexpDirSafe( filter.maskDirectory );
  filter.maskTransientAll = _.files.regexpAllSafe( filter.maskTransientAll );
  // filter.maskTransientTerminal = _.files.regexpTerminalSafe( filter.maskTransientTerminal );
  filter.maskTransientDirectory = _.files.regexpDirSafe( filter.maskTransientDirectory );

  return filter;
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
 * @function _fileOptionsGet
 * @namespace wTools.files
 * @module Tools/mid/Files
 */

function _fileOptionsGet( filePath,o )
{
  o = o || {};

  if( _.objectIs( filePath ) )
  {
    o = filePath;
  }
  else
  {
    o.filePath = filePath;
  }

  if( !o.filePath )
  throw _.err( '_fileOptionsGet :','Expects "o.filePath"' );

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
 * let fs = require('fs');

   let path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   buffer = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { filePath : path2, data : buffer } );


     let newer = wTools.filesNewer( path1, path2 );
     // 'tmp/sample/file2'
   }, 100);
 * @param {string|File.Stats} dst first file path/stat
 * @param {string|File.Stats} src second file path/stat
 * @returns {string|File.Stats}
 * @throws {Error} if type of one of arguments is not string/file.Stats
 * @function filesNewer
 * @namespace wTools.files
 * @module Tools/mid/Files
 */

function filesNewer( dst,src )
{
  let odst = dst;
  let osrc = src;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( _.fileStatIs( src ) )
  src = { stat : src };
  else if( _.strIs( src ) )
  src = { stat : _.fileProvider.statRead( src ) };
  else if( !_.objectIs( src ) )
  throw _.err( 'unknown src type' );

  if( _.fileStatIs( dst ) )
  dst = { stat : dst };
  else if( _.strIs( dst ) )
  dst = { stat : _.fileProvider.statRead( dst ) };
  else if( !_.objectIs( dst ) )
  throw _.err( 'unknown dst type' );


  let timeSrc = _.entityMax( [ src.stat.mtime/* , src.stat.birthtime */ ] ).value;
  let timeDst = _.entityMax( [ dst.stat.mtime/* , dst.stat.birthtime */ ] ).value;

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
 * let fs = require('fs');

 let path1 = 'tmp/sample/file1',
 path2 = 'tmp/sample/file2',
 buffer = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] );

 wTools.fileWrite( { filePath : path1, data : buffer } );
 setTimeout( function()
 {
   wTools.fileWrite( { filePath : path2, data : buffer } );

   let newer = wTools.filesOlder( path1, path2 );
   // 'tmp/sample/file1'
 }, 100);
 * @param {string|File.Stats} dst first file path/stat
 * @param {string|File.Stats} src second file path/stat
 * @returns {string|File.Stats}
 * @throws {Error} if type of one of arguments is not string/file.Stats
 * @function filesOlder
 * @namespace wTools.files
 * @module Tools/mid/Files
 */

function filesOlder( dst,src )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  let result = filesNewer( dst,src );

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
 * let path = '/home/tmp/sample/file1',
 * textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
 *
 * wTools.fileWrite( { filePath : path, data : textData1 } );
 * let spectre = wTools.filesSpectre( path );
 * //{
 * //   L : 1,
 * //   o : 4,
 * //   r : 3,
 * //   e : 5,
 * //   m : 3,
 * //   ' ' : 7,
 * //   i : 6,
 * //   p : 2,
 * //   s : 4,
 * //   u : 2,
 * //   d : 2,
 * //   l : 2,
 * //   t : 5,
 * //   a : 2,
 * //   ',' : 1,
 * //   c : 3,
 * //   n : 2,
 * //   g : 1,
 * //   '.' : 1,
 * //   length : 56
 * // }
 * @param {string|wFileRecord} src absolute path or FileRecord instance
 * @returns {Object}
 * @throws {Error} If count of arguments are different from one.
 * @throws {Error} If `src` is not absolute path or FileRecord.
 * @function filesSpectre
 * @namespace wTools.files
 * @module Tools/mid/Files
*/

function filesSpectre( src )
{

  _.assert( arguments.length === 1, 'filesSpectre :','expect single argument' );

  src = _.fileProvider.recordFactory().record( src );
  let read = src.read;

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
 * specters do not have the same letters, method returns 0.
 * @example
 * let path1 = 'tmp/sample/file1',
 * path2 = 'tmp/sample/file2',
 * textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
 *
 * wTools.fileWrite( { filePath : path1, data : textData1 } );
 * wTools.fileWrite( { filePath : path2, data : textData1 } );
 * let similarity = wTools.filesSimilarity( path1, path2 ); // 1
 * @param {string} src1 path string 1
 * @param {string} src2 path string 2
 * @param {Object} [o]
 * @param {Function} [onReady]
 * @returns {number}
 * @function filesSimilarity
 * @namespace wTools.files
 * @module Tools/mid/Files
*/

function filesSimilarity( o )
{

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( filesSimilarity,o );

  o.src1 = _.fileProvider.recordFactory().record( o.src1 );
  o.src2 = _.fileProvider.recordFactory().record( o.src2 );

  // if( !o.src1.latters )
  let latters1 = _.files.filesSpectre( o.src1.absolute );

  // if( !o.src2.latters )
  let latters2 = _.files.filesSpectre( o.src2.absolute );

  let result = _.strLattersSpectresSimilarity( latters1,latters2 );

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

  for( let s = 0 ; s < shadows.length ; s++ )
  {
    let shadow = shadows[ s ];
    shadow = _.objectIs( shadow ) ? shadow.relative : shadow;

    for( let o = 0 ; o < owners.length ; o++ )
    {

      let owner = owners[ o ];

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
  let report = '';

  file = _.FileRecord( file );

  let fileTypes = {};

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

  let parsed = /^v(\d+).(\d+).(\d+)/.exec( _global.process.version );
  for( let i = 1; i < 4; i++ )
  {
    if( parsed[ i ] < src[ i - 1 ] )
    return false;

    if( parsed[ i ] > src[ i - 1 ] )
    return true;
  }

  return true;
}

// --
// encoder
// --

function encoderNormalize( o )
{

  o = _.routineOptions( encoderNormalize, o );
  if( _.strIs( o.exts ) )
  o.exts = [ o.exts ];
  else if( o.exts === null )
  o.exts = [];

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o.criterion ) );
  _.assert( _.longIs( o.exts ) );
  _.assert( o.criterion.reader || o.criterion.writer );

  let collectionMap = o.criterion.reader ? _.files.ReadEncoders : _.files.WriteEncoders;

  if( o.name === null && o.exts.length )
  o.name = nameGenerate();

  _.assert( _.strDefined( o.name ) );
  // _.assert( _.routineIs( o.onData ) ); /* xxx : implement */

  return o;

  /* */

  function nameGenerate()
  {
    let name = o.exts[ 0 ];
    let counter = 2;
    while( collectionMap[ name ] !== undefined )
    {
      debugger;
      name = o.exts[ 0 ] + '.' + counter;
    }
    return name;
  }

}

encoderNormalize.defaults =
{

  name : null,
  exts : null,
  criterion : null,
  gdf : null,
  forConfig : null, /* xxx : remove */

  onBegin : null,
  onEnd : null,
  onError : null, /* xxx : remove */
  onData : null,

}

//

function encoderRegister( o, ext )
{

  o = _.files.encoderNormalize( o );

  let collectionMap = o.criterion.reader ? _.files.ReadEncoders : _.files.WriteEncoders;
  let name = ext ? ext : o.name;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( ext === undefined || _.strDefined( ext ) );

  if( collectionMap[ name ] !== undefined )
  {
    let encoder2 = collectionMap[ o.name ];
    if( encoder2 === o )
    return o;
    if( encoder2.criterion.default )
    return o;
    if( !o.criterion.default )
    return o;
  }

  // console.log( `Registered encoder::${name}` );

  collectionMap[ name ] = o;

  return o;
}

encoderRegister.defaults =
{

  ... encoderNormalize.defaults,

}

//

function _encoderFromGdf( gdf )
{

  _.assert( gdf.ext.length );
  _.assert( gdf instanceof _.gdf.Converter );

  let encoder = Object.create( null );
  encoder.gdf = gdf;
  encoder.exts = gdf.ext.slice();
  if( gdf.forConfig ) /* xxx : remove */
  encoder.forConfig = true;

  encoder.criterion = Object.create( null );
  if( gdf.forConfig )
  encoder.criterion.config = true;
  if( gdf.default )
  encoder.criterion.default = true;

  return encoder;
}

//

let _encoderWriterFromGdfCache = new HashMap;
function encoderWriterFromGdf( gdf )
{

  if( _encoderWriterFromGdfCache.has( gdf ) )
  return _encoderWriterFromGdfCache.get( gdf );

  let encoder = _.files._encoderFromGdf( gdf );
  encoder.criterion.writer = true;

  encoder.onBegin = function( op )
  {
    let encoded = op.encoder.gdf.encode({ data : op.operation.data, secondary : op.operation });
    op.operation.data = encoded.data;
    if( encoded.format === 'string' )
    op.operation.encoding = 'utf8';
    else
    op.operation.encoding = encoded.format;
  }

  _encoderWriterFromGdfCache.set( gdf, encoder );
  return encoder;
}

//

let _encoderReaderFromGdfCache = new HashMap;
function encoderReaderFromGdf( gdf )
{

  if( _encoderReaderFromGdfCache.has( gdf ) )
  return _encoderReaderFromGdfCache.get( gdf );

  let encoder = _.files._encoderFromGdf( gdf );
  encoder.criterion.reader = true;
  let expectsString = _.longHas( gdf.in, 'string' );
  // _.assert( !!expectsString, 'not tested' ); /* xxx */

  encoder.onBegin = function( e )
  {
    if( expectsString )
    e.operation.encoding = 'utf8';
    else
    e.operation.encoding = op.encoder.gdf.in[ 0 ];
  }

  encoder.onEnd = function( op ) /* xxx : should be onData */
  {
    let decoded = op.encoder.gdf.encode({ data : op.data, secondary : op.operation });
    op.data = decoded.data;
  }

  _encoderReaderFromGdfCache.set( gdf, encoder );
  return encoder;
}

//

function encodersFromGdfs()
{
  _.assert( _.Gdf, 'module::Gdf is required to generate encoders!' );
  _.assert( _.mapIs( _.gdf.inMap ) );
  _.assert( _.mapIs( _.gdf.outMap ) );

  for( let k in _.gdf.inOutMap )
  {
    if( !_.strHas( k, 'structure' ) )
    continue;
    var defaults = _.entityFilter( _.gdf.inOutMap[ k ], ( c ) => c.default ? c : undefined );
    if( defaults.length > 1 )
    throw _.err( `Several default converters for '${k}' in-out combination:`, _.select( defaults, '*/name' )  );
  }

  let writeGdf = _.gdf.inMap[ 'structure' ];
  let readGdf = _.gdf.outMap[ 'structure' ];

  let WriteEndoders = Object.create( null );
  let ReadEncoders = Object.create( null );

  writeGdf.forEach( ( gdf ) =>
  {
    let encoder = _.files.encoderWriterFromGdf( gdf );
    _.assert( gdf.ext.length );
    // if( _.longHas( gdf.ext, 'json' ) )
    // debugger;
    _.each( gdf.ext, ( ext ) =>
    {
      // debugger;
      if( !WriteEndoders[ ext ] || gdf.default )
      _.files.encoderRegister( encoder, ext );
      // WriteEndoders[ ext ] = encoder;
    })
  })

  /* */

  readGdf.forEach( ( gdf ) =>
  {
    let encoder = _.files.encoderReaderFromGdf( gdf );
    _.assert( gdf.ext.length );
    _.each( gdf.ext, ( ext ) =>
    {
      if( !ReadEncoders[ ext ] || gdf.default )
      _.files.encoderRegister( encoder, ext );
      // ReadEncoders[ ext ] = encoder;
    })
  })

  /* */

  for( let k in _.files.ReadEncoders )
  {
    let gdf = _.files.ReadEncoders[ k ].gdf;
    if( gdf )
    if( !_.longHas( readGdf, gdf ) || !_.longHas( gdf.ext, k ) )
    {
      _.assert( 0, 'not tested' );
      delete _.files.ReadEncoders[ k ]
    }
  }

  for( let k in _.files.WriteEncoders )
  {
    let gdf = _.files.WriteEncoders[ k ].gdf;
    if( gdf )
    if( !_.longHas( writeGdf, gdf ) || !_.longHas( gdf.ext, k ) )
    {
      // _.assert( 0, 'not tested' );
      delete _.files.WriteEncoders[ k ];
    }
  }

  /* */

  _.assert( _.mapIs( _.files.ReadEncoders ) );
  _.assert( _.mapIs( _.files.WriteEncoders ) );

  Object.assign( _.files.ReadEncoders, ReadEncoders );
  Object.assign( _.files.WriteEncoders, WriteEndoders );
}

//

function encoderDeduce( o )
{
  let result = [];

  o = _.routineOptions( encoderDeduce, arguments );

  if( o.filePath && !o.ext )
  o.ext = _.path.ext( o.filePath );
  if( o.ext )
  o.ext = o.ext.toLowerCase();

  _.assert( _.strIs( o.ext ) || o.ext === null );
  _.assert( _.mapIs( o.criterion ) );
  _.assert( o.criterion.writer || o.criterion.reader );

  if( o.ext )
  if( _.files.WriteEncoders[ o.ext ] )
  {
    let encoder = _.files.WriteEncoders[ o.ext ];
    _.assert( _.objectIs( encoder ), `Write encoder ${o.ext} is missing` );
    _.assert( _.longHas( encoder.exts, o.ext ) );
    _.arrayAppendOnce( result, encoder );
  }

  result = filterAll( result );

  if( !o.single || !result.length )
  for( let i = 0 ; i < _.files.gdfTypesToWrite.length ; i++ )
  {
    let type = _.files.gdfTypesToWrite[ i ];
    if( !_.gdf.outMap[ type ] )
    continue;
    for( let i2 = 0 ; i2 < _.gdf.outMap[ type ].length ; i2++ )
    {
      let gdf = _.gdf.outMap[ type ][ i2 ];
      let o2 = _.mapBut( o, [ 'single', 'returning', 'criterion' ] );
      let methodName = o.criterion.reader ? supportsInput : supportsOutput;
      let supports = gdf[ methodName ]( o2 );
      if( supports )
      _.arrayAppendOnce( result, _.files.encoderWriterFromGdf( gdf ) );
    }
  }

  result = filterAll( result );

  if( o.single )
  {

    if( result.length > 1 )
    _.filter_( result, ( encoder ) => encoder.criterion.default ? encoder : undefined );

    _.assert
    (
      result.length >= 1,
      () => `Found no reader for format:${o.format} ext:${o.ext} filePath:${o.filePath}.`
    );
    _.assert
    (
      result.length <= 1,
      () => `Found ${result.length} readers for format:${o.format} ext:${o.ext} filePath:${o.filePath}, but need only one.`
    );
    if( o.returning === 'name' )
    return result[ 0 ].name;
    else
    return result[ 0 ];
  }

  debugger;
  if( o.returning === 'name' )
  return result.map( ( encoder ) => encoder.name );
  else
  return result;

  function filterAll( encoders )
  {
    if( o.criterion === null )
    return encoders;
    if( _.mapKeys( o.criterion ).length === 0 )
    return encoders;
    return _.filter_( encoders, ( encoder ) =>
    {
      let satisfied = _.objectSatisfy
      ({
        src : encoder.criterion,
        template : o.criterion,
        levels : 1,
        strict : false,
      });
      if( satisfied )
      return encoder;
    });
  }
}

encoderDeduce.defaults =
{
  data : null,
  format : null,
  filePath : null,
  ext : null,
  criterion : null,
  single : 1,
  returning : 'name',
}

// --
// declaration
// --

let gdfTypesToWrite = [ 'string', 'buffer.raw', 'buffer.bytes', 'buffer.node' ];

let Extension = /* xxx : review */
{

  // regexp

  regexpMakeSafe : regexpAllSafe,
  regexpAllSafe,
  regexpTerminalSafe,
  regexpDirSafe,
  filterSafer,

  _fileOptionsGet,

  // etc

  filesNewer,
  filesOlder,

  filesSpectre,
  filesSimilarity,

  filesShadow,

  fileReport,

  nodeJsIsSameOrNewer,

  // encoder

  encoderNormalize,
  encoderRegister,
  _encoderFromGdf,
  encoderWriterFromGdf,
  encoderReaderFromGdf,
  encodersFromGdfs,
  encoderDeduce,

  // fields

  gdfTypesToWrite,

}

_.mapSupplement( Self, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
