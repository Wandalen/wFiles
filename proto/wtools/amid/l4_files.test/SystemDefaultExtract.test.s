( function _SystemDefaultExtract_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProviderSystemDefault.test.s' );

}

//

let _ = _global_.wTools;
let Parent = wTests[ 'Tools.mid.files.fileProvider.system.default.Abstract' ];

_.assert( !!Parent );

//

var filesTree = /* xxx : remove? */
{
}

//

function onSuiteBegin()
{
  var context = this;

  context.provider = _.FileProvider.System({ empty : 1 });

  context.providerEffective = _.FileProvider.Extract
  ({
    protocols : [ 'current', 'second' ],
    usingExtraStat : 1
  });
  context.provider.providerRegister( context.providerEffective );

  context.provider.defaultProvider = context.providerEffective;
  context.globalFromPreferred = _.routineJoin( context.providerEffective.path, context.providerEffective.path.globalFromPreferred );
  context.provider.UsingBigIntForStat = context.providerEffective.UsingBigIntForStat;

}

//

function onRoutineEnd( test )
{
  let context = this;
  let provider = context.provider;
  _.sure( _.arraySetIdentical( _.mapKeys( provider.providersWithProtocolMap ), [ 'second', 'current' ] ), test.name, 'has not restored system!' );
}

//

function onSuiteEnd()
{
  let context = this;
  context.providerEffective.finit();
  context.provider.finit();
}

//

function providerMake()
{
  let context = this;

  let system = _.FileProvider.System({ empty : 1 });

  let provider = _.FileProvider.Extract
  ({
    protocols : [ 'current', 'second' ],
    usingExtraStat : 1
  });

  system.providerRegister( provider );

  system.defaultProvider = provider;
  system.UsingBigIntForStat = provider.UsingBigIntForStat;

  return system;
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.system.default.Extract',
  abstract : 0,
  silencing : 1,
  enabled : 0,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    providerMake,

    filesTree,
    provider : null,
    providerEffective : null,
    globalFromPreferred : null
  },

  tests :
  {
  },

}

//

let Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
