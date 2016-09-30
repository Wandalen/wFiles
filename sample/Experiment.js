if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
  require( '../staging/amid/file/FileProviderSimpleStructure.s' )
  require( '../../wDeployer/staging/amid/deployer/Deployer.ss' )



}

var _ = wTools;

var tree =
{
 "folder.abc" :
 {
   'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
   'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   'folder2.x' :
   {
     'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   }
 }
}

var deployer = new wDeployer();
deployer.read( __dirname  );
var files = _.FileProvider.SimpleStructure( { tree : tree } );
var read = files._fileRead( { pathFile : '/folder.abc/folder2.x/test1.txt', sync : 1 } );
console.log( 'read :',read );

// console.log(_.entitySelect( tree, 'folder.abc' ));
