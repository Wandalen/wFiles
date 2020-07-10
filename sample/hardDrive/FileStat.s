if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileStat sync

var stats = files.statRead
({
  filePath : `${__dirname}/../tmp.tmp/forReading.txt`,
  sync : 1
});
console.log( stats );

// fileStat async

files.statRead
({
  filePath : `${__dirname}/../tmp.tmp/forReading.txt`,
  throwing : 1,
  sync : 0
})
.finallyGive( ( err, arg ) =>
{
  if( err ) throw err;
  console.log( arg );
});
