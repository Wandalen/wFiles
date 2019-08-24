( function _FileProvider_System_HardDrive_test_ss_( ) {

'use strict';  

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools/mid/files/fileProvider/Abstract' ];

_.assert( !!Parent );

//

function pathFor( filePath )
{
  var self = this;

  filePath =  _.path.join( self.testSuitePath,  filePath );

  return self.providerEffective.originPath + _.path.normalize( filePath );
}

//

function onSuiteBegin()
{
  var self = this;

  self.testSuitePath = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'System/HardDrive' );

  self.provider.providerRegister( self.providerEffective );
  self.provider.defaultProvider = self.providerEffective;
  self.globalFromPreferred = _.routineJoin( self.providerEffective.path, self.providerEffective.path.globalFromPreferred );
  self.provider.UsingBigIntForStat = self.providerEffective.UsingBigIntForStat;
  // self.provider.defaultOrigin = self.providerEffective.originPath;
  // self.provider.defaultProtocol = self.providerEffective.protocol;

}

function onSuiteEnd()
{ 
  _.assert( _.strHas( this.testSuitePath, 'System/HardDrive' ) );
  // this.providerEffective.filesDelete({ filePath : this.testSuitePath });
  _.path.dirTempClose( this.testSuitePath );
}

function onRoutineEnd( test )
{
  let context = this;
  let system = context.system || context.provider;
  _.sure( system instanceof _.FileProvider.System );
  _.sure( _.entityIdentical( _.mapKeys( system.providersWithProtocolMap ), [ 'file', 'hd' ] ), test.name, 'has not restored system!' );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/System/withHardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    provider : _.FileProvider.System({ empty : 1 }),
    providerEffective : _.FileProvider.HardDrive(),
    testSuitePath : null,

    pathFor : pathFor,
    globalFromPreferred : null
    // testFile : null,
    // testSuitePath : __dirname + '/../../../../tmp.tmp/hard-drive',
    // testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

  tests :
  {
  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
