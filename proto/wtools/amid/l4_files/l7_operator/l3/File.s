( function _File_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wOperatorFile;
function wOperatorFile( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'File';

// --
//
// --

function finit()
{
  let file = this;
  file.unform();
  return _.Copyable.prototype.finit.call( this );
}

//

function init( o )
{
  let file = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( file );

  if( file.Self === Self )
  Object.preventExtensions( file );

  if( o )
  file.copy( o );

  file.form();
  return file;
}

//

function unform()
{
  let file = this;

  if( !file.operation )
  return;

  _.assert( operator.filesMap[ file.globalPath ] === file );
  delete operator.filesMap[ file.globalPath ];

}

//

function form()
{
  let file = this;
  let operator = file.operator;

  _.assert( operator instanceof _.files.operator.Operator );
  _.assert( _.strDefined( file.globalPath ) );
  _.assert( operator.filesMap[ file.globalPath ] === undefined || operator.filesMap[ file.globalPath ] === file ); debugger;

  operator.filesMap[ file.globalPath ] = file;
}

// --
// relations
// --

let Composes =
{
  globalPath : null,
  localPath : null,
}

let Aggregates =
{
  deeds : _.define.own([]),
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
