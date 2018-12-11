( function _FileProvider_Extract_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;
  require( './aFileProvider.test.s' );
}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools/mid/files/fileProvider/Abstract' ];

_.assert( !!Parent );

//

var filesTree =
{
  'folder.abc' :
  {
    'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
    'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
    'folder2.x' :
    {
      'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
    }
  },
  'test_dir' :
  {
    'test3.js' : 'test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n',
  },
  'file1' : 'Excepteur sint occaecat cupidatat non proident',
  'file' : 'abc',
  'linkToFile' : [{ hardLink : '/file' }],
  'linkToUnknown' : [{ hardLink : '/unknown' }],
  'linkToDir' : [{ hardLink : '/test_dir' }],
  'softLinkToFile' : [{ softLink : '/file' }],
  'softLinkToUnknown' : [{ softLink : '/unknown' }],
  'softLinkToDir' : [{ softLink : '/test_dir' }],
}

//

function pathFor( filePath )
{
  return '/' + filePath;
}

// --
// tests
// --

function copy( test )
{

  test.case = 'default';

  var extract1 = new _.FileProvider.Extract();
  var extract2 = new _.FileProvider.Extract({});
  test.is( extract1.filesTree !== extract2.filesTree );

  test.case = 'from map with constructor';

  var op = { filesTree : {} }
  var extract1 = new _.FileProvider.Extract( op );
  var extract2 = new _.FileProvider.Extract( op );
  test.is( op.filesTree === extract1.filesTree );
  test.is( extract1.filesTree === extract2.filesTree );

  test.case = 'from map with copy';

  var op = { filesTree : {} }
  var extract1 = new _.FileProvider.Extract( op );
  var extract2 = new _.FileProvider.Extract();
  extract2.copy( op );
  test.is( op.filesTree === extract1.filesTree );
  test.is( extract1.filesTree === extract2.filesTree );

  /* !!! fix that */

  // test.case = 'from another instance with constructor';
  //
  // var op = { filesTree : {} }
  // var extract1 = new _.FileProvider.Extract( op );
  // var extract2 = new _.FileProvider.Extract( extract1 );
  // test.is( op.filesTree === extract1.filesTree );
  // test.is( extract1.filesTree !== extract2.filesTree );
  //
  // test.case = 'from another instance with copy';
  //
  // var op = { filesTree : {} }
  // var extract1 = new _.FileProvider.Extract( op );
  // var extract2 = new _.FileProvider.Extract();
  // extract2.copy( extract1 );
  // test.is( op.filesTree === extract1.filesTree );
  // test.is( extract1.filesTree !== extract2.filesTree );
  //
  // test.case = 'from another instance with clone';
  //
  // var op = { filesTree : {} }
  // var extract1 = new _.FileProvider.Extract( op );
  // var extract2 = extract1.clone();
  // extract2.copy( extract1 );
  // test.is( op.filesTree === extract1.filesTree );
  // test.is( extract1.filesTree !== extract2.filesTree );

}

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Extract',
  silencing : 1,
  abstract : 0,
  enabled : 1,

  context :
  {
    filesTree : filesTree,
    provider : _.FileProvider.Extract( { filesTree : filesTree, usingTime : 1 } ),
    pathFor : pathFor,
    testFile : '/file1'
  },

  tests :
  {

    copy : copy,

  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
