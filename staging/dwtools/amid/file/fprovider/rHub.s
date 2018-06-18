( function _rHub_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _global = _global_; var _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../FileMid.s' );

}

//

var _global = _global_; var _ = _global_.wTools;
var Routines = {};
var FileRecord = _.FileRecord;
var Parent = _.FileProvider.Partial;
var Self = function wFileProviderHub( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Hub';

_.assert( _.urlJoin );
_.assert( _.urlNormalize );
_.assert( _.urlsNormalize );
_.assert( _.urlIsNormalized );

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );

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
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( provider === null || provider instanceof _.FileProvider.Abstract );

  if( provider )
  {

    _.assert( provider.protocols && provider.protocols.length );
    _.assert( provider.originPath );

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
  var self = this;

  _.assert( arguments.length === 1 );

  if( src instanceof _.FileProvider.Abstract )
  self.providerRegister( src );
  else if( _.arrayIs( src ) )
  for( var p = 0 ; p < src.length ; p++ )
  self.providerRegister( src[ p ] );
  else _.assert( 0,'Unknown kind of argument',src );

  return self;
}

//

function providerRegister( fileProvider )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( fileProvider.protocols && fileProvider.protocols.length,'cant register file provider without protocols',_.strQuote( fileProvider.nickName ) );
  _.assert( _.strIsNotEmpty( fileProvider.originPath ),'cant register file provider without "originPath"',_.strQuote( fileProvider.nickName ) );

  var protocol = fileProvider.protocol;
  if( self.providersWithProtocolMap[ protocol ] )
  _.assert( 0,_.strQuote( fileProvider.nickName ),'is trying to reserve protocol, reserved by',_.strQuote( self.providersWithProtocolMap[ protocol ].nickName ) );
  self.providersWithProtocolMap[ protocol ] = fileProvider;

  var originPath = fileProvider.originPath;
  self.providersWithOriginMap[ originPath ] = fileProvider;

  if( fileProvider.hub )
  _.assert( !fileProvider.hub,'File provider',fileProvider.nickName,'already has a hub',fileProvider.hub.nickName );
  fileProvider.hub = self;

  return self;
}

//

function providerUnregister( fileProvider )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( self.providersWithProtocolMap[ fileProvider.protocol ] === fileProvider );
  _.assert( self.providersWithOriginMap[ fileProvider.originPath ] === fileProvider );
  _.assert( fileProvider.hub === self );

  delete self.providersWithProtocolMap[ fileProvider.protocol ];
  delete self.providersWithOriginMap[ fileProvider.originPath ];
  fileProvider.hub = null;

  return self;
}

//

function providerForPath( url )
{
  var self = this;

  if( _.strIs( url ) )
  url = _.urlParse( url );

  _.assert( url );
  _.assert( ( url.protocols.length ) ? url.protocols[ 0 ].toLowerCase : true );
  _.assert( _.mapIs( url ) ) ;
  _.assert( arguments.length === 1 );

  /* */

  var origin = url.origin || self.defaultOrigin;

  _.assert( _.strIs( origin ) || origin === null );

  if( origin )
  origin = origin.toLowerCase();

  if( self.providersWithOriginMap[ origin ] )
  {
    return self.providersWithOriginMap[ origin ];
  }

  /* */

  return self.defaultProvider;
}

// --
// adapter
// --

function _fileRecordContextForm( recordContext )
{
  var self = this;

  _.assert( recordContext instanceof _.FileRecordContext );
  _.assert( arguments.length === 1 );

  if( !recordContext.fileProviderEffective )
  debugger;

  if( !recordContext.fileProviderEffective )
  recordContext.fileProviderEffective = recordContext.fileProvider.providerForPath( recordContext.basePath );

  _.assert( recordContext.fileProviderEffective,'no provider for path',recordContext.basePath );

  recordContext.basePath = recordContext.fileProviderEffective.localFromUrl( recordContext.basePath );

  return recordContext;
}

//

function _fileRecordFormBegin( record )
{
  var self = this;

  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );

  return record;
}

//

function _fileRecordPathForm( record )
{
  var self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );

  record.absoluteEffective = record.absoluteUrl;
  record.realEffective = record.realUrl;

  return record;
}

//

function _fileRecordFormEnd( record )
{
  var self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );

  record.realEffective = record.realUrl;

  return record;
}

//

function fieldSet()
{
  var self = this;

  Parent.prototype.fieldSet.apply( self, arguments );

  if( self.providersWithOriginMap )
  for( var or in self.providersWithOriginMap )
  {
    var provider = self.providersWithOriginMap[ or ];
    provider.fieldSet.apply( provider, arguments )
  }

}

//

function fieldReset()
{
  var self = this;

  Parent.prototype.fieldReset.apply( self, arguments );

  if( self.providersWithOriginMap )
  for( var or in self.providersWithOriginMap )
  {
    var provider = self.providersWithOriginMap[ or ];
    provider.fieldReset.apply( provider, arguments );
  }

}

// --
// path
// --

function localFromUrl( filePath )
{
  var self = this;
  _.assert( arguments.length === 1 );
  return self._localFromUrl( filePath ).filePath;
}

//

function _localFromUrl( filePath, provider )
{
  var self = this;
  var r = { filePath : filePath, provider : provider };

  _.assert( _.strIs( filePath ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  r.originalPath = filePath;

  r.parsedPath = r.originalPath;
  if( _.strIs( filePath ) )
  r.parsedPath = _.urlParse( _.urlNormalize( r.parsedPath ) );

  if( !r.provider )
  {
    _.assert( r.parsedPath.protocols );
    r.provider = self.providerForPath( r.parsedPath );
  }

  _.assert( r.provider,'no provider for path',filePath );

  r.filePath = r.provider.localFromUrl( r.parsedPath );

  return r;
}

//

var localsFromUrls = _.routineInputMultiplicator_functor
({
  routine : localFromUrl,
  vectorizingMap : 0,
});

//

function pathNativize( filePath )
{
  var self = this;

  _.assert( _.strIs( filePath ) ) ;
  _.assert( arguments.length === 1 );

  return self._pathNativize( filePath ).filePath;
}

//

function _pathNativize( filePath,provider )
{
  var self = this;
  var r = self._localFromUrl.apply( self,arguments );
  r.filePath = r.provider.pathNativize( r.filePath );
  _.assert( r.provider,'no provider for path',filePath );
  return r;
}

//

function _pathResolveLink_body( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  /* needed to return local path for softlink src */
  if( !o.resolvingSoftLink && !o.resolvingTextLink )
  return o.filePath;

  var r = self._localFromUrl( o.filePath );
  o.filePath = r.filePath;

  var result = r.provider.pathResolveLink.body.call( r.provider,o );

  _.assert( result );

  result = self.pathJoin( r.provider.originPath, result );

  if( result === o.filePath )
  {
    debugger;
    xxx
    return r.originalPath;
  }

  return result;
}

var defaults = _pathResolveLink_body.defaults = Object.create( Parent.prototype.pathResolveLink.defaults );
var paths = _pathResolveLink_body.paths = Object.create( Parent.prototype.pathResolveLink.paths );
var having = _pathResolveLink_body.having = Object.create( Parent.prototype.pathResolveLink.having );

//

function pathResolveLink( o )
{
  var self = this;
  var o = self.pathResolveLink.pre.call( self,self.pathResolveLink,arguments );
  var result = self.pathResolveLink.body.call( self,o );
  return result;
}

pathResolveLink.pre = Parent.prototype.pathResolveLink.pre;
pathResolveLink.body = _pathResolveLink_body;

var defaults = pathResolveLink.defaults = Object.create( Parent.prototype.pathResolveLink.defaults );
var paths = pathResolveLink.paths = Object.create( Parent.prototype.pathResolveLink.paths );
var having = pathResolveLink.having = Object.create( Parent.prototype.pathResolveLink.having );

//

function _pathResolveSoftLink_body( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var r = self._localFromUrl( o.filePath );

  o.filePath = r.filePath;

  var result = r.provider.pathResolveSoftLink.body.call( r.provider,o );

  _.assert( result );

  if( result === o.filePath )
  return r.originalPath;

  return result;
}

var defaults = _pathResolveSoftLink_body.defaults = Object.create( Parent.prototype.pathResolveSoftLink.defaults );
var paths = _pathResolveSoftLink_body.paths = Object.create( Parent.prototype.pathResolveSoftLink.paths );
var having = _pathResolveSoftLink_body.having = Object.create( Parent.prototype.pathResolveSoftLink.having );

//

function pathResolveSoftLink( path )
{
  var self = this;
  var o = self.pathResolveSoftLink.pre.call( self,self.pathResolveSoftLink,arguments );
  var result = self.pathResolveSoftLink.body.call( self,o );
  return result;
}

pathResolveSoftLink.pre = Parent.prototype.pathResolveSoftLink.pre;
pathResolveSoftLink.body = _pathResolveSoftLink_body;

var defaults = pathResolveSoftLink.defaults = Object.create( Parent.prototype.pathResolveSoftLink.defaults );
var paths = pathResolveSoftLink.paths = Object.create( Parent.prototype.pathResolveSoftLink.paths );
var having = pathResolveSoftLink.having = Object.create( Parent.prototype.pathResolveSoftLink.having );

//

function _pathResolveHardLink_body( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var r = self._localFromUrl( o.filePath );

  o.filePath = r.filePath;

  var result = r.provider.pathResolveHardLink.body.call( r.provider,o );

  _.assert( result );

  if( result === o.filePath )
  return r.originalPath;

  return result;
}

var defaults = _pathResolveHardLink_body.defaults = Object.create( Parent.prototype.pathResolveHardLink.defaults );
var paths = _pathResolveHardLink_body.paths = Object.create( Parent.prototype.pathResolveHardLink.paths );
var having = _pathResolveHardLink_body.having = Object.create( Parent.prototype.pathResolveHardLink.having );

//

function pathResolveHardLink( path )
{
  var self = this;
  var o = self.pathResolveHardLink.pre.call( self,self.pathResolveHardLink,arguments );
  var result = self.pathResolveHardLink.body.call( self,o );
  return result;
}

pathResolveHardLink.pre = Parent.prototype.pathResolveHardLink.pre;
pathResolveHardLink.body = _pathResolveHardLink_body;

var defaults = pathResolveHardLink.defaults = Object.create( Parent.prototype.pathResolveHardLink.defaults );
var paths = pathResolveHardLink.paths = Object.create( Parent.prototype.pathResolveHardLink.paths );
var having = pathResolveHardLink.having = Object.create( Parent.prototype.pathResolveHardLink.having );


// --
//
// --

function filesAreHardLinkedAct( dstPath, srcPath )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var dst = self._localFromUrl( dstPath );
  var src = self._localFromUrl( srcPath );

  _.assert( dst.provider,'no provider for path',dstPath );
  _.assert( src.provider,'no provider for path',srcPath );

  if( dst.provider !== src.provider )
  return false;

  debugger; xxx

  return dst.provider.filesAreHardLinkedAct( dst.filePath, src.filePath );
}

//

function _link_functor( fop )
{
  var fop = _.routineOptions( _link_functor,arguments );
  var routine = fop.routine;
  var name = routine.name;
  var onDifferentProviders = fop.onDifferentProviders;

  _.assert( _.strIsNotEmpty( name ) );
  _.assert( routine.defaults );
  _.assert( routine.paths );
  _.assert( routine.having );

  function hubLink( o )
  {
    var self = this;

    _.assert( arguments.length === 1 );

    var dst = self._localFromUrl( o.dstPath );
    var src = self._localFromUrl( o.srcPath );

    _.assert( dst.provider,'no provider for path',o.dstPath );
    _.assert( src.provider,'no provider for path',o.srcPath );

    if( dst.provider !== src.provider )
    if( onDifferentProviders )
    return onDifferentProviders.call( self,o,dst,src,routine );
    else
    throw _.err( 'Cant ' + name + ' files of different file providers :\n' + o.dstPath + '\n' + o.srcPath );

    o.dstPath = dst.filePath;
    o.srcPath = src.filePath;

    return dst.provider[ name ]( o );
  }

  var defaults = hubLink.defaults = Object.create( routine.defaults );
  var paths = hubLink.paths = Object.create( routine.paths );
  var having = hubLink.having = Object.create( routine.having );

  _.assert( defaults.srcPath !== undefined );
  _.assert( defaults.dstPath !== undefined );

  return hubLink;
}

_link_functor.defaults =
{
  routine : null,
  onDifferentProviders : null,
}

//

var linkHardAct = _link_functor({ routine : Parent.prototype.linkHardAct });
var fileRenameAct = _link_functor({ routine : Parent.prototype.fileRenameAct });

//

function _fileCopyActDifferent( o,dst,src,routine )
{
  var self = this;

  /* qqq : implement async */
  _.assert( o.sync,'not implemented' );

  if( src.provider.fileIsSoftLink( src.filePath ) )
  {
    var resolvedPath = src.provider.pathResolveSoftLink( src.filePath );
    return dst.provider.linkSoft
    ({
      dstPath : dst.filePath,
      srcPath : _.urlJoin( src.parsedPath.origin,resolvedPath ),
      allowMissing : 1,
    });
  }

  var read = src.provider.fileRead
  ({
    filePath : src.filePath,
    resolvingTextLink : 0,
    resolvingSoftLink : 0,
    sync : 1,
  });

  return dst.provider.fileWrite( dst.filePath, read );
}

var fileCopyAct = _link_functor({ routine : Parent.prototype.fileCopyAct, onDifferentProviders : _fileCopyActDifferent });

// --
//
// --

function _defaultProviderSet( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

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
  var self = this;

  _.assert( arguments.length === 1 );

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
  var self = this;

  _.assert( arguments.length === 1 );

  if( src )
  {
    _.assert( _.strIs( src ) );
    _.assert( _.urlIsGlobal( src ) );
    var protocol = _.strRemoveEnd( src,'://' );
    _.assert( !_.urlIsGlobal( protocol ) );
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

// --
//
// --

function routinesGenerate()
{
  var self = this;

  var KnownRoutineFields =
  {
    name : null,
    pre : null,
    body : null,
    defaults : null,
    paths : null,
    having : null,
    encoders : null,
  }

  for( var r in Parent.prototype ) (function()
  {
    var name = r;
    var original = Parent.prototype[ r ];

    if( !original )
    return;

    var having = original.having;

    if( !having )
    return;

    _.assert( original );
    // _.assert( _.routineIs( original ) );
    _.assertMapHasOnly( original,KnownRoutineFields );

    if( having.hubRedirecting === 0 || having.hubRedirecting === false )
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
    _.assert( original.paths );
    if(  original.paths )
    _.assert( original.defaults );

    var hubResolving = having.hubResolving;
    var havingBare = having.bare;
    var paths = original.paths;
    var pathsLength = paths ? _.mapKeys( paths ).length : 0;
    var pre = original.pre;
    var body = original.body;

    /* */

    function pathsNormalize( o )
    {
      var self = this;
      var provider = self;

      for( var p in paths )
      if( o[ p ] )
      {
        if( pathsLength === 1 )
        {
          var r;

          // if( havingBare )
          // debugger;

          if( hubResolving )
          o[ p ] = self.pathResolveLink
          ({
            filePath : o[ p ],
            resolvingSoftLink : o.resolvingSoftLink,
            resolvingTextLink : o.resolvingTextLink,
          });

          r = self._localFromUrl( o[ p ] );
          o[ p ] = r.filePath;
          provider = r.provider;

          _.assert( provider,'No provider for path',o[ p ] );

        }
        else
        {
          o[ p ] = self.localFromUrl( o[ p ] );
        }
      }

      return provider;
    }

    /* */

    var wrap = Routines[ r ] = function hub( o )
    {
      var self = this;

      if( arguments.length === 1 && wrap.defaults )
      {
        if( _.strIs( o ) )
        o = { filePath : o }
      }

      if( pre )
      o = pre.call( this,wrap,arguments );
      else if( wrap.defaults )
      _.routineOptions( wrap,o );

      var provider = self;

      provider = pathsNormalize.call( self,o );

      if( provider === self )
      {
        _.assert( _.routineIs( original ),'no original method for',name );
        return original.call( provider,o );
      }
      else
      {
        _.assert( _.routineIs( provider[ name ] ) );
        return provider[ name ].call( provider,o );
      }
    }

    wrap.having = Object.create( original.having );

    if( original.defaults )
    {
      wrap.defaults = Object.create( original.defaults );
      wrap.paths = Object.create( original.paths );
    }

    if( original.encoders )
    wrap.encoders = Object.create( original.encoders );

    if( original.pre )
    wrap.pre = original.pre;

    if( original.body )
    wrap.body = original.body;

  })();

}

routinesGenerate();

//

var FilteredRoutines =
{

  // path

  pathForCopy : Routines.pathForCopy,
  pathFirstAvailable : Routines.pathFirstAvailable,
  // pathResolveSoftLink : Routines.pathResolveSoftLink,
  pathResolveSoftLinkAct : Routines.pathResolveSoftLinkAct,
  pathResolveHardLinkAct : Routines.pathResolveHardLinkAct,


  // read act

  fileReadAct : Routines.fileReadAct,
  fileReadStreamAct : Routines.fileReadStreamAct,
  fileStatAct : Routines.fileStatAct,
  fileHashAct : Routines.fileHashAct,

  fileIsTerminalAct : Routines.fileIsTerminalAct,
  directoryReadAct : Routines.directoryReadAct,


  // read content

  fileReadStream : Routines.fileReadStream,
  fileRead : Routines.fileRead,
  fileReadSync : Routines.fileReadSync,
  fileReadJson : Routines.fileReadJson,
  fileReadJs : Routines.fileReadJs,

  fileInterpret : Routines.fileInterpret,

  fileHash : Routines.fileHash,
  filesFingerprints : Routines.filesFingerprints,

  directoryRead : Routines.directoryRead,
  directoryReadDirs : Routines.directoryReadDirs,
  directoryReadTerminals : Routines.directoryReadTerminals,


  // read stat

  fileStat : Routines.fileStat,

  fileIsTerminal : Routines.fileIsTerminal,
  fileResolvedIsTerminal : Routines.fileResolvedIsTerminal,
  fileIsSoftLink : Routines.fileIsSoftLink,
  fileIsHardLink : Routines.fileIsHardLink,
  fileIsTextLink : Routines.fileIsTextLink,
  fileIsLink : Routines.fileIsLink,
  fileResolvedIsLink : Routines.fileResolvedIsLink,

  filesStats : Routines.filesStats,
  filesAreTerminals : Routines.filesAreTerminals,
  filesAreSoftLinks : Routines.filesAreSoftLinks,
  filesAreHardLinks : Routines.filesAreHardLinks,
  filesAreTextLinks : Routines.filesAreTextLinks,
  filesAreLinks : Routines.filesAreLinks,

  // filesSame : Routines.filesSame,
  filesAreSame : Routines.filesAreSame,
  // filesAreHardLinkedAct : Routines.filesAreHardLinkedAct,
  filesAreHardLinked : Routines.filesAreHardLinked,
  filesSize : Routines.filesSize,
  fileSize : Routines.fileSize,

  directoryIs : Routines.directoryIs,
  directoryResolvedIs : Routines.directoryResolvedIs,
  directoryIsEmpty : Routines.directoryIsEmpty,

  directoriesAre : Routines.directoriesAre,
  directoriesAreEmpty : Routines.directoriesAreEmpty,


  // write act

  fileWriteAct : Routines.fileWriteAct,
  fileWriteStreamAct : Routines.fileWriteStreamAct,
  fileTimeSetAct : Routines.fileTimeSetAct,
  fileDeleteAct : Routines.fileDeleteAct,

  directoryMakeAct : Routines.directoryMakeAct,

  // fileRenameAct : Routines.fileRenameAct,
  // fileCopyAct : Routines.fileCopyAct,

  linkSoftAct : Routines.linkSoftAct,
  // linkHardAct : Routines.linkHardAct,

  hardLinkBreakAct : Routines.hardLinkBreakAct,
  softLinkBreakAct : Routines.softLinkBreakAct,

  hardLinkBreak : Routines.hardLinkBreak,
  softLinkBreak : Routines.softLinkBreak,


  // write

  fileTouch : Routines.fileTouch,
  fileWrite : Routines.fileWrite,
  fileWriteStream : Routines.fileWriteStream,
  fileAppend : Routines.fileAppend,
  fileWriteJson : Routines.fileWriteJson,
  fileWriteJs : Routines.fileWriteJs,

  fileTimeSet : Routines.fileTimeSet,

  fileDelete : Routines.fileDelete,

  directoryMake : Routines.directoryMake,
  directoryMakeForFile : Routines.directoryMakeForFile,

  // fileRename : Routines.fileRename,
  // fileCopy : Routines.fileCopy,
  // linkSoft : Routines.linkSoft,
  // linkHard : Routines.linkHard,

  fileExchange : Routines.fileExchange,

}

// --
// relationship
// --

var defaultProviderSymbol = Symbol.for( 'defaultProvider' );
var defaultProtocolSymbol = Symbol.for( 'defaultProtocol' );
var defaultOriginSymbol = Symbol.for( 'defaultOrigin' );

var Composes =
{

  defaultProtocol : null,

  providersWithProtocolMap : {},
  providersWithOriginMap : {},

}

var Aggregates =
{
}

var Associates =
{
  defaultProvider : null,
}

var Restricts =
{
}

var Medials =
{
  empty : 0,
  providers : null,
  defaultOrigin : null,
}

var Accessors =
{
  defaultProvider : 'defaultProvider',
  defaultProtocol : 'defaultProtocol',
  defaultOrigin : 'defaultOrigin',
}

// --
// define class
// --

var Proto =
{

  init : init,

  // provider

  providerDefaultSet : providerDefaultSet,
  providerRegister : providerRegister,
  providerUnregister : providerUnregister,
  providersRegister : providersRegister,
  providerForPath : providerForPath,


  // adapter

  _fileRecordContextForm : _fileRecordContextForm,
  _fileRecordFormBegin : _fileRecordFormBegin,
  _fileRecordPathForm : _fileRecordPathForm,
  _fileRecordFormEnd : _fileRecordFormEnd,

  fieldSet : fieldSet,
  fieldReset : fieldReset,


  // path

  localFromUrl : localFromUrl,
  _localFromUrl : _localFromUrl,
  localsFromUrls : localsFromUrls,
  pathNativize : pathNativize,
  _pathNativize : _pathNativize,

  _pathResolveLink_body : _pathResolveLink_body,
  pathResolveLink : pathResolveLink,

  _pathResolveSoftLink_body : _pathResolveSoftLink_body,
  pathResolveSoftLink : pathResolveSoftLink,

  _pathResolveHardLink_body : _pathResolveHardLink_body,
  pathResolveHardLink : pathResolveHardLink,

  pathNormalize : _.urlNormalize,
  pathsNormalize : _.urlsNormalize,
  pathJoin : _.urlJoin,
  pathResolve : _.urlResolve,
  pathRebase : _.urlRebase,
  pathDir : _.urlDir,
  pathRelative : _.urlRelative,
  pathIsNormalized : _.urlIsNormalized,
  pathIsAbsolute : _.urlIsAbsolute,
  pathCommon : _.urlCommon,


  //

  filesAreHardLinkedAct : filesAreHardLinkedAct,
  linkHardAct : linkHardAct,
  fileRenameAct : fileRenameAct,
  fileCopyAct : fileCopyAct,


  //

  _defaultProviderSet : _defaultProviderSet,
  _defaultProtocolSet : _defaultProtocolSet,
  _defaultOriginSet : _defaultOriginSet,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Medials : Medials,
  Accessors : Accessors,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );

//

_.mapSupplementOwn( Self.prototype, FilteredRoutines );

var missingMap = Object.create( null );
for( var r in Routines )
{
  _.assert( Self.prototype[ r ],'routine',r,'does not exist in prototype' );
  if( !_.mapOwnKey( Self.prototype,r ) && Routines[ r ] !== Self.prototype[ r ] )
  missingMap[ r ] = 'Routines.' + r;
}
_.assert( !_.mapKeys( missingMap ).length, 'several routine(s) were not written into Proto explicitly','\n',_.toStr( missingMap,{ stringWrapper : '' } ) );

_.assert( !FilteredRoutines.pathResolveLink );
_.assert( !( 'pathResolveLink' in FilteredRoutines ) );
_.assertMapHasNoUndefine( FilteredRoutines );
_.assertMapHasNoUndefine( Proto );
_.assertMapHasNoUndefine( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

_.FileProvider[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
