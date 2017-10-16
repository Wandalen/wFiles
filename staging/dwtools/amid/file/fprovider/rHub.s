( function _rHub_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

}

//

var _ = wTools;
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

  debugger;

  _.assert( arguments.length === 1 );
  _.assert( fileProvider instanceof _.FileProvider.Abstract );
  _.assert( fileProvider.protocols && fileProvider.protocols.length,'cant register file provider without protocols',_.strQuote( fileProvider.nameNick ) );
  _.assert( _.strIsNotEmpty( fileProvider.origin ),'cant register file provider without origin',_.strQuote( fileProvider.nameNick ) );

  for( var p = 0 ; p < fileProvider.protocols.length ; p++ )
  {
    var provider = fileProvider.protocols[ p ];
    if( self.providersWithOriginMap[ p ] )
    _.assert( !self.providersWithOriginMap[ p ],_.strQuote( fileProvider.nameNick ),'is trying to reserve origin, reserved by',_.strQuote( self.providersWithOriginMap[ p ].nameNick ) );
    self.providersWithOriginMap[ p ] = provider;
  }

  // for( var p = 0 ; p < fileProvider.protocols.length ; p++ )
  // {
  //   var provider = fileProvider.protocols[ p ];
  //
  //   if( self.providersWithProtocolMap[ p ] )
  //   _.assert( !self.providersWithProtocolMap[ p ],_.strQuote( fileProvider.nameNick ),'is trying to register protocol, registered by',_.strQuote( self.providersWithProtocolMap[ p ].nameNick ) );
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
  //_.assert( o.provider.prototype instanceof _.FileProvider.Abstract.prototype );

  if( !o.protocols )
  o.protocols = o.provider.protocols;

  _.assert( o.protocols && o.protocols.length,'cant register file provider without protocols',_.strQuote( o.provider.nameNick ) );

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

  _.assert( _.mapIs( url ) ) ;
  _.assert( arguments.length === 1 );

  var protocol = url.protocol[ 0 ].toLowerString();

  for( var f in providersWithProtocolMap )
  {
    if( protocol === f )
    return providersWithProtocolMap[ f ];
  }

  return self.defaultProvider;
}

// --
// read
// --

function fileReadAct( o )
{
  var self = this;
  var result = null;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileReadAct,o );

  var filePath = _.urlParse( o.filePath );
  var provider = self.providerForPath( filePath )
  o.filePath = provider.localFromUrl( filePath );
  return provider.fileReadAct( o );
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

//

function fileReadStreamAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );
  var o = _.routineOptions( fileReadStreamAct, o );

  xxx;

  var filePath = _.urlParse( o.filePath );
  var provider = self.providerForPath( filePath )
  o.filePath = provider.localFromUrl( filePath );
  return provider.fileReadStreamAct( o );
}

fileReadStreamAct.defaults = {};
fileReadStreamAct.defaults.__proto__ = Parent.prototype.fileReadStreamAct.defaults;

//

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );
  _.assert( !o.sync,'not implemented' );

  var o = _.routineOptions( fileStatAct,o );
  var result = null;

  /* */

  var filePath = _.urlParse( o.filePath );
  var provider = self.providerForPath( filePath )
  o.filePath = provider.localFromUrl( filePath );
  return provider.fileReadAct( o );
}

fileStatAct.defaults = {};
fileStatAct.defaults.__proto__ = Parent.prototype.fileStatAct.defaults;

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


  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : fileReadStreamAct,
  fileStatAct : fileStatAct,
  fileHashAct : null,

  // directoryReadAct : directoryReadAct,


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
if( _.FileProvider.Path )
_.FileProvider.Path.mixin( Self );

//

// if( typeof module !== 'undefined' )
// if( !_.FileProvider.Default )
// {
//   _.FileProvider.Default = Self;
//   _.fileProvider = new Self();
// }

_.FileProvider[ Self.nameShort ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
