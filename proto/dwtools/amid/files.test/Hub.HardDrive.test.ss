( function _FileProvider_Hub_HardDrive_test_ss_( ) {

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

  self.testSuitePath = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'Hub/HardDrive' );

  self.provider.providerRegister( self.providerEffective );
  self.provider.defaultProvider = self.providerEffective;
  self.globalFromLocal = _.routineJoin( self.providerEffective.path, self.providerEffective.path.globalFromLocal );
  self.provider.UsingBigIntForStat = self.providerEffective.UsingBigIntForStat;
  // self.provider.defaultOrigin = self.providerEffective.originPath;
  // self.provider.defaultProtocol = self.providerEffective.protocol;

}

function onSuiteEnd()
{
  _.assert( _.strEnds( this.testSuitePath, 'Hub/HardDrive' ) );
  // this.providerEffective.filesDelete({ filePath : this.testSuitePath });
  _.path.dirTempClose( this.testSuitePath );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Hub/withHardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    provider : _.FileProvider.Hub({ empty : 1 }),
    providerEffective : _.FileProvider.HardDrive(),
    testSuitePath : null,

    pathFor : pathFor,
    globalFromLocal : null
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
