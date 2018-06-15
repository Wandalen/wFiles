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
var Parent = wTests[ 'FileProvider' ];

_.assert( Parent );

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
  'linkToFile' : [{ hardLink : './file' }],
  'linkToUnknown' : [{ hardLink : './unknown' }],
  'linkToDir' : [{ hardLink : './test_dir' }],
  'softLinkToFile' : [{ softLink : './file' }],
  'softLinkToUnknown' : [{ softLink : './unknown' }],
  'softLinkToDir' : [{ softLink : './test_dir' }],
}

//

function makePath( filePath )
{
  return '/' + filePath;
}

// --
// define class
// --

var Proto =
{

  name : 'FileProvider.Extract',
  silencing : 1,
  abstract : 0,
  // verbosity : 10,

  context :
  {
    filesTree : filesTree,
    provider : _.FileProvider.Extract( { filesTree : filesTree } ),
    makePath : makePath,
    testFile : 'file1'
  },

  tests :
  {
  },

}

//

// if( typeof module !== 'undefined' )
// Self = new wTestSuite( Parent ).extendBy( Self );
var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

// if( 0 )
// if( isBrowser )
// {
//   Self = new wTestSuite( Parent ).extendBy( Self );
//   _.Tester.test( Self.name );
// }

})();
