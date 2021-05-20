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

  _.assert( operation.deedArray.length === 0 );

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
  let mission = operation.mission;
  let operator = operation.operator;

  if( !operation.id )
  return;

  _.assert( mission instanceof _.files.operator.Mission );
  _.assert( operator instanceof _.files.operator.Operator );

  _.container.each( operation.deedArray.slice(), ( deed ) => deed.finit() );
  _.assert( operation.deedArray.length === 0 );

  _.arrayRemoveOnceStrictly( operator.operationArray, operation );
  _.arrayRemoveOnceStrictly( mission.operationArray, operation );

  operation.id = -1;
  return operation;
}

//

function form()
{
  let operation = this;
  let mission = operation.mission;
  let operator = operation.operator;

  if( operation.operator === null )
  operator = operation.operator = mission.operator;
  if( mission && mission.operator === null )
  mission.operator = operator.operator;

  _.assert( operation.id === null );
  _.assert( mission === null || mission instanceof _.files.operator.Mission );
  _.assert( mission === null || mission.operator === operator );
  _.assert( operator instanceof _.files.operator.Operator );

  operation.id = operator.idAllocate();

  if( mission )
  _.arrayAppendOnceStrictly( mission.operationArray, operation );
  _.arrayAppendOnceStrictly( operator.operationArray, operation );

  if( operation.action === 'filesReflect' )
  {
    operation._boot = operation.reflectBoot;
    operation._redo = operation.reflectRedo;
  }
  else if( operation.action === 'third' )
  {
    operation._boot = operation.thirdBoot;
    operation._redo = operation.thirdRedo;
  }
  else _.assert( 0, `Unknown action ${operation.action} of operation` );

  return operation;
}

//

function form2()
{
  let operation = this;
  let files = new HashMap;

  // xxx
  // operation.deedArray.forEach( ( deed ) =>
  // {
  //   _.set.each( deed.src, ( file ) => files.set( file.globalPath, file ) );
  //   _.set.each( deed.dst, ( file ) => files.set( file.globalPath, file ) );
  // });
  //
  // _.map.each( files, ( file ) =>
  // {
  //   file.reform2();
  // });

}

//

function deedMake( o )
{
  let operation = this;
  return new _.files.operator.Deed
  ({
    operation,
    ... o,
  })
}


//

function redo( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = operation.operator;

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
  let ignoredAction = new Set([ 'nop', 'fileDelete', 'exclude', 'ignore' ]);
  o.ready = o.ready || _.take( null );

  let opts = _.props.extend( null, operation.options );
  opts.dst = operation.dst;
  opts.src = operation.src;
  opts.src = _.entity.make( opts.src );
  opts.dst = _.entity.make( opts.dst );

  opts.onUp = opts.onUp ? _.array.as( opts.onUp ) : [];
  opts.onUp.push( handleUp );
  opts.onDown = opts.onDown ? _.array.as( opts.onDown ) : [];
  opts.onDown.push( handleDown );

  o.ready.then( () => operator.filesSystem.filesReflect( opts ) );
  o.ready.then( handleEnd );

  return o.ready;

  /* */

  function handleUp( record, op )
  {
    let mtr = _.path.moveTextualReport( record.dst.absolute, record.src.absolute );
    // logger.log( ` + handleUp ${mtr}` );

    let dst = operator.fileFor( record.dst.absoluteGlobal, record.dst.absolute );
    let src = operator.fileFor( record.src.absoluteGlobal, record.src.absolute );
    record.deed = operation.deedMake();
    let srcUsage = record.deed.use( src );
    srcUsage.facetSet = 'reading';
    record.deed.use( dst );

    if( record.dst.stat )
    if( dst.firstEffectiveDeed === null )
    {
      record.thirdDeed = mission.thirdOperation.deedMake
      ({
        facetSet : [ 'third' ],
        action : 'third',
        status : 'uptodate',
      });
      var dstUsage = record.thirdDeed.use( dst );
      dstUsage.facetSet = 'reading';
    }

  }

  /* */

  function handleDown( record, op )
  {
    let mtr = _.path.moveTextualReport( record.dst.absolute, record.src.absolute );
    logger.log( ` + handleDown ${mtr} ${record.action}` );

    _.assert( !!record.deed );

    let deed = record.deed;
    deed.action = record.action;
    deed.status = 'uptodate';
    if( ignoredAction.has( record.action ) )
    {
      _.assert( 0, 'not tested' );
      if( record.thirdDeed )
      record.thirdDeed.finit();
      deed.finit();
      return;
    }

    // deed.srcAttributes = [ 'reading' ];
    deed.facetSet = [ 'producing' ];
    // deed.attributesUpdateDone();

    // let dst = [ ... deed.dst ][ 0 ];
    // let src = [ ... deed.src ][ 0 ];

    // dst.producerArray.push( deed );

    // if( record.dst.stat )
    // {
    //   debugger;
    // }
    // else
    // {
    //   dst.producerArray.push( deed );
    //   debugger;
    // }

    // if( deed.action === 'dirMake' )
    // debugger;
  }

  /* */

  function handleEnd()
  {
    operation.status = 'uptodate';
    operation.form2();
    return o;
  }

  /* */

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

//

function thirdBoot( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

  return o;
}

//

function thirdRedo( o )
{
  let operation = this;
  let mission = operation.mission;
  let operator = mission.operator;

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
  deedArray : _.define.own( [] ),
}

let Associates =
{
  id : null,
  mission : null,
  operator : null,
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
  form2,
  deedMake,

  redo,
  reflectBoot,
  reflectRedo,
  thirdBoot,
  thirdRedo,

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
