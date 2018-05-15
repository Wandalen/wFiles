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

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );

  _.assert( arguments.length === 0 || arguments.length === 1 );

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

function _fileRecordFormBegin( record )
{
  var self = this;

  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );

  debugger;

  // record.fileProvider = record.fileProvider.providerForPath( record.input );
  // record.input = record.fileProvider.localFromUrl( record.input );

  return path;
}

//

function _fileRecordFormEnd( record )
{
  var self = this;
  _.assert( record instanceof _.FileRecord );
  _.assert( arguments.length === 1 );
  _.assert( record.fileProvider === self );

  debugger;

  record.absoluteEffective = record.full;
  record.fileProviderEffective = self.providerForPath( record.absoluteEffective );

  return record;
}

//

function fileRecord( filePath, recordContext )
{
  var self = this;
  var provider = self;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  // filePath = _.urlNormalize( filePath );
  //
  // var provider = self.providerForPath( filePath );
  //
  // _.assert( provider );
  //
  // filePath = provider.localFromUrl( filePath );
  // debugger;
  // return provider.fileRecord( filePath, recordContext );

  return Parent.prototype.fileRecord.call( self, filePath, recordContext );
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

//

function providerForPath( url )
{
  var self = this;

  if( _.strIs( url ) )
  url = _.urlParse( url );

  _.assert( url.protocols.length ? url.protocols[ 0 ].toLowerCase : true );

  var origin = url.origin || self.defaultOrigin;
  var protocol = url.protocols.length ? url.protocols[ 0 ].toLowerCase() : self.defaultProtocol;

  _.assert( _.strIs( origin ) );
  _.assert( _.strIs( protocol ) );
  _.assert( _.mapIs( url ) ) ;
  _.assert( arguments.length === 1 );

  if( self.providersWithOriginMap[ origin ] )
  {
    return self.providersWithOriginMap[ origin ];
  }

  if( self.providersWithProtocolMap[ protocol ] )
  {
    debugger; xxx;
    var Provider = self.providersWithProtocolMap[ protocol ];
    var provider = new Provider({ oiriginPath : origin });
    self.providerRegister( provider );
    return provider;
  }

  return self.defaultProvider;
}

//

function localFromUrl( filePath )
{
  var self = this;
  _.assert( arguments.length === 1 );
  return self._localFromUrl( filePath );
}

//

function _localFromUrl( filePath,provider )
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  var parsedPath = filePath;
  if( _.strIs( filePath ) )
  parsedPath = _.urlParse( _.urlNormalize( parsedPath ) );

  if( !parsedPath.protocols.length )
  return filePath;

  if( !provider )
  provider = self.providerForPath( parsedPath );

  _.assert( provider );

  return provider.localFromUrl( parsedPath );
}

//

function pathNativize( filePath )
{
  var self = this;

  _.assert( _.strIs( filePath ) ) ;
  _.assert( arguments.length === 1 );

  var parsedPath = filePath;
  if( _.strIs( filePath ) )
  parsedPath = _.urlParse( _.urlNormalize( parsedPath ) );

  if( !parsedPath.protocols.length )
  return filePath;

  if( !provider )
  provider = self.providerForPath( parsedPath );

  _.assert( provider );

  return provider.pathNativize( provider.localFromUrl( parsedPath ) );
}

// --
//
// --

// function filesFind( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//
//   if( _.strIs( o ) )
//   o = { filePath : o };
//
//   var provider;
//
//   function pathToLocal( path )
//   {
//     var path = _.urlParse( _.urlNormalize( path ) );
//     if( !provider )
//     provider = self.providerForPath( path );
//     return provider.localFromUrl( path );
//   }
//
//   if( o.globIn )
//   o.globIn = pathToLocal( o.globIn );
//
//   if( o.filePath )
//   o.filePath = pathToLocal( o.filePath );
//
//   if( o.basePath )
//   o.basePath = pathToLocal( o.basePath );
//
//   _.assert( provider );
//
//   return provider.filesFind( o );
// }
//
// //
//
// function filesDelete()
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 || arguments.length === 3 );
//
//   var o = self._filesFindOptions( arguments,1 );
//
//   o.filePath = _.urlNormalize( o.filePath );
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//
//   return provider.filesDelete( o );
// }
//
// //
//
// function fileCopyAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( fileCopyAct,o );
//
//   debugger; xxx
//
//   o.srcPath = _.urlNormalize( o.srcPath );
//   o.dstPath = _.urlNormalize( o.dstPath );
//
//   var srcPath = _.urlParse( o.srcPath );
//   var srcProvider = self.providerForPath( srcPath )
//
//   var dstPath = _.urlParse( o.dstPath );
//   var dstProvider = self.providerForPath( dstPath )
//
//   o.srcPath = srcProvider.pathNativize( o.srcPath );
//   o.dstPath = dstProvider.pathNativize( o.dstPath );
//
//   if( srcProvider === dstProvider )
//   {
//     o.srcPath = srcProvider.localFromUrl( srcPath );
//     o.dstPath = dstProvider.localFromUrl( dstPath );
//     return dstProvider.fileCopyAct( o );
//   }
//   else
//   {
//     var file = self.fileRead( o.srcPath );
//     return self.fileWrite( o.dstPath, file );
//   }
//
// }
//
// fileCopyAct.defaults = {};
// fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;
//
// fileCopyAct.having = {};
// fileCopyAct.having.__proto__ = Parent.prototype.fileCopyAct.having;

// Routines.fileCopyAct = fileCopyAct;

// --
//
// --

var ArgumentHandlers = {};

ArgumentHandlers.fileWrite = function fileWriteArguments()
{
  return { filePath : arguments[ 0 ], data : arguments[ 1 ] };
}

ArgumentHandlers.fileTimeSet = function fileTimeSetArguments()
{
  return { filePath : arguments[ 0 ], atime : arguments[ 1 ], mtime : arguments[ 2 ] };
}

//

function routinesGenerate()
{
  var self = this;

  var KnownRoutineFields =
  {
    pre : null,
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

    // if( !original.defaults )
    // return;
    // if( original.defaults.filePath === undefined )
    // return;

    if(  original.defaults )
    _.assert( original.paths );
    if(  original.paths )
    _.assert( original.defaults );

    var havingBare = having.bare;
    var paths = original.paths;
    var pre = original.pre;
    var wrap = Routines[ r ] = function hub( o )
    {
      var self = this;

      // debugger;
      // _.assert( arguments.length >= 1 && arguments.length <= 3 );

      if( arguments.length === 1 )
      {
        if( _.strIs( o ) )
        o = { filePath : o }
      }
      else if( ArgumentHandlers[ name ] )
      {
        debugger;
        o = ArgumentHandlers[ name ].apply( self, arguments );
      }

      if( pre )
      o = pre.call( this,wrap,arguments );
      else
      _.routineOptions( wrap,o );

      for( var p in paths )
      if( o[ p ] )
      {
        if( havingBare )
        o[ p ] = self.pathNativize( o[ p ] );
        else
        o[ p ] = self.localFromUrl( o[ p ] );
      }

      _.assert( _.routineIs( original ) );
      return original.call( self,o );
      // return self[ name ].call( self,o );
    }

    wrap.having = Object.create( original.having );

    if( original.defaults )
    {
      wrap.defaults = Object.create( original.defaults );
      wrap.paths = Object.create( original.paths );
    }

    if( original.encoders )
    {
      wrap.encoders = Object.create( original.encoders );
    }

  })();

}

routinesGenerate();

//

// function generateLinkingRoutines()
// {
//   var self = this;
//
//   for( var r in Parent.prototype ) (function()
//   {
//     var name = r;
//     var original = Parent.prototype[ r ];
//
//     if( name === 'fileCopyAct' )
//     debugger;
//
//     if( !original )
//     return;
//
//     // if( Routines[ r ] )
//     // return;
//
//     _.assert( original );
//     _.assert( !Routines[ r ] );
//
//     if( !original.having )
//     return;
//     if( !original.defaults )
//     return;
//     if( original.defaults.dstPath === undefined || original.defaults.srcPath === undefined )
//     return;
//
//     var wrap = Routines[ r ] = function link( o )
//     {
//       var self = this;
//
//       _.assert( arguments.length === 1 || arguments.length === 2 );
//
//       if( !original.having.bare )
//       if( arguments.length === 2 )
//       {
//         o =
//         {
//           dstPath : arguments[ 0 ],
//           srcPath : arguments[ 1 ],
//         }
//       }
//
//       _.routineOptions( wrap,o );
//
//       o.srcPath = _.urlNormalize( o.srcPath );
//       o.dstPath = _.urlNormalize( o.dstPath );
//
//       var srcPath = _.urlParse( o.srcPath );
//       var srcProvider = self.providerForPath( srcPath )
//
//       var dstPath = _.urlParse( o.dstPath );
//       var dstProvider = self.providerForPath( dstPath )
//
//
//       if( original.having.bare )
//       {
//         o.srcPath = srcProvider.pathNativize( o.srcPath );
//         o.dstPath = dstProvider.pathNativize( o.dstPath );
//       }
//
//       if( srcProvider === dstProvider )
//       {
//         o.srcPath = srcProvider.localFromUrl( srcPath );
//         o.dstPath = dstProvider.localFromUrl( dstPath );
//         return dstProvider[ name ]( o );
//       }
//       else
//       {
//         return Parent.prototype[ name ].call( self, o );
//       }
//     }
//
//     wrap.having = Object.create( original.having );
//     wrap.defaults = Object.create( original.defaults );
//
//   })();
//
// }
//
// generateLinkingRoutines();

// --
// relationship
// --

var Composes =
{

  defaultProvider : null,
  defaultProtocol : 'file',
  defaultOrigin : 'file://',

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
}

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

  filesSame : Routines.filesSame,
  filesAreHardLinked : Routines.filesAreHardLinked,

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

  _fileRecordFormBegin : _fileRecordFormBegin,
  _fileRecordFormEnd : _fileRecordFormEnd,
  fileRecord : fileRecord,

  fieldSet : fieldSet,
  fieldReset : fieldReset,

  providerForPath : providerForPath,
  localFromUrl : localFromUrl,
  _localFromUrl : _localFromUrl,
  pathNativize : pathNativize,


  //

  // filesFind : filesFind,
  // filesDelete : filesDelete,
  // fileCopyAct : fileCopyAct,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Medials : Medials,

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

_.mapExtend( Self.prototype,FilteredRoutines );

for( var r in Routines )
_.assert( Routines[ r ] === Self.prototype[ r ],'routine',r,'was not written into Proto explicitly' );
_.assert( Self.prototype.linkHardAct );

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
