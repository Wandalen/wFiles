( function _FileProvider_Hub_copy_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  if( typeof wBase === 'undefined' )
  try
  {
    try
    {
      require.resolve( '../../../../../dwtools/Base.s' )/*fff*/;
    }
    finally
    {
      require( '../../../../../dwtools/Base.s' )/*fff*/;
    }
  }
  catch( err )
  {
    require( 'wTools' );
  }
var _ = wTools;

  if( !wTools.FileProvider )
  require( '../file/FileTop.s' );

  _.include( 'wTesting' );
}

//

var _ = wTools;

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
  _.fileProvider.filesDelete({ filePath : self.testRootDirectory });
}

//

function copy( test )
{
  var self = this;

  var hardDrive = _.FileProvider.HardDrive();
  var simpleStructure = _.FileProvider.SimpleStructure();

  self.hub.providerRegister( hardDrive );
  self.hub.providerRegister( simpleStructure );

  var hdUrl = hardDrive.urlFromLocal( _.pathJoin( self.testRootDirectory, test.name ) );
  var ssUrl = simpleStructure.urlFromLocal( '/root/file/copy' );

  var tree =
  {
    'src' :
    {
      'a.a' : 'a',
      'b1.b' : 'b1',
      'b2.b' : 'b2x',
      'c' :
      {
        'b3.b' : 'b3x',
        'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
        'srcfile' : 'srcfile',
        'srcdir' : {},
        'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
        'srcfile-dstdir' : 'x',
      }
    }
  }

  self.hub.filesDelete( hdUrl );
  self.hub.filesTreeWrite
  ({
    filePath : hdUrl,
    filesTree : tree,
    allowWrite : 1,
    allowDelete : 1,
    sameTime : 1,
  });

  //

  test.description = 'copy files hd -> hd';
  var hdUrlDst = hardDrive.urlFromLocal( _.pathJoin( self.testRootDirectory, test.name + '_copy' ) );
  self.hub.filesCopy
  ({
    src : hdUrl,
    dst : hdUrlDst
  });
  var expected = self.hub.filesFind
  ({
    filePath : hdUrl,
    outputFormat : 'relative',
    relative : hdUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingFirstDirectory : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : hdUrlDst,
    outputFormat : 'relative',
    relative : hdUrlDst,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingFirstDirectory : 0
  });

  test.identical( got,expected );

  //

  test.description = 'copy files hardDrive -> simpleStructure'
  self.hub.filesCopy
  ({
    src : hdUrl,
    dst : ssUrl
  });
  var expected = self.hub.filesFind
  ({
    filePath : hdUrl,
    outputFormat : 'relative',
    relative : hdUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingFirstDirectory : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : ssUrl,
    outputFormat : 'relative',
    relative : ssUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingFirstDirectory : 0
  });
  test.identical( got,expected );

  return;

  //

  self.hub.filesDelete( ssUrl );
  self.hub.filesTreeWrite
  ({
    filePath : ssUrl,
    filesTree : tree,
    allowWrite : 1,
    allowDelete : 1,
    sameTime : 1,
  });

  var ssUrlDst = simpleStructure.urlFromLocal( '/root/file/_copy' );
  self.hub.filesCopy
  ({
    src : ssUrl,
    dst : ssUrlDst
  });
  var expected = self.hub.filesFind
  ({
    filePath : ssUrl,
    outputFormat : 'relative',
    includingFirstDirectory : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : ssUrlDst,
    outputFormat : 'relative',
    includingFirstDirectory : 0
  });
  test.identical( got,expected );
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.Hub.copy',
  abstract : 0,
  silencing : 1,

  onSuitBegin : testDirMake,
  onSuitEnd : testDirClean,

  context :
  {
    hub : _.FileProvider.Hub({ empty : 1 }),
    testRootDirectory : null,
  },

  tests :
  {
    copy : copy
  },

}

//

var Self = new wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
