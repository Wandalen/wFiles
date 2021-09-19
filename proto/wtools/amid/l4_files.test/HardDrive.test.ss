
( function _HardDrive_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );
  _.include( 'wTesting' );
  require( '../l4_files/entry/Files.s' );
}

const _ = _global_.wTools;

// --
// tests
// --

function readWriteOptionWriteMode( test )
{
  let a = test.assetFor( false );

  /* */

  test.case = 'read write';
  a.reflect();
  var data = 'test data';
  var filePath = a.abs( 'file1.txt' );
  a.fileProvider.fileWrite( filePath, data );
  var got = a.fileProvider.fileRead( filePath );
  test.identical( got, data );

  /* */

  test.case = 'writeMode';
  a.reflect();
  var data = 'test data';
  var filePath = a.abs( 'file1.txt' );
  a.fileProvider.fileWrite({ filePath, data, writeMode: 'rewrite' });
  var got = a.fileProvider.fileRead( filePath );
  a.fileProvider.fileWrite({ filePath, data });
  test.identical( got, data );

  /* */

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.Namespace',
  silencing : 1,

  tests :
  {
    readWriteOptionWriteMode,
  },
};

//

const Self = wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
