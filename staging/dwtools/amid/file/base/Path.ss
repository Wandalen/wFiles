(function _Path_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

  wTools.include( 'wPath' );

}

var _ = wTools;
var Self = wTools;

// --
// path
// --

/**
 * Returns absolute path to file. Accepts file record object. If as argument passed string, method returns it.
 * @example
 * var pathStr = 'foo/bar/baz',
    fileRecord = FileRecord( pathStr );
   var path = wTools.pathGet( fileRecord ); // '/home/user/foo/bar/baz';
 * @param {string|wFileRecord} src file record or path string
 * @returns {string}
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If type of argument is not string or wFileRecord.
 * @method pathGet
 * @memberof wTools
 */

function pathGet( src )
{

  _.assert( arguments.length === 1 );

  if( _.strIs( src ) )
  return src;
  else if( src instanceof _.FileRecord )
  return src.absolute;
  else _.assert( 0, 'pathGet : unexpected type of argument', _.strTypeOf( src ) );

}

//

function pathsGet( src )
{

  debugger;
  throw _.err( 'not tested' );
  _.assert( arguments.length === 1 );

  if( _.arrayIs( src ) )
  {
    var result = [];
    for( var s = 0 ; s < src.length ; s++ )
    result.push( this.pathGet( src[ s ] ) );
    return result;
  }

  return this.pathGet( src );
}

//

/**
 * Generate path string for copy of existing file passed into `o.path`. If file with generated path is exists now,
 * method try to generate new path by adding numeric index into tail of path, before extension.
 * @example
 * var pathStr = 'foo/bar/baz.txt',
   var path = wTools.pathForCopy( {path : pathStr } ); // 'foo/bar/baz-copy.txt'
 * @param {Object} o options argument
 * @param {string} o.path Path to file for create name for copy.
 * @param {string} [o.postfix='copy'] postfix for mark file copy.
 * @returns {string} path for copy.
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If passed object has unexpected property.
 * @throws {Error} If file for `o.path` is not exist.
 * @method pathForCopy
 * @memberof wTools
 */

function pathForCopy( o )
{

  return _.fileProvider.pathForCopy.apply( _.fileProvider,arguments );

  // if( !_.mapIs( o ) )
  // o = { path : o };
  //
  // _.assert( _.strIs( o.path ) );
  // _.assert( arguments.length === 1 );
  // _.routineOptions( pathForCopy,o );
  //
  // var postfix = _.strPrependOnce( o.postfix ? '-' : '',o.postfix );
  // var file = _.FileRecord( o.path,{ fileProvider : _.fileProvider } );
  //
  // // debugger;
  // // if( !_.fileProvider.fileStat({ filePath : file.absolute, sync : 1 }) )
  // // throw _.err( 'pathForCopy : original does not exit : ' + file.absolute );
  //
  // var parts = _.strSplit({ src : file.name, delimeter : '-' });
  // if( parts[ parts.length-1 ] === o.postfix )
  // file.name = parts.slice( 0,parts.length-1 ).join( '-' );
  //
  // // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // // same effect as previous
  //
  // if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  // file.name = parts.slice( 0,parts.length-1 ).join( '-' );
  // else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  // file.name = parts.slice( 0,parts.length-2 ).join( '-' );
  //
  // /*file.absolute =  file.dir + '/' + file.name + file.extWithDot;*/
  //
  // var path = _.pathJoin( file.dir , file.name + postfix + file.extWithDot );
  // if( !_.fileProvider.fileStat({ filePath : path , sync : 1 }) )
  // return path;
  //
  // var attempts = 1 << 13;
  // var index = 1;
  //
  // while( attempts > 0 )
  // {
  //
  //   var path = _.pathJoin( file.dir , file.name + postfix + '-' + index + file.extWithDot );
  //
  //   if( !_.fileProvider.fileStat({ filePath : path , sync : 1 }) )
  //
  //   return path;
  //
  //   attempts -= 1;
  //   index += 1;
  //
  // }
  //
  // throw _.err( 'pathForCopy : cant make copy path for : ' + file.absolute );
}

// debugger;
// pathForCopy.defaults = _.FileProvider.Default.prototype.pathForCopy.defaults;

pathForCopy.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  path : null,
}

//

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
   var regObj = pathRegexpMakeSafe( paths );
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
 * @param {string|string[]|RegexpObject} [maskAll]
 * @returns {RegexpObject}
 * @throws {Error} if passed more than one argument.
 * @see {@link wTools~RegexpObject} RegexpObject
 * @method pathRegexpMakeSafe
 * @memberof wTools
 */

function pathRegexpMakeSafe( maskAll )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

  var maskAll = _.regexpMakeObject( maskAll || {},'includeAny' );
  var excludeMask = _.regexpMakeObject
  ({
    excludeAny :
    [
      'node_modules',
      '.unique',
      '.git',
      '.svn',
      '.hg',
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
  });

  maskAll = _.RegexpObject.shrink( maskAll,excludeMask );

  return maskAll;
}

//

/**
 * Returns path for main module (module that running directly by node).
 * @returns {string}
 * @method pathRealMainFile
 * @memberof wTool
 */

var _pathRealMainFile;
function pathRealMainFile()
{
  if( _pathRealMainFile ) return _pathRealMainFile;
  _pathRealMainFile = _.pathRegularize( require.main.filename );
  return _pathRealMainFile;
}

//

/**
 * Returns path dir name for main module (module that running directly by node).
 * @returns {string}
 * @method pathRealMainDir
 * @memberof wTool
 */

var _pathRealMainDir;
function pathRealMainDir()
{
  if( _pathRealMainDir )
  return _pathRealMainDir;

  if( require.main )
  _pathRealMainDir = _.pathRegularize( _.pathDir( require.main.filename ) );
  else
  return this.pathEffectiveMainFile();

  return _pathRealMainDir;
}

//

/**
 * Returns absolute path for file running directly by node
 * @returns {string}
 * @throws {Error} If passed any argument.
 * @method pathEffectiveMainFile
 * @memberof wTool
 */

var pathEffectiveMainFile = ( function pathEffectiveMainFile()
{
  var result = '';

  return function pathEffectiveMainFile()
  {
    _.assert( arguments.length === 0 );

    if( result )
    return result;

    if( process.argv[ 0 ] || process.argv[ 1 ] )
    {
      result = _.pathJoin( _.pathCurrentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] );
      result = _.pathResolve( result );
    }

    if( !_.fileProvider.fileStat( result ) )
    // if( 0 )
    {
      console.error( 'process.argv :',process.argv.join( ',' ) );
      console.error( 'pathCurrentAtBegin :',_.pathCurrentAtBegin );
      console.error( 'pathEffectiveMainFile.raw :',_.pathJoin( _.pathCurrentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] ) );
      console.error( 'pathEffectiveMainFile :',result );
      console.error( 'not tested' );
      debugger;
      //throw _.err( 'not tested' );
      result = _.pathRealMainFile();
    }

    return result;
  }

})()

//

/**
 * Returns path dirname for file running directly by node
 * @returns {string}
 * @throws {Error} If passed any argument.
 * @method pathEffectiveMainFile
 * @memberof wTool
 */

function pathEffectiveMainDir()
{
  _.assert( arguments.length === 0 );

  var result = _.pathDir( pathEffectiveMainFile() );

  return result;
}

//

/**
 * Returns the current working directory of the Node.js process. If as argument passed path to existing directory,
   method sets current working directory to it. If passed path is an existing file, method set its parent directory
   as current working directory.
 * @param {string} [path] path to set current working directory.
 * @returns {string}
 * @throws {Error} If passed more than one argument.
 * @throws {Error} If passed path to not exist directory.
 * @method pathCurrent
 * @memberof wTool
 */

function pathCurrent()
{
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  try
  {

    var path = arguments[ 0 ];
    _.assert( _.strIs( path ) );

    if( _.fileProvider.fileStat( path ) && _.fileProvider.fileIsTerminal( path ) )
    path = _.pathResolve( path,'..' );

    process.chdir( _.fileProvider.pathNativize( path ) );

  }
  catch( err )
  {
    throw _.err( 'file was not found : ' + arguments[ 0 ] + '\n',err );
  }

  // console.log( '_',_ );

  var result = process.cwd();
  result = _.pathRegularize( result );

  return result;
}

//

/**
 * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
 * for windows environment variables.
 * @returns {string}
 * @method pathUserHome
 * @memberof wTool
 */

function pathUserHome()
{
  _.assert( arguments.length === 1 );
  var result = process.env[ ( process.platform == 'win32' ) ? 'USERPROFILE' : 'HOME' ] || __dirname;
  result = _.pathRegularize( result );
  return result;
}

//

function pathResolveTextLink( path )
{
  return _.fileProvider.pathResolveTextLink.apply( _.fileProvider,arguments );
}

//

function _pathResolveTextLink( path )
{
  return _.fileProvider._pathResolveTextLink.apply( _.fileProvider,arguments );
}

//

function dirTempFor( o )
{
  if( _.strIs( o ) )
  o = { packageName : o }

  _.routineOptions( dirTempFor,o );
  _.assert( arguments.length === 1 );

  _.assert( _.strIs( o.packageName ) );

  if( !o.packagePath )
  {
    o.packagePath = _.pathRealMainDir();
  }

  _.assert( _.strIs( o.packagePath ) );

  var filePath = _.pathJoin( o.packagePath, o.packageName );

  o.filePath = filePath;

  _.fileProvider.directoryMake( o.filePath );

  return o.filePath;
}

dirTempFor.defaults =
{
  packageName : null,
  packagePath : null
}

// --
// prototype
// --

var Proto =
{

  pathGet : pathGet,
  pathsGet : pathsGet,

  pathForCopy : pathForCopy,

  pathRegexpMakeSafe : pathRegexpMakeSafe,

  pathRealMainFile : pathRealMainFile,
  pathRealMainDir : pathRealMainDir,

  pathEffectiveMainFile : pathEffectiveMainFile,
  pathEffectiveMainDir : pathEffectiveMainDir,

  pathCurrent : pathCurrent,
  pathUserHome : pathUserHome,

  pathResolveTextLink : pathResolveTextLink,
  _pathResolveTextLink : _pathResolveTextLink,

  dirTempFor : dirTempFor,

}

_.mapExtend( Self,Proto );

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
