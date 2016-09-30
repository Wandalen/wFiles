if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
  require( '../staging/amid/file/FileProviderSimpleStructure.s' )
  //require( '../../wDeployer/staging/amid/deployer/Deployer.ss' )



}

var _ = wTools;

// var deployer = new wDeployer();`
// deployer.read( __dirname );
//_.FileProvider.Abstract.readFileSync( { pathFile : __dirname + 'sample3.js' } );
var files = _.FileProvider.HardDrive();
var read = files.fileReadSync( { pathFile : __filename } );
console.log( 'read :',read );
