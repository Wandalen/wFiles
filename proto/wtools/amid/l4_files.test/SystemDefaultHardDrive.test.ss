( function _SystemDefaultHardDrive_test_ss_()
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

// --
// context
// --

function onSuiteBegin()
{
  let context = this;

  context.providerEffective = _.FileProvider.HardDrive();

  context.provider = _.FileProvider.System({ empty : 1 });
  context.provider.providerRegister( context.providerEffective );
  context.provider.defaultProvider = context.providerEffective;
  context.globalFromPreferred =
  _.routineJoin( context.providerEffective.path, context.providerEffective.path.globalFromPreferred );
  context.provider.UsingBigIntForStat = context.providerEffective.UsingBigIntForStat;

  let path = context.providerEffective.path;
  context.suiteTempPath = path.tempOpen( path.join( __dirname, '../..'  ), 'System/HardDrive' );

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
  let system = context.system || context.provider;
  _.sure( system instanceof _.FileProvider.System );
  _.sure( _.entityIdentical( _.props.keys( system.providersWithProtocolMap ), [ 'hd', 'file' ] ), test.name, 'has not restored system!' );
}

//

function pathFor( filePath )
{
  let context = this;

  filePath = _.path.join( context.suiteTempPath, filePath );

  return filePath
  // return context.providerEffective.originPath + _.path.normalize( filePath );
}

//

function providerMake()
{
  let context = this;

  let system = _.FileProvider.System({ empty : 1 });

  let provider = _.FileProvider.HardDrive
  ({
    protocols : [ 'hd', 'file' ],
    // protocols : [ 'current', 'second' ],
  });

  system.providerRegister( provider );

  system.defaultProvider = provider;

  return system;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.system.default.HardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    pathFor,
    providerMake,
    provider : null,
    providerEffective : null,
    suiteTempPath : null,
    globalFromPreferred : null,
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
