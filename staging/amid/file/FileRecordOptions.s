( function _FileRecordOptions_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' )

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
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileRecordOptions';

//

function init( o )
{
  var self = this;

  // _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( o === undefined || _.objectIs( o ) /*|| _.strIs( o )*/ );

  // _.mapExtend( self,self.Composes );
  // _.mapExtend( self,self.Associates );

  Object.assign( self,self.copyableFields );
  Object.preventExtensions( self );

  // if( _.strIs( o ) )
  // {
  //
  //   self.pathFile = arguments[ 0 ];
  //
  // }
  // else
  // if( _.objectIs( o ) )
  // {
  //
  //   debugger;
  //   _.mapExtend( self,o );
  //   _.assertMapHasOnly( o,self.Composes,self.Associates );
  //
  // }

  for( var a = 0 ; a < arguments.length ; a++ )
  Object.assign( self,arguments[ a ] );

  /* */

  if( self.dir )
  {
    if( self.dir instanceof Self )
    self.dir = self.dir.absolute;
    self.dir = _.pathRegularize( self.dir );
  }

  if( self.relative )
  {
    if( self.relative instanceof Self )
    self.relative = self.relative.absolute;
    self.relative = _.pathRegularize( self.relative );
  }

  if( !self.relative )
  if( self.dir )
  {
    self.relative = self.dir;
  }
  // else
  // {
  //   _.assert( _.pathIsAbsolute( self.pathFile ),'( FileRecordOptions ) expects ( dir ) or ( relative ) option or absolute path' );
  //   self.relative = _.pathDir( self.pathFile );
  // }

  if( self.dir )
  _.assert( _.pathIsAbsolute( self.dir ),'( o.dir ) should be absolute path',self.dir );

  if( self.relative )
  _.assert( _.pathIsAbsolute( self.relative ),'o.relative should be absolute path',self.relative );

  _.assert( self.maskAll === null || _.regexpObjectIs( self.maskAll ) );
  _.assert( self.maskTerminal === null || _.regexpObjectIs( self.maskTerminal ) );
  _.assert( self.maskDir === null || _.regexpObjectIs( self.maskDir ) );

  Object.freeze( self );

}

//

function tollerantMake( o )
{
  _.assert( arguments.length >= 1 );
  if( arguments.length === 1 )
  {
    return new Self( _.mapScreen( Self.copyableFields,o ) );
  }
  else
  {
    var result = _.arraySlice( arguments );
    result[ 0 ] = _.mapScreen( Self.copyableFields,o );
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

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  notOlder : null,
  notNewer : null,

  onRecord : null,

  safe : 1,
  strict : 1,
  verbosity : 0,

  resolvingSoftLink : 0,
  resolvingTextLink : 0,

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

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

//

if( typeof module !== 'undefined' )
{

  require( './FileRecord.s' );

}

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

// _global_[ Self.name ] = wTools[ Self.nameShort ] = Self;
wTools[ Self.nameShort ] = Self;
return Self;

})();
