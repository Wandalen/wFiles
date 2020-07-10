if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileRead sync

var data = files.fileRead
({
  filePath : `${__dirname}/../data/File1.txt`,
  sync : 1
});
console.log( 'read sync: ', data );

// fileRead async

files.fileRead
({
  filePath : `${__dirname}/../data/File1.txt`,
  sync : 0
})
.finallyGive( ( err, data ) =>
{
  if( err ) throw err;
  console.log( 'read async: ', data );
});
