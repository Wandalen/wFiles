(function _Path_ss_() {

'use strict';

// let toBuffer = null;
// let Os = null;

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

  // Os = require( 'os' );

  let _ = _global_.wTools;

  _.include( 'wPathFundamentals' );

}

let _global = _global_;
let _ = _global_.wTools;
let Self = _global_.wTools.path;

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

let _pathRealMainFile;
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

let _pathRealMainDir;
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

let effectiveMainFile = ( function effectiveMainFile()
{
  let result = '';

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

    if( !this.fileProvider.statResolvedRead( result ) )
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

  let result = _.path.dir( this.effectiveMainFile() );

  return result;
}

//

function resolveTextLink( path )
{
  _.assert( !!this.fileProvider );
  return this.fileProvider.pathResolveTextLink.apply( this.fileProvider,arguments );
}

//

function _resolveTextLink( path )
{
  _.assert( !!this.fileProvider );
  return this.fileProvider._pathResolveTextLink.apply( this.fileProvider,arguments );
}

//

/**
 * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
 * for windows environment variables.
 * @returns {string}
 * @method userHome
 * @memberof wTools.path
 */

function dirUserHome()
{
  _.assert( arguments.length === 0 );
  _.assert( _.routineIs( this.fileProvider.pathDirUserHomeAct ) );
  if( this.userHomePath )
  return this.userHomePath;
  return this.fileProvider.pathDirUserHomeAct();
}

//

function dirTemp()
{
  _.assert( arguments.length === 0 );
  _.assert( _.routineIs( this.fileProvider.pathDirTempAct ) );
  if( this.tempPath )
  return this.tempPath;
  return this.fileProvider.pathDirTempAct();
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

  o = _.routineOptions( dirTempFor,o );

  if( !o.packageName)
  o.packageName = _.idWithGuid();
  else
  o.packageName = _.path.join( o.packageName, _.idWithGuid() );

  // if( !o.packagePath )
  // o.packagePath = Os ? Os.tmpdir() : '/';

  if( !o.packagePath )
  o.packagePath = _.path.dirTemp();

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
  packagePath = _.path.dirTempFor.apply( _, arguments );
  this.fileProvider.filesDelete({ filePath : packagePath, throwing : 0 });
  this.fileProvider.dirMake( packagePath );
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

function _forCopy_pre( routine,args )
{
  // let self = this;

  _.assert( args.length === 1 );

  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { filePath : o };

  _.routineOptions( routine,o );
  // _.assert( self instanceof _.FileProvider.Abstract );
  _.assert( _.strIs( o.filePath ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return o;
}

//

function _forCopy_body( o )
{
  let path = this;
  let fileProvider = this.fileProvider;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let postfix = _.strPrependOnce( o.postfix, o.postfix ? '-' : '' );
  let file = fileProvider.recordFactory().record( o.filePath );
  let name = file.name;

  let parts = _.strSplitFast({ src : name, delimeter : '-', preservingEmpty : 0, preservingDelimeters : 0 });
  if( parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0,parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous

  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0,parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  name = parts.slice( 0,parts.length-2 ).join( '-' );

  /*file.absolute =  file.dir + '/' + file.name + file.extWithDot;*/

  let filePath = path.join( file.dir , name + postfix + file.extWithDot );
  if( !fileProvider.statResolvedRead({ filePath : filePath , sync : 1 }) )
  return filePath;

  let attempts = 1 << 13;
  let index = 1;

  while( attempts > 0 )
  {

    let filePath = path.join( file.dir , name + postfix + '-' + index + file.extWithDot );

    if( !fileProvider.statResolvedRead({ filePath : filePath , sync : 1 }) )
    return filePath;

    attempts -= 1;
    index += 1;

  }

  throw _.err( 'Cant make copy path for : ' + file.absolute );
}

_forCopy_body.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  filePath : null,
}

// var paths = _forCopy_body.paths = Object.create( null );
var having = _forCopy_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';

//

/**
 * Generate path string for copy of existing file passed into `o.path`. If file with generated path is exists now,
 * method try to generate new path by adding numeric index into tail of path, before extension.
 * @example
 * let str = 'foo/bar/baz.txt',
   let path = wTools.pathforCopy( {path : str } ); // 'foo/bar/baz-copy.txt'
 * @param {Object} o options argument
 * @param {string} o.path Path to file for create name for copy.
 * @param {string} [o.postfix='copy'] postfix for mark file copy.
 * @returns {string} path for copy.
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If passed object has unexpected property.
 * @throws {Error} If file for `o.path` is not exists.
 * @method forCopy
 * @memberof wTools.path
 */

let forCopy = _.routineFromPreAndBody( _forCopy_pre, _forCopy_body );

forCopy.having.aspect = 'entry';

// /**
//  * Generate path string for copy of existing file passed into `o.path`. If file with generated path is exists now,
//  * method try to generate new path by adding numeric index into tail of path, before extension.
//  * @example
//  * let str = 'foo/bar/baz.txt',
//    let path = wTools.forCopy( {path : str } ); // 'foo/bar/baz-copy.txt'
//  * @param {Object} o options argument
//  * @param {string} o.path Path to file for create name for copy.
//  * @param {string} [o.postfix='copy'] postfix for mark file copy.
//  * @returns {string} path for copy.
//  * @throws {Error} If missed argument, or passed more then one.
//  * @throws {Error} If passed object has unexpected property.
//  * @throws {Error} If file for `o.path` is not exist.
//  * @method forCopy
//  * @memberof wTools.path
//  */
//
// function forCopy( o )
// {
//   // _.assert( !!this.fileProvider );
//   // return this.fileProvider.forCopy.apply( this.fileProvider, arguments );
// }
//
// forCopy.defaults =
// {
//   delimeter : '-',
//   postfix : 'copy',
//   path : null,
// }

function _firstAvailable_pre( routine,args )
{
  // let self = this;

  _.assert( args.length === 1 );

  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { paths : o }

  _.routineOptions( routine,o );
  _.assert( _.arrayIs( o.paths ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return o;
}

//

function _firstAvailable_body( o )
{
  let path = this;
  let fileProvdier = path.fileProvider;

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let p = 0 ; p < o.paths.length ; p++ )
  {
    let path = o.paths[ p ];
    if( fileProvdier.fileExists( o.onPath ? o.onPath.call( o,path,p ) : path ) )
    return path;
  }

  return undefined;
}

_firstAvailable_body.defaults =
{
  paths : null,
  onPath : null,
}

// var paths = _firstAvailable_body.paths = Object.create( null );
var having = _firstAvailable_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';

let firstAvailable = _.routineFromPreAndBody( _firstAvailable_pre, _firstAvailable_body );

firstAvailable.having.aspect = 'entry';

// --
// declare
// --

let Proto =
{

  realMainFile : realMainFile,
  realMainDir : realMainDir,

  effectiveMainFile : effectiveMainFile,
  effectiveMainDir : effectiveMainDir,

  resolveTextLink : resolveTextLink,
  _resolveTextLink : _resolveTextLink,

  dirUserHome : dirUserHome,
  dirTemp : dirTemp,
  dirTempFor : dirTempFor,
  dirTempOpen : dirTempOpen,
  dirTempClose : dirTempClose,
  forCopy : forCopy,
  firstAvailable : firstAvailable,

}

_.mapExtend( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
{ /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
