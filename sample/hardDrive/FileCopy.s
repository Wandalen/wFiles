if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var srcPath = `${__dirname}/../tmp.tmp/forCopying.txt`;
var dstPath = `${__dirname}/../tmp.tmp/forCopyingCopied.txt`;

// fileCopy sync

files.fileCopy
({
  dstPath,
  srcPath,
  sync : 1
});
var copiedData = files.fileRead({ filePath : dstPath, sync : 1 });
console.log( 'copied sync: ', copiedData ); // logs: copied sync: for copying data...
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
  console.log( 'copied async: ', copiedData ); // logs: copied async: for copying data...
  files.fileDelete({ filePath : dstPath, sync : 1 });
})
