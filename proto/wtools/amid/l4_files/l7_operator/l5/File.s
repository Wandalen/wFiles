( function _File_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = _.files.operator.AbstractResource;
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

  _.assert( file.deedArray.length === 0 );

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
  let operator = file.operator;

  if( !file.id )
  return;

  _.assert( operator.filesMap[ file.globalPath ] === file );
  delete operator.filesMap[ file.globalPath ];

  file.id = -1;
  return file;
}

//

function form()
{
  let file = this;
  let operator = file.operator;

  _.assert( operator instanceof _.files.operator.Operator );
  _.assert( _.strDefined( file.globalPath ) );
  _.assert( operator.filesMap[ file.globalPath ] === undefined || operator.filesMap[ file.globalPath ] === file );
  _.assert( file.id === null );

  file.id = operator.idAllocate();

  operator.filesMap[ file.globalPath ] = file;
  return file;
}

//

function reform2()
{
  let file = this;
  let operator = file.operator;

  // if( file.deedArray.length >= 2 )
  // debugger;

  file.firstEffectiveDeed = null;
  _.array.whileRight( file.deedArray, ( deed ) =>
  {
    if( deed.facetSet.size > 0 )
    if( !deed.facetSet.has( 'reading' ) && !deed.facetSet.has( 'editing' ) )
    {
      file.firstEffectiveDeed = deed;
      return false;
    }
    return true;
  });

  if( file.firstEffectiveDeed )
  debugger;

  file.firstReadingDeed = null;
  _.array.whileLeft( file.deedArray, ( deed ) =>
  {
    if( deed.facetSet.has( 'reading' ) )
    {
      file.firstReadingDeed = deed;
      return false;
    }
    return true;
  });

  // if( file.firstReadingDeed )
  // debugger;

  // if( isDst )
  // if( file.firstEffectiveDeed === null )
  // if( !deed.facetSet.has( 'editing' ) && deed.facetSet.size > 0 )
  // {
  //   file.firstEffectiveDeed = deed;
  // }

}

// //
//
// function deedOff( usage )
// {
//   let file = this;
//   let operator = file.operator;
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.files.operator.usageIs( usage ) );
//   _.arrayRemoveElementOnceStrictly( file.deedArray, deed );
//
//   deed.filesSet.delete( usage );
//   // if( isDst )
//   // deed.dst.delete( usage );
//   // else
//   // deed.src.delete( usage );
//
//   if( file.deedArray.length === 0 )
//   file.finit();
//
// }
//
// //
//
// function deedOn( usage )
// {
//   let file = this;
//   let operator = file.operator;
//
//   _.assert( _.files.operator.usageIs( usage ) );
//   _.assert( arguments.length === 1 );
//   _.arrayAppendElementOnceStrictly( file.deedArray, usage );
//
//   // if( isDst )
//   // if( file.firstEffectiveDeed === null )
//   // if( !deed.facetSet.has( 'editing' ) && deed.facetSet.size > 0 )
//   // {
//   //   file.firstEffectiveDeed = deed;
//   // }
//
// }

// //
//
// function account( deed, attribute )
// {
//   let file = this;
//   let operator = file.operator;
//
//   debugger;
//   if( _.set.is( attribute ) && attribute.length === 1 )
//   attribute = _.set.first( attribute );
//
//   if( _.set.is( attribute )
//   {
//     _.assert( 0, 'not implemented' );
//   }
//   else
//   {
//
//   }
//
// }

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
  deedArray : _.define.own([]),
  firstEffectiveDeed : null,
  firstReadingDeed : null,
}

let Associates =
{
  id : null,
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
  reform2,

  // deedOff,
  // deedOn,

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

_.files.operator[ Self.shortName ] = Self;

})();
