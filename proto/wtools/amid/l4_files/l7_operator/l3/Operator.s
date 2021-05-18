( function _Operator_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wOperator;
function wOperator( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Operator';

// --
//
// --

function init( o )
{
  let operator = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( operator );

  if( operator.Self === Self )
  Object.preventExtensions( operator );

  if( o )
  operator.copy( o );

  operator.form();

  return operator;
}

//

function form()
{
  let operator = this;

  if( !operator.filesSystem )
  {
    let filesSystem = _.FileProvider.System({ providers : [] });
    _.FileProvider.Git().providerRegisterTo( filesSystem );
    _.FileProvider.Npm().providerRegisterTo( filesSystem );
    _.FileProvider.Http().providerRegisterTo( filesSystem );
    let defaultProvider = _.FileProvider.Default();
    defaultProvider.providerRegisterTo( filesSystem );
    filesSystem.defaultProvider = defaultProvider;
    operator.filesSystem = filesSystem;
  }

  return operator;
}

//

function fileFor( globalPath, localPath )
{
  let operator = this;

  _.assert( _.strDefined( globalPath ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  let file = operator.filesMap[ globalPath ];
  if( !file )
  {
    file = operator.filesMap[ globalPath ] = _.files.operator.File
    ({
      globalPath : globalPath,
      localPath : localPath || null,
      operator : operator,
    });
  }

  return file;
}

// --
// relations
// --

let Composes =
{
  counter : 0,
}

let Aggregates =
{
}

let Associates =
{
  operationArray : _.define.own([]),
  filesMap : _.define.own({}),
}

let Restricts =
{
  filesSystem : null,
}

let Statics =
{
}

// --
// declare
// --

let Extension =
{

  init,
  form,
  fileFor,

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
_.files.operator[ Self.shortName ] = Self;

})();
