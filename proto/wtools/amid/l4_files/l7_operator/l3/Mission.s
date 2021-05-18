( function _Mission_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wOperatorMission;
function wOperatorMission( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Mission';

// --
//
// --

function finit()
{
  let mission = this;
  mission.unform();

  _.assert( mission.operationArray.length === 0 );

  return _.Copyable.prototype.finit.call( mission );
}

//

function init( o )
{
  let mission = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( mission );

  if( mission.Self === Self )
  Object.preventExtensions( mission );

  if( o )
  mission.copy( o );

  mission.form();

  return mission;
}

//

function unform()
{
  let mission = this;

  if( !mission.operator )
  return;

  mission.operationArray.slice().forEach( ( operation ) => operation.finit() );
  _.assert( mission.operationArray.length === 0 );

  _.assert( mission.operator.missionSet.has( mission ) );
  mission.operator.missionSet.delete( mission );

  return mission;
}

//

function form()
{
  let mission = this;

  if( !mission.operator )
  mission.operator = new _.files.operator.Operator();
  mission.operator.missionSet.add( mission );

  return mission;
}

//

function filesReflect( o )
{
  let mission = this;
  let operator = mission.operator;
  let filesSystem = operator.filesSystem;

  o = filesSystem.filesReflect.head.call( filesSystem, filesSystem.filesReflect, arguments );

  let src = o.src;
  let dst = o.dst;

  _.assert( src instanceof _.files.FileRecordFilter );
  _.assert( dst instanceof _.files.FileRecordFilter );

  delete o.src;
  delete o.dst;

  let operation = _.files.operator.Operation
  ({
    mission,
    options : o,
    action : 'filesReflect',
    src,
    dst,
  });

  return operation;
}

filesReflect.defaults =
{
  ... _.FileProvider.FindMixin.prototype.filesReflect.defaults,
}

//

function redo( o )
{
  let mission = this;
  let ready = _.take( null );
  o = _.routine.options( redo, arguments );

  mission.operationArray.forEach( ( operation ) =>
  {
    ready.then( () => operation.redo( o ) );
  });

  return ready;
}

redo.defaults =
{
}

// --
// relations
// --

let Composes =
{
  missionName : null,
}

let Aggregates =
{
  operationArray : _.define.own([]),
}

let Associates =
{
  operator : null,
}

let Restricts =
{
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

  filesReflect,

  redo,

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
