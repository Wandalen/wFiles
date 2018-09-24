( function _Partial_s_() {

'use strict';

var _global = _global_;
var _ = _global_.wTools;

_.assert( !_.FileProvider.wFileProviderPartial );
_.assert( _.routineIs( _.routineVectorize_functor ) );
_.assert( _.routineIs( _.path.join ) );

//

/**
  * Definitions :
  *  Terminal file :: leaf of files sysytem, contains series of bytes. Terminal file cant contain other files.
  *  Directory :: non-leaf node of files sysytem, contains other directories and terminal file(s).
  *  File :: any node of files sysytem, could be leaf( terminal file ) or non-leaf( directory ).
  *  Only terminal files contains series of bytes, function of directory to organize logical space for terminal files.
  *  self :: pathCurrent object.
  *  Self :: pathCurrent class.
  *  Parent :: parent class.
  *  Statics :: static fields.
  *  extend :: extend destination with all properties from source.
  */

/*
 Act version of method :

- should assert that path is absolute
- should not extend or delete fields of options map, no _providerOptions, routineOptions
- should path.nativize all paths in options map if needed by its own means !!!
- should expect normalized path, but not nativized
- should expect ready options map, no complex arguments preprocessing
- should not create folders structure for path


*/

//

var _global = _global_;
var _ = _global_.wTools;
var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderPartial( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Partial';

//

function init( o )
{
  var self = this;

  Parent.prototype.init.call( self );

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( self.path === null )
  {
    self.path = self.Path.CloneExtending({ fileProvider : self });
  }

  if( self.logger === null )
  self.logger = new _.Logger({ output : _global.logger });

  if( o )
  if( o.protocol !== undefined || o.originPath !== undefined )
  {
    if( o.protocol !== undefined )
    self.protocol = o.protocol;
    else if( o.originPath !== undefined )
    self.originPath = o.originPath;
  }

  if( self.verbosity >= 2 )
  self.logger.log( 'new',_.strTypeOf( self ) );

}

//

function finit()
{
  let self = this;
  if( self.hub )
  self.hub.providerUnregister( self );
  _.Copyable.prototype.finit.call( self );
}

//

function MakeDefault()
{

  _.assert( !!_.FileProvider.Default );
  _.assert( !_.fileProvider );
  _.fileProvider = new _.FileProvider.Default();
  _.assert( _.path.fileProvider === null );
  _.path.fileProvider = _.fileProvider;
  _.assert( _.path.fileProvider === _.fileProvider );
  _.assert( _.uri.fileProvider === _.fileProvider );

  return _.fileProvider;
}

// --
// etc
// --

function _providerOptions( o )
{
  var self = this;

  _.assert( _.objectIs( o ),'expects map { o }' );

  for( var k in self.ProviderDefaults )
  {
    if( o[ k ] === null )
    if( self[ k ] !== undefined && self[ k ] !== null )
    o[ k ] = self[ k ];
  }

  if( o.verbosity !== undefined && o.verbosity !== null )
  {
    if( !_.numberIs( o.verbosity ) )
    o.verbosity = o.verbosity ? 1 : 0;
    if( o.verbosity < 0 )
    o.verbosity = 0;
  }

}

//

function _preSinglePath( routine,args )
{
  var self = this;

  _.assert( args.length === 1 );

  var o = args[ 0 ];

  if( self.path.like( o ) )
  o = { filePath : self.path.from( o ) };

  _.routineOptions( routine, o );
  self._providerOptions( o );

  o.filePath = self.path.normalize( o.filePath );

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( self.path.isAbsolute( o.filePath ), 'expects absolute path {-o.filePath-}, but got', o.filePath );

  return o;
}

//

/**
 * Return options for file read/write. If `filePath is an object, method returns it. Method validate result option
    properties by default parameters from invocation context.
 * @param {string|Object} filePath
 * @param {Object} [o] Object with default options parameters
 * @returns {Object} Result options
 * @private
 * @throws {Error} If arguments is missed
 * @throws {Error} If passed extra arguments
 * @throws {Error} If missed `PathFiile`
 * @method _fileOptionsGet
 * @memberof FileProvider.Partial
 */

function _fileOptionsGet( filePath,o )
{
  var self = this;
  var o = o || Object.create( null );

  if( _.objectIs( filePath ) )
  {
    o = filePath;
  }
  else
  {
    o.filePath = filePath;
  }

  if( !o.filePath )
  throw _.err( '_fileOptionsGet :','expects (-o.filePath-)' );

  _.assertMapHasOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

//

function providerForPath( path )
{
  var self = this;
  _.assert( _.strIs( path ) );
  _.assert( !_.uri.isGlobal( path ) );
  return self;
}

// --
// path
// --

function localFromUri( url )
{
  var self = this;

  if( _.strIs( url ) )
  url = _.uri.parse( url );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.mapIs( url ) ) ;
  _.assert( _.strIs( url.localPath ) );
  _.assert( !self.protocols || !url.protocol || _.arrayHasAll( self.protocols, url.protocols ) );

  return url.localPath;
}

//

var localsFromUris = _.routineVectorize_functor
({
  routine : localFromUri,
  vectorizingMap : 0,
});

//

function urlFromLocal( localPath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( localPath ) )
  _.assert( self.path.isAbsolute( localPath ) );
  _.assert( _.strIs( self.originPath ) );

  return self.originPath + localPath;
}

//

var urlsFromLocals = _.routineVectorize_functor
({
  routine : urlFromLocal,
  vectorizingMap : 0,
});

//

function pathNativizeAct( filePath )
{
  var self = this;
  // debugger; xxx
  _.assert( _.strIs( filePath ) ) ;
  return filePath;
}

var having = pathNativizeAct.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 1;
having.kind = 'path';

// //
//
// var pathsNativize = _.routineVectorize_functor( path.nativize );

//

var pathCurrentAct = null;

//

// function pathCurrent()
// {
//   var self = this;
//
//   _.assert( arguments.length === 0 || arguments.length === 1 );
//   _.assert( _.routineIs( self.pathCurrentAct ) );
//
//   if( arguments[ 0 ] )
//   try
//   {
//
//     var path = arguments[ 0 ];
//     _.assert( _.strIs( path ) );
//
//     if( !self.path.isAbsolute( path ) )
//     path = self.path.join( self.pathCurrentAct(), path );
//
//     if( self.fileStat( path ) && self.fileIsTerminal( path ) )
//     path = self.path.resolve( path,'..' );
//
//     self.pathCurrentAct( path );
//
//   }
//   catch( err )
//   {
//     throw _.err( 'File was not found : ' + arguments[ 0 ] + '\n', err );
//   }
//
//   var result = self.pathCurrentAct();
//
//   _.assert( _.strIs( result ) );
//
//   result = self.path.normalize( result );
//
//   return result;
// }

//
//
// function pathResolve()
// {
//   var self = this;
//   var path;
//
//   _.assert( arguments.length > 0 );
//   _.assert( self instanceof _.FileProvider.Abstract );
//
//   path = self.path.join.apply( self.path,arguments );
//
//   if( path == null )
//   path = self.pathCurrent();
//   else if( !self.path.isAbsolute( path ) )
//   path = self.path.join( self.pathCurrent(), path );
//
//   path = self.path.normalize( path );
//
//   _.assert( path.length > 0 );
//
//   return path;
// }
//
// //
//
// var pathsResolve = _.path._pathMultiplicator_functor
// ({
//   routine : pathResolve
// })

//

function _pathForCopy_pre( routine,args )
{
  var self = this;

  _.assert( args.length === 1 );

  var o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { path : o };

  _.routineOptions( routine,o );
  _.assert( self instanceof _.FileProvider.Abstract );
  _.assert( _.strIs( o.path ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return o;
}

//

function _pathForCopy_body( o )
{
  var fileProvider = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var postfix = _.strPrependOnce( o.postfix, o.postfix ? '-' : '' );
  var file = fileProvider.fileRecord( o.path );
  let name = file.name;

  // debugger;
  // if( !fileProvider.fileStat({ filePath : file.absolute, sync : 1 }) )
  // throw _.err( 'forCopy : original does not exit : ' + file.absolute );

  var parts = _.strSplitFast({ src : name, delimeter : '-', preservingEmpty : 0, preservingDelimeters : 0 });
  if( parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0,parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous

  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0,parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  name = parts.slice( 0,parts.length-2 ).join( '-' );

  /*file.absolute =  file.dir + '/' + file.name + file.extWithDot;*/

  var path = fileProvider.path.join( file.dir , name + postfix + file.extWithDot );
  if( !fileProvider.fileStat({ filePath : path , sync : 1 }) )
  return path;

  var attempts = 1 << 13;
  var index = 1;

  while( attempts > 0 )
  {

    var path = fileProvider.path.join( file.dir , name + postfix + '-' + index + file.extWithDot );

    if( !fileProvider.fileStat({ filePath : path , sync : 1 }) )

    return path;

    attempts -= 1;
    index += 1;

  }

  throw _.err( 'Cant make copy path for : ' + file.absolute );
}

_pathForCopy_body.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  path : null,
}

var paths = _pathForCopy_body.paths = Object.create( null );
var having = _pathForCopy_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';

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
 * @throws {Error} If file for `o.path` is not exists.
 * @method forCopy
 * @memberof wTools
 */

// function forCopy( o )
// {
//   var self = this;
//   var o = self.forCopy.pre.call( self,self.forCopy,arguments );
//   var result = self.forCopy.body.call( self,o );
//   return result;
// }
//
// forCopy.pre = _pathForCopy_pre;
// forCopy.body = _pathForCopy_body;
//
// var defaults = forCopy.defaults = Object.create( _pathForCopy_body.defaults );
// var paths = forCopy.paths = Object.create( _pathForCopy_body.paths );
// var having = forCopy.having = Object.create( _pathForCopy_body.having );

var forCopy = _.routineForPreAndBody( _pathForCopy_pre, _pathForCopy_body );

forCopy.having.aspect = 'entry';

//

function _pathFirstAvailable_pre( routine,args )
{
  var self = this;

  _.assert( args.length === 1 );

  var o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { paths : o }

  _.routineOptions( routine,o );
  _.assert( _.arrayIs( o.paths ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return o;
}

//

function _pathFirstAvailable_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  for( var p = 0 ; p < o.paths.length ; p++ )
  {
    var path = o.paths[ p ];
    if( self.fileStat( o.onPath ? o.onPath.call( o,path,p ) : path ) )
    return path;
  }

  return undefined;
}

_pathFirstAvailable_body.defaults =
{
  paths : null,
  onPath : null,
}

var paths = _pathFirstAvailable_body.paths = Object.create( null );
var having = _pathFirstAvailable_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';

//

// function firstAvailable( o )
// {
//   var self = this;
//   var o = self.firstAvailable.pre.call( self,self.firstAvailable,arguments );
//   var result = self.firstAvailable.body.call( self,o );
//   return result;
// }
//
// firstAvailable.pre = _pathFirstAvailable_pre;
// firstAvailable.body = _pathFirstAvailable_body;
//
// var defaults = firstAvailable.defaults = Object.create( _pathFirstAvailable_body.defaults );
// var paths = firstAvailable.paths = Object.create( _pathFirstAvailable_body.paths );
// var having = firstAvailable.having = Object.create( _pathFirstAvailable_body.having );
//
// having.aspect = 'entry';

var firstAvailable = _.routineForPreAndBody( _pathFirstAvailable_pre, _pathFirstAvailable_body );

firstAvailable.having.aspect = 'entry';

//

var _pathResolveTextLinkAct = null;

//

function _pathResolveTextLink( path, allowNotExisting )
{
  var self = this;
  var result = self._pathResolveTextLinkAct( path,[],false,allowNotExisting );

  if( !result )
  return { resolved : false, path : path };

  _.assert( arguments.length === 1 || arguments.length === 2  );

  if( result && path[ 0 ] === '.' && !self.path.isAbsolute( result ) )
  result = './' + result;

  self.logger.log( 'resolveTextLink :',path,'->',result );

  return { resolved : true, path : result };
}

//

function resolveTextLink( path, allowNotExisting )
{
  var self = this;

  if( !self.usingTextLink )
  return path;

  _.assert( _.strIs( path ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  return self._pathResolveTextLink( path,allowNotExisting ).path;
}

//

var pathResolveSoftLinkAct = Object.create( null );

var defaults = pathResolveSoftLinkAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.readLink = 0;
defaults.relativeToDir = 0;

var paths = pathResolveSoftLinkAct.paths = Object.create( null );

paths.filePath = null;

var having = pathResolveSoftLinkAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

function _pathResolveSoftLink_body( o )
{
  var self = this;

  _.assert( _.routineIs( self.pathResolveSoftLinkAct ) );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!o.filePath );

  if( !self.fileIsSoftLink( o.filePath ) )
  return o.filePath;

  var result = self.pathResolveSoftLinkAct( o );

  return self.path.normalize( result );
}

var defaults = _pathResolveSoftLink_body.defaults = Object.create( pathResolveSoftLinkAct.defaults );
var paths = _pathResolveSoftLink_body.paths = Object.create( pathResolveSoftLinkAct.paths );
var having = _pathResolveSoftLink_body.having = Object.create( pathResolveSoftLinkAct.having );

having.driving = 0;
having.aspect = 'body';

//

function pathResolveSoftLink( path )
{
  var self = this;
  var o = self.pathResolveSoftLink.pre.call( self,self.pathResolveSoftLink,arguments );
  var result = self.pathResolveSoftLink.body.call( self,o );
  return result;
}

pathResolveSoftLink.pre = _preSinglePath;
pathResolveSoftLink.body = _pathResolveSoftLink_body;

var defaults = pathResolveSoftLink.defaults = Object.create( _pathResolveSoftLink_body.defaults );
var paths = pathResolveSoftLink.paths = Object.create( _pathResolveSoftLink_body.paths );
var having = pathResolveSoftLink.having = Object.create( _pathResolveSoftLink_body.having );

having.aspect = 'entry';

//

var pathResolveHardLinkAct = Object.create( null );

var defaults = pathResolveHardLinkAct.defaults = Object.create( null );

defaults.filePath = null;

var paths = pathResolveHardLinkAct.paths = Object.create( null );

paths.filePath = null;

var having = pathResolveHardLinkAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

function _pathResolveHardLink_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!o.filePath );

  if( !_.routineIs( self.pathResolveHardLinkAct ) )
  return o.filePath;

  if( !self.fileIsHardLink( o.filePath ) )
  return o.filePath;

  var result = self.pathResolveHardLinkAct( o );

  return self.path.normalize( result );
}

var defaults = _pathResolveHardLink_body.defaults = Object.create( pathResolveHardLinkAct.defaults );
var paths = _pathResolveHardLink_body.paths = Object.create( pathResolveHardLinkAct.paths );
var having = _pathResolveHardLink_body.having = Object.create( pathResolveHardLinkAct.having );

having.driving = 0;
having.aspect = 'body';

//

// function pathResolveHardLink( path )
// {
//   var self = this;
//   var o = self.pathResolveHardLink.pre.call( self,self.pathResolveHardLink,arguments );
//   var result = self.pathResolveHardLink.body.call( self,o );
//   return result;
// }
//
// pathResolveHardLink.pre = _preSinglePath;
// pathResolveHardLink.body = _pathResolveHardLink_body;
//
// var defaults = pathResolveHardLink.defaults = Object.create( _pathResolveHardLink_body.defaults );
// var paths = pathResolveHardLink.paths = Object.create( _pathResolveHardLink_body.paths );
// var having = pathResolveHardLink.having = Object.create( _pathResolveHardLink_body.having );

var pathResolveHardLink = _.routineForPreAndBody( _preSinglePath, _pathResolveHardLink_body );

pathResolveHardLink.having.aspect = 'entry';

//

// function pathResolveHardLink( path )
// {
//   var self = this;
//   _.assert( arguments.length === 1, 'expects single argument' );
//   return path;
// }

//

/*
  qqq : option preservingRelative:1 to preserve relative in path of soft link if happened to be so
*/

function _pathResolveLinkChain_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  // _.assert( _.boolLike( o.resolvingHardLink ) );
  _.assert( _.boolLike( o.resolvingSoftLink ) );
  _.assert( _.boolLike( o.resolvingTextLink ) );

  // if( o.filePath === '/production/semantic/themes/basic/assets/fonts/icons.eot' )
  // debugger;

  // if( _.strHas( o.filePath, 'index2.usefile.s' ) )
  // debugger;

  var hub = o.hub || self.hub;
  if( hub && hub !== self && _.uri.isGlobal( o.filePath ) )
  return hub.resolveLinkChain.body.call( hub,o );

  if( _.arrayHas( o.result, o.filePath ) )
  if( self.throwing )
  throw _.err( 'Cycle in links' );
  else
  return o.result;

  o.result.push( o.filePath );

  // if( o.resolvingHardLink )
  {
    var filePath = self.pathResolveHardLink( o.filePath );
    if( filePath !== o.filePath )
    {
      // debugger;
      o.filePath = _.uri.normalize( _.uri.join( o.filePath, filePath ) );
      return self.resolveLinkChain.body.call( self,o );
    }
  }

  if( o.resolvingSoftLink )
  {
    var filePath = self.pathResolveSoftLink( o.filePath );
    if( filePath !== o.filePath )
    {
      // debugger;
      o.filePath = _.uri.normalize( _.uri.join( o.filePath, filePath ) );
      return self.resolveLinkChain.body.call( self,o );
    }
  }

  if( o.resolvingTextLink )
  {
    var filePath = self.resolveTextLink( o.filePath );
    if( filePath !== o.filePath )
    {
      // debugger;
      o.filePath = _.uri.normalize( _.uri.join( o.filePath, filePath ) );
      return self.resolveLinkChain.body.call( self,o );
    }
  }

  return o.result;
}

_pathResolveLinkChain_body.defaults =
{
  hub : null,
  filePath : null,
  // resolvingHardLink : null,
  resolvingSoftLink : null,
  resolvingTextLink : null,
  result : [],
}

var paths = _pathResolveLinkChain_body.paths = Object.create( null );

paths.filePath = null;

var having = _pathResolveLinkChain_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

//

// function resolveLinkChain( o )
// {
//   var self = this;
//   var o = self.resolveLinkChain.pre.call( self,self.resolveLinkChain,arguments );
//   var result = self.resolveLinkChain.body.call( self,o );
//   return result;
// }
//
// resolveLinkChain.pre = _preSinglePath;
// resolveLinkChain.body = _pathResolveLinkChain_body;
//
// var defaults = resolveLinkChain.defaults = Object.create( _pathResolveLinkChain_body.defaults );
// var paths = resolveLinkChain.paths = Object.create( _pathResolveLinkChain_body.paths );
// var having = resolveLinkChain.having = Object.create( _pathResolveLinkChain_body.having );
//
// having.aspect = 'entry';

var resolveLinkChain = _.routineForPreAndBody( _preSinglePath, _pathResolveLinkChain_body );

resolveLinkChain.having.aspect = 'entry';

//

function _pathResolveLink_body( o )
{
  var self = this;

  _.assert( _.routineIs( self.resolveLinkChain.body ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  var o2 = _.mapExtend( null,o );
  o2.result = [];
  self.resolveLinkChain.body.call( self,o2 );

  return o2.result[ o2.result.length-1 ];
}

_pathResolveLink_body.defaults =
{
  hub : null,
  filePath : null,
  // resolvingHardLink : null,
  resolvingSoftLink : null,
  resolvingTextLink : null,
}

var paths = _pathResolveLink_body.paths = Object.create( null );

paths.filePath = null;

var having = _pathResolveLink_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

//

// function pathResolveLink( o )
// {
//   var self = this;
//   var o = self.pathResolveLink.pre.call( self,self.pathResolveLink,arguments );
//   var result = self.pathResolveLink.body.call( self,o );
//   return result;
// }
//
// pathResolveLink.pre = _preSinglePath;
// pathResolveLink.body = _pathResolveLink_body;
//
// var defaults = pathResolveLink.defaults = Object.create( _pathResolveLink_body.defaults );
// var paths = pathResolveLink.paths = Object.create( _pathResolveLink_body.paths );
// var having = pathResolveLink.having = Object.create( _pathResolveLink_body.having );
//
// having.aspect = 'entry';

var pathResolveLink = _.routineForPreAndBody( _preSinglePath, _pathResolveLink_body );

pathResolveLink.having.aspect = 'entry';

//

// var linkSoftReadAct = Object.create( null );

// var defaults = linkSoftReadAct.defaults = Object.create( null );

// defaults.filePath = null;
// defaults.relativeToDir = 0;

// var paths = linkSoftReadAct.paths = Object.create( null );

// paths.filePath = null;

// var having = linkSoftReadAct.having = Object.create( null );

// having.writing = 0;
// having.reading = 1;
// having.driving = 1;

//

// function _linkSoftRead_body( o )
// {
//   var self = this;

//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( !!o.filePath );

//   if( !_.routineIs( self.linkSoftReadAct ) )
//   return o.filePath;

//   if( !self.fileIsSoftLink( o.filePath ) )
//   return o.filePath;

//   var result = self.linkSoftReadAct( o );

//   return self.path.normalize( result );
// }

// _.routineExtend( _linkSoftRead_body, linkSoftReadAct );

// var having = _linkSoftRead_body.having;

// having.driving = 0;
// having.aspect = 'body';

//

// function linkSoftRead( path )
// {
//   var self = this;
//   var o = self.linkSoftRead.pre.call( self,self.linkSoftRead,arguments );
//   var result = self.linkSoftRead.body.call( self,o );
//   return result;
// }

// linkSoftRead.pre = _preSinglePath;
// linkSoftRead.body = _linkSoftRead_body;

// _.routineExtend( linkSoftRead, _linkSoftRead_body );

// var having = linkSoftRead.having;

// having.aspect = 'entry';

// --
// record
// --

function _fileRecordContextForm( recordContext )
{
  var self = this;
  _.assert( recordContext instanceof _.FileRecordContext );
  _.assert( arguments.length === 1, 'expects single argument' );
  return recordContext;
}

//

function _fileRecordFormBegin( record )
{
  var self = this;
  return record;
}

//

function _fileRecordPathForm( record )
{
  var self = this;
  return record;
}

//

function _fileRecordFormEnd( record )
{
  var self = this;
  return record;
}

//

function fileRecord( filePath,c )
{
  var self = this;

  if( filePath instanceof _.FileRecord )
  {
    if( arguments[ 1 ] === undefined || _.mapContain( filePath.context,c ) )
    {
      return filePath;
    }
    else
    {
      c = filePath.context.cloneOverriding( c );
      return self.fileRecord( filePath.absolute,c );
    }
  }

  _.assert( _.strIs( filePath ),'expects string {-filePath-}, but got',_.strTypeOf( filePath ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( c === undefined )
  c = Object.create( null );

  if( !c.basePath && !c.dirPath && !c.branchPath )
  {
    c.basePath = self.path.dir( filePath );
    c.branchPath = c.basePath;
  }

  if( !( c instanceof _.FileRecordContext ) )
  {
    // if( !c.filter )
    // c.filter = _.FileRecordFilter({ fileProvider : self }).form();
    if( !c.fileProvider )
    c.fileProvider = self;
    c = _.FileRecordContext( c );
    c.form();
  }

  _.assert( c.fileProvider === self || c.fileProviderEffective === self );

  return _.FileRecord( filePath, c );
}

var having = fileRecord.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.kind = 'record';

//

function fileRecords( filePaths,fileRecordOptions )
{
  var self = this;

  if( _.strIs( filePaths ) || filePaths instanceof _.FileRecord )
  filePaths = [ filePaths ];

  _.assert( _.arrayIs( filePaths ),'expects array {-filePaths-}, but got',_.strTypeOf( filePaths ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var result = [];

  for( var r = 0 ; r < filePaths.length ; r++ )
  result[ r ] = self.fileRecord( filePaths[ r ],fileRecordOptions );

  return result;
}

var having = fileRecords.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.kind = 'record';

//

function fileRecordsFiltered( filePaths,fileContext )
{
  var self = this;
  var result = self.fileRecords( filePaths,fileContext );

  for( var r = result.length-1 ; r >= 0 ; r-- )
  if( !result[ r ].isActual )
  result.splice( r,1 );

  return result;
}

var having = fileRecordsFiltered.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.kind = 'record';

//

// function _fileRecordsSort( o )
// {
//   var self = this;

//   if( arguments.length === 1 )
//   if( _.longIs( o ) )
//   {
//     o = { src : o }
//   }

//   if( arguments.length === 2 )
//   {
//     o =
//     {
//       src : arguments[ 0 ],
//       sorter : arguments[ 1 ]
//     }
//   }

//   if( _.strIs( o.sorter ) )
//   {
//     var parseOptions =
//     {
//       src : o.sorter,
//       fields : { hardlinks : 1, modified : 1 }
//     }
//     o.sorter = _.strSorterParse( parseOptions );
//   }

//   _.routineOptions( _fileRecordsSort, o );

//   _.assert( _.longIs( o.src ) );
//   _.assert( _.longIs( o.sorter ) );

//   for( var i = 0; i < o.src.length; i++ )
//   {
//     if( !( o.src[ i ] instanceof _.FileRecord ) )
//     throw _.err( '_fileRecordsSort : expects FileRecord instances in src, got:', _.strTypeOf( o.src[ i ] ) );
//   }

//   var result = o.src.slice();
//   var sorted = false;

//   for( var i = 0; i < o.sorter.length; i++ )
//   {
//     var sortMethod =  o.sorter[ i ][ 0 ];
//     var sortMethodEnabled =  o.sorter[ i ][ 1 ];

//     if( !sortMethodEnabled )
//     continue;

//     if( result.length === 1 )
//     break;

//     if( sortMethod === 'hardlinks' )
//     {
//       var mostLinkedRecord = _.entityMax( result,( record ) => record.stat ? record.stat.nlink : 0 ).element;
//       var mostLinks = mostLinkedRecord.stat.nlink;
//       result = _.entityFilter( result, ( record ) =>
//       {
//         if( record.stat && record.stat.nlink === mostLinks )
//         return record;
//       })
//     }
//     else if( sortMethod === 'modified' )
//     {
//       result = _.entityMax( result,( record ) => record.stat ? record.stat.mtime.getTime() : 0 ).element;
//     }
//     else
//     {
//       throw _.err( '_fileRecordsSort : unknown sort method: ', sortMethod );
//     }

//     sorted = true;

//     result = _.arrayAs( result );
//   }

//   _.assert( sorted, '_fileRecordsSort : files were not sorted, propably all sort methods are disabled, sorter: \n', o.sorter );
//   _.assert( result.length === 1 );

//   return result[ 0 ];
// }

// _fileRecordsSort.defaults =
// {
//   src : null,
//   sorter : null
// }

//

function _fileRecordsSort( o )
{
  var self = this;

  if( arguments.length === 1 )
  if( _.longIs( o ) )
  {
    o = { src : o }
  }

  if( arguments.length === 2 )
  {
    o =
    {
      src : arguments[ 0 ],
      sorter : arguments[ 1 ]
    }
  }

  if( _.strIs( o.sorter ) )
  {
    var parseOptions =
    {
      src : o.sorter,
      fields : { hardlinks : 1, modified : 1 }
    }
    o.sorter = _.strSorterParse( parseOptions );
  }

  _.routineOptions( _fileRecordsSort, o );

  _.assert( _.longIs( o.src ) );
  _.assert( _.longIs( o.sorter ) );

  for( var i = 0; i < o.src.length; i++ )
  {
    if( !( o.src[ i ] instanceof _.FileRecord ) )
    throw _.err( '_fileRecordsSort : expects FileRecord instances in src, got:', _.strTypeOf( o.src[ i ] ) );
  }

  var result = o.src.slice();

  var knownSortMethods = [ 'modified', 'hardlinks' ];

  for( var i = 0; i < o.sorter.length; i++ )
  {
    var sortMethod =  o.sorter[ i ][ 0 ];
    var sortByMax = o.sorter[ i ][ 1 ];

    _.assert( knownSortMethods.indexOf( sortMethod ) !== -1, '_fileRecordsSort : unknown sort method: ', sortMethod );

    var routine = sortByMax ? _.entityMax : _.entityMin;

    if( sortMethod === 'hardlinks' )
    {
      var selectedRecord = routine( result,( record ) => record.stat ? record.stat.nlink : 0 ).element;
      result = [ selectedRecord ];
    }

    if( sortMethod === 'modified' )
    {
      var selectedRecord = routine( result,( record ) => record.stat ? record.stat.mtime.getTime() : 0 ).element;
      result = _.entityFilter( result, ( record ) =>
      {
        if( record.stat && record.stat.mtime.getTime() === selectedRecord.stat.mtime.getTime() )
        return record;
      });
    }
  }

  _.assert( result.length === 1 );

  return result[ 0 ];
}

_fileRecordsSort.defaults =
{
  src : null,
  sorter : null
}

//

function fileRecordContext( context )
{
  var self = this;

  context = context || Object.create( null );

  if( context instanceof _.FileRecordContext )
  return context

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !context.fileProvider )
  context.fileProvider = self;

  _.assert( context.fileProvider === self );

  return _.FileRecordContext( context );
}

var having = fileRecordContext.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'record';

//

function fileRecordFilter( filter )
{
  var self = this;

  filter = filter || Object.create( null );

  if( filter && filter instanceof _.FileRecordFilter )
  return filter

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !filter.fileProvider )
  filter.fileProvider = self;

  // _.assert( filter.fileProvider === self );

  return _.FileRecordFilter( filter );
}

var having = fileRecordFilter.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'record';

// --
// read act
// --

var fileReadAct = Object.create( null );

var defaults = fileReadAct.defaults = Object.create( null );

defaults.sync = null;
defaults.filePath = null;
defaults.encoding = null;
defaults.advanced = null;
defaults.resolvingSoftLink = null;

var paths = fileReadAct.paths = Object.create( null );

paths.filePath = null;

var having = fileReadAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

var fileReadStreamAct = Object.create( null );

var defaults = fileReadStreamAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.encoding = null;

var paths = fileReadStreamAct.paths = Object.create( null );

paths.filePath = null;

var having = fileReadStreamAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

var fileStatAct = Object.create( null );

var defaults = fileStatAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.throwing = 0;
defaults.resolvingSoftLink = null;

var paths = fileStatAct.paths = Object.create( null );

paths.filePath = null;

var having = fileStatAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

var _fileExistsAct = Object.create( null );

var defaults = _fileExistsAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

var paths = _fileExistsAct.paths = Object.create( null );

paths.filePath = null;

var having = _fileExistsAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

function fileExistsAct( o )
{
  let self = this;
  let o2 = _.mapExtend( null, o );
  o2.throwing = 0;
  _.mapSupplement( o2, self.fileStatAct.defaults );
  let result = self.fileStatAct( o2 );
  _.assert( result === null || _.objectIs( result ) );
  _.assert( arguments.length === 1 );
  return !!result;
}

_.routineExtend( fileExistsAct, _fileExistsAct );

//

var fileHashAct = Object.create( null );

var defaults = fileHashAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.throwing = null;

var paths = fileHashAct.paths = Object.create( null );

paths.filePath = null;

var having = fileHashAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

var directoryReadAct = Object.create( null );

var defaults = directoryReadAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.throwing = null;

var paths = directoryReadAct.paths = Object.create( null );

paths.filePath = null;

var having = directoryReadAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

var fileIsTerminalAct = Object.create( null );

var defaults = fileIsTerminalAct.defaults = Object.create( null );

defaults.filePath = null;

var paths = fileIsTerminalAct.paths = Object.create( null );

paths.filePath = null;

var having = fileIsTerminalAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

// --
// read content
// --

function _fileReadStream_body( o )
{
  var self = this;
  var result;
  var optionsRead = _.mapExtend( null, o );
  delete optionsRead.throwing;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( !o.throwing )
  {
    try
    {
      result = self.fileReadStreamAct( optionsRead );
    }
    catch( err )
    {
      return null;
    }
  }
  else
  {
    result = self.fileReadStreamAct( optionsRead );
  }

  return result;
}

var defaults = _fileReadStream_body.defaults = Object.create( fileReadStreamAct.defaults );

defaults.throwing = null;

var paths = _fileReadStream_body.paths = Object.create( fileReadStreamAct.paths );
var having = _fileReadStream_body.having = Object.create( fileReadStreamAct.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function fileReadStream( o )
// {
//   var self = this;
//   var o = self.fileReadStream.pre.call( self, self.fileReadStream, arguments );
//   var result = self.fileReadStream.body.call( self, o );
//   return result;
// }
//
// fileReadStream.pre = _preSinglePath;
// fileReadStream.body = _fileReadStream_body;
//
// var defaults = fileReadStream.defaults = Object.create( _fileReadStream_body.defaults );
// var paths = fileReadStream.paths = Object.create( _fileReadStream_body.paths );
// var having = fileReadStream.having = Object.create( _fileReadStream_body.having );
//
// having.aspect = 'entry';

var fileReadStream = _.routineForPreAndBody( _preSinglePath, _fileReadStream_body );

fileReadStream.having.aspect = 'entry';

//

function _fileRead_body( o )
{
  var self = this;
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.encoding ) );

  var encoder = fileRead.encoders[ o.encoding ];

  if( o.resolvingTextLink )
  o.filePath = self.resolveTextLink( o.filePath );

  /* exec */

  handleBegin();

  var optionsRead = _.mapOnly( o, self.fileReadAct.defaults );

  try
  {
    result = self.fileReadAct( optionsRead );
  }
  catch( err )
  {
    if( o.sync )
    result = err;
    else
    result = new _.Consequence().error( err );
  }

  /* throwing */

  if( o.sync )
  {
    if( _.errIs( result ) )
    return handleError( result );
    return handleEnd( result );
  }
  else
  {

    result
    .ifNoErrorThen( handleEnd )
    .ifErrorThen( handleError )
    ;

    return result;
  }

  /* return */

  return handleEnd( result );

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    _.sure( encoder.onBegin.call( self,{ operation : o, encoder : encoder }) === undefined );

    if( !o.onBegin )
    return;

    var r = o

    debugger;
    _.Consequence.give( o.onBegin,r );
  }

  /* end */

  function handleEnd( data )
  {

    try
    {
      let context = { data : data, operation : o, encoder : encoder, provider : self };
      if( encoder && encoder.onEnd )
      _.sure( encoder.onEnd.call( self, context ) === undefined );
      data = context.data;
    }
    catch( err )
    {
      debugger;
      handleError( err );
      return null;
    }

    if( self.verbosity >= 5 )
    self.logger.log( ' . read :', o.filePath );

    o.result = data;

    var r;
    if( o.returningRead )
    r = data;
    else
    r = o;

    if( o.onEnd )
    debugger;
    if( o.onEnd )
    _.Consequence.give( o.onEnd,o );

    return r;
  }

  /* error */

  function handleError( err )
  {

    if( encoder && encoder.onError )
    try
    {
      err = _._err
      ({
        args : [ stack,'\nfileRead( ',o.filePath,' )\n',err ],
        usingSourceCode : 0,
        level : 0,
      });
      err = encoder.onError.call( self,{ error : err, operation : o, encoder : encoder })
    }
    catch( err2 )
    {
      /* there the simplest output is reqired to avoid recursion */
      console.error( err2 );
      console.error( err.toString() + '\n' + err.stack );
    }

    if( o.onError )
    wConsequence.error( o.onError,err );

    if( o.throwing )
    throw _.err( err );

    return null;
  }

}

var defaults = _fileRead_body.defaults = Object.create( fileReadAct.defaults );

defaults.returningRead = 1;
defaults.throwing = null;
defaults.name = null;
defaults.onBegin = null;
defaults.onEnd = null;
defaults.onError = null;
defaults.resolvingTextLink = null;

var paths = _fileRead_body.paths = Object.create( fileReadAct.paths );
var having = _fileRead_body.having = Object.create( fileReadAct.having );

having.driving = 0;
having.aspect = 'body';

_fileRead_body.encoders = Object.create( null );

//

/**
 * Reads the entire content of a file.
 * Accepts single paramenter - path to a file ( o.filePath ) or options map( o ).
 * Returns wConsequence instance. If `o` sync parameter is set to true (by default) and returnRead is set to true,
    method returns encoded content of a file.
 * There are several way to get read content : as argument for function passed to wConsequence.got(), as second argument
    for `o.onEnd` callback, and as direct method returns, if `o.returnRead` is set to true.
 *
 * @example
 * // content of tmp/json1.json : {"a" :1,"b" :"s","c" : [ 1,3,4 ] }
   var fileReadOptions =
   {
     sync : 0,
     filePath : 'tmp/json1.json',
     encoding : 'json',

     onEnd : function( err, result )
     {
       console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
     }
   };

   var con = wTools.fileProvider.fileRead( fileReadOptions );

   // or
   fileReadOptions.onEnd = null;
   var con2 = wTools.fileProvider.fileRead( fileReadOptions );

   con2.got(function( err, result )
   {
     console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
   });

 * @example
   fileRead({ filePath : file.absolute, encoding : 'buffer.node' })

 * @param {Object} o Read options
 * @param {String} [o.filePath=null] Path to read file
 * @param {Boolean} [o.sync=true] Determines in which way will be read file. If this set to false, file will be read
    asynchronously, else synchronously
 * Note : if even o.sync sets to true, but o.returnRead if false, method will path resolve read content through wConsequence
    anyway.
 * @param {Boolean} [o.returningRead=true] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
    into object with key 'options' and options as value.
 * @param {Boolean} [o.throwing=false] Controls error throwing. Returns null if error occurred and ( throwing ) is disabled.
 * @param {String} [o.name=null]
 * @param {String} [o.encoding='utf8'] Determines encoding processor. The possible values are :
 *    'utf8' : default value, file content will be read as string.
 *    'json' : file content will be parsed as JSON.
 *    'arrayBuffer' : the file content will be return as raw ArrayBuffer.
 * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
 * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
 * @param {Function} [o.onError=null] @see [@link fileRead~onError]
 * @param {*} [o.advanced=null]
 * @returns {wConsequence|ArrayBuffer|string|Array|Object}
 * @throws {Error} If missed arguments.
 * @throws {Error} If ( o ) has extra parameters.
 * @method fileRead
 * @memberof FileProvider.Partial
 */

/**
 * This callback is run before fileRead starts read the file. Accepts error as first parameter.
 * If in fileRead passed 'o.returningRead' that is set to true, callback accepts as second parameter object with key 'options'
    and value that is reference to options object passed into fileRead method, and user has ability to configure that
    before start reading file.
 * @callback fileRead~onBegin
 * @param {Error} err
 * @param {Object|*} options options argument passed into fileRead.
 */

/**
 * This callback invoked after file has been read, and accepts encoded file content data (by depend from
    options.encoding value), string by default ('utf8' encoding).
 * @callback fileRead~onEnd
 * @param {Error} err Error occurred during file read. If read success it's sets to null.
 * @param {ArrayBuffer|Object|Array|String} result Encoded content of read file.
 */

/**
 * Callback invoke if error occurred during file read.
 * @callback fileRead~onError
 * @param {Error} error
 */

// function fileRead( o )
// {
//   var self = this;
//   var o = self.fileRead.pre.call( self, self.fileRead, arguments );
//   var result = self.fileRead.body.call( self, o );
//   return result;
// }
//
// fileRead.pre = _preSinglePath;
// fileRead.body = _fileRead_body;
//
// var defaults = fileRead.defaults = Object.create( _fileRead_body.defaults );
// var paths = fileRead.paths = Object.create( _fileRead_body.paths );
// var having = fileRead.having = Object.create( _fileRead_body.having );
//
// having.aspect = 'entry';
// having.hubResolving = 1;
//
//

var fileRead = _.routineForPreAndBody( _preSinglePath, _fileRead_body );

fileRead.having.aspect = 'entry';
fileRead.having.hubResolving = 1;

//

/**
 * Reads the entire content of a file synchronously.
 * Method returns encoded content of a file.
 * Can accepts `filePath` as first parameters and options as second
 *
 * @example
 * // content of tmp/json1.json : { "a" : 1, "b" : "s", "c" : [ 1,3,4 ]}
 var fileReadOptions =
 {
   filePath : 'tmp/json1.json',
   encoding : 'json',

   onEnd : function( err, result )
   {
     console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
   }
 };

 var res = wTools.fileReadSync( fileReadOptions );
 // { a : 1, b : 's', c : [ 1, 3, 4 ] }

 * @param {Object} o read options
 * @param {string} o.filePath path to read file
 * @param {boolean} [o.returningRead=true] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
 into object with key 'options' and options as value.
 * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
 pass into o.onEnd as first parameter. Note : if sync is set to false, error will caught anyway.
 * @param {string} [o.name=null]
 * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are :
 *    'utf8' : default value, file content will be read as string.
 *    'json' : file content will be parsed as JSON.
 *    'arrayBuffer' : the file content will be return as raw ArrayBuffer.
 * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
 * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
 * @param {Function} [o.onError=null] @see [@link fileRead~onError]
 * @param {*} [o.advanced=null]
 * @returns {wConsequence|ArrayBuffer|string|Array|Object}
 * @throws {Error} if missed arguments
 * @throws {Error} if `o` has extra parameters
 * @method fileReadSync
 * @memberof wFileProviderPartial
 */

// function fileReadSync( o )
// {
//   var self = this;
//   var o = self.fileReadSync.pre.call( self, self.fileReadSync, arguments );
//   var result = self.fileReadSync.body.call( self, o );
//   return result;
// }
//
// fileReadSync.pre = fileRead.pre;
// fileReadSync.body = fileRead.body;
//
// var defaults = fileReadSync.defaults = Object.create( fileRead.defaults );
//
// defaults.sync = 1;
//
// var paths = fileReadSync.paths = Object.create( fileRead.paths );
// var having = fileReadSync.having = Object.create( fileRead.having );
//
//

var fileReadSync = _.routineForPreAndBody( fileRead.pre, fileRead.body );

fileReadSync.defaults.sync = 1;
fileReadSync.having.aspect = 'entry';

//

function _fileReadJson_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  return self.fileRead( o );
}

var defaults = _fileReadJson_body.defaults = Object.create( fileRead.defaults );

defaults.sync = 1;
defaults.encoding = 'json';

var paths = _fileReadJson_body.paths = Object.create( fileRead.paths );
var having = _fileReadJson_body.having = Object.create( fileRead.having );

having.driving = 0;
having.aspect = 'body';

//

/**
 * Reads a JSON file and then parses it into an object.
 *
 * @example
 * // content of tmp/json1.json : {"a" :1,"b" :"s","c" :[1,3,4]}
 *
 * var res = wTools.fileReadJson( 'tmp/json1.json' );
 * // { a : 1, b : 's', c : [ 1, 3, 4 ] }
 * @param {string} filePath file path
 * @returns {*}
 * @throws {Error} If missed arguments, or passed more then one argument.
 * @method fileReadJson
 * @memberof wFileProviderPartial
 */

//
//
// function fileReadJson( o )
// {
//   var self = this;
//   var o = self.fileReadJson.pre.call( self, self.fileReadJson, arguments );
//   var result = self.fileReadJson.body.call( self, o );
//   return result;
// }
//
// fileReadJson.pre = _preSinglePath;
// fileReadJson.body = _fileReadJson_body;
//
// var defaults = fileReadJson.defaults = Object.create( _fileReadJson_body.defaults );
// var paths = fileReadJson.paths = Object.create( _fileReadJson_body.paths );
// var having = fileReadJson.having = Object.create( _fileReadJson_body.having );
//
// having.aspect = 'entry';
//
//

var fileReadJson = _.routineForPreAndBody( fileRead.pre, _fileReadJson_body );

fileReadJson.having.aspect = 'entry';

//

function _fileReadJs_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  return self.fileRead( o );
}

var defaults = _fileReadJs_body.defaults = Object.create( fileRead.defaults );

defaults.sync = 1;
defaults.encoding = 'structure.js';

var paths = _fileReadJs_body.paths = Object.create( fileRead.paths );
var having = _fileReadJs_body.having = Object.create( fileRead.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function fileReadJs( o )
// {
//   var self = this;
//   var o = self.fileReadJs.pre.call( self, self.fileReadJs, arguments );
//   var result = self.fileReadJs.body.call( self, o );
//   return result;
// }
//
// fileReadJs.pre = _preSinglePath;
// fileReadJs.body = _fileReadJs_body;
//
// var defaults = fileReadJs.defaults = Object.create( _fileReadJs_body.defaults );
// var paths = fileReadJs.paths = Object.create( _fileReadJs_body.paths );
// var having = fileReadJs.having = Object.create( _fileReadJs_body.having );
//
// having.aspect = 'entry';
//
//

var fileReadJs = _.routineForPreAndBody( fileRead.pre, _fileReadJs_body );

fileReadJs.having.aspect = 'entry';

//

function _fileInterpret_pre( routine,args )
{
  var self = this;

  _.assert( args.length === 1 );

  var o = args[ 0 ];

  if( self.path.like( o ) )
  o = { filePath : self.path.from( o ) };

  _.routineOptions( routine, o );
  var encoding = o.encoding;
  self._providerOptions( o );
  o.encoding = encoding;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.strIs( o.filePath ) );

  o.filePath = self.path.normalize( o.filePath );

  return o;
}

//

function _fileInterpret_body( o )
{
  var self = this;
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( !o.encoding )
  {
    var ext = self.path.ext( o.filePath );
    for( var e in fileInterpret.encoders )
    {
      var encoder = fileInterpret.encoders[ e ];
      if( !encoder.exts )
      continue;
      if( encoder.forInterpreter !== undefined && !encoder.forInterpreter )
      continue;
      if( _.arrayHas( encoder.exts,ext ) )
      {
        o.encoding = e;
        break;
      }
    }
  }

  if( !o.encoding )
  o.encoding = fileRead.defaults.encoding;

  return self.fileRead( o );
}

_.routineExtend( _fileInterpret_body, fileRead );

_fileInterpret_body.defaults.encoding = null;

// var defaults = _fileInterpret_body.defaults = Object.create( fileRead.defaults );
//
// defaults.encoding = null;
//
// var paths = _fileInterpret_body.paths = Object.create( fileRead.paths );
// var having = _fileInterpret_body.having = Object.create( fileRead.having );
//
// having.driving = 0;
// having.aspect = 'body';

//
//
// function fileInterpret( o )
// {
//   var self = this;
//   var o = self.fileInterpret.pre.call( self, self.fileInterpret, arguments );
//   var result = self.fileInterpret.body.call( self, o );
//   return result;
// }
//
// fileInterpret.pre = _fileInterpret_pre;
// fileInterpret.body = _fileInterpret_body;
//
// var defaults = fileInterpret.defaults = Object.create( _fileInterpret_body.defaults );
// var paths = fileInterpret.paths = Object.create( _fileInterpret_body.paths );
// var having = fileInterpret.having = Object.create( _fileInterpret_body.having );
//
// having.aspect = 'entry';
//
//

var fileInterpret = _.routineForPreAndBody( _fileInterpret_pre, _fileInterpret_body );

fileInterpret.having.aspect = 'entry';

//

var _fileHash_body = ( function()
{
  var crypto;

  return function fileHash( o )
  {
    var self = this;

    _.assert( arguments.length === 1, 'expects single argument' );

    if( o.verbosity >= 3 )
    self.logger.log( ' . fileHash :',o.filePath );

    if( crypto === undefined )
    crypto = require( 'crypto' );
    var md5sum = crypto.createHash( 'md5' );

    /* */

    if( o.sync && _.boolLike( o.sync ) )
    {
      var result;
      try
      {
        var stat = self.fileStat({ filePath : o.filePath, sync : 1, throwing : 0 });
        _.sure( !!stat, 'Cant get stats of file ' + _.strQuote( o.filePath ) );
        _.sure( stat.size <= self.hashFileSizeLimit, 'File is too big ' + _.strQuote( o.filePath ) + ' ' + stat.size + ' > ' + self.hashFileSizeLimit );
        var read = self.fileReadSync( o.filePath );
        md5sum.update( read );
        result = md5sum.digest( 'hex' );
      }
      catch( err )
      {
        if( o.throwing )
        throw err;
        result = NaN;
      }

      return result;

    }
    else if( o.sync === 'worker' )
    {

      debugger; throw _.err( 'not implemented' );

    }
    else
    {
      var con = new _.Consequence();
      var stream = self.fileReadStream( o.filePath );

      stream.on( 'data', function( d )
      {
        md5sum.update( d );
      });

      stream.on( 'end', function()
      {
        var hash = md5sum.digest( 'hex' );
        con.give( hash );
      });

      stream.on( 'error', function( err )
      {
        if( o.throwing )
        con.error( _.err( err ) );
        else
        con.give( NaN );
      });

      return con;
    }
  }

})();

var defaults = _fileHash_body.defaults = Object.create( fileHashAct.defaults );

defaults.throwing = null;
defaults.verbosity = null;

var paths = _fileHash_body.paths = Object.create( fileHashAct.paths );
var having = _fileHash_body.having = Object.create( fileHashAct.having );

having.driving = 0;
having.aspect = 'body';

//

/**
 * Returns md5 hash string based on the content of the terminal file.
 * @param {String|Object} o Path to a file or object with options.
 * @param {String|FileRecord} [ o.filePath=null ] - Path to a file or instance of FileRecord @see{@link wFileRecord}
 * @param {Boolean} [ o.sync=true ] - Determines in which way file will be read : true - synchronously, otherwise - asynchronously.
 * In asynchronous mode returns wConsequence.
 * @param {Boolean} [ o.throwing=false ] - Controls error throwing. Returns NaN if error occurred and ( throwing ) is disabled.
 * @param {Boolean} [ o.verbosity=0 ] - Sets the level of console output.
 * @returns {Object|wConsequence|NaN}
 * If ( o.filePath ) path exists - returns hash as String, otherwise returns null.
 * If ( o.sync ) mode is disabled - returns Consequence instance @see{@link wConsequence }.
 * @example
 * wTools.fileProvider.fileHash( './existingDir/test.txt' );
 * // returns 'fd8b30903ac80418777799a8200c4ff5'
 *
 * @example
 * wTools.fileProvider.fileHash( './notExistingFile.txt' );
 * // returns NaN
 *
 * @example
 * var consequence = wTools.fileProvider.fileHash
 * ({
 *  filePath : './existingDir/test.txt',
 *  sync : 0
 * });
 * consequence.got( ( err, hash ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( hash );
 * })
 *
 * @method fileHash
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.filePath ) path to a file doesn't exist or file is a directory.
 * @memberof wFileProviderPartial
 */

// function fileHash( o )
// {
//   var self = this;
//   var o = self.fileHash.pre.call( self, self.fileHash, arguments );
//   var result = self.fileHash.body.call( self, o );
//   return result;
// }
//
// fileHash.pre = _preSinglePath;
// fileHash.body = _fileHash_body;
//
// var defaults = fileHash.defaults = Object.create( _fileHash_body.defaults );
// var paths = fileHash.paths = Object.create( _fileHash_body.paths );
// var having = fileHash.having = Object.create( _fileHash_body.having );
//
// having.aspect = 'entry';
//
//

var fileHash = _.routineForPreAndBody( _preSinglePath, _fileHash_body );

fileHash.having.aspect = 'entry';

//

function filesFingerprints( files )
{
  var self = this;

  if( _.strIs( files ) || files instanceof _.FileRecord )
  files = [ files ];

  _.assert( _.arrayIs( files ) || _.mapIs( files ) );

  var result = Object.create( null );

  for( var f = 0 ; f < files.length ; f++ )
  {
    var record = self.fileRecord( files[ f ] );
    var fingerprint = Object.create( null );

    if( !record.isActual )
    continue;

    fingerprint.size = record.stat.size;
    fingerprint.hash = record.hashGet();

    result[ record.relative ] = fingerprint;
  }

  return result;
}

var having = filesFingerprints.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function _directoryRead_pre( routine,args )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( args.length === 0 || args.length === 1 );

  var o = args[ 0 ] || Object.create( null );

  if( self.path.like( o ) )
  o = { filePath : self.path.from( o ) };

  /* not safe */
  // if( o.filePath === null || o.filePath === undefined )
  // o.filePath = self.pathCurrent();

  _.routineOptions( routine, o );
  self._providerOptions( o );

  _.assert( self.path.isAbsolute( o.filePath ) );

  return o;
}

//

function _directoryRead_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var o2 = _.mapExtend( null, o );
  delete o2.outputFormat;
  delete o2.basePath;
  o2.filePath = self.path.normalize( o2.filePath );

  var result = self.directoryReadAct( o2 );

  if( o2.sync )
  {
    if( result )
    result = adjust( result );
  }
  else
  {
    result.ifNoErrorThen( function( list )
    {
      if( list )
      return adjust( list );
      return list;
    });
  }

  return result;

  /* - */

  function adjust( result )
  {

    _.assert( _.arrayIs( result ) );

    result.sort( function( a, b )
    {
      a = a.toLowerCase();
      b = b.toLowerCase();
      if( a < b ) return -1;
      if( a > b ) return +1;
      return 0;
    });

    var isDir = self.directoryIs( o.filePath );

    if( o.outputFormat === 'absolute' )
    result = result.map( function( relative )
    {
      if( isDir )
      return self.path.join( o.filePath,relative );
      else
      return o.filePath;
    });
    else if( o.outputFormat === 'record' )
    result = result.map( function( relative )
    {
      return self.fileRecord( relative, { dirPath : o.filePath, basePath : o.basePath } );
    });
    else if( o.basePath )
    result = result.map( function( relative )
    {
      return self.path.relative( o.basePath,self.path.join( o.filePath,relative ) );
    });

    return result;
  }

}

var defaults = _directoryRead_body.defaults = Object.create( directoryReadAct.defaults );

defaults.outputFormat = 'relative';
defaults.basePath = null;
defaults.throwing = 0;

var paths = _directoryRead_body.paths = Object.create( directoryReadAct.paths );
var having = _directoryRead_body.having = Object.create( directoryReadAct.having );

having.driving = 0;
having.aspect = 'body';

//

/**
 * Returns list of files located in a directory. List is represented as array of paths to that files.
 * @param {String|Object} o Path to a directory or object with options.
 * @param {String|FileRecord} [ o.filePath=null ] - Path to a directory or instance of FileRecord @see{@link wFileRecord}
 * @param {Boolean} [ o.sync=true ] - Determines in which way list of files will be read : true - synchronously, otherwise - asynchronously.
 * In asynchronous mode returns wConsequence.
 * @param {Boolean} [ o.throwing=false ] - Controls error throwing. Returns null if error occurred and ( throwing ) is disabled.
 * @param {String} [ o.outputFormat='relative' ] - Sets style of a file path in a result array. Possible values : 'relative', 'absolute', 'record'.
 * @param {String} [ o.basePath=o.filePath ] - Relative path to a files from directory located by path ( o.filePath ). By default is equal to ( o.filePath );
 * @returns {Array|wConsequence|null}
 * If ( o.filePath ) path exists - returns list of files as Array, otherwise returns null.
 * If ( o.sync ) mode is disabled - returns Consequence instance @see{@link wConsequence }.
 *
 * @example
 * wTools.fileProvider.directoryRead( './existingDir' );
 * // returns [ 'a.txt', 'b.js', 'c.md' ]
 *
 * @example
 * wTools.fileProvider.directoryRead( './notExistingDir' );
 * // returns null
 *
 * * @example
 * wTools.fileProvider.directoryRead( './existingEmptyDir' );
 * // returns []
 *
 * @example
 * var consequence = wTools.fileProvider.directoryRead
 * ({
 *  filePath : './existingDir',
 *  sync : 0
 * });
 * consequence.got( ( err, files ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( files );
 * })
 *
 * @method directoryRead
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) path is not a String or instance of FileRecord @see{@link wFileRecord}
 * @throws { Exception } If ( o.filePath ) path doesn't exist.
 * @memberof wFileProviderPartial
 */

// function directoryRead( o )
// {
//   var self = this;
//   var o = self.directoryRead.pre.call( self, self.directoryRead, arguments );
//   var result = self.directoryRead.body.call( self, o );
//   return result;
// }
//
// directoryRead.pre = _directoryRead_pre;
// directoryRead.body = _directoryRead_body;
//
// var defaults = directoryRead.defaults = Object.create( _directoryRead_body.defaults );
// var paths = directoryRead.paths = Object.create( _directoryRead_body.paths );
// var having = directoryRead.having = Object.create( _directoryRead_body.having );
//
// having.aspect = 'entry';
//
//

var directoryRead = _.routineForPreAndBody( _directoryRead_pre, _directoryRead_body );

directoryRead.having.aspect = 'entry';

//

function _directoryReadDirs_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var result = self.directoryRead( o );

  result = result.filter( function( path )
  {
    var stat = self.fileStat( path );
    if( stat.isDirectory() )
    return true;
  });

  return result;
}

var defaults = _directoryReadDirs_body.defaults = Object.create( directoryRead.defaults );
var paths = _directoryReadDirs_body.paths = Object.create( directoryRead.defaults );
var having = _directoryReadDirs_body.having = Object.create( directoryRead.defaults );

having.driving = 0;
having.aspect = 'body';

//
//
// function directoryReadDirs( o )
// {
//   var self = this;
//   var o = self.directoryReadDirs.pre.call( self, self.directoryReadDirs, arguments );
//   var result = self.directoryReadDirs.body.call( self, o );
//   return result;
// }
//
// directoryReadDirs.pre = directoryRead.pre;
// directoryReadDirs.body = _directoryReadDirs_body;
//
// var defaults = directoryReadDirs.defaults = Object.create( _directoryReadDirs_body.defaults );
// var paths = directoryReadDirs.paths = Object.create( _directoryReadDirs_body.paths );
// var having = directoryReadDirs.having = Object.create( _directoryReadDirs_body.having );
//
// having.aspect = 'entry';
//
//

var directoryReadDirs = _.routineForPreAndBody( directoryRead.pre, _directoryReadDirs_body );

directoryReadDirs.having.aspect = 'entry';

//

function _directoryReadTerminals_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var result = self.directoryRead( o );

  result = result.filter( function( path )
  {
    var stat = self.fileStat( path );
    if( !stat.isDirectory() )
    return true;
  });

  return result;

}

var defaults = _directoryReadTerminals_body.defaults = Object.create( directoryRead.defaults );
var paths = _directoryReadTerminals_body.paths = Object.create( directoryRead.defaults );
var having = _directoryReadTerminals_body.having = Object.create( directoryRead.defaults );

having.driving = 0;
having.aspect = 'body';

//
//
// function directoryReadTerminals( o )
// {
//   var self = this;
//   var o = self.directoryReadTerminals.pre.call( self, self.directoryReadTerminals, arguments );
//   var result = self.directoryReadTerminals.body.call( self, o );
//   return result;
// }
//
// directoryReadTerminals.pre = directoryRead.pre;
// directoryReadTerminals.body = _directoryReadTerminals_body;
//
// var defaults = directoryReadTerminals.defaults = Object.create( _directoryReadTerminals_body.defaults );
// var paths = directoryReadTerminals.paths = Object.create( _directoryReadTerminals_body.paths );
// var having = directoryReadTerminals.having = Object.create( _directoryReadTerminals_body.having );
//
// having.aspect = 'entry';
//
//

var directoryReadTerminals = _.routineForPreAndBody( directoryRead.pre, _directoryReadTerminals_body );

directoryReadTerminals.having.aspect = 'entry';

// --
// read stat
// --

function _fileStat_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.routineIs( self.fileStatAct ) );

  // if( o.resolvingTextLink )
  // o.filePath = self.path.resolveTextLink( o.filePath, true );

  o.filePath = self.pathResolveLink
  ({
    filePath : o.filePath,
    // resolvingSoftLink : o.resolvingSoftLink,
    resolvingSoftLink : 0,
    resolvingTextLink : o.resolvingTextLink,
  });

  var o2 = _.mapOnly( o, self.fileStatAct.defaults );

  return self.fileStatAct( o2 );
}

_.routineExtend( _fileStat_body, fileStatAct );

_fileStat_body.defaults.resolvingTextLink = null;
_fileStat_body.having.driving = 0;
_fileStat_body.having.aspect = 'body';

//

/**
 * Returns object with information about a file.
 * @param {String|Object} o Path to a file or object with options.
 * @param {String|FileRecord} [ o.filePath=null ] - Path to a file or instance of FileRecord @see{@link wFileRecord}
 * @param {Boolean} [ o.sync=true ] - Determines in which way file stats will be readed : true - synchronously, otherwise - asynchronously.
 * In asynchronous mode returns wConsequence.
 * @param {Boolean} [ o.throwing=false ] - Controls error throwing. Returns null if error occurred and ( throwing ) is disabled.
 * @param {Boolean} [ o.resolvingTextLink=false ] - Enables resolving of text links @see{@link wFileProviderPartial~resolvingTextLink}.
 * @param {Boolean} [ o.resolvingSoftLink=true ] - Enables resolving of soft links @see{@link wFileProviderPartial~resolvingSoftLink}.
 * @returns {Object|wConsequence|null}
 * If ( o.filePath ) path exists - returns file stats as Object, otherwise returns null.
 * If ( o.sync ) mode is disabled - returns Consequence instance @see{@link wConsequence }.
 * @example
 * wTools.fileProvider.fileStat( './existingDir/test.txt' );
 * // returns
 * Stats
 * {
    dev : 2523469189,
    mode : 16822,
    nlink : 1,
    uid : 0,
    gid : 0,
    rdev : 0,
    blksize : undefined,
    ino : 13229323905402304,
    size : 0,
    blocks : undefined,
    atimeMs : 1525429693979.7004,
    mtimeMs : 1525429693979.7004,
    ctimeMs : 1525429693979.7004,
    birthtimeMs : 1513244276986.976,
    atime : '2018-05-04T10:28:13.980Z',
    mtime : '2018-05-04T10:28:13.980Z',
    ctime : '2018-05-04T10:28:13.980Z',
    birthtime : '2017-12-14T09:37:56.987Z',
  }
 *
 * @example
 * wTools.fileProvider.fileStat( './notExistingFile.txt' );
 * // returns null
 *
 * @example
 * var consequence = wTools.fileProvider.fileStat
 * ({
 *  filePath : './existingDir/test.txt',
 *  sync : 0
 * });
 * consequence.got( ( err, stats ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( stats );
 * })
 *
 * @method fileStat
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.filePath ) path to a file doesn't exist.
 * @memberof wFileProviderPartial
 */

// function fileStat( o )
// {
//   var self = this;
//   var o = self.fileStat.pre.call( self, self.fileStat, arguments );
//   var result = self.fileStat.body.call( self, o );
//   return result;
// }
//
// fileStat.pre = _preSinglePath;
// fileStat.body = _fileStat_body;
//
// var defaults = fileStat.defaults = Object.create( _fileStat_body.defaults );
// var paths = fileStat.paths = Object.create( _fileStat_body.paths );
// var having = fileStat.having = Object.create( _fileStat_body.having );

var fileStat = _.routineForPreAndBody( _preSinglePath, _fileStat_body );

fileStat.having.aspect = 'entry';
fileStat.having.hubRedirecting = 0;

//

/**
 * Returns object with information about a file.
 * @param {String|Object} o Path to a file or object with options.
 * @param {String|FileRecord} [ o.filePath=null ] - Path to a file or instance of FileRecord @see{@link wFileRecord}
 * @param {Boolean} [ o.sync=true ] - Determines in which way file stats will be readed : true - synchronously, otherwise - asynchronously.
 * In asynchronous mode returns wConsequence.
 * @param {Boolean} [ o.throwing=false ] - Controls error throwing. Returns null if error occurred and ( throwing ) is disabled.
 * @param {Boolean} [ o.resolvingTextLink=false ] - Enables resolving of text links @see{@link wFileProviderPartial~resolvingTextLink}.
 * @param {Boolean} [ o.resolvingSoftLink=true ] - Enables resolving of soft links @see{@link wFileProviderPartial~resolvingSoftLink}.
 * @returns {Object|wConsequence|null}
 * If ( o.filePath ) path exists - returns file stats as Object, otherwise returns null.
 * If ( o.sync ) mode is disabled - returns Consequence instance @see{@link wConsequence }.
 * @example
 * wTools.fileProvider.fileExists( './existingDir/test.txt' );
 * // returns
 * Stats
 * {
    dev : 2523469189,
    mode : 16822,
    nlink : 1,
    uid : 0,
    gid : 0,
    rdev : 0,
    blksize : undefined,
    ino : 13229323905402304,
    size : 0,
    blocks : undefined,
    atimeMs : 1525429693979.7004,
    mtimeMs : 1525429693979.7004,
    ctimeMs : 1525429693979.7004,
    birthtimeMs : 1513244276986.976,
    atime : '2018-05-04T10:28:13.980Z',
    mtime : '2018-05-04T10:28:13.980Z',
    ctime : '2018-05-04T10:28:13.980Z',
    birthtime : '2017-12-14T09:37:56.987Z',
  }
 *
 * @example
 * wTools.fileProvider.fileExists( './notExistingFile.txt' );
 * // returns null
 *
 * @example
 * var consequence = wTools.fileProvider.fileExists
 * ({
 *  filePath : './existingDir/test.txt',
 *  sync : 0
 * });
 * consequence.got( ( err, stats ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( stats );
 * })
 *
 * @method fileExists
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.filePath ) path to a file doesn't exist.
 * @memberof wFileProviderPartial
 */

function _fileExists_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.routineIs( self.fileExistsAct ) );

  // if( o.resolvingTextLink )
  // o.filePath = self.path.resolveTextLink( o.filePath, true );

  var o2 = _.mapOnly( o, self.fileExistsAct.defaults );

  return self.fileExistsAct( o2 );
}

var defaults = _fileExists_body.defaults = Object.create( fileExistsAct.defaults );

// defaults.resolvingTextLink = null;

var paths = _fileExists_body.paths = Object.create( fileExistsAct.paths );
var having = _fileExists_body.having = Object.create( fileExistsAct.having );

having.driving = 0;
having.aspect = 'body';

//

var fileExists = _.routineForPreAndBody( _preSinglePath, _fileExists_body );

fileExists.having.aspect = 'entry';

//

function _fileIsTerminal_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.mapIs( o ) );
  _.assert( _.boolLike( o.resolvingSoftLink ) );

  if( _.routineIs( self.fileIsTerminalAct ) )
  return self.fileIsTerminalAct( o );

  o.filePath = self.pathResolveLink
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  if( self.directoryIs( o.filePath ) )
  return false;

  if( o.resolvingSoftLink )
  if( self.fileIsSoftLink( o.filePath ) )
  return false;

  if( self.usingTextLink && o.resolvingTextLink )
  if( self.fileIsTextLink( o.filePath ) )
  return false;

  var stat = self.fileStat
  ({
    filePath : o.filePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  });

  if( !stat )
  return false;

  return stat.isFile();
}

var defaults = _fileIsTerminal_body.defaults = Object.create( fileIsTerminalAct.defaults );

defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

var paths = _fileIsTerminal_body.paths = Object.create( fileIsTerminalAct.paths );
var having = _fileIsTerminal_body.having = Object.create( fileIsTerminalAct.having );

having.driving = 0;
having.hubResolving = 1;

//

/**
 * Returns true if file at ( filePath ) is an existing regular terminal file.
 * @example
 * wTools.fileIsTerminal( './existingDir/test.txt' ); // true
 * @param {string} filePath Path string
 * @returns {boolean}
 * @method fileIsTerminal
 * @memberof wFileProviderPartial
 */

// function fileIsTerminal( filePath )
// {
//   var self = this;
//   var o = self.fileIsTerminal.pre.call( self, self.fileIsTerminal, arguments );
//   var result = self.fileIsTerminal.body.call( self, o );
//   return result;
// }
//
// fileIsTerminal.pre = _preSinglePath;
// fileIsTerminal.body = _fileIsTerminal_body;
//
// var defaults = fileIsTerminal.defaults = Object.create( _fileIsTerminal_body.defaults );
// var paths = fileIsTerminal.paths = Object.create( _fileIsTerminal_body.paths );
// var having = fileIsTerminal.having = Object.create( _fileIsTerminal_body.having );
//
//

var fileIsTerminal = _.routineForPreAndBody( _preSinglePath, _fileIsTerminal_body );

fileIsTerminal.having.aspect = 'entry';

//

/**
 * Returns true if resolved file at ( filePath ) is an existing regular terminal file.
 * @example
 * wTools.fileIsTerminal( './existingDir/test.txt' ); // true
 * @param {string} filePath Path string
 * @returns {boolean}
 * @method fileResolvedIsTerminal
 * @memberof wFileProviderPartial
 */

// function fileResolvedIsTerminal( filePath )
// {
//   var self = this;
//   var o = self.fileResolvedIsTerminal.pre.call( self, self.fileResolvedIsTerminal, arguments );
//   var result = self.fileResolvedIsTerminal.body.call( self, o );
//   return result;
// }
//
// fileResolvedIsTerminal.pre = _preSinglePath;
// fileResolvedIsTerminal.body = _fileIsTerminal_body;
//
// var defaults = fileResolvedIsTerminal.defaults = Object.create( fileIsTerminal.defaults );
//
// defaults.resolvingSoftLink = null;
// defaults.resolvingTextLink = null;
//
// var paths = fileResolvedIsTerminal.paths = Object.create( fileIsTerminal.paths );
// var having = fileResolvedIsTerminal.having = Object.create( fileIsTerminal.having );
//
//

var fileResolvedIsTerminal = _.routineForPreAndBody( _preSinglePath, _fileIsTerminal_body );

fileResolvedIsTerminal.defaults.resolvingSoftLink = null;
fileResolvedIsTerminal.defaults.resolvingTextLink = null;

fileResolvedIsTerminal.having.aspect = 'entry';

//

/**
 * Return True if `filePath` is a symbolic link.
 * @param filePath
 * @returns {boolean}
 * @method fileIsSoftLink
 * @memberof wFileProviderPartial
 */

function fileIsSoftLink( filePath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var stat = self.fileStat
  ({
    filePath : filePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0
  });

  if( !stat )
  return false;

  return stat.isSymbolicLink();
}

var having = fileIsSoftLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

/**
 * Return True if file at `filePath` is a hard link.
 * @param filePath
 * @returns {boolean}
 * @method fileIsHardLink
 * @memberof wFileProviderPartial
 */

function fileIsHardLink( filePath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var stat = self.fileStat
  ({
    filePath : filePath,
    resolvingSoftLink : 0,
  });

  if( !stat )
  return false;

  return stat.nlink >= 2;
}

var having = fileIsHardLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function fileIsTextLink( filePath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( !self.usingTextLink )
  return false;

  var result = self._pathResolveTextLink( filePath );

  return !!result.resolved;
}

var having = fileIsTextLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function _fileIsLink_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var result = false;

  if( o.resolvingSoftLink && o.resolvingTextLink )
  return result;

  if( !o.resolvingSoftLink  )
  {
    result = self.fileIsSoftLink( o.filePath );
  }

  if( o.usingTextLink && !o.resolvingTextLink )
  {
    if( !result )
    result = self.fileIsTextLink( o.filePath );
  }

  return result;
}

var defaults = _fileIsLink_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;
defaults.usingTextLink = 0;

var paths = _fileIsLink_body.paths = Object.create( null );

paths.filePath = null;

var having = _fileIsLink_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.aspect = 'body';
having.driving = 0;

//
//
// function fileIsLink( o )
// {
//   var self = this;
//   var o = self.fileIsLink.pre.call( self, self.fileIsLink, arguments );
//   var result = self.fileIsLink.body.call( self, o );
//   return result;
// }
//
// fileIsLink.pre = _preSinglePath;
// fileIsLink.body = _fileIsLink_body;
//
// var defaults = fileIsLink.defaults = Object.create( _fileIsLink_body.defaults );
// var paths = fileIsLink.paths = Object.create( _fileIsLink_body.paths );
// var having = fileIsLink.having = Object.create( _fileIsLink_body.having );
//
// having.aspect = 'entry';
//
//

var fileIsLink = _.routineForPreAndBody( _preSinglePath, _fileIsLink_body );

fileIsLink.having.aspect = 'entry';

//
//
// function fileResolvedIsLink( o )
// {
//   var self = this;
//   var o = self.fileResolvedIsLink.pre.call( self, self.fileResolvedIsLink, arguments );
//   var result = self.fileResolvedIsLink.body.call( self, o );
//   return result;
// }
//
// fileResolvedIsLink.pre = _preSinglePath;
// fileResolvedIsLink.body = _fileIsLink_body;
//
// var defaults = fileResolvedIsLink.defaults = Object.create( _fileIsLink_body.defaults );
//
// defaults.resolvingSoftLink = null;
// defaults.resolvingTextLink = null;
//
// var paths = fileResolvedIsLink.paths = Object.create( _fileIsLink_body.paths );
// var having = fileResolvedIsLink.having = Object.create( _fileIsLink_body.having );
//
// having.aspect = 'entry';
//
//

var fileResolvedIsLink = _.routineForPreAndBody( _preSinglePath, _fileIsLink_body );

fileResolvedIsLink.defaults.resolvingSoftLink = null;
fileResolvedIsLink.defaults.resolvingTextLink = null;

fileResolvedIsLink.having.aspect = 'entry';

//

/**
 * Check if two paths, file stats or FileRecords are associated with the same file or files with same content.
 * @example
 * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     usingTime = true,
     buffer = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { filePath : path2, data : buffer } );

     var sameWithoutTime = wTools.filesAreSame( path1, path2 ); // true

     var sameWithTime = wTools.filesAreSame( path1, path2, usingTime ); // false
   }, 100);
 * @param {string|wFileRecord} ins1 first file to compare
 * @param {string|wFileRecord} ins2 second file to compare
 * @param {boolean} usingTime if this argument sets to true method will additionally check modified time of files, and
    if they are different, method returns false.
 * @returns {boolean}
 * @method filesAreSame
 * @memberof wFileProviderPartial
 */

function _filesAreSame_pre( routine,args )
{
  var self = this;
  var o;

  if( args.length === 2 )
  {
    o =
    {
      ins1 : args[ 0 ],
      ins2 : args[ 1 ],
    }
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
  }

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.routineOptions( routine,o );

  return o;
}

//

function _filesAreSame_body( o )
{
  var self = this;

  o.ins1 = self.fileRecord( o.ins1 );
  o.ins2 = self.fileRecord( o.ins2 );

  // o.ins1 = self.fileRecord( o.ins1,{ resolvingSoftLink : o.resolvingSoftLink, resolvingTextLink : o.resolvingTextLink } );
  // o.ins2 = self.fileRecord( o.ins2,{ resolvingSoftLink : o.resolvingSoftLink, resolvingTextLink : o.resolvingTextLink } );

  /* no stat */

  if( !o.ins1.stat )
  return false;
  if( !o.ins2.stat )
  return false;

  /* dir */

  if( o.ins1.stat.isDirectory() )
  {
    if( !o.ins2.stat.isDirectory() )
    return false;
    debugger;
    if( o.ins1.ino > 0 )
    if( o.ins1.ino === o.ins2.ino )
    return true;
    if( o.ins1.size !== o.ins2.size )
    return false;
    return o.ins1.real === o.ins2.real;
  }

  /* soft link */

  if( o.ins1.isSoftLink )
  {
    debugger;
    if( !o.ins2.isSoftLink )
    return false;
    return self.pathResolveSoftLink( o.ins1 ) === self.pathResolveSoftLink( o.ins2 );
  }

  /* text link */

  if( o.ins1.isTextLink )
  {
    debugger;
    if( !o.ins2.isTextLink )
    return false;
    return self.resolveTextLink( o.ins1 ) === self.resolveTextLink( o.ins2 );
  }

  /* hard linked */

  if( _.bigIntIs( o.ins1.stat.ino ) && _.bigIntIs( o.ins2.stat.ino ) )
  if( o.ins1.context.fileProviderEffective === o.ins2.context.fileProviderEffective )
  if( o.ins1.stat.ino > 0 )
  if( o.ins1.stat.ino === o.ins2.stat.ino )
  return true;

  /* false for empty files */

  if( !o.ins1.stat.size || !o.ins2.stat.size )
  return false;

  /* size */

  if( o.ins1.stat.size !== o.ins2.stat.size )
  return false;

  /* hash */

  try
  {
    var h1 = o.ins1.hashGet();
    var h2 = o.ins2.hashGet();

    _.assert( _.strIs( h1 ) && _.strIs( h2 ) );

    return h1 === h2;
  }
  catch( err )
  {
    return NaN;
  }
}

var defaults = _filesAreSame_body.defaults = Object.create( null );

defaults.ins1 = null;
defaults.ins2 = null;

var paths = _filesAreSame_body.paths = Object.create( null );

var having = _filesAreSame_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.aspect = 'body';

var filesAreSame = _.routineForPreAndBody( _filesAreSame_pre, _filesAreSame_body );

filesAreSame.having.aspect = 'entry';

//

var filesAreHardLinkedAct = Object.create( null );
var having = filesAreHardLinkedAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

//

function _filesAreHardLinked_pre( routine,args )
{
  var self = this;
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  if( args.length !== 1 || ( !_.arrayIs( args[ 0 ] ) && !_.argumentsArrayIs( args[ 0 ] ) ) )
  return args;
  else
  {
    _.assert( args.length === 1 );
    return args[ 0 ];
  }
}

//

function _filesAreHardLinked_body( files )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( !files.length )
  return true;

  if( _.routineIs( self.filesAreHardLinkedAct ) )
  {
    for( var i = 1 ; i < files.length ; i++ )
    {
      if( !self.filesAreHardLinkedAct( files[ 0 ],files[ i ] ) )
      return false;
    }
    return true;
  }

  var statFirst = self.fileStat( files[ 0 ] );
  if( !statFirst )
  return false;

  for( var i = 1 ; i < files.length ; i++ )
  {
    var statCurrent = self.fileStat( self.path.from( files[ i ] ) );
    if( !statCurrent || !_.fileStatsCouldBeLinked( statFirst, statCurrent ) )
    return false;
  }

  return true;
}

var having = _filesAreHardLinked_body.having = Object.create( filesAreHardLinkedAct.having );
having.driving = 0;
having.aspect = 'body';

//

/**
 * Check if one of paths is hard link to other.
 * @example
   var fs = require( 'fs' );

   var path1 = '/home/tmp/sample/file1',
   path2 = '/home/tmp/sample/file2',
   buffer = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   fs.symlinkSync( path1, path2 );

   var linked = wTools.filesAreHardLinked( path1, path2 ); // true

 * @param {string|wFileRecord} ins1 path string/file record instance
 * @param {string|wFileRecord} ins2 path string/file record instance

 * @returns {boolean}
 * @throws {Error} if missed one of arguments or pass more then 2 arguments.
 * @method filesAreHardLinked
 * @memberof wFileProviderPartial
 */

function filesAreHardLinked( files )
{
  var self = this;
  var files = self.filesAreHardLinked.pre.call( self, self.filesAreHardLinked, arguments );
  var result = self.filesAreHardLinked.body.call( self, files );
  return result;
}

filesAreHardLinked.pre = _filesAreHardLinked_pre;
filesAreHardLinked.body = _filesAreHardLinked_body;

var having = filesAreHardLinked.having = Object.create( _filesAreHardLinked_body.having );
having.driving = 0;
having.aspect = 'entry';

// var filesAreHardLinked = _.routineForPreAndBody( _filesAreHardLinked_pre, _filesAreHardLinked_body );
//
// filesAreHardLinked.having.aspect = 'entry';

//

/**
 * Returns sum of sizes of files in `paths`.
 * @example
 * var path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   textData2 = 'Aenean non feugiat mauris';

   wTools.fileWrite( { filePath : path1, data : textData1 } );
   wTools.fileWrite( { filePath : path2, data : textData2 } );
   var size = wTools.filesSize( [ path1, path2 ] );
   console.log(size); // 81
 * @param {string|string[]} paths path to file or array of paths
 * @param {Object} [o] additional o
 * @param {Function} [o.onBegin] callback that invokes before calculation size.
 * @param {Function} [o.onEnd] callback.
 * @returns {number} size in bytes
 * @method filesSize
 * @memberof wFileProviderPartial
 */

function filesSize( o )
{
  var self = this;
  var o = o || Object.create( null );

  if( _.strIs( o ) || _.arrayIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1, 'expects single argument' );

  // throw _.err( 'not tested' );

  // var result = self.UsingBigIntForStat ? BigInt( 0 ) : 0 ;
  var o = o || Object.create( null );
  o.filePath = _.arrayAs( o.filePath );

  // if( o.onBegin ) o.onBegin.call( this,null );
  //
  // if( o.onEnd ) throw 'Not implemented';

  var optionsForSize = _.mapExtend( null,o );
  optionsForSize.filePath = o.filePath[ 0 ];

  let result = self.fileSize( optionsForSize );

  for( var p = 1 ; p < o.filePath.length ; p++ )
  {
    // var optionsForSize = _.mapExtend( null,o );
    optionsForSize.filePath = o.filePath[ p ];
    result += self.fileSize( optionsForSize );
  }

  return result;
}

var having = filesSize.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function _fileSize_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( o.filePath === '/out/icons' )
  debugger;

  // if( self.fileIsSoftLink( o.filePath ) )
  // {
  //   throw _.err( 'not tested' );
  //   return false;
  // }

  var stat = self.fileStat( o );

  _.sure( _.objectIs( stat ) );

  return stat.size;
}

var defaults = _fileSize_body.defaults = Object.create( fileStat.defaults );
var paths = _fileSize_body.paths = Object.create( fileStat.paths );
var having = _fileSize_body.having = Object.create( fileStat.having );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

//

/**
 * Return file size in bytes. For symbolic links return false. If onEnd callback is defined, method returns instance
    of wConsequence.
 * @example
 * var path = 'tmp/fileSize/data4',
     bufferData1 = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] ), // size 4
     bufferData2 = Buffer.from( [ 0x07, 0x06, 0x05 ] ); // size 3

   wTools.fileWrite( { filePath : path, data : bufferData1 } );

   var size1 = wTools.fileSize( path );
   console.log(size1); // 4

   var con = wTools.fileSize( {
     filePath : path,
     onEnd : function( size )
     {
       console.log( size ); // 7
     }
   } );

   wTools.fileWrite( { filePath : path, data : bufferData2, append : 1 } );

 * @param {string|Object} o o object or path string
 * @param {string} o.filePath path to file
 * @param {Function} [o.onBegin] callback that invokes before calculation size.
 * @param {Function} o.onEnd this callback invoked in end of pathCurrent js event loop and accepts file size as
    argument.
 * @returns {number|boolean|wConsequence}
 * @throws {Error} If passed less or more than one argument.
 * @throws {Error} If passed unexpected parameter in o.
 * @throws {Error} If filePath is not string.
 * @method fileSize
 * @memberof wFileProviderPartial
 */

var fileSize = _.routineForPreAndBody( _preSinglePath, _fileSize_body );

fileSize.having.aspect = 'entry';

_.assert( fileSize.having.hubRedirecting === 0 );

//

function _directoryIs_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( o.resolvingSoftLink !== null );
  _.assert( o.resolvingTextLink !== null );

  var stat = self.fileStat
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  if( !stat )
  return false;

  if( stat.isSymbolicLink() )
  return false;

  return stat.isDirectory();
}

var defaults = _directoryIs_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = null;
defaults.resolvingTextLink = null;

var paths = _directoryIs_body.paths = Object.create( null );

paths.filePath = null;

var having = _directoryIs_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.aspect = 'body';

//

/**
 * Return True if file at ( filePath ) is an existing directory.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.directoryIs( './existingDir/' ); // true
 * @param {string} filePath Tested path string
 * @returns {boolean}
 * @method directoryIs
 * @memberof wFileProviderPartial
 */

// function directoryIs( filePath )
// {
//   var self = this;
//   var o = self.directoryIs.pre.call( self, self.directoryIs, arguments );
//   var result = self.directoryIs.body.call( self, o );
//   return result;
// }
//
// directoryIs.pre = _preSinglePath;
// directoryIs.body = _directoryIs_body;
//
// var defaults = directoryIs.defaults = Object.create( _directoryIs_body.defaults );
// var paths = directoryIs.paths = Object.create( _directoryIs_body.paths );
// var having = directoryIs.having = Object.create( _directoryIs_body.having );
//
// having.aspect = 'entry';
//
//

var directoryIs = _.routineForPreAndBody( _preSinglePath, _directoryIs_body );

directoryIs.having.aspect = 'entry';

//

/**
 * Return True if file at resolved ( filePath ) is an existing directory.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.directoryIs( './existingDir/' ); // true
 * @param {string} filePath Tested path string
 * @returns {boolean}
 * @method directoryResolvedIs
 * @memberof wFileProviderPartial
 */

// function directoryResolvedIs( filePath )
// {
//   var self = this;
//   var o = self.fileWrite.pre.call( self, self.fileWrite, arguments );
//   var result = self.fileWrite.body.call( self, o );
//   return result;
// }
//
// directoryResolvedIs.pre = _preSinglePath;
// directoryResolvedIs.body = _directoryIs_body;
//
// var defaults = directoryResolvedIs.defaults = Object.create( _directoryIs_body.defaults );
//
// defaults.resolvingSoftLink = 1;
// defaults.resolvingTextLink = 1;
//
// var paths = directoryResolvedIs.paths = Object.create( _directoryIs_body.paths );
// var having = directoryResolvedIs.having = Object.create( _directoryIs_body.having );
//
// having.aspect = 'entry';
//
//

var directoryResolvedIs = _.routineForPreAndBody( _preSinglePath, _directoryIs_body );

directoryResolvedIs.defaults.resolvingSoftLink = 1;
directoryResolvedIs.defaults.resolvingTextLink = 1;

directoryResolvedIs.having.aspect = 'entry';

//

/**
 * Returns True if file at ( filePath ) is an existing empty directory, otherwise returns false.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.fileProvider.directoryIsEmpty( './existingEmptyDir/' ); // true
 * @param {string} filePath - Path to the directory.
 * @returns {boolean}
 * @method directoryIsEmpty
 * @memberof wFileProviderPartial
 */

function directoryIsEmpty( filePath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( self.directoryIs( filePath ) )
  return !self.directoryRead( filePath ).length;

  return false;
}

var having = directoryIsEmpty.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

// --
// write act
// --

var fileWriteAct = Object.create( null );

var defaults = fileWriteAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.data = '';
defaults.encoding = 'original.type';
defaults.writeMode = 'rewrite';

var paths = fileWriteAct.paths = Object.create( null );

paths.filePath = null;

var having = fileWriteAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var fileWriteStreamAct = Object.create( null );

var defaults = fileWriteStreamAct.defaults = Object.create( null );

defaults.filePath = null;

var paths = fileWriteStreamAct.paths = Object.create( null );

paths.filePath = null;

var having = fileWriteStreamAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var fileDeleteAct = Object.create( null );

var defaults = fileDeleteAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

var paths = fileDeleteAct.paths = Object.create( null );

paths.filePath = null;

var having = fileDeleteAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var fileTimeSetAct = Object.create( null );

var defaults = fileTimeSetAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.atime = null;
defaults.mtime = null;

var paths = fileTimeSetAct.paths = Object.create( null );

paths.filePath = null;

var having = fileTimeSetAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var directoryMakeAct = Object.create( null );

directoryMakeAct.defaults =
{
  filePath : null,
  sync : null,
}

var paths = directoryMakeAct.paths = Object.create( null );

paths.filePath = null;

var having = directoryMakeAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

// --
// write
// --


//

function _fileWriteStream_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var o2 = _.mapExtend( null, o );

  return self.fileWriteStreamAct( o2 );
}

var defaults = _fileWriteStream_body.defaults = Object.create( fileWriteStreamAct.defaults );
var paths = _fileWriteStream_body.paths = Object.create( fileWriteStreamAct.paths );
var having = _fileWriteStream_body.having = Object.create( fileWriteStreamAct.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function fileWriteStream( o )
// {
//   var self = this;
//   var o = self.fileWriteStream.pre.call( self, self.fileWriteStream, arguments );
//   var result = self.fileWriteStream.body.call( self, o );
//   return result;
// }
//
// fileWriteStream.pre = _preSinglePath;
// fileWriteStream.body = _fileWriteStream_body;
//
// var defaults = fileWriteStream.defaults = Object.create( _fileWriteStream_body.defaults );
// var paths = fileWriteStream.paths = Object.create( _fileWriteStream_body.paths );
// var having = fileWriteStream.having = Object.create( _fileWriteStream_body.having );

var fileWriteStream = _.routineForPreAndBody( _preSinglePath, _fileWriteStream_body );

fileWriteStream.having.aspect = 'entry';

//

function _fileWrite_pre( routine,args )
{
  var self = this;
  var o;

  if( args[ 1 ] !== undefined )
  {
    o = { filePath : args[ 0 ], data : args[ 1 ] };
    _.assert( args.length === 2 );
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
    _.assert( _.objectIs( o ),'expects 2 arguments {-o.filePath-} and {-o.data-} to write, or single options map' );
  }

  _.assert( o.data !== undefined, 'expects defined {-o.data-}' );
  _.routineOptions( routine,o );
  self._providerOptions( o );
  _.assert( _.strIs( o.filePath ),'expects string {-o.filePath-}' );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return o;
}

//

function _fileWrite_body( o )
{
  var self = this;

  o.encoding = o.encoding || self.encoding;

  let encoder = self.fileWrite.encoders[ o.encoding ];
  // if( encoder )
  // debugger;
  if( encoder && encoder.onBegin )
  _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder, data : o.data } ) === undefined );

  var o2 = _.mapOnly( o, self.fileWriteAct.defaults );

  _.assert( arguments.length === 1, 'expects single argument' );

  log();

  /* makingDirectory */

  if( o.makingDirectory )
  {
    self.directoryMakeForFile( o.filePath );
  }

  var terminateLink = !self.resolvingSoftLink && self.fileIsSoftLink( o.filePath );

  if( terminateLink && o.writeMode !== 'rewrite' )
  {
    self.fieldSet( 'resolvingSoftLink', 1 );
    let readData = self.fileRead({ filePath :  o.filePath, encoding : 'original.type' });
    self.fieldReset( 'resolvingSoftLink', 1 );

    let writeData = o.data;

    if( _.bufferBytesIs( readData ) )
    writeData = _.bufferBytesFrom( writeData );
    else if( _.bufferRawIs( readData ) )
    writeData = _.bufferRawFrom( writeData );
    else
    _.assert( _.strIs( readData ), 'not implemented for:', _.strTypeOf( readData ) );

    // qqq : ???
    // if( _.bufferNodeIs( readData ) )
    // {
    //   writeData = _.bufferNodeFrom( readData );
    // }
    // else if( _.bufferRawIs( readData ) )
    // {
    //   if( typeof Buffer != 'undefined' )
    //   writeData = Buffer.from( writeData );
    //   writeData = _.bufferRawFrom( writeData );
    // }
    // qqq : ???

    if( o.writeMode === 'append' )
    {
      if( _.strIs( writeData ) )
      o2.data = _.strJoin( readData, writeData );
      else
      o2.data = _.bufferJoin( readData, writeData )
    }
    else if( o.writeMode === 'prepend' )
    {
      if( _.strIs( writeData ) )
      o2.data = _.strJoin( writeData, readData );
      else
      o2.data = _.bufferJoin( writeData, readData )
    }
    else
    throw _.err( 'not implemented writeMode :', o.writeMode )

    o2.writeMode = 'rewrite';
  }

  /* purging */

  if( o.purging || terminateLink )
  {
    self.filesDelete({ filePath : o2.filePath, throwing : 0 });
  }

  var result = self.fileWriteAct( o2 );

  if( encoder && encoder.onEnd )
  _.sure( encoder.onEnd.call( self, { operation : o, encoder : encoder, data : o.data, result : result } ) === undefined );

  return result;

  /* log */

  function log()
  {
    if( o.verbosity >= 3 )
    self.logger.log( ' + writing', _.toStrShort( o.data ), 'to', o.filePath );
  }

}

var defaults = _fileWrite_body.defaults = Object.create( fileWriteAct.defaults );

defaults.verbosity = null;
defaults.makingDirectory = 1;
defaults.purging = 0;

var paths = _fileWrite_body.paths = Object.create( fileWriteAct.paths );
var having = _fileWrite_body.having = Object.create( fileWriteAct.having );

having.driving = 0;
having.aspect = 'body';

_fileWrite_body.encoders = Object.create( null );

//

/**
 * Writes data to a file. `data` can be a string or a buffer. Creating the file if it does not exist yet.
 * Returns wConsequence instance.
 * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
   exist, it's created. Method can accept two parameters : string `filePath` and string\buffer `data`, or single
   argument : options object, with required 'filePath' and 'data' parameters.
 * @example
 *
    var data = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      options =
      {
        filePath : 'tmp/sample.txt',
        data : data,
        sync : false,
      };
    var con = wTools.fileWrite( options );
    con.got( function()
    {
        console.log('write finished');
    });
 * @param {Object} options write options
 * @param {string} options.filePath path to file is written.
 * @param {string|Buffer} [options.data=''] data to write
 * @param {boolean} [options.append=false] if this options sets to true, method appends passed data to existing data
    in a file
 * @param {boolean} [options.sync=true] if this parameter sets to false, method writes file asynchronously.
 * @param {boolean} [options.force=true] if it's set to false, method throws exception if parents dir in `filePath`
    path is not exists
 * @param {boolean} [options.silentError=false] if it's set to true, method will catch error, that occurs during
    file writes.
 * @param {boolean} [options.verbosity=false] if sets to true, method logs write process.
 * @param {boolean} [options.clean=false] if sets to true, method removes file if exists before writing
 * @returns {wConsequence}
 * @throws {Error} If arguments are missed
 * @throws {Error} If passed more then 2 arguments.
 * @throws {Error} If `filePath` argument or options.PathFile is not string.
 * @throws {Error} If `data` argument or options.data is not string or Buffer,
 * @throws {Error} If options has unexpected property.
 * @method fileWrite
 * @memberof wFileProviderPartial
 */

var fileWrite = _.routineForPreAndBody( _fileWrite_pre, _fileWrite_body );

fileWrite.having.aspect = 'entry';

_.assert( _.mapIs( fileWrite.encoders ) );

//

function _fileAppend_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var o2 = _.mapOnly( o, self.fileWriteAct.defaults );
  return self.fileWrite( o );
}

var defaults = _fileAppend_body.defaults = Object.create( fileWrite.defaults );

defaults.writeMode = 'append';

var paths = _fileAppend_body.paths = Object.create( fileWrite.paths );
var having = _fileAppend_body.having = Object.create( fileWrite.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function fileAppend( o )
// {
//   var self = this;
//   var o = self.fileAppend.pre.call( self, self.fileAppend, arguments );
//   var result = self.fileAppend.body.call( self, o );
//   return result;
// }
//
// fileAppend.pre = _fileWrite_pre;
// fileAppend.body = _fileAppend_body;
//
// var defaults = fileAppend.defaults = Object.create( _fileAppend_body.defaults );
// var paths = fileAppend.paths = Object.create( _fileAppend_body.paths );
// var having = fileAppend.having = Object.create( _fileAppend_body.having );
//
// having.aspect = 'entry';
//
//

var fileAppend = _.routineForPreAndBody( _fileWrite_pre, _fileAppend_body );

fileAppend.having.aspect = 'entry';

//

function _fileWriteJson_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  /* stringify */

  var originalData = o.data;
  if( o.jsLike )
  {
    o.data = _.toJs( o.data );
  }
  else
  {
    if( o.cloning )
    o.data = _.cloneData({ src : o.data });
    if( o.pretty )
    o.data = _.toJson( o.data, { cloning : 0 } );
    else
    o.data = JSON.stringify( o.data );
  }

  if( o.prefix )
  o.data = o.prefix + o.data;

  /* validate */

  if( Config.debug && o.pretty ) try
  {

    // var parsedData = o.jsLike ? _.exec( o.data ) : JSON.parse( o.data );
    // _.assert( _.entityEquivalent( parsedData,originalData ),'not identical' );

  }
  catch( err )
  {

    // debugger;
    self.logger.log( '-' );
    self.logger.error( 'JSON:' );
    self.logger.error( _.toStr( o.data,{ levels : 999 } ) );
    self.logger.log( '-' );
    throw _.err( 'Cant convert JSON\n',err );
  }

  /* write */

  // delete o.prefix;
  // delete o.pretty;
  // delete o.jsLike;
  // delete o.cloning;

  let o2 = _.mapOnly( o, self.fileWrite.defaults );

  return self.fileWrite( o2 );
}

var defaults = _fileWriteJson_body.defaults = Object.create( fileWrite.defaults );

defaults.prefix = '';
defaults.jsLike = 0;
defaults.pretty = 1;
defaults.sync = null;
defaults.cloning = _.toJson.cloning;

var paths = _fileWriteJson_body.paths = Object.create( fileWrite.paths );
var having = _fileWriteJson_body.having = Object.create( fileWrite.having );

having.driving = 0;
having.aspect = 'body';

_.assert( _.boolLike( _.toJson.defaults.cloning ) );

//

/**
 * Writes data as json string to a file. `data` can be a any primitive type, object, array, array like. Method can
    accept options similar to fileWrite method, and have similar behavior.
 * Returns wConsequence instance.
 * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
 exist, it's created. Method can accept two parameters : string `filePath` and string\buffer `data`, or single
 argument : options object, with required 'filePath' and 'data' parameters.
 * @example
 * var fileProvider = _.FileProvider.Default();
 * var fs = require('fs');
   var data = { a : 'hello', b : 'world' },
   var con = fileProvider.fileWriteJson( 'tmp/sample.json', data );
   // file content : { "a" : "hello", "b" : "world" }

 * @param {Object} o write options
 * @param {string} o.filePath path to file is written.
 * @param {string|Buffer} [o.data=''] data to write
 * @param {boolean} [o.append=false] if this options sets to true, method appends passed data to existing data
 in a file
 * @param {boolean} [o.sync=true] if this parameter sets to false, method writes file asynchronously.
 * @param {boolean} [o.force=true] if it's set to false, method throws exception if parents dir in `filePath`
 path is not exists
 * @param {boolean} [o.silentError=false] if it's set to true, method will catch error, that occurs during
 file writes.
 * @param {boolean} [o.verbosity=false] if sets to true, method logs write process.
 * @param {boolean} [o.clean=false] if sets to true, method removes file if exists before writing
 * @param {string} [o.pretty=''] determines data stringify method.
 * @returns {wConsequence}
 * @throws {Error} If arguments are missed
 * @throws {Error} If passed more then 2 arguments.
 * @throws {Error} If `filePath` argument or options.PathFile is not string.
 * @throws {Error} If options has unexpected property.
 * @method fileWriteJson
 * @memberof wFileProviderPartial
 */

// function fileWriteJson( o )
// {
//   var self = this;
//   var o = self.fileWriteJson.pre.call( self, self.fileWriteJson, arguments );
//   var result = self.fileWriteJson.body.call( self, o );
//   return result;
// }
//
// fileWriteJson.pre = _fileWrite_pre;
// fileWriteJson.body = _fileWriteJson_body;
//
// var defaults = fileWriteJson.defaults = Object.create( _fileWriteJson_body.defaults );
// var paths = fileWriteJson.paths = Object.create( _fileWriteJson_body.paths );
// var having = fileWriteJson.having = Object.create( _fileWriteJson_body.having );
//
// having.aspect = 'entry';
//
//

var fileWriteJson = _.routineForPreAndBody( _fileWrite_pre, _fileWriteJson_body );

fileWriteJson.having.aspect = 'entry';

//
//
// function _fileWriteJs_body( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//
//   return self.fileWriteJson( o );
// }

var fileWriteJs = _.routineForPreAndBody( _fileWrite_pre, _fileWriteJson_body );

var defaults = fileWriteJs.defaults;

defaults.jsLike = 1;

var having = fileWriteJs.having;

having.driving = 0;
having.aspect = 'body';

//
//
// function fileWriteJs( o )
// {
//   var self = this;
//   var o = self.fileWriteJs.pre.call( self, self.fileWriteJs, arguments );
//   var result = self.fileWriteJs.body.call( self, o );
//   return result;
// }
//
// fileWriteJs.pre = _fileWrite_pre;
// fileWriteJs.body = _fileWriteJs_body;
//
// var defaults = fileWriteJs.defaults = Object.create( _fileWriteJs_body.defaults );
// var paths = fileWriteJs.paths = Object.create( _fileWriteJs_body.paths );
// var having = fileWriteJs.having = Object.create( _fileWriteJs_body.having );
//
// having.aspect = 'entry';
//
//
//
// var fileWriteJs = _.routineForPreAndBody( _fileWrite_pre, _fileWriteJs_body );
//
// fileWriteJs.having.aspect = 'entry';

//

function _fileTouch_pre( routine, args )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  var o = args[ 0 ];

  if( args.length === 2 )
  {
    o =
    {
      filePath : self.path.from( args[ 0 ] ),
      data : args[ 1 ]
    }
  }
  else
  {
    if( self.path.like( o ) )
    o = { filePath : self.path.from( o ) };
  }

  _.routineOptions( routine,o );
  self._providerOptions( o );
  _.assert( _.strIs( o.filePath ),'expects string {-o.filePath-}, but got',_.strTypeOf( o.filePath ) );

  return o;
}

//

function _fileTouch_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var stat = self.fileStat( o.filePath );
  if( stat )
  {
    if( !self.fileResolvedIsTerminal( o.filePath ) )
    {
      throw _.err( o.filePath,'is not terminal' );
      return null;
    }
  }

  o.data = stat ? self.fileRead({ filePath : o.filePath, encoding : 'original.type' }) : '';
  self.fileWrite( o );

  return self;
}

var defaults = _fileTouch_body.defaults = Object.create( fileWrite.defaults );

defaults.data = null;

var paths = _fileTouch_body.paths = Object.create( fileWrite.paths );
var having = _fileTouch_body.having = Object.create( fileWrite.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function fileTouch( o )
// {
//   var self = this;
//   var o = self.fileTouch.pre.call( self, self.fileTouch, arguments );
//   var result = self.fileTouch.body.call( self, o );
//   return result;
// }
//
// fileTouch.pre = _fileTouch_pre;
// fileTouch.body = _fileTouch_body;
//
// var defaults = fileTouch.defaults = Object.create( _fileTouch_body.defaults );
// var paths = fileTouch.paths = Object.create( _fileTouch_body.paths );
// var having = fileTouch.having = Object.create( _fileTouch_body.having );
//
// having.aspect = 'entry';
//
//

var fileTouch = _.routineForPreAndBody( _fileTouch_pre, _fileTouch_body );

fileTouch.having.aspect = 'entry';

//

function _fileTimeSet_pre( routine,args )
{
  var self = this;
  var o;

  if( args.length === 3 )
  o =
  {
    filePath : args[ 0 ],
    atime : args[ 1 ],
    mtime : args[ 2 ],
  }
  else if( args.length === 2 ) /* qqq : tests required */
  {
    var stat = args[ 1 ];
    if( _.strIs( stat ) )
    stat = self.fileStat({ filePath : stat, sync : 1, throwing : 1 })
    // _.assert( _.fileStatIs( stat ) );
    o =
    {
      filePath : args[ 0 ],
      atime : stat.atime,
      mtime : stat.mtime,
    }
  }
  else
  {
    _.assert( args.length === 1 );
    o = args[ 0 ];
  }

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.routineOptions( routine,o );

  return o;
}

//

function _fileTimeSet_body( o )
{
  var self = this;
  _.assert( arguments.length === 1, 'expects single argument' );
  return self.fileTimeSetAct( o );
}

var defaults = _fileTimeSet_body.defaults = Object.create( fileTimeSetAct.defaults );
var paths = _fileTimeSet_body.paths = Object.create( fileTimeSetAct.paths );
var having = _fileTimeSet_body.having = Object.create( fileTimeSetAct.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function fileTimeSet( o )
// {
//   var self = this;
//   var o = self.fileTimeSet.pre.call( self, self.fileTimeSet, arguments );
//   var result = self.fileTimeSet.body.call( self,o );
//   return result;
// }
//
// fileTimeSet.pre = _fileTimeSet_pre;
// fileTimeSet.body = _fileTimeSet_body;
//
// var defaults = fileTimeSet.defaults = Object.create( _fileTimeSet_body.defaults );
// var paths = fileTimeSet.paths = Object.create( _fileTimeSet_body.paths );
// var having = fileTimeSet.having = Object.create( _fileTimeSet_body.having );
//
// having.aspect = 'entry';
//
//

var fileTimeSet = _.routineForPreAndBody( _fileTimeSet_pre, _fileTimeSet_body );

fileTimeSet.having.aspect = 'entry';

//

function _fileDelete_body( o )
{
  var self = this;
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.arrayIs( o.filePath ) )
  {
    if( o.sync )
    {
      var con = new _.Consequence().give();
      var cons = [];
      for( var f = 0 ; f < o.filePath.length ; f++ )
      {
        var o2 = _.mapExtend( null,o );
        o2.filePath = o.filePath[ f ];
        cons[ f ] = _fileDelete_body.call( self,o2 );
      }
      con.andThen( cons );
      return con;
    }
    else
    {
      for( var f = 0 ; f < o.filePath.length ; f++ )
      {
        var o2 = _.mapExtend( null,o );
        o2.filePath = o.filePath[ f ];
        _fileDelete_body.call( self,o2 );
      }
      return;
    }
  }

  o.filePath = self.resolveLinkChain
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  // _.assert( o.filePath.length === 1, 'not tested' );
  act( o.filePath[ 0 ] );

  return result;

  /* */

  function act( filePath )
  {

    var o2 = _.mapExtend( null,o );

    o2.filePath = filePath;

    delete o2.throwing;
    delete o2.verbosity;
    delete o2.resolvingSoftLink;
    delete o2.resolvingTextLink;

    /* */

    try
    {
      result = self.fileDeleteAct( o2 );
    }
    catch( err )
    {
      if( o.throwing )
      debugger;
      log( 0 );
      _.assert( o.sync );
      if( o.throwing )
      throw _.err( err );
      return null;
    }

    /* */

    if( o.sync )
    {
      log( 1 );
    }
    else
    result.doThen( function( err,arg )
    {
      log( !err );
      if( err )
      {
        if( o.throwing )
        throw err;
        return null;
      }
    });

  }

  /* */

  function log( ok )
  {
    if( o.verbosity < 2 )
    return;
    if( ok )
    self.logger.log( '- fileDelete ' + o.filePath );
    else
    self.logger.log( '! failed fileDelete ' + o.filePath );
  }

}

var defaults = _fileDelete_body.defaults = Object.create( fileDeleteAct.defaults );

defaults.throwing = null;
defaults.verbosity = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

var paths = _fileDelete_body.paths = Object.create( fileDeleteAct.paths );
var having = _fileDelete_body.having = Object.create( fileDeleteAct.having );

having.driving = 0;
having.aspect = 'body';

//

/**
 * Deletes a terminal file or empty directory.
 * @param {String|Object} o Path to a file or object with options.
 * @param {String|FileRecord} [ o.filePath=null ] Path to a file or instance of FileRecord @see{@link wFileRecord}
 * @param {Boolean} [ o.sync=true ] Determines in which way file stats will be readed : true - synchronously, otherwise - asynchronously.
 * In asynchronous mode returns wConsequence.
 * @param {Boolean} [ o.throwing=false ] Controls error throwing. Returns null if error occurred and ( throwing ) is disabled.
 * @returns {undefined|wConsequence|null}
 * If ( o.filePath ) doesn't exist and ( o.throwing ) is disabled - returns null.
 * If ( o.sync ) mode is disabled - returns Consequence instance @see{@link wConsequence }.
 *
 * @example
 * wTools.fileProvider.fileDelete( './existingDir/test.txt' );
 *
 * @example
 * var consequence = wTools.fileProvider.fileDelete
 * ({
 *  filePath : './existingDir/test.txt',
 *  sync : 0
 * });
 * consequence.got( ( err, result ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( result );
 * })
 *
 * @method fileDelete
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.filePath ) path to a file doesn't exist or file is an directory with files.
 * @memberof wFileProviderPartial
 */

// function fileDelete( o )
// {
//   var self = this;
//   var o = self.fileDelete.pre.call( self, self.fileDelete, arguments );
//   var result = self.fileDelete.body.call( self, o );
//   return result;
// }
//
// fileDelete.pre = _preSinglePath;
// fileDelete.body = _fileDelete_body;
//
// var defaults = fileDelete.defaults = Object.create( _fileDelete_body.defaults );
// var paths = fileDelete.paths = Object.create( _fileDelete_body.paths );
// var having = fileDelete.having = Object.create( _fileDelete_body.having );
//
// having.aspect = 'entry';
//
//

var fileDelete = _.routineForPreAndBody( _preSinglePath, _fileDelete_body );

fileDelete.having.aspect = 'entry';

//

function _directoryMake_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.path.isNormalized( o.filePath ) );

  var stat = self.fileStat( o.filePath );

  if( stat )
  {

    if( stat.isFile() )
    if( o.rewritingTerminal )
    self.fileDelete( o.filePath );
    else
    return handleError( _.err( 'Cant rewrite terminal file:',_.strQuote( o.filePath ),'by directory file.' ) );

    if( stat.isDirectory() )
    {
      if( !o.force  )
      return handleError( _.err( 'File already exists:', _.strQuote( o.filePath ) ) );
      else
      return o.sync ? undefined : new _.Consequence().give();
    }

  }

  var exists = !!self.fileStat( self.path.dir( o.filePath ) );

  if( !o.force && !exists )
  return handleError( _.err( 'Directory', _.strQuote( o.filePath ), ' doesn\'t exist!. Use force option to create it.' ) );

  // delete o.rewritingTerminal;
  // delete o.force;

  var parts = [ o.filePath ];
  var dir = o.filePath;

  if( !exists )
  while( !exists )
  {
    dir = self.path.dir( dir );

    if( dir === '/' )
    break;

    exists = !!self.fileStat( dir );

    if( !exists )
    {
      _.arrayPrependOnce( parts, dir );
    }
    else
    {
      break;
    }
  }

  /* */

  if( o.sync )
  {
    for( var i = 0; i < parts.length; i++ )
    onPart.call( self, parts[ i ] );
  }
  else
  {
    var con = new _.Consequence().give();
    for( var i = 0; i < parts.length; i++ )
    con.ifNoErrorThen( _.routineSeal( self, onPart, [ parts[ i ] ] ) );

    return con;
  }

  /* */

  function onPart( filePath )
  {
    var self = this;
    let o2 = _.mapOnly( o, self.directoryMakeAct.defaults );
    o2.filePath = filePath;
    return self.directoryMakeAct( o2 );
  }

  /* */

  function handleError( err )
  {
    debugger;
    if( o.sync )
    throw err;
    else
    return new _.Consequence().error( err );
  }

}

var defaults = _directoryMake_body.defaults = Object.create( directoryMakeAct.defaults );

defaults.force = 1;
defaults.rewritingTerminal = 1;

var paths = _directoryMake_body.paths = Object.create( directoryMakeAct.paths );
var having = _directoryMake_body.having = Object.create( directoryMakeAct.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function directoryMake( o )
// {
//   var self = this;
//   var o = self.directoryMake.pre.call( self, self.directoryMake, arguments );
//   var result = self.directoryMake.body.call( self, o );
//   return result;
// }
//
// directoryMake.pre = _preSinglePath;
// directoryMake.body = _directoryMake_body;
//
// var defaults = directoryMake.defaults = Object.create( _directoryMake_body.defaults );
// var paths = directoryMake.paths = Object.create( _directoryMake_body.paths );
// var having = directoryMake.having = Object.create( _directoryMake_body.having );
//
// having.aspect = 'entry';
//
//

var directoryMake = _.routineForPreAndBody( _preSinglePath, _directoryMake_body );

directoryMake.having.aspect = 'entry';

//

function _directoryMakeForFile_body( o )
{
  var self = this;

  // if( self.path.like( o ) )
  // o = { filePath : self.path.from( o ) };

  // _.routineOptions( directoryMakeForFile,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  o.filePath = self.path.dir( o.filePath );

  return self.directoryMake( o );
}

var defaults = _directoryMakeForFile_body.defaults = Object.create( directoryMake.defaults );

defaults.force = 1;

var paths = _directoryMakeForFile_body.paths = Object.create( directoryMake.paths );
var having = _directoryMakeForFile_body.having = Object.create( directoryMake.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function directoryMakeForFile( o )
// {
//   var self = this;
//   var o = self.directoryMakeForFile.pre.call( self, self.directoryMakeForFile, arguments );
//   var result = self.directoryMakeForFile.body.call( self, o );
//   return result;
// }
//
// directoryMakeForFile.pre = _preSinglePath;
// directoryMakeForFile.body = _directoryMakeForFile_body;
//
// var defaults = directoryMakeForFile.defaults = Object.create( _directoryMakeForFile_body.defaults );
// var paths = directoryMakeForFile.paths = Object.create( _directoryMakeForFile_body.paths );
// var having = directoryMakeForFile.having = Object.create( _directoryMakeForFile_body.having );
//
// having.aspect = 'entry';
//
//

var directoryMakeForFile = _.routineForPreAndBody( _preSinglePath, _directoryMakeForFile_body );

directoryMakeForFile.having.aspect = 'entry';

// --
// link act
// --

var fileRenameAct = Object.create( null );

fileRenameAct.name = 'fileRenameAct';

var defaults = fileRenameAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.sync = null;

var paths = fileRenameAct.paths = Object.create( null );

paths.dstPath = null;
paths.srcPath = null;

var having = fileRenameAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var fileCopyAct = Object.create( null );

fileCopyAct.name = 'fileCopyAct';

var defaults = fileCopyAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.breakingDstHardLink = 0;
defaults.sync = null;

var paths = fileCopyAct.paths = Object.create( null );

paths.dstPath = null;
paths.srcPath = null;

var having = fileCopyAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var linkSoftAct = Object.create( null );

var defaults = linkSoftAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.sync = null;
defaults.type = null;

var paths = linkSoftAct.paths = Object.create( null );

paths.dstPath = null;
// paths.srcPath = null;

var having = linkSoftAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

/**
 * Creates hard link( new name ) to existing source( o.srcPath ) named as ( o.dstPath ).
 *
 * Accepts only ready options.
 * Expects normalized absolute paths for source( o.srcPath ) and destination( o.dstPath ), routine makes nativization by itself.
 * Source ( o.srcPath ) must be an existing terminal file.
 * Destination ( o.dstPath ) must not exist in filesystem.
 * Folders structure before destination( o.dstPath ) must exist in filesystem.
 * If source( o.srcPath ) and destination( o.dstPath ) paths are equal, operiation is considered as successful.
 *
 * @method linkHardAct
 * @memberof wFileProviderPartial
 */

var linkHardAct = Object.create( null );

linkHardAct.name = 'linkHardAct';

var defaults = linkHardAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.breakingSrcHardLink = 0;
defaults.breakingDstHardLink = 1;
defaults.sync = null;

var paths = linkHardAct.paths = Object.create( null );

// paths.dstPath = null;
// paths.srcPath = null;

var having = linkHardAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;
having.hardLinking = 1;

//

var hardLinkBreakAct = Object.create( null );

var defaults = hardLinkBreakAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

var paths = hardLinkBreakAct.paths = Object.create( null );

paths.filePath = null;

var having = hardLinkBreakAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

//

var softLinkBreakAct = Object.create( null );

var defaults = softLinkBreakAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

var paths = softLinkBreakAct.paths = Object.create( null );

paths.filePath = null;

var having = softLinkBreakAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

// --
// link
// --

function _link_pre( routine,args )
{
  var self = this;
  var o;

  if( args.length === 2 )
  {
    o =
    {
      dstPath : args[ 0 ],
      srcPath : args[ 1 ],
    }
    _.assert( args.length === 2 );
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
  }

  _.routineOptions( routine,o );
  self._providerOptions( o );
  _.mapSupplementNulls( o,routine.defaults );

  _.assert( o.filePaths === undefined );

  if( _.longIs( o.dstPath ) )
  {
    o.dstPath = o.dstPath.map( ( dstPath ) => self.path.from( dstPath ) );
    o.dstPath = self.path.pathsNormalize( o.dstPath );
  }
  else
  {
    o.dstPath = self.path.from( o.dstPath );
    o.dstPath = self.path.normalize( o.dstPath );
  }

  if( o.srcPath )
  {
    o.srcPath = self.path.from( o.srcPath );
    o.srcPath = self.path.normalize( o.srcPath );
  }

  // if( o.verbosity )
  // self.logger.log( routine.name,':', o.dstPath + ' <- ' + o.srcPath );

  return o;
}

//

function _linkMultiple( o,link )
{
  var self = this;

  if( o.dstPath.length < 2 )
  return o.sync ? true : new _.Consequence().give( true );

  _.assert( !!o );
  _.assert( _.strIs( o.srcPath ) || o.srcPath === null );
  _.assert( _.strIs( o.sourceMode ) || _.longIs( o.sourceMode ) );

  var needed = 0;
  var records = self.fileRecords( o.dstPath );

  var newestRecord;
  var mostLinkedRecord;

  function handleError( err )
  {
    if( o.sync )
    throw err;
    else
    return new _.Consequence().error( err );
  }

  if( o.srcPath )
  {
    if( !self.fileStat( o.srcPath ) )
    return handleError( _.err( '{ o.srcPath } ', o.srcPath, ' doesn\'t exist.' ) );
    newestRecord = mostLinkedRecord = self.fileRecord( o.srcPath );
  }
  else
  {
    var sorter = o.sourceMode;
    _.assert( !!sorter, 'Expects { option.sourceMode }' );
    newestRecord = self._fileRecordsSort( records, sorter );

    if( !newestRecord )
    return handleError( _.err( 'Source file was not selected, probably provided paths { o.dstPath } do not exist.' ) );

    let zero = self.UsingBigIntForStat ? BigInt( 0 ) : 0;
    mostLinkedRecord = _.entityMax( records,( record ) => record.stat ? record.stat.nlink : zero ).element;
  }

  for( var p = 0 ; p < records.length ; p++ )
  {
    var record = records[ p ];
    if( !record.stat || !_.fileStatsCouldBeLinked( newestRecord.stat,record.stat ) )
    {
      needed = 1;
      break;
    }
  }

  if( !needed )
  return o.sync ? true : new _.Consequence().give( true );

  /* */

  if( mostLinkedRecord.absolute !== newestRecord.absolute )
  {
    var read = self.fileRead({ filePath : newestRecord.absolute, encoding : 'original.type' });
    self.fileWrite( mostLinkedRecord.absolute,read );
  }

  /* */

  function onRecord( record )
  {
    if( record === mostLinkedRecord )
    return o.sync ? true : new _.Consequence().give( true );

    if( !o.allowDiffContent )
    if( record.stat && newestRecord.stat.mtime.getTime() === record.stat.mtime.getTime() && newestRecord.stat.birthtime.getTime() === record.stat.birthtime.getTime() )
    {
      if( _.fileStatsHaveDifferentContent( newestRecord.stat , record.stat ) )
      {
        var err = _.err( 'several files has same date but different content',newestRecord.absolute,record.absolute );
        debugger;
        if( o.sync )
        throw err;
        else
        return new _.Consequence().error( err );
      }
    }

    if( !record.stat || !_.fileStatsCouldBeLinked( mostLinkedRecord.stat , record.stat ) )
    {
      var linkOptions = _.mapExtend( null,o );
      linkOptions.dstPath = record.absolute;
      linkOptions.srcPath = mostLinkedRecord.absolute;
      return link.call( self,linkOptions );
    }

    return o.sync ? true : new _.Consequence().give( true );
  }

  /* */

  if( o.sync )
  {
    for( var p = 0 ; p < records.length ; p++ )
    {
      if( !onRecord( records[ p ] ) )
      return false;
    }

    return true;
  }
  else
  {
    var throwing = o.throwing;
    o.throwing = 1;
    var cons = [];

    var result = { err : undefined, got : true };

    function handler( err, got )
    {
      if( err && !_.definedIs( result.err ) )
      result.err = err;
      else
      result.got &= got;
    }

    for( var p = 0 ; p < records.length ; p++ )
    cons.push( onRecord( records[ p ] ).tap( handler ) );

    var con = new _.Consequence().give();

    con.andThen( cons )
    .doThen( () =>
    {
      if( result.err )
      {
        if( throwing )
        throw result.err;
        else
        return false;
      }
      return result.got;
    });

    return con;
  }

}

//

function _link_functor( gen )
{

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( _link_functor,gen );

  var nameOfMethodAct = gen.nameOfMethodAct;
  var nameOfMethodEntry = _.strRemoveEnd( gen.nameOfMethodAct,'Act' );
  var expectingAbsolutePaths = gen.expectingAbsolutePaths;
  var onBeforeRaname = gen.onBeforeRaname;
  var onAfterRaname = gen.onAfterRaname;
  var renamingAllowed = gen.renamingAllowed;
  var equalPathsIgnoring = gen.equalPathsIgnoring;
  var hardLinkedPathsIgnoring = gen.hardLinkedPathsIgnoring;

  _.assert( !onBeforeRaname || _.routineIs( onBeforeRaname ) );
  _.assert( !onAfterRaname || _.routineIs( onAfterRaname ) );

  /* */

  function _link_body( o )
  {

    var self = this;
    var linkAct = self[ nameOfMethodAct ];

    _.assert( arguments.length === 1, 'expects single argument' );
    _.assert( _.routineIs( linkAct ),'method',nameOfMethodAct,'is not implemented' );
    _.assert( _.objectIs( linkAct.defaults ),'method',nameOfMethodAct,'does not have defaults, but should' );

    _.assert( o.breakingSrcHardLink !== null );
    _.assert( o.resolvingSrcSoftLink !== null );
    _.assert( o.resolvingSrcTextLink !== null );
    _.assert( o.breakingDstHardLink !== null );
    _.assert( o.resolvingDstSoftLink !== null );
    _.assert( o.resolvingDstTextLink !== null );

    if( _.longIs( o.dstPath ) && linkAct.having.hardLinking )
    return _linkMultiple.call( self,o,_link_body );

    _.assert( _.strIs( o.srcPath ) && _.strIs( o.dstPath ) );

    /* resolve path */

    o.originalSrcPath = o.srcPath;
    o.originalDstPath = o.dstPath;

    if( !self.path.isAbsolute( o.dstPath ) )
    {
      _.assert( self.path.isAbsolute( o.srcPath ), o.srcPath );
      o.dstPath = self.path.resolve( o.srcPath, o.dstPath );
    }
    else if( !_.uri.isGlobal( o.srcPath ) && !self.path.isAbsolute( o.srcPath ) )
    {
      _.assert( self.path.isAbsolute( o.dstPath ), o.dstPath );
      o.srcPath = self.path.resolve( o.dstPath, o.srcPath );
    }

    /* equal paths */

    if( o.dstPath === o.srcPath )
    {
      if( equalPathsIgnoring )
      {
        if( o.sync )
        return true;
        return new _.Consequence().give( true );
      }

      if( !o.allowMissing )
      if( o.throwing )
      {
        var err = _.err( 'Making link to itself is not allowed. Please enable o.allowMissing' );
        if( o.sync )
        throw err;
        return new _.Consequence().error( err );
      }
      else
      {
        if( o.sync )
        return false;
        return new _.Consequence().give( false );
      }
    }

    /* hard-linked paths */

    if( hardLinkedPathsIgnoring )
    if( self.filesAreHardLinked( o.dstPath, o.srcPath ) )
    {
      if( o.sync )
      return true;
      return new _.Consequence().give( true );
    }

    /* */

    /* "if" required because relative path should be preserved */
    if( o.resolvingDstSoftLink || o.resolvingDstTextLink )
    o.dstPath = self.pathResolveLink
    ({
      filePath : o.dstPath,
      resolvingSoftLink : o.resolvingDstSoftLink,
      resolvingTextLink : o.resolvingDstTextLink,
      // resolvingHardLink : 0,
    });

    /* */

    /* qqq : pathResolveLink expects absolute path */
    /* "if" required because relative path should be preserved */
    if( self.path.isAbsolute( o.originalSrcPath ) )
    if( o.resolvingSrcSoftLink || o.resolvingSrcTextLink )
    o.srcPath = self.pathResolveLink
    ({
      filePath : o.srcPath,
      resolvingSoftLink : o.resolvingSrcSoftLink,
      resolvingTextLink : o.resolvingSrcTextLink,
      // resolvingHardLink : 0,
    });

    /* allowMissing */

    if( !o.allowMissing )
    if( !self.fileStat({ filePath : o.srcPath, resolvingSoftLink : 0, resolvingTextLink : 0 }) )
    {

      if( o.throwing )
      {
        debugger;
        var err = _.err( 'Src file', o.srcPath, 'does not exist' );
        if( o.sync )
        throw err;
        return new _.Consequence().error( err );
      }
      else
      {
        if( o.sync )
        return false;
        return new _.Consequence().give( false );
      }

    }

    /* act options */

    var optionsAct = _.mapOnly( o, linkAct.defaults );

    /* */

    if( o.sync )
    {

      var temp;
      try
      {
        if( onBeforeRaname )
        onBeforeRaname.call( self, o );

        if( self.fileStat({ filePath : optionsAct.dstPath, resolvingSoftLink : 0, resolvingTextLink : 0 }) )
        {
          if( !o.rewriting )
          throw _.err( 'dst file exist and rewriting is forbidden :',o.dstPath );
          // else if( _.definedIs( o.breakingDstSoftLink ) )
          // {
          //   if( o.breakingDstSoftLink && self.fileIsSoftLink( o.dstPath ) )
          //   self.softLinkBreak({ filePath : o.dstPath, sync : 1 });
          // }
          else if( renamingAllowed )
          {
            temp = tempNameMake();
            if( self.fileStat({ filePath : temp }) )
            self.filesDelete( temp );
            self.fileRename({ dstPath : temp, srcPath : optionsAct.dstPath, sync : 1, verbosity : 0, resolvingSrcSoftLink : 0, resolvingSrcTextLink : 0 });
          }
        }

        // qqq : ???
        // if( self.fileStat({ filePath : optionsAct.dstPath }) )
        // {
        //   if( !o.rewriting )
        //   throw _.err( 'dst file exist and rewriting is forbidden :',o.dstPath );
        //   temp = tempNameMake();
        //   if( self.fileStat({ filePath : temp }) )
        //   {
        //     temp = null;
        //     self.filesDelete( o.dstPath );
        //   }
        //   if( temp )
        //   {
        //     if( _.definedIs( o.breakingDstHardLink ) || _.definedIs( o.breakingDstSoftLink ) )
        //     {
        //       if( o.breakingDstHardLink || o.breakingDstSoftLink )
        //       temp = null;
        //       if( o.breakingDstSoftLink && self.fileIsSoftLink( o.dstPath ) )
        //       self.softLinkBreak({ filePath : o.dstPath, sync : 1 });
        //     }
        //     else
        //     self.fileRenameAct({ dstPath : temp, srcPath : optionsAct.dstPath, sync : 1 });
        //   }
        // }

        if( onAfterRaname && o.rewriting )
        onAfterRaname.call( self, o );

        linkAct.call( self,optionsAct );
        log();

        if( temp )
        self.filesDelete({ filePath : temp, verbosity : 0 });

      }
      catch( err )
      {

        if( temp ) try
        {
          debugger;
          self.fileRenameAct({ dstPath : optionsAct.dstPath, originalDstPath : o.originalDstPath, originalSrcPath : o.originalSrcPath, srcPath : temp, sync : 1 });
        }
        catch( err2 )
        {
          debugger;
          console.error( err2 );
          console.error( err.toString() + '\n' + err.stack );
        }

        if( o.throwing )
        throw _.err( 'Cant', nameOfMethodAct, o.dstPath, '<-', o.srcPath, '\n', err )
        return false;

      }

      return true;
    }
    else /* async */
    {

      // var temp = tempNameMake();
      // var dstExists,tempExists;

      // return _.timeOut( 0, () =>
      // {
      //   if( onBeforeRaname )
      //   onBeforeRaname.call( self, o );

      //   return self.fileStat({ filePath : optionsAct.dstPath, sync : 0 })
      // })
      // .ifNoErrorThen( function( exists )
      // {

      //   dstExists = exists;
      //   if( dstExists )
      //   {
      //     if( !o.rewriting )
      //     {
      //       var err = _.err( 'dst file exist and rewriting is forbidden :',optionsAct.dstPath );
      //       if( o.throwing )
      //       throw err;
      //       else
      //       throw _.errAttend( err );
      //     }

      //     return self.fileStat({ filePath : temp, sync : 0 });
      //   }

      // })
      // .ifNoErrorThen( function( exists )
      // {

      //   if( !dstExists )
      //   return;

      //   tempExists = exists;
      //   if( !tempExists )
      //   {
      //     if( _.definedIs( o.breakingDstHardLink ) || _.definedIs( o.breakingDstSoftLink ) )
      //     {
      //       if( o.breakingDstHardLink || o.breakingDstSoftLink )
      //       return self.fileCopyAct({ dstPath : temp, srcPath : optionsAct.dstPath, sync : 0, breakingDstHardLink : 0 })
      //       .ifNoErrorThen( () =>
      //       {
      //         if( o.breakingDstSoftLink && self.fileIsSoftLink( optionsAct.dstPath ) )
      //         return self.softLinkBreak({ filePath : o.dstPath, sync : 0 });
      //       })
      //     }
      //     else
      //     return self.fileRenameAct({ dstPath : temp, srcPath : optionsAct.dstPath, sync : 0 });
      //   }
      //   else
      //   {
      //     return self.filesDelete({ filePath : optionsAct.dstPath /*, sync : 0 */, verbosity : 0 });
      //   }

      // })
      // .ifNoErrorThen( function()
      // {
      //   if( onAfterRaname && o.rewriting )
      //   return onAfterRaname.call( self, o );
      // })
      // .ifNoErrorThen( function()
      // {

      //   log();

      //   return linkAct.call( self,optionsAct );

      // })
      // .ifNoErrorThen( function()
      // {

      //   if( temp )
      //   return self.filesDelete({ filePath : temp, /* sync : 0 */ verbosity : 0  });

      // })
      // .doThen( function( err )
      // {

      //   if( err )
      //   {
      //     var con = new _.Consequence().give();
      //     if( temp )
      //     {
      //       con.doThen( _.routineSeal( self,self.fileRenameAct,
      //       [{
      //         dstPath : optionsAct.dstPath,
      //         srcPath : temp,
      //         sync : 0,
      //         // verbosity : 0,
      //       }]));
      //     }

      //     return con.doThen( function()
      //     {
      //       if( o.throwing )
      //       throw _.errLogOnce( err );
      //       return false;
      //     });
      //   }

      //   return true;
      // })
      // ;

      /**/

      var temp;
      var statOptions =
      {
        filePath : optionsAct.dstPath,
        resolvingSoftLink : 0,
        resolvingTextLink : 0,
        sync : 0
      };
      var renamingOptions =
      {
        dstPath : null,
        srcPath : optionsAct.dstPath,
        sync : 0,
        verbosity : 0,
        resolvingSrcSoftLink : 0,
        resolvingSrcTextLink : 0,
      }

      var con = _.timeOut( 0 );

      if( onBeforeRaname )
      con.ifNoErrorThen( () => onBeforeRaname.call( self, o ) );

      con.ifNoErrorThen( () => self.fileStat( statOptions ) );

      con.ifNoErrorThen( ( dstStat ) =>
      {
        if( !dstStat )
        return;

        if( !o.rewriting )
        throw _.err( 'dst file exist and rewriting is forbidden :',o.dstPath );

        if( !renamingAllowed )
        return;

        temp = tempNameMake();
        statOptions.filePath = temp;
        renamingOptions.dstPath = temp;

        return self.fileStat( statOptions )
        .ifNoErrorThen( ( tempStat ) =>
        {
          if( tempStat )
          return self.filesDelete( temp );
        })
        .ifNoErrorThen( () => self.fileRename( renamingOptions ) );
      })

      if( onAfterRaname && o.rewriting )
      con.ifNoErrorThen( () => onAfterRaname.call( self, o ) );

      con.ifNoErrorThen( () => linkAct.call( self,optionsAct ) )
      con.ifNoErrorThen( () =>
      {
        log();

        if( temp )
        return self.filesDelete({ filePath : temp, verbosity : 0 });
      })


      con.doThen( ( err ) =>
      {
        if( !err )
        return true;

        var innerCon = new _.Consequence().give();

        if( temp )
        innerCon.ifNoErrorThen( () =>
        {
          renamingOptions.dstPath = optionsAct.dstPath;
          renamingOptions.srcPath = temp;

          return self.fileRename( renamingOptions );
        })

        innerCon.ifNoErrorThen( () =>
        {
          if( o.throwing )
          throw _.err( 'Cant', nameOfMethodAct, o.dstPath, '<-', o.srcPath, '\n', err )
          return false;
        })

        return innerCon;
      });


      return con;

    }

    /* */

    function log()
    {
      if( !o.verbosity || o.verbosity < 2 )
      return;
      var c = _.uri.isGlobal( o.srcPath ) ? '' : self.path.common( o.dstPath, o.srcPath );
      if( c.length > 1 )
      self.logger.log( ' +', nameOfMethodEntry,':',c,':',self.path.relative( c,o.dstPath ),'<-',self.path.relative( c,o.srcPath ) );
      else
      self.logger.log( ' +', nameOfMethodEntry,':',o.dstPath,'<-',o.srcPath );
    }

    /* */

    function tempNameMake()
    {
      return optionsAct.dstPath + '-' + _.idWithGuid() + '.tmp';
    }

  }

  function linkEntry( o )
  {
    var self = this;
    var o = self[ nameOfMethodEntry ].pre.call( self,self[ nameOfMethodEntry ],arguments );
    var result = self[ nameOfMethodEntry ].body.call( self,o );
    return result;
  }

  linkEntry.pre = _link_pre;
  linkEntry.body = _link_body;

  /* qqq : at the end, all files should has the same size */

  return linkEntry;
}

_link_functor.defaults =
{
  nameOfMethodAct : null,
  onBeforeRaname : null,
  onAfterRaname : null,
  expectingAbsolutePaths : true,
  renamingAllowed : true,
  equalPathsIgnoring : true,
  hardLinkedPathsIgnoring : false
}

//

/**
 * Changes name of the file.
 * Takes single argument - object with options or two arguments : destination( o.dstPath ) and source( o.srcPath ) paths.
 * Routine changes name of the source file if ( o.srcPath ) and ( dstPath ) have different file names. Also moves source file to the new location( dstPath )
 * if parent directories of ( o.srcPath ) and ( o.dstPath ) are not same. If ( o.dstPath ) path exists and ( o.rewriting ) is enabled, the destination file can be overwritten.
 *
 * @param {Object} o Object with options.
 * @param {String|FileRecord} [ o.dstPath=null ] - Destination path or instance of FileRecord @see{@link wFileRecord}. Path must be absolute.
 * @param {String|FileRecord} [ o.srcPath=null ] - Source path or instance of FileRecord @see{@link wFileRecord}. Path can be relative to destination path or absolute.
 * In case of FileRecord instance, absolute path will be used.
 * @param {Boolean} [ o.sync=true ] - Determines in which way file will be renamed : true - synchronously, otherwise - asynchronously.
 * In asynchronous mode returns wConsequence.
 * @param {Boolean} [ o.throwing=true ] - Controls error throwing. Returns false if error occurred and ( o.throwing ) is disabled.
 * @param {Boolean} [ o.rewriting=false ] - Controls rewriting of the destination file( o.dstPath ).
 * @returns {Boolean|wConsequence} Returns true after successful rename, otherwise false is returned. Also returns false if an error occurs and ( o.throwing ) is disabled.
 * In async mode returns Consequence instance @see{@link wConsequence } with same result.
 *
 * @example
 * wTools.fileProvider.fileRename( '/existingDir/notExistingDst','/existingDir/existingSrc' );
 * //returns true
 *
 * @example
 * wTools.fileProvider.fileRename( '/existingDir/existingSrc','/existingDir/existingSrc' );
 * //returns false
 *
 * @example
 * wTools.fileProvider.fileRename
 * ({
 *  dstPath : '/existingDir/notExistingDst',
 *  srcPath : '/existingDir/notExistingSrc',
 *  throwing : 1
 * });
 * //throws an Error
 *
 * @example
 * wTools.fileProvider.fileRename
 * ({
 *  dstPath : '/existingDir/notExistingDst',
 *  srcPath : '/existingDir/notExistingSrc',
 *  throwing : 0
 * });
 * //returns false
 *
 * @example
 * wTools.fileProvider.fileRename
 * ({
 *  dstPath : '/existingDir/notExistingDst',
 *  srcPath : '/existingDir/notExistingSrc',
 *  throwing : 0
 * });
 * //returns false
 *
 * @example
 * wTools.fileProvider.fileRename
 * ({
 *  dstPath : '/existingDir/existingDst',
 *  srcPath : '/existingDir/existingSrc',
 *  throwing : 0,
 *  rewriting : 0
 * });
 * //returns false
 *
 * @example
 * wTools.fileProvider.fileRename
 * ({
 *  dstPath : '/existingDir/existingDst',
 *  srcPath : '/existingDir/existingSrc',
 *  throwing : 0,
 *  rewriting : 1
 * });
 * //returns true
 *
 * @example
 * var consequence = wTools.fileProvider.fileRename
 * ({
 *  dstPath : '/existingDir/notExistingDst',
 *  srcPath : '/existingDir/existingSrc',
 *  sync : 0
 * });
 * consequence.got( ( err, got ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( got ); // true
 * })
 *
 * @method fileRename
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.srcPath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.dstPath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.srcPath ) path to a file doesn't exist.
 * @throws { Exception } If destination( o.dstPath ) and source( o.srcPath ) files exist and ( o.rewriting ) is disabled.
 * @memberof wFileProviderPartial
 */

var fileRename = _link_functor
({
  nameOfMethodAct : 'fileRenameAct',
  equalPathsIgnoring : true,
});

var defaults = fileRename.body.defaults = Object.create( fileRenameAct.defaults );

defaults.rewriting = 0;
defaults.throwing = null;
defaults.verbosity = null;

defaults.resolvingSrcSoftLink = 1;
defaults.resolvingSrcTextLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

var paths = fileRename.body.paths = Object.create( fileRenameAct.paths );
var having = fileRename.body.having = Object.create( fileRenameAct.having );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

var defaults = fileRename.defaults = Object.create( fileRename.body.defaults );
var paths = fileRename.paths = Object.create( fileRename.body.paths );
var having = fileRename.having = Object.create( fileRename.body.having );

having.aspect = 'entry';

//

/**
 * Creates copy of a file. Accepts two arguments: ( srcPath ),( dstPath ) or options object.
 * Returns true if operation is finished successfully or if source and destination paths are equal.
 * Otherwise throws error with corresponding message or returns false, it depends on ( o.throwing ) property.
 * In asynchronously mode returns wConsequence instance.
 * @example
   var fileProvider = _.FileProvider.Default();
   var result = fileProvider.fileCopy( 'src.txt','dst.txt' );
   console.log( result );// true
   var stats = fileProvider.fileStat( 'dst.txt' );
   console.log( stats ); // returns Stats object
 * @example
   var fileProvider = _.FileProvider.Default();
   var consequence = fileProvider.fileCopy
   ({
     srcPath : 'src.txt',
     dstPath : 'dst.txt',
     sync : 0
   });
   consequence.got( function( err, got )
   {
     if( err )
     throw err;
     console.log( got ); // true
     var stats = fileProvider.fileStat( 'dst.txt' );
     console.log( stats ); // returns Stats object
   });

 * @param {Object} o - options object.
 * @param {string} o.srcPath path to source file.
 * @param {string} o.dstPath path where to copy source file.
 * @param {boolean} [o.sync=true] If set to false, method will copy file asynchronously.
 * @param {boolean} [o.rewriting=true] Enables rewriting of destination path if it exists.
 * @param {boolean} [o.throwing=true] Enables error throwing. Returns false if error occurred and ( o.throwing ) is disabled.
 * @param {boolean} [o.verbosity=true] Enables logging of copy process.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 2.
 * @throws {Error} If dstPath or dstPath is not string.
 * @throws {Error} If options object has unexpected property.
 * @throws {Error} If ( o.rewriting ) is false and destination path exists.
 * @throws {Error} If path to source file( srcPath ) not exists and ( o.throwing ) is enabled, otherwise returns false.
 * @method fileCopy
 * @memberof wFileProviderPartial
 */

function fileCopy_functor()
{

  function _onBeforeRaname( o )
  {
    var self = this;

    _.assert( _.strIs( o.srcPath ) );

    var directoryIs = self.directoryIs({ filePath : o.srcPath, resolvingSoftLink : 0, resolvingTextLink : 0 })
    if( directoryIs )
    {
      debugger;
      var directoryIs = self.fileIsDirectory({ filePath : o.srcPath, resolvingSoftLink : 0, resolvingTextLink : 0 })
      throw _.err( o.srcPath,'is directory file!' );
    }

  }

  function _fileCopyOnRewriting( o )
  {
    var self = this;

    _.assert( _.objectIs( o ) );

    var dirPath = self.path.dir( o.dstPath );
    if( self.directoryIs({ filePath : dirPath, resolvingSoftLink : 0, resolvingTextLink : 0 }) )
    return;

    if( o.rewriting )
    return self.directoryMakeForFile({ filePath : o.dstPath, rewritingTerminal : 1, force : 1, sync : o.sync });
  }

  var fileCopy = _link_functor
  ({
    nameOfMethodAct : 'fileCopyAct',
    onAfterRaname : _fileCopyOnRewriting,
    onBeforeRaname : _onBeforeRaname,
    renamingAllowed : false,
    equalPathsIgnoring : true,
  });

  return fileCopy;
}

var fileCopy = fileCopy_functor();

var defaults = fileCopy.body.defaults = Object.create( fileCopyAct.defaults );

defaults.rewriting = 1;
defaults.throwing = null;
defaults.verbosity = null;

defaults.resolvingSrcSoftLink = 1;
defaults.resolvingSrcTextLink = 0;
defaults.breakingDstHardLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

var paths = fileCopy.body.paths = Object.create( fileCopyAct.paths );
var having = fileCopy.body.having = Object.create( fileCopyAct.having );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

var defaults = fileCopy.defaults = Object.create( fileCopy.body.defaults );
var paths = fileCopy.paths = Object.create( fileCopy.body.paths );
var having = fileCopy.having = Object.create( fileCopy.body.having );

having.aspect = 'entry';

//

/**
 * link methods options
 * @typedef { object } wTools~linkOptions
 * @property { boolean } [ dstPath= ] - Target file.
 * @property { boolean } [ srcPath= ] - Source file.
 * @property { boolean } [ o.sync=true ] - Runs method in synchronous mode. Otherwise asynchronously and returns wConsequence object.
 * @property { boolean } [ rewriting=true ] - Rewrites target( o.dstPath ).
 * @property { boolean } [ verbosity=true ] - Logs working process.
 * @property { boolean } [ throwing=true ] - Enables error throwing. Otherwise returns true/false.
 */

/**
 * Creates soft link( symbolic ) to existing source( o.srcPath ) named as ( o.dstPath ).
 * Rewrites target( o.dstPath ) by default if it exist. Logging of working process is controled by option( o.verbosity ).
 * Returns true if link is successfully created. If some error occurs during execution method uses option( o.throwing ) to
 * determine what to do - throw error or return false.
 *
 * @param { wTools~linkOptions } o - options { @link wTools~linkOptions  }
 *
 * @method linkSoft
 * @throws { exception } If( o.srcPath ) doesn`t exist.
 * @throws { exception } If cant link ( o.srcPath ) with ( o.dstPath ).
 * @memberof wFileProviderPartial
 */

var linkSoft = _link_functor
({
  nameOfMethodAct : 'linkSoftAct',
  expectingAbsolutePaths : false,
  equalPathsIgnoring : false,
});

var defaults = linkSoft.body.defaults = Object.create( linkSoftAct.defaults );

defaults.rewriting = 1;
defaults.throwing = null;
defaults.verbosity = null;
defaults.allowMissing = 0;
defaults.resolvingSrcSoftLink = 0;
defaults.resolvingSrcTextLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

var paths = linkSoft.body.paths = Object.create( linkSoftAct.paths );

var having = linkSoft.body.having = Object.create( linkSoftAct.having );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

var defaults = linkSoft.defaults = Object.create( linkSoft.body.defaults );
var paths = linkSoft.paths = Object.create( linkSoft.body.paths );
var having = linkSoft.having = Object.create( linkSoft.body.having );

having.aspect = 'entry';

//

/**
 * Creates hard link( new name ) to existing source( o.srcPath ) named as ( o.dstPath ).
 * Rewrites target( o.dstPath ) by default if it exist. Logging of working process is controled by option( o.verbosity ).
 * Returns true if link is successfully created. If some error occurs during execution method uses option( o.throwing ) to
 * determine what to do - throw error or return false.
 *
 * @param { wTools~linkOptions } o - options { @link wTools~linkOptions  }
 *
 * @method linkSoft
 * @throws { exception } If( o.srcPath ) doesn`t exist.
 * @throws { exception } If cant link ( o.srcPath ) with ( o.dstPath ).
 * @memberof wFileProviderPartial
 */

var linkHard = _link_functor
({
  nameOfMethodAct : 'linkHardAct',
  equalPathsIgnoring : true,
  hardLinkedPathsIgnoring : true
});

var defaults = linkHard.body.defaults = Object.create( linkHardAct.defaults );

defaults.rewriting = 1;
defaults.throwing = null;
defaults.verbosity = null;
defaults.allowDiffContent = 0;
defaults.sourceMode = 'modified>hardlinks>';
defaults.breakingSrcHardLink = 0;
defaults.resolvingSrcSoftLink = 1;
defaults.resolvingSrcTextLink = 0;
defaults.breakingDstHardLink = 1;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

var paths = linkHard.body.paths = Object.create( linkHardAct.paths );

var having = linkHard.body.having = Object.create( linkHardAct.having );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

var defaults = linkHard.defaults = Object.create( linkHard.body.defaults );
var paths = linkHard.paths = Object.create( linkHard.body.paths );
var having = linkHard.having = Object.create( linkHard.body.having );

having.aspect = 'entry';

//

function _fileExchange_pre( routine,args )
{
  var self = this;
  var o;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( args.length === 2 )
  {
    o =
    {
      dstPath : args[ 0 ],
      srcPath : args[ 1 ],
    }
    _.assert( args.length === 2 );
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
  }

  _.routineOptions( routine,o );
  self._providerOptions( o );
  _.assert( _.strIs( o.srcPath ) && _.strIs( o.dstPath ) );

  return o;
}

//

function _fileExchange_body( o )
{
  var self  = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var dstPath = o.dstPath;
  var srcPath = o.srcPath;

  var allowMissing = o.allowMissing;
  delete o.allowMissing;

  var src = self.fileStat({ filePath : o.srcPath, throwing : 0 });
  var dst = self.fileStat({ filePath : o.dstPath, throwing : 0 });

  function _returnNull()
  {
    if( o.sync )
    return null;
    else
    return new _.Consequence().give( null );
  }

  if( !src || !dst )
  {
    if( allowMissing )
    {
      if( !src && dst )
      {
        o.srcPath = o.dstPath;
        o.dstPath = srcPath;
      }
      if( !src && !dst )
      return _returnNull();

      return self.fileRename( o );
    }
    else if( o.throwing )
    {
      var err;

      if( !src && !dst )
      {
        err = _.err( 'srcPath and dstPath not exist! srcPath: ', o.srcPath, ' dstPath: ', o.dstPath )
      }
      else if( !src )
      {
        err = _.err( 'srcPath not exist! srcPath: ', o.srcPath );
      }
      else
      {
        err = _.err( 'dstPath not exist! dstPath: ', o.dstPath );
      }

      if( o.sync )
      throw err;
      else
      return new _.Consequence().error( err );
    }
    else
    return _returnNull();
  }

  var temp = o.srcPath + '-' + _.idWithGuid() + '.tmp';

  o.dstPath = temp;

  if( o.sync )
  {
    self.fileRename( o );
    o.dstPath = o.srcPath;
    o.srcPath = dstPath;
    self.fileRename( o );
    o.dstPath = dstPath;
    o.srcPath = temp;
    return self.fileRename( o );
  }
  else
  {
    var con = new _.Consequence().give();

    con.ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) )
    .ifNoErrorThen( function()
    {
      o.dstPath = o.srcPath;
      o.srcPath = dstPath;
    })
    .ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) )
    .ifNoErrorThen( function()
    {
      o.dstPath = dstPath;
      o.srcPath = temp;
    })
    .ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) );

    return con;
  }
}

var defaults = _fileExchange_body.defaults = Object.create( null );

defaults.srcPath = null;
defaults.dstPath = null;
defaults.sync = null;
defaults.allowMissing = 1;
defaults.throwing = null;
defaults.verbosity = null;

var paths = _fileExchange_body.paths = Object.create( null );

var having = _fileExchange_body.having = Object.create( null );

having.writing = 1;
having.reading = 1;
having.driving = 0;
having.aspect = 'body';

//

/**
 * Swaps content of the two files.
 * Takes single argument - object with options or two arguments : destination( o.dstPath ) and source( o.srcPath ) paths.
 * @param {Object} o Object with options.
 * @param {String|FileRecord} [ o.dstPath=null ] - Destination path or instance of FileRecord @see{@link wFileRecord}. Path must be absolute.
 * @param {String|FileRecord} [ o.srcPath=null ] - Source path or instance of FileRecord @see{@link wFileRecord}. Path can be relative to destination path or absolute.
 * In case of FileRecord instance, absolute path will be used.
 * @param {Boolean} [ o.sync=true ] - Determines execution mode: true - synchronously, false - asynchronously.
 * In asynchronous mode returns wConsequence @see{@link wConsequence }.
 * @param {Boolean} [ o.throwing=true ] - Controls error throwing. Returns false if error occurred and ( o.throwing ) is disabled.
 * @param {Boolean} [ o.allowMissing=true ] - Allows missing of the file( s ). If source ( o.srcPath ) is missing - ( o.srcPath ) becomes destination and ( o.dstPath ) becomes the source. Routine returns null if both paths are missing.
 * @returns {Boolean|wConsequence} Returns true after successful exchange, otherwise false is returned. Also returns false if an error occurs and ( o.throwing ) is disabled.
 * In async mode returns Consequence instance @see{@link wConsequence } with same result.
 *
 * @example
 * wTools.fileProvider.fileExchange( '/existingDir/existingDst','/existingDir/existingSrc' );
 * //returns true
 *
 * @example
 * var consequence = wTools.fileProvider.fileExchange
 * ({
 *  dstPath : '/existingDir/existingDst',
 *  srcPath : '/existingDir/existingSrc',
 *  sync : 0
 * });
 * consequence.got( ( err, got ) =>
 * {
 *    if( err )
 *    throw err;
 *
 *    console.log( got ); // true
 * })
 *
 * @method fileExchange
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.srcPath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.dstPath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.srcPath ) path to a file doesn't exist.
 * @throws { Exception } If destination( o.dstPath ) and source( o.srcPath ) files exist and ( o.rewriting ) is disabled.
 * @memberof wFileProviderPartial
 */

// function fileExchange( o )
// {
//   var self = this;
//   var o = self.fileExchange.pre.call( self, self.fileExchange, arguments );
//   var result = self.fileExchange.body.call( self, o );
//   return result;
// }
//
// fileExchange.pre = _fileExchange_pre;
// fileExchange.body = _fileExchange_body;
//
// var defaults = fileExchange.defaults = Object.create( _fileExchange_body.defaults );
// var paths = fileExchange.paths = Object.create( _fileExchange_body.paths );
// var having = fileExchange.having = Object.create( _fileExchange_body.having );
//
// having.aspect = 'entry';
//
//

var fileExchange = _.routineForPreAndBody( _fileExchange_pre, _fileExchange_body );

fileExchange.having.aspect = 'entry';

//

function _hardLinkBreak_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.routineIs( self.hardLinkBreakAct ) )
  return self.hardLinkBreakAct( o );
  else
  {
    var options =
    {
      filePath :  o.filePath,
      purging : 1
    };

    if( o.sync )
    return self.fileTouch( options );
    else
    return _.timeOut( 0, () => self.fileTouch( options ) );
  }
}

var defaults = _hardLinkBreak_body.defaults = Object.create( hardLinkBreakAct.defaults );
var paths = _hardLinkBreak_body.paths = Object.create( hardLinkBreakAct.paths );
var having = _hardLinkBreak_body.having = Object.create( hardLinkBreakAct.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function hardLinkBreak( o )
// {
//   var self = this;
//   var o = self.hardLinkBreak.pre.call( self, self.hardLinkBreak, arguments );
//   var result = self.hardLinkBreak.body.call( self, o );
//   return result;
// }
//
// hardLinkBreak.pre = _preSinglePath;
// hardLinkBreak.body = _hardLinkBreak_body;
//
// var defaults = hardLinkBreak.defaults = Object.create( _hardLinkBreak_body.defaults );
// var paths = hardLinkBreak.paths = Object.create( _hardLinkBreak_body.paths );
// var having = hardLinkBreak.having = Object.create( _hardLinkBreak_body.having );
//
// having.aspect = 'entry';
//
//

var hardLinkBreak = _.routineForPreAndBody( _preSinglePath, _hardLinkBreak_body );

hardLinkBreak.having.aspect = 'entry';

//

function _softLinkBreak_body( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.routineIs( self.softLinkBreakAct ) )
  return self.softLinkBreakAct( o );
  else
  {
    var options =
    {
      filePath :  o.filePath,
      purging : 1
    };

    if( o.sync )
    return self.fileTouch( options );
    else
    return _.timeOut( 0, () => self.fileTouch( options ) );
  }
}

var defaults = _softLinkBreak_body.defaults = Object.create( softLinkBreakAct.defaults );
var paths = _softLinkBreak_body.paths = Object.create( softLinkBreakAct.paths );
var having = _softLinkBreak_body.having = Object.create( softLinkBreakAct.having );

having.driving = 0;
having.aspect = 'body';

//
//
// function softLinkBreak( o )
// {
//   var self = this;
//   var o = self.softLinkBreak.pre.call( self, self.softLinkBreak, arguments );
//   var result = self.softLinkBreak.body.call( self, o );
//   return result;
// }
//
// softLinkBreak.pre = _preSinglePath;
// softLinkBreak.body = _softLinkBreak_body;
//
// var defaults = softLinkBreak.defaults = Object.create( _softLinkBreak_body.defaults );
// var paths = softLinkBreak.paths = Object.create( _softLinkBreak_body.paths );
// var having = softLinkBreak.having = Object.create( _softLinkBreak_body.having );
//
// having.aspect = 'entry';
//
//

var softLinkBreak = _.routineForPreAndBody( _preSinglePath, _softLinkBreak_body );

softLinkBreak.having.aspect = 'entry';

// --
//
// --

// function _verbositySet( val )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//
//   if( !_.numberIs( val ) )
//   val = val ? 1 : 0;
//   if( val < 0 )
//   val = 0;
//
//   self[ verbositySymbol ] = val;
// }
//
// var having = _verbositySet.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 0;
// having.driving = 0;
// having.kind = 'inter';

//

function _protocolsSet( val )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.strIs( val ) )
  self._protocolsSet([ val ]);

  _.assert( _.arrayIs( val ) )

  val = val.slice();

  var protocol = val.join( '+' );

  self[ protocolsSymbol ] = val;
  self[ protocolSymbol ] = protocol;

  if( protocol )
  self[ originPathSymbol ] = protocol + '://';
  else
  self[ originPathSymbol ] = '';

}

var having = _protocolsSet.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'inter';

//

function _protocolSet( val )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( val ) );

  self._protocolsSet( val.split( '+' ) );
}

var having = _protocolSet.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'inter';

//

function _originPathSet( val )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( val ) );
  _.assert( _.strEnds( val,'://' ) );

  val = _.strRemoveEnd( val, '://' );

  _.assert( !_.strHas( val,'://' ) );

  self._protocolsSet( val.split( '+' ) );
}

var having = _originPathSet.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'inter';

// --
// encoders
// --

var readEncoders = fileRead.encoders;
var writeEncoders = fileWrite.encoders;

readEncoders[ 'buffer' ] =
{

  onBegin : function( e )
  {
    _.assert( 0,'"buffer" is deprecated encoding, please use "buffer.node" or "buffer.raw"' );
  },

}

readEncoders[ 'arraybuffer' ] =
{

  onBegin : function( e )
  {
    _.assert( 0,'"arraybuffer" is deprecated encoding, please use "buffer.raw"' );
  },

}

readEncoders[ 'json' ] =
{

  exts : [ 'json' ],
  forInterpreter : 1,

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'json' );
    e.operation.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( '( fileRead.encoders.json.onEnd ) expects string' );
    e.data = JSON.parse( e.data );
  },

}

//

readEncoders[ 'structure.js' ] =
{

  exts : [ 'js','s','ss','jstruct' ],
  forInterpreter : 0,

  onBegin : function( e )
  {
    e.operation.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( '( fileRead.encoders.structure.js.onEnd ) expects string' );
    e.data = _.exec({ code : e.data, filePath : e.operation.filePath, prependingReturn : 1 });
  },

}

// fileRead.encoders = readEncoders;
// fileInterpret.encoders = readEncoders;

//

readEncoders[ 'smart.js' ] =
{

  exts : [ 'js','s','ss','jstruct' ],
  forInterpreter : 1,

  onBegin : function( e )
  {
    // debugger;
    e.operation.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    // debugger;
    _.sure( _.strIs( e.data ), 'expects string' );

    if( typeof process !== 'undefined' && typeof require !== 'undefined' )
    if( _.FileProvider.HardDrive && e.provider instanceof _.FileProvider.HardDrive )
    {
      try
      {
        e.data = require( _.fileProvider.path.nativize( e.operation.filePath ) );
        return;
      }
      catch( err )
      {
      }
    }

    e.data = _.exec
    ({
      code : e.data,
      filePath : e.operation.filePath,
      prependingReturn : 1,
    });
  },

}

//

readEncoders[ 'node.js' ] =
{

  exts : [ 'js','s','ss','jstruct' ],
  forInterpreter : 0,

  onBegin : function( e )
  {
    e.operation.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( '( fileRead.encoders.node.js.onEnd ) expects string' );
    e.data = require( _.fileProvider.path.nativize( e.operation.filePath ) );
  },

}

//
//
// if( Config.platform === 'nodejs' )
// readEncoders[ 'node.js' ] =
// {
//
//   exts : [ 'js','s','ss' ],
//
//   onBegin : function( e )
//   {
//     e.operation.encoding = 'utf8';
//   },
//
//   onEnd : function( e )
//   {
//     return require( _.fileProvider.path.nativize( e.operation.filePath ) );
//   },
// }
//
// fileReadAct.encoders = readEncoders;
// fileWriteAct.encoders = writeEncoders;

//

readEncoders[ 'buffer.bytes' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    e.data = e.data;
    _.assert( _.bufferBytesIs( e.data ) );
  },

}

// writeEncoders[ 'buffer.bytes' ] =
// {
//
//   onBegin : function( e )
//   {
//     debugger;
//     _.assert( e.operation.encoding === 'buffer.bytes' );
//     e.operation.encoding = 'buffer.node';
//     // var result = _.bufferNodeFrom( e.data );
//     // return result;
//     return e.data;
//   },
//
// }

// --
// vars
// --

var verbositySymbol = Symbol.for( 'verbosity' );
var protocolsSymbol = Symbol.for( 'protocols' );
var protocolSymbol = Symbol.for( 'protocol' );
var originPathSymbol = Symbol.for( 'originPath' );

var WriteMode = [ 'rewrite','prepend','append' ];

var ProviderDefaults =
{
  'encoding' : null,
  // 'resolvingHardLink' : null,
  'resolvingSoftLink' : null,
  'resolvingTextLink' : null,
  'usingSoftLink' : null,
  'usingTextLink' : null,
  'verbosity' : null,
  'sync' : null,
  'throwing' : null,
  'hub' : null,
}

// --
// relationship
// --

var Composes =
{
  protocols : _.define.own([]),
  encoding : 'utf8',
  // encoding : 'latin1', /* qqq */
  hashFileSizeLimit : 1 << 22,

  // resolvingHardLink : 1, /* !!! : deprecate */
  resolvingSoftLink : 1,
  resolvingTextLink : 0,
  usingSoftLink : 1,
  usingTextLink : 0,

  verbosity : 0,
  sync : 1,
  throwing : 1,
  safe : 1,
  stating : 1,
}

var Aggregates =
{
}

var Associates =
{
  path : null,
  logger : null,
  hub : null,
}

var Restricts =
{
}

var Medials =
{
  protocol : null,
  originPath : null,
}

var Statics =
{
  MakeDefault : MakeDefault,
  Path : _.path.CloneExtending({ fileProvider : Self }),
  WriteMode : WriteMode,
  ProviderDefaults : ProviderDefaults
}

var Forbids =
{

  done : 'done',
  currentAct : 'currentAct',
  current : 'current',
  resolvingHardLink : 'resolvingHardLink',

  pathNativize : 'pathNativize',
  pathsNativize : 'pathsNativize',
  pathCurrent : 'pathCurrent',
  pathResolve : 'pathResolve',
  pathsResolve : 'pathsResolve',

  linkSoftRead : 'linkSoftRead',
  linkSoftReadAct : 'linkSoftReadAct'

}

var Accessors =
{
  protocols : 'protocols',
  protocol : 'protocol',
  originPath : 'originPath',
}

// --
// declare
// --

var Proto =
{

  init : init,
  finit : finit,
  MakeDefault : MakeDefault,

  // etc

  _fileOptionsGet : _fileOptionsGet,
  _providerOptions : _providerOptions,
  _preSinglePath : _preSinglePath,

  providerForPath : providerForPath,

  // path

  localFromUri : localFromUri,
  localsFromUris : localsFromUris,

  urlFromLocal : urlFromLocal,
  urlsFromLocals : urlsFromLocals,

  pathNativizeAct : pathNativizeAct,
  // path.nativize : path.nativize,
  // pathsNativize : pathsNativize,

  pathCurrentAct : pathCurrentAct,
  // pathCurrent : pathCurrent,

  // pathResolve : pathResolve,
  // pathsResolve : pathsResolve,

  _pathForCopy_pre : _pathForCopy_pre,
  _pathForCopy_body : _pathForCopy_body,
  forCopy : forCopy,

  _pathFirstAvailable_pre : _pathFirstAvailable_pre,
  _pathFirstAvailable_body : _pathFirstAvailable_body,
  firstAvailable : firstAvailable,

  _pathResolveTextLinkAct : _pathResolveTextLinkAct,
  _pathResolveTextLink : _pathResolveTextLink,
  resolveTextLink : resolveTextLink,

  pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  _pathResolveSoftLink_body : _pathResolveSoftLink_body,
  pathResolveSoftLink : pathResolveSoftLink,

  pathResolveHardLinkAct : pathResolveHardLinkAct,
  _pathResolveHardLink_body : _pathResolveHardLink_body,
  pathResolveHardLink : pathResolveHardLink,

  _pathResolveLinkChain_body : _pathResolveLinkChain_body,
  resolveLinkChain : resolveLinkChain,

  _pathResolveLink_body : _pathResolveLink_body,
  pathResolveLink : pathResolveLink,

  // linkSoftReadAct : linkSoftReadAct,
  // _linkSoftRead_body : _linkSoftRead_body,
  // linkSoftRead : linkSoftRead,

  // record

  _fileRecordContextForm : _fileRecordContextForm,
  _fileRecordFormBegin : _fileRecordFormBegin,
  _fileRecordPathForm : _fileRecordPathForm,
  _fileRecordFormEnd : _fileRecordFormEnd,

  fileRecord : fileRecord,
  fileRecords : fileRecords,
  fileRecordsFiltered : fileRecordsFiltered,

  _fileRecordsSort : _fileRecordsSort,

  fileRecordContext : fileRecordContext,
  fileRecordFilter : fileRecordFilter,

  // read act

  fileReadAct : fileReadAct,
  fileReadStreamAct : fileReadStreamAct,
  fileStatAct : fileStatAct,
  fileExistsAct : fileExistsAct,
  fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,
  fileIsTerminalAct : fileIsTerminalAct,

  // read content

  fileReadStream : fileReadStream,

  fileRead : fileRead,
  fileReadSync : fileReadSync,
  fileReadJson : fileReadJson,

  fileReadJs : fileReadJs,
  fileInterpret : fileInterpret,
  fileHash : fileHash,

  filesFingerprints : filesFingerprints,

  directoryRead : directoryRead,
  directoryReadDirs : directoryReadDirs,
  directoryReadTerminals : directoryReadTerminals,

  // read stat

  _fileStat_body : _fileStat_body,
  fileStat : fileStat,

  fileExists : fileExists,

  fileIsTerminal : fileIsTerminal,
  fileResolvedIsTerminal : fileResolvedIsTerminal,

  fileIsSoftLink : fileIsSoftLink,
  fileIsHardLink : fileIsHardLink,
  fileIsTextLink : fileIsTextLink,

  fileIsLink : fileIsLink,
  fileResolvedIsLink : fileResolvedIsLink,

  filesStats : _.routineVectorize_functor( fileStat ),
  filesAreTerminals : _.routineVectorize_functor( fileIsTerminal ),
  filesAreSoftLinks : _.routineVectorize_functor( fileIsSoftLink ),
  filesAreHardLinks : _.routineVectorize_functor( fileIsHardLink ),
  filesAreTextLinks : _.routineVectorize_functor( fileIsTextLink ),
  filesAreLinks : _.routineVectorize_functor( fileIsLink ),

  filesAreSame : filesAreSame,

  filesAreHardLinkedAct : filesAreHardLinkedAct,

  filesAreHardLinked : filesAreHardLinked,

  filesSize : filesSize,
  fileSize : fileSize,

  directoryIs : directoryIs,
  directoryResolvedIs : directoryResolvedIs,

  directoryIsEmpty : directoryIsEmpty,
  directoriesAre : _.routineVectorize_functor( directoryIs ),
  directoriesAreEmpty : _.routineVectorize_functor( directoryIsEmpty ),

  // write act

  fileWriteAct : fileWriteAct,
  fileWriteStreamAct : fileWriteStreamAct,
  fileTimeSetAct : fileTimeSetAct,
  fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,

  // write

  fileWriteStream : fileWriteStream,

  fileWrite : fileWrite,
  fileAppend : fileAppend,
  fileWriteJson : fileWriteJson,
  fileWriteJs : fileWriteJs,

  fileTouch : fileTouch,
  fileTimeSet : fileTimeSet,
  fileDelete : fileDelete,

  directoryMake : directoryMake,

  directoryMakeForFile : directoryMakeForFile,

  // link act

  fileRenameAct : fileRenameAct,
  fileCopyAct : fileCopyAct,
  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,

  hardLinkBreakAct : hardLinkBreakAct,
  softLinkBreakAct : softLinkBreakAct,

  // link

  _link_pre : _link_pre,
  _linkMultiple : _linkMultiple,
  _link_functor : _link_functor,

  fileRename : fileRename,
  fileCopy : fileCopy,
  linkSoft : linkSoft,
  linkHard : linkHard,

  _fileExchange_pre : _fileExchange_pre,
  _fileExchange_body : _fileExchange_body,
  fileExchange : fileExchange,

  _hardLinkBreak_body : _hardLinkBreak_body,
  hardLinkBreak : hardLinkBreak,

  _softLinkBreak_body : _softLinkBreak_body,
  softLinkBreak : softLinkBreak,

  //

  _protocolsSet : _protocolsSet,
  _protocolSet : _protocolSet,
  _originPathSet : _originPathSet,

  // relations

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Medials : Medials,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.FieldsStack.mixin( Self );
_.Verbal.mixin( Self );

_.assert( _.routineIs( Self.prototype.filesStats ) );
_.assert( _.objectIs( Self.prototype.filesStats.defaults ) );

// --
// export
// --

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
