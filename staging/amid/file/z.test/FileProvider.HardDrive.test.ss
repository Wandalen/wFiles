( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

  var _ = wTools;

  _.include( 'wFiles' );

}

//

var _ = wTools;
var Parent = wTests.FileProvider;
var Self = {};

//

function makePath( pathFile )
{
  return _.pathJoin( this.testRootDirectory,  pathFile );
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.HardDrive',

  special :
  {
    testRootDirectory : __dirname + '/../../../tmp.tmp/hard-drive',
    provider : _.FileProvider.HardDrive(),
    makePath : makePath,
    testFile : __dirname + '/../../../LICENSE'
  },

}

if( typeof module !== 'undefined' )
Self = new wTestSuite( Parent ).extendBy( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
