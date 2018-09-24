( function _FileRecordContext_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' )

}

var _global = _global_;
var _ = _global_.wTools;

_.assert( !_.FileRecordContext );

//

var _global = _global_;
var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecordContext( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self && arguments.length === 1 )
  {
    _.assert( arguments.length === 1, 'expects single argument' );
    return o;
  }
  else
  {
    return new( _.routineJoin( Self, Self, arguments ) );
  }
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'FileRecordContext';

//

function init( o )
{
  var self = this;

  self[ usingSoftLinkSymbol ] = null;
  self[ resolvingSoftLinkSymbol ] = null;
  self[ usingTextLinkSymbol ] = null;
  self[ resolvingTextLinkSymbol ] = null;
  self[ originPathSymbol ] = null;
  self[ statingSymbol ] = null;
  self[ safeSymbol ] = null;

  _.instanceInit( self );
  Object.preventExtensions( self );

  _.assert( self.originPath === null );

  /* */

  if( arguments.length !== 1 || arguments[ 0 ] !== undefined )
  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var src = arguments[ a ];

    if( !_.mapIs( src ) )
    debugger;
    if( _.mapIs( src ) )
    Object.assign( self,src );
    else
    Object.assign( self,_.mapOnly( src, Self.prototype.fieldsOfCopyableGroups ) );
  }

  // debugger;
  // self.form();
}

//

function TollerantMake( o )
{
  _.assert( arguments.length >= 1, 'expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

//

function form()
{
  let self = this;
  let path = self.fileProvider.path;

  // if( self.branchPath === 'tmp:///' )
  // debugger;

  _.assert( arguments.length === 0 );
  _.assert( !self.formed );

  self.formed = 1;

  /* */

  if( self.basePath )
  {

    self.basePath = path.from( self.basePath );
    self.basePath = path.normalize( self.basePath );

    if( !self.fileProviderEffective )
    self.fileProviderEffective = self.fileProvider.providerForPath( self.basePath );

    if( Config.debug )
    if( _.uri.isGlobal( self.basePath ) )
    {
      var url = _.uri.parse( self.basePath );
      _.assert( self.originPath === null || self.originPath === '' || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
    }
  }

  if( self.dirPath )
  {
    self.dirPath = path.from( self.dirPath );
    self.dirPath = path.normalize( self.dirPath );

    if( self.basePath )
    self.dirPath = path.join( self.basePath, self.dirPath );

    // if( !self.fileProviderEffective )
    // self.fileProviderEffective = self.fileProvider.providerForPath( self.dirPath );

    if( Config.debug )
    if( _.uri.isGlobal( self.dirPath ) )
    {
      var url = _.uri.parse( self.dirPath );
      _.assert( self.originPath === null || self.originPath === '' || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
    }
  }

  if( !self.branchPath )
  {
    self.branchPath = path.normalize( path.join( self.basePath, self.dirPath || '' ) );
  }
  else if( self.branchPath )
  {
    //debugger;
    self.branchPath = path.normalize( path.join( self.basePath, self.dirPath || '', self.branchPath ) );
  }

  if( !self.basePath )
  if( self.dirPath )
  {
    self.basePath = self.dirPath;
  }

  if( !self.basePath && self.filter && self.branchPath )
  self.basePath = self.filter.basePath[ self.branchPath ];

  /* */

  self.fileProvider._fileRecordContextForm( self );

  if( !self.fileProviderEffective )
  self.fileProviderEffective = self.fileProvider;

  /* */

  if( Config.debug )
  {

    _.assert( self.fileProvider instanceof _.FileProvider.Abstract );
    _.assert( path.isAbsolute( self.basePath ) );
    _.assert( self.dirPath === null || path.is( self.dirPath ) );
    // _.assert( self.branchPath === null || path.isAbsolute( self.branchPath ) );
    _.assert( path.isAbsolute( self.branchPath ) );

    if( self.dirPath )
    _.assert( _.uri.isGlobal( self.dirPath ) || path.isAbsolute( self.dirPath ), () => '{-o.dirPath-} should be absolute path' + _.strQuote( self.dirPath ) );

    // if( self.basePath )
    // {
      _.assert( _.strIsNotEmpty( self.basePath ) );
      _.assert( _.uri.isGlobal( self.basePath ) || path.isAbsolute( self.basePath ), () => '{-o.basePath-} should be absolute path' + _.strQuote( self.basePath ) );
    // }

    _.assert( self.filter === null || self.filter instanceof _.FileRecordFilter );

    if( self.filter )
    {
      _.assert( !!self.filter.formed );
      // if( _.uri.isGlobal( self.filter.basePath ) )
      // _.assert( _.uri.parse( self.filter.basePath ).localPath === self.basePath );
      // else
      _.assert( self.filter.basePath[ self.branchPath ] === self.basePath );
    }

  }

  Object.freeze( self );
  return self;
}

//

function _usingSoftLinkGet()
{
  var self = this;

  if( self[ usingSoftLinkSymbol ] !== null )
  return self[ usingSoftLinkSymbol ];

  if( self.fileProviderEffective )
  return self.fileProviderEffective.usingSoftLink;
  else if( self.fileProvider )
  return self.fileProvider.usingSoftLink;

  return self[ usingSoftLinkSymbol ];
}

//

function _resolvingSoftLinkSet( src )
{
  var self = this;
  self[ resolvingSoftLinkSymbol ] = src;
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

var usingSoftLinkSymbol = Symbol.for( 'usingSoftLink' );
var resolvingSoftLinkSymbol = Symbol.for( 'resolvingSoftLink' );
var usingTextLinkSymbol = Symbol.for( 'usingTextLink' );
var resolvingTextLinkSymbol = Symbol.for( 'resolvingTextLink' );
var originPathSymbol = Symbol.for( 'originPath' );
var statingSymbol = Symbol.for( 'stating' );
var safeSymbol = Symbol.for( 'safe' );

var Composes =
{

  dirPath : null,
  basePath : null,
  branchPath : null,

  onRecord : null,

  strict : 1,
  // sync : 1,

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

var Medials =
{
  // dir : null, /* xxx : move it here */
}

var Restricts =
{
  formed : 0,
}

var Statics =
{
  TollerantMake : TollerantMake,
}

var Accessors =
{

  resolvingSoftLink : 'resolvingSoftLink',
  usingSoftLink : 'usingSoftLink',

  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',

  originPath : 'originPath',
  stating : 'stating',
  safe : 'safe',

}

var Forbids =
{
  dir : 'dir',

  sync : 'sync',
  relative : 'relative',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',

  maskAll : 'maskAll',
  maskTerminal : 'maskTerminal',
  maskDirectory : 'maskDirectory',

  notOlder : 'notOlder',
  notNewer : 'notNewer',
  notOlderAge : 'notOlderAge',
  notNewerAge : 'notNewerAge',

}

// --
// declare
// --

var Proto =
{

  init : init,
  TollerantMake : TollerantMake,

  form : form,

  _usingSoftLinkGet : _usingSoftLinkGet,
  _resolvingSoftLinkSet : _resolvingSoftLinkSet,
  _resolvingSoftLinkGet : _resolvingSoftLinkGet,

  _usingTextLinkGet : _usingTextLinkGet,
  _resolvingTextLinkGet : _resolvingTextLinkGet,

  _originPathGet : _originPathGet,
  _statingGet : _statingGet,
  _safeGet : _safeGet,

  /**/

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
{

  require( './FileRecord.s' );

}

//

_[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
