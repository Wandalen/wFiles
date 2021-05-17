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

function finit()
{
  let operation = this;
  operation.unform();
  return _.Copyable.prototype.finit.call( this );
}

//

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

function unform()
{
  let operation = this;

  if( !operation.mission )
  return;

  let mission = operation.mission;
  let operator = mission.operator;

  _.assert( mission instanceof _.files.Mission );
  _.assert( operator instanceof _.files.Operator );

  _.arrayRemoveOnceStrictly( operator.operationsArray, operation );
  _.arrayRemoveOnceStrictly( mission.operationsArray, operation );

}

//

function form()
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  _.assert( mission instanceof _.files.Mission );
  _.assert( operator instanceof _.files.Operator );

  _.arrayAppendOnceStrictly( operator.operationsArray, operation );
  _.arrayAppendOnceStrictly( mission.operationsArray, operation );

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

  finit,
  init,
  unform,
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
