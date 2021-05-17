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
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  self.form();

  return self;
}

//

function form()
{
  let self = this;

  if( !self.filesSystem )
  {
    let filesSystem = _.FileProvider.System({ providers : [] });

    _.FileProvider.Git().providerRegisterTo( filesSystem );
    _.FileProvider.Npm().providerRegisterTo( filesSystem );
    _.FileProvider.Http().providerRegisterTo( filesSystem );
    let defaultProvider = _.FileProvider.Default();
    defaultProvider.providerRegisterTo( filesSystem );
    filesSystem.defaultProvider = defaultProvider;
    self.filesSystem = filesSystem;
  }

  return self;
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
  operationsArray : null,
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
