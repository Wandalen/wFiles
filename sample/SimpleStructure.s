
if( typeof module !== 'undefined' )
require( '../staging/amid/file/Files.ss' );
// require( 'wFiles' );

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
  'file1' : 'Excepteur sint occaecat cupidatat non proid',
}

//

var _ = wTools;
var fileProvider = _.FileProvider.SimpleStructure({ filesTree : filesTree });

fileProvider.fileWriteAct( 'xxx','xxx' );

console.log( 'filesTree.xxx',filesTree.xxx );
