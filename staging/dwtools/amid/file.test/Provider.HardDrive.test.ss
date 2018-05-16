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

function makePath( filePath )
{
  filePath =  _.pathJoin( this.testRootDirectory,  filePath );
  filePath = _.pathNormalize( filePath );
  filePath =  this.originalProvider.originPath + filePath;
  debugger
  return filePath
}

//

function pathsAreLinked( paths )
{

  var statsFirst = this.provider.fileStat( paths[ 0 ] );
  for( var i = 1; i < paths.length; i++ )
  {
    var statCurrent = this.provider.fileStat( paths[ i ] );
    if( !_.statsAreLinked( statsFirst, statCurrent ) )
    return false
  }

  return true;
}

//

function linkGroups( paths, groups )
{
  groups.forEach( ( g ) =>
  {
    if( g.length >= 2 )
    {
      var filePathes = g.map( ( i ) => paths[ i ] );
      this.provider.linkHard({ dstPath : filePathes });
    }
  })
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

function makeHardLinksToPath( filePath, amount )
{
  var self = this;

  _.assert( _.pathIsAbsolute( filePath ) );
  _.assert( _.strHas( filePath, 'tmp.tmp' ) );

  var dir = _.dirTempMake( _.pathDir( filePath ) );
  var files = [];
  for( var c = 0; c < amount; c++ )
  {
    var path = _.pathJoin( dir, 'file' + c );
    self.provider.linkHard( path, filePath );
  }

  var stat = self.provider.fileStat( filePath );
  _.assert( stat.nlink >= amount );

}

//

function testDirMake( test )
{
  var self = this;
  self.testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..'  ) );
}

//

function testDirClean()
{
  var self = this;
  debugger
  self.provider.filesDelete({ filePath : self.testRootDirectory });
}

//

function onSuitBegin()
{
  var self = this;

  self.provider.providerRegister( self.originalProvider );
  self.provider.defaultProvider = self.originalProvider;
  self.provider.defaultOrigin = self.originalProvider.originPath;
  self.provider.defaultProtocol = 'file';

  self.testDirMake();
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
  onSuitEnd : testDirClean,

  context :
  {
    originalProvider : _.FileProvider.HardDrive(),
    provider : _.FileProvider.Hub({ empty : 1 }),
    makePath : makePath,
    makeFiles : makeFiles,
    makeHardLinksToPath : makeHardLinksToPath,
    pathsAreLinked : pathsAreLinked,
    linkGroups : linkGroups,
    testDirMake : testDirMake,
    testRootDirectory : null,
    testFile : null,
    // testRootDirectory : __dirname + '/../../../../tmp.tmp/hard-drive',
    // testFile : __dirname + '/../../../../tmp.tmp/hard-drive/test.txt',
  },

  tests :
  {
    // fileRenameSync : null,
  },

}

//

var Self = new wTestSuit( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
