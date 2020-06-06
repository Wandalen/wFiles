( function _System_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _global = _global_;
  let _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );
}

//

/**
 @classdesc Class that allows file manipulations between different file providers using global paths.
 @class wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

let _global = _global_;
let _ = _global_.wTools;
let Routines = Object.create( null );
let FileRecord = _.FileRecord;
let Parent = _.FileProvider.Partial;
let Self = function wFileSystem( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'System';

_.assert( _.routineIs( _.uri.join ) );
_.assert( _.routineIs( _.uri.normalize ) );
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

  _.assert( self.providers === undefined );
}

// --
// provider
// --

/**
 @summary Changes default file provider.
 @description Sets default provider to `null` if no argument provided.
 @param {Object} [provider] Provider to set as default.
 @function providerDefaultSet
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

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

/**
 @summary Short-cut for {@link module:Tools/mid/Files.wTools.FileProvider.wFileSystem.providerRegister}. Registers several file providers.
 @param {Object|Object[]} fileProvider Provider(s) to register.
 @function providerRegister
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

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

/**
 @summary Adds provider to the inner registry.
 @description Provider should have protocol and origin path defined.
 @param {Object} fileProvider Provider to register.
 @function providerRegister
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

function providerRegister( fileProvider ) // xxx
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract, () => 'Expects file providers, but got ' + _.strType( fileProvider ) );
  _.assert( _.arrayIs( fileProvider.protocols ) );
  _.assert( _.strDefined( fileProvider.protocol ), 'Cant register file provider without {-protocol-} defined', _.strQuote( fileProvider.qualifiedName ) );
  _.assert( _.strDefined( fileProvider.originPath ) );
  _.assert( fileProvider.protocols && fileProvider.protocols.length, 'Cant register file provider without protocols', _.strQuote( fileProvider.qualifiedName ) );

  let protocolMap = self.providersWithProtocolMap;
  for( let p = 0 ; p < fileProvider.protocols.length ; p++ )
  {
    let protocol = fileProvider.protocols[ p ];
    if( protocolMap[ protocol ] )
    _.assert
    (
      !protocolMap[ protocol ] || protocolMap[ protocol ] === fileProvider,
      () => _.strQuote( fileProvider.qualifiedName ) + ' is trying to reserve protocol ' + _.strQuote( protocol ) + ', which is reserved by ' + _.strQuote( protocolMap[ protocol ].qualifiedName )
    );
    protocolMap[ protocol ] = fileProvider;
  }

  _.assert( !fileProvider.system || fileProvider.system === self, () => 'File provider ' + fileProvider.qualifiedName + ' already has a system ' + fileProvider.system.qualifiedName );
  fileProvider.system = self;

  return self;
}

//

/**
 @summary Removes provider from the inner registry.
 @description Provider must be registered in current system.
 @param {Object} fileProvider Provider to unregister.
 @function providerUnregister
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

function providerUnregister( fileProvider )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( self.providersWithProtocolMap[ fileProvider.protocol ] === fileProvider );
  _.assert( fileProvider.system === self );

  delete self.providersWithProtocolMap[ fileProvider.protocol ];
  fileProvider.system = null;

  return self;
}

//

/**
 @summary Selects file provider for specified global path.
 @description Returns default file provider if system doesn't have provider for specified path.
 @param {String} url Source url.
 @function providerForPath
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

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

//

function protocolNameGenerate( skip )
{
  let self = this;
  let number = 1;
  let name;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  skip = skip || 0;
  skip += 1;

  do
  {
    name = 'pro' + number;
    number += 1;
    if( !self.providersWithProtocolMap[ name ] )
    skip -= 1;
  }
  while( skip > 0 )

  return name;
}

//

/**
 @summary Returns true if current system has specified file `provider` in the registry.
 @param {Object} provider File provider to check.
 @function hasProvider
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

function hasProvider( provider )
{
  let self = this;
  _.assert( arguments.length === 1 );
  return !!self.providersWithProtocolMap[ provider.protocol ];
}

// --
// adapter
// --

function _recordFactoryFormEnd( recordFactory )
{
  let self = this;

  _.assert( recordFactory instanceof _.FileRecordFactory );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( recordFactory.effectiveProvider instanceof _.FileProvider.Abstract, 'No provider for base path', recordFactory.basePath, 'found' );
  // _.assert( !_.path.isGlobal( recordFactory.basePath ) );
  // _.assert( recordFactory.stemPath === null || !_.path.isGlobal( recordFactory.stemPath ) );

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

// //
//
// function _recordPathForm( record )
// {
//   let self = this;
//   _.assert( record instanceof _.FileRecord );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   return record;
// }

//

function _recordFormEnd( record )
{
  let self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1, 'Expects single argument' );

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

/**
 @summary Converts global path `filePath` to local.
 @param {String} filePath Global path.
 @function preferredFromGlobalAct
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

function preferredFromGlobalAct( filePath )
{
  let self = this;
  _.assert( arguments.length === 1, 'Expects single argument' );
  return self._pathLocalize( filePath ).localPath;
}

//

function _pathLocalize( filePath )
{
  let self = this;
  let path = self.path;
  let r = self._pathLocalizeMaybe( filePath );

  _.sure( _.objectIs( r.provider ), () => 'No provider for path ' + _.strQuote( filePath ) );

  return r;
}

//

function _pathLocalizeMaybe( filePath )
{
  let self = this;
  let path = self.path;
  let r = Object.create( null );
  r.originalPath = filePath;
  r.parsedPath = r.originalPath;

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  self._pathRelocalize( r, null );

  return r;
}

//

function _pathRelocalize( r, provider )
{
  let self = this;
  let path = self.path;

  _.assert( _.strIs( r.originalPath ), 'Expects string' );
  _.assert( _.strIs( r.parsedPath ) || _.mapIs( r.parsedPath ), 'Expects map or string parsedPath' );
  _.assert( arguments.length === 2 );

  if( _.strIs( r.parsedPath ) )
  r.parsedPath = path.parse( path.normalize( r.parsedPath ) );

  if( !r.provider )
  if( provider )
  r.provider = provider;
  if( !r.provider )
  r.provider = self.providerForPath( r.parsedPath );

  if( r.provider )
  r.localPath = r.provider.path.preferredFromGlobal( r.parsedPath );
  else
  r.localPath = r.originalPath;

  _.assert( _.strIs( r.localPath ) );

  return r;
}

//

function pathNativizeAct( filePath )
{
  let self = this;
  let r = self._pathLocalize( self, filePath );
  r.localPath = r.provider.path.nativize( r.localPath );
  _.assert( 0, 'not implemented' ); xxx
  _.assert( _.objectIs( r.provider ), 'No provider for path', filePath );
  _.assert( arguments.length === 1 );
}

//

/**
 @summary Returns current working directory of default provider.
 @description Changes current working directory if new path is provided.
 @function pathCurrentAct
 @class wTools.FileProvider.wFileSystem
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

function pathCurrentAct()
{
  let self = this;

  if( self.defaultProvider )
  return self.defaultProvider.path.current.apply( self.defaultProvider.path, arguments );

  _.assert( 0, 'Default provider is not set for the ', self.qualifiedName );
}

//

function pathDirTempAct()
{
  let self = this;

  if( self.defaultProvider )
  return self.defaultProvider.path.dirTemp.apply( self.defaultProvider.path, arguments );

  _.assert( 0, 'Default provider is not set for the ', self.qualifiedName );
}

//

function pathNativizeAct( filePath )
{
  let self = this;
  let r = self._pathLocalize( filePath );
  if( r && r.provider )
  return r.provider.pathNativizeAct.call( r.provider, r.localPath );
  debugger;
  if( self.defaultProvider )
  return self.defaultProvider.path.dirTemp.apply( self.defaultProvider.path, arguments );
  debugger;
  return filePath;
}

//

function pathResolveLinkFull_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let r = self._pathLocalize( o.filePath );
  o.filePath = r.localPath;

  let result = r.provider.pathResolveLinkFull.body.call( r.provider, o );

  if( o.sync )
  {
    return handleResult( result );
  }
  else
  {
    result.then( handleResult );
    return result;
  }

  /*  */

  function handleResult( result )
  {
    if( result === null )
    return null;

    result.filePath = self.path.join( r.provider.originPath, result.filePath );
    result.relativePath = self.path.join( r.provider.originPath, result.relativePath );
    result.absolutePath = self.path.join( r.provider.originPath, result.absolutePath );

    return result;
  }
}

_.routineExtend( pathResolveLinkFull_body, Parent.prototype.pathResolveLinkFull );

let pathResolveLinkFull = _.routineFromPreAndBody( Parent.prototype.pathResolveLinkFull.pre, pathResolveLinkFull_body );

//

function pathResolveLinkTail_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let r = self._pathLocalize( o.filePath );
  o.filePath = r.localPath;

  let result = r.provider.pathResolveLinkTail.body.call( r.provider, o );

  if( result === null )
  return null;

  if( result.filePath === null )
  return null;

  result.filePath = self.path.join( r.provider.originPath, result.filePath );
  result.absolutePath = self.path.join( r.provider.originPath, result.absolutePath );

  return result;
}

_.routineExtend( pathResolveLinkTail_body, Parent.prototype.pathResolveLinkTail );

let pathResolveLinkTail = _.routineFromPreAndBody( Parent.prototype.pathResolveLinkTail.pre, pathResolveLinkTail_body );

//

function pathResolveSoftLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let r = self._pathLocalize( o.filePath );

  o.filePath = r.localPath;

  let result = r.provider.pathResolveSoftLink.body.call( r.provider, o );

  if( result === null )
  return result;

  _.assert( !!result );

  result = self.path.join( r.provider.originPath, result );

  if( result === o.filePath )
  {
    debugger;
    _.assert( 0, 'not tested' );
    return r.originalPath;
  }

  return result;
}

_.routineExtend( pathResolveSoftLink_body, Parent.prototype.pathResolveSoftLink );

let pathResolveSoftLink = _.routineFromPreAndBody( Parent.prototype.pathResolveSoftLink.pre, pathResolveSoftLink_body );

//

function pathResolveTextLink_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let r = self._pathLocalize( o.filePath );

  o.filePath = r.localPath;

  let result = r.provider.pathResolveTextLink.body.call( r.provider, o );

  if( result === null )
  return result;

  _.assert( !!result );

  result = self.path.join( r.provider.originPath, result );

  if( result === o.filePath )
  {
    debugger;
    _.assert( 0, 'not tested' );
    return r.originalPath;
  }

  return result;
}

_.routineExtend( pathResolveTextLink_body, Parent.prototype.pathResolveTextLink );

let pathResolveTextLink = _.routineFromPreAndBody( Parent.prototype.pathResolveTextLink.pre, pathResolveTextLink_body );

//

function fileRead_body( o )
{
  let self = this;

  _.assert( arguments.length === 1 );

  o.filePath = self.pathResolveLinkFull
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  o.filePath = o.filePath.absolutePath;

  let r = self._pathLocalize( o.filePath );
  let o2 = _.mapExtend( null, o );

  o2.resolvingSoftLink = 0;
  o2.filePath = r.localPath;
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
  let allowingMissedSrc = fop.allowingMissedSrc;

  _.assert( _.routineIs( fop.onDifferentProviders ) || _.boolIs( fop.onDifferentProviders ) );
  _.assert( _.strDefined( routineName ) );
  _.assert( _.objectIs( routine.defaults ) );
  _.assert( routine.paths === undefined );
  _.assert( _.objectIs( routine.having ) );

  _.routineExtend( hubLink, routine );

  if( fop.onDifferentProviders === true )
  fop.onDifferentProviders = function handleDifferentProviders( op )
  {
  }

  let onDifferentProviders = fop.onDifferentProviders;
  let defaults = hubLink.defaults;

  _.assert( defaults.srcPath !== undefined );
  _.assert( defaults.dstPath !== undefined );

  return hubLink;

  /* */

  function hubLink( o )
  {
    let self = this;
    let op = Object.create( null );
    op.continue = true;
    op.options = _.mapExtend( null, o );
    op.routineName = routineName;
    op.end = function end()
    {
      op.continue = false;
      return op.result;
    }

    _.assert( arguments.length === 1, 'Expects single argument' );

    /* */

    // op.originalDst = self._pathLocalize( op.options.originalDstPath );
    // if( allowingMissedSrc )
    // op.originalSrc = self._pathLocalizeMaybe( op.options.originalSrcPath );
    // else
    // op.originalSrc = self._pathLocalize( op.options.originalSrcPath );
    //
    // _.assert( !!op.originalDst.provider, 'No provider for path', op.options.originalDstPath );
    // _.assert( allowingMissedSrc || !!op.originalSrc.provider, 'No provider for path', op.options.originalSrcPath );
    //
    // op.options.originalDstPath = op.originalDst.localPath;
    //
    // if( op.originalDst.provider !== op.originalSrc.provider )
    // {
    // }
    // else
    // {
    //   op.options.originalSrcPath = op.originalSrc.localPath;
    // }

    /* */

    // op.relativeDst = self._pathLocalize( op.options.relativeDstPath );
    // if( allowingMissedSrc )
    // op.relativeSrc = self._pathLocalizeMaybe( op.options.relativeSrcPath );
    // else
    // op.relativeSrc = self._pathLocalize( op.options.relativeSrcPath );

    op.relativeDst = self._pathLocalizeMaybe( op.options.relativeDstPath );
    op.relativeSrc = self._pathLocalizeMaybe( op.options.relativeSrcPath );

    if( !op.relativeSrc.provider && op.relativeDst.provider )
    self._pathRelocalize( op.relativeSrc, op.relativeDst.provider );
    if( op.relativeSrc.provider && !op.relativeDst.provider )
    self._pathRelocalize( op.relativeDst, op.relativeSrc.provider );

    _.assert( !!op.relativeDst.provider, 'No provider for path', op.options.relativeDstPath );
    _.assert( allowingMissedSrc || !!op.relativeSrc.provider, 'No provider for path', op.options.relativeSrcPath );

    /* */

    op.dst = self._pathLocalizeMaybe( op.options.dstPath );
    op.src = self._pathLocalizeMaybe( op.options.srcPath );

    if( !op.src.provider && op.dst.provider )
    self._pathRelocalize( op.src, op.dst.provider );
    if( op.src.provider && !op.dst.provider )
    self._pathRelocalize( op.dst, op.src.provider );

    _.assert( !!op.dst.provider, 'No provider for path', op.options.dstPath );
    _.assert( allowingMissedSrc || !!op.src.provider, 'No provider for path', op.options.srcPath );

    /* */

    op.options.dstPath = op.dst.localPath;
    op.options.relativeDstPath = op.relativeDst.localPath;

    if( op.dst.provider !== op.src.provider )
    {
      op.options.relativeDstPath = op.options.dstPath;
      op.options.relativeSrcPath = op.options.srcPath;

      if( onDifferentProviders )
      {
        onDifferentProviders.call( self, op );
        if( !op.continue )
        return op.result;
      }
      else
      {
        throw _.err( 'Cant ' + routineName + ' files of different file providers :\n' + op.options.dstPath + '\n' + op.options.srcPath );
      }
    }
    else
    {
      op.options.srcPath = op.src.localPath;
      op.options.relativeSrcPath = op.relativeSrc.localPath;
    }

    op.result = op.dst.provider[ routineName ]( op.options );
    return op.end();
  }

}

_link_functor.defaults =
{
  routine : null,
  onDifferentProviders : false,
  allowingMissedSrc : false,
}

//

let hardLinkAct = _link_functor({ routine : Parent.prototype.hardLinkAct });
let fileRenameAct = _link_functor({ routine : Parent.prototype.fileRenameAct });

let softLinkAct = _link_functor
({
  routine : Parent.prototype.softLinkAct,
  onDifferentProviders : true,
  allowingMissedSrc : true,
});
let textLinkAct = _link_functor
({
  routine : Parent.prototype.textLinkAct,
  onDifferentProviders : true,
  allowingMissedSrc : true,
});

//

function _fileCopyActDifferent( op )
{
  let self = this;
  let path = self.path;
  let o = op.options;

  if( op.src.provider.isTextLink( op.src.localPath ) )
  {
    _.assert( 0, 'Expects terminal file, not text link' );
  }

  if( op.src.provider.isSoftLink( op.src.localPath ) )
  {
    _.assert( 0, 'Expects terminal file, not soft link' );
    // let resolvedPath = op.src.provider.pathResolveSoftLink( op.src.localPath );
    // debugger;
    // c.result = op.dst.provider.softLink
    // ({
    //   dstPath : op.dst.localPath,
    //   srcPath : path.join( op.src.parsedPath.origin, resolvedPath ),
    //   sync : o.sync,
    //   allowingMissed : 1,
    // });
    // return op.end();
  }

  /*
    for extract resolving should be on
    otherwise extract does not resolve intermediate directories
  */

  let read = op.src.provider.fileRead
  ({
    filePath : op.src.localPath,
    resolvingTextLink : 1,
    resolvingSoftLink : 1,
    encoding : 'original.type',
    sync : o.sync,
  });

  if( o.sync )
  op.result = op.dst.provider.fileWrite
  ({
    filePath : op.dst.localPath,
    data : read,
    encoding : 'original.type',
  });
  else
  op.result = read.then( ( read ) =>
  {
    return op.dst.provider.fileWrite
    ({
      filePath : op.dst.localPath,
      data : read,
      sync : 0,
      encoding : 'original.type',
    });
  });

  return op.end();
}

let fileCopyAct = _link_functor
({
  routine : Parent.prototype.fileCopyAct,
  onDifferentProviders : _fileCopyActDifferent,
});

// --
// link
// --

function hardLinkBreak_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let r = self._pathLocalize( o.filePath );
  let o2 = _.mapExtend( null, o );

  o2.filePath = r.localPath;

  return r.provider.hardLinkBreak.body.call( r.provider, o2 );
}

_.routineExtend( hardLinkBreak_body, Parent.prototype.hardLinkBreak );

let hardLinkBreak = _.routineFromPreAndBody( Parent.prototype._preFilePathScalarWithProviderDefaults, hardLinkBreak_body );

//

function filesAreHardLinkedAct( o )
{
  let self = this;

  _.assertRoutineOptions( filesAreHardLinkedAct, arguments );
  _.assert( o.filePath.length === 2, 'Expects exactly two arguments' );

  let dst = self._pathLocalize( o.filePath[ 0 ] );
  let src = self._pathLocalize( o.filePath[ 1 ] );

  _.assert( !!dst.provider, 'No provider for path', o.filePath[ 0 ] );
  _.assert( !!src.provider, 'No provider for path', o.filePath[ 1 ] );

  if( dst.provider !== src.provider )
  return false;

  return dst.provider.filesAreHardLinkedAct({ filePath : [ dst.localPath, src.localPath ] });
}

_.routineExtend( filesAreHardLinkedAct, Parent.prototype.filesAreHardLinkedAct );


//

function dirMake_body( o )
{
  let self = this;

  _.assert( arguments.length === 1 );

  let r = self._pathLocalize( o.filePath );
  let o2 = _.mapExtend( null, o );
  o2.filePath = r.localPath;
  return r.provider.dirMake.body.call( r.provider, o2 );
}

_.routineExtend( dirMake_body, Parent.prototype.dirMake );

let dirMake = _.routineFromPreAndBody( Parent.prototype.dirMake.pre, dirMake_body );

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
//   _.assert( arguments.length === 0, 'Expects no arguments' );
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
    vectorized : null,
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
      let filePath;

      for( let p in operates )
      if( o[ p ] )
      {
        if( operatesLength === 1 )
        {
          let r;

          if( hubResolving )
          o[ p ] = self.pathResolveLinkFull
          ({
            filePath : o[ p ],
            resolvingSoftLink : o.resolvingSoftLink || false,
            resolvingTextLink : o.resolvingTextLink || false,
          });

          if( operates[ p ].allowingMissed )
          r = self._pathLocalizeMaybe( o[ p ] );
          else
          r = self._pathLocalize( o[ p ] );

          filePath = o[ p ];
          provider = r.provider;
          o[ p ] = r.localPath;

        }
        else
        {
          if( o[ p ] instanceof _.FileRecord )
          continue;

          o[ p ] = self.path.preferredFromGlobal( o[ p ] );
        }
      }

      _.assert( _.objectIs( provider ), 'No provider for path', filePath );
      return provider;
    }

    /* */

    let _routine =
    {
      [ r + 'System' ] : function( o )
      {
        let self = this;

        if( arguments.length === 1 && wrap.defaults )
        {
          if( _.strIs( o ) )
          o = { filePath : o }
        }

        if( pre )
        o = pre.call( this, wrap, arguments );

        let o2 = _.mapExtend( null, o );

        if( !pre && wrap.defaults )
        if( !wrap.having || !wrap.having.driving )
        _.routineOptions( wrap, o2 );

        let provider = self;

        provider = resolve.call( self, o2 );

        if( provider === self )
        {
          _.assert( _.routineIs( original ), 'No original method for', name );
          return original.call( provider, o2 );
        }
        else
        {
          _.assert( _.routineIs( provider[ name ] ) );
          return provider[ name ].call( provider, o2 );
        }
      }
    }

    let wrap = Routines[ r ] = _routine[ r + 'System' ];
    _.routineExtend( wrap, original );

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

  // lock

  fileLockAct : Routines.fileLockAct,
  fileUnlockAct : Routines.fileUnlockAct,
  fileIsLockedAct : Routines.fileIsLockedAct,

  // link

  hardLinkBreakAct : Routines.hardLinkBreakAct,
  softLinkBreakAct : Routines.softLinkBreakAct,

  filesCanBeSame : Routines.filesCanBeSame,
  filesAreSameForSure : Routines.filesAreSameForSure

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

/**
 * @typedef {Object} Fields
 * @property {String} defaultProtocol
 * @property {Object} providersWithProtocolMap={}
 * @property {Object} defaultProvider
 * @property {Boolean} safe=0
 * @class wFileSystem
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
*/

/**
 * @typedef {Object} Medials
 * @property {Boolean} empty=0
 * @property {Object[]} providers
 * @property {String} defaultOrigin
 * @class wFileSystem
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
*/

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
  protocolNameGenerate,
  hasProvider,

  // adapter

  _recordFactoryFormEnd,
  _recordFormBegin,
  // _recordPathForm,
  _recordFormEnd,

  _recordAbsoluteGlobalMaybeGet,
  _recordRealGlobalMaybeGet,

  fieldPush,
  fieldPop,

  // path

  preferredFromGlobalAct,
  _pathLocalize,
  _pathLocalizeMaybe,
  _pathRelocalize,

  pathCurrentAct,
  pathDirTempAct,
  pathNativizeAct,

  pathResolveLinkFull,
  pathResolveLinkTail,
  pathResolveSoftLink,
  pathResolveTextLink,

  // read

  fileRead,

  // linker

  _link_functor,

  hardLinkAct,
  fileRenameAct,

  softLinkAct,
  textLinkAct,

  fileCopyAct,

  // link

  hardLinkBreak,

  filesAreHardLinkedAct,

  //

  dirMake,

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

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
