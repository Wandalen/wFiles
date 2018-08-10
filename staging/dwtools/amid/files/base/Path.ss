(function _Path_ss_() {

'use strict';

var toBuffer = null;
var Os = null;

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

  Os = require( 'os' );
  var _global = _global_;
  var _ = _global_.wTools;

  _.include( 'wPathFundamentals'/*ttt*/ );

}

var _global = _global_;
var _ = _global_.wTools;
var Self = _global_.wTools.path;

_.assert( _.objectIs( Self ) );

// --
// path
// --

/**
 * Returns path for main module (module that running directly by node).
 * @returns {string}
 * @method realMainFile
 * @memberof wTool
 */

var _pathRealMainFile;
function realMainFile()
{
  if( _pathRealMainFile ) return _pathRealMainFile;
  _pathRealMainFile = _.path.normalize( require.main.filename );
  return _pathRealMainFile;
}

//

/**
 * Returns path dir name for main module (module that running directly by node).
 * @returns {string}
 * @method realMainDir
 * @memberof wTool
 */

var _pathRealMainDir;
function realMainDir()
{
  if( _pathRealMainDir )
  return _pathRealMainDir;

  if( require.main )
  _pathRealMainDir = _.path.normalize( _.path.dir( require.main.filename ) );
  else
  return this.effectiveMainFile();

  return _pathRealMainDir;
}

//

/**
 * Returns absolute path for file running directly by node
 * @returns {string}
 * @throws {Error} If passed any argument.
 * @method effectiveMainFile
 * @memberof wTool
 */

var effectiveMainFile = ( function effectiveMainFile()
{
  var result = '';

  return function effectiveMainFile()
  {
    _.assert( arguments.length === 0 );

    if( result )
    return result;

    if( process.argv[ 0 ] || process.argv[ 1 ] )
    {
      result = _.path.join( _.path.currentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] );
      result = _.path.resolve( result );
    }

    if( !_.fileProvider.fileStat( result ) )
    // if( 0 )
    {
      console.error( 'process.argv :',process.argv.join( ',' ) );
      console.error( 'currentAtBegin :',_.path.currentAtBegin );
      console.error( 'effectiveMainFile.raw :',_.path.join( _.path.currentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] ) );
      console.error( 'effectiveMainFile :',result );
      console.error( 'not tested' );
      debugger;
      //throw _.err( 'not tested' );
      result = _.path.realMainFile();
    }

    return result;
  }

})()

//

/**
 * Returns path dirname for file running directly by node
 * @returns {string}
 * @throws {Error} If passed any argument.
 * @method effectiveMainDir
 * @memberof wTool
 */

function effectiveMainDir()
{
  _.assert( arguments.length === 0 );

  var result = _.path.dir( effectiveMainFile() );

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
 * @method current
 * @memberof wTool
 */

function current()
{
  var result = _.fileProvider.current.apply( _.fileProvider,arguments );
  return result;
}

//

/**
 * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
 * for windows environment variables.
 * @returns {string}
 * @method userHome
 * @memberof wTool
 */

function userHome()
{
  _.assert( arguments.length === 1, 'expects single argument' );
  var result = process.env[ ( process.platform == 'win32' ) ? 'USERPROFILE' : 'HOME' ] || __dirname;
  result = _.path.normalize( result );
  return result;
}

//

function resolveTextLink( path )
{
  return _.fileProvider.resolveTextLink.apply( _.fileProvider,arguments );
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

  o.packagePath = _.path.normalize( _.path.join( o.packagePath, 'tmp.tmp', o.packageName ) );

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
  var packagePath = _.path.dirTempFor.apply( _, arguments );
  _.fileProvider.filesDelete({ filePath : packagePath, throwing : 0 });
  _.fileProvider.directoryMake( packagePath );
  return packagePath;
}

//

/**
 * Generate path string for copy of existing file passed into `o.path`. If file with generated path is exists now,
 * method try to generate new path by adding numeric index into tail of path, before extension.
 * @example
 * var str = 'foo/bar/baz.txt',
   var path = wTools.forCopy( {path : str } ); // 'foo/bar/baz-copy.txt'
 * @param {Object} o options argument
 * @param {string} o.path Path to file for create name for copy.
 * @param {string} [o.postfix='copy'] postfix for mark file copy.
 * @returns {string} path for copy.
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If passed object has unexpected property.
 * @throws {Error} If file for `o.path` is not exist.
 * @method forCopy
 * @memberof wTools
 */

function forCopy( o )
{

  return _.fileProvider.forCopy.apply( _.fileProvider,arguments );

}

forCopy.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  path : null,
}

// --
// declare
// --

var Proto =
{


  realMainFile : realMainFile,
  realMainDir : realMainDir,

  effectiveMainFile : effectiveMainFile,
  effectiveMainDir : effectiveMainDir,

  current : current,
  userHome : userHome,

  resolveTextLink : resolveTextLink,
  _pathResolveTextLink : _pathResolveTextLink,

  dirTempFor : dirTempFor,
  dirTempMake : dirTempMake,
  // dirTempFree : dirTempFree, // qqq : implement

  forCopy : forCopy,

}

_.mapExtend( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
