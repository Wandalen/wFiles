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

function _recordFactoryFormEnd( recordContext )
{
  let self = this;

  _.assert( recordContext instanceof _.FileRecordFactory );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !recordContext.effectiveFileProvider )
  debugger;

  if( !recordContext.effectiveFileProvider )
  recordContext.effectiveFileProvider = recordContext.fileProvider.providerForPath( recordContext.basePath );

  _.assert( _.objectIs( recordContext.effectiveFileProvider ), 'No provider for path', recordContext.basePath );

  recordContext.basePath = recordContext.effectiveFileProvider.localFromGlobal( recordContext.basePath );

  if( recordContext.stemPath !== null )
  recordContext.stemPath = recordContext.effectiveFileProvider.localFromGlobal( recordContext.stemPath );

  return recordContext;
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

  record.hubAbsolute = record.absoluteUri;
  record.realAbsolute = record.realUri;

  return record;
}

//

function _recordFormEnd( record )
{
  let self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );

  record.realAbsolute = record.realUri;

  return record;
}

//

function fieldSet()
{
  let self = this;

  Parent.prototype.fieldSet.apply( self, arguments );

  if( self.providersWithProtocolMap )
  for( let or in self.providersWithProtocolMap )
  {
    let provider = self.providersWithProtocolMap[ or ];
    provider.fieldSet.apply( provider, arguments )
  }

}

//

function fieldReset()
{
  let self = this;

  Parent.prototype.fieldReset.apply( self, arguments );

  if( self.providersWithProtocolMap )
  for( let or in self.providersWithProtocolMap )
  {
    let provider = self.providersWithProtocolMap[ or ];
    provider.fieldReset.apply( provider, arguments );
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

function _pathResolveLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  /* needed to return local path for softlink src */
  if( !o.resolvingSoftLink && !o.resolvingTextLink )
  return o.filePath;

  let r = self._localFromGlobal( o.filePath );
  o.filePath = r.filePath;

  let result = r.provider.pathResolveLink.body.call( r.provider, o );

  _.assert( !!result );

  result = self.path.join( r.provider.originPath, result );

  if( result === o.filePath )
  {
    debugger;
    _.assert( 0, 'not implemented' );
    return r.originalPath;
  }

  return result;
}

_.routineExtend( _pathResolveLink_body, Parent.prototype.pathResolveLink );

let pathResolveLink = _.routineFromPreAndBody( Parent.prototype.pathResolveLink.pre, _pathResolveLink_body );

//

function _pathResolveSoftLink_body( o )
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

_.routineExtend( _pathResolveSoftLink_body, Parent.prototype.pathResolveSoftLink );

let pathResolveSoftLink = _.routineFromPreAndBody( Parent.prototype.pathResolveSoftLink.pre, _pathResolveSoftLink_body );

//

// function pathResolveHardLink_body( o )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   let r = self._localFromGlobal( o.filePath );
//
//   o.filePath = r.filePath;
//
//   let result = r.provider.pathResolveHardLink.body.call( r.provider, o );
//
//   _.assert( !!result );
//
//   if( result === o.filePath )
//   return r.originalPath;
//
//   return result;
// }
//
// _.routineExtend( pathResolveHardLink_body, Parent.prototype.pathResolveHardLink );
//
// let pathResolveHardLink = _.routineFromPreAndBody( Parent.prototype.pathResolveHardLink.pre, pathResolveHardLink_body );

//

function pathCurrentAct()
{
  let self = this;

  if( self.defaultProvider )
  return self.defaultProvider.path.current.apply( self.defaultProvider.path, arguments );

  _.assert( 0, 'Default provider is not set for the Hub', self.nickName );
}

// --
//
// --

// function statResolvedRead_body( o )
// {
//   let self = this;
//
//   // debugger;
//
//   _.assert( arguments.length === 1 );
//
//   o.filePath = self.pathResolveLink
//   ({
//     filePath : o.filePath,
//     resolvingSoftLink : o.resolvingSoftLink,
//     resolvingTextLink : o.resolvingTextLink,
//   });
//
//   let r = self._localFromGlobal( o.filePath );
//   let o2 = _.mapOnly( o, self.statReadAct.defaults );
//
//   o2.resolvingSoftLink = 0;
//   o2.filePath = r.filePath;
//   let result = r.provider.statReadAct.call( r.provider, o2 );
//
//   return result;
// }
//
// _.routineExtend( statResolvedRead_body, Parent.prototype.statResolvedRead );
//
// let statResolvedRead = _.routineFromPreAndBody( Parent.prototype.statResolvedRead.pre, statResolvedRead_body );

//

function fileRead_body( o )
{
  let self = this;

  // debugger;

  _.assert( arguments.length === 1 );

  o.filePath = self.pathResolveLink
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

//

// function _filesReflect_body( o )
// {
//   let self = this;
//   let path = self.path;
//
//   if(  )
//
//   return o.result;
// }
//
// _.routineExtend( _filesReflect_body, _.FileProvider.Find.prototype.filesReflect );
//
// var defaults = _filesReflect_body.defaults;
//
// let filesReflect = _.routineFromPreAndBody( _.FileProvider.Find.prototype.filesReflect.pre, _filesReflect_body );

// --
//
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

//

function _link_functor( fop )
{
  fop = _.routineOptions( _link_functor, arguments );
  let routine = fop.routine;
  let name = routine.name;
  let onDifferentProviders = fop.onDifferentProviders;

  _.assert( _.strDefined( name ) );
  _.assert( _.objectIs( routine.defaults ) );
  // _.assert( _.objectIs( routine.paths ) );
  _.assert( routine.paths === undefined );
  _.assert( _.objectIs( routine.having ) );

  // let defaults = hubLink.defaults = Object.create( routine.defaults );
  // // let paths = hubLink.paths = Object.create( routine.paths );
  // let having = hubLink.having = Object.create( routine.having );

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
    if( onDifferentProviders )
    return onDifferentProviders.call( self, o, dst, src, routine );
    else
    throw _.err( 'Cant ' + name + ' files of different file providers :\n' + o.dstPath + '\n' + o.srcPath );

    o.dstPath = dst.filePath;
    o.srcPath = src.filePath;

    return dst.provider[ name ]( o );
  }

}

_link_functor.defaults =
{
  routine : null,
  onDifferentProviders : null,
}

//

let hardLinkAct = _link_functor({ routine : Parent.prototype.hardLinkAct });
let fileRenameAct = _link_functor({ routine : Parent.prototype.fileRenameAct });

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
      allowingMissing : 1,
    });
  }

  // let srcEncoding = src.provider._bufferEncodingGet();
  // let dstEncoding = dst.provider._bufferEncodingGet();
  // let srcEncoding = 'buffer.bytes';
  // let dstEncoding = 'buffer.bytes';

  // if( _.strEnds( src.filePath, 'icons' ) )
  // debugger;

  // debugger;

  let read = src.provider.fileRead
  ({
    filePath : src.filePath,
    resolvingTextLink : 0,
    resolvingSoftLink : 0,
    encoding : 'original.type',
    // encoding : 'buffer.bytes',
    sync : 1,
  });

  // if( srcEncoding !== dstEncoding )
  // {
  //   if( dstEncoding === 'buffer.node' )
  //   read = _.bufferNodeFrom( read );
  //   else if( dstEncoding === 'buffer.raw' )
  //   read = _.bufferRawFrom( read );
  //   else
  //   _.assert( 0, 'Not implemented conversion from', srcEncoding, 'to', dstEncoding );
  // }

  let result = dst.provider.fileWrite
  ({
    filePath : dst.filePath,
    data : read,
    encoding : 'original.type',
    // encoding : 'buffer.bytes',
  });

  return result;
}

let fileCopyAct = _link_functor({ routine : Parent.prototype.fileCopyAct, onDifferentProviders : _fileCopyActDifferent });

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
          o[ p ] = self.pathResolveLink
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
  // pathResolveHardLinkAct : Routines.pathResolveHardLinkAct,

  // read

  fileReadAct : Routines.fileReadAct,
  streamReadAct : Routines.streamReadAct,
  fileHashAct : Routines.fileHashAct,

  // isTerminalAct : Routines.isTerminalAct,
  // isDirAct : Routines.isDirAct,

  dirReadAct : Routines.dirReadAct,
  statReadAct : Routines.statReadAct,
  fileExistsAct : Routines.fileExistsAct,

  // write

  fileWriteAct : Routines.fileWriteAct,
  streamWriteAct : Routines.streamWriteAct,
  fileTimeSetAct : Routines.fileTimeSetAct,
  fileDeleteAct : Routines.fileDeleteAct,

  dirMakeAct : Routines.dirMakeAct,

  softLinkAct : Routines.softLinkAct,
  textLinkAct : Routines.textLinkAct,

  hardLinkBreakAct : Routines.hardLinkBreakAct,
  softLinkBreakAct : Routines.softLinkBreakAct,

}

// --
// path
// --

let Path = _.uri.CloneExtending({ fileProvider : Self });
_.assert( _.prototypeHas( Path, _.uri ) );

// Path.pathNativizeAct = pathNativizeAct;

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

  fieldSet,
  fieldReset,

  // path

  localFromGlobal,
  _localFromGlobal,
  localsFromGlobals,

  pathResolveLink,
  pathResolveSoftLink,

  pathCurrentAct,

  //

  // statResolvedRead,
  fileRead,

  //

  filesAreHardLinkedAct,

  hardLinkAct,
  fileRenameAct,
  fileCopyAct,

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
_.assert( !FilteredRoutines.pathResolveLink );
_.assert( !( 'pathResolveLink' in FilteredRoutines ) );
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
