( function _Partial_s_() {

'use strict';

let _global = _global_;
let _ = _global_.wTools;

_.assert( !_.FileProvider.wFileProviderPartial );
_.assert( _.routineIs( _.routineVectorize_functor ) );
_.assert( _.routineIs( _.path.join ) );

//

/**
  * Definitions :
  *  Terminal file :: leaf of files sysytem, contains series of bytes. Terminal file cant contain other files.
  *  Directory :: non-leaf node of files sysytem, contains other dirs and terminal file(s).
  *  File :: any node of files sysytem, could be leaf( terminal file ) or non-leaf( directory ).
  *  Only terminal files contains series of bytes, function of directory to organize logical space for terminal files.
  *  self :: pathCurrent object.
  *  Self :: pathCurrent class.
  *  Parent :: parent class.
  *  Statics :: static fields.
  */

/*
 Act version of method :

- should assert that path is absolute
- should not extend or delete fields of options map, no _providerDefaults, routineOptions
- should path.nativize all paths in options map if needed by its own means
- should expect normalized path, but not nativized
- should expect ready options map, no complex arguments preprocessing
- should not create folders structure for path

*/

//

let Parent = _.FileProvider.Abstract;
let Self = function wFileProviderPartial( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Partial';

// --
// shortcuts
// --

function _vectorize( routine, select )
{
  select = select || 1;

  let routineName = routine.name;

  _.assert( _.routineIs( routine ) );
  _.assert( _.strDefined( routineName ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  let routine2 = _.routineVectorize_functor
  ({
    routine : [ routineName ],
    vectorizingArray : 1,
    vectorizingMap : 0,
    vectorizingKeys : 0,
    select : select,
  });

  _.routineExtend( routine2, routine );

  return routine2;
}

//

function _vectorizeAll( routine, select )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  let routine2 = _vectorize( routine, select );
  _.routineExtend( all, routine );
  return all;

  /* */

  function all()
  {
    let result = routine2.apply( this, arguments );
    return _.all( result );
  }

}

//

function _vectorizeAny( routine, select )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  let routine2 = _vectorize( routine, select );
  _.routineExtend( any, routine );
  return any;

  /* */

  function any()
  {
    let result = routine2.apply( this, arguments );
    return _.any( result );
  }

}

//

function _vectorizeNone( routine, select )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  let routine2 = _vectorize( routine, select );
  _.routineExtend( none, routine );
  return none;

  /* */

  function none()
  {
    let result = routine2.apply( this, arguments );
    return _.none( result );
  }

}

// --
// inter
// --

function init( o )
{
  let self = this;

  Parent.prototype.init.call( self );

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  {
    if( o.logger )
    self.logger = o.logger;
    else
    self.logger = new _.Logger({ output : console });
    self.copy( o );
  }
  else
  {
    self.logger = new _.Logger({ output : console });
  }

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
  self.logger.log( 'new', _.strType( self ) );

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

function _providerDefaults( o )
{
  let self = this;

  _.assert( _.objectIs( o ), 'Expects map { o }' );

  if( o.verbosity === null && self.verbosity !== null )
  o.verbosity = _.numberClamp( self.verbosity - 3, 0, 9 );

  for( let k in self.ProviderDefaults )
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

function _preFilePathScalarWithoutProviderDefaults( routine, args )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args && args.length === 1, 'Routine ' + routine.name + ' expects exactly one arguments' );

  let o = args[ 0 ];

  if( path.like( o ) )
  o = { filePath : path.from( o ) };

  _.routineOptions( routine, o );

  o.filePath = path.normalize( o.filePath );

  _.assert( path.isAbsolute( o.filePath ), () => 'Expects absolute path {-o.filePath-}, but got ' + _.strQuote( o.filePath ) );

  return o;
}

//

function _preFilePathScalarWithProviderDefaults( routine, args )
{
  let self = this;

  let o = self._preFilePathScalarWithoutProviderDefaults.apply( self, arguments );

  if( o.verbosity === null )
  o.verbosity = _.numberClamp( self.verbosity - 4, 0, 9 );

  self._providerDefaults( o );

  return o;
}

//

function _preFilePathVectorWithoutProviderDefaults( routine, args )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args && args.length === 1, 'Routine ' + routine.name + ' expects exactly one arguments' );

  let o = args[ 0 ];

  if( path.like( o ) )
  o = { filePath : path.from( o ) };
  else if( _.arrayIs( o ) )
  o = { filePath : o };

  _.routineOptions( routine, o );

  _.assert( path.s.allAreAbsolute( o.filePath ), () => 'Expects absolute path {-o.filePath-}, but got ' + _.strQuote( o.filePath ) );

  o.filePath = path.s.normalize( o.filePath );

  return o;
}

//

function _preFilePathVectorWithProviderDefaults( routine, args )
{
  let self = this;

  let o = self._preFilePathVectorWithoutProviderDefaults.apply( self, arguments );

  if( o.verbosity === null )
  o.verbosity = _.numberClamp( self.verbosity - 4, 0, 9 );

  self._providerDefaults( o );

  return o;
}

//

function _preSrcDstPathWithoutProviderDefaults( routine, args )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2, 'Routine ' + routine.name + ' expects one or two arguments' );

  let o = args[ 0 ];

  if( path.like( args[ 0 ] ) || path.like( args[ 1 ] ) )
  o = { dstPath : args[ 0 ], srcPath : args[ 1 ] }

  // let o = args[ 0 ];
  // if( path.like( o ) )
  // o = { filePath : path.from( o ) };
  // else if( _.arrayIs( o ) )
  // o = { filePath : o };

  _.routineOptions( routine, o );

  if( o.dstPath !== null )
  {
    o.dstPath = path.s.from( o.dstPath );
    o.dstPath = path.s.normalize( o.dstPath );
  }

  if( o.srcPath !== null )
  {
    o.srcPath = path.s.from( o.srcPath );
    o.srcPath = path.s.normalize( o.srcPath );
  }

  return o;
}

//

function _preSrcDstPathWithProviderDefaults( routine, args )
{
  let self = this;

  let o = self._preSrcDstPathWithoutProviderDefaults.apply( self, arguments );

  if( o.verbosity === null )
  o.verbosity = _.numberClamp( self.verbosity - 4, 0, 9 );

  self._providerDefaults( o );

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

function _fileOptionsGet( filePath, o )
{
  let self = this;
  o = o || Object.create( null );

  if( _.objectIs( filePath ) )
  {
    o = filePath;
  }
  else
  {
    o.filePath = filePath;
  }

  if( !o.filePath )
  throw _.err( '_fileOptionsGet :', 'Expects (-o.filePath-)' );

  _.assertMapHasOnly( o, this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

//

function protocolsForOrigins( origins )
{
  if( origins === null )
  return origins;

  if( _.arrayIs( origins ) )
  return origins.map( ( origin ) => self.protocolsForOrigins( origin ) );
  _.assert( _.strIs( origins ) );
  return _.strRemoveEnd( _.strRemoveEnd( origins, '//' ), ':' );
}

//

function originsForProtocols( protocols )
{
  if( _.arrayIs( protocols ) )
  return protocols.map( ( protocol ) => self.originsForProtocols( protocol ) );
  _.assert( _.strIs( protocols ) );
  return protocols + '://';
}

//

function providerForPath( path )
{
  let self = this;
  _.assert( _.strIs( path ), 'Expects string' );
  _.assert( !_.path.isGlobal( path ) );
  return self;
}

//

function providerRegisterTo( hub )
{
  let self = this;
  hub.providerRegister( self );
  return self;
}

// //
//
// function claimBeginAct( o )
// {
//   let self = this;
// }
//
// //
//
// function claimBegin( o )
// {
//   let self = this;
//
//   if( _.strIs( o ) )
//   o = { filePath : o }
//   _.assert( arguments.length === 1 );
//
//   if( self.claimMap && self.claimMap[ o.filePath ] )
//   {
//     let claim = self.claimMap[ o.filePath ];
//     claim.used += 1;
//     return claim;
//   }
//
//   let result = self.claimBeginAct( o );
//
//   if( Config.debug && self.claimMap )
//   if( !_.consequenceLike( result ) )
//   check( self.claimMap[ o.filePath ] );
//   else
//   _.Consequence.From( result ).doThen( ( err ) =>
//   {
//     if( err )
//     throw err;
//     check( self.claimMap[ o.filePath ] );
//   });
//
//   return result;
//
//   function check( claim )
//   {
//     // _.assert( claim.times >= 1 ); // xxx
//   }
// }
//
// //
//
// function claimEndAct( o )
// {
//   let self = this;
// }
//
// //
//
// function claimEnd( o )
// {
//   let self = this;
//
//   if( arguments.length === 0 )
//   {
//     let con;
//     for( let c in self.claimMap )
//     {
//       let r = self.claimEnd({ filePath : c, times : Infinity }); /* xxx : use concurrent instead of serial */
//       if( con || _.consequenceLike( r ) )
//       {
//         con = new _.Consequence().give( null );
//         con.doThen( r );
//       }
//     }
//     return con;
//   }
//
//   if( _.strIs( o ) )
//   o = { filePath : o }
//
//   if( !self.claimMap )
//   return;
//
//   _.routineOptions( claimEnd, o );
//   _.assert( arguments.length === 1 );
//   _.assert( !!self.claimMap[ o.filePath ], 'Path', _.strQuote( o.filePath ), 'was not claimed' );
//   _.assert( self.claimMap[ o.filePath ].times >= 1 );
//
//   let claim = self.claimMap[ o.filePath ];
//
//   if( o.times === Infinity )
//   claim.times = 0;
//   else
//   claim.times -= 1;
//
//   if( claim.times > 0 )
//   return false;
//
//   return self.claimEndAct( o );
// }
//
// claimEnd.defaults =
// {
//   filePath : null,
//   times : 1,
// }

// --
// path
// --

function localFromGlobal( uri )
{
  let self = this;

  if( _.strIs( uri ) )
  {
    if( !_.path.isGlobal( uri ) )
    return uri;
    uri = _.uri.parse( uri );
  }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.mapIs( uri ) ) ;
  _.assert( _.strIs( uri.localPath ) );
  _.assert( !self.protocols || !uri.protocol || _.arrayHas( self.protocols, uri.protocol ) );

  return uri.localPath;
}

//

function globalFromLocal( localPath )
{
  let self = this;
  let path = self.path.parse ? self.path : _.uri;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( localPath ) )
  _.assert( !self.protocols.length || _.strIs( self.originPath ) );

  if( self.originPath )
  return path.join( self.originPath, localPath );
  else
  return localPath;
}

//

function pathNativizeAct( filePath )
{
  let self = this;
  _.assert( _.strIs( filePath ), 'Expects string' ) ;
  return filePath;
}

var having = pathNativizeAct.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 1;
having.kind = 'path';

//

let pathCurrentAct = null;

//

function _pathForCopy_pre( routine, args )
{
  let self = this;

  _.assert( args.length === 1 );

  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { path : o };

  _.routineOptions( routine, o );
  _.assert( self instanceof _.FileProvider.Abstract );
  _.assert( _.strIs( o.path ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return o;
}

//

function _pathForCopy_body( o )
{
  let fileProvider = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let postfix = _.strPrependOnce( o.postfix, o.postfix ? '-' : '' );
  let file = fileProvider.recordFactory().record( o.path );
  let name = file.name;

  let parts = _.strSplitFast({ src : name, delimeter : '-', preservingEmpty : 0, preservingDelimeters : 0 });
  if( parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0, parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous

  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0, parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  name = parts.slice( 0, parts.length-2 ).join( '-' );

  /*file.absolute =  file.dir + '/' + file.name + file.extWithDot;*/

  let path = fileProvider.path.join( file.dir , name + postfix + file.extWithDot );
  if( !fileProvider.statResolvedRead({ filePath : path , sync : 1 }) )
  return path;

  let attempts = 1 << 13;
  let index = 1;

  while( attempts > 0 )
  {

    let path = fileProvider.path.join( file.dir , name + postfix + '-' + index + file.extWithDot );

    if( !fileProvider.statResolvedRead({ filePath : path , sync : 1 }) )
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

// var paths = _pathForCopy_body.paths = Object.create( null );
var having = _pathForCopy_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';

//

// /**
//  * Generate path string for copy of existing file passed into `o.path`. If file with generated path is exists now,
//  * method try to generate new path by adding numeric index into tail of path, before extension.
//  * @example
//  * let str = 'foo/bar/baz.txt',
//    let path = wTools.pathforCopy( {path : str } ); // 'foo/bar/baz-copy.txt'
//  * @param {Object} o options argument
//  * @param {string} o.path Path to file for create name for copy.
//  * @param {string} [o.postfix='copy'] postfix for mark file copy.
//  * @returns {string} path for copy.
//  * @throws {Error} If missed argument, or passed more then one.
//  * @throws {Error} If passed object has unexpected property.
//  * @throws {Error} If file for `o.path` is not exists.
//  * @method forCopy
//  * @memberof wTools
//  */
//
// let forCopy = _.routineFromPreAndBody( _pathForCopy_pre, _pathForCopy_body );
//
// forCopy.having.aspect = 'entry';

//
//
// function _pathFirstAvailable_pre( routine, args )
// {
//   let self = this;
//
//   _.assert( args.length === 1 );
//
//   let o = args[ 0 ];
//
//   if( !_.mapIs( o ) )
//   o = { paths : o }
//
//   _.routineOptions( routine, o );
//   _.assert( _.arrayIs( o.paths ) );
//   _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//
//   return o;
// }
//
// //
//
// function _pathFirstAvailable_body( o )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   for( let p = 0 ; p < o.paths.length ; p++ )
//   {
//     let path = o.paths[ p ];
//     if( self.statResolvedRead( o.onPath ? o.onPath.call( o, path, p ) : path ) )
//     return path;
//   }
//
//   return undefined;
// }
//
// _pathFirstAvailable_body.defaults =
// {
//   paths : null,
//   onPath : null,
// }
//
// var paths = _pathFirstAvailable_body.paths = Object.create( null );
// var having = _pathFirstAvailable_body.having = Object.create( null );
//
// having.driving = 0;
// having.aspect = 'body';
//
// let firstAvailable = _.routineFromPreAndBody( _pathFirstAvailable_pre, _pathFirstAvailable_body );
//
// firstAvailable.having.aspect = 'entry';



let _pathResolveTextLinkAct = null;

//

// function _pathResolveTextLink( path, allowingMissing )
function _pathResolveTextLink( o )
{
  let self = this;

  _.assertRoutineOptions( _pathResolveTextLink, arguments );

  let result = self._pathResolveTextLinkAct
  ({
    filePath : o.filePath,
    // visited : [],
    // hasLink : false,
  });

  if( !result )
  return { resolved : false, originalFilePath : o.filePath, resolvedFilePath : null };

  _.assert( arguments.length === 1 || arguments.length === 2  );

  if( result && o.filePath[ 0 ] === '.' && !self.path.isAbsolute( result ) )
  result = './' + result;

  self.logger.log( 'pathResolveTextLink :', o.filePath, '->', result );

  return { resolved : true, originalFilePath : o.filePath, resolvedFilePath : result };
}

_pathResolveTextLink.defaults =
{
  filePath : null
}

//

function pathResolveTextLink_pre( routine, args )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1, 'Expects single argument for', routine.name );
  _.routineOptions( routine, args );

  return args[ 0 ];
}

//

function pathResolveTextLink_body( o )
{
  let self = this;

  if( !self.usingTextLink )
  return o.filePath;

  _.assertRoutineOptions( pathResolveTextLink_body, arguments );
  _.assert( _.strIs( o.filePath ), 'Expects string' );
  _.assert( arguments.length === 1, 'Expects exactly one argument' );

  let result = self._pathResolveTextLink( o );

  return result.resolvedFilePath || result.originalFilePath;
}

pathResolveTextLink_body.defaults =
{
  filePath : null
}

let pathResolveTextLink = _.routineFromPreAndBody( pathResolveTextLink_pre, pathResolveTextLink_body );

//

let pathResolveSoftLinkAct = Object.create( null );

var defaults = pathResolveSoftLinkAct.defaults = Object.create( null );

defaults.filePath = null;
// defaults.readLink = 0;

// var paths = pathResolveSoftLinkAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = pathResolveSoftLinkAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = pathResolveSoftLinkAct.operates  = Object.create( null );

operates.filePath = { pathToRead : 1 };

//

function pathResolveSoftLink_body( o )
{
  let self = this;

  _.assert( _.routineIs( self.pathResolveSoftLinkAct ) );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!o.filePath );

  /* should not have redundant conditions */
  /* qqq : check does it cause problems */

  // if( !self.isSoftLink( o.filePath ) )
  // return o.filePath;

  let result = self.pathResolveSoftLinkAct( o );

  result = self.path.normalize( result );

  return result;
}

_.routineExtend( pathResolveSoftLink_body, pathResolveSoftLinkAct );

// var defaults = pathResolveSoftLink_body.defaults = Object.create( pathResolveSoftLinkAct.defaults );
// var paths = pathResolveSoftLink_body.paths = Object.create( pathResolveSoftLinkAct.paths );
// var having = pathResolveSoftLink_body.having = Object.create( pathResolveSoftLinkAct.having );

var having = pathResolveSoftLink_body.having;

having.driving = 0;
having.aspect = 'body';

//

function pathResolveSoftLink( path )
{
  let self = this;
  let o = self.pathResolveSoftLink.pre.call( self, self.pathResolveSoftLink, arguments );
  let result = self.pathResolveSoftLink.body.call( self, o );
  return result;
}

pathResolveSoftLink.pre = _preFilePathScalarWithProviderDefaults;
pathResolveSoftLink.body = pathResolveSoftLink_body;

var defaults = pathResolveSoftLink.defaults = Object.create( pathResolveSoftLink_body.defaults );
// var paths = pathResolveSoftLink.paths = Object.create( pathResolveSoftLink_body.paths );
var having = pathResolveSoftLink.having = Object.create( pathResolveSoftLink_body.having );

having.aspect = 'entry';

// //
//
// let pathResolveHardLinkAct = Object.create( null );
//
// var defaults = pathResolveHardLinkAct.defaults = Object.create( null );
//
// defaults.filePath = null;
//
// var paths = pathResolveHardLinkAct.paths = Object.create( null );
//
// paths.filePath = null;
//
// var having = pathResolveHardLinkAct.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 1;
//
// var operates = pathResolveHardLinkAct.operates = Object.create( null );
//
// operates.filePath = { pathToRead : 1 }
//
// //
//
// function pathResolveHardLink_body( o )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( !!o.filePath );
//
//   if( !_.routineIs( self.pathResolveHardLinkAct ) )
//   return o.filePath;
//
//   if( !self.isHardLink( o.filePath ) )
//   return o.filePath;
//
//   let result = self.pathResolveHardLinkAct( o );
//
//   return self.path.normalize( result );
// }
//
// var defaults = pathResolveHardLink_body.defaults = Object.create( pathResolveHardLinkAct.defaults );
// var paths = pathResolveHardLink_body.paths = Object.create( pathResolveHardLinkAct.paths );
// var having = pathResolveHardLink_body.having = Object.create( pathResolveHardLinkAct.having );
//
// having.driving = 0;
// having.aspect = 'body';

//

// function pathResolveHardLink( path )
// {
//   let self = this;
//   let o = self.pathResolveHardLink.pre.call( self, self.pathResolveHardLink, arguments );
//   let result = self.pathResolveHardLink.body.call( self, o );
//   return result;
// }
//
// pathResolveHardLink.pre = _preFilePathScalarWithProviderDefaults;
// pathResolveHardLink.body = pathResolveHardLink_body;
//
// var defaults = pathResolveHardLink.defaults = Object.create( pathResolveHardLink_body.defaults );
// var paths = pathResolveHardLink.paths = Object.create( pathResolveHardLink_body.paths );
// var having = pathResolveHardLink.having = Object.create( pathResolveHardLink_body.having );
//
// let pathResolveHardLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, pathResolveHardLink_body );
//
// pathResolveHardLink.having.aspect = 'entry';

//

// function pathResolveHardLink( path )
// {
//   let self = this;
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   return path;
// }

//

function pathResolveLinkChain_pre()
{
  let self = this;
  let o = self._preFilePathScalarWithProviderDefaults.apply( self, arguments );

  if( o.found === null )
  o.found = [];

  if( o.result === null )
  o.result = [];

  return o;
}

//

/*
  qqq : option preservingRelative:1 to preserve relative in path of soft link if happened to be so
  !!! qqq : no duplicates
*/

function pathResolveLinkChain_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.boolLike( o.resolvingSoftLink ) );
  _.assert( _.boolLike( o.resolvingTextLink ) );
  _.assert( _.boolLike( o.allowingMissing ) );
  _.assert( _.boolLike( o.throwing ) );
  _.assert( _.arrayIs( o.found ) );
  _.assert( _.arrayIs( o.result ) );
  _.assertRoutineOptions( pathResolveLinkChain_body, arguments );

  let hub = o.hub || self.hub;
  if( hub && hub !== self && path.isGlobal( o.filePath ) )
  return hub.pathResolveLinkChain.body.call( hub, o );

  if( _.arrayHas( o.found, o.filePath ) )
  {
    o.err = { cycleInLinks : true }; /* xxx */ // used by Extract.statReadAct to get kind of error
    debugger;
    if( o.throwing )
    {
      throw _.err( 'Links cycle at', _.strQuote( o.filePath ) );
    }
    else
    {
      o.result.push( o.filePath );
      o.found.push( o.filePath );
      return o.result;
    }
  }

  o.result.push( o.filePath );
  o.found.push( o.filePath );

  /*
    condition to avoid recursion in stat and overburden
    pathResolveLink does not guarantee reading stat
  */

  if( !o.resolvingIntermediateDirectories && !o.resolvingSoftLink && !o.resolvingTextLink )
  return o.result;

  /* */

  if( o.resolvingIntermediateDirectories )
  {
    o.resolvingIntermediateDirectories = 0;

    let parts = path.split( o.filePath );
    let o2 = _.mapExtend( null, o );
    o2.filePath = '/';

    for( let i = 1; i < parts.length; i++ )
    {
      o2.filePath = path.join( o2.filePath, parts[ i ] );
      o2.stat = null;
      if( self.isLink( o2.filePath ) )
      self.pathResolveLinkChain.body.call( self, o2 );
      else if( i === parts.length - 1 )
      self.pathResolveLinkChain.body.call( self, o2 );
    }

    return o2.result;
  }

  /* */

  if( !o.stat )
  o.stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    resolvingSoftLink : 0,
    sync : 1,
    // resolvingTextLink : 0,
  });
  if( !o.stat )
  {
    o.found.push( o.stat );
    o.result.push( o.stat );

    if( o.result.length > 2 )
    if( o.throwing && !o.allowingMissing )
    {
      debugger;
      throw _.err( 'Does not exist file', _.strQuote( o.filePath ) );
    }

    return o.result;
  }

  // debugger;
  // if( o.result.length > 1 )
  // {
  //   // let stat = self.statRead({ filePath : o.filePath, resolvingSoftLink : 0, resolvingTextLink : 0, throwing : o.throwing });
  //   if( !stat )
  //   {
  //     o.found.push( stat );
  //     o.result.push( stat );
  //     return o.result;
  //   }
  // }

  /* */

  if( o.resolvingSoftLink && o.stat.isSoftLink() )
  {
    let filePath = self.pathResolveSoftLink({ filePath : o.filePath }); /* qqq : implement allowingMissing */
    // _.assert( filePath !== o.filePath );
    if( filePath !== o.filePath )
    {
      if( o.preservingRelative && !path.isAbsolute( filePath ) )
      o.found.push( filePath );

      o.filePath = path.join( o.filePath, filePath )
      o.stat = null;
      return self.pathResolveLinkChain.body.call( self, o );
    }
  }

  /* */

  if( self.usingTextLink )
  if( o.resolvingTextLink && o.stat.isTextLink() )
  {
    let filePath = self.pathResolveTextLink({ filePath : o.filePath });
    // _.assert( filePath !== o.filePath );
    if( filePath !== o.filePath )
    {
      if( o.preservingRelative && !path.isAbsolute( filePath ) )
      o.found.push( filePath );

      o.filePath = path.join( o.filePath, filePath )
      o.stat = null;
      return self.pathResolveLinkChain.body.call( self, o );
    }
  }

  // /* */
  //
  // if( self.usingTextLink )
  // if( o.resolvingTextLink )
  // {
  //   let filePath = self.pathResolveTextLink({ filePath : o.filePath, allowingMissing : true });
  //   if( filePath !== o.filePath )
  //   {
  //     o.filePath = path.join( o.filePath, filePath );
  //     return self.pathResolveLinkChain.body.call( self, o );
  //   }
  // }

  return o.result;
}

pathResolveLinkChain_body.defaults =
{
  hub : null,
  filePath : null,
  resolvingSoftLink : null,
  resolvingTextLink : null,
  throwing : 1,
  allowingMissing : 1,
  preservingRelative : 1,
  resolvingIntermediateDirectories : 0,
  result : null,
  found : null,
  stat : null,
}

// var paths = pathResolveLinkChain_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = pathResolveLinkChain_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

// xxx
//
// function pathResolveLinkChain_body( o )
// {
//   let self = this;
//   let path = self.path;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( _.boolLike( o.resolvingSoftLink ) );
//   _.assert( _.boolLike( o.resolvingTextLink ) );
//
//   let hub = o.hub || self.hub;
//   if( hub && hub !== self && path.isGlobal( o.filePath ) )
//   return hub.pathResolveLinkChain.body.call( hub, o );
//
//   if( _.arrayHas( o.found, o.filePath ) )
//   {
//     o.err = { cycleInLinks : true }; /* xxx */
//     debugger;
//     if( o.throwing )
//     throw _.err( 'Links cycle at', _.strQuote( o.filePath ) );
//     else
//     return o.result;
//   }
//
//   o.result.push( o.filePath );
//   o.found.push( o.filePath );
//
//   if( o.result.length > 1 )
//   {
//     let stat = self.statRead({ filePath : o.filePath, resolvingSoftLink : 0, resolvingTextLink : 0, throwing : o.throwing });
//     if( !stat )
//     {
//       o.found.push( stat );
//       o.result.push( stat );
//       return o.result;
//     }
//   }
//
//   /* */
//
//   if( o.resolvingIntermediateDirectories )
//   {
//     o.resolvingIntermediateDirectories = 0;
//
//     let parts = o.filePath.split( '/' );
//     o.filePath = '/';
//     for( let i = 1; i < parts.length; i++ )
//     {
//       o.filePath = path.join( o.filePath, parts[ i ] );
//       if( self.isLink( o.filePath ) )
//       self.pathResolveLinkChain.body.call( self, o );
//       else if( i === parts.length - 1 )
//       self.pathResolveLinkChain.body.call( self, o );
//     }
//
//     return o.result;
//   }
//
//   /* */
//
//   // {
//   //   let filePath = self.pathResolveHardLink( o.filePath );
//   //   if( filePath !== o.filePath )
//   //   {
//   //     // o.filePath = _.uri.normalize( _.uri.join( o.filePath, filePath ) );
//   //     o.filePath = path.join( o.filePath, filePath );
//   //     return self.pathResolveLinkChain.body.call( self, o );
//   //   }
//   // }
//
//   /* */
//
//   if( o.resolvingSoftLink )
//   {
//     let filePath = self.pathResolveSoftLink({ filePath : o.filePath });
//     if( filePath !== o.filePath || self.isSoftLink( filePath ) )
//     {
//
//       // if( path.isGlobal( filePath ) )
//       // debugger;
//
//       /* if( o.preservingRelative && !_.uri.isAbsolute( filePath ) )
//       {
//         // let prefix = _.uri.join( o.filePath, filePath );
//         let prefix = path.join( o.filePath, filePath );
//         let postfix = '';
//         let last = o.last || o.filePath;
//         if( _.strBegins( last, o.filePath ) )
//         postfix = _.strRemoveBegin( last, o.filePath );
//         o.last = prefix + postfix;
//         // o.result.push( o.last ); // qqq ??? o.O
//         // filePath = _.uri.dir( o.filePath );
//         filePath = path.dir( o.filePath ); // qqq ???
//         if( !self.isLink( filePath ) ) // qqq ???
//         filePath = o.last; // qqq ???
//       }
//       else
//       {
//         // filePath = _.uri.join( o.filePath, filePath );
//         filePath = path.join( o.filePath, filePath );
//       } */
//
//       if( o.preservingRelative && !path.isAbsolute( filePath ) )
//       o.found.push( filePath );
//
//       // o.filePath = _.uri.normalize( filePath );
//       o.filePath = path.join( o.filePath, filePath )
//       return self.pathResolveLinkChain.body.call( self, o );
//     }
//   }
//
//   /* */
//
//   if( self.usingTextLink )
//   if( o.resolvingTextLink )
//   {
//     let filePath = self.pathResolveTextLink({ filePath : o.filePath, allowingMissing : true });
//     if( filePath !== o.filePath )
//     {
//       // o.filePath = _.uri.normalize( _.uri.join( o.filePath, filePath ) );
//       o.filePath = path.join( o.filePath, filePath );
//       return self.pathResolveLinkChain.body.call( self, o );
//     }
//   }
//
//   return o.result;
// }
//
// pathResolveLinkChain_body.defaults =
// {
//   hub : null,
//   filePath : null,
//   resolvingSoftLink : null,
//   resolvingTextLink : null,
//   preservingRelative : 1,
//   resolvingIntermediateDirectories : 0,
//   throwing : 1,
//   result : [],
//   found : []
// }
//
// var paths = pathResolveLinkChain_body.paths = Object.create( null );
//
// paths.filePath = null;
//
// var having = pathResolveLinkChain_body.having = Object.create( null );
//
// having.driving = 0;
// having.aspect = 'body';
// having.hubRedirecting = 0;
//
// xxx

//

let pathResolveLinkChain = _.routineFromPreAndBody( pathResolveLinkChain_pre, pathResolveLinkChain_body );

pathResolveLinkChain.having.aspect = 'entry';

//

function pathResolveLink_body( o )
{
  let self = this;

  _.assert( _.routineIs( self.pathResolveLinkChain.body ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  let o2 = _.mapExtend( null, o );
  o2.found = [];
  o2.result = [];
  o2.resolvingIntermediateDirectories = 0;
  let r = self.pathResolveLinkChain.body.call( self, o2 );
  o.stat = o2.stat;

  if( r[ r.length-1 ] === null )
  r = r[ r.length-2 ];
  else
  r = r[ r.length-1 ];

  _.assert( r === null || _.strIs( r ) );

  return r;
}

pathResolveLink_body.defaults =
{
  hub : null,
  stat : null,
  filePath : null,
  resolvingSoftLink : null,
  resolvingTextLink : null,
  throwing : 1,
  allowingMissing : 1,
  preservingRelative : 1,
  // resolvingIntermediateDirectories : 0, /* qqq : why was it here? */
}

// var paths = pathResolveLink_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = pathResolveLink_body.having = Object.create( null );

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

//

let pathResolveLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, pathResolveLink_body );

pathResolveLink.having.aspect = 'entry';

// --
// record
// --

function _recordFactoryFormEnd( recordContext )
{
  let self = this;
  _.assert( recordContext instanceof _.FileRecordFactory );
  _.assert( arguments.length === 1, 'Expects single argument' );
  return recordContext;
}

//

function _recordFormBegin( record )
{
  let self = this;
  return record;
}

//

function _recordPathForm( record )
{
  let self = this;
  return record;
}

//

function _recordFormEnd( record )
{
  let self = this;
  return record;
}

//

function record( filePath )
{
  let self = this;

  _.assert( arguments.length === 1 );

  if( filePath instanceof _.FileRecord )
  {
    return filePath;
  }

  _.assert( _.strIs( filePath ), () => 'Expects string {-filePath-}, but got ' + _.strType( filePath ) );

  return self.recordFactory().record( filePath );
}

var having = record.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.kind = 'record';

//
// xxx
// function record( filePath, c )
// {
//   let self = this;
//
//   if( filePath instanceof _.FileRecord )
//   {
//     if( arguments[ 1 ] === undefined || _.mapContain( filePath.context, c ) )
//     {
//       return filePath;
//     }
//     else
//     {
//       c = filePath.context.cloneExtending( c );
//       return self.record( filePath.absolute, c );
//     }
//   }
//
//   _.assert( _.strIs( filePath ), 'Expects string {-filePath-}, but got', _.strType( filePath ) );
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//
//   if( c === undefined )
//   c = Object.create( null );
//
//   if( !c.basePath && !c.dirPath && !c.stemPath )
//   {
//     c.basePath = self.path.dir( filePath );
//     c.stemPath = c.basePath;
//   }
//
//   if( !( c instanceof _.FileRecordFactory ) )
//   {
//     // if( !c.filter )
//     // c.filter = _.FileRecordFilter({ fileProvider : self }).form();
//     if( !c.fileProvider )
//     c.fileProvider = self;
//     c = _.FileRecordFactory( c );
//     c.form();
//   }
//
//   _.assert( c.fileProvider === self || c.effectiveFileProvider === self );
//
//   return _.FileRecord( filePath, c );
// }
//
// var having = fileRecord.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
// having.kind = 'record';
//
// //
//
// function records( filePaths, fileRecordOptions )
// {
//   let self = this;
//
//   if( _.strIs( filePaths ) || filePaths instanceof _.FileRecord )
//   filePaths = [ filePaths ];
//
//   _.assert( _.arrayIs( filePaths ), 'Expects array {-filePaths-}, but got', _.strType( filePaths ) );
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//
//   let result = [];
//
//   for( let r = 0 ; r < filePaths.length ; r++ )
//   result[ r ] = self.record( filePaths[ r ], fileRecordOptions );
//
//   return result;
// }
//
// var having = records.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
// having.kind = 'record';
//
// //
//
// function recordsFiltered( filePaths, fileContext )
// {
//   let self = this;
//   let result = self.records( filePaths, fileContext );
//
//   for( let r = result.length-1 ; r >= 0 ; r-- )
//   if( !result[ r ].isActual )
//   result.splice( r, 1 );
//
//   return result;
// }
//
// var having = recordsFiltered.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
// having.kind = 'record';
//
//

// function _recordsSort( o )
// {
//   let self = this;

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
//     let parseOptions =
//     {
//       src : o.sorter,
//       fields : { hardlinks : 1, modified : 1 }
//     }
//     o.sorter = _.strSorterParse( parseOptions );
//   }

//   _.routineOptions( _recordsSort, o );

//   _.assert( _.longIs( o.src ) );
//   _.assert( _.longIs( o.sorter ) );

//   for( let i = 0; i < o.src.length; i++ )
//   {
//     if( !( o.src[ i ] instanceof _.FileRecord ) )
//     throw _.err( '_recordsSort : expects FileRecord instances in src, got:', _.strType( o.src[ i ] ) );
//   }

//   let result = o.src.slice();
//   let sorted = false;

//   for( let i = 0; i < o.sorter.length; i++ )
//   {
//     let sortMethod =  o.sorter[ i ][ 0 ];
//     let sortMethodEnabled =  o.sorter[ i ][ 1 ];

//     if( !sortMethodEnabled )
//     continue;

//     if( result.length === 1 )
//     break;

//     if( sortMethod === 'hardlinks' )
//     {
//       let mostLinkedRecord = _.entityMax( result, ( record ) => record.stat ? record.stat.nlink : 0 ).element;
//       let mostLinks = mostLinkedRecord.stat.nlink;
//       result = _.entityFilter( result, ( record ) =>
//       {
//         if( record.stat && record.stat.nlink === mostLinks )
//         return record;
//       })
//     }
//     else if( sortMethod === 'modified' )
//     {
//       result = _.entityMax( result, ( record ) => record.stat ? record.stat.mtime.getTime() : 0 ).element;
//     }
//     else
//     {
//       throw _.err( '_recordsSort : unknown sort method: ', sortMethod );
//     }

//     sorted = true;

//     result = _.arrayAs( result );
//   }

//   _.assert( sorted, '_recordsSort : files were not sorted, propably all sort methods are disabled, sorter: \n', o.sorter );
//   _.assert( result.length === 1 );

//   return result[ 0 ];
// }

// _recordsSort.defaults =
// {
//   src : null,
//   sorter : null
// }

//

function _recordsSort( o )
{
  let self = this;

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
    let parseOptions =
    {
      src : o.sorter,
      fields : { hardlinks : 1, modified : 1 }
    }
    o.sorter = _.strSorterParse( parseOptions );
  }

  _.routineOptions( _recordsSort, o );

  _.assert( _.longIs( o.src ) );
  _.assert( _.longIs( o.sorter ) );

  for( let i = 0; i < o.src.length; i++ )
  {
    if( !( o.src[ i ] instanceof _.FileRecord ) )
    throw _.err( '_recordsSort : expects FileRecord instances in src, got:', _.strType( o.src[ i ] ) );
  }

  let result = o.src.slice();

  let knownSortMethods = [ 'modified', 'hardlinks' ];

  for( let i = 0; i < o.sorter.length; i++ )
  {
    let sortMethod =  o.sorter[ i ][ 0 ];
    let sortByMax = o.sorter[ i ][ 1 ];

    _.assert( knownSortMethods.indexOf( sortMethod ) !== -1, '_recordsSort : unknown sort method: ', sortMethod );

    let routine = sortByMax ? _.entityMax : _.entityMin;

    if( sortMethod === 'hardlinks' )
    {
      let selectedRecord = routine( result, ( record ) => record.stat ? record.stat.nlink : 0 ).element;
      result = [ selectedRecord ];
    }

    if( sortMethod === 'modified' )
    {
      let selectedRecord = routine( result, ( record ) => record.stat ? record.stat.mtime.getTime() : 0 ).element;
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

_recordsSort.defaults =
{
  src : null,
  sorter : null
}

//

function recordFactory( context )
{
  let self = this;

  context = context || Object.create( null );

  if( context instanceof _.FileRecordFactory )
  {
    // if( !context.formed )
    // context.form();
    return context
  }

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !context.fileProvider )
  context.fileProvider = self;

  _.assert( context.fileProvider === self );

  return _.FileRecordFactory( context )/*.form()*/;
}

var having = recordFactory.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'record';

//

function recordFilter( filter )
{
  let self = this;

  filter = filter || Object.create( null );

  if( filter instanceof _.FileRecordFilter )
  {
    if( !filter.hubFileProvider )
    filter.hubFileProvider = self.hub || self;
    return filter
  }

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !filter.hubFileProvider )
  filter.hubFileProvider = self.hub || self;

  if( !filter.effectiveFileProvider && !( self instanceof _.FileProvider.Hub ) )
  filter.effectiveFileProvider = self;

  return _.FileRecordFilter( filter );
}

var having = recordFilter.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'record';

// --
// stat
// --

let statReadAct = Object.create( null );

var defaults = statReadAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.throwing = 0;
defaults.resolvingSoftLink = null;

// var paths = statReadAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = statReadAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = statReadAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

function statRead_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.routineIs( self.statReadAct ) );

  // if( o.resolvingTextLink )
  // o.filePath = self.path.pathResolveTextLink( o.filePath, true );

  let stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    sync : 1,
    resolvingSoftLink : 0,
  });

  let o2 =
  {
    stat : stat,
    filePath : o.filePath,
    resolvingTextLink : o.resolvingTextLink,
    resolvingSoftLink : o.resolvingSoftLink,
    // resolvingSoftLink : 0, // qqq
    throwing : o.throwing
  }

  self.pathResolveLinkChain( o2 );

  if( o2.result[ o2.result.length - 1 ] === null )
  {
    if( o.throwing )
    {
      debugger;
      _.assert( 0, 'not tested' );
      let err = _.err( 'Failed to resolve' );
      if( o.sync )
      throw err;
      return new _.Consequence().error( err );
    }
    else
    {
      if( o.sync )
      return null;
      return new _.Consequence().give( null );
    }
  }

  // o.filePath = self.pathResolveLink( o2 );
  //
  // if( o.filePath === null )
  // {
  //   if( o.sync )
  //   return null;
  //   return new _.Consequence().give( null );
  // }

  // let o2 = _.mapOnly( o, self.statReadAct.defaults );
  // let result = self.statReadAct( o2 );
  // let result = o2.stat;

  if( o.sync )
  {
    return end( o2.stat );
  }
  else
  {
    let result = new _.Consequence().give( o2.stat );
    return result.ifNoErrorThen( end );
  }

  /* - */

  function end( stat )
  {
    if( stat )
    {
      _.assert( _.routineIs( stat.isTerminal ), 'Stat should have routine isTerminal' );
      _.assert( _.routineIs( stat.isDir ), 'Stat should have routine isDir' );
      _.assert( _.routineIs( stat.isTextLink ), 'Stat should have routine isTextLink' );
      _.assert( _.routineIs( stat.isSoftLink ), 'Stat should have routine isSoftLink' );
      _.assert( _.routineIs( stat.isHardLink ), 'Stat should have routine isHardLink' );
    }
    return stat;
  }

}

_.routineExtend( statRead_body, statReadAct );

statRead_body.defaults.resolvingTextLink = 0;
statRead_body.having.driving = 0;
statRead_body.having.aspect = 'body';

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
 * wTools.fileProvider.statResolvedRead( './existingDir/test.txt' );
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
 * wTools.fileProvider.statResolvedRead( './notExistingFile.txt' );
 * // returns null
 *
 * @example
 * let consequence = wTools.fileProvider.statResolvedRead
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
 * @method statResolvedRead
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) is not a String or instance of wFileRecord.
 * @throws { Exception } If ( o.filePath ) path to a file doesn't exist.
 * @memberof wFileProviderPartial
 */

let statRead = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, statRead_body );

statRead.having.aspect = 'entry';
statRead.having.hubRedirecting = 0;

statRead.defaults.resolvingSoftLink = 0;
statRead.defaults.resolvingTextLink = 0;

//

let statResolvedRead = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, statRead_body );

statResolvedRead.having.aspect = 'entry';
statResolvedRead.having.hubRedirecting = 0;

statResolvedRead.defaults.resolvingSoftLink = null;
statResolvedRead.defaults.resolvingTextLink = null;

//

/**
 * Returns sum of sizes of files in `paths`.
 * @example
 * let path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   textData2 = 'Aenean non feugiat mauris';

   wTools.fileWrite( { filePath : path1, data : textData1 } );
   wTools.fileWrite( { filePath : path2, data : textData2 } );
   let size = wTools.filesSize( [ path1, path2 ] );
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
  let self = this;
  o = o || Object.create( null );

  if( _.strIs( o ) || _.arrayIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1, 'Expects single argument' );

  o.filePath = _.arrayAs( o.filePath );

  let optionsForSize = _.mapExtend( null, o );
  optionsForSize.filePath = o.filePath[ 0 ];

  let result = self.fileSize( optionsForSize );

  for( let p = 1 ; p < o.filePath.length ; p++ )
  {
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

function fileSize_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let stat = self.statResolvedRead( o );

  _.sure( _.objectIs( stat ) );

  return stat.size;
}

_.routineExtend( fileSize_body, statResolvedRead );

// var defaults = fileSize_body.defaults = Object.create( statResolvedRead.defaults );
// var paths = fileSize_body.paths = Object.create( statResolvedRead.paths );
// var having = fileSize_body.having = Object.create( statResolvedRead.having );

var having = fileSize_body.having;

having.driving = 0;
having.aspect = 'body';
having.hubRedirecting = 0;

//

let _fileExistsAct = Object.create( null );

var defaults = _fileExistsAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

// var paths = _fileExistsAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = _fileExistsAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = _fileExistsAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

function fileExistsAct( o )
{
  let self = this;
  let o2 = _.mapExtend( null, o );
  _.assert( fileExistsAct, arguments );
  // _.mapSupplement( o2, self.fileExistsAct.defaults );
  o2.throwing = 0;
  o2.resolvingSoftLink = 0;
  debugger;
  let result = self.statReadAct( o2 );
  _.assert( result === null || _.objectIs( result ) );
  _.assert( arguments.length === 1 );
  return !!result;
}

_.routineExtend( fileExistsAct, _fileExistsAct );

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
 * let consequence = wTools.fileProvider.fileExists
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

function fileExists_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.routineIs( self.fileExistsAct ) );

  // if( o.resolvingTextLink )
  // o.filePath = self.path.pathResolveTextLink( o.filePath, true );

  let o2 = _.mapOnly( o, self.fileExistsAct.defaults );

  return self.fileExistsAct( o2 );
}

_.routineExtend( fileExists_body, fileExistsAct );

// var defaults = fileExists_body.defaults = Object.create( fileExistsAct.defaults );
//
// // defaults.resolvingTextLink = null;
//
// var paths = fileExists_body.paths = Object.create( fileExistsAct.paths );
// var having = fileExists_body.having = Object.create( fileExistsAct.having );

var having = fileExists_body.having;

having.driving = 0;
having.aspect = 'body';

//

let fileExists = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, fileExists_body );

fileExists.having.aspect = 'entry';

// --
// read
// --

let streamReadAct = Object.create( null );

var defaults = streamReadAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.encoding = null;

// var paths = streamReadAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = streamReadAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = streamReadAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

function streamRead_body( o )
{
  let self = this;
  let result;
  let optionsRead = _.mapExtend( null, o );
  delete optionsRead.throwing;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !o.throwing )
  {
    try
    {
      result = self.streamReadAct( optionsRead );
    }
    catch( err )
    {
      return null;
    }
  }
  else
  {
    result = self.streamReadAct( optionsRead );
  }

  return result;
}

var defaults = streamRead_body.defaults = Object.create( streamReadAct.defaults );

defaults.throwing = null;

// var paths = streamRead_body.paths = Object.create( streamReadAct.paths );
var having = streamRead_body.having = Object.create( streamReadAct.having );

having.driving = 0;
having.aspect = 'body';

let streamRead = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, streamRead_body );

streamRead.having.aspect = 'entry';

//

function fileRead_pre( routine, args )
{
  let self = this;
  let o = self._preFilePathScalarWithProviderDefaults.apply( self, arguments );
  // let o = self._preFilePathScalarWithoutProviderDefaults.apply( self, arguments );
  // if( o.verbosity === null )
  // o.verbosity = _.numberClamp( self.verbosity - 4, 0, 9 );
  // self._providerDefaults( o );
  return o;
}

//

let fileReadAct = Object.create( null );

var defaults = fileReadAct.defaults = Object.create( null );

defaults.sync = null;
defaults.filePath = null;
defaults.encoding = null;
defaults.advanced = null;
defaults.resolvingSoftLink = null;

// var paths = fileReadAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = fileReadAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = fileReadAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1 };

//

function fileRead_body( o )
{
  let self = this;
  let result = null;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.encoding ) );

  let encoder = fileRead.encoders[ o.encoding ];

  if( o.resolvingTextLink )
  o.filePath = self.pathResolveTextLink( o.filePath );

  /* exec */

  handleBegin();

  let optionsRead = _.mapOnly( o, self.fileReadAct.defaults );

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
    _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder }) === undefined );

    if( !o.onBegin )
    return;

    let r = o

    debugger;
    _.Consequence.give( o.onBegin, r );
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

    if( o.verbosity >= 4 )
    self.logger.log( ' . Read :', o.filePath );

    o.result = data;

    let r;
    if( o.returningRead )
    r = data;
    else
    r = o;

    if( o.onEnd )
    debugger;
    if( o.onEnd )
    _.Consequence.give( o.onEnd, o );

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
        args : [ stack, '\nfileRead( ', o.filePath, ' )\n', err ],
        usingSourceCode : 0,
        level : 0,
      });
      err = encoder.onError.call( self, { error : err, operation : o, encoder : encoder })
    }
    catch( err2 )
    {
      /* there the simplest output is reqired to avoid recursion */
      console.error( err2 );
      console.error( err.toString() + '\n' + err.stack );
    }

    if( o.onError )
    wConsequence.error( o.onError, err );

    if( o.throwing )
    throw _.err( err );

    return null;
  }

}

var defaults = fileRead_body.defaults = Object.create( fileReadAct.defaults );

defaults.returningRead = 1;
defaults.throwing = null;
defaults.name = null;
defaults.onBegin = null;
defaults.onEnd = null;
defaults.onError = null;
defaults.resolvingTextLink = null;
defaults.verbosity = null;

// var paths = fileRead_body.paths = Object.create( fileReadAct.paths );
var having = fileRead_body.having = Object.create( fileReadAct.having );

having.driving = 0;
having.aspect = 'body';

// debugger;
fileRead_body.encoders = _.FileReadEncoders;
_.assert( _.objectIs( fileRead_body.encoders ) );
// fileRead_body.encoders = Object.create( null );

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
 * // content of tmp/json1.json : {"a" :1, "b" :"s", "c" : [ 1, 3, 4 ] }
   let fileReadOptions =
   {
     sync : 0,
     filePath : 'tmp/json1.json',
     encoding : 'json',

     onEnd : function( err, result )
     {
       console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
     }
   };

   let con = wTools.fileProvider.fileRead( fileReadOptions );

   // or
   fileReadOptions.onEnd = null;
   let con2 = wTools.fileProvider.fileRead( fileReadOptions );

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

let fileRead = _.routineFromPreAndBody( fileRead_pre, fileRead_body );

fileRead.having.aspect = 'entry';
fileRead.having.hubResolving = 1;

//

/**
 * Reads the entire content of a file synchronously.
 * Method returns encoded content of a file.
 * Can accepts `filePath` as first parameters and options as second
 *
 * @example
 * // content of tmp/json1.json : { "a" : 1, "b" : "s", "c" : [ 1, 3, 4 ]}
 let fileReadOptions =
 {
   filePath : 'tmp/json1.json',
   encoding : 'json',

   onEnd : function( err, result )
   {
     console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
   }
 };

 let res = wTools.fileReadSync( fileReadOptions );
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

let fileReadSync = _.routineFromPreAndBody( fileRead.pre, fileRead.body );

fileReadSync.defaults.sync = 1;
fileReadSync.having.aspect = 'entry';

//

function fileReadJson_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  return self.fileRead( o );
}

var defaults = fileReadJson_body.defaults = Object.create( fileRead.defaults );

defaults.sync = 1;
defaults.encoding = 'json';

// var paths = fileReadJson_body.paths = Object.create( fileRead.paths );
var having = fileReadJson_body.having = Object.create( fileRead.having );

having.driving = 0;
having.aspect = 'body';

//

/**
 * Reads a JSON file and then parses it into an object.
 *
 * @example
 * // content of tmp/json1.json : {"a" :1, "b" :"s", "c" :[1, 3, 4]}
 *
 * let res = wTools.fileReadJson( 'tmp/json1.json' );
 * // { a : 1, b : 's', c : [ 1, 3, 4 ] }
 * @param {string} filePath file path
 * @returns {*}
 * @throws {Error} If missed arguments, or passed more then one argument.
 * @method fileReadJson
 * @memberof wFileProviderPartial
 */

let fileReadJson = _.routineFromPreAndBody( fileRead.pre, fileReadJson_body );

fileReadJson.having.aspect = 'entry';

//

function fileReadJs_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  return self.fileRead( o );
}

var defaults = fileReadJs_body.defaults = Object.create( fileRead.defaults );

defaults.sync = 1;
defaults.encoding = 'js.structure';

// var paths = fileReadJs_body.paths = Object.create( fileRead.paths );
var having = fileReadJs_body.having = Object.create( fileRead.having );

having.driving = 0;
having.aspect = 'body';

let fileReadJs = _.routineFromPreAndBody( fileRead.pre, fileReadJs_body );

fileReadJs.having.aspect = 'entry';

//

function _fileInterpret_pre( routine, args )
{
  let self = this;

  _.assert( args.length === 1 );

  let o = args[ 0 ];

  if( self.path.like( o ) )
  o = { filePath : self.path.from( o ) };

  _.routineOptions( routine, o );
  let encoding = o.encoding;
  self._providerDefaults( o );
  o.encoding = encoding;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.strIs( o.filePath ) );

  o.filePath = self.path.normalize( o.filePath );

  return o;
}

//

function _fileInterpret_body( o )
{
  let self = this;
  let result = null;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !o.encoding )
  {
    let ext = self.path.ext( o.filePath );
    for( let e in fileInterpret.encoders )
    {
      let encoder = fileInterpret.encoders[ e ];
      if( !encoder.exts )
      continue;
      if( encoder.forInterpreter !== undefined && !encoder.forInterpreter )
      continue;
      if( _.arrayHas( encoder.exts, ext ) )
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

let fileInterpret = _.routineFromPreAndBody( _fileInterpret_pre, _fileInterpret_body );

fileInterpret.having.aspect = 'entry';

//

let fileHashAct = Object.create( null );

var defaults = fileHashAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.throwing = null;

// var paths = fileHashAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = fileHashAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = fileHashAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

let fileHash_body = ( function()
{
  let Crypto;

  return function fileHash( o )
  {
    let self = this;

    _.assert( arguments.length === 1, 'Expects single argument' );

    if( o.verbosity >= 3 )
    self.logger.log( ' . fileHash :', o.filePath );

    if( Crypto === undefined )
    Crypto = require( 'crypto' );
    let md5sum = Crypto.createHash( 'md5' );

    /* */

    if( o.sync && _.boolLike( o.sync ) )
    {
      let result;
      try
      {
        let stat = self.statResolvedRead({ filePath : o.filePath, sync : 1, throwing : 0 });
        _.sure( !!stat, 'Cant get stats of file ' + _.strQuote( o.filePath ) );
        if( stat.size > self.hashFileSizeLimit )
        throw _.err( 'File is too big ' + _.strQuote( o.filePath ) + ' ' + stat.size + ' > ' + self.hashFileSizeLimit );
        let read = self.fileReadSync( o.filePath );
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
      let con = new _.Consequence();
      let stream = self.streamRead( o.filePath );

      stream.on( 'data', function( d )
      {
        md5sum.update( d );
      });

      stream.on( 'end', function()
      {
        let hash = md5sum.digest( 'hex' );
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

/*
qqq : use routineExtend where possible please
*/

_.routineExtend( fileHash_body, fileHashAct );

// var defaults = fileHash_body.defaults = Object.create( fileHashAct.defaults );

var defaults = fileHash_body.defaults;

defaults.throwing = null;
defaults.verbosity = null;

// var paths = fileHash_body.paths = Object.create( fileHashAct.paths );
// var having = fileHash_body.having = Object.create( fileHashAct.having );

var having = fileHash_body.having;

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
 * let consequence = wTools.fileProvider.fileHash
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

let fileHash = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, fileHash_body );

fileHash.having.aspect = 'entry';

//

function dirRead_pre( routine, args )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 0 || args.length === 1 );

  let o = args[ 0 ] || Object.create( null );

  if( self.path.like( o ) )
  o = { filePath : self.path.from( o ) };

  _.routineOptions( routine, o );
  self._providerDefaults( o );

  _.assert( self.path.isAbsolute( o.filePath ) );

  return o;
}

//

let dirReadAct = Object.create( null );

var defaults = dirReadAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.throwing = null;

// var paths = dirReadAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = dirReadAct.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = dirReadAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

function dirRead_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayHas( [ 'record', 'absolute', 'relative' ], o.outputFormat ) )
  _.assertRoutineOptions( dirRead_body, arguments );

  let o2 = _.mapExtend( null, o );
  delete o2.outputFormat;
  delete o2.basePath;
  o2.filePath = self.path.normalize( o2.filePath );

  let result = self.dirReadAct( o2 );

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

    // let isDir = self.resolvedIsDir( o.filePath ); /* qqq : add test case for this line */

    if( o.outputFormat === 'absolute' )
    result = result.map( function( relative )
    {
      // if( isDir )
      return self.path.join( o.filePath, relative );
      // else
      // return o.filePath;
    });
    else if( o.outputFormat === 'record' )
    result = result.map( function( relative )
    {
      return self.recordFactory({ dirPath : o.filePath, basePath : o.basePath }).record( relative );
    });
    else if( o.basePath )
    result = result.map( function( relative )
    {
      return self.path.relative( o.basePath, self.path.join( o.filePath, relative ) );
    });

    return result;
  }

}

var defaults = dirRead_body.defaults = Object.create( dirReadAct.defaults );

defaults.outputFormat = 'relative';
defaults.basePath = null;
defaults.throwing = 0;

// var paths = dirRead_body.paths = Object.create( dirReadAct.paths );
var having = dirRead_body.having = Object.create( dirReadAct.having );

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
 * wTools.fileProvider.dirRead( './existingDir' );
 * // returns [ 'a.txt', 'b.js', 'c.md' ]
 *
 * @example
 * wTools.fileProvider.dirRead( './notExistingDir' );
 * // returns null
 *
 * * @example
 * wTools.fileProvider.dirRead( './existingEmptyDir' );
 * // returns []
 *
 * @example
 * let consequence = wTools.fileProvider.dirRead
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
 * @method dirRead
 * @throws { Exception } If no arguments provided.
 * @throws { Exception } If ( o.filePath ) path is not a String or instance of FileRecord @see{@link wFileRecord}
 * @throws { Exception } If ( o.filePath ) path doesn't exist.
 * @memberof wFileProviderPartial
 */

let dirRead = _.routineFromPreAndBody( dirRead_pre, dirRead_body );

dirRead.having.aspect = 'entry';

//

function dirReadDirs_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self.dirRead( o );

  result = result.filter( function( path )
  {
    let stat = self.statResolvedRead( path );
    if( stat.isDirectory() )
    return true;
  });

  return result;
}

var defaults = dirReadDirs_body.defaults = Object.create( dirRead.defaults );
// var paths = dirReadDirs_body.paths = Object.create( dirRead.defaults );
var having = dirReadDirs_body.having = Object.create( dirRead.defaults );

having.driving = 0;
having.aspect = 'body';

let dirReadDirs = _.routineFromPreAndBody( dirRead.pre, dirReadDirs_body );

dirReadDirs.having.aspect = 'entry';

//

function dirReadTerminals_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self.dirRead( o );

  result = result.filter( function( path )
  {
    let stat = self.statResolvedRead( path );
    if( !stat.isDirectory() )
    return true;
  });

  return result;

}

var defaults = dirReadTerminals_body.defaults = Object.create( dirRead.defaults );
// var paths = dirReadTerminals_body.paths = Object.create( dirRead.defaults );
var having = dirReadTerminals_body.having = Object.create( dirRead.defaults );

having.driving = 0;
having.aspect = 'body';

let dirReadTerminals = _.routineFromPreAndBody( dirRead.pre, dirReadTerminals_body );

dirReadTerminals.having.aspect = 'entry';

//

function filesFingerprints( files )
{
  let self = this;

  if( _.strIs( files ) || files instanceof _.FileRecord )
  files = [ files ];

  _.assert( _.arrayIs( files ) || _.mapIs( files ) );

  let result = Object.create( null );

  for( let f = 0 ; f < files.length ; f++ )
  {
    let record = self.record( files[ f ] );
    let fingerprint = Object.create( null );

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

/**
 * Check if two paths, file stats or FileRecords are associated with the same file or files with same content.
 * @example
 * let path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     usingTime = true,
     buffer = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { filePath : path2, data : buffer } );

     let sameWithoutTime = wTools.filesAreSame( path1, path2 ); // true

     let sameWithTime = wTools.filesAreSame( path1, path2, usingTime ); // false
   }, 100);
 * @param {string|wFileRecord} ins1 first file to compare
 * @param {string|wFileRecord} ins2 second file to compare
 * @param {boolean} usingTime if this argument sets to true method will additionally check modified time of files, and
    if they are different, method returns false.
 * @returns {boolean}
 * @method filesAreSame
 * @memberof wFileProviderPartial
 */

function filesAreSame_pre( routine, args )
{
  let self = this;
  let o;

  if( args.length === 2 || args.length === 3 )
  {
    o =
    {
      ins1 : args[ 0 ],
      ins2 : args[ 1 ],
      default : args[ 2 ],
    }
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
  }

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.routineOptions( routine, o );

  return o;
}

//

function filesAreSame_body( o )
{
  let self = this;

  o.ins1 = self.record( o.ins1 );
  o.ins2 = self.record( o.ins2 );

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
    return self.pathResolveTextLink( o.ins1 ) === self.pathResolveTextLink( o.ins2 );
  }

  /* hard linked */

  if( _.bigIntIs( o.ins1.stat.ino ) && _.bigIntIs( o.ins2.stat.ino ) )
  if( o.ins1.context.effectiveFileProvider === o.ins2.context.effectiveFileProvider )
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
    let h1 = o.ins1.hashGet();
    let h2 = o.ins2.hashGet();

    _.assert( _.strIs( h1 ) && _.strIs( h2 ) );

    return h1 === h2;
  }
  catch( err )
  {
    return o.default;
  }
}

var defaults = filesAreSame_body.defaults = Object.create( null );

defaults.ins1 = null;
defaults.ins2 = null;
defaults.default = NaN;

// var paths = filesAreSame_body.paths = Object.create( null );

var having = filesAreSame_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.aspect = 'body';

let filesAreSame = _.routineFromPreAndBody( filesAreSame_pre, filesAreSame_body );

filesAreSame.having.aspect = 'entry';

//

/**
 * Return file size in bytes. For symbolic links return false. If onEnd callback is defined, method returns instance
    of wConsequence.
 * @example
 * let path = 'tmp/fileSize/data4',
     bufferData1 = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] ), // size 4
     bufferData2 = Buffer.from( [ 0x07, 0x06, 0x05 ] ); // size 3

   wTools.fileWrite( { filePath : path, data : bufferData1 } );

   let size1 = wTools.fileSize( path );
   console.log(size1); // 4

   let con = wTools.fileSize( {
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

let fileSize = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, fileSize_body );

fileSize.having.aspect = 'entry';

_.assert( fileSize.having.hubRedirecting === 0 );

//

// function isTerminal_body( o )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( o.resolvingSoftLink !== null );
//   _.assert( o.resolvingTextLink !== null );
//
//   let stat = self.statResolvedRead
//   ({
//     filePath : o.filePath,
//     resolvingSoftLink : o.resolvingSoftLink,
//     resolvingTextLink : o.resolvingTextLink,
//   });
//
//   if( !stat )
//   return false;
//
//   if( stat.isSymbolicLink() )
//   return false;
//
//   return stat.isFile();
// }
//
// var defaults = isTerminal_body.defaults = Object.create( null );
//
// defaults.filePath = null;
// defaults.resolvingSoftLink = null;
// defaults.resolvingTextLink = null;
//
// var paths = isTerminal_body.paths = Object.create( null );
//
// paths.filePath = null;
//
// var having = isTerminal_body.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
// having.aspect = 'body';
//
// //
//
// /**
//  * Return True if file at ( filePath ) is an existing terminal.
//  * If file is symbolic link to file or terminal return false.
//  * @example
//  * wTools.isTerminal( './existingDir/' ); // true
//  * @param {string} filePath Tested path string
//  * @returns {boolean}
//  * @method isTerminal
//  * @memberof wFileProviderPartial
//  */
//
// let isTerminal = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isTerminal_body );
//
// isTerminal.having.aspect = 'entry';
//
// //
//
// /**
//  * Return True if file at resolved ( filePath ) is an existing terminal.
//  * If file is symbolic link to file or terminal return false.
//  * @example
//  * wTools.isTerminal( './existingDir/' ); // true
//  * @param {string} filePath Tested path string
//  * @returns {boolean}
//  * @method terminalResolvedIs
//  * @memberof wFileProviderPartial
//  */
//
// let terminalResolvedIs = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isTerminal_body );
//
// terminalResolvedIs.defaults.resolvingSoftLink = 1;
// terminalResolvedIs.defaults.resolvingTextLink = 1;
//
// terminalResolvedIs.having.aspect = 'entry';

//

// function isTerminalAct( o )
// {
//   let self = this;
//
//   _.assertRoutineOptions( isTerminalAct, o );
//
//   let stat = self.statRead( o );
//
//   if( !stat )
//   return false;
//
//   return stat.isFile();
// }
//
// var defaults = isTerminalAct.defaults = Object.create( null );
//
// defaults.filePath = null;
//
// var paths = isTerminalAct.paths = Object.create( null );
//
// paths.filePath = null;
//
// var having = isTerminalAct.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 1;
//
// var operates = isTerminalAct.operates = Object.create( null );
//
// operates.filePath = { pathToRead : 1 }

//

function isTerminal_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.assertRoutineOptions( isTerminal_body, arguments ) );
  _.assert( _.boolLike( o.resolvingSoftLink ) );
  _.assert( _.boolLike( o.resolvingTextLink ) );

  let stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    sync : 1,
    resolvingSoftLink : 0,
  });

  let o2 =
  {
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
    stat : stat,
    throwing : 0
  }

  o.filePath = self.pathResolveLink( o2 );

  if( o.filePath === null )
  return false;

  if( o2.stat === null )
  return false;

  // if( self.isDir( o.filePath ) )
  // return false;

  /* !!! qqq : doublecheck that isSoftLink is not required and add stand-alone test routine */

  // // if( o.resolvingSoftLink )
  // if( self.usingSoftLink )
  // if( self.isSoftLink( o.filePath ) )
  // return false;
  //
  // // if( self.usingTextLink && o.resolvingTextLink )
  // if( self.usingTextLink )
  // if( self.isTextLink( o.filePath ) )
  // return false;

  // if( _.routineIs( self.isTerminalAct ) )
  // return self.isTerminalAct( _.mapOnly( o, self.isTerminalAct.defaults ) );

  // let stat = self.statRead
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : 0,
  //   resolvingTextLink : 0,
  // });

  // if( !stat )
  // return false;

  return o2.stat.isTerminal();
}

var defaults = isTerminal_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

// var paths = isTerminal_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = isTerminal_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.hubResolving = 1;

var operates = isTerminal_body.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

// var defaults = isTerminal_body.defaults = Object.create( isTerminalAct.defaults );
//
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;
//
// var paths = isTerminal_body.paths = Object.create( isTerminalAct.paths );
// var having = isTerminal_body.having = Object.create( isTerminalAct.having );
//
// having.driving = 0;
// having.hubResolving = 1;

//

/**
 * Returns true if file at ( filePath ) is an existing regular terminal file.
 * @example
 * wTools.isTerminal( './existingDir/test.txt' ); // true
 * @param {string} filePath Path string
 * @returns {boolean}
 * @method isTerminal
 * @memberof wFileProviderPartial
 */

let isTerminal = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isTerminal_body );

isTerminal.having.aspect = 'entry';

//

/**
 * Returns true if resolved file at ( filePath ) is an existing regular terminal file.
 * @example
 * wTools.isTerminal( './existingDir/test.txt' ); // true
 * @param {string} filePath Path string
 * @returns {boolean}
 * @method resolvedIsTerminal
 * @memberof wFileProviderPartial
 */

let resolvedIsTerminal = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isTerminal_body );

resolvedIsTerminal.defaults.resolvingSoftLink = null;
resolvedIsTerminal.defaults.resolvingTextLink = null;

resolvedIsTerminal.having.aspect = 'entry';

//
//
// function isDirAct( o )
// {
//   let self = this;
//
//   _.assertRoutineOptions( isDirAct, o );
//
//   let stat = self.statRead( o );
//
//   if( !stat )
//   return false;
//
//   return stat.isDirectory();
// }
//
// var defaults = isDirAct.defaults = Object.create( null );
//
// defaults.filePath = null;
//
// var paths = isDirAct.paths = Object.create( null );
//
// paths.filePath = null;
//
// var having = isDirAct.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 1;
//
// var operates = isDirAct.operates = Object.create( null );
//
// operates.filePath = { pathToRead : 1 }

//

function isDir_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.assertRoutineOptions( isDir_body, arguments ) );
  _.assert( _.boolLike( o.resolvingSoftLink ) );
  _.assert( _.boolLike( o.resolvingTextLink ) );

  o.filePath = self.pathResolveLink
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  // // if( self.isDir( o.filePath ) )
  // // return false;
  //
  // // if( o.resolvingSoftLink )
  // if( self.usingSoftLink )
  // if( self.isSoftLink( o.filePath ) )
  // return false;
  //
  // // if( self.usingTextLink && o.resolvingTextLink )
  // if( self.usingTextLink )
  // if( self.isTextLink( o.filePath ) )
  // return false;

  // if( _.routineIs( self.isDirAct ) )
  // return self.isDirAct( _.mapOnly( o, self.isDirAct.defaults ) );

  let stat = self.statRead
  ({
    filePath : o.filePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  });

  if( !stat )
  return false;

  return stat.isDir();
}

var defaults = isDir_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

// var paths = isDir_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = isDir_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

var operates = isDir_body.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

// _.routineExtend( isDir_body, isTerminal_body );

// {
//
//   xxx
//
//   // let self = this;
//   //
//   // _.assert( arguments.length === 1, 'Expects single argument' );
//   // _.assert( o.resolvingSoftLink !== null );
//   // _.assert( o.resolvingTextLink !== null );
//   //
//   // let stat = self.statResolvedRead
//   // ({
//   //   filePath : o.filePath,
//   //   resolvingSoftLink : o.resolvingSoftLink,
//   //   resolvingTextLink : o.resolvingTextLink,
//   // });
//   //
//   // if( !stat )
//   // return false;
//   //
//   // if( stat.isSymbolicLink() )
//   // return false;
//   //
//   // return stat.isDirectory();
//
// }
//
// _.routineExtend( isDir_body, isTerminal_body );
//
// // var defaults = isDir_body.defaults = Object.create( isTerminal_body.defa );
//
// defaults.filePath = null;
// defaults.resolvingSoftLink = null;
// defaults.resolvingTextLink = null;
//
// var paths = isDir_body.paths = Object.create( null );
//
// paths.filePath = null;
//
// var having = isDir_body.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
// having.aspect = 'body';

//

/**
 * Return True if file at ( filePath ) is an existing directory.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.isDir( './existingDir/' ); // true
 * @param {string} filePath Tested path string
 * @returns {boolean}
 * @method isDir
 * @memberof wFileProviderPartial
 */

let isDir = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isDir_body );

isDir.having.aspect = 'entry';

//

/**
 * Return True if file at resolved ( filePath ) is an existing directory.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.isDir( './existingDir/' ); // true
 * @param {string} filePath Tested path string
 * @returns {boolean}
 * @method resolvedIsDir
 * @memberof wFileProviderPartial
 */

let resolvedIsDir = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isDir_body );

resolvedIsDir.defaults.resolvingSoftLink = null;
resolvedIsDir.defaults.resolvingTextLink = null;

resolvedIsDir.having.aspect = 'entry';

//

function isTextLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.assertRoutineOptions( isTextLink_body, arguments ) );
  _.assert( _.boolLike( o.resolvingSoftLink ) );
  // _.assert( _.boolLike( o.resolvingTextLink ) );

  let stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    sync : 1,
    resolvingSoftLink : 0,
  });

  let o2 =
  {
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : 0,
    stat : stat,
    throwing : 0
  }

  o.filePath = self.pathResolveLink( o2 );

  if( o.filePath === null )
  return false;

  if( o2.stat === null )
  return false;

  return o2.stat.isTextLink();

  // o.filePath = self.pathResolveLink
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : o.resolvingSoftLink,
  //   resolvingTextLink : 0,
  //   // resolvingTextLink : o.resolvingTextLink,
  // });

  // let stat = self.statRead
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : 0,
  //   resolvingTextLink : 0,
  // });

  // if( !stat )
  // return false;

  // return stat.isTextLink();
}

var defaults = isTextLink_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;

// var paths = isTextLink_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = isTextLink_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.hubResolving = 1;

var operates = isTextLink_body.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

let isTextLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isTextLink_body );

isTextLink.defaults.resolvingSoftLink = 0;
// isTextLink.defaults.resolvingTextLink = 0;

isTextLink.having.aspect = 'entry';

//

let resolvedIsTextLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isTextLink_body );

resolvedIsTextLink.defaults.resolvingSoftLink = null;
// resolvedIsTextLink.defaults.resolvingTextLink = null;

resolvedIsTextLink.having.aspect = 'entry';

// function isTextLink_body( filePath )
// {
//   let self = this;
//   let path = self.path;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   // filePath = path.normalize( filePath );
//   // let result = self.isTextLinkAct( filePath );
//   // return result;
//
//   let stat = self.statRead( filePath );
//
//   if( !stat )
//   return false;
//
//   return stat.isTextLink();
// }
//
// var having = isTextLink.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;

// //
//
// /**
//  * Return True if `filePath` is a symbolic link.
//  * @param filePath
//  * @returns {boolean}
//  * @method isSoftLinkAct
//  * @memberof wFileProviderPartial
//  */
//
// function isSoftLinkAct( filePath )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   if( !self.fileExists( filePath ) )
//   return false;
//
//   let stat = self.statResolvedRead
//   ({
//     filePath : filePath,
//     resolvingSoftLink : 0,
//     resolvingTextLink : 0,
//   });
//
//   if( !stat )
//   return false;
//
//   return stat.isSymbolicLink();
// }
//
// var having = isSoftLinkAct.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
//
// var operates = isSoftLinkAct.operates = Object.create( null );
//
// operates.filePath = { pathToRead : 1 }

//

/**
 * Return True if `filePath` is a symbolic link.
 * @param filePath
 * @returns {boolean}
 * @method isSoftLink
 * @memberof wFileProviderPartial
 */

function isSoftLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.assertRoutineOptions( isSoftLink_body, arguments ) );
  // _.assert( _.boolLike( o.resolvingSoftLink ) );
  _.assert( _.boolLike( o.resolvingTextLink ) );

  let stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    sync : 1,
    resolvingSoftLink : 0,
  });

  let o2 =
  {
    filePath : o.filePath,
    resolvingSoftLink : 0,
    resolvingTextLink : o.resolvingTextLink,
    stat : stat,
    throwing : 0
  }

  o.filePath = self.pathResolveLink( o2 );

  if( o.filePath === null )
  return false;

  if( o2.stat === null )
  return false;

  return o2.stat.isSoftLink()

  // o.filePath = self.pathResolveLink
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : 0,
  //   // resolvingSoftLink : o.resolvingSoftLink,
  //   resolvingTextLink : o.resolvingTextLink,
  // });

  // let stat = self.statRead
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : 0,
  //   resolvingTextLink : 0,
  // });

  // if( !stat )
  // return false;

  // return stat.isSoftLink();
}

var defaults = isSoftLink_body.defaults = Object.create( null );

defaults.filePath = null;
// defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

// var paths = isSoftLink_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = isSoftLink_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.hubResolving = 1;

var operates = isSoftLink_body.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

let isSoftLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isSoftLink_body );

// isSoftLink.defaults.resolvingSoftLink = 0;
isSoftLink.defaults.resolvingTextLink = 0;

isSoftLink.having.aspect = 'entry';

//

let resolvedIsSoftLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isSoftLink_body );

// resolvedIsSoftLink.defaults.resolvingSoftLink = null;
resolvedIsSoftLink.defaults.resolvingTextLink = null;

resolvedIsSoftLink.having.aspect = 'entry';

// //
//
// function isSoftLink( filePath )
// {
//   let self = this;
//   let path = self.path;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   // filePath = path.normalize( filePath );
//   // let result = self.isSoftLinkAct( filePath );
//   // return result;
//   // debugger;
//
//   let stat = self.statRead( filePath );
//   if( !stat )
//   return false;
//   return stat.isSoftLink();
// }
//
// var having = isSoftLink.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;

// //
//
// /**
//  * Return True if file at `filePath` is a hard link.
//  * @param filePath
//  * @returns {boolean}
//  * @method isHardLinkAct
//  * @memberof wFileProviderPartial
//  */
//
// function isHardLinkAct( filePath )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   let stat = self.statRead
//   ({
//     filePath : filePath,
//     resolvingSoftLink : 0,
//     resolvingTextLink : 0,
//   });
//
//   if( !stat )
//   return false;
//
//   return stat.nlink >= 2;
// }
//
// var having = isHardLinkAct.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
//
// var operates = isHardLinkAct.operates = Object.create( null );
//
// operates.filePath = { pathToRead : 1 }

//

/**
 * Return True if file at `filePath` is a hard link.
 * @param filePath
 * @returns {boolean}
 * @method isHardLink
 * @memberof wFileProviderPartial
 */

function isHardLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.assertRoutineOptions( isHardLink_body, arguments ) );
  _.assert( _.boolLike( o.resolvingSoftLink ) );
  _.assert( _.boolLike( o.resolvingTextLink ) );

  let stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    sync : 1,
    resolvingSoftLink : 0,
  });

  let o2 =
  {
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
    stat : stat,
    throwing : 0
  }

  o.filePath = self.pathResolveLink( o2 );

  if( o.filePath === null )
  return false;

  if( o2.stat === null )
  return false;

  return o2.stat.isHardLink();

  // o.filePath = self.pathResolveLink
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : o.resolvingSoftLink,
  //   resolvingTextLink : o.resolvingTextLink,
  // });

  // let stat = self.statRead
  // ({
  //   filePath : o.filePath,
  //   resolvingSoftLink : 0,
  //   resolvingTextLink : 0,
  // });

  // if( !stat )
  // return false;

  // return stat.isHardLink();
}

var defaults = isHardLink_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

// var paths = isHardLink_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = isHardLink_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;
having.hubResolving = 1;

var operates = isHardLink_body.operates = Object.create( null );

operates.filePath = { pathToRead : 1 }

//

let isHardLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isHardLink_body );

isHardLink.defaults.resolvingSoftLink = 0;
isHardLink.defaults.resolvingTextLink = 0;

isHardLink.having.aspect = 'entry';

//

let resolvedIsHardLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isHardLink_body );

resolvedIsHardLink.defaults.resolvingSoftLink = null;
resolvedIsHardLink.defaults.resolvingTextLink = null;

resolvedIsHardLink.having.aspect = 'entry';

// function isHardLink( filePath )
// {
//   let self = this;
//   let path = self.path;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   // filePath = path.normalize( filePath );
//   // let result = self.isHardLinkAct( filePath );
//   // return result;
//
//   debugger;
//   let stat = self.statRead( filePath );
//
//   if( !stat )
//   return false;
//
//   return stat.isTextLink();
// }
//
// var having = isHardLink.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;

//

function isLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = false;

  if( o.resolvingSoftLink && o.resolvingTextLink )
  return result;

  /* let stat = self.statRead
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  if( !stat )
  return result;

  result = stat.isLink(); */

  let stat = self.statReadAct
  ({
    filePath : o.filePath,
    throwing : 0,
    sync : 1,
    resolvingSoftLink : 0,
  });

  let o2 =
  {
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
    stat : stat,
    throwing : 0
  }

  o.filePath = self.pathResolveLink( o2 );

  if( o.filePath === null )
  return result;

  if( o2.stat === null )
  return result;

  result = o2.stat.isLink();

  // if( !o.resolvingSoftLink && !result )
  // result = stat.isSoftLink();
  //
  // if( !o.resolvingTextLink && !result && o.usingTextLink )
  // result = stat.isTextLink();

  // if( !o.resolvingSoftLink  )
  // {
  //   result = self.isSoftLink( o.filePath );
  // }
  //
  // if( o.usingTextLink && !o.resolvingTextLink )
  // {
  //   if( !result )
  //   result = self.isTextLink( o.filePath );
  // }

  return result;
}

var defaults = isLink_body.defaults = Object.create( null );

defaults.filePath = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;
defaults.usingTextLink = 0;

// var paths = isLink_body.paths = Object.create( null );
//
// paths.filePath = null;

var having = isLink_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.aspect = 'body';
having.driving = 0;

let isLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isLink_body );

isLink.having.aspect = 'entry';

let resolvedIsLink = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, isLink_body );

resolvedIsLink.defaults.resolvingSoftLink = null;
resolvedIsLink.defaults.resolvingTextLink = null;

resolvedIsLink.having.aspect = 'entry';

//

/**
 * Returns True if file at ( filePath ) is an existing empty directory, otherwise returns false.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.fileProvider.dirIsEmpty( './existingEmptyDir/' ); // true
 * @param {string} filePath - Path to the directory.
 * @returns {boolean}
 * @method dirIsEmpty
 * @memberof wFileProviderPartial
 */

function dirIsEmpty( filePath )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( self.isDir( filePath ) )
  return !self.dirRead( filePath ).length;

  return false;
}

var having = dirIsEmpty.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function resolvedDirIsEmpty( filePath )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( self.resolvedIsDir( filePath ) )
  return !self.dirRead( filePath ).length;

  return false;
}

var having = resolvedDirIsEmpty.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

// //
//
// function isTextLinkAct( filePath )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   if( !self.usingTextLink )
//   return false;
//
//   let result = self._pathResolveTextLink( filePath );
//
//   return !!result.resolved;
// }
//
// var having = isTextLinkAct.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
//
// var operates = isTextLinkAct.operates = Object.create( null );
//
// operates.filePath = { pathToRead : 1 }

// --
// write
// --

let streamWriteAct = Object.create( null );

var defaults = streamWriteAct.defaults = Object.create( null );

defaults.filePath = null;

// var paths = streamWriteAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = streamWriteAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = streamWriteAct.operates = Object.create( null );

operates.filePath = { pathToWrite : 1 }

//

function _streamWrite_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let o2 = _.mapExtend( null, o );

  return self.streamWriteAct( o2 );
}

var defaults = _streamWrite_body.defaults = Object.create( streamWriteAct.defaults );
// var paths = _streamWrite_body.paths = Object.create( streamWriteAct.paths );
var having = _streamWrite_body.having = Object.create( streamWriteAct.having );

having.driving = 0;
having.aspect = 'body';

let streamWrite = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, _streamWrite_body );

streamWrite.having.aspect = 'entry';

//

let fileWriteAct = Object.create( null );

var defaults = fileWriteAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;
defaults.data = '';
defaults.encoding = 'original.type';
defaults.writeMode = 'rewrite';

// var paths = fileWriteAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = fileWriteAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = fileWriteAct.operates = Object.create( null );

operates.filePath = { pathToWrite : 1 }

//

function fileWrite_pre( routine, args )
{
  let self = this;
  let o;

  if( args[ 1 ] !== undefined )
  {
    o = { filePath : args[ 0 ], data : args[ 1 ] };
    _.assert( args.length === 2 );
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
    _.assert( _.objectIs( o ), 'Expects 2 arguments {-o.filePath-} and {-o.data-} to write, or single options map' );
  }

  _.assert( o.data !== undefined, 'Expects defined {-o.data-}' );
  _.routineOptions( routine, o );
  self._providerDefaults( o );
  _.assert( _.strIs( o.filePath ), 'Expects string {-o.filePath-}' );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return o;
}

//

function fileWrite_body( o )
{
  let self = this;
  let path = self.path;

  o.encoding = o.encoding || self.encoding;

  let encoder = self.fileWrite.encoders[ o.encoding ];

  let o2 = _.mapOnly( o, self.fileWriteAct.defaults );

  if( encoder && encoder.onBegin )
  _.sure( encoder.onBegin.call( self, { operation : o2, encoder : encoder, data : o2.data } ) === undefined );

  _.assert( arguments.length === 1, 'Expects single argument' );

  // debugger;
  // if( !path.isSafe( o.filePath, o.safe ) )
  if( !path.isSafe( o.filePath, self.safe ) )
  {
    debugger;
    throw path.ErrorNotSafe( 'Writing', o.filePath, o.safe );
  }

  log();

  /* makingDirectory */

  if( o.makingDirectory )
  {
    self.dirMakeForFile( o.filePath );
  }

  let terminateLink = !self.resolvingSoftLink && self.isSoftLink( o.filePath );

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
    _.assert( _.strIs( readData ), 'not implemented for:', _.strType( readData ) );

    if( o.writeMode === 'append' )
    {
      if( _.strIs( writeData ) )
      o2.data = _.strJoin([ readData, writeData ]);
      else
      o2.data = _.bufferJoin( readData, writeData )
    }
    else if( o.writeMode === 'prepend' )
    {
      if( _.strIs( writeData ) )
      o2.data = _.strJoin([ writeData, readData ]);
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

  let result = self.fileWriteAct( o2 );

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

var defaults = fileWrite_body.defaults = Object.create( fileWriteAct.defaults );

defaults.verbosity = null;
defaults.makingDirectory = 1;
defaults.purging = 0;

// var paths = fileWrite_body.paths = Object.create( fileWriteAct.paths );
var having = fileWrite_body.having = Object.create( fileWriteAct.having );

having.driving = 0;
having.aspect = 'body';

// fileWrite_body.encoders = Object.create( null );
fileWrite_body.encoders = _.FileWriteEncoders;
_.assert( _.objectIs( fileWrite_body.encoders ) );

//

/**
 * Writes data to a file. `data` can be a string or a buffer. Creating the file if it does not exist yet.
 * Returns wConsequence instance.
 * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
   exist, it's created. Method can accept two parameters : string `filePath` and string\buffer `data`, or single
   argument : options object, with required 'filePath' and 'data' parameters.
 * @example
 *
    let data = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      options =
      {
        filePath : 'tmp/sample.txt',
        data : data,
        sync : false,
      };
    let con = wTools.fileWrite( options );
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

let fileWrite = _.routineFromPreAndBody( fileWrite_pre, fileWrite_body );

fileWrite.having.aspect = 'entry';

_.assert( _.mapIs( fileWrite.encoders ) );

//

function _fileAppend_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let o2 = _.mapOnly( o, self.fileWriteAct.defaults );
  return self.fileWrite( o );
}

var defaults = _fileAppend_body.defaults = Object.create( fileWrite.defaults );

defaults.writeMode = 'append';

// var paths = _fileAppend_body.paths = Object.create( fileWrite.paths );
var having = _fileAppend_body.having = Object.create( fileWrite.having );

having.driving = 0;
having.aspect = 'body';

let fileAppend = _.routineFromPreAndBody( fileWrite_pre, _fileAppend_body );

fileAppend.having.aspect = 'entry';

//

function _fileWriteJson_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  /* stringify */

  let originalData = o.data;
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

    // let parsedData = o.jsLike ? _.exec( o.data ) : JSON.parse( o.data );
    // _.assert( _.entityEquivalent( parsedData, originalData ), 'not identical' );

  }
  catch( err )
  {

    // debugger;
    self.logger.log( '-' );
    self.logger.error( 'JSON:' );
    self.logger.error( _.toStr( o.data, { levels : 999 } ) );
    self.logger.log( '-' );
    throw _.err( 'Cant convert JSON\n', err );
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

// var paths = _fileWriteJson_body.paths = Object.create( fileWrite.paths );
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
 * let fileProvider = _.FileProvider.Default();
 * let fs = require('fs');
   let data = { a : 'hello', b : 'world' },
   let con = fileProvider.fileWriteJson( 'tmp/sample.json', data );
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

let fileWriteJson = _.routineFromPreAndBody( fileWrite_pre, _fileWriteJson_body );

fileWriteJson.having.aspect = 'entry';

//

let fileWriteJs = _.routineFromPreAndBody( fileWrite_pre, _fileWriteJson_body );

var defaults = fileWriteJs.defaults;

defaults.jsLike = 1;

var having = fileWriteJs.having;

having.driving = 0;
having.aspect = 'body';

//

function fileTouch_pre( routine, args )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ];

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

  _.routineOptions( routine, o );
  self._providerDefaults( o );
  _.assert( _.strIs( o.filePath ), 'Expects string {-o.filePath-}, but got', _.strType( o.filePath ) );

  return o;
}

//

function fileTouch_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // let stat = self.statResolvedRead( o.filePath );
  // if( stat )
  if( self.fileExists( o.filePath ) )
  {
    let stat = self.statResolvedRead( o.filePath );
    if( !self.resolvedIsTerminal( o.filePath ) )
    {
      throw _.err( o.filePath, 'is not terminal' );
      return null;
    }
    o.data = self.fileRead({ filePath : o.filePath, encoding : 'original.type' });
  }
  else
  {
    o.data = '';
  }

  // o.data = stat ? self.fileRead({ filePath : o.filePath, encoding : 'original.type' }) : '';
  self.fileWrite( o );

  return self;
}

var defaults = fileTouch_body.defaults = Object.create( fileWrite.defaults );

defaults.data = null;

// var paths = fileTouch_body.paths = Object.create( fileWrite.paths );
var having = fileTouch_body.having = Object.create( fileWrite.having );

having.driving = 0;
having.aspect = 'body';

//

let fileTouch = _.routineFromPreAndBody( fileTouch_pre, fileTouch_body );

fileTouch.having.aspect = 'entry';

//

let fileTimeSetAct = Object.create( null );

var defaults = fileTimeSetAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.atime = null;
defaults.mtime = null;

// var paths = fileTimeSetAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = fileTimeSetAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = fileTimeSetAct.operates = Object.create( null );

operates.filePath = { pathToWrite : 1 }

//

function _fileTimeSet_pre( routine, args )
{
  let self = this;
  let o;

  if( args.length === 3 )
  o =
  {
    filePath : args[ 0 ],
    atime : args[ 1 ],
    mtime : args[ 2 ],
  }
  else if( args.length === 2 ) /* qqq : tests required */
  {
    let stat = args[ 1 ];
    if( _.strIs( stat ) )
    stat = self.statResolvedRead({ filePath : stat, sync : 1, throwing : 1 })
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

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.routineOptions( routine, o );

  return o;
}

//

function _fileTimeSet_body( o )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self.fileTimeSetAct( o );
}

var defaults = _fileTimeSet_body.defaults = Object.create( fileTimeSetAct.defaults );
// var paths = _fileTimeSet_body.paths = Object.create( fileTimeSetAct.paths );
var having = _fileTimeSet_body.having = Object.create( fileTimeSetAct.having );

having.driving = 0;
having.aspect = 'body';

//

let fileTimeSet = _.routineFromPreAndBody( _fileTimeSet_pre, _fileTimeSet_body );

fileTimeSet.having.aspect = 'entry';

//

let fileDeleteAct = Object.create( null );

var defaults = fileDeleteAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

// var paths = fileDeleteAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = fileDeleteAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = fileDeleteAct.operates = Object.create( null );

operates.filePath = { pathToWrite : 1 }

//

function fileDelete_body( o )
{
  let self = this;
  let path = self.path;
  let result = null;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.numberIs( o.safe ) );

  // logger.log( 'fileDelete', o.filePath ); debugger;

  if( _.arrayIs( o.filePath ) )
  {
    if( o.sync )
    {
      for( let f = 0 ; f < o.filePath.length ; f++ )
      {
        let o2 = _.mapExtend( null, o );
        o2.filePath = o.filePath[ f ];
        fileDelete_body.call( self, o2 );
      }
      return;
    }
    else
    {
      let con = new _.Consequence().give( null );
      let cons = [];
      for( let f = 0 ; f < o.filePath.length ; f++ )
      {
        let o2 = _.mapExtend( null, o );
        o2.filePath = o.filePath[ f ];
        cons[ f ] = fileDelete_body.call( self, o2 );
      }
      con.andThen( cons );
      return con;
    }
  }

  /* is safe */

  o.filePath = self.pathResolveLinkChain
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  _.assert( path.s.allAreAbsolute( o.filePath ) );
  if( !path.s.allAreSafe( o.filePath, o.safe ) )
  {
    debugger;
    throw path.ErrorNotSafe( 'Deleting', o.filePath, o.safe );
  }

  /* act */

  act( o.filePath[ 0 ] );

  return result;

  /* */

  function act( filePath )
  {

    let o2 = _.mapExtend( null, o );

    o2.filePath = filePath;

    delete o2.throwing;
    delete o2.verbosity;
    delete o2.resolvingSoftLink;
    delete o2.resolvingTextLink;
    delete o2.safe;

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
    result.doThen( function( err, arg )
    {
      log( !err );
      if( err )
      {
        if( o.throwing )
        throw err;
        return null;
      }
      return arg;
    });

  }

  /* */

  function log( ok )
  {
    if( !( o.verbosity >= 2 ) )
    return;
    if( ok )
    self.logger.log( ' - fileDelete ' + o.filePath );
    else
    self.logger.log( ' ! failed fileDelete ' + o.filePath );
  }

}

var defaults = fileDelete_body.defaults = Object.create( fileDeleteAct.defaults );

defaults.throwing = null;
defaults.verbosity = null;
defaults.safe = null;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

// var paths = fileDelete_body.paths = Object.create( fileDeleteAct.paths );
var having = fileDelete_body.having = Object.create( fileDeleteAct.having );

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
 * let consequence = wTools.fileProvider.fileDelete
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

let fileDelete = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, fileDelete_body );

fileDelete.having.aspect = 'entry';

let fileResolvedDelete = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, fileDelete_body, 'fileResolvedDelete' );

fileResolvedDelete.having.aspect = 'entry';
fileResolvedDelete.defaults.resolvingSoftLink = null;
fileResolvedDelete.defaults.resolvingTextLink = null;

//

let dirMakeAct = Object.create( null );

dirMakeAct.defaults =
{
  filePath : null,
  sync : null,
}

// var paths = dirMakeAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = dirMakeAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = dirMakeAct.operates = Object.create( null );

operates.filePath = { pathToWrite : 1 }

//

function _dirMake_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( path.isNormalized( o.filePath ) );

  /* qqq : do similar thing */
  // let stat = self.statResolvedRead( o.filePath );
  // if( stat )
  if( self.fileExists( o.filePath ) )
  {

    let stat = self.statResolvedRead( o.filePath );
    if( stat.isFile() )
    if( o.rewritingTerminal )
    self.fileDelete( o.filePath );
    else
    return handleError( _.err( 'Cant rewrite terminal file', _.strQuote( o.filePath ), 'by directory file.' ) );

    if( stat.isDirectory() )
    {
      if( !o.recursive  )
      return handleError( _.err( 'File already exists:', _.strQuote( o.filePath ) ) );
      else
      return o.sync ? undefined : new _.Consequence().give( null );
    }

  }

  // let exists = !!self.statResolvedRead( path.dir( o.filePath ) );
  let exists = self.fileExists( path.dir( o.filePath ) );

  if( !o.recursive && !exists )
  return handleError( _.err( 'Directory', _.strQuote( o.filePath ), ' doesn\'t exist!. Use {-o.recursive-} option to create it.' ) );

  let parts = [ o.filePath ];
  let dir = o.filePath;

  if( !exists )
  while( !exists )
  {
    dir = path.dir( dir );

    if( dir === '/' )
    break;

    // exists = !!self.statResolvedRead( dir );
    exists = self.fileExists( dir );

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
    for( let i = 0; i < parts.length; i++ )
    onPart.call( self, parts[ i ] );
  }
  else
  {
    let con = new _.Consequence().give( null );
    for( let i = 0; i < parts.length; i++ )
    con.ifNoErrorThen( _.routineSeal( self, onPart, [ parts[ i ] ] ) );

    return con;
  }

  /* */

  function onPart( filePath )
  {
    let self = this;
    let o2 = _.mapOnly( o, self.dirMakeAct.defaults );
    o2.filePath = filePath;
    return self.dirMakeAct( o2 );
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

var defaults = _dirMake_body.defaults = Object.create( dirMakeAct.defaults );

defaults.recursive = 1;
defaults.rewritingTerminal = 1;

// var paths = _dirMake_body.paths = Object.create( dirMakeAct.paths );
var having = _dirMake_body.having = Object.create( dirMakeAct.having );

having.driving = 0;
having.aspect = 'body';

let dirMake = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, _dirMake_body );

dirMake.having.aspect = 'entry';

//

function _dirMakeForFile_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  o.filePath = self.path.dir( o.filePath );

  return self.dirMake( o );
}

var defaults = _dirMakeForFile_body.defaults = Object.create( dirMake.defaults );

defaults.recursive = 1;

// var paths = _dirMakeForFile_body.paths = Object.create( dirMake.paths );
var having = _dirMakeForFile_body.having = Object.create( dirMake.having );

having.driving = 0;
having.aspect = 'body';

let dirMakeForFile = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, _dirMakeForFile_body );

dirMakeForFile.having.aspect = 'entry';

// --
// link
// --

function _link_pre( routine, args )
{
  let self = this;
  let o = self._preSrcDstPathWithProviderDefaults.apply( self, arguments );
  _.mapSupplementNulls( o, routine.defaults );
  return o;

  // let self = this;
  // let o;
  //
  // if( args.length === 2 )
  // {
  //   o =
  //   {
  //     dstPath : args[ 0 ],
  //     srcPath : args[ 1 ],
  //   }
  //   _.assert( args.length === 2 );
  // }
  // else
  // {
  //   o = args[ 0 ];
  //   _.assert( args.length === 1 );
  // }
  //
  // _.routineOptions( routine, o );
  //
  // if( o.verbosity === null )
  // o.verbosity = _.numberClamp( self.verbosity - 3, 0, 9 );
  //
  // self._providerDefaults( o );
  // _.mapSupplementNulls( o, routine.defaults );
  //
  // _.assert( o.filePaths === undefined );
  //
  // if( _.longIs( o.dstPath ) )
  // {
  //   o.dstPath = o.dstPath.map( ( dstPath ) => self.path.from( dstPath ) );
  //   o.dstPath = self.path.s.normalize( o.dstPath );
  // }
  // else
  // {
  //   o.dstPath = self.path.from( o.dstPath );
  //   o.dstPath = self.path.normalize( o.dstPath );
  // }
  //
  // if( o.srcPath )
  // {
  //   o.srcPath = self.path.from( o.srcPath );
  //   o.srcPath = self.path.normalize( o.srcPath );
  // }
  //
  // // if( o.verbosity )
  // // self.logger.log( routine.name, ':', o.dstPath + ' <- ' + o.srcPath );
  //
  // return o;
}

//

function _linkMultiple( o, link )
{
  let self = this;

  if( o.dstPath.length < 2 )
  return o.sync ? true : new _.Consequence().give( true );

  _.assert( !!o );
  _.assert( _.strIs( o.srcPath ) || o.srcPath === null );
  _.assert( _.strIs( o.sourceMode ) || _.longIs( o.sourceMode ) );

  let needed = 0;
  let records = self.recordFactory().records( o.dstPath );
  let newestRecord;
  let mostLinkedRecord;

  if( o.srcPath )
  {
    if( !self.statResolvedRead( o.srcPath ) )
    return error( _.err( '{ o.srcPath } ', o.srcPath, ' doesn\'t exist.' ) );
    newestRecord = mostLinkedRecord = self.record( o.srcPath );
  }
  else
  {
    let sorter = o.sourceMode;
    _.assert( !!sorter, 'Expects { option.sourceMode }' );
    newestRecord = self._recordsSort( records, sorter );

    if( !newestRecord )
    return error( _.err( 'Source file was not selected, probably provided paths { o.dstPath } do not exist.' ) );

    let zero = self.UsingBigIntForStat ? BigInt( 0 ) : 0;
    mostLinkedRecord = _.entityMax( records, ( record ) => record.stat ? record.stat.nlink : zero ).element;
  }

  for( let p = 0 ; p < records.length ; p++ )
  {
    let record = records[ p ];
    if( !record.stat || !_.statsCouldBeLinked( newestRecord.stat, record.stat ) )
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
    let read = self.fileRead({ filePath : newestRecord.absolute, encoding : 'original.type' });
    self.fileWrite( mostLinkedRecord.absolute, read );
    /*
      fileCopy cant be used here
      because hardlinks of most linked file with other files should be preserved
    */
  }

  /* */

  if( o.sync )
  {
    for( let p = 0 ; p < records.length ; p++ )
    {
      if( !onRecord( records[ p ] ) )
      return false;
    }
    return true;
  }
  else
  {
    let cons = [];
    let result = { err : undefined, got : true };
    let throwing = o.throwing;
    o.throwing = 1;

    function handler( err, got )
    {
      if( err && !_.definedIs( result.err ) )
      result.err = err;
      else
      result.got &= got;
    }

    for( let p = 0 ; p < records.length ; p++ )
    cons.push( onRecord( records[ p ] ).tap( handler ) );

    let con = new _.Consequence().give( null );

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

  /* - */

  function error( err )
  {
    if( o.sync )
    throw err;
    else
    return new _.Consequence().error( err );
  }

  /* */

  function onRecord( record )
  {
    if( record === mostLinkedRecord )
    return o.sync ? true : new _.Consequence().give( true );

    if( !o.allowDiffContent )
    if( record.stat && newestRecord.stat.mtime.getTime() === record.stat.mtime.getTime() && newestRecord.stat.birthtime.getTime() === record.stat.birthtime.getTime() )
    {
      if( _.statsHaveDifferentContent( newestRecord.stat , record.stat ) )
      {
        let err = _.err( 'Several files has the same date but different content', newestRecord.absolute, record.absolute );
        debugger;
        if( o.sync )
        throw err;
        else
        return new _.Consequence().error( err );
      }
    }

    if( !record.stat || !_.statsCouldBeLinked( mostLinkedRecord.stat , record.stat ) )
    {
      let linkOptions = _.mapExtend( null, o );
      linkOptions.dstPath = record.absolute;
      linkOptions.srcPath = mostLinkedRecord.absolute;
      return link.call( self, linkOptions );
    }

    return o.sync ? true : new _.Consequence().give( true );
  }

}

//

function _link_functor( gen )
{

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( _link_functor, gen );

  let actMethod = gen.actMethod;
  let actMethodName = gen.actMethodName;
  let entryMethodName = _.strRemoveEnd( gen.actMethodName, 'Act' );
  // let expectingAbsolutePaths = gen.expectingAbsolutePaths;
  let onVerify = gen.onVerify;
  let onSkip = gen.onSkip;
  let onRanameBegin = gen.onRanameBegin;
  // let onAfterRaname = gen.onAfterRaname;
  let renaming = gen.renaming;
  // let renamingHardLinks = gen.renamingHardLinks;
  let skippingSamePath = gen.skippingSamePath;
  // let skippingHardLinked = gen.skippingHardLinked;
  // let skippingSoftLinked = gen.skippingSoftLinked;
  let skippingMissing = gen.skippingMissing;

  _.assert( _.objectIs( actMethod ) || _.routineIs( actMethod ) );
  _.assert( _.objectIs( actMethod.defaults ) );
  _.assert( !onVerify || _.routineIs( onVerify ) );
  _.assert( !onSkip || _.routineIs( onSkip ) );
  _.assert( !onRanameBegin || _.routineIs( onRanameBegin ) );
  // _.assert( !onAfterRaname || _.routineIs( onAfterRaname ) );

  /* - */

  function _link_body( o )
  {
    let self = this;
    let path = self.path;
    let c = Object.create( null );
    c.linkAct = self[ actMethodName ];
    c.result = undefined;
    c.tempPath = undefined;
    c.dstStat = undefined;
    c.srcStat = undefined;
    c.options = o;

    verify( arguments );

    if( _.longIs( o.dstPath ) && c.linkAct.having.hardLinking ) /* qqq : should work not only for hardlinks */
    return _linkMultiple.call( self, o, _link_body );
    _.assert( _.strIs( o.srcPath ) && _.strIs( o.dstPath ) );

    // if( entryMethodName === 'fileCopy' )
    // debugger;
    // self.logger.log( ' +', entryMethodName, ':', path.moveReport( o.dstPath, o.srcPath ) );
    // debugger;

    pathResolve();
    pathResolveLinks();

    // let dstStat;
    c.srcStat = self.statRead({ filePath : o.srcPath });

    if( skip() )
    return end();

    let o2 = c.options2 = _.mapOnly( o, c.linkAct.defaults );

    /* */

    if( o.sync )
    {

      try
      {

        if( onRanameBegin )
        onRanameBegin.call( self, c );

        if( self.fileExists( o2.dstPath ) )
        {
          verifyDst()
          if( tempRenameCan() )
          tempRename();
        }
        else if( o.makingDirectory )
        {
          self.dirMakeForFile( o2.dstPath );
        }

        // if( onAfterRaname )
        // onAfterRaname.call( self, o2 );

        c.linkAct.call( self, o2 );
        log();

        if( c.tempPath )
        {
          self.filesDelete({ filePath : c.tempPath, verbosity : 0 });
          c.tempPath = null;
        }

        validateSize();

      }
      catch( err )
      {

        tempRenameBack();
        if( o.throwing )
        throw _.err( 'Cant', entryMethodName, o.dstPath, '<-', o.srcPath, '\n', err )
        return false;

      }

      return true;
    }
    else /* async */
    {

      // _.assert( 0, 'synchronize with sync version' );

      let con = new _.Consequence().give( null )

      if( onRanameBegin )
      con.ifNoErrorThen( _.routineSeal( self,onRanameBegin, [ c ] ) );

      con.ifNoErrorThen( _.routineSeal( self,self.fileExists, [ o2.dstPath ] ) );
      con.ifNoErrorThen( ( dstExists ) =>
      {
        if( dstExists )
        {
          return verifyDstAsync().ifNoErrorThen( () => tempRenameAsync() )
        }
        else if( o.makingDirectory )
        {
          return self.dirMakeForFile({ filePath : o2.dstPath, sync : 0 });
        }
      });

      con.ifNoErrorThen( _.routineSeal( self, c.linkAct, [ o2 ] ) );

      con.ifNoErrorThen( ( got ) =>
      {
        log();
        if( c.tempPath )
        return self.filesDelete({ filePath : c.tempPath, verbosity : 0 });
        return got;
      });
      con.ifNoErrorThen( () =>
      {
        c.tempPath = null;
        validateSize();
        return true;
      });

      con.ifErrorThen( ( err ) =>
      {
        return tempRenameBackAsync()
        .doThen( () =>
        {
          if( o.throwing )
          throw _.err( 'Cant', entryMethodName, o.dstPath, '<-', o.srcPath, '\n', err )
          return false;
        })
      })

      return con;
    }

    /* - */

    function verify( args )
    {
      _.assert( args.length === 1, 'Expects single argument' );
      _.assert( _.routineIs( c.linkAct ), 'method', actMethodName, 'is not implemented' );
      _.assert( _.objectIs( c.linkAct.defaults ), 'method', actMethodName, 'does not have defaults, but should' );
      _.assertRoutineOptions( _link_body, args );
      // debugger;
      // _.assert( _.boolLike( o.breakingSrcHardLink ) );
      _.assert( _.boolLike( o.resolvingSrcSoftLink ) );
      _.assert( _.boolLike( o.resolvingSrcTextLink ) );
      // _.assert( _.boolLike( o.breakingDstHardLink ) );
      _.assert( _.boolLike( o.resolvingDstSoftLink ) );
      _.assert( _.boolLike( o.resolvingDstTextLink ) );
      if( onVerify )
      onVerify.call( self, c );
    }

    /* - */

    function skip()
    {

      /* allowingMissing */

      if( !c.srcStat )
      {
        if( !o.allowingMissing )
        {
          debugger;
          let err = _.err( 'Source file', _.strQuote( o.srcPath ), 'does not exist' );
          error( err );
          return true;
        }
        if( skippingMissing )
        {
          end( false );
          return true;
        }
      }

      /* equal paths */

      if( o.dstPath === o.srcPath )
      {

        if( skippingSamePath )
        {
          end( true );
          return true;
        }

        if( !o.allowingMissing )
        {
          let err = _.err( 'Making link on itself is not allowed. Please enable options {-o.allowingMissing-} if that was your goal.' );
          error( err );
          return true;
        }

      }

      /* skipping */

      if( onSkip )
      if( onSkip.call( self, c ) )
      {
        end( true );
        return true;
      }

      // let skipping = false;
      //
      // if( skippingHardLinked )
      // skipping = skipping || self.filesAreHardLinked([ o.dstPath, o.srcPath ]);
      // if( skippingSoftLinked )
      // skipping = skipping || self.filesAreSoftLinked([ o.dstPath, o.srcPath ]);
      //
      // if( skipping )
      // {
      //   end( true );
      //   return true;
      // }

      return false;
    }

    /* - */

    function verifyDst()
    {

      if( !o.rewriting )
      throw _.err( 'Destination file ' + _.strQuote( o2.dstPath ) + ' exist and rewriting is off.' );

      c.dstStat = self.statRead
      ({
        filePath : o2.dstPath,
        resolvingSoftLink : 0,
        resolvingTextLink : 0,
        sync : 1,
      });

      if( c.dstStat.isDirectory() && !o.rewritingDirs )
      throw _.err( 'Destination file ' + _.strQuote( o2.dstPath ) + ' is a directory and rewritingDirs is off.' );

    }

    /* - */

    function verifyDstAsync()
    {

      if( !o.rewriting )
      throw _.err( 'Destination file ' + _.strQuote( o2.dstPath ) + ' exist and rewriting is off.' );

      return self.statRead
      ({
        filePath : o2.dstPath,
        resolvingSoftLink : 0,
        resolvingTextLink : 0,
        sync : 0,
      })
      .ifNoErrorThen( ( stat ) =>
      {
        c.dstStat = stat;
        if( c.dstStat.isDirectory() && !o.rewritingDirs )
        throw _.err( 'Destination file ' + _.strQuote( o2.dstPath ) + ' is a directory and rewritingDirs is off.' );
        return stat;
      })
    }

    /* - */

    function pathResolve()
    {

      _.assert( o.originalSrcPath === null, 'not tested' );
      _.assert( o.originalDstPath === null, 'not tested' );

      if( !o.originalSrcPath )
      o.originalSrcPath = o.srcPath;
      if( !o.originalDstPath )
      o.originalDstPath = o.dstPath;

      if( !path.isAbsolute( o.dstPath ) )
      {
        _.assert( path.isAbsolute( o.srcPath ), () => 'Expects absolute path {-o.srcPath-}, but got', _.strQuote( o.srcPath ) );
        o.dstPath = path.resolve( o.srcPath, o.dstPath );
      }
      // else if( !_.path.isGlobal( o.srcPath ) && !path.isAbsolute( o.srcPath ) )
      else if( !path.isAbsolute( o.srcPath ) )
      {
        _.assert( path.isAbsolute( o.dstPath ), () => 'Expects absolute path {-o.dstPath-}, but got', _.strQuote( o.dstPath ) );
        o.srcPath = path.resolve( o.dstPath, o.srcPath );
      }

      _.assert( path.isAbsolute( o.srcPath ) );
      _.assert( path.isAbsolute( o.dstPath ) );

    }

    /* - */

    function pathResolveLinks()
    {

      _.assert( path.isAbsolute( o.srcPath ) );
      _.assert( path.isAbsolute( o.dstPath ) );

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
      /* temp fix : "if" required because relative path should be preserved */

      // if( self.path.isAbsolute( o.originalSrcPath ) )
      if( o.resolvingSrcSoftLink || o.resolvingSrcTextLink )
      o.srcPath = self.pathResolveLink
      ({
        filePath : o.srcPath,
        resolvingSoftLink : o.resolvingSrcSoftLink,
        resolvingTextLink : o.resolvingSrcTextLink,
        // resolvingHardLink : 0,
      });

    }

    /* - */

    function log()
    {
      if( !o.verbosity || o.verbosity < 2 )
      return;
      self.logger.log( ' +', entryMethodName, ':', path.moveReport( o.dstPath, o.srcPath ) );
    }

    /* - */

    function tempRenameCan()
    {

      _.assert( _.fileStatIs( c.dstStat ) );

      if( !renaming )
      return false;

      /* qqq : if breakingSrcHardLink is on then src file should be broken */

      if( !o.breakingDstHardLink && c.dstStat.isHardLink() )
      // if( !renamingHardLinks && c.dstStat.isHardLink() )
      return false;

      return true;
    }

    /* - */

    function tempRename()
    {

      c.tempPath = tempNameMake( o2.dstPath );
      if( self.statRead({ filePath : c.tempPath }) )
      self.filesDelete( c.tempPath );
      self.fileRenameAct
      ({
        dstPath : c.tempPath,
        srcPath : o.dstPath,
        originalDstPath : o.originalDstPath,
        originalSrcPath : o.originalSrcPath,
        sync : 1,
        // resolvingSrcSoftLink : 0,
        // resolvingSrcTextLink : 0,
        // verbosity : 0,
      });

    }

    function tempRenameAsync()
    {
      if( !tempRenameCan() )
      return false;

      c.tempPath = tempNameMake( o2.dstPath );
      return self.statRead
      ({
        filePath : c.tempPath,
        sync : 0
      })
      .ifNoErrorThen( ( tempStat ) =>
      {
        if( tempStat )
        return self.filesDelete( c.tempPath );
        return tempStat;
      })
      .ifNoErrorThen( () =>
      {
        return self.fileRenameAct
        ({
          dstPath : c.tempPath,
          srcPath : o.dstPath,
          originalDstPath : o.originalDstPath,
          originalSrcPath : o.originalSrcPath,
          sync : 0,
          // resolvingSrcSoftLink : 0,
          // resolvingSrcTextLink : 0,
          // verbosity : 0,
        });
      })
    }

    /* - */

    function tempRenameBack()
    {

      if( c.tempPath ) try
      {
        debugger;
        self.fileRenameAct
        ({
          dstPath : o.dstPath,
          srcPath : c.tempPath,
          originalDstPath : o.originalDstPath,
          originalSrcPath : o.originalSrcPath,
          sync : 1,
        });
      }
      catch( err2 )
      {
        debugger;
        console.error( err2 );
        // console.error( err.toString() + '\n' + err.stack );
      }

    }

    function tempRenameBackAsync()
    {
      if( !c.tempPath )
      return new _.Consequence().give( null );

      return self.fileRenameAct
      ({
        dstPath : o.dstPath,
        srcPath : c.tempPath,
        originalDstPath : o.originalDstPath,
        originalSrcPath : o.originalSrcPath,
        sync : 0,
      })
      .doThen( ( err2, got ) )
      {
        if( err2 )
        console.error( err2 );
        return got;
      }
    }

    /* - */

    function tempNameMake( filePath )
    {
      return filePath + '-' + _.idWithGuid() + '.tmp';
    }

    /* - */

    function validateSize()
    {
      /* qqq : fix please */
      // if( !Config.debug )
      // return;
      // let c.srcStat = self.statResolvedRead({ filePath : o.srcPath, resolvingSoftLink : 1, resolvingTextLink : 1 });
      // if( !c.srcStat )
      // return;
      // let c.dstStat = self.statResolvedRead({ filePath : o.dstPath, resolvingSoftLink : 1, resolvingTextLink : 1 });
      // if( !c.dstStat )
      // return;
      // _.assert( !!c.dstStat );
      // if( !( c.srcStat.size == c.dstStat.size ) )
      // self.logger.warn( `Warning: ${o.srcPath} (${c.srcStat.size}) and ${o.dstPath} (${c.dstStat.size}) should have same size!` )
    }

    /* - */

    function error( err )
    {
      if( o.throwing )
      {
        if( o.sync )
        throw err;
        c.result = new _.Consequence().error( err );
        return c.result;
      }
      else
      {
        // if( o.sync )
        // return false;
        // return new _.Consequence().give( false );
        return end( null ); /* qqq : should return null, if error. not false. cover it, please */
      }
    }

    /* - */

    function end( r )
    {
      if( r !== undefined )
      if( o.sync )
      c.result = r;
      else
      c.result = _.Consequence().give( r );
      _.assert( !!o.sync || _.consequenceIs( c.result ) );
      _.assert( c.result !== undefined );
      return c.result;
    }

  }

  // function linkEntry( o )
  // {
  //   let self = this;
  //   o = self[ entryMethodName ].pre.call( self, self[ entryMethodName ], arguments );
  //   let result = self[ entryMethodName ].body.call( self, o );
  //   return result;
  // }
  //
  // linkEntry.pre = _link_pre;
  // linkEntry.body = _link_body;

  _.routineExtend( _link_body, actMethod )

  var having = _link_body.having;

  having.driving = 0;
  having.aspect = 'body';
  // having.hubRedirecting = 0;

  let linkEntry = _.routineFromPreAndBody( _link_pre, _link_body, entryMethodName );

  var having = linkEntry.having;

  having.aspect = 'entry';

  /* qqq : at the end, all files should has the same size */

  return linkEntry;
}

_link_functor.defaults =
{

  actMethod : null,
  actMethodName : null,

  onVerify : null,
  onSkip : null,
  onRanameBegin : null,

  renaming : true,
  skippingSamePath : true,
  skippingMissing : false,

}

//

let fileRenameAct = Object.create( null );

fileRenameAct.name = 'fileRenameAct';

var defaults = fileRenameAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.sync = null;

// var paths = fileRenameAct.paths = Object.create( null );
//
// paths.dstPath = null;
// paths.srcPath = null;

var having = fileRenameAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = fileRenameAct.operates = Object.create( null );

operates.srcPath = { pathToRead : 1 }
operates.dstPath = { pathToWrite : 1 }

//

/**
 * Changes name of the file.
 * Takes single argument - object with options or two arguments : destination( o.dstPath ) and source( o.srcPath ) paths.
 * Routine changes name of the source file if ( o.srcPath ) and ( dstPath ) have different file names. Also moves source file to the new location( dstPath )
 * if parent dirs of ( o.srcPath ) and ( o.dstPath ) are not same. If ( o.dstPath ) path exists and ( o.rewriting ) is enabled, the destination file can be overwritten.
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
 * wTools.fileProvider.fileRename( '/existingDir/notExistingDst', '/existingDir/existingSrc' );
 * //returns true
 *
 * @example
 * wTools.fileProvider.fileRename( '/existingDir/existingSrc', '/existingDir/existingSrc' );
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
 * let consequence = wTools.fileProvider.fileRename
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

let fileRename = _link_functor
({
  actMethodName : 'fileRenameAct',
  actMethod : fileRenameAct,
  skippingSamePath : true,
  skippingMissing : true,
});

// var defaults = fileRename.body.defaults = Object.create( fileRenameAct.defaults );

var defaults = fileRename.body.defaults;

defaults.rewriting = 0;
defaults.rewritingDirs = 0;
defaults.makingDirectory = 0;
defaults.allowingMissing = 0;
defaults.throwing = null;
defaults.verbosity = null;
defaults.resolvingSrcSoftLink = 1;
defaults.resolvingSrcTextLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

// var paths = fileRename.body.paths = Object.create( fileRenameAct.paths );
// var having = fileRename.body.having = Object.create( fileRenameAct.having );
//
// having.driving = 0;
// having.aspect = 'body';
// having.hubRedirecting = 0;
//
// var defaults = fileRename.defaults = Object.create( fileRename.body.defaults );
// var paths = fileRename.paths = Object.create( fileRename.body.paths );
// var having = fileRename.having = Object.create( fileRename.body.having );
//
// having.aspect = 'entry';

//

let fileCopyAct = Object.create( null );

fileCopyAct.name = 'fileCopyAct';

var defaults = fileCopyAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.breakingDstHardLink = 0;
defaults.sync = null;

// var paths = fileCopyAct.paths = Object.create( null );
//
// paths.dstPath = null;
// paths.srcPath = null;

var having = fileCopyAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = fileCopyAct.operates = Object.create( null );

operates.srcPath = { pathToRead : 1 }
operates.dstPath = { pathToWrite : 1 }

//

/**
 * Creates copy of a file. Accepts two arguments: ( srcPath ), ( dstPath ) or options object.
 * Returns true if operation is finished successfully or if source and destination paths are equal.
 * Otherwise throws error with corresponding message or returns false, it depends on ( o.throwing ) property.
 * In asynchronously mode returns wConsequence instance.
 * @example
   let fileProvider = _.FileProvider.Default();
   let result = fileProvider.fileCopy( 'src.txt', 'dst.txt' );
   console.log( result );// true
   let stats = fileProvider.statResolvedRead( 'dst.txt' );
   console.log( stats ); // returns Stats object
 * @example
   let fileProvider = _.FileProvider.Default();
   let consequence = fileProvider.fileCopy
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
     let stats = fileProvider.statResolvedRead( 'dst.txt' );
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

function _fileCopyRenameBegin( c )
{
  let self = this;
  let o = c.options;

  _.assert( _.strIs( o.srcPath ) );
  _.assert( _.fileStatIs( c.srcStat ) );

  let isDir = c.srcStat.isDir();
  if( isDir )
  {
    debugger;
    throw _.err( 'Cant copy directory ' + _.strQuote( o.srcPath ) + ', consider method filesCopy'  );
  }

  return c;
}

let fileCopy = _link_functor
({
  actMethod : fileCopyAct,
  actMethodName : 'fileCopyAct',
  onRanameBegin : _fileCopyRenameBegin,
  // renaming : true,
  // renamingHardLinks : false,
  skippingSamePath : true,
  skippingMissing : true,
});

// var defaults = fileCopy.body.defaults = Object.create( fileCopyAct.defaults );

var defaults = fileCopy.body.defaults;

defaults.rewriting = 1;
defaults.rewritingDirs = 0;
defaults.makingDirectory = 0;
defaults.allowingMissing = 0;
defaults.throwing = null;
defaults.verbosity = null;

defaults.breakingSrcHardLink = 0;
defaults.resolvingSrcSoftLink = 1;
defaults.resolvingSrcTextLink = 0;

defaults.breakingDstHardLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

// var paths = fileCopy.body.paths = Object.create( fileCopyAct.paths );
// var having = fileCopy.body.having = Object.create( fileCopyAct.having );
//
// having.driving = 0;
// having.aspect = 'body';
// having.hubRedirecting = 0;
//
// var defaults = fileCopy.defaults = Object.create( fileCopy.body.defaults );
// var paths = fileCopy.paths = Object.create( fileCopy.body.paths );
// var having = fileCopy.having = Object.create( fileCopy.body.having );
//
// having.aspect = 'entry';

//

let softLinkAct = Object.create( null );

softLinkAct.name = 'softLinkAct';

var defaults = softLinkAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.sync = null;
defaults.type = null;

// var paths = softLinkAct.paths = Object.create( null );
//
// paths.dstPath = null;
// paths.srcPath = null;

var having = softLinkAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = softLinkAct.operates = Object.create( null );

operates.srcPath = { pathToRead : 1 }
operates.dstPath = { pathToWrite : 1 }

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
 * @method softLink
 * @throws { exception } If( o.srcPath ) doesn`t exist.
 * @throws { exception } If cant link ( o.srcPath ) with ( o.dstPath ).
 * @memberof wFileProviderPartial
 */

function _softLinkSkip( c )
{
  let self = this;
  let o = c.options;
  if( o.dstPath !== o.srcPath && self.filesAreSoftLinked([ o.dstPath, o.srcPath ]) )
  return true;
}

let softLink = _link_functor
({
  actMethod : softLinkAct,
  actMethodName : 'softLinkAct',
  //expectingAbsolutePaths : false,
  skippingSamePath : false,
  skippingMissing : false,
  // skippingSoftLinked : true,
  onSkip : _softLinkSkip,
});

// var defaults = softLink.body.defaults = Object.create( softLinkAct.defaults );

var defaults = softLink.body.defaults;

defaults.rewriting = 1;
defaults.rewritingDirs = 0;
defaults.makingDirectory = 0;
defaults.throwing = null;
defaults.verbosity = null;
defaults.allowingMissing = 0;

defaults.resolvingSrcSoftLink = 0;
defaults.resolvingSrcTextLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

// var paths = softLink.body.paths = Object.create( softLinkAct.paths );
//
// var having = softLink.body.having = Object.create( softLinkAct.having );
//
// having.driving = 0;
// having.aspect = 'body';
// having.hubRedirecting = 0;
//
// var defaults = softLink.defaults = Object.create( softLink.body.defaults );
// var paths = softLink.paths = Object.create( softLink.body.paths );
// var having = softLink.having = Object.create( softLink.body.having );
//
// having.aspect = 'entry';

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
 * @method hardLinkAct
 * @memberof wFileProviderPartial
 */

let hardLinkAct = Object.create( null );

hardLinkAct.name = 'hardLinkAct';

var defaults = hardLinkAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;
defaults.breakingSrcHardLink = 0;
defaults.breakingDstHardLink = 1;
defaults.sync = null;

// var paths = hardLinkAct.paths = Object.create( null );
//
// // paths.dstPath = null;
// // paths.srcPath = null;

var having = hardLinkAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;
having.hardLinking = 1;

var operates = hardLinkAct.operates = Object.create( null );

operates.srcPath = { pathToRead : 1 }
operates.dstPath = { pathToWrite : 1 }

//

/**
 * Creates hard link( new name ) to existing source( o.srcPath ) named as ( o.dstPath ).
 * Rewrites target( o.dstPath ) by default if it exist. Logging of working process is controled by option( o.verbosity ).
 * Returns true if link is successfully created. If some error occurs during execution method uses option( o.throwing ) to
 * determine what to do - throw error or return false.
 *
 * @param { wTools~linkOptions } o - options { @link wTools~linkOptions  }
 *
 * @method softLink
 * @throws { exception } If( o.srcPath ) doesn`t exist.
 * @throws { exception } If cant link ( o.srcPath ) with ( o.dstPath ).
 * @memberof wFileProviderPartial
 */

function _hardLinkSkip( c )
{
  let self = this;
  let o = c.options;
  if( self.filesAreHardLinked([ o.dstPath, o.srcPath ]) )
  return true;
}

function _hardLinkVerify( c )
{
  let self = this;
  let o = c.options;
  _.assert( _.boolLike( o.breakingSrcHardLink ) );
  _.assert( _.boolLike( o.breakingDstHardLink ) );
  _.assert
  (
    !!c.options.breakingSrcHardLink || !!c.options.breakingDstHardLink,
    'Both source and destination hardlinks could not be preserved, please set breakingSrcHardLink or breakingDstHardLink to true'
  );
}

let hardLink = _link_functor
({
  actMethod : hardLinkAct,
  actMethodName : 'hardLinkAct',
  skippingSamePath : true,
  skippingMissing : false,
  // skippingHardLinked : true,
  onVerify : _hardLinkVerify,
  onSkip : _hardLinkSkip,
});

// var defaults = hardLink.body.defaults = Object.create( hardLinkAct.defaults );

var defaults = hardLink.body.defaults;

defaults.rewriting = 1;
defaults.rewritingDirs = 0;
defaults.makingDirectory = 0;
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

// _.routineExtend( hardLink.body, hardLinkAct );
//
// // var paths = hardLink.body.paths = Object.create( hardLinkAct.paths );
// // var having = hardLink.body.having = Object.create( hardLinkAct.having );
//
// var having = hardLink.body.having;
//
// having.driving = 0;
// having.aspect = 'body';
// having.hubRedirecting = 0;
//
// _.routineExtend( hardLink, hardLink.body );
//
// // var defaults = hardLink.defaults = Object.create( hardLink.body.defaults );
// // var paths = hardLink.paths = Object.create( hardLink.body.paths );
// // var having = hardLink.having = Object.create( hardLink.body.having );
//
// var having = hardLink.having;
//
// having.aspect = 'entry';

//

function textLinkAct( o )
{
  let self = this;
  let path = self.path;

  _.assertRoutineOptions( textLinkAct, arguments );
  _.assert( path.is( o.srcPath ) );
  _.assert( path.isAbsolute( o.dstPath ) );

  return self.fileWrite( o.dstPath, 'link ' + o.srcPath );
}

var defaults = textLinkAct.defaults = Object.create( null );

defaults.dstPath = null;
defaults.srcPath = null;
defaults.originalDstPath = null;
defaults.originalSrcPath = null;

var having = textLinkAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = textLinkAct.operates = Object.create( null );

operates.srcPath = { pathToRead : 1 }
operates.dstPath = { pathToWrite : 1 }

//

/**
 * Creates text link to existing source( o.srcPath ) named as ( o.dstPath ).
 * Rewrites target( o.dstPath ) by default if it exist. Logging of working process is controled by option( o.verbosity ).
 * Returns true if link is successfully created. If some error occurs during execution method uses option( o.throwing ) to
 * determine what to do - throw error or return false.
 *
 * @param { wTools~linkOptions } o - options { @link wTools~linkOptions  }
 *
 * @method textLink
 * @throws { exception } If( o.srcPath ) doesn`t exist.
 * @throws { exception } If cant link ( o.srcPath ) with ( o.dstPath ).
 * @memberof wFileProviderPartial
 */

function _textLinkSkip( c )
{
  let self = this;
  let o = c.options;
  debugger; // qqq : implement filesAreTextLinked
  if( o.dstPath !== o.srcPath && self.filesAreTextLinked([ o.dstPath, o.srcPath ]) )
  return true;
}

let textLink = _link_functor
({
  actMethod : textLinkAct,
  actMethodName : 'textLinkAct',
  skippingSamePath : false,
  skippingMissing : false,
  onSkip : _textLinkSkip,
});

var defaults = textLink.body.defaults;

defaults.rewriting = 1;
defaults.rewritingDirs = 0;
defaults.makingDirectory = 0;
defaults.throwing = null;
defaults.verbosity = null;
defaults.allowingMissing = 0;

defaults.resolvingSrcSoftLink = 0;
defaults.resolvingSrcTextLink = 0;
defaults.resolvingDstSoftLink = 0;
defaults.resolvingDstTextLink = 0;

//

// function textLink_body( o )
// {
//   let self = this;
//   let path = self.path;
//
//   _.assertRoutineOptions( textLink_body, arguments );
//   _.assert( path.is( o.srcPath ) );
//   _.assert( path.isAbsolute( o.dstPath ) );
//
//   return self.fileWrite( o.dstPath, 'link ' + o.srcPath );
// }
//
// var defaults = textLink_body.defaults = Object.create( null );
//
// defaults.srcPath = null;
// defaults.dstPath = null;
//
// var having = textLink_body.having = Object.create( null );
//
// having.writing = 1;
// having.reading = 1;
// having.driving = 0;
// having.aspect = 'body';
//
// let textLink = _.routineFromPreAndBody( _preSrcDstPathWithProviderDefaults, textLink_body );
//
// textLink.having.aspect = 'entry';

//

function fileExchange_pre( routine, args )
{
  let self = this;
  let o;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

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

  _.routineOptions( routine, o );
  self._providerDefaults( o );
  _.assert( _.strIs( o.srcPath ) && _.strIs( o.dstPath ) );

  return o;
}

//

function fileExchange_body( o )
{
  let self  = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let dstPath = o.dstPath;
  let srcPath = o.srcPath;

  let allowingMissing = o.allowingMissing;
  delete o.allowingMissing;

  let src = self.statResolvedRead({ filePath : o.srcPath, throwing : 0 });
  let dst = self.statResolvedRead({ filePath : o.dstPath, throwing : 0 });

  function _returnNull()
  {
    if( o.sync )
    return null;
    else
    return new _.Consequence().give( null );
  }

  if( !src || !dst )
  {
    if( allowingMissing )
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
      let err;

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

  let tempPath = o.srcPath + '-' + _.idWithGuid() + '.tmp';

  o.dstPath = tempPath;

  if( o.sync )
  {
    self.fileRename( o );
    o.dstPath = o.srcPath;
    o.srcPath = dstPath;
    self.fileRename( o );
    o.dstPath = dstPath;
    o.srcPath = tempPath;
    return self.fileRename( o );
  }
  else
  {
    let con = new _.Consequence().give( null );

    con.ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      o.dstPath = o.srcPath;
      o.srcPath = dstPath;
    })
    .ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      o.dstPath = dstPath;
      o.srcPath = tempPath;
    })
    .ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) );

    return con;
  }
}

var defaults = fileExchange_body.defaults = Object.create( null );

defaults.srcPath = null;
defaults.dstPath = null;
defaults.sync = null;
defaults.allowingMissing = 1;
defaults.throwing = null;
defaults.verbosity = null;

// var paths = fileExchange_body.paths = Object.create( null );

var having = fileExchange_body.having = Object.create( null );

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
 * @param {Boolean} [ o.allowingMissing=true ] - Allows missing of the file( s ). If source ( o.srcPath ) is missing - ( o.srcPath ) becomes destination and ( o.dstPath ) becomes the source. Routine returns null if both paths are missing.
 * @returns {Boolean|wConsequence} Returns true after successful exchange, otherwise false is returned. Also returns false if an error occurs and ( o.throwing ) is disabled.
 * In async mode returns Consequence instance @see{@link wConsequence } with same result.
 *
 * @example
 * wTools.fileProvider.fileExchange( '/existingDir/existingDst', '/existingDir/existingSrc' );
 * //returns true
 *
 * @example
 * let consequence = wTools.fileProvider.fileExchange
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

let fileExchange = _.routineFromPreAndBody( fileExchange_pre, fileExchange_body );

fileExchange.having.aspect = 'entry';

// --
// link
// --

let hardLinkBreakAct = Object.create( null );

var defaults = hardLinkBreakAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

// var paths = hardLinkBreakAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = hardLinkBreakAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = hardLinkBreakAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1, pathToWrite : 1 }

//

function hardLinkBreak_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.routineIs( self.hardLinkBreakAct ) )
  return self.hardLinkBreakAct( o );
  else
  {
    let options =
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

var defaults = hardLinkBreak_body.defaults = Object.create( hardLinkBreakAct.defaults );
// var paths = hardLinkBreak_body.paths = Object.create( hardLinkBreakAct.paths );
var having = hardLinkBreak_body.having = Object.create( hardLinkBreakAct.having );

having.driving = 0;
having.aspect = 'body';

let hardLinkBreak = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, hardLinkBreak_body );

hardLinkBreak.having.aspect = 'entry';

//

let softLinkBreakAct = Object.create( null );

var defaults = softLinkBreakAct.defaults = Object.create( null );

defaults.filePath = null;
defaults.sync = null;

// var paths = softLinkBreakAct.paths = Object.create( null );
//
// paths.filePath = null;

var having = softLinkBreakAct.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 1;

var operates = softLinkBreakAct.operates = Object.create( null );

operates.filePath = { pathToRead : 1, pathToWrite : 1 }

//

function _softLinkBreak_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.routineIs( self.softLinkBreakAct ) )
  return self.softLinkBreakAct( o );
  else
  {
    let options =
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
var having = _softLinkBreak_body.having = Object.create( softLinkBreakAct.having );

having.driving = 0;
having.aspect = 'body';

let softLinkBreak = _.routineFromPreAndBody( _preFilePathScalarWithProviderDefaults, _softLinkBreak_body );

softLinkBreak.having.aspect = 'entry';

//

let filesAreHardLinkedAct = Object.create( null );

var defaults = filesAreHardLinkedAct.defaults = Object.create( null );
defaults.filePath = null;

var having = filesAreHardLinkedAct.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 1;

var operates = filesAreHardLinkedAct.operates = Object.create( null );
operates.filePath = { pathToRead : 1 }

//

/**
 * Check if one of paths is hard link to other.
 * @example
   let fs = require( 'fs' );

   let path1 = '/home/tmp/sample/file1',
   path2 = '/home/tmp/sample/file2',
   buffer = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   fs.symlinkSync( path1, path2 );

   let linked = wTools.filesAreHardLinked( path1, path2 ); // true

 * @param {string|wFileRecord} ins1 path string/file record instance
 * @param {string|wFileRecord} ins2 path string/file record instance

 * @returns {boolean}
 * @throws {Error} if missed one of arguments or pass more then 2 arguments.
 * @method filesAreHardLinked
 * @memberof wFileProviderPartial
 */

function filesAreLinked_pre( routine, args )
{
  let self = this;
  let o;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( args.length === 2 )
  {
    o = { filePath : [ args[ 0 ], args[ 1 ] ] }
  }
  else if( _.arrayLike( args[ 0 ] ) )
  {
    _.assert( args.length === 1 );
    o = { filePath : args[ 0 ] }
  }
  else
  {
    _.assert( args.length === 1 );
    o = args[ 0 ];
  }

  _.assert( _.mapIs( o ) );

  o = self._preFilePathVectorWithProviderDefaults.call( self, routine, [ o ] );

  return o;
}

//

function filesAreHardLinked_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( filesAreHardLinked_body, arguments );

  if( !o.filePath.length )
  return true;

  if( _.routineIs( self.filesAreHardLinkedAct ) )
  {
    for( let i = 1 ; i < o.filePath.length ; i++ )
    {
      if( !self.filesAreHardLinkedAct( o.filePath[ 0 ], o.filePath[ i ] ) )
      return false;
    }
    return true;
  }

  let statFirst = self.statResolvedRead( o.filePath[ 0 ] );
  if( !statFirst )
  return false;

  for( let i = 1 ; i < o.filePath.length ; i++ )
  {
    let statCurrent = self.statResolvedRead( self.path.from( o.filePath[ i ] ) );
    if( !statCurrent || !_.statsCouldBeLinked( statFirst, statCurrent ) )
    return false;
  }

  /*
    should return "not sure" ( null ), not true if result is not precise
  */

  return null;
}

var defaults = filesAreHardLinked_body.defaults = Object.create( null );
defaults.filePath = null;

var operates = filesAreHardLinked_body.operates = Object.create( null );
operates.filePath = { pathToRead : 1 }

var having = filesAreHardLinked_body.having = Object.create( null );
having.aspect = 'body';
having.writing = 0;
having.reading = 1;
having.driving = 0;

//

let filesAreHardLinked = _.routineFromPreAndBody( filesAreLinked_pre, filesAreHardLinked_body );

filesAreHardLinked.having.driving = 0;
filesAreHardLinked.having.aspect = 'entry';

//

function filesAreSoftLinked_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( filesAreSoftLinked_body, arguments );
  _.assert( o.filePath.length >= 2 );

  o.filePath = path.s.normalize( o.filePath );

  _.assert( path.s.allAreAbsolute( o.filePath ) );

  if( o.filePath[ 0 ] === o.filePath[ 1 ] )
  return false;

  let resolved = [];

  for( let i = 0 ; i < o.filePath.length ; i++ )
  {
    resolved[ i ] = self.pathResolveLink
    ({
      filePath : o.filePath[ i ],
      resolvingSoftLink : true,
      resolvingTextLink : o.resolvingTextLink,
    });
    _.assert( path.is( resolved[ 0 ] ) );
  }

  for( let i = 1 ; i < resolved.length ; i++ )
  {
    if( resolved[ 0 ] !== resolved[ i ] )
    return false;
  }

  return true;
}

var defaults = filesAreSoftLinked_body.defaults = Object.create( null );
defaults.filePath = null;
defaults.resolvingTextLink = null;

var operates = filesAreSoftLinked_body.operates = Object.create( null );
operates.filePath = { pathToRead : 1 }

var having = filesAreSoftLinked_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;
having.aspect = 'body';

//

let filesAreSoftLinked = _.routineFromPreAndBody( filesAreLinked_pre, filesAreSoftLinked_body );

filesAreSoftLinked.having.driving = 0;
filesAreSoftLinked.having.aspect = 'entry';

//

function filesAreTextLinked_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( filesAreTextLinked_body, arguments );
  _.assert( o.filePath.length >= 2 );

  o.filePath = path.s.normalize( o.filePath );

  _.assert( path.s.allAreAbsolute( o.filePath ) );

  if( o.filePath[ 0 ] === o.filePath[ 1 ] )
  return false;

  let resolved = [];

  for( let i = 0 ; i < o.filePath.length ; i++ )
  {
    resolved[ i ] = self.pathResolveLink
    ({
      filePath : o.filePath[ i ],
      resolvingSoftLink : o.resolvingSoftLink,
      resolvingTextLink : true,
    });
    _.assert( path.is( resolved[ 0 ] ) );
  }

  for( let i = 1 ; i < resolved.length ; i++ )
  {
    if( resolved[ 0 ] !== resolved[ i ] )
    return false;
  }

  return true;
}

var defaults = filesAreTextLinked_body.defaults = Object.create( null );
defaults.filePath = null;
defaults.resolvingSoftLink = null;

var operates = filesAreTextLinked_body.operates = Object.create( null );
operates.filePath = { pathToRead : 1 }

var having = filesAreTextLinked_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;
having.aspect = 'body';

//

let filesAreTextLinked = _.routineFromPreAndBody( filesAreLinked_pre, filesAreTextLinked_body );

filesAreTextLinked.having.driving = 0;
filesAreTextLinked.having.aspect = 'entry';

// --
// accessor
// --

function _protocolsSet( protocols )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( protocols === null )
  {
    self[ protocolsSymbol ] = [];
    self[ protocolSymbol ] = null;
    return protocols;
  }

  if( _.strIs( protocols ) )
  return self._protocolsSet([ protocols ]);

  _.assert( _.arrayIs( protocols ) )
  _.assert( protocols.every( ( p ) => !_.strHas( p, ':' ) && !_.strHas( p, '/' ) ) );

  protocols = protocols.map( ( p ) => p.toLowerCase() );

  let protocol = protocols[ 0 ];
  // let protocol = protocols.join( '+' );

  self[ protocolsSymbol ] = protocols;
  self[ protocolSymbol ] = protocol;

  if( protocol )
  self[ originPathSymbol ] = self.originsForProtocols( protocol );
  else
  self[ originPathSymbol ] = null;

  // self[ originPathSymbol ] = protocols.map( ( protocol ) => protocol + '://' );

}

var having = _protocolsSet.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'inter';

//

function _protocolSet( protocol )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( protocol ) );

  self._protocolsSet( protocol );
}

var having = _protocolSet.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'inter';

//

function _originPathSet( origins )
{
  let self = this;

  self.protocols = self.protocolsForOrigins( origins );

  // _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( _.strIs( origins ) );
  // _.assert( _.strEnds( origins, '://' ) );
  //
  // origins = _.strRemoveEnd( origins, '://' );
  //
  // _.assert( !_.strHas( origins, '://' ) );

  // self._protocolsSet( origins.split( '+' ) );
}

var having = _originPathSet.having = Object.create( null );

having.writing = 0;
having.reading = 0;
having.driving = 0;
having.kind = 'inter';

// --
// vars
// --

let verbositySymbol = Symbol.for( 'verbosity' );
let protocolsSymbol = Symbol.for( 'protocols' );
let protocolSymbol = Symbol.for( 'protocol' );
let originPathSymbol = Symbol.for( 'originPath' );

let WriteMode = [ 'rewrite', 'prepend', 'append' ];

let ProviderDefaults =
{
  'encoding' : null,
  'resolvingSoftLink' : null,
  'resolvingTextLink' : null,
  'usingSoftLink' : null,
  'usingTextLink' : null,
  'verbosity' : null,
  'sync' : null,
  'throwing' : null,
  'safe' : null,
  'hub' : null,
}

// --
// relationship
// --

let Composes =
{

  protocols : _.define.own([]),

  encoding : 'utf8',
  hashFileSizeLimit : 1 << 22,

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

let Aggregates =
{
}

let Associates =
{
  path : null,
  logger : null,
  hub : null,
}

let Restricts =
{
}

let Medials =
{
  protocol : null,
  originPath : null,
}

let Statics =
{
  MakeDefault : MakeDefault,
  Path : _.path.CloneExtending({ fileProvider : Self }),
  WriteMode : WriteMode,
  ProviderDefaults : ProviderDefaults
}

let Forbids =
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

  softLinkRead : 'softLinkRead',
  softLinkReadAct : 'softLinkReadAct',
  linkSoftAct : 'linkSoftAct',
  linkSoft : 'linkSoft',
  linkHardAct : 'linkHardAct',
  linkHard : 'linkHard',
  pathResolveHardLinkAct : 'pathResolveHardLinkAct',
  pathResolveHardLink : 'pathResolveHardLink',

  isTerminalAct : 'isTerminalAct',
  isDirAct : 'isDirAct',
  isTextLinkAct : 'isTextLinkAct',
  isSoftLinkAct : 'isSoftLinkAct',
  isHardLinkAct : 'isHardLinkAct',

}

let Accessors =
{
  protocols : 'protocols',
  protocol : 'protocol',
  originPath : 'originPath',
}

// --
// declare
// --

let Proto =
{

  init,
  finit,
  MakeDefault,

  // functors

  _vectorize,
  _vectorizeAll,
  _vectorizeAny,
  _vectorizeNone,

  // etc

  _fileOptionsGet,
  _providerDefaults,
  _preFilePathScalarWithoutProviderDefaults,
  _preFilePathScalarWithProviderDefaults,
  _preFilePathVectorWithoutProviderDefaults,
  _preFilePathVectorWithProviderDefaults,
  _preSrcDstPathWithoutProviderDefaults,
  _preSrcDstPathWithProviderDefaults,

  protocolsForOrigins,
  originsForProtocols,
  providerForPath,
  providerRegisterTo,

  // path

  localFromGlobal,
  localsFromGlobals : _vectorize( localFromGlobal ),

  globalFromLocal,
  globalsFromLocals : _vectorize( globalFromLocal ),

  pathNativizeAct,
  pathCurrentAct,
  pathDirTempAct : null,

  _pathResolveTextLinkAct : null,
  _pathResolveTextLink,
  pathResolveTextLink,

  pathResolveSoftLinkAct,
  pathResolveSoftLink,

  // pathResolveHardLinkAct,
  // pathResolveHardLink,

  pathResolveLinkChain,
  pathResolveLink,

  // record

  _recordFactoryFormEnd,
  _recordFormBegin,
  _recordPathForm,
  _recordFormEnd,

  record,
  _recordsSort,
  recordFactory,
  recordFilter,

  // stat

  statReadAct,
  statRead,
  statsRead : _vectorize( statRead ),
  statResolvedRead,
  statsResolvedRead : _vectorize( statResolvedRead ),

  filesSize,
  fileSize,

  fileExistsAct,
  fileExists,
  filesExists : _vectorize( fileExists ),
  filesExistsAll : _vectorizeAll( fileExists ),
  filesExistsAny : _vectorizeAny( fileExists ),
  filesExistsNone : _vectorizeNone( fileExists ),

  isTerminal,
  areTerminals : _vectorize( isTerminal ),
  allAreTerminals : _vectorizeAll( isTerminal ),
  anyAreTerminals : _vectorizeAny( isTerminal ),
  noneAreTerminals : _vectorizeNone( isTerminal ),
  resolvedIsTerminal,
  resolvedAreTerminals : _vectorize( resolvedIsTerminal ),
  resolvedAllAreTerminals : _vectorizeAll( resolvedIsTerminal ),
  resolvedAnyAreTerminals : _vectorizeAny( resolvedIsTerminal ),
  resolvedNoneAreTerminals : _vectorizeNone( resolvedIsTerminal ),

  isDir,
  areDirs : _vectorize( isDir ),
  allAreDirs : _vectorizeAll( isDir ),
  anyAreDirs : _vectorizeAny( isDir ),
  noneAreDirs : _vectorizeNone( isDir ),
  resolvedIsDir,
  resolvedAreDirs : _vectorize( resolvedIsDir ),
  resolvedAllAreDirs : _vectorizeAll( resolvedIsDir ),
  resolvedAnyAreDirs : _vectorizeAny( resolvedIsDir ),
  resolvedNoneAreDirs : _vectorizeNone( resolvedIsDir ),

  isTextLink,
  filesAreTextLinks : _vectorize( isTextLink ),
  allAreTextLinks : _vectorizeAll( isTextLink ),
  anyAreTextLinks : _vectorizeAny( isTextLink ),
  noneAreTextLinks : _vectorizeNone( isTextLink ),
  resolvedIsTextLink,
  resolvedAreTextLinks : _vectorize( resolvedIsTextLink ),
  resolvedAllAreTextLinks : _vectorizeAll( resolvedIsTextLink ),
  resolvedAnyAreTextLinks : _vectorizeAny( resolvedIsTextLink ),
  resolvedNoneAreTextLinks : _vectorizeNone( resolvedIsTextLink ),

  isSoftLink,
  filesAreSoftLinks : _vectorize( isSoftLink ),
  allAreSoftLinks : _vectorizeAll( isSoftLink ),
  anyAreSoftLinks : _vectorizeAny( isSoftLink ),
  noneAreSoftLinks : _vectorizeNone( isSoftLink ),
  resolvedIsSoftLink,
  resolvedAreSoftLinks : _vectorize( resolvedIsSoftLink ),
  resolvedAllAreSoftLinks : _vectorizeAll( resolvedIsSoftLink ),
  resolvedAnyAreSoftLinks : _vectorizeAny( resolvedIsSoftLink ),
  resolvedNoneAreSoftLinks : _vectorizeNone( resolvedIsSoftLink ),

  isHardLink,
  areHardLinks : _vectorize( isHardLink ),
  allAreHardLinks : _vectorizeAll( isHardLink ),
  anyAreHardLinks : _vectorizeAny( isHardLink ),
  noneAreHardLinks : _vectorizeNone( isHardLink ),
  resolvedIsHardLink,
  resolvedAreHardLinks : _vectorize( resolvedIsHardLink ),
  resolvedAllAreHardLinks : _vectorizeAll( resolvedIsHardLink ),
  resolvedAnyAreHardLinks : _vectorizeAny( resolvedIsHardLink ),
  resolvedNoneAreHardLinks : _vectorizeNone( resolvedIsHardLink ),

  isLink,
  areLinks : _vectorize( isLink ),
  allAreLinks : _vectorizeAll( isLink ),
  anyAreLinks : _vectorizeAny( isLink ),
  noneAreLinks : _vectorizeNone( isLink ),
  resolvedIsLink,
  filesResolvedAreLinks : _vectorize( resolvedIsLink ),
  filesResolvedAllAreLinks : _vectorizeAll( resolvedIsLink ),
  filesResolvedAnyAreLinks : _vectorizeAny( resolvedIsLink ),
  filesResolvedNoneAreLinks : _vectorizeNone( resolvedIsLink ),

  dirIsEmpty,
  dirsAreEmpty : _vectorize( dirIsEmpty ),
  dirsAllAreEmpty : _vectorizeAll( dirIsEmpty ),
  dirsAnyAreEmpty : _vectorizeAny( dirIsEmpty ),
  dirsNoneAreEmpty : _vectorizeNone( dirIsEmpty ),
  resolvedDirIsEmpty,
  resolvedDirsAreEmpty : _vectorize( resolvedDirIsEmpty ),
  resolvedDirsAllAreEmpty : _vectorizeAll( resolvedDirIsEmpty ),
  resolvedDirsAnyAreEmpty : _vectorizeAny( resolvedDirIsEmpty ),
  resolvedDirsNoneAreEmpty : _vectorizeNone( resolvedDirIsEmpty ),

  // read

  streamReadAct,
  streamRead,

  fileReadAct,
  fileRead,
  fileReadSync,
  fileReadJson,
  fileReadJs,
  fileInterpret,

  fileHashAct,
  fileHash,

  dirReadAct,
  dirRead,
  dirReadDirs,
  dirReadTerminals,

  filesFingerprints,
  filesAreSame,

  // write

  streamWriteAct,
  streamWrite,

  fileWriteAct,
  fileWrite,
  fileAppend,
  fileWriteJson,
  fileWriteJs,
  fileTouch,

  fileTimeSetAct,
  fileTimeSet,

  fileDeleteAct,
  fileDelete,
  fileResolvedDelete,

  dirMakeAct,
  dirMake,
  dirMakeForFile,

  // link

  _link_pre,
  _linkMultiple,
  _link_functor,

  fileRenameAct,
  fileRename,

  fileCopyAct,
  fileCopy,

  softLinkAct,
  softLink,

  hardLinkAct,
  hardLink,

  textLinkAct,
  textLink,

  /* qqq : cover routine textLink */

  fileExchange,

  // link

  hardLinkBreakAct,
  hardLinkBreak,
  softLinkBreakAct,
  softLinkBreak,

  filesAreHardLinkedAct,
  filesAreHardLinked,
  filesAreSoftLinked,
  filesAreTextLinked,

  // accessor

  _protocolsSet,
  _protocolSet,
  _originPathSet,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Medials,
  Statics,
  Forbids,
  Accessors,

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

_.assert( _.routineIs( Self.prototype.statsResolvedRead ) );
_.assert( _.objectIs( Self.prototype.statsResolvedRead.defaults ) );

// --
// export
// --

_.FileProvider[ Self.shortName ] = Self;

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.assert( _.FileProvider.Partial.prototype.statRead.defaults.resolvingSoftLink === 0 );
_.assert( _.FileProvider.Partial.prototype.statRead.defaults.resolvingTextLink === 0 );

})();
