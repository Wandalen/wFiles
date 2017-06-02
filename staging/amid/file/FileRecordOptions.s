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

  // _.assert( o === undefined || _.objectIs( o ) );

  Object.assign( self,self.copyableFields );
  Object.preventExtensions( self );

  /* */

  // logger.log( 'arguments.length',arguments.length );
  // logger.log( 'arguments[ 0 ].dst',arguments[ 0 ].dst );
  // logger.log( 'arguments[ 0 ].relative',arguments[ 0 ].relative );
  // logger.log( arguments[ 0 ] );

  // if( arguments[ 0 ].dst === '/pro/web/Dave/app/server/include' )
  // debugger;
  //
  // if( arguments[ 0 ].relative === '/pro/web/Dave/app/proto' )
  // debugger;
  //
  // if( arguments[ 0 ].relative === '/pro/web/Dave/app/server/include' )
  // debugger;
  // if( arguments[ 0 ].relative === '/pro/web/Dave/app/server/include/abase/z.test' )
  // debugger;
  // debugger;

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var src = arguments[ a ];
    // if( src.constructor )
    // _.assert( src.constructor === {}.constructor );

    if( !_.mapIs( src ) )
    debugger;

    if( _.mapIs( src ) )
    Object.assign( self,src );
    else
    Object.assign( self,_.mapScreen( Self.prototype.copyableFields,src ) );
    // _.mapExtendFiltering( _.filter.srcOwn(),self,src );

  }

  // debugger;

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
  //   _.assert( _.pathIsAbsolute( self.filePath ),'( FileRecordOptions ) expects ( dir ) or ( relative ) option or absolute path' );
  //   self.relative = _.pathDir( self.filePath );
  // }

  if( self.dir )
  _.assert( _.pathIsAbsolute( self.dir ),'( o.dir ) should be absolute path',self.dir );

  if( self.relative )
  _.assert( _.pathIsAbsolute( self.relative ),'o.relative should be absolute path',self.relative );

  _.assert( self.maskAll === null || _.regexpObjectIs( self.maskAll ) );
  _.assert( self.maskTerminal === null || _.regexpObjectIs( self.maskTerminal ) );
  _.assert( self.maskDir === null || _.regexpObjectIs( self.maskDir ) );

  _.instanceFinit( self );

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
  cls : Self,
  parent : Parent,
  extend : Proto,
});

// wCopyable.mixin( Self );

//

if( typeof module !== 'undefined' )
{

  require( './FileRecord.s' );

}

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

wTools[ Self.nameShort ] = Self;
return Self;

})();
