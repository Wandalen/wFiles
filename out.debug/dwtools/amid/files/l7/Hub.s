( function _Hub_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _global = _global_;
  let _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );
}

//

let _global = _global_;
let _ = _global_.wTools;
let Routines = Object.create( null );
let FileRecord = _.FileRecord;
let Parent = _.FileProvider.Partial;
let Self = function wFileProviderHub( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Hub';

_.assert( _.routineIs( _.uri.join ) );
_.assert( _.routineIs( _.uri.normalize ) );
// _.assert( _.routineIs( _.uri.urisNormalize ) );
_.assert( _.routineIs( _.uri.isNormalized ) );

// --
// inter
// --

function init( o )
{
  let self = this;
  Parent.prototype.init.call( self, o );

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( o )
  if( o.defaultOrigin !== undefined )
  {
    debugger;
    throw _.err( 'not tested' );
  }

  if( o && o.providers )
  {
    self.providersRegister( o.providers );
  }
  else if( !o || !o.empty )
  if( _.fileProvider )
  {
    self.providerRegister( _.fileProvider );
    self.providerDefaultSet( _.fileProvider );
  }

}

// --
// provider
// --

function providerDefaultSet( provider )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( provider === null || provider instanceof _.FileProvider.Abstract );

  if( provider )
  {

    _.assert( _.arrayIs( provider.protocols ) && provider.protocols.length > 0 );
    _.assert( _.strIs( provider.originPath ) );

    self.defaultProvider = provider;
    self.defaultProtocol = provider.protocols[ 0 ];
    self.defaultOrigin = provider.originPath;

  }
  else
  {

    self.defaultProvider = null;
    self.defaultProtocol = null;
    self.defaultOrigin = null;

  }

}

//

function providersRegister( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( src instanceof _.FileProvider.Abstract )
  self.providerRegister( src );
  else if( _.arrayIs( src ) )
  for( let p = 0 ; p < src.length ; p++ )
  self.providerRegister( src[ p ] );
  else _.assert( 0, 'Unknown kind of argument', src );

  return self;
}

//

function providerRegister( fileProvider )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( _.arrayIs( fileProvider.protocols ) );
  _.assert( _.strDefined( fileProvider.protocol ), 'Cant register file provider without {-protocol-} defined', _.strQuote( fileProvider.nickName ) );
  _.assert( _.strDefined( fileProvider.originPath ) );
  _.assert( fileProvider.protocols && fileProvider.protocols.length, 'Cant register file provider without protocols', _.strQuote( fileProvider.nickName ) );

  {
    let protocolMap = self.providersWithProtocolMap;
    // let originMap = self.providersWithOriginMap;
    for( let p = 0 ; p < fileProvider.protocols.length ; p++ )
    {
      let protocol = fileProvider.protocols[ p ];
      if( protocolMap[ protocol ] )
      _.assert
      (
        !protocolMap[ protocol ] || protocolMap[ protocol ] === fileProvider,
        () => _.strQuote( fileProvider.nickName ) + ' is trying to reserve protocol, reserved by ' + _.strQuote( protocolMap[ protocol ].nickName )
      );
      protocolMap[ protocol ] = fileProvider;
      // originMap[ self.originsForProtocols( protocol ) ] = fileProvider;
    }
  }

  _.assert( !fileProvider.hub || fileProvider.hub === self, () => 'File provider ' + fileProvider.nickName + ' already has a hub ' + fileProvider.hub.nickName );
  fileProvider.hub = self;

  return self;
}

//

function providerUnregister( fileProvider )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( self.providersWithProtocolMap[ fileProvider.protocol ] === fileProvider );
  // _.assert( self.providersWithOriginMap[ fileProvider.originPath ] === fileProvider );
  _.assert( fileProvider.hub === self );

  delete self.providersWithProtocolMap[ fileProvider.protocol ];
  // delete self.providersWithOriginMap[ fileProvider.originPath ];
  fileProvider.hub = null;

  return self;
}

//

function providerForPath( url )
{
  let self = this;
  let path = self.path;

  if( _.strIs( url ) )
  url = path.parse( url );

  _.assert( _.mapIs( url ) );
  _.assert( ( url.protocols.length ) ? _.routineIs( url.protocols[ 0 ].toLowerCase ) : true );
  _.assert( arguments.length === 1, 'Expects single argument' );

  /* */

  let protocol = url.protocol || self.defaultProtocol;

  _.assert( _.strIs( protocol ) || protocol === null );

  if( protocol )
  protocol = protocol.toLowerCase();

  if( self.providersWithProtocolMap[ protocol ] )
  {
    return self.providersWithProtocolMap[ protocol ];
  }

  /* */

  return self.defaultProvider;
}

// --
// adapter
// --

function _recordFactoryFormEnd( recordFactory )
{
  let self = this;

  _.assert( recordFactory instanceof _.FileRecordFactory );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !recordFactory.effectiveFileProvider )
  debugger;

  if( !recordFactory.effectiveFileProvider )
  recordFactory.effectiveFileProvider = recordFactory.fileProvider.providerForPath( recordFactory.basePath );

  _.assert( recordFactory.effectiveFileProvider instanceof _.FileProvider.Abstract, 'No provider for base path', recordFactory.basePath, 'found' );

  recordFactory.basePath = recordFactory.effectiveFileProvider.localFromGlobal( recordFactory.basePath );

  if( recordFactory.stemPath !== null )
  recordFactory.stemPath = recordFactory.effectiveFileProvider.localFromGlobal( recordFactory.stemPath );

  return recordFactory;
}

//

function _recordFormBegin( record )
{
  let self = this;

  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );

  return record;
}

//

function _recordPathForm( record )
{
  let self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );

  // record.absoluteGlobalMaybe = record.absoluteGlobal;
  // record.realGlobalMaybe = record.realGlobal;

  return record;
}

//

function _recordFormEnd( record )
{
  let self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );

  // record.realGlobalMaybe = record.realGlobal;

  return record;
}

//

function _recordAbsoluteGlobalMaybeGet( record )
{
  let self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );
  return record.absoluteGlobal;
}

//

function _recordRealGlobalMaybeGet( record )
{
  let self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );
  return record.realGlobal;
}

//

function fieldPush()
{
  let self = this;

  Parent.prototype.fieldPush.apply( self, arguments );

  if( self.providersWithProtocolMap )
  for( let or in self.providersWithProtocolMap )
  {
    let provider = self.providersWithProtocolMap[ or ];
    provider.fieldPush.apply( provider, arguments )
  }

}

//

function fieldPop()
{
  let self = this;

  Parent.prototype.fieldPop.apply( self, arguments );

  if( self.providersWithProtocolMap )
  for( let or in self.providersWithProtocolMap )
  {
    let provider = self.providersWithProtocolMap[ or ];
    provider.fieldPop.apply( provider, arguments );
  }

}

// --
// path
// --

function localFromGlobal( filePath )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._localFromGlobal( filePath ).filePath;
}

//

function _localFromGlobal( filePath, provider )
{
  let self = this;
  let path = self.path;
  let r = { filePath : filePath, provider : provider };

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  // if( _.strHas( filePath, 'git+' ) )
  // debugger;

  r.originalPath = filePath;

  r.parsedPath = r.originalPath;
  if( _.strIs( filePath ) )
  r.parsedPath = path.parse( path.normalize( r.parsedPath ) );

  if( !r.provider )
  {
    _.assert( _.arrayIs( r.parsedPath.protocols ) );
    r.provider = self.providerForPath( r.parsedPath );
  }

  _.assert( _.objectIs( r.provider ), 'no provider for path', filePath );

  r.filePath = r.provider.localFromGlobal( r.parsedPath );

  _.assert( _.strIs( r.filePath ) );

  return r;
}

//

let localsFromGlobals = _.routineVectorize_functor
({
  routine : localFromGlobal,
  vectorizingMap : 0,
});

//

function pathNativizeAct( filePath )
{
  let self = this;
  let r = self._localFromGlobal.apply( self, arguments );
  r.filePath = r.provider.path.nativize( r.filePath );
  xxx
  _.assert( _.objectIs( r.provider ), 'no provider for path', filePath );
  _.assert( arguments.length === 1 );
  return r;
}

//

function pathCurrentAct()
{
  let self = this;

  if( self.defaultProvider )
  return self.defaultProvider.path.current.apply( self.defaultProvider.path, arguments );

  _.assert( 0, 'Default provider is not set for the Hub', self.nickName );
}

//

function pathResolveLinkFull_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // if( !o.resolvingSoftLink && !o.resolvingTextLink )
  // return o.filePath;

  let r = self._localFromGlobal( o.filePath );
  o.filePath = r.filePath;

  let result = r.provider.pathResolveLinkFull.body.call( r.provider, o );

  // _.assert( !!result );

  if( result === null )
  return null;

  result = self.path.join( r.provider.originPath, result );

  if( result === o.filePath )
  {
    debugger;
    _.assert( 0, 'not tested' );
    // return r.originalPath;
  }

  return result;
}

_.routineExtend( pathResolveLinkFull_body, Parent.prototype.pathResolveLinkFull );

let pathResolveLinkFull = _.routineFromPreAndBody( Parent.prototype.pathResolveLinkFull.pre, pathResolveLinkFull_body );

//

function pathResolveLinkTail_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // if( !o.resolvingSoftLink && !o.resolvingTextLink )
  // return o.filePath;

  let r = self._localFromGlobal( o.filePath );
  o.filePath = r.filePath;

  // if( o.filePath === '/src/a1' )
  // debugger;

  let result = r.provider.pathResolveLinkTail.body.call( r.provider, o );

  if( result === null )
  return null;

  if( result.filePath === null )
  return null;

  // _.assert( !!result );

  result.filePath = self.path.join( r.provider.originPath, result.filePath );
  result.absolutePath = self.path.join( r.provider.originPath, result.absolutePath );

  // if( result === o.filePath )
  // {
  //   debugger;
  //   _.assert( 0, 'not tested' );
  //   // return r.originalPath;
  // }

  return result;
}

_.routineExtend( pathResolveLinkTail_body, Parent.prototype.pathResolveLinkTail );

let pathResolveLinkTail = _.routineFromPreAndBody( Parent.prototype.pathResolveLinkTail.pre, pathResolveLinkTail_body );

//

function pathResolveSoftLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let r = self._localFromGlobal( o.filePath );

  o.filePath = r.filePath;

  let result = r.provider.pathResolveSoftLink.body.call( r.provider, o );

  _.assert( !!result );

  if( result === o.filePath )
  return r.originalPath;

  return result;
}

_.routineExtend( pathResolveSoftLink_body, Parent.prototype.pathResolveSoftLink );

let pathResolveSoftLink = _.routineFromPreAndBody( Parent.prototype.pathResolveSoftLink.pre, pathResolveSoftLink_body );

//

function fileRead_body( o )
{
  let self = this;

  // debugger;

  _.assert( arguments.length === 1 );

  o.filePath = self.pathResolveLinkFull
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  let r = self._localFromGlobal( o.filePath );
  // let o2 = _.mapOnly( o, self.statReadAct.defaults );
  let o2 = _.mapExtend( null, o );

  o2.resolvingSoftLink = 0;
  o2.filePath = r.filePath;
  let result = r.provider.fileRead.body.call( r.provider, o2 );

  return result;
}

_.routineExtend( fileRead_body, Parent.prototype.fileRead );

let fileRead = _.routineFromPreAndBody( Parent.prototype.fileRead.pre, fileRead_body );

// --
// linker
// --

function _link_functor( fop )
{
  fop = _.routineOptions( _link_functor, arguments );

  let routine = fop.routine;
  let routineName = routine.name;
  let onDifferentProviders = fop.onDifferentProviders;
  let allowDifferentProviders = fop.allowDifferentProviders;

  _.assert( _.strDefined( routineName ) );
  _.assert( _.objectIs( routine.defaults ) );
  _.assert( routine.paths === undefined );
  _.assert( _.objectIs( routine.having ) );

  _.routineExtend( hubLink, routine );

  let defaults = hubLink.defaults;

  _.assert( defaults.srcPath !== undefined );
  _.assert( defaults.dstPath !== undefined );

  return hubLink;

  /* */

  function hubLink( o )
  {
    let self = this;

    _.assert( arguments.length === 1, 'Expects single argument' );

    let dst = self._localFromGlobal( o.dstPath );
    let src = self._localFromGlobal( o.srcPath );

    _.assert( !!dst.provider, 'no provider for path', o.dstPath );
    _.assert( !!src.provider, 'no provider for path', o.srcPath );

    if( dst.provider !== src.provider )
    {
      if( allowDifferentProviders )
      {
      }
      else
      {
        if( onDifferentProviders )
        return onDifferentProviders.call( self, o, dst, src, routine );
        else
        throw _.err( 'Cant ' + routineName + ' files of different file providers :\n' + o.dstPath + '\n' + o.srcPath );
      }
    }
    else
    {
      o.srcPath = src.filePath;
    }

    o.dstPath = dst.filePath;

    return dst.provider[ routineName ]( o );
  }

}

_link_functor.defaults =
{
  routine : null,
  onDifferentProviders : null,
  allowDifferentProviders : 0,
}

//

let hardLinkAct = _link_functor({ routine : Parent.prototype.hardLinkAct });
let fileRenameAct = _link_functor({ routine : Parent.prototype.fileRenameAct });

let softLinkAct = _link_functor({ routine : Parent.prototype.softLinkAct, allowDifferentProviders : 1 });
let textLinkAct = _link_functor({ routine : Parent.prototype.textLinkAct, allowDifferentProviders : 1 });

//

function _fileCopyActDifferent( o, dst, src, routine )
{
  let self = this;
  let path = self.path;

  /* qqq : implement async */
  _.assert( o.sync, 'not implemented' );

  if( src.provider.isSoftLink( src.filePath ) )
  {
    let resolvedPath = src.provider.pathResolveSoftLink( src.filePath );
    return dst.provider.softLink
    ({
      dstPath : dst.filePath,
      srcPath : path.join( src.parsedPath.origin, resolvedPath ),
      allowingMissed : 1,
    });
  }

  let read = src.provider.fileRead
  ({
    filePath : src.filePath,
    resolvingTextLink : 0,
    resolvingSoftLink : 0,
    encoding : 'original.type',
    sync : 1,
  });

  let result = dst.provider.fileWrite
  ({
    filePath : dst.filePath,
    data : read,
    encoding : 'original.type',
  });

  return result;
}

let fileCopyAct = _link_functor({ routine : Parent.prototype.fileCopyAct, onDifferentProviders : _fileCopyActDifferent });

// --
// link
// --

function filesAreHardLinkedAct( dstPath, srcPath )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  let dst = self._localFromGlobal( dstPath );
  let src = self._localFromGlobal( srcPath );

  _.assert( !!dst.provider, 'no provider for path', dstPath );
  _.assert( !!src.provider, 'no provider for path', srcPath );

  if( dst.provider !== src.provider )
  return false;

  // debugger;
  // _.assert( 0, 'not tested' );

  return dst.provider.filesAreHardLinkedAct( dst.filePath, src.filePath );
}

// --
//
// --

function _defaultProviderSet( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( src )
  {
    _.assert( src instanceof _.FileProvider.Abstract );
    self[ defaultProviderSymbol ] = src;
    self[ defaultProtocolSymbol ] = src.protocol;
    self[ defaultOriginSymbol ] = src.originPath;
  }
  else
  {
    _.assert( src === null )
    self[ defaultProviderSymbol ] = null;
    self[ defaultProtocolSymbol ] = null;
    self[ defaultOriginSymbol ] = null;
  }

}

//

function _defaultProtocolSet( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( src )
  {
    _.assert( _.strIs( src ) );
    self[ defaultProtocolSymbol ] = src;
    self[ defaultOriginSymbol ] = src + '://';
  }
  else
  {
    _.assert( src === null )
    self[ defaultProtocolSymbol ] = null;
    self[ defaultOriginSymbol ] = null;
  }

}

//

function _defaultOriginSet( src )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( src )
  {
    _.assert( _.strIs( src ) );
    _.assert( path.isGlobal( src ) );
    let protocol = _.strRemoveEnd( src, '://' );
    _.assert( !path.isGlobal( protocol ) );
    self[ defaultProtocolSymbol ] = protocol;
    self[ defaultOriginSymbol ] = src;
  }
  else
  {
    _.assert( src === null )
    self[ defaultProtocolSymbol ] = null;
    self[ defaultOriginSymbol ] = null;
  }

}

// //
//
// function _verbosityChange()
// {
//   let self = this;
//
//   _.assert( arguments.length === 0 );
//
//   for( var f in self.providersWithProtocolMap )
//   {
//     let fileProvider = self.providersWithProtocolMap[ f ];
//     if( fileProvider.verbosity !== self.verbosity )
//     debugger;
//     // debugger;
//     fileProvider.verbosity = self.verbosity;
//   }
//
// }

// --
//
// --

function routinesGenerate()
{
  let self = this;

  let KnownRoutineFields =
  {
    name : null,
    pre : null,
    body : null,
    defaults : null,
    // paths : null,
    having : null,
    encoders : null,
    operates : null,
  }

  for( let r in Parent.prototype ) (function()
  {
    let name = r;
    let original = Parent.prototype[ r ];

    if( !original )
    return;

    var having = original.having;

    if( !having )
    return;

    _.assert( !!original );
    _.assertMapHasOnly( original, KnownRoutineFields );

    if( having.hubRedirecting === 0 || having.hubRedirecting === false )
    return;

    if( !having.driving )
    return;

    if( having.kind === 'path' )
    return;

    if( having.kind === 'inter' )
    return;

    if( having.kind === 'record' )
    return;

    if( having.aspect === 'body' )
    return;

    if(  original.defaults )
    _.assert( _.objectIs( original.operates ) );
    if(  original.operates )
    _.assert( _.objectIs( original.defaults ) );

    let hubResolving = having.hubResolving;
    let havingBare = having.driving;
    var operates = original.operates;
    let operatesLength = operates ? _.mapKeys( operates ).length : 0;
    let pre = original.pre;
    let body = original.body;

    /* */

    function resolve( o )
    {
      let self = this;
      let provider = self;

      for( let p in operates )
      if( o[ p ] )
      {
        if( operatesLength === 1 )
        {
          let r;

          // if( havingBare )
          // debugger;
          //
          // _.assert( o.resolvingSoftLink !== undefined );
          // _.assert( o.resolvingTextLink !== undefined );
          // xxx

          if( hubResolving )
          o[ p ] = self.pathResolveLinkFull
          ({
            filePath : o[ p ],
            resolvingSoftLink : o.resolvingSoftLink || false,
            resolvingTextLink : o.resolvingTextLink || false,
          });

          r = self._localFromGlobal( o[ p ] );
          o[ p ] = r.filePath;
          provider = r.provider;

          _.assert( _.objectIs( provider ), 'No provider for path', o[ p ] );

        }
        else
        {
          o[ p ] = self.localFromGlobal( o[ p ] );
        }
      }

      return provider;
    }

    /* */

    let wrap = Routines[ r ] = function hub( o )
    {
      let self = this;

      if( arguments.length === 1 && wrap.defaults )
      {
        if( _.strIs( o ) )
        o = { filePath : o }
      }

      if( pre )
      o = pre.call( this, wrap, arguments );
      else if( wrap.defaults )
      _.routineOptions( wrap, o );

      let provider = self;

      provider = resolve.call( self, o );

      if( provider === self )
      {
        _.assert( _.routineIs( original ), 'No original method for', name );
        return original.call( provider, o );
      }
      else
      {
        _.assert( _.routineIs( provider[ name ] ) );
        return provider[ name ].call( provider, o );
      }
    }

    _.routineExtend( wrap, original );

    // wrap.having = Object.create( original.having );
    //
    // if( original.defaults )
    // {
    //   wrap.defaults = Object.create( original.defaults );
    //   wrap.paths = Object.create( original.paths );
    // }
    //
    // if( original.encoders )
    // wrap.encoders = Object.create( original.encoders );
    //
    // if( original.pre )
    // wrap.pre = original.pre;
    //
    // if( original.body )
    // wrap.body = original.body;

  })();

}

routinesGenerate();

//

let FilteredRoutines =
{

  // path

  pathResolveSoftLinkAct : Routines.pathResolveSoftLinkAct,
  pathResolveTextLinkAct : Routines.pathResolveTextLinkAct,

  // read

  fileReadAct : Routines.fileReadAct,
  streamReadAct : Routines.streamReadAct,
  hashReadAct : Routines.hashReadAct,
  dirReadAct : Routines.dirReadAct,
  statReadAct : Routines.statReadAct,
  fileExistsAct : Routines.fileExistsAct,

  // write

  fileWriteAct : Routines.fileWriteAct,
  streamWriteAct : Routines.streamWriteAct,
  fileTimeSetAct : Routines.fileTimeSetAct,
  fileDeleteAct : Routines.fileDeleteAct,
  dirMakeAct : Routines.dirMakeAct,

  // link

  hardLinkBreakAct : Routines.hardLinkBreakAct,
  softLinkBreakAct : Routines.softLinkBreakAct,

}

// --
// path
// --

let Path = _.uri.CloneExtending({ fileProvider : Self });
_.assert( _.prototypeHas( Path, _.uri ) );

// --
// relationship
// --

let defaultProviderSymbol = Symbol.for( 'defaultProvider' );
let defaultProtocolSymbol = Symbol.for( 'defaultProtocol' );
let defaultOriginSymbol = Symbol.for( 'defaultOrigin' );

let Composes =
{

  defaultProtocol : null,
  providersWithProtocolMap : _.define.own({}),

  safe : 0,

}

let Aggregates =
{
}

let Associates =
{
  defaultProvider : null,
}

let Restricts =
{
}

let Medials =
{
  empty : 0,
  providers : null,
  defaultOrigin : null,
}

let Accessors =
{
  defaultProvider : 'defaultProvider',
  defaultProtocol : 'defaultProtocol',
  defaultOrigin : 'defaultOrigin',
}

let Statics =
{
  Path : Path,
}

let Forbids =
{
  providersWithOriginMap : 'providersWithOriginMap',
}

// --
// declare
// --

let Proto =
{

  init,

  // provider

  providerDefaultSet,
  providerRegister,
  providerUnregister,
  providersRegister,
  providerForPath,

  // adapter

  _recordFactoryFormEnd,
  _recordFormBegin,
  _recordPathForm,
  _recordFormEnd,

  _recordAbsoluteGlobalMaybeGet,
  _recordRealGlobalMaybeGet,

  fieldPush,
  fieldPop,

  // path

  localFromGlobal,
  _localFromGlobal,
  localsFromGlobals,

  pathCurrentAct,

  pathResolveLinkFull,
  pathResolveLinkTail,
  pathResolveSoftLink,

  //

  fileRead,

  // linker

  _link_functor,

  hardLinkAct,
  fileRenameAct,

  softLinkAct,
  textLinkAct,

  fileCopyAct,

  // link

  filesAreHardLinkedAct,

  // accessor

  _defaultProviderSet,
  _defaultProtocolSet,
  _defaultOriginSet,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Medials,
  Accessors,
  Statics,
  Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );

//

_.mapSupplementOwn( Self.prototype, FilteredRoutines );

let missingMap = Object.create( null );
for( let r in Routines )
{
  _.assert( !!Self.prototype[ r ], 'routine', r, 'does not exist in prototype' );
  if( !_.mapOwnKey( Self.prototype, r ) && Routines[ r ] !== Self.prototype[ r ] )
  missingMap[ r ] = 'Routines.' + r;
}

_.assert( !_.mapKeys( missingMap ).length, 'routine(s) were not written into Proto explicitly', '\n', _.toStr( missingMap, { stringWrapper : '' } ) );
_.assert( !FilteredRoutines.pathResolveLinkFull );
_.assert( !( 'pathResolveLinkFull' in FilteredRoutines ) );
_.assertMapHasNoUndefine( FilteredRoutines );
_.assertMapHasNoUndefine( Proto );
_.assertMapHasNoUndefine( Self );
_.assert( _.prototypeHas( Self.prototype.Path, _.uri ) );
_.assert( Self.Path === Self.prototype.Path );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
