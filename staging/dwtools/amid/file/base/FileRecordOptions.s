( function _FileRecordOptions_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' )

}

if( wTools.FileRecordOptions )
return;

wTools.assert( !wTools.FileRecordOptions );

//

var _ = wTools;
var Parent = null;
var Self = function wFileRecordOptions( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
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

Self.nameShort = 'FileRecordOptions';

//

function init( o )
{
  var self = this;

  Object.assign( self,self.copyableFields );
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
    Object.assign( self,_.mapScreen( Self.prototype.copyableFields,src ) );

  }

  /* */

  if( self.fileProvider && self.originPath )
  {
    _.assert( self.fileProvider.originPath,'file provider does not have originPath',_.strQuote( self.fileProvider.nickName ) );
    _.assert( self.originPath === null || self.originPath === self.fileProvider.originPath,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( self.fileProvider.originPath ) );
    self.originPath = self.fileProvider.originPath;
  }

  if( self.fileProvider && self.resolvingSoftLink === null )
  self.resolvingSoftLink = self.fileProvider.resolvingSoftLink;
  else
  self.resolvingSoftLink = !!self.resolvingSoftLink;

  if( self.fileProvider && self.resolvingTextLink === null )
  self.resolvingTextLink = self.fileProvider.resolvingTextLink;
  else
  self.resolvingTextLink = !!self.resolvingTextLink;

  /* */

  if( self.dir )
  {
    if( self.dir instanceof Self )
    self.dir = self.dir.absolute;
    if( _.strHas( self.dir,'//' ) )
    {
      var url = _.urlParse( self.dir );
      _.assert( self.originPath === null || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
      url.localPath = _.pathNormalize( url.localPath );
      self.originPath = url.origin;
      self.dir = _.urlStr( url );
    }
    else
    {
      self.dir = _.pathNormalize( self.dir );
    }
  }

  if( self.relative )
  {
    if( self.relative instanceof Self )
    self.relative = self.relative.absolute;
    if( _.strHas( self.relative,'//' ) )
    {
      var url = _.urlParse( self.relative );
      _.assert( self.originPath === null || self.originPath === url.origin,'attempt to change origin from',_.strQuote( self.originPath ),'to',_.strQuote( url.origin ) );
      url.localPath = _.pathNormalize( url.localPath );
      self.originPath = url.origin;
      self.relative = _.urlStr( url );
    }
    else
    {
      self.relative = _.pathNormalize( self.relative );
    }
  }

  if( !self.relative )
  if( self.dir )
  {
    self.relative = self.dir;
  }

  if( !self.dir )
  if( self.relative )
  {
    self.dir = self.relative;
  }

  if( self.dir )
  _.assert( _.urlIsGlobal( self.dir ) || _.pathIsAbsolute( self.dir ),'( o.dir ) should be absolute path',self.dir );

  if( self.relative )
  _.assert( _.urlIsGlobal( self.relative ) || _.pathIsAbsolute( self.relative ),'o.relative should be absolute path',self.relative );

  _.assert( self.maskAll === null || _.regexpObjectIs( self.maskAll ) );
  _.assert( self.maskTerminal === null || _.regexpObjectIs( self.maskTerminal ) );
  _.assert( self.maskDir === null || _.regexpObjectIs( self.maskDir ) );

  Object.freeze( self );
  // _.instanceFinit( self );

}

//

function tollerantMake( o )
{
  _.assert( arguments.length >= 1 );

  if( arguments.length === 1 )
  {
    return new Self( _.mapScreen( Self.prototype.copyableFields,o ) );
  }
  else
  {
    var result = _.arraySlice( arguments );
    for( var r = 0 ; r < result.length ; r++ )
    {
      result[ r ] = _.mapScreen( Self.prototype.copyableFields,result[ r ] );
    }
    return new( _.routineJoin( Self, Self, result ) );
  }

}

// --
//
// --

var Composes =
{

  dir : null,
  relative : null,
  originPath : null,

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

  onRecord : null,

  safe : 1,
  strict : 1,
  verbosity : 0,

  resolvingSoftLink : null,
  resolvingTextLink : null,

}

var Aggregates =
{
}

var Associates =
{
  fileProvider : null,
}

var Restricts =
{
}

var Statics =
{
  tollerantMake : tollerantMake,
  copyableFields : Object.create( null ),
}

var Forbids =
{
  // dir : 'dir',
  // relative : 'relative',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
}

// --
// prototype
// --

var Proto =
{

  init : init,
  tollerantMake : tollerantMake,

  /**/

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

if( Proto.Composes )
_.mapExtend( Statics.copyableFields,Proto.Composes );
if( Proto.Aggregates )
_.mapExtend( Statics.copyableFields,Proto.Aggregates );
if( Proto.Associates )
_.mapExtend( Statics.copyableFields,Proto.Associates );

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.accessorForbid( Self.prototype,Forbids );

// wCopyable.mixin( Self );

//

if( typeof module !== 'undefined' )
{

  require( './FileRecord.s' );

}

//

wTools[ Self.nameShort ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
