( function _rHub_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../FileMid.s' );

}

//

var _ = _global_.wTools;
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

  if( !o || !o.empty )
  if( _.fileProvider )
  {
    self.providerRegister( _.fileProvider );
    self.providerDefaultSet( _.fileProvider );
  }

}

// --
// fields
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

function providerRegister( fileProvider )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( fileProvider instanceof _.FileProvider.Abstract )
  self._providerInstanceRegister( fileProvider );
  else
  self._providerClassRegister( fileProvider );

  return self;
}

//

function _providerInstanceRegister( fileProvider )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( fileProvider.protocols && fileProvider.protocols.length,'cant register file provider without protocols',_.strQuote( fileProvider.nickName ) );
  _.assert( _.strIsNotEmpty( fileProvider.originPath ),'cant register file provider without "originPath"',_.strQuote( fileProvider.nickName ) );

  var originPath = fileProvider.originPath;

  if( self.providersWithOriginMap[ originPath ] )
  _.assert( !self.providersWithOriginMap[ originPath ],_.strQuote( fileProvider.nickName ),'is trying to reserve origin, reserved by',_.strQuote( self.providersWithOriginMap[ originPath ].nickName ) );

  self.providersWithOriginMap[ originPath ] = fileProvider;

/*
file:///some/staging/index.html
file:///some/staging/index.html
http://some.come/staging/index.html
svn+https://user@subversion.com/svn/trunk
*/

  return self;
}

//

function _providerClassRegister( o )
{
  var self = this;

  if( _.routineIs( o ) )
  o = { provider : o  };

  _.assert( arguments.length === 1 );
  _.assert( _.constructorIs( o.provider ) );
  _.routineOptions( _providerClassRegister,o );
  _.assert( Object.isPrototypeOf.call( _.FileProvider.Abstract.prototype , o.provider.prototype ) );

  if( !o.protocols )
  o.protocols = o.provider.protocols;

  _.assert( o.protocols && o.protocols.length,'cant register file provider without protocols',_.strQuote( o.provider.nickName ) );

  for( var p = 0 ; p < o.protocols.length ; p++ )
  {
    var protocol = o.protocols[ p ];

    if( self.providersWithProtocolMap[ protocol ] )
    _.assert( !self.providersWithProtocolMap[ protocol ],_.strQuote( fileProvider.nickName ),'is trying to register protocol ' + _.strQuote( protocol ) + ', registered by',_.strQuote( self.providersWithProtocolMap[ protocol ].nickName ) );

    self.providersWithProtocolMap[ protocol ] = o.provider;
  }

  return self;
}

_providerClassRegister.defaults =
{
  provider : null,
  protocols : null,
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

  recordContext.basePath = recordContext.fileProviderEffective.localFromUrl( recordContext.basePath );

  return recordContext;
}

//

function _fileRecordFormBegin( record )
{
  var self = this;

  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );

  // debugger;
  // record.fileProviderEffective = record.fileProvider.providerForPath( record.input );
  // record.input = record.fileProvider.localFromUrl( record.input );

  return record;
}

//

function _fileRecordFormEnd( record )
{
  var self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );
  // _.assert( record.fileProvider === self );

  // debugger;

  record.absoluteEffective = record.full;
  // record.fileProviderEffective = self.providerForPath( record.absoluteEffective );

  return record;
}

//

// function fileRecord( filePath, recordContext )
// {
//   var self = this;
//   var provider = self;
//
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//
//   // filePath = _.urlNormalize( filePath );
//   //
//   // var provider = self.providerForPath( filePath );
//   //
//   // _.assert( provider );
//   //
//   // filePath = provider.localFromUrl( filePath );
//   // debugger;
//   // return provider.fileRecord( filePath, recordContext );
//
//   return Parent.prototype.fileRecord.call( self, filePath, recordContext );
// }

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

  _.assert( _.strIs( origin ) );

  if( self.providersWithOriginMap[ origin ] )
  {
    return self.providersWithOriginMap[ origin ];
  }

  /* */

  var protocol = url.protocols.length ? url.protocols[ 0 ].toLowerCase() : self.defaultProtocol;

  _.assert( _.strIs( protocol ) );

  if( self.providersWithProtocolMap[ protocol ] )
  {
    debugger; xxx;
    var Provider = self.providersWithProtocolMap[ protocol ];
    var provider = new Provider({ oiriginPath : origin });
    self.providerRegister( provider );
    return provider;
  }

  /* */

  return self.defaultProvider;
}

//

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

  r.parsedPath = filePath;
  if( _.strIs( filePath ) )
  r.parsedPath = _.urlParse( _.urlNormalize( r.parsedPath ) );

  if( !r.provider )
  {
    _.assert( r.parsedPath.protocols );
    if( !r.parsedPath.protocols.length )
    return r;
    r.provider = self.providerForPath( r.parsedPath );
  }

  _.assert( r.provider );

  r.filePath = r.provider.localFromUrl( r.parsedPath );

  return r;
}

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
  _.assert( r.provider );
  return r.provider.pathNativize( r.filePath );
}

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

    debugger;

    return dst.provider[ name ]( dst.filePath, src.filePath );
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

  _.assert( o.sync,'not implemented' );

  var read = src.provider.fileReadSync( src.filePath );
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

// var ArgumentHandlers = {};
//
// ArgumentHandlers.fileWrite = function fileWriteArguments()
// {
//   return { filePath : arguments[ 0 ], data : arguments[ 1 ] };
// }
//
// ArgumentHandlers.fileTimeSet = function fileTimeSetArguments()
// {
//   return { filePath : arguments[ 0 ], atime : arguments[ 1 ], mtime : arguments[ 2 ] };
// }

//

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

    var havingBare = having.bare;
    var paths = original.paths;
    var pathsLength = paths ? _.mapKeys( paths ).length : 0;
    var pre = original.pre;

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

          if( havingBare )
          debugger;

          if( havingBare )
          r = self._pathNativize( o[ p ] );
          else
          r = self._localFromUrl( o[ p ] );
          o[ p ] = r.filePath;
          provider = r.provider;

          _.assert( provider );
        }
        else
        {
          debugger;
          if( havingBare )
          o[ p ] = self.pathNativize( o[ p ] );
          else
          o[ p ] = self.localFromUrl( o[ p ] );
        }
      }

      return provider;
    }

    /* */

    var wrap = Routines[ r ] = function hub( o )
    {
      var self = this;

      // debugger;
      // _.assert( arguments.length >= 1 && arguments.length <= 3 );

      if( arguments.length === 1 && wrap.defaults )
      {
        if( _.strIs( o ) )
        o = { filePath : o }
      }
      // else if( ArgumentHandlers[ name ] )
      // {
      //   debugger;
      //   o = ArgumentHandlers[ name ].apply( self, arguments );
      // }

      if( pre )
      o = pre.call( this,wrap,arguments );
      else if( wrap.defaults )
      _.routineOptions( wrap,o );

      var provider = self;

      provider = pathsNormalize.call( self,o );

      _.assert( provider );

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

  })();

}

routinesGenerate();

//

var FilteredRoutines =
{

  // read act

  fileReadAct : Routines.fileReadAct,
  fileReadStreamAct : Routines.fileReadStreamAct,
  fileStatAct : Routines.fileStatAct,
  fileHashAct : Routines.fileHashAct,

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
  fileIsSoftLink : Routines.fileIsSoftLink,
  fileIsHardLink : Routines.fileIsHardLink,
  fileIsTextLink : Routines.fileIsTextLink,
  fileIsLink : Routines.fileIsLink,

  filesStats : Routines.filesStats,
  filesAreTerminals : Routines.filesAreTerminals,
  filesAreSoftLinks : Routines.filesAreSoftLinks,
  filesAreHardLinks : Routines.filesAreHardLinks,
  filesAreTextLinks : Routines.filesAreTextLinks,
  filesAreLinks : Routines.filesAreLinks,

  filesSame : Routines.filesSame,
  filesAreHardLinkedAct : Routines.filesAreHardLinkedAct,
  filesAreHardLinked : Routines.filesAreHardLinked,
  filesSize : Routines.filesSize,
  fileSize : Routines.fileSize,

  directoryIs : Routines.directoryIs,
  directoryIsEmpty : Routines.directoryIsEmpty,

  directoriesAre : Routines.directoriesAre,
  directoriesAreEmpty : Routines.directoriesAreEmpty,


  // write act

  fileWriteAct : Routines.fileWriteAct,
  fileWriteStreamAct : Routines.fileWriteStreamAct,
  fileTimeSetAct : Routines.fileTimeSetAct,
  fileDeleteAct : Routines.fileDeleteAct,

  directoryMakeAct : Routines.directoryMakeAct,

  fileRenameAct : Routines.fileRenameAct,
  fileCopyAct : Routines.fileCopyAct,
  linkSoftAct : Routines.linkSoftAct,
  linkHardAct : Routines.linkHardAct,

  hardLinkTerminateAct : Routines.hardLinkTerminateAct,
  softLinkTerminateAct : Routines.softLinkTerminateAct,

  hardLinkTerminate : Routines.hardLinkTerminate,
  softLinkTerminate : Routines.softLinkTerminate,


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

  fileRename : Routines.fileRename,
  fileCopy : Routines.fileCopy,
  linkSoft : Routines.linkSoft,
  linkHard : Routines.linkHard,

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

  defaultProvider : null,
  defaultProtocol : 'file',
  // defaultOrigin : 'file://',

  providersWithProtocolMap : {},
  providersWithOriginMap : {},

}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

var Medials =
{
  empty : 0,
  defaultOrigin : null,
}

var Accessors =
{
  defaultProvider : 'defaultProvider',
  defaultProtocol : 'defaultProtocol',
  defaultOrigin : 'defaultOrigin',
}

// --
// prototype
// --

var Proto =
{

  init : init,

  // fields

  providerDefaultSet : providerDefaultSet,
  providerRegister : providerRegister,

  _providerInstanceRegister : _providerInstanceRegister,
  _providerClassRegister : _providerClassRegister,


  // adapter

  _fileRecordContextForm : _fileRecordContextForm,
  _fileRecordFormBegin : _fileRecordFormBegin,
  _fileRecordFormEnd : _fileRecordFormEnd,
  // fileRecord : fileRecord,

  fieldSet : fieldSet,
  fieldReset : fieldReset,


  // path

  providerForPath : providerForPath,

  localFromUrl : localFromUrl,
  _localFromUrl : _localFromUrl,
  pathNativize : pathNativize,
  _pathNativize : _pathNativize,

  pathJoin : _.urlJoin,
  pathNormalize : _.urlNormalize,
  pathsNormalize : _.urlsNormalize,
  pathIsNormalized : _.urlIsNormalized,


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

_.mapStretch( Self.prototype,FilteredRoutines );

for( var r in Routines )
{
  _.assert( _.mapOwnKey( Self.prototype,r ) || Routines[ r ] === Self.prototype[ r ],'routine',r,'was not written into Proto explicitly' );
}

_.assertMapHasNoUndefine( Proto );
_.assertMapHasNoUndefine( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

_.FileProvider[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
