( function _SystemDefaultHardDrive_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProviderSystemDefault.test.s' );

}

//

const _ = _global_.wTools;
let Parent = wTests[ 'Tools.mid.files.fileProvider.system.default.Abstract' ];

_.assert( !!Parent );

// --
// context
// --

function onSuiteBegin()
{
  var context = this;

  context.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..'  ), 'System/HardDrive' );

  context.providerEffective = _.FileProvider.HardDrive();

  context.provider = _.FileProvider.System({ empty : 1 });
  context.provider.providerRegister( context.providerEffective );
  context.provider.defaultProvider = context.providerEffective;
  context.globalFromPreferred =
  _.routineJoin( context.providerEffective.path, context.providerEffective.path.globalFromPreferred );
  context.provider.UsingBigIntForStat = context.providerEffective.UsingBigIntForStat;

}

//

function onSuiteEnd()
{
  let context = this;
  context.providerEffective.finit();
  context.provider.finit();
  _.assert( _.strHas( this.suiteTempPath, '.tmp' ), this.suiteTempPath );
  // this.providerEffective.filesDelete({ filePath : this.suiteTempPath });
  _.path.tempClose( this.suiteTempPath );
}

//

function onRoutineEnd( test )
{
  let context = this;
  let system = context.system || context.provider;
  _.sure( system instanceof _.FileProvider.System );
  _.sure( _.entityIdentical( _.mapKeys( system.providersWithProtocolMap ), [ 'file', 'hd' ] ), test.name, 'has not restored system!' );
}

//

function pathFor( filePath )
{
  var context = this;

  filePath =  _.path.join( context.suiteTempPath,  filePath );

  return context.providerEffective.originPath + _.path.normalize( filePath );
}

//

function providerMake()
{
  let context = this;

  let system = _.FileProvider.System({ empty : 1 });

  let provider = _.FileProvider.HardDrive
  ({
    protocols : [ 'file', 'hd' ],
    // protocols : [ 'current', 'second' ],
  });

  system.providerRegister( provider );

  system.defaultProvider = provider;

  return system;
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.system.default.HardDrive',
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
