( function _FileProvider_SimpleStructure_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests.FileProvider;

//

var filesTree =
{
 "folder.abc" :
 {
   'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
   'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   'folder2.x' :
   {
     'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   }
 },
 "test_dir" :
 {
   'test3.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
 }
}

//

function makePath( pathFile )
{
  return pathFile;
}

// --
// proto
// --

var Self =
{

  name : 'FileProvider.SimpleStructure',
  verbosity : 0,

  special :
  {
    filesTree : filesTree,
    provider : _.FileProvider.SimpleStructure( { filesTree : filesTree } ),
    makePath : makePath,
  },

  tests :
  {
  },

}

if( typeof module !== 'undefined' )
Self = new wTestSuite( Parent ).extendBy( Proto );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
