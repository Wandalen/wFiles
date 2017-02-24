( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

  var _ = wTools;

  // _.include( 'wFiles' );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

//

function makePath( pathFile )
{
  if( !this.provider.fileStat( this.testRootDirectory ) )
  this.provider.directoryMake( this.testRootDirectory );

  pathFile =  _.pathJoin( this.testRootDirectory,  pathFile );
  return this.provider.pathNativize( pathFile );
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.HardDrive',
  sourceFilePath : sourceFilePath,

  special :
  {
    provider : _.FileProvider.HardDrive(),
    makePath : makePath,
    testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

}

//

if( typeof module !== 'undefined' )
Self = new wTestSuite( Parent ).extendBy( Proto );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
