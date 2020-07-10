if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var srcPathFile = `${__dirname}/../tmp.tmp/forRenaming.txt`;
var dstPathFile = `${__dirname}/../tmp.tmp/forRenamingRenamed.txt`;

var srcPathDir = `${__dirname}/../tmp.tmp/forRenamingDir`;
var dstPathDir = `${__dirname}/../tmp.tmp/forRenamingDirRenamed`;

/* fileRename sync */

// file renaming
files.fileRename
({
  dstPath : dstPathFile,
  srcPath : srcPathFile,
  sync : 1
});
var dataFromRenamedFile = files.fileRead({ filePath : dstPathFile, sync : 1 });
console.log( dataFromRenamedFile ); // logs: from renamed file...
files.fileRename({ dstPath : srcPathFile, srcPath : dstPathFile, sync : 1 });

// directory renaming
files.fileRename
({
  dstPath : dstPathDir,
  srcPath : srcPathDir,
  sync : 1
});
var content = files.dirRead({ filePath : dstPathDir });
console.log( content ); // logs: [ 'file.txt' ]
files.fileRename({ dstPath : srcPathDir, srcPath : dstPathDir, sync : 1 });

/* fileRename async */

// file renaming
var con = files.fileRename
({
  dstPath : dstPathFile,
  srcPath : srcPathFile,
  sync : 0
});
con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;

  var dataFromRenamedFile = files.fileRead({ filePath : dstPathFile, sync : 1 });
  console.log( dataFromRenamedFile ); // logs: from renamed file...
  files.fileRename({ dstPath : srcPathFile, srcPath : dstPathFile, sync : 1 });
});

// directory renaming
var con = files.fileRename
({
  dstPath : dstPathDir,
  srcPath : srcPathDir,
  sync : 0
});
con.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;

  var content = files.dirRead({ filePath : dstPathDir });
  console.log( content ); // logs: [ 'file.txt' ]
  files.fileRename({ dstPath : srcPathDir, srcPath : dstPathDir, sync : 1 });
});
