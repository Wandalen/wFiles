if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
  require( '../staging/amid/file/FileProviderSimpleStructure.s' )

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

// please move it ( deploter ) out into separete sample in another module
// module Files should not be aware of modules of higher level

// var deployer = new wDeployer();
// deployer.read( __dirname + '/include' );

var files = _.FileProvider.SimpleStructure( { tree : tree } );
var consequence = files.fileReadAct( { pathFile : '/folder.abc/folder2.x/test1.txt', sync : 0 } );

// problem was not consequence
// but implementation of FileProvider.SimpleStructure.fileReadAct

consequence.then_( function( err,data )
{

  console.log( 'files.fileReadAct :' );

  if( err )
  throw _.err( err );
  else
  console.log( data );

});
