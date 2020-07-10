if( typeof module !== 'undefined' )
require( 'wFiles' )

var tree =
{
  'dir1' :
  {
    'dir2' :
    {
      'fileRenameSync.txt' : 'renamed sync data...',
      'fileRenameAsync.txt' : 'renamed async data...',
    }
  },
  'dir1.2' : { 'file1.txt' : 'data', 'file2.txt' : 'data' },
  'dir1.3' : { 'file2.txt' : 'data', 'file3.txt' : 'data' }
}

//

var _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });

/* fileRename sync */

// file renaming
provider.fileRename
({
  dstPath : '/dir1/dir2/fileRenameSyncRenamed.txt',
  srcPath : '/dir1/dir2/fileRenameSync.txt',
  sync : 1
});
var dataFromRenamedFile = provider.fileRead({ filePath : '/dir1/dir2/fileRenameSyncRenamed.txt', sync : 1 });
console.log( dataFromRenamedFile ); // logs: renamed sync data...

// directory renaming
provider.fileRename
({
  dstPath : '/dir3',
  srcPath : '/dir1.2',
  sync : 1
});
var content = provider.dirRead({ filePath : '/dir3' });
console.log( 'sync dir renaming: ', content ); // logs: sync dir renaming: [ 'file1.txt', 'file2.txt' ]

/* fileRename async */

// file renaming
var con = provider.fileRename
({
  dstPath : '/dir1/dir2/fileRenameAsyncRenamed.txt',
  srcPath : '/dir1/dir2/fileRenameAsync.txt',
  sync : 0
});
con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  var dataFromRenamedFile = provider.fileRead({ filePath : '/dir1/dir2/fileRenameAsyncRenamed.txt', sync : 1 });
  console.log( dataFromRenamedFile ); // logs: renamed async data...
});

// directory renaming
var con = provider.fileRename
({
  dstPath : '/dir4',
  srcPath : '/dir1.3',
  sync : 0
});
con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  var content = provider.dirRead({ filePath : '/dir4' });
  console.log( 'async dir renaming: ', content ); // logs: async dir renaming: [ 'file3.txt', 'file4.txt' ]
});
