if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var dstPath = `${__dirname}/../tmp.tmp/madeDir`;

// directoryMake sync

files.dirMake({ filePath : dstPath, sync : 1 });
console.log( 'sync dirMake: ', files.fileExists( dstPath ) ); // logs: sync dirMake: true
files.fileDelete( dstPath );

// directoryMake async

var con = files.dirMake({ filePath : dstPath, sync : 0 });
con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;

  console.log( 'async dirMake: ', files.fileExists( dstPath ) ); // logs: async dirMake: true
  files.fileDelete( dstPath );
})
