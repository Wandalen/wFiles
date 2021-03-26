( function _Carrier_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
let Parent = null;
const Self = wStatsCarrier;
function wStatsCarrier( o )
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

// _.[ Self.shortName ] = Self;
_[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
