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
var Parent = wTests[ 'FileProvider' ];
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

_.assert( Parent );

//

function makePath( pathFile )
{
  pathFile =  _.pathJoin( this.testRootDirectory,  pathFile );
  return this.provider.pathNativize( pathFile );
}

function makeTestDir()
{
  if( this.provider.fileStat( this.testRootDirectory ) )
  this.provider.fileDelete({ pathFile : this.testRootDirectory, force : 1 });

  this.provider.directoryMake
  ({
    pathFile : this.testRootDirectory,
    force : 1
  });

  var read = this.provider.pathNativize( _.pathJoin( this.testRootDirectory, 'read' ) );
  var written = this.provider.pathNativize( _.pathJoin( this.testRootDirectory, 'written' ) );

  if( !this.provider.fileStat( read ) )
  this.provider.directoryMake( read );

  if( !this.provider.fileStat( written ) )
  this.provider.directoryMake( written );
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
    makeTestDir : makeTestDir,
    testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

}

//

if( typeof module !== 'undefined' )
var Self = new wTestSuite( Parent ).extendBy( Proto );
if( typeof module !== 'undefined' && !module.parent )
{
  Self.special.makeTestDir();
  _.Testing.test( Self.name );
}

} )( );
