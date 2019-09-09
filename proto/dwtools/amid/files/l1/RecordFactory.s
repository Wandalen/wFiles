( function _FileRecordFactory_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

/**
 * @class wFileRecordFactory
 * @memberof module:Tools/mid/Files
*/

let _global = _global_;
let _ = _global_.wTools;
let Parent = _.FileRecordContext;
let Self = function wFileRecordFactory( o )
{
  return _.workpiece.construct( Self, this, arguments );
  // if( !( this instanceof Self ) )
  // if( o instanceof Self && arguments.length === 1 )
  // {
  //   _.assert( arguments.length === 1, 'Expects single argument' );
  //   return o;
  // }
  // else
  // {
  //   return new( _.constructorJoin( Self, arguments ) );
  // }
  // return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'FileRecordFactory';

_.assert( !_.FileRecordFactory );

// --
// routine
// --

function init( o )
{
  let factory = this;

  factory[ usingSoftLinkSymbol ] = null;
  factory[ resolvingSoftLinkSymbol ] = null;
  factory[ usingTextLinkSymbol ] = null;
  factory[ resolvingTextLinkSymbol ] = null;
  factory[ statingSymbol ] = null;
  factory[ safeSymbol ] = null;

  _.assert( arguments.length === 0 || arguments.length === 1, 'Expects single argument' );

  _.workpiece.initFields( factory );
  Object.preventExtensions( factory );

  /* */

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let src = arguments[ a ];
    if( _.mapIs( src ) )
    Object.assign( factory, src );
    else
    Object.assign( factory, _.mapOnly( src, Self.prototype.fieldsOfCopyableGroups ) );
  }

  return factory;
}

// //
//
// /**
//  * @summary Creates factory instance ignoring unknown options.
//  * @param {Object} o Options map.
//  * @function TolerantFrom
//  * @memberof module:Tools/mid/Files.wFileRecordFactory
// */
//
// function TolerantFrom( o )
// {
//   _.assert( arguments.length >= 1, 'Expects at least one argument' );
//   _.assert( _.objectIs( Self.prototype.Composes ) );
//   o = _.mapsExtend( null, arguments );
//   return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
// }

//

function _formAssociations()
{
  let factory = this;

  _.assert( factory.formed === 0 );

  /* */

  if( factory.filter )
  {
    factory.system = factory.system || factory.filter.system;
    factory.effectiveProvider = factory.effectiveProvider || factory.filter.effectiveProvider;
    factory.defaultProvider = factory.defaultProvider || factory.filter.defaultProvider;
  }

  /* */

  // /* find file system */
  //
  // if( !factory.system )
  // if( factory.effectiveProvider && factory.effectiveProvider instanceof _.FileProvider.System )
  // {
  //   factory.system = factory.effectiveProvider;
  //   factory.effectiveProvider = null;
  // }
  //
  // if( !factory.system )
  // if( factory.effectiveProvider && factory.effectiveProvider.system && factory.effectiveProvider.system instanceof _.FileProvider.System )
  // {
  //   factory.system = factory.effectiveProvider.system;
  // }
  //
  // if( !factory.system )
  // if( factory.defaultProvider && factory.defaultProvider instanceof _.FileProvider.System )
  // {
  //   factory.system = factory.defaultProvider;
  // }
  //
  // if( !factory.system )
  // if( factory.defaultProvider && factory.defaultProvider.system && factory.defaultProvider.system instanceof _.FileProvider.System )
  // {
  //   factory.system = factory.defaultProvider.system;
  // }
  //
  // if( factory.system )
  // if( factory.system.system && factory.system.system !== factory.system )
  // {
  //   _.assert( !( factory.system instanceof _.FileProvider.System ) );
  //   if( !factory.effectiveProvider )
  //   factory.effectiveProvider = factory.system;
  //   factory.system = factory.system.system;
  // }
  //
  // /* find effective provider */
  //
  // if( factory.effectiveProvider && factory.effectiveProvider instanceof _.FileProvider.System )
  // {
  //   _.assert( factory.system === null || factory.system === factory.effectiveProvider );
  //   factory.system = factory.effectiveProvider;
  //   factory.effectiveProvider = null;
  // }
  //
  // /* reset system */
  //
  // if( factory.effectiveProvider && factory.effectiveProvider.system )
  // {
  //   _.assert( factory.system === null || factory.system === factory.effectiveProvider.system );
  //   factory.system = factory.effectiveProvider.system;
  // }
  //
  // /* find default provider */
  //
  // if( !factory.defaultProvider )
  // {
  //   factory.defaultProvider = factory.defaultProvider || factory.effectiveProvider || factory.system;
  // }
  //
  // /* reset system */
  //
  // if( factory.system && !( factory.system instanceof _.FileProvider.System ) )
  // {
  //   _.assert( factory.system === factory.defaultProvider || factory.system === factory.effectiveProvider )
  //   factory.system = null;
  // }

  // if( factory.system )
  // {
  //   if( factory.system.system && factory.system.system !== factory.system )
  //   {
  //     _.assert( factory.effectiveProvider === null || factory.effectiveProvider === factory.system );
  //     factory.effectiveProvider = factory.system;
  //     factory.system = factory.system.system;
  //   }
  // }
  //
  // if( factory.effectiveProvider )
  // {
  //   if( factory.effectiveProvider instanceof _.FileProvider.System )
  //   {
  //     _.assert( factory.system === null || factory.system === factory.effectiveProvider );
  //     factory.system = factory.effectiveProvider;
  //     factory.effectiveProvider = null;
  //   }
  // }
  //
  // if( factory.effectiveProvider && factory.effectiveProvider.system )
  // {
  //   _.assert( factory.system === null || factory.system === factory.effectiveProvider.system );
  //   factory.system = factory.effectiveProvider.system;
  // }
  //
  // if( !factory.defaultProvider )
  // {
  //   factory.defaultProvider = factory.defaultProvider || factory.effectiveProvider || factory.system;
  // }

  /* */

  // _.assert( !factory.system || factory.system instanceof _.FileProvider.Abstract, 'Expects {- factory.system -}' );
  // _.assert( factory.defaultProvider instanceof _.FileProvider.Abstract );
  // _.assert( !factory.effectiveProvider || !( factory.effectiveProvider instanceof _.FileProvider.System ) );

  return Parent.prototype._formAssociations.apply( factory, arguments );
}

//

function form()
{
  let factory = this;

  _.assert( arguments.length === 0 );
  _.assert( !factory.formed );

  /* */

  factory._formAssociations();

  let system = factory.system || factory.effectiveProvider || factory.defaultProvider;
  let path = system.path;

  /* */

  if( factory.basePath )
  {

    _.assert( !!path );

    factory.basePath = path.from( factory.basePath );
    factory.basePath = path.canonize( factory.basePath );

    if( !factory.effectiveProvider )
    factory.effectiveProvider = system.providerForPath( factory.basePath );

    if( Config.debug )
    if( _.path.isGlobal( factory.basePath ) )
    {
      let url = _.uri.parse( factory.basePath );
    }

  }

  /* */

  if( factory.dirPath )
  {
    factory.dirPath = path.from( factory.dirPath );
    factory.dirPath = path.canonize( factory.dirPath );

    if( factory.basePath )
    factory.dirPath = path.join( factory.basePath, factory.dirPath );

    if( Config.debug )
    if( _.path.isGlobal( factory.dirPath ) )
    {
      let url = _.uri.parse( factory.dirPath );
    }
  }

  if( !factory.stemPath )
  {
    factory.stemPath = path.canonize( path.join( factory.basePath, factory.dirPath || '' ) );
  }
  else if( factory.stemPath )
  {
    factory.stemPath = path.canonize( path.join( factory.basePath, factory.dirPath || '', factory.stemPath ) );
  }

  if( !factory.basePath )
  if( factory.dirPath )
  {
    factory.basePath = factory.dirPath;
  }

  if( !factory.basePath && factory.filter && factory.stemPath )
  {
    _.assert( factory.filter.formed === 5 );
    factory.basePath = factory.filter.formedBasePath[ factory.stemPath ];
  }

  /* */

  if( !factory.system )
  factory.system = factory.defaultProvider;

  if( !factory.effectiveProvider )
  factory.effectiveProvider = factory.defaultProvider;

  _.assert( !!factory.system );

  factory.system._recordFactoryFormEnd( factory );

  /* */

  if( Config.debug )
  {

    _.assert( factory.system instanceof _.FileProvider.Abstract );
    _.assert( path.isAbsolute( factory.basePath ) );
    _.assert( factory.dirPath === null || path.is( factory.dirPath ) );
    _.assert( path.isAbsolute( factory.stemPath ) );

    if( factory.dirPath )
    _.assert( _.path.isGlobal( factory.dirPath ) || path.isAbsolute( factory.dirPath ), () => '{-o.dirPath-} should be absolute path' + _.strQuote( factory.dirPath ) );

    _.assert( _.strDefined( factory.basePath ) );
    _.assert( _.path.isGlobal( factory.basePath ) || path.isAbsolute( factory.basePath ), () => '{-o.basePath-} should be absolute path' + _.strQuote( factory.basePath ) );

    _.assert( factory.filter === null || factory.filter instanceof _.FileRecordFilter );

    if( factory.filter )
    {
      _.assert( factory.filter.formed === 5 );
      _.assert( !!factory.filter.formedBasePath );
      _.assert( !!factory.filter.src || factory.filter.formedBasePath[ factory.stemPath ] === factory.basePath ); // yyy
      _.assert( factory.filter.effectiveProvider === factory.effectiveProvider );
      _.assert( factory.filter.system === factory.system || factory.filter.system === null );
      _.assert( factory.filter.defaultProvider === factory.defaultProvider );
    }

  }

  factory.formed = 1;
  Object.freeze( factory );
  return factory;
}

//

/**
 * @summary Creates instance of FileRecord.
 * @param {Object} o Options map.
 * @function record
 * @memberof module:Tools/mid/Files.wFileRecordFactory#
*/

function record( o )
{
  let factory = this;

  if( o instanceof _.FileRecord )
  {
    _.assert( o.factory === factory || !!o.factory );
    return o;
  }

  let op = Object.create( null );

  if( _.strIs( o ) )
  {
    o = { input : o }
  }

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.input ), () => 'Expects string {-o.input-}, but got ' + _.strType( o.input ) );
  _.assert( o.factory === undefined || o.factory === factory );

  o.factory = factory;

  return _.FileRecord( o );
}

//

/**
 * @summary Creates instances of FileRecord for provided file paths.
 * @param {Array} filePaths Paths to files.
 * @function records
 * @memberof module:Tools/mid/Files.wFileRecordFactory#
*/

/**
 * @summary Creates instances of FileRecord for provided file paths ignoring files that don't exist in file system.
 * @param {Array} filePaths Paths to files.
 * @function recordsFiltered
 * @memberof module:Tools/mid/Files.wFileRecordFactory#
*/

function recordsFiltered( filePaths )
{
  var factory = this;

  _.assert( arguments.length === 1 );

  var result = factory.records( filePaths );

  for( var r = result.length-1 ; r >= 0 ; r-- )
  if( !result[ r ].stat )
  result.splice( r,1 );

  return result;
}

//

function _usingSoftLinkGet()
{
  let factory = this;

  if( factory[ usingSoftLinkSymbol ] !== null )
  return factory[ usingSoftLinkSymbol ];

  if( factory.effectiveProvider )
  return factory.effectiveProvider.usingSoftLink;
  else if( factory.system )
  return factory.system.usingSoftLink;

  return factory[ usingSoftLinkSymbol ];
}

//

function _resolvingSoftLinkSet( src )
{
  let factory = this;
  factory[ resolvingSoftLinkSymbol ] = src;
}

//

function _resolvingSoftLinkGet()
{
  let factory = this;

  if( !factory.resolving )
  return false;

  if( factory[ resolvingSoftLinkSymbol ] !== null )
  return factory[ resolvingSoftLinkSymbol ];

  if( factory.effectiveProvider )
  return factory.effectiveProvider.resolvingSoftLink;
  else if( factory.system )
  return factory.system.resolvingSoftLink;

  return factory[ resolvingSoftLinkSymbol ];
}

//

function _usingTextLinkGet()
{
  let factory = this;

  /* using knows nothing about resolving */
  // if( !factory.resolving )
  // return false;

  if( factory[ usingTextLinkSymbol ] !== null )
  return factory[ usingTextLinkSymbol ];

  if( factory.effectiveProvider )
  return factory.effectiveProvider.usingTextLink;
  else if( factory.system )
  return factory.system.usingTextLink;

  return factory[ usingTextLinkSymbol ];
}

//

function _resolvingTextLinkGet()
{
  let factory = this;

  if( !factory.resolving )
  return false;

  if( factory[ resolvingTextLinkSymbol ] !== null )
  return factory[ resolvingTextLinkSymbol ];

  if( factory.effectiveProvider )
  return factory.effectiveProvider.resolvingTextLink;
  else if( factory.system )
  return factory.system.resolvingTextLink;

  return factory[ resolvingTextLinkSymbol ];
}

//

function _statingGet()
{
  let factory = this;

  if( factory[ statingSymbol ] !== null )
  return factory[ statingSymbol ];

  if( factory.effectiveProvider )
  return factory.effectiveProvider.stating;
  else if( factory.system )
  return factory.system.stating;

  return factory[ statingSymbol ];
}

//

function _safeGet()
{
  let factory = this;

  if( factory[ safeSymbol ] !== null )
  return factory[ safeSymbol ];

  if( factory.effectiveProvider )
  return factory.effectiveProvider.safe;
  else if( factory.system )
  return factory.system.safe;

  return factory[ safeSymbol ];
}

// --
// relation
// --

let usingSoftLinkSymbol = Symbol.for( 'usingSoftLink' );
let resolvingSoftLinkSymbol = Symbol.for( 'resolvingSoftLink' );
let usingTextLinkSymbol = Symbol.for( 'usingTextLink' );
let resolvingTextLinkSymbol = Symbol.for( 'resolvingTextLink' );
let statingSymbol = Symbol.for( 'stating' );
let safeSymbol = Symbol.for( 'safe' );

/**
 * @typedef {Object} Fields
 * @property {String} dirPath
 * @property {String} basePath
 * @property {String} stemPath
 * @property {Boolean} strict=1
 * @property {Boolean} allowingMissed
 * @property {Boolean} allowingCycled
 * @property {Boolean} resolvingSoftLink
 * @property {Boolean} resolvingTextLink
 * @property {Boolean} usingTextLink
 * @property {Boolean} stating
 * @property {Boolean} resolving
 * @property {Boolean} safe
 * @memberof module:Tools/mid/Files.wFileRecordFactory
*/

let Composes =
{

  dirPath : null,
  basePath : null,
  stemPath : null,

  strict : 1,
  allowingMissed : 0,
  allowingCycled : 0,
  resolvingSoftLink : null,
  resolvingTextLink : null,
  usingSoftLink : null,
  usingTextLink : null,
  stating : null,
  resolving : 1,
  safe : null,

}

let Aggregates =
{
}

let Associates =
{
  system : null,
  effectiveProvider : null,
  defaultProvider : null,
  filter : null,
}

let Medials =
{
}

let Restricts =
{
  formed : 0,
}

let Statics =
{
  // TolerantFrom : TolerantFrom,
}

let Forbids =
{

  dir : 'dir',
  sync : 'sync',
  relative : 'relative',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',
  maskAll : 'maskAll',
  maskTerminal : 'maskTerminal',
  maskDirectory : 'maskDirectory',
  notOlder : 'notOlder',
  notNewer : 'notNewer',
  notOlderAge : 'notOlderAge',
  notNewerAge : 'notNewerAge',
  originPath : 'originPath',
  onRecord : 'onRecord',
  fileProviderEffective : 'fileProviderEffective',
  fileProvider : 'fileProvider',
  hubFileProvider : 'hubFileProvider',
  effectiveFileProvider : 'effectiveFileProvider',
  defaultFileProvider : 'defaultFileProvider',

}

let Accessors =
{

  resolvingSoftLink : 'resolvingSoftLink',
  usingSoftLink : 'usingSoftLink',

  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',

  stating : 'stating',
  safe : 'safe',

}

// --
// declare
// --

let Proto =
{

  init,
  // TolerantFrom,

  _formAssociations,
  form,

  record,
  records : _.routineVectorize_functor( record ),
  recordsFiltered,

  _usingSoftLinkGet,
  _resolvingSoftLinkSet,
  _resolvingSoftLinkGet,

  _usingTextLinkGet,
  _resolvingTextLinkGet,

  _statingGet,
  _safeGet,

  /* */

  Composes,
  Aggregates,
  Associates,
  Restricts,
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

// _.Copyable.mixin( Self );

//

_[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
