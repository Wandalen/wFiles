( function _FileProvider_Hub_HardDrive_test_ss_( ) {

'use strict';

// !!! disabled because Provider.Hub is in implementation phase

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools/mid/files/fileProvider/Abstract' ];

_.assert( !!Parent );

//

function makePath( filePath )
{
  var self = this;

  filePath =  _.path.join( self.testRootDirectory,  filePath );

  return self.providerEffective.originPath + _.path.normalize( filePath );
}

//

function onSuiteBegin()
{
  var self = this;

  self.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'Hub/HardDrive' );

  self.provider.providerRegister( self.providerEffective );
  self.provider.defaultProvider = self.providerEffective;
  self.provider.defaultOrigin = self.providerEffective.originPath;
  self.provider.defaultProtocol = self.providerEffective.protocol;

}

function onSuiteEnd()
{
  _.assert( _.strEnds( this.testRootDirectory, 'Hub/HardDrive' ) );
  // this.providerEffective.filesDelete({ filePath : this.testRootDirectory });
  _.path.dirTempClose( this.testRootDirectory );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Hub/withHardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 0,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    provider : _.FileProvider.Hub({ empty : 1 }),
    providerEffective : _.FileProvider.HardDrive(),
    testRootDirectory : null,

    makePath : makePath,
    // testFile : null,
    // testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    // testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

  tests :
  {
  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
