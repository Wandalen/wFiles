( function _Abstract_s_() {

'use strict';

var _ = wTools;

_.assert( !_.FileProvider.wFileProviderPartial );

var Parent = null;
var Self = function wFileProviderAbstract( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Abstract';

//

function init( o )
{
}

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
}

var Restricts =
{
}

var Statics =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.prototypeMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
