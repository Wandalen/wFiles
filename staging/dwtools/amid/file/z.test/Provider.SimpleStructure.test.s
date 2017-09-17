( function _FileProvider_SimpleStructure_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;
  require( './aFileProvider.test.s' );
}

//

var _ = wTools;
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
}

//

function makePath( filePath )
{
  return './' + filePath;
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.SimpleStructure',
  silencing : 1,
  abstract : 0,

  context :
  {
    filesTree : filesTree,
    provider : _.FileProvider.SimpleStructure( { filesTree : filesTree } ),
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

if( 0 )
if( isBrowser )
{
  Self = new wTestSuite( Parent ).extendBy( Self );
  _.Tester.test( Self.name );
}

})();
