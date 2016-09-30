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
 "folder" :
 {
   'test1' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
   'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   'folder2' :
   {
     'test1' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   }
 }
}

// var deployer = new wDeployer();
// deployer.read( __dirname  );
var files = _.FileProvider.SimpleStructure( { tree : tree } );
var read = files._fileRead( { pathFile : 'folder' } );
// var read = files._fileRead( { pathFile : 'folder.folder2' } );
console.log( 'read :',read );
