if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var srcPath = `${__dirname}/../tmp.tmp/forRenaming.txt`;
var dstPath = `${__dirname}/../tmp.tmp/madeDir`;

// directoryMake sync

files.dirMake({ filePath : dstPath, sync : 1 });
console.log( 'sync dirMake: ', files.fileExists( dstPath ) );
files.fileDelete( dstPath );

// directoryMake async

var con = files.dirMake({ filePath : dstPath, sync : 0 });
con.got( ( err ) =>
{
  // if(err)
  // throw err;
  console.log( 'async dirMake: ', files.fileExists( dstPath ) );
  files.fileDelete( dstPath );
})
