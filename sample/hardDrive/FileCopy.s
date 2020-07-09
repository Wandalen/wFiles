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
console.log( copiedData );
files.fileDelete({ filePath : dstPath, sync : 1 });

// fileCopy async

var con = files.fileCopy
({
  dstPath,
  srcPath,
  sync : 0
});

con.got( ( err ) =>
{
  // if( err )
  // throw err;
  var copiedData = files.fileRead({ filePath : dstPath, sync : 1 });
  console.log( copiedData );
  files.fileDelete({ filePath : dstPath, sync : 1 });
})
