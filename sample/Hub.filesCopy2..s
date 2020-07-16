if( typeof module !== 'undefined' )
require( 'wFiles' )

let _ = wTools;

/* filesCopy HardDrive -> Extract */

var hub = _.FileProvider.Hub();

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
  }
}
var simpleStructure = _.FileProvider.Extract
({
  filesTree : filesTree,
  safe : 0
});

hub.providerRegister( simpleStructure );

var hdUrl = _.fileProvider.urlFromLocal( _.normalize( _.join( __dirname, 'dst' ) ) );
var ssUrl = simpleStructure.urlFromLocal( '/folder.abc' );

hub.filesCopy
({
  dst : hdUrl,
  src : ssUrl,
  preserveTime : 0
});

var files = hub.filesFind( hdUrl );
console.log( files );