(function _FilePath_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  require( './provider/FileProviderHardDrive.ss' );

}

var Path = require( 'path' );
var File = require( 'fs-extra' );

var _ = wTools;
var FileRecord = _.FileRecord;
var fileProvider = _.FileProvider.HardDrive();
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

var pathGet = function( src )
{

  _.assert( arguments.length === 1 );

  if( _.strIs( src ) )
  return src;
  else if( src instanceof wFileRecord )
  return src.absolute;
  else throw _.err( 'pathGet : unexpected type of argument : ' + _.strTypeOf( src ) );

}

//

/**
 * Generate path string for copy of existing file passed into `o.srcPath`. If file with generated path is exists now,
 * method try to generate new path by adding numeric index into tail of path, before extension.
 * @example
 * var pathStr = 'foo/bar/baz.txt',
   var path = wTools.pathCopy( {srcPath : pathStr } ); // 'foo/bar/baz-copy.txt'
 * @param {Object} o options argument
 * @param {string} o.srcPath Path to file for create name for copy.
 * @param {string} [o.postfix='copy'] postfix for mark file copy.
 * @returns {string} path for copy.
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If passed object has unexpected property.
 * @throws {Error} If file for `o.srcPath` is not exists.
 * @method pathCopy
 * @memberof wTools
 */

var pathCopy = function( o )
{

  if( !_.mapIs( o ) )
  o = { srcPath : o };

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( o,pathCopy.defaults );
  _.mapSupplement( o,pathCopy.defaults );

  o.srcPath = wFileRecord( o.srcPath );

  if( !File.existsSync( o.srcPath.absolute ) )
  throw _.err( 'pathCopy : original does not exit : ' + o.srcPath.absolute );

  var parts = _.strSplit({ src : o.srcPath.name, splitter : '-' });
  if( parts[ parts.length-1 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous
  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-2 ).join( '-' );

  /*o.srcPath.absolute =  o.srcPath.dir + '/' + o.srcPath.name + o.srcPath.extWithDot;*/

  var path = o.srcPath.dir + '/' + o.srcPath.name + '-' + o.postfix + o.srcPath.extWithDot;
  if( !File.existsSync( path ) )
  return path;

  var attempts = 1 << 13;
  var index = 1;

  // while( attempts > 0 )
  while( attempts-- )
  {

    var path = o.srcPath.dir + '/' + o.srcPath.name + '-' + o.postfix + '-' + index + o.srcPath.extWithDot;

    if( !File.existsSync( path ) )
    return path;

    // attempts -= 1;
    index += 1;

  }

  throw _.err( 'pathCopy : cant make copy path for : ' + o.srcPath.absolute );
}

pathCopy.defaults =
{
  postfix : 'copy',
  srcPath : null,
}

//

/**
 * Normalize a path by collapsing redundant separators and  resolving '..' and '.' segments, so A//B, A/./B and
    A/foo/../B all become A/B. This string manipulation may change the meaning of a path that contains symbolic links.
    On Windows, it converts forward slashes to backward slashes. If the path is an empty string, method returns '.'
    representing the current working directory.
 * @example
   var path = '/foo/bar//baz1/baz2//some/..'
   path = wTools.pathNormalize( path ); // /foo/bar/baz1/baz2
 * @param {string} src path for normalization
 * @returns {string}
 * @method pathNormalize
 * @memberof wTools
 */

var pathNormalize = function( src )
{

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( src ) );

  var hasDot = src[ 0 ] === '.' && ( src[ 1 ] === '/' || src[ 1 ] === '\\' );
  var result = Path.normalize( src ).replace( /\\/g,'/' );
  if( hasDot )
  result = './' + result;

  return result;
}

//

/**
 * Returns a relative path to `path` from an `relative` path. This is a path computation : the filesystem is not
   accessed to confirm the existence or nature of path or start. As second argument method can accept array of paths,
   in this case method returns array of appropriate relative paths. If `relative` and `path` each resolve to the same
   path method returns '.'.
 * @example
 * var pathFrom = '/foo/bar/baz',
   pathsTo =
   [
     '/foo/bar',
     '/foo/bar/baz/dir1',
   ],
   relatives = wTools.pathRelative( pathFrom, pathsTo ); //  [ '..', 'dir1' ]
 * @param {string|wFileRecord} relative start path
 * @param {string|string[]} path path to.
 * @returns {string|string[]}
 * @method pathRelative
 * @memberof wTools
 */

var pathRelative = function( relative,path )
{

  var relative = _.pathGet( relative );

  _.assert( arguments.length === 2 );
  _.assert( _.strIs( relative ) );
  _.assert( _.strIs( path ) || _.arrayIs( path ) );

  if( _.arrayIs( path ) )
  {
    var result = [];
    for( var p = 0 ; p < path.length ; p++ )
    result[ p ] = _.pathRelative( relative,path [p ] );
    return result;
  }

  var result = Path.relative( relative,path );
  result = _.pathNormalize( result );

  //console.log( 'pathRelative :',relative,path,result );

  return result;
}

//

  /**
   * Method resolves a sequence of paths or path segments into an absolute path.
   * The given sequence of paths is processed from right to left, with each subsequent path prepended until an absolute
   * path is constructed. If after processing all given path segments an absolute path has not yet been generated,
   * the current working directory is used.
   * @example
   * var absPath = wTools.pathResolve('work/wFiles'); // '/home/user/work/wFiles';
   * @param [...string] paths A sequence of paths or path segments
   * @returns {string}
   * @method pathResolve
   * @memberof wTools
   */

var pathResolve = function()
{

  var result = Path.resolve.apply( this,arguments );
  result = _.pathNormalize( result );

  return result;
}

//

  /**
   * Checks if string is correct possible for current OS path and represent file/directory that is safe for modification
   * (not hidden for example).
   * @param pathFile
   * @returns {boolean}
   * @method pathIsSafe
   * @memberof wTools
   */

var pathIsSafe = function( pathFile )
{
  var safe = true;

  _.assert( _.strIs( pathFile ) );

  safe = safe && !/(^|\/)\.(?!$|\/)/.test( pathFile );

  if( safe )
  safe = pathFile.length > 8 || ( pathFile[ 0 ] !== '/' && pathFile[ 1 ] !== ':' );

  return safe;
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
     /(^|\/)\.(?!$|\/)/, // any hidden paths
     /(^|\/)-(?!$|\/)/,
   * @example :
   * var paths =
      {
        includeAny : [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
        includeAll : [ 'index.js' ],
        excludeAny : [ 'Gruntfile.js', 'gulpfile.js' ],
        excludeAll : [ 'package.json', 'bower.json' ]
      };
     var regObj = pathRegexpSafeShrink( paths );
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
   //        /(^|\/)\.(?!$|\/)/,
   //        /(^|\/)-(?!$|\/)/
   //      ],
   //    excludeAll : [ /package\.json/, /bower\.json/ ]
   //  }
   * @param {string|string[]|RegexpObject} [maskAll]
   * @returns {RegexpObject}
   * @throws {Error} if passed more than one argument.
   * @see {@link wTools~RegexpObject} RegexpObject
   * @method pathRegexpSafeShrink
   * @memberof wTools
   */

var pathRegexpSafeShrink = function( maskAll )
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
      /(^|\/)\.(?!$|\/)/,
      /(^|\/)-(?!$|\/)/,
    ],
  });

  maskAll = _.RegexpObject.shrink( maskAll,excludeMask );

  return maskAll;
}

//

  /**
   * Returns path for main module (module that running directly by node).
   * @returns {string}
   * @method pathMainFile
   * @memberof wTool
   */

var _pathMainFile;
var pathMainFile = function()
{
  if( _pathMainFile ) return _pathMainFile;
  _pathMainFile = _.pathNormalize( require.main.filename );
  return _pathMainFile;
}

//

  /**
   * Returns path dir name for main module (module that running directly by node).
   * @returns {string}
   * @method pathMainDir
   * @memberof wTool
   */

var _pathMainDir;
var pathMainDir = function()
{
  if( _pathMainDir ) return _pathMainDir;
  _pathMainDir = _.pathNormalize( Path.dirname( require.main.filename ) );
  return _pathMainDir;
}

//

  /**
   * Returns absolute path for file running directly by node
   * @returns {string}
   * @throws {Error} If passed any argument.
   * @method pathBaseFile
   * @memberof wTool
   */

var pathBaseFile = function pathBaseFile()
{

  var result = '';

  return function pathBaseFile()
  {
    _.assert( arguments.length === 0 );

    if( result )
    return result;

    if( process.argv[ 0 ] || process.argv[ 1 ] )
    {
      result = _.pathJoin( _.pathCurrentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] );
      result = _.pathNormalize( Path.resolve( result ) );
    }

    if( !File.existsSync( result ) )
    {
      console.error( 'process.argv :',process.argv.join( ',' ) );
      console.error( 'pathCurrentAtBegin :',_.pathCurrentAtBegin );
      console.error( 'pathBaseFile.raw :',_.pathJoin( _.pathCurrentAtBegin,process.argv[ 1 ] || process.argv[ 0 ] ) );
      console.error( 'pathBaseFile :',result );
      console.error( 'not tested' );
      debugger;
      //throw _.err( 'not tested' );
      result = _.pathMainFile();
    }

    return result;
  }

}();

//

  /**
   * Returns path dirname for file running directly by node
   * @returns {string}
   * @throws {Error} If passed any argument.
   * @method pathBaseFile
   * @memberof wTool
   */

var pathBaseDir = function()
{
  _.assert( arguments.length === 0 );

  var result = _.pathDir( pathBaseFile() );

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

var pathCurrent = function()
{
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  try
  {

    var path = arguments[ 0 ];
    _.assert( _.strIs( path ) );

    if( fileProvider.fileStat( path ) && fileProvider.fileIsTerminal( path ) )
    path = _.pathJoin( path,'..' );

    process.chdir( path );

  }
  catch( err )
  {
    throw _.err( 'file was not found : ' + arguments[ 0 ] + '\n',err );
  }

  var result = process.cwd();
  result = _.pathNormalize( result );

  return result;
}

//

/**
 * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
 * for windows environment variables.
 * @returns {string}
 * @method pathHome
 * @memberof wTool
 */

var pathHome = function()
{
  var home = process.env[ ( process.platform == 'win32' ) ? 'USERPROFILE' : 'HOME' ] || __dirname;
  return home;
}

//

var pathResolveTextLink = function( path )
{
  return _pathResolveTextLink( path ).path;
}

//

var _pathResolveTextLink = function( path )
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

    path = _.pathNormalize( path );
    var exists = fileProvider.fileStat( path );

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

      var cpath = prefix + parts.slice( 0,p+1 ).join( '/' );

      var stat = fileProvider.fileStat( cpath );
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
        path = cpath + '/../' + path;

        var result = _pathResolveTextLinkAct( path,visited,hasLink );
        if( hasLink )
        {
          if( !result )
          throw _.err( 'cant resolve : ' + ( m ? m[ 1 ] : path ) );
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
  pathCopy : pathCopy,

  pathNormalize : pathNormalize,
  pathRelative : pathRelative,
  pathResolve : pathResolve,

  pathIsSafe : pathIsSafe,
  pathRegexpSafeShrink : pathRegexpSafeShrink,

  pathMainFile : pathMainFile,
  pathMainDir : pathMainDir,

  pathBaseFile : pathBaseFile,
  pathBaseDir : pathBaseDir,

  pathCurrent : pathCurrent,
  pathHome : pathHome,

  pathResolveTextLink : pathResolveTextLink,
  _pathResolveTextLink : _pathResolveTextLink,
  _pathResolveTextLinkAct : _pathResolveTextLinkAct,

}

_.mapExtend( Self,Proto );

//

console.log( 'pathBaseFile : ' + _.pathBaseFile() );
console.log( 'pathMainFile : ' + _.pathMainFile() );
console.log( 'pathCurrent : ' + _.pathCurrent() );

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
