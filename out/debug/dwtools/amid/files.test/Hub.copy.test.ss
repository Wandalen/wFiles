( function _FileProvider_Hub_copy_test_ss_( ) {

'use strict'; /*aaa*/

// !!! disabled because Provider.Hub is in implementation phase

return;

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

var _ = _global_.wTools;

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  _.include( 'wTesting' );
}

//

var _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  this.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'Hub/Copy' );
}

//

function onSuiteEnd()
{
  _.assert( _.strEnds( this.testRootDirectory, 'Hub/Copy' ) );
  _.path.dirTempClose( this.testRootDirectory );
}

//

function copy( test )
{
  var self = this;

  var hardDrive = _.FileProvider.HardDrive();
  var simpleStructure = _.FileProvider.Extract({ filesTree : Object.create( null ), protocols : [ 'extract' ] });

  self.hub.providerRegister( hardDrive );
  self.hub.providerRegister( simpleStructure );

  var hdUrl = hardDrive.urlFromLocal( _.path.normalize( __dirname ) );
  var hdUrlDst = hardDrive.urlFromLocal( _.path.join( self.testRootDirectory, test.name + '_copy' ) );
  var ssUrl = simpleStructure.urlFromLocal( '/root/file/copy' );
  var ssUrlDst = simpleStructure.urlFromLocal( '/root/file/_copy' );

  //

  test.description = 'copy files hd -> hd';
  _.assert( _.strHas( hdUrlDst, 'tmp.tmp' ) );
  self.hub.filesDelete( hdUrlDst );
  self.hub.filesCopy
  ({
    src : hdUrl,
    dst : hdUrlDst
  });
  var expected = self.hub.filesFind
  ({
    filePath : hdUrl,
    outputFormat : 'relative',
    basePath : hdUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : hdUrlDst,
    outputFormat : 'relative',
    basePath : hdUrlDst,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });

  test.identical( got,expected );

  //

  test.description = 'copy files hardDrive -> simpleStructure';
  _.assert( _.strHas( hdUrlDst, 'tmp.tmp' ) );
  self.hub.filesDelete( hdUrlDst );
  self.hub.filesCopy
  ({
    src : hdUrl,
    dst : ssUrl
  });
  var expected = self.hub.filesFind
  ({
    filePath : hdUrl,
    outputFormat : 'relative',
    basePath : hdUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : ssUrl,
    outputFormat : 'relative',
    basePath : ssUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  test.identical( got,expected );

  //

  test.description = 'copy files simpleStructure -> simpleStructure';
  self.hub.filesCopy
  ({
    src : ssUrl,
    dst : ssUrlDst
  });
  var expected = self.hub.filesFind
  ({
    filePath : ssUrl,
    outputFormat : 'relative',
    basePath : ssUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : ssUrlDst,
    outputFormat : 'relative',
    basePath : ssUrlDst,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  test.identical( got,expected );

  //

  test.description = 'copy files simpleStructure -> hardDrive';
  _.assert( _.strHas( hdUrlDst, 'tmp.tmp' ) );
  self.hub.filesDelete( hdUrlDst );

  self.hub.filesCopy
  ({
    src : ssUrlDst,
    dst : hdUrlDst
  });
  var expected = self.hub.filesFind
  ({
    filePath : ssUrl,
    outputFormat : 'relative',
    basePath : ssUrl,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : hdUrlDst,
    outputFormat : 'relative',
    basePath : hdUrlDst,
    recursive : 1,
    includingDirectories : 1,
    includingTerminals : 1,
    includingBase : 0
  });
  test.identical( got,expected );

}

// --
// proto
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Hub/Copy',
  abstract : 0,
  silencing : 1,
  enabled : 0,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

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
