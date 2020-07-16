( function _Carrier_s_() {

'use strict'; 

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wStatsCarrier( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'StatCarrier';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.workpiece.initFields( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  return self;
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
// declare
// --

var Extension =
{

  init,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.Copyable.mixin( Self );

//

_.[ Self.shortName ] = Self;

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
