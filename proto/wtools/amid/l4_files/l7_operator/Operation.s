( function _Operation_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wFilesOperation;
function wFilesOperation( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Operation';

// --
//
// --

function init( o )
{
  let operation = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( operation );

  if( operation.Self === Self )
  Object.preventExtensions( operation );

  if( o )
  operation.copy( o );

  operation.form();

  return operation;
}

//

function form()
{
  let operation = this;

  _.assert( operation.mission instanceof _.files.Mission );

  

}

// --
// relations
// --

var Composes =
{
  type : null,
  options : null,
  src : null,
  dst : null,
  canceler : null,
}

var Aggregates =
{
}

var Associates =
{
  mission : null,
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
  form,

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
_.files[ Self.shortName ] = Self;

})();
