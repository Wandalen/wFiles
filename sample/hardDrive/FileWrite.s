if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var path = `${__dirname}/../data/tmp.tmp/WrittenFile.txt`;
var dataSync = 'sync data';
var dataAsync = 'async data';

// fileWrite sync

files.fileWrite
({
  filePath : path,
  data : dataSync,
  sync : 1,
  makingDirectory : 1
});
var result = files.fileRead({ filePath : path, sync : 1 });
console.log( result === dataSync ); // logs: true

// fileWrite async

files.fileWrite
({
  filePath : path,
  data : dataAsync,
  sync : 0,
  makingDirectory : 1
})
.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  var result = files.fileRead({ filePath : path, sync : 1 });
  console.log( result === dataAsync ); // logs: true
});
