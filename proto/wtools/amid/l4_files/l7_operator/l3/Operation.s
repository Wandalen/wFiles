( function _Operation_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wOperatorOperation;
function wOperatorOperation( o )
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

  _.assert( mission instanceof _.files.operator.Mission );
  _.assert( operator instanceof _.files.operator.Operator );

  _.arrayRemoveOnceStrictly( operator.operationArray, operation );
  _.arrayRemoveOnceStrictly( mission.operationArray, operation );

}

//

function form()
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  _.assert( mission instanceof _.files.operator.Mission );
  _.assert( operator instanceof _.files.operator.Operator );

  _.arrayAppendOnceStrictly( operator.operationArray, operation );
  _.arrayAppendOnceStrictly( mission.operationArray, operation );

  if( operation.action === 'filesReflect' )
  {
    operation._boot = operation.reflectBoot;
    operation._redo = operation.reflectRedo;
  }

}

//

function deedMake( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  return new _.files.operator.Deed
  ({
    src : o.src,
    dst : o.dst,
  })
}

deedMake.defaults =
{
  dst : null,
  src : null,
}

//

function redo( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  if( operation.status === 'unbooted' )
  operation._boot( o );
  else
  operation._redo( o );

  return o;
}

redo.defaults =
{
}

//

function reflectBoot( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  let opts = _.props.extend( null, operation.options );
  opts.dst = operation.dst;
  opts.src = operation.src;
  opts.src = _.entity.make( opts.src );
  opts.dst = _.entity.make( opts.dst );

  opts.onUp = opts.onUp ? _.array.as( opts.onUp ) : [];
  opts.onUp.push( handleUp );
  opts.onDown = opts.onDown ? _.array.as( opts.onDown ) : [];
  opts.onDown.push( handleDown );

  operator.filesSystem.filesReflect( opts );
  operation.status = 'uptodate';

  return o;

  function handleUp( record, op )
  {
    let mtr = _.path.moveTextualReport( record.dst.absolute, record.src.absolute );
    logger.log( ` + handleUp ${mtr}` );
    debugger;

    let dst = operator.fileFor( record.dst.absoluteGlobal, record.dst.absolute );
    let src = operator.fileFor( record.src.absoluteGlobal, record.src.absolute );
    debugger;
    record.deed = operation.deedMake({ dst, src });
  }

  function handleDown( record, op )
  {
    let mtr = _.path.moveTextualReport( record.dst.absolute, record.src.absolute );
    logger.log( ` + handleDown ${mtr} ${record.action}` );
    debugger;

    _.assert( !!record.deed );
  }

}

//

function reflectRedo( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  let opts = _.props.extend( null, operation.options );
  opts.dst = operation.dst;
  opts.src = operation.src;
  opts.src = _.entity.make( opts.src );
  opts.dst = _.entity.make( opts.dst );

  operator.filesSystem.filesReflect( opts );

  return o;
}

// --
// relations
// --

let Composes =
{
  action : null,
  options : null,
  dst : null,
  src : null,
  direction : 'both',
  status : 'unbooted',
  canceler : null,
}

let Aggregates =
{
  deedsArray : _.define.own( [] ),
}

let Associates =
{
  mission : null,
}

let Restricts =
{
  _boot : null,
  _redo : null,
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
  deedMake,

  redo,
  reflectBoot,
  reflectRedo,

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
