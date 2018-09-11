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

  _.include( 'wPathFundamentals' );

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
 * @memberof wTools.path
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
 * @memberof wTools.path
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
 * @memberof wTools.path
 */

var effectiveMainFile = ( function effectiveMainFile()
{
  var result = '';

  return function effectiveMainFile()
  {
    _.assert( !!this.fileProvider );
    _.assert( arguments.length === 0 );

    if( result )
    return result;

    if( process.argv[ 0 ] || process.argv[ 1 ] )
    {
      result = _.path.join( _.path.currentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] );
      result = _.path.resolve( result );
    }

    if( !this.fileProvider.fileStat( result ) )
    {
      debugger;
      console.error( 'process.argv :', process.argv.join( ',' ) );
      console.error( 'currentAtBegin :', _.path.currentAtBegin );
      console.error( 'effectiveMainFile.raw :', _.path.join( _.path.currentAtBegin, process.argv[ 1 ] || process.argv[ 0 ] ) );
      console.error( 'effectiveMainFile :', result );
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
 * @memberof wTools.path
 */

function effectiveMainDir()
{
  _.assert( arguments.length === 0 );

  var result = _.path.dir( this.effectiveMainFile() );

  return result;
}

// function current()
// {
//   _.assert( !!this.fileProvider );
//   var result = this.fileProvider.pathCurrent.apply( this.fileProvider, arguments );
//   return result;
// }

//
//
// function nativize()
// {
//   _.assert( !!this.fileProvider );
//   var result = this.fileProvider.path.nativize.apply( this.fileProvider, arguments );
//   return result;
// }

//

/**
 * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
 * for windows environment variables.
 * @returns {string}
 * @method userHome
 * @memberof wTools.path
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
  _.assert( !!this.fileProvider );
  return this.fileProvider.resolveTextLink.apply( this.fileProvider,arguments );
}

//

function _pathResolveTextLink( path )
{
  _.assert( !!this.fileProvider );
  return this.fileProvider._pathResolveTextLink.apply( this.fileProvider,arguments );
}

//

function dirTempFor( o )
{
  _.assert( arguments.length <= 2 );

  if( arguments.length === 1 )
  {
    if( arguments[ 0 ] !== undefined && arguments[ 0 ] !== null )
    o = { packageName : arguments[ 0 ] }
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

  _.assert( !_.path.isAbsolute( o.packageName ), 'dirTempFor: {o.packageName} must not contain an absolute path:', o.packageName );

  o.fullPath = _.path.normalize( _.path.join( o.packagePath, 'tmp.tmp', o.packageName ) );

  return o.fullPath;
}

dirTempFor.defaults =
{
  packageName : null,
  packagePath : null
}

//

function dirTempOpen( packagePath, packageName )
{
  _.assert( !!this.fileProvider );
  var packagePath = _.path.dirTempFor.apply( _, arguments );
  this.fileProvider.filesDelete({ filePath : packagePath, throwing : 0 });
  this.fileProvider.directoryMake( packagePath );
  return packagePath;
}

//

function dirTempClose( filePath )
{
  _.assert( arguments.length === 1 );
  _.assert( !!this.fileProvider );
  _.assert( _.path.isAbsolute( filePath ) );
  _.assert( _.strHas( _.path.normalize( filePath ), '/tmp.tmp/' ), 'dirTempClose: provided path does not contain temporary directory:', filePath );
  this.fileProvider.filesDelete({ filePath : filePath, throwing : 0 });
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
 * @memberof wTools.path
 */

function forCopy( o )
{
  _.assert( !!this.fileProvider );
  return this.fileProvider.forCopy.apply( this.fileProvider, arguments );
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

  // current : current,
  // nativize : nativize,

  userHome : userHome,

  resolveTextLink : resolveTextLink,
  _pathResolveTextLink : _pathResolveTextLink,

  dirTempFor : dirTempFor,
  dirTempOpen : dirTempOpen,
  dirTempClose : dirTempClose, // qqq : implement

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
