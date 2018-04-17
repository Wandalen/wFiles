( function _rHub_s_() {

'use strict'; // aaa

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

  if( !o || !o.empty && _.fileProvider )
  {
    self.providerRegister( _.fileProvider );
    self.defaultProvider = _.fileProvider;
    self.defaultProtocol = 'file';
    self.defaultOrigin = 'file:///';
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

  // for( var p = 0 ; p < fileProvider.protocols.length ; p++ )
  // {
  //   var provider = fileProvider.protocols[ p ];
  //   if( self.providersWithOriginMap[ p ] )
  //   _.assert( !self.providersWithOriginMap[ p ],_.strQuote( fileProvider.nickName ),'is trying to reserve origin, reserved by',_.strQuote( self.providersWithOriginMap[ p ].nickName ) );
  //   self.providersWithOriginMap[ p ] = provider;
  // }

  // for( var p = 0 ; p < fileProvider.protocols.length ; p++ )
  // {
  //   var provider = fileProvider.protocols[ p ];
  //
  //   if( self.providersWithProtocolMap[ p ] )
  //   _.assert( !self.providersWithProtocolMap[ p ],_.strQuote( fileProvider.nickName ),'is trying to register protocol, registered by',_.strQuote( self.providersWithProtocolMap[ p ].nickName ) );
  //
  //   self.providersWithProtocolMap[ p ] = provider;
  // }

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

function pathNativize( filePath )
{
  var self = this;
  _.assert( _.strIs( filePath ) ) ;
  _.assert( arguments.length === 1 );
  return filePath;
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
  // _.assert( _.strIsNotEmpty( origin ) );
  _.assert( _.strIs( protocol ) );
  // _.assert( _.strIsNotEmpty( protocol ) );
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

function fileRecord( filePath, recordOptions )
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  filePath = _.urlNormalize( filePath );

  var provider = self.providerForPath( filePath );

  filePath = provider.localFromUrl( filePath );

  return provider.fileRecord( filePath, recordOptions );
}

//

function filesFind( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  o = { filePath : o };

  if( o.relative )
  o.relative = _.urlNormalize( o.relative );

  var filePath = _.urlParse( _.urlNormalize( o.filePath ) );

  if( o.relative )
  var relative = _.urlParse( _.urlNormalize( o.relative ) );
  var provider = self.providerForPath( filePath )
  o.filePath = provider.localFromUrl( filePath );

  if( o.relative )
  o.relative = provider.localFromUrl( relative );

  return provider.filesFind( o );
}

//

function filesDelete()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  var o = self._filesFindOptions.apply( self,arguments );

  o.filePath = _.urlNormalize( o.filePath );

  var filePath = _.urlParse( o.filePath );
  var provider = self.providerForPath( filePath )
  o.filePath = provider.localFromUrl( filePath );

  return provider.filesDelete( o );
}

//

function fileCopyAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileCopyAct,o );

  o.srcPath = _.urlNormalize( o.srcPath );
  o.dstPath = _.urlNormalize( o.dstPath );

  var srcPath = _.urlParse( o.srcPath );
  var srcProvider = self.providerForPath( srcPath )

  var dstPath = _.urlParse( o.dstPath );
  var dstProvider = self.providerForPath( dstPath )

  o.srcPath = srcProvider.pathNativize( o.srcPath );
  o.dstPath = dstProvider.pathNativize( o.dstPath );

  if( srcProvider === dstProvider )
  {
    o.srcPath = srcProvider.localFromUrl( srcPath );
    o.dstPath = dstProvider.localFromUrl( dstPath );
    return dstProvider.fileCopyAct( o );
  }
  else
  {
    var file = self.fileRead( o.srcPath );
    return self.fileWrite( o.dstPath, file );
  }
}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;

fileCopyAct.having = {};
fileCopyAct.having.__proto__ = Parent.prototype.fileCopyAct.having;

Routines.fileCopyAct = fileCopyAct;

//

function fieldSet()
{
  var self = this;

  Parent.prototype.fieldSet.apply( self, arguments );

  if( self.providersWithOriginMap )
  for( var k in self.providersWithOriginMap )
  {
    var provider = self.providersWithOriginMap[ k ];
    provider.fieldSet.apply( provider, arguments )
  }
}

//

function fieldReset()
{
  var self = this;

  Parent.prototype.fieldReset.apply( self, arguments );

  if( self.providersWithOriginMap )
  for( var k in self.providersWithOriginMap )
  {
    var provider = self.providersWithOriginMap[ k ];
    provider.fieldReset.apply( provider, arguments );
  }
}

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

function generateWritingRoutines()
{
  var self = this;

  for( var r in Parent.prototype ) (function()
  {
    var name = r;
    var original = Parent.prototype[ r ];

    // if( r === 'linkHardAct' )
    // debugger;

    if( !original )
    return;

    _.assert( original );

    if( !original.having )
    return;
    // if( !original.having.bare )
    // return;
    if( !original.defaults )
    return;
    if( original.defaults.filePath === undefined )
    return;

    var wrap = Routines[ r ] = function link( o )
    {
      var self = this;

      _.assert( arguments.length >= 1 && arguments.length <= 3 );

      if( arguments.length === 1 )
      {
        if( _.strIs( o ) )
        o = { filePath : o }
      }
      else if( ArgumentHandlers[ name ] )
      {
        o = ArgumentHandlers[ name ].apply( self, arguments );
      }

      _.routineOptions( wrap,o );

      o.filePath = _.pathGet( o.filePath );

      var filePath = _.urlNormalize( o.filePath );
      var provider = self.providerForPath( filePath );
      o.filePath = provider.localFromUrl( filePath );

      if( original.having.bare )
      o.filePath = provider.pathNativize( o.filePath );

      return provider[ name ]( o );
    }

    wrap.having = Object.create( original.having );
    wrap.defaults = Object.create( original.defaults );

    if( original.encoders )
    {
      wrap.encoders = Object.create( original.encoders );
    }

  })();

}

generateWritingRoutines();

//

function generateLinkingRoutines()
{
  var self = this;

  for( var r in Parent.prototype ) (function()
  {
    var name = r;
    var original = Parent.prototype[ r ];

    if( !original )
    return;

    // if( r === 'linkHardAct' )
    // debugger;

    if( Routines[ r ] )
    return;

    _.assert( original );

    if( !original.having )
    return;
    // if( !original.having.bare )
    // return;
    if( !original.defaults )
    return;
    if( original.defaults.dstPath === undefined || original.defaults.srcPath === undefined )
    return;

    var wrap = Routines[ r ] = function link( o )
    {
      var self = this;

      _.assert( arguments.length === 1 || arguments.length === 2 );

      if( !original.having.bare )
      if( arguments.length === 2 )
      {
        o =
        {
          dstPath : arguments[ 0 ],
          srcPath : arguments[ 1 ],
        }
      }

      _.routineOptions( wrap,o );

      o.srcPath = _.urlNormalize( o.srcPath );
      o.dstPath = _.urlNormalize( o.dstPath );

      var srcPath = _.urlParse( o.srcPath );
      var srcProvider = self.providerForPath( srcPath )

      var dstPath = _.urlParse( o.dstPath );
      var dstProvider = self.providerForPath( dstPath )


      if( original.having.bare )
      {
        o.srcPath = srcProvider.pathNativize( o.srcPath );
        o.dstPath = dstProvider.pathNativize( o.dstPath );
      }

      if( srcProvider === dstProvider )
      {
        o.srcPath = srcProvider.localFromUrl( srcPath );
        o.dstPath = dstProvider.localFromUrl( dstPath );
        return dstProvider[ name ]( o );
      }
      else
      {
        // _.assert( name === 'fileCopyAct' || !_.strEnds( name, 'Act' ) );

        // if( name === 'fileCopyAct' )
        // {
        //   var file = self.fileRead( o.srcPath );
        //   return self.fileWrite( o.dstPath, file );
        // }

        return Parent.prototype[ name ].call( self, o );
      }
    }

    wrap.having = Object.create( original.having );
    wrap.defaults = Object.create( original.defaults );

  })();

}

generateLinkingRoutines();

// --
// relationship
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
  providersWithProtocolMap : {},
  providersWithOriginMap : {},
  defaultProvider : null,
  defaultProtocol : 'file',
  defaultOrigin : 'file://',
}

var Restricts =
{
}

var Medials =
{
  empty : 0,
}

// --
// prototype
// --

var Proto =
{

  init : init,

  providerRegister : providerRegister,
  _providerInstanceRegister : _providerInstanceRegister,
  _providerClassRegister : _providerClassRegister,


  // adapter

  pathNativize : pathNativize,
  providerForPath : providerForPath,
  fileRecord : fileRecord,
  filesFind : filesFind,
  filesDelete : filesDelete,
  // directoryMake : directoryMake,
  // fileDelete : fileDelete,
  fieldSet : fieldSet,
  fieldReset : fieldReset,

  // read act

  fileReadAct : Routines.fileReadAct,
  fileReadStreamAct : Routines.fileReadStreamAct,
  fileStatAct : Routines.fileStatAct,
  fileHashAct : Routines.fileHashAct,

  directoryReadAct : Routines.directoryReadAct,

  // read content

  fileRead : Routines.fileRead,
  fileReadStream : Routines.fileReadStream,
  fileReadSync : Routines.fileReadSync,
  fileReadJson : Routines.fileReadJson,
  fileReadJs : Routines.fileReadJs,

  fileHash : Routines.fileHash,
  filesFingerprints : Routines.filesFingerprints,

  filesSame : Routines.filesSame,
  filesLinked : Routines.filesLinked,

  directoryRead : Routines.directoryRead,

  // read stat

  fileStat : Routines.fileStat,
  fileIsTerminal : Routines.fileIsTerminal,
  fileIsSoftLink : Routines.fileIsSoftLink,
  fileIsHardLink : Routines.fileIsHardLink,

  filesSize : Routines.filesSize,
  fileSize : Routines.fileSize,

  directoryIs : Routines.directoryIs,
  directoryIsEmpty : Routines.directoryIsEmpty,


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

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Medials : Medials,

}

//

for( var r in Routines )
_.assert( Routines[ r ] === Proto[ r ],'routine',r,'was not written into Proto explicitly' );
_.assert( Proto.linkHardAct );

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );
if( _.FileProvider.Path )
_.FileProvider.Path.mixin( Self );

//

_.FileProvider[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
