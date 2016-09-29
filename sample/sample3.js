if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
  require( '../staging/amid/file/FileProviderSimpleStructure.ss' )



}

var _ = wTools;
// var treeWriten = _.FileProvider.AdvancedMixin.filesTreeRead
// ({
//   pathFile : __dirname +'sample3.js',
//   readTerminals : 0,
// });
//
// logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );
//
// var fileProvider = _.FileProvider.HardDrive({});
var fileProvider = _.FileProvider.SimpleStructure( { tree : {} } );
