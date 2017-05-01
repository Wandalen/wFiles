( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

  var _ = wTools;

  // console.log( '_.fileProvider :',_.fileProvider );

}

//

var _ = wTools;
var Parent = wTests[ 'FileProvider' ];

_.assert( Parent );

//

function makePath( filePath )
{
  filePath =  _.pathJoin( this.testRootDirectory,  filePath );
  return this.provider.pathNativize( filePath );
}

//

function makeTestDir( test )
{

  console.log( 'makeTestDir' );

  if( this.provider.fileStat( this.testRootDirectory ) )
  this.provider.fileDelete({ filePath : this.testRootDirectory, force : 1 });

  this.provider.directoryMake
  ({
    filePath : this.testRootDirectory,
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
  abstract : 0,

  onSuiteBegin : makeTestDir,

  context :
  {
    provider : _.FileProvider.HardDrive(),
    makePath : makePath,
    makeTestDir : makeTestDir,
    testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

}

//

// if( typeof module !== 'undefined' )
var Self = new wTestSuite( Parent ).extendBy( Proto );

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
