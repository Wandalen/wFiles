( function _Namespace_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Self = _.files = _.files || Object.create( null );

// --
// implementation
// --

// --
// meta
// --

function _Setup()
{

  // debugger;
  // if( !_.fileProvider )
  // _.FileProvider.Default.MakeDefault();

  _.path.currentAtBegin = _.path.current();

}

// --
// declaration
// --

let Extension =
{

  // meta

  _Setup,

}

_.mapSupplement( Self, Extension );

_.files._Setup();

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
