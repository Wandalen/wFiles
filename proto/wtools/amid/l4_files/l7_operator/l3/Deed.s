( function _Deed_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wOperatorDeed;
function wOperatorDeed( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Deed';

// --
//
// --

function finit()
{
  let deed = this;
  deed.unform();
  return _.Copyable.prototype.finit.call( deed );
}

//

function init( o )
{
  let deed = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( deed );

  if( deed.Self === Self )
  Object.preventExtensions( deed );

  deed.src = _.set.as( deed.src );
  deed.dst = _.set.as( deed.dst );

  if( o )
  deed.copy( o );

  return deed;
}

//

function unform()
{
  let deed = this;

  if( !deed.operation )
  return;

  if( !deed.formed )
  return

  _.arrayRemoveOnceStrictly( operation.deedsArray, deed );

}

//

function form()
{
  let deed = this;
  let operation = deed.operation;
  let mission = operation.mission;
  let operator = mission.operator;

  _.assert( operation instanceof _.files.operator.Operation );
  _.assert( mission instanceof _.files.operator.Mission );
  _.assert( operator instanceof _.files.operator.Operator );

  _.arrayAppendOnceStrictly( operation.deedsArray, deed );

  deed.formed = 1;
}

// --
// relations
// --

let Composes =
{
  dst : _.define.own( new Set ),
  src : _.define.own( new Set ),
  status : null,
}

let Aggregates =
{
}

let Associates =
{
  mission : null,
}

let Restricts =
{
  formed : 0,
}

let Statics =
{
}

// --
// declare
// --

let Extension =
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
_.files.operator[ Self.shortName ] = Self;

})();
