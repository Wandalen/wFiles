( function _Namespace_s_()
{

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _.files = _.files || Object.create( null );

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
