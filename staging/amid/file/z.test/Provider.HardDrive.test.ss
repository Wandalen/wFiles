( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

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

function pathsAreLinked( paths )
{
  var linked = true;
  var statsFirst = this.provider.fileStat( paths[ 0 ] );
  for( var i = 1; i < paths.length; i++ )
  {
    var statCurrent = this.provider.fileStat( paths[ i ] );
    linked &= _.statsAreLinked( statsFirst, statCurrent );
    if( !linked )
    break;
  }

  return linked;
}

//

function makeFiles( names, dirPath, data )
{
  var self = this;

  if( !_.arrayIs( data ) )
  data = _.arrayFillTimes( [], names.length, data );

  _.assert( data.length === names.length );

  var paths = names.map( ( p )  => self.makePath( _.pathJoin( dirPath, p ) ) );
  paths.forEach( ( p, i )  =>
  {
    if( self.provider.fileStat( p ) )
    self.provider.fileTouch({ filePath : p, purging : 1 });

    self.provider.fileWrite( p, data[ i ] )
  });

  return paths;
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
  silencing : 1,

  onSuiteBegin : makeTestDir,

  context :
  {
    provider : _.FileProvider.HardDrive(),
    makePath : makePath,
    makeFiles : makeFiles,
    pathsAreLinked : pathsAreLinked,
    makeTestDir : makeTestDir,
    testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

  tests :
  {
    // fileRenameSync : null,
  },

}

//

// var Self = new wTestSuite( Parent ).extendBy( Proto );
var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
