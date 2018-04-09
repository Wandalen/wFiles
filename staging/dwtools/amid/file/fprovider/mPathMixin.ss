(function _PathMixin_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../FileMid.s' );

  _.include( 'wPath' );

  var File = require( 'fs-extra' );

}

var _ = _global_.wTools;

// --
//
// --

function _mixin( cls )
{

  var dstProto = cls.prototype;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( cls ) );

  _.mixinApply
  ({
    dstProto : dstProto,
    descriptor : Self,
  });

}

//

function pathCurrent()
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  try
  {

    var path = arguments[ 0 ];
    _.assert( _.strIs( path ) );

    if( !_.pathIsAbsolute( path ) )
    path = _.pathJoin( self.pathCurrentAct(), path );

    if( self.fileStat( path ) && self.fileIsTerminal( path ) )
    path = self.pathResolve( path,'..' );

    self.pathCurrentAct( self.pathNativize( path ) );

  }
  catch( err )
  {
    throw _.err( 'file was not found : ' + arguments[ 0 ] + '\n',err );
  }

  var result = self.pathCurrentAct();

  _.assert( _.strIs( result ) );

  result = _.pathNormalize( result );

  return result;
}

//

function pathResolve()
{
  var self = this;
  var path;

  _.assert( arguments.length > 0 );

  path = _.pathJoin.apply( _,arguments );

  if( path[ 0 ] !== '/' )
  path = _.pathJoin( self.pathCurrent(),path );

  path = _.pathNormalize( path );

  _.assert( path.length > 0 );

  return path;
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
 * @throws {Error} If file for `o.path` is not exists.
 * @method pathForCopy
 * @memberof wTools
 */

function pathForCopy( o )
{
  var fileProvider = this;

  if( !_.mapIs( o ) )
  o = { path : o };

  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( _.strIs( o.path ) );
  _.assert( arguments.length === 1 );
  _.routineOptions( pathForCopy,o );

  var postfix = _.strPrependOnce( o.postfix, o.postfix ? '-' : '' );
  var file = _.FileRecord( o.path,{ fileProvider : fileProvider } );

  // debugger;
  // if( !fileProvider.fileStat({ filePath : file.absolute, sync : 1 }) )
  // throw _.err( 'pathForCopy : original does not exit : ' + file.absolute );

  var parts = _.strSplit({ src : file.name, delimeter : '-' });
  if( parts[ parts.length-1 ] === o.postfix )
  file.name = parts.slice( 0,parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous

  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  file.name = parts.slice( 0,parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  file.name = parts.slice( 0,parts.length-2 ).join( '-' );

  /*file.absolute =  file.dir + '/' + file.name + file.extWithDot;*/

  var path = _.pathJoin( file.dir , file.name + postfix + file.extWithDot );
  if( !fileProvider.fileStat({ filePath : path , sync : 1 }) )
  return path;

  var attempts = 1 << 13;
  var index = 1;

  while( attempts > 0 )
  {

    var path = _.pathJoin( file.dir , file.name + postfix + '-' + index + file.extWithDot );

    if( !fileProvider.fileStat({ filePath : path , sync : 1 }) )

    return path;

    attempts -= 1;
    index += 1;

  }

  throw _.err( 'pathForCopy : cant make copy path for : ' + file.absolute );
}

pathForCopy.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  path : null,
}

//

function pathFirstAvailable( o )
{
  var self = this;

  if( _.arrayIs( o ) )
  o = { paths : o }

  _.routineOptions( pathFirstAvailable,o );
  _.assert( _.arrayIs( o.paths ) );
  _.assert( arguments.length === 1 );

  for( var p = 0 ; p < o.paths.length ; p++ )
  {
    var path = o.paths[ p ];
    if( self.fileStat( o.onPath ? o.onPath.call( o,path,p ) : path ) )
    return path;
  }

  return undefined;
}

pathFirstAvailable.defaults =
{
  paths : null,
  onPath : null,
}

//

function pathResolveTextLink( path, allowNotExisting )
{
  return this._pathResolveTextLink( path,allowNotExisting ).path;
}

//

function _pathResolveTextLink( path, allowNotExisting )
{
  var result = this._pathResolveTextLinkAct( path,[],false,allowNotExisting );

  if( !result )
  return { resolved : false, path : path };

  _.assert( arguments.length === 1 || arguments.length === 2  );

  if( result && path[ 0 ] === '.' && !_.pathIsAbsolute( result ) )
  result = './' + result;

  logger.log( 'pathResolveTextLink :',path,'->',result );

  return { resolved : true, path : result };
}

//

var _pathResolveTextLinkAct = ( function()
{
  var buffer;

  return function _pathResolveTextLinkAct( path,visited,hasLink,allowNotExisting )
  {

    if( !buffer )
    buffer = new Buffer( 512 );

    if( visited.indexOf( path ) !== -1 )
    throw _.err( 'cyclic text link :',path );
    visited.push( path );

    var regexp = /link ([^\n]+)\n?$/;

    path = _.pathNormalize( path );
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
      {
        if( allowNotExisting )
        return path;
        else
        return false;
      }

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

        var result = _pathResolveTextLinkAct( path,visited,hasLink,allowNotExisting );
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

//

function pathResolveSoftLink( path )
{
  var self = this;
  var result = this.pathResolveSoftLinkAct( path );
  return _.pathNormalize( result );
}

//

var pathResolveSoftLinkAct = {};

// --
// prototype
// --

var Supplement =
{

  pathCurrentAct : null,

  pathCurrent : pathCurrent,
  pathResolve : pathResolve,
  pathForCopy : pathForCopy,

  pathFirstAvailable : pathFirstAvailable,

  pathResolveTextLink : pathResolveTextLink,
  _pathResolveTextLink : _pathResolveTextLink,
  _pathResolveTextLinkAct : _pathResolveTextLinkAct,

  pathResolveSoftLink : pathResolveSoftLink,
  pathResolveSoftLinkAct : pathResolveSoftLinkAct,

}

//

var Self =
{

  supplement : Supplement,

  name : 'wFilePorviderPathMixin',
  nameShort : 'Path',
  _mixin : _mixin,

}

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.nameShort ] = _.mixinMake( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
