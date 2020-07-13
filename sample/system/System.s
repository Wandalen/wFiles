if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

/* fileCopy from HardDrive to Extract */

var hub = _.FileProvider.System({ providers : [] });

var hardDriveProvider = _.FileProvider.HardDrive({ protocol : 'hard' });

var tree =
{
  dir1 :
  {
    dir2 : {}
  }
}
var extractProvider = _.FileProvider.Extract({ protocol : 'ext', filesTree : tree });

hub.providerRegister( hardDriveProvider );
hub.providerRegister( extractProvider );
hub.defaultProvider = hardDriveProvider;
/* or vice versa
hardDriveProvider.providerRegisterTo( hub );
extractProvider.providerRegisterTo( hub );
*/
// bug maybe. Create test suite with system...
hub.fileCopy
({
  dstPath : 'ext:///dir1/dir2/fileFromHardDrive.txt',
  srcPath : `hard://${__dirname}/../data/File1.txt`,
  sync : 1
});

var data = extractProvider.fileRead
({
  filePath : '/dir1/dir2/fileFromHardDrive.txt',
  sync : 1
});
console.log( data ); // logs: data from hard drive...
