if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();
var path = `${__dirname}/../tmp.tmp/forWriting.txt`;
var dataSync = 'sync data';
var dataAsync = 'async data';

// fileWrite sync

files.fileWrite
({
  filePath : path,
  data : dataSync,
  sync : 1
});
var result = files.fileRead({ filePath : path, sync : 1 });
console.log( result === dataSync );

// fileWrite async
debugger;
files.fileWrite
({
  filePath : path,
  data : dataAsync,
  sync : 0
})
.got( ( err ) =>
{
  // if( err )
  // throw err;
  var result = files.fileRead({ filePath : path, sync : 1 });
  console.log( result === dataAsync );
});
