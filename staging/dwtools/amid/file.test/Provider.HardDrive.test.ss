( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'FileProvider' ];

_.assert( Parent );

//

function onSuitBegin( test )
{
  this.testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..'  ) );
}

//

function onSuitEnd()
{
  this.provider.filesDelete( this.testRootDirectory );
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.HardDrive',
  abstract : 0,
  silencing : 1,

  onSuitBegin : onSuitBegin,
  onSuitEnd : onSuitEnd,

  context :
  {
    provider : _.FileProvider.HardDrive(),

    onSuitBegin : onSuitBegin,
    testRootDirectory : null,
    // testFile : null,
    // testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    // testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

  tests :
  {
  },

}

//

var Self = new wTestSuit( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
