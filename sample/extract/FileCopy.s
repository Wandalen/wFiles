if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' :
  {
    'fileForCopying.txt' : 'data from copied file...',
    'dir2' : {}
  },
  'dir1.2' : {}
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

// fileCopy sync

provider.fileCopy
({
  dstPath : '/dir1/dir2/copied.txt',
  srcPath : '/dir1/fileForCopying.txt',
  sync : 1
});
var copiedFileData = provider.fileRead({ filePath : '/dir1/dir2/copied.txt', sync : 1 });
console.log( 'sync copying: ', copiedFileData ); // logs: sync copying: data from copied file...

// fileCopy async

var con = provider.fileCopy
({
  dstPath : '/dir1.2/copied.txt',
  srcPath : '/dir1/fileForCopying.txt',
  sync : 0
});

con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  var copiedData = provider.fileRead({ filePath : '/dir1.2/copied.txt', sync : 1 });
  console.log( 'async copying: ', copiedData ); // logs: async copying: data from copied file...
})
