( function _SystemDefaultExtract_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  require( './aFileProviderSystemDefault.test.s' );
}

//

const _ = _global_.wTools;
const Parent = wTests[ 'Tools.files.fileProvider.system.default.Abstract' ];

_.assert( !!Parent );

// //
//
// var filesTree = /* xxx : remove? */
// {
// }

//

function onSuiteBegin()
{
  let context = this;

  context.provider = _.FileProvider.System({ empty : 1 });
  context.providerEffective = _.FileProvider.Extract
  ({
    protocols : [ 'current', 'second' ],
    usingExtraStat : 1
  });
  context.provider.providerRegister( context.providerEffective );

  context.provider.defaultProvider = context.providerEffective;
  context.globalFromPreferred =
  _.routineJoin( context.providerEffective.path, context.providerEffective.path.globalFromPreferred );
  context.provider.UsingBigIntForStat = context.providerEffective.UsingBigIntForStat;

  let path = context.providerEffective .path;
  context.suiteTempPath = path.tempOpen( path.join( __dirname, '../..'  ), 'System/Extract' );

}

//

function onSuiteEnd()
{
  let context = this;
  context.providerEffective.finit();
  context.provider.finit();

  let path = context.providerEffective.path;
  _.assert( _.strHas( context.suiteTempPath, '.tmp' ), context.suiteTempPath );
  path.tempClose( context.suiteTempPath );

}

//

function onRoutineEnd( test )
{
  let context = this;
  let provider = context.provider;
  _.sure( _.arraySetIdentical( _.props.keys( provider.providersWithProtocolMap ), [ 'second', 'current' ] ), test.name, 'has not restored system!' );
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
  // system.UsingBigIntForStat = provider.UsingBigIntForStat;
  _.assert( system.UsingBigIntForStat === provider.UsingBigIntForStat );

  return system;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.system.default.Extract',
  abstract : 0,
  silencing : 1,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    providerMake,
    // filesTree,
    provider : null,
    providerEffective : null,
    globalFromPreferred : null
  },

  tests :
  {
  },

}

//

const Self = wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
