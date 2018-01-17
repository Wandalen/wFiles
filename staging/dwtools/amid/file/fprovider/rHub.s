( function _rHub_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

}

//

var _ = wTools;
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
  _.assert( !self.providersWithOriginMap[ originPath ],_.strQuote( fileProvider.nickName ),'is trying to reserve origin, reserved by',_.strQuote( self.providersWithOriginMap[ p ].nickName ) );

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

  _.assert( _.strIsNotEmpty( origin ) );
  _.assert( _.strIsNotEmpty( protocol ) );
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

  var provider = self.providerForPath( filePath );

  return provider.fileRecord( filePath, recordOptions );
}

//

function directoryMake( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  {
    o = { filePath : o }
  }

  var provider = self.providerForPath( o.filePath );

  return provider.directoryMake( o );
}

//

function fileDelete( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  {
    o = { filePath : o }
  }

  var provider = self.providerForPath( o.filePath );

  return provider.fileDelete( o );
}

//

function fieldSet()
{
  var self = this;

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

  for( var k in self.providersWithOriginMap )
  {
    var provider = self.providersWithOriginMap[ k ];
    provider.fieldReset.apply( provider, arguments )
  }
}

// --
// read
// --

// function fileReadAct( o )
// {
//   var self = this;
//   var result = null;
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( fileReadAct,o );
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//   return provider.fileReadAct( o );
// }
//
// fileReadAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );
// fileReadAct.having = Object.create( Parent.prototype.fileReadAct.having );
//
// //
//
// function fileReadStreamAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.filePath ) );
//   var o = _.routineOptions( fileReadStreamAct, o );
//
//   xxx;
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//   return provider.fileReadStreamAct( o );
// }
//
// fileReadStreamAct.defaults = Object.create( Parent.prototype.fileReadStreamAct.defaults );
// fileReadStreamAct.having = Object.create( Parent.prototype.fileReadStreamAct.having );
//
// //
//
// function fileStatAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.filePath ) );
//
//   var o = _.routineOptions( fileStatAct,o );
//   var result = null;
//
//   /* */
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//
//   return provider.fileStatAct( o );
// }
//
// fileStatAct.defaults = Object.create( Parent.prototype.fileStatAct.defaults );
// fileStatAct.having = Object.create( Parent.prototype.fileStatAct.having );
//
// //
//
// function directoryReadAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( directoryReadAct,o );
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//
//   return provider.directoryReadAct( o );
// }
//
// directoryReadAct.defaults = Object.create( Parent.prototype.directoryReadAct.defaults );
// directoryReadAct.having = Object.create( Parent.prototype.directoryReadAct.having );

// --
//
// --

function generateWritingRoutines()
{
  var self = this;

  for( var r in Parent.prototype ) (function()
  {
    var name = r;
    var original = Parent.prototype[ r ];

    if( !original.having )
    return;
    if( !original.having.bare )
    return;
    if( !original.defaults )
    return;
    if( original.defaults.filePath === undefined )
    return;

    var wrap = Routines[ r ] = function link( o )
    {
      var self = this;

      _.assert( arguments.length === 1 );
      _.routineOptions( wrap,o );

      var filePath = _.urlParse( o.filePath );
      var provider = self.providerForPath( filePath );
      o.filePath = provider.localFromUrl( filePath );
      o.filePath = provider.pathNativize( o.filePath );

      if( provider[ name ].encoders )
      Routines[ name ].encoders = Object.create( provider[ name ].encoders )

      return provider[ name ]( o );
    }

    wrap.having = Object.create( original.having );
    wrap.defaults = Object.create( original.defaults );



  })();

}

generateWritingRoutines();

//

// function fileDeleteAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( fileDeleteAct,o );
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//
//   return provider.fileDeleteAct( o );
// }
//
// fileDeleteAct.defaults = Object.create( Parent.prototype.fileDeleteAct.defaults );
// fileDeleteAct.having = Object.create( Parent.prototype.fileDeleteAct.having );
//
// //
//
// function directoryMakeAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( directoryMakeAct,o );
//
//   var filePath = _.urlParse( o.filePath );
//   var provider = self.providerForPath( filePath )
//   o.filePath = provider.localFromUrl( filePath );
//
//   return provider.directoryMakeAct( o );
// }
//
// directoryMakeAct.defaults = Object.create( Parent.prototype.directoryMakeAct.defaults );
// directoryMakeAct.having = Object.create( Parent.prototype.directoryMakeAct.having );
//
// /* fileWriteAct */

//

function generateLinkingRoutines()
{
  var self = this;

  for( var r in Parent.prototype ) (function()
  {
    var name = r;
    var original = Parent.prototype[ r ];

    // if( name === 'linkHardAct' )
    // debugger;
    // if( !_.routineIs( original ) )
    // return;

    if( !original.having )
    return;
    if( !original.having.bare )
    return;
    if( !original.defaults )
    return;
    if( original.defaults.dstPath === undefined || original.defaults.srcPath === undefined )
    return;

    var wrap = Routines[ r ] = function link( o )
    {
      var self = this;

      _.assert( arguments.length === 1 );
      _.routineOptions( wrap,o );

      o.srcPath = _.urlNormalize( o.srcPath );
      o.dstPath = _.urlNormalize( o.dstPath );

      var srcPath = _.urlParse( o.srcPath );
      var srcProvider = self.providerForPath( srcPath )
      o.srcPath = srcProvider.localFromUrl( srcPath );

      var dstPath = _.urlParse( o.dstPath );
      var dstProvider = self.providerForPath( dstPath )
      o.dstPath = dstProvider.localFromUrl( dstPath );

      o.srcPath = srcProvider.pathNativize( o.srcPath );
      o.dstPath = dstProvider.pathNativize( o.dstPath );

      _.assert( srcProvider === dstProvider );

      return dstProvider[ name ]( o );
    }

    wrap.having = Object.create( original.having );
    wrap.defaults = Object.create( original.defaults );

  })();

}

generateLinkingRoutines();

// function linkSoftAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( directoryMakeAct,o );
//
//   var srcPath = _.urlParse( o.srcPath );
//   var srcProvider = self.providerForPath( srcPath )
//   o.srcPath = srcProvider.localFromUrl( srcPath );
//
//   var dstPath = _.urlParse( o.dstPath );
//   var dstProvider = self.providerForPath( dstPath )
//   o.dstPath = dstProvider.localFromUrl( dstPath );
//
//   _.assert( srcProvider === dstProvider );
//
//   return dstProvider.directoryMakeAct( o );
// }

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
  defaultProtocol : null,
  defaultOrigin : null,
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
  directoryMake : directoryMake,
  fileDelete : fileDelete,
  fieldSet : fieldSet,
  fieldReset : fieldReset,


  // read

  fileReadAct : Routines.fileReadAct,
  fileReadStreamAct : Routines.fileReadStreamAct,
  fileStatAct : Routines.fileStatAct,
  fileHashAct : Routines.fileHashAct,

  directoryReadAct : Routines.directoryReadAct,


  //

  fileWriteAct : Routines.fileWriteAct,
  fileWriteStreamAct : Routines.fileWriteStreamAct,
  fileDeleteAct : Routines.fileDeleteAct,
  directoryMakeAct : Routines.directoryMakeAct,

  fileTimeSetAct : Routines.fileTimeSetAct,
  hardLinkTerminateAct : Routines.hardLinkTerminateAct,
  softLinkTerminateAct : Routines.softLinkTerminateAct,

  linkSoftAct : Routines.linkSoftAct,
  linkHardAct : Routines.linkHardAct,
  fileCopyAct : Routines.fileCopyAct,
  fileRenameAct : Routines.fileRenameAct,

  // // read
  //
  // fileReadAct : fileReadAct,
  // fileReadStreamAct : fileReadStreamAct,
  // fileStatAct : fileStatAct,
  // fileHashAct : fileHashAct,
  //
  // directoryReadAct : directoryReadAct,
  //
  //
  // // write
  //
  // fileWriteStreamAct : fileWriteStreamAct,
  //
  // fileWriteAct : fileWriteAct,
  //
  // fileDeleteAct : fileDeleteAct,
  // fileDelete : fileDelete,
  //
  // fileCopyAct : fileCopyAct,
  // fileRenameAct : fileRenameAct,
  //
  // fileTimeSetAct : fileTimeSetAct,
  //
  // directoryMakeAct : directoryMakeAct,
  // directoryMake : directoryMake,
  //
  // linkSoftAct : linkSoftAct,
  // linkHardAct : linkHardAct,


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
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
