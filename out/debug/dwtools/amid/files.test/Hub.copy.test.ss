( function _FileProvider_Hub_copy_test_ss_( ) {

'use strict';

// !!! disabled because Provider.Hub is in implementation phase

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  _.include( 'wTesting' );
}

//

var _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  this.testSuitePath = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ) );
}

//

function onSuiteEnd()
{
  _.fileProvider.filesDelete({ filePath : this.testSuitePath });
}

//

function copy( test )
{
  var self = this;

  var hardDrive = _.FileProvider.HardDrive();
  var simpleStructure = _.FileProvider.Extract({ filesTree : Object.create( null ) });

  self.hub.providerRegister( hardDrive );
  self.hub.providerRegister( simpleStructure );

  var hdUrl = hardDrive.path.globalFromPreferred( _.path.normalize( __dirname ) );
  var hdUrlDst = hardDrive.path.globalFromPreferred( _.path.join( self.testSuitePath, test.name + '_copy' ) );
  var ssUrl = simpleStructure.path.globalFromPreferred( '/root/files/copy' );
  var ssUrlDst = simpleStructure.path.globalFromPreferred( '/root/files/_copy' );

  //

  test.case = 'copy files hd -> hd';
  _.assert( _.strHas( hdUrlDst, 'tmp.tmp' ) );
  self.hub.filesDelete( hdUrlDst );
  self.hub.filesCopyOld
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
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : hdUrlDst,
    outputFormat : 'relative',
    basePath : hdUrlDst,
    recursive : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });

  test.identical( got,expected );

  //

  test.case = 'copy files hardDrive -> simpleStructure';
  _.assert( _.strHas( hdUrlDst, 'tmp.tmp' ) );
  self.hub.filesDelete( hdUrlDst );
  self.hub.filesCopyOld
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
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : ssUrl,
    outputFormat : 'relative',
    basePath : ssUrl,
    recursive : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  test.identical( got,expected );

  //

  test.case = 'copy files simpleStructure -> simpleStructure';
  self.hub.filesCopyOld
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
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : ssUrlDst,
    outputFormat : 'relative',
    basePath : ssUrlDst,
    recursive : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  test.identical( got,expected );

  //

  test.case = 'copy files simpleStructure -> hardDrive';
  _.assert( _.strHas( hdUrlDst, 'tmp.tmp' ) );
  self.hub.filesDelete( hdUrlDst );

  self.hub.filesCopyOld
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
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  var got = self.hub.filesFind
  ({
    filePath : hdUrlDst,
    outputFormat : 'relative',
    basePath : hdUrlDst,
    recursive : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingStem : 0
  });
  test.identical( got,expected );

}

// --
// proto
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Hub/copy',
  abstract : 0,
  silencing : 1,
  enabled : 0,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    hub : _.FileProvider.Hub({ empty : 1 }),
    testSuitePath : null,
  },

  tests :
  {
    copy : copy
  },

}

//

var Self = new wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
