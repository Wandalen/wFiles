(function _Path_ss_() {

'use strict';

var toBuffer = null;
var Os = null;

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

  Os = require( 'os' );

  var _global = _global_; var _ = _global_.wTools;

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
 * @method pathRealMainFile
 * @memberof wTool
 */

var _pathRealMainFile;
function pathRealMainFile()
{
  if( _pathRealMainFile ) return _pathRealMainFile;
  _pathRealMainFile = _.path.pathNormalize( require.main.filename );
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
  _pathRealMainDir = _.path.pathNormalize( _.path.pathDir( require.main.filename ) );
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
      result = _.path.pathJoin( _.path.pathCurrentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] );
      result = _.path.pathResolve( result );
    }

    if( !_.fileProvider.fileStat( result ) )
    // if( 0 )
    {
      console.error( 'process.argv :',process.argv.join( ',' ) );
      console.error( 'pathCurrentAtBegin :',_.path.pathCurrentAtBegin );
      console.error( 'pathEffectiveMainFile.raw :',_.path.pathJoin( _.path.pathCurrentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] ) );
      console.error( 'pathEffectiveMainFile :',result );
      console.error( 'not tested' );
      debugger;
      //throw _.err( 'not tested' );
      result = _.path.pathRealMainFile();
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

  var result = _.path.pathDir( pathEffectiveMainFile() );

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
  var result = _.fileProvider.pathCurrent.apply( _.fileProvider,arguments );
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
  _.assert( arguments.length === 1, 'expects single argument' );
  var result = process.env[ ( process.platform == 'win32' ) ? 'USERPROFILE' : 'HOME' ] || __dirname;
  result = _.path.pathNormalize( result );
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

  o.packagePath = _.path.pathNormalize( _.path.pathJoin( o.packagePath, 'tmp.tmp', o.packageName ) );

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
// define class
// --

var Proto =
{


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
  // dirTempFree : dirTempFree, // qqq : implement

  pathForCopy : pathForCopy,

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
