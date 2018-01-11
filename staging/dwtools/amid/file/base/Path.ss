(function _Path_ss_() {

'use strict';

var toBuffer = null;
var Os = null;

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

  Os = require( 'os' );

  wTools.include( 'wPath' );

}

var _ = wTools;
var Self = wTools;

// --
// path
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
 * @param {string|string[]|RegexpObject} [mask]
 * @returns {RegexpObject}
 * @throws {Error} if passed more than one argument.
 * @see {@link wTools~RegexpObject} RegexpObject
 * @method pathRegexpMakeSafe
 * @memberof wTools
 */

function pathRegexpMakeSafe( mask )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

  var mask = _.regexpMakeObject( mask || {},'includeAny' );
  var excludeMask = _.regexpMakeObject
  ({
    excludeAny :
    [
      'node_modules',

      // '.unique',
      // '.git',
      // '.svn',
      // '.hg',

      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
  });

  mask = _.RegexpObject.shrink( mask,excludeMask );

  return mask;
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
  _pathRealMainFile = _.pathNormalize( require.main.filename );
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
  _pathRealMainDir = _.pathNormalize( _.pathDir( require.main.filename ) );
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
 * @method pathEffectiveMainDir
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

    if( !_.pathIsAbsolute( path ) )
    path = _.pathJoin( process.cwd(), path );

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
  result = _.pathNormalize( result );

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
  result = _.pathNormalize( result );
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
  _.assert( arguments.length <= 2 );

  if( arguments.length === 1 )
  {
    if( _.strIs( o ) )
    o = { packagePath : o }
  }
  else
  {
    o =
    {
      packagePath : arguments[ 0 ],
      packageName : arguments[ 1 ]
    }
  }

  var o = _.routineOptions( dirTempFor,o );

  if( !o.packageName)
  o.packageName = _.idWithGuid();

  if( !o.packagePath )
  o.packagePath = Os.tmpdir();

  o.packagePath = _.pathNormalize( _.pathJoin( o.packagePath, 'tmp.tmp', o.packageName ) );

  return o.packagePath;
}

dirTempFor.defaults =
{
  packageName : null,
  packagePath : null
}

//

function dirTempMake( packagePath, packageName )
{
  var packagePath = _.dirTempFor.apply( _, arguments );
  _.fileProvider.fileDeleteForce( packagePath );
  _.fileProvider.directoryMake( packagePath );
  return packagePath;
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

}

pathForCopy.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  path : null,
}

// --
// prototype
// --

var Proto =
{

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
  dirTempMake : dirTempMake,

  pathForCopy : pathForCopy,

}

_.mapExtend( Self,Proto );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
