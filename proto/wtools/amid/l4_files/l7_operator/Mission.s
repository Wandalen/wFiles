( function _Mission_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wFilesMission;
function wFilesMission( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Mission';

// --
//
// --

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

function form()
{
  let mission = this;

  if( !mission.operator )
  mission.operator = new _.files.Operator();

  if( !mission.operationArray )
  mission.operationArray = [];

  return mission;
}

//

function filesReflect( o )
{
  let mission = this;
  let operator = mission.operator;
  let filesSystem = operator.filesSystem;

  o = filesSystem.filesReflect.head.call( filesSystem, filesSystem.filesReflect, arguments ); debugger;

  let src = o.src;
  let dst = o.dst;

  _.assert( src instanceof _.files.FileRecordFilter );
  _.assert( dst instanceof _.files.FileRecordFilter );

  delete o.src;
  delete o.dst;

  let operation = _.files.Operation
  ({
    mission,
    options : o,
    type : 'filesReflect',
    src : o.src,
    dst : o.dst,
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
  let ready = _.take( null );
  o = _.routine.options( arguments );

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

var Composes =
{
  missionName : null,
}

var Aggregates =
{
  operationArray : null,
}

var Associates =
{
  operator : null,
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
_.files[ Self.shortName ] = Self;

})();
