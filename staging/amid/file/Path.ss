(function _Path_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  // require( './HardDrive.ss' );

  wTools.include( 'wPath' );

  var Path = require( 'path' );
  var File = require( 'fs-extra' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var fileProvider = _.fileProvider;
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
  else throw _.err( 'pathGet : unexpected type of argument : ' + _.strTypeOf( src ) );

}

//

/**
 * Generate path string for copy of existing file passed into `o.srcPath`. If file with generated path is exists now,
 * method try to generate new path by adding numeric index into tail of path, before extension.
 * @example
 * var pathStr = 'foo/bar/baz.txt',
   var path = wTools.pathForCopy( {srcPath : pathStr } ); // 'foo/bar/baz-copy.txt'
 * @param {Object} o options argument
 * @param {string} o.srcPath Path to file for create name for copy.
 * @param {string} [o.postfix='copy'] postfix for mark file copy.
 * @returns {string} path for copy.
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If passed object has unexpected property.
 * @throws {Error} If file for `o.srcPath` is not exists.
 * @method pathForCopy
 * @memberof wTools
 */

function pathForCopy( o )
{

  if( !_.mapIs( o ) )
  o = { srcPath : o };

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( o,pathForCopy.defaults );
  _.mapSupplement( o,pathForCopy.defaults );

  o.srcPath = _.fileProvider.fileRecord( o.srcPath );

  if( !_.fileProvider.fileStat( o.srcPath.absolute ) )
  throw _.err( 'pathForCopy : original does not exit : ' + o.srcPath.absolute );

  var parts = _.strSplit({ src : o.srcPath.name, delimeter : '-' });
  if( parts[ parts.length-1 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous

  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-2 ).join( '-' );

  /*o.srcPath.absolute =  o.srcPath.dir + '/' + o.srcPath.name + o.srcPath.extWithDot;*/

  var path = _.pathJoin( o.srcPath.dir , o.srcPath.name + '-' + o.postfix + o.srcPath.extWithDot );
  if( !_.fileProvider.fileStat( path ) )
  return path;

  var attempts = 1 << 13;
  var index = 1;

  while( attempts > 0 )
  {

    var path = _.pathJoin( o.srcPath.dir , o.srcPath.name + '-' + o.postfix + '-' + index + o.srcPath.extWithDot );

    if( !_.fileProvider.fileStat( path ) )
    return path;

    attempts -= 1;
    index += 1;

  }

  throw _.err( 'pathForCopy : cant make copy path for : ' + o.srcPath.absolute );
}

pathForCopy.defaults =
{
  postfix : 'copy',
  srcPath : null,
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
      '.DS_Store',
      'Thumbs.db',
      'thumbs.db',
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
  _pathRealMainDir = _.pathRegularize( Path.dirname( require.main.filename ) );
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
  return _pathResolveTextLink( path ).path;
}

//

function _pathResolveTextLink( path )
{
  var result = _pathResolveTextLinkAct( path,[],false );

  if( !result )
  return { resolved : false, path : path };

  _.assert( arguments.length === 1 );

  if( result && path[ 0 ] === '.' && !_.pathIsAbsolute( result ) )
  result = './' + result;

  logger.log( 'pathResolveTextLink :',path,'->',result );

  return { resolved : true, path : result };
}

//

var _pathResolveTextLinkAct = ( function()
{
  var buffer = new Buffer( 512 );

  return function _pathResolveTextLinkAct( path,visited,hasLink )
  {

    if( visited.indexOf( path ) !== -1 )
    throw _.err( 'cyclic text link :',path );
    visited.push( path );

    var regexp = /link ([^\n]+)\n?$/;

    path = _.pathRegularize( path );
    var exists = _.fileProvider.fileStat( path );

    var prefix,parts;
    if( path[ 0 ] === '/' )
    {
      prefix = '/';
      parts = path.substr( 1 ).split( '/' );
    }
    else
    {
      prefix = '';
      parts = path.split( '/' );
    }

    for( var p = exists ? p = parts.length-1 : 0 ; p < parts.length ; p++ )
    {

      var cpath = _.fileProvider.pathNativize( prefix + parts.slice( 0,p+1 ).join( '/' ) );

      var stat = _.fileProvider.fileStat( cpath );
      if( !stat )
      return false;

      if( stat.isFile() )
      {

        var size = stat.size;
        var readSize = 256;
        var f = File.openSync( cpath, 'r' );
        do
        {

          readSize *= 2;
          readSize = Math.min( readSize,size );
          if( buffer.length < readSize )
          buffer = new Buffer( readSize );
          File.readSync( f,buffer,0,readSize,0 );
          var read = buffer.toString( 'utf8',0,readSize );
          var m = read.match( regexp );

        }
        while( m && readSize < size );
        File.close( f );

        if( m )
        hasLink = true;

        if( !m )
        if( p !== parts.length-1 )
        return false;
        else
        return hasLink ? path : false;

        var path = _.pathJoin( m[ 1 ],parts.slice( p+1 ).join( '/' ) );

        if( path[ 0 ] === '.' )
        path = _.pathReroot( cpath , '..' , path );

        var result = _pathResolveTextLinkAct( path,visited,hasLink );
        if( hasLink )
        {
          if( !result )
          {
            debugger;
            throw _.err
            (
              'cant resolve : ' + visited[ 0 ] +
              '\nnot found : ' + ( m ? m[ 1 ] : path ) +
              '\nlooked at :\n' + ( visited.join( '\n' ) )
            );
          }
          else
          return result;
        }
        else
        {
          throw _.err( 'not expected' );
          return result;
        }
      }

    }

    return hasLink ? path : false;
  }

})();

// --
// prototype
// --

var Proto =
{

  pathGet : pathGet,
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
  _pathResolveTextLinkAct : _pathResolveTextLinkAct,

}

_.mapExtend( Self,Proto );

// console.log( __dirname,': _Path_ss_ : _.pathGet' );
// console.log( _.pathGet );

//

// console.log( 'pathEffectiveMainFile : ' + _.pathEffectiveMainFile() );
// console.log( 'pathRealMainFile : ' + _.pathRealMainFile() );
// console.log( 'pathCurrent : ' + _.pathCurrent() );

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
