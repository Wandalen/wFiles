if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var srcPath = `${__dirname}/../data/File1.txt`;
var dstPath = `${__dirname}/../data/tmp.tmp/CopiedFile.txt`;

// fileCopy sync

files.fileCopy
({
  dstPath,
  srcPath,
  sync : 1
});
var copiedData = files.fileRead({ filePath : dstPath, sync : 1 });
console.log( 'copied sync: ', copiedData );
files.fileDelete({ filePath : dstPath, sync : 1 });

// fileCopy async

var con = files.fileCopy
({
  dstPath,
  srcPath,
  sync : 0
});

con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;

  var copiedData = files.fileRead({ filePath : dstPath, sync : 1 });
  console.log( 'copied async: ', copiedData );
})
