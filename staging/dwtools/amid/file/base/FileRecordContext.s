( function _FileRecordContext_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' )

}

var _ = _global_.wTools;

_.assert( !_.FileRecordContext );

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecordContext( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self && arguments.length === 1 )
  {
    _.assert( arguments.length === 1 );
    return o;
  }
  else
  {
    return new( _.routineJoin( Self, Self, arguments ) );
  }
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileRecordContext';

//

function init( o )
{
  var self = this;

  self[ resolvingSoftLinkSymbol ] = null;
  self[ resolvingTextLinkSymbol ] = null;
  self[ usingTextLinkSymbol ] = null;
  self[ originPathSymbol ] = null;
  self[ statingSymbol ] = null;
  self[ safeSymbol ] = null;

  _.instanceInit( self );
  // Object.assign( self,self.copyableFields );
  Object.preventExtensions( self );

  // debugger;

  _.assert( self.originPath === null );

  /* */

  if( arguments.length !== 1 || arguments[ 0 ] !== undefined )
  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var src = arguments[ a ];

    // debugger;
    if( !_.mapIs( src ) )
    debugger;
    if( _.mapIs( src ) )
    Object.assign( self,src );
    else
    Object.assign( self,_.mapScreen( Self.prototype.copyableFields,src ) );
  }

  /* */

  if( self.basePath )
  {
    self.basePath = _.pathGet( self.basePath );
    self.basePath = self.fileProvider.pathNormalize( self.basePath );

    if( !self.fileProviderEffective )
    self.fileProviderEffective = self.fileProvider.providerForPath( self.basePath );

    if( Config.debug )
    if( _.urlIsGlobal( self.basePath ) )
    {
      var url = _.urlParse( self.basePath );
      _.assert( self.originPath === null || self.originPath === '' || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
    }
  }

  if( self.dir )
  {
    self.dir = _.pathGet( self.dir );
    self.dir = self.fileProvider.pathNormalize( self.dir );

    if( !self.fileProviderEffective )
    self.fileProviderEffective = self.fileProvider.providerForPath( self.dir );

    if( Config.debug )
    if( _.urlIsGlobal( self.dir ) )
    {
      var url = _.urlParse( self.dir );
      _.assert( self.originPath === null || self.originPath === '' || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
    }
  }

  // if( self.dir )
  // {
  //   self.dir = _.pathGet( self.dir );
  //   if( _.urlIsGlobal( self.dir ) )
  //   {
  //     var url = _.urlParse( self.dir );
  //     _.assert( self.originPath === null || self.originPath === '' || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
  //     url.localPath = _.pathNormalize( url.localPath );
  //     if( url.origin )
  //     self.originPath = url.origin;
  //     self.dir = _.urlStr( url );
  //   }
  //   else
  //   {
  //     self.dir = _.pathNormalize( self.dir );
  //   }
  // }

  if( !self.basePath )
  if( self.dir )
  {
    self.basePath = self.dir;
  }

  _.assert( self.basePath );

  /* */

  _.assert( self.fileProvider );
  self.fileProvider._fileRecordContextForm( self );

  if( !self.fileProviderEffective )
  self.fileProviderEffective = self.fileProvider;

  /**/

  if( self.dir )
  _.assert( _.urlIsGlobal( self.dir ) || _.pathIsAbsolute( self.dir ),'( o.dir ) should be absolute path',self.dir );

  if( self.basePath )
  _.assert( _.urlIsGlobal( self.basePath ) || _.pathIsAbsolute( self.basePath ),'o.basePath should be absolute path',self.basePath );

  _.assert( self.filter instanceof _.FileRecordFilter );
  // _.assert( self.filter.maskAll === null || _.regexpObjectIs( self.filter.maskAll ) );
  // _.assert( self.filter.maskTerminal === null || _.regexpObjectIs( self.filter.maskTerminal ) );
  // _.assert( self.filter.maskDir === null || _.regexpObjectIs( self.filter.maskDir ) );

  Object.freeze( self );
}

//

function tollerantMake( o )
{
  _.assert( arguments.length >= 1 );
  _.assert( Self.prototype.Composes );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapScreen( Self.prototype.copyableFields,o ) );
}

//

function _resolvingSoftLinkGet()
{
  var self = this;

  if( self[ resolvingSoftLinkSymbol ] !== null )
  return self[ resolvingSoftLinkSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.resolvingSoftLink;
  else if( self.fileProvider )
  return self.fileProvider.resolvingSoftLink;

  return self[ resolvingSoftLinkSymbol ];
}

//

function _resolvingTextLinkGet()
{
  var self = this;

  if( self[ resolvingTextLinkSymbol ] !== null )
  return self[ resolvingTextLinkSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.resolvingTextLink;
  else if( self.fileProvider )
  return self.fileProvider.resolvingTextLink;

  return self[ resolvingTextLinkSymbol ];
}

//

function _usingTextLinkGet()
{
  var self = this;

  if( self[ usingTextLinkSymbol ] !== null )
  return self[ usingTextLinkSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.usingTextLink;
  else if( self.fileProvider )
  return self.fileProvider.usingTextLink;

  return self[ usingTextLinkSymbol ];
}

//

function _originPathGet()
{
  var self = this;

  if( self[ originPathSymbol ] !== null )
  return self[ originPathSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.originPath;
  else if( self.fileProvider )
  return self.fileProvider.originPath;

  return self[ originPathSymbol ];
}

//

function _statingGet()
{
  var self = this;

  if( self[ statingSymbol ] !== null )
  return self[ statingSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.stating;
  else if( self.fileProvider )
  return self.fileProvider.stating;

  return self[ statingSymbol ];
}

//

function _safeGet()
{
  var self = this;

  if( self[ safeSymbol ] !== null )
  return self[ safeSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.safe;
  else if( self.fileProvider )
  return self.fileProvider.safe;

  return self[ safeSymbol ];
}

// --
//
// --

var resolvingSoftLinkSymbol = Symbol.for( 'resolvingSoftLink' );
var resolvingTextLinkSymbol = Symbol.for( 'resolvingTextLink' );
var usingTextLinkSymbol = Symbol.for( 'usingTextLink' );
var originPathSymbol = Symbol.for( 'originPath' );
var statingSymbol = Symbol.for( 'stating' );
var safeSymbol = Symbol.for( 'safe' );

var Composes =
{

  dir : null,
  basePath : null,

  // maskAll : null,
  // maskTerminal : null,
  // maskDir : null,
  //
  // notOlder : null,
  // notNewer : null,
  // notOlderAge : null,
  // notNewerAge : null,

  onRecord : null,

  strict : 1,
  sync : 1,

  resolvingSoftLink : null,
  resolvingTextLink : null,
  usingTextLink : null,
  originPath : null,
  stating : null,
  safe : null,

}

var Aggregates =
{
}

var Associates =
{
  fileProvider : null,
  fileProviderEffective : null,
  filter : null,
}

var Restricts =
{
}

var Statics =
{
  tollerantMake : tollerantMake,
  // copyableFields : Object.create( null ),
}

var Accessors =
{
  resolvingSoftLink : 'resolvingSoftLink',
  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',

  originPath : 'originPath',
  stating : 'stating',
  safe : 'safe',
}

var Forbids =
{
  relative : 'relative',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',

  maskAll : 'maskAll',
  maskTerminal : 'maskTerminal',
  maskDir : 'maskDir',

  notOlder : 'notOlder',
  notNewer : 'notNewer',
  notOlderAge : 'notOlderAge',
  notNewerAge : 'notNewerAge',

}

// --
// prototype
// --

var Proto =
{

  init : init,
  tollerantMake : tollerantMake,

  _resolvingSoftLinkGet : _resolvingSoftLinkGet,
  _resolvingTextLinkGet : _resolvingTextLinkGet,
  _usingTextLinkGet : _usingTextLinkGet,

  _originPathGet : _originPathGet,
  _statingGet : _statingGet,
  _safeGet : _safeGet,

  /**/

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

// if( Proto.Composes )
// _.mapExtend( Statics.copyableFields,Proto.Composes );
// if( Proto.Aggregates )
// _.mapExtend( Statics.copyableFields,Proto.Aggregates );
// if( Proto.Associates )
// _.mapExtend( Statics.copyableFields,Proto.Associates );

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.accessor( Self.prototype,Accessors );
_.accessorForbid( Self.prototype,Forbids );

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
{

  require( './FileRecord.s' );

}

//

_[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
