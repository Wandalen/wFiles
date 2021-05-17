( function _Operator_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Parent = null;
const Self = wFilesOperator;
function wFilesOperator( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Operator';

// --
//
// --

function init( o )
{
  var operator = this;

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

  if( !operator.operationArray )
  operator.operationArray = [];

  return operator;
}

// --
// relations
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
  operationArray : null,
}

var Restricts =
{
  filesSystem : null,
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
