if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
}

var _ = wTools;

var cachingStats = _.FileProvider.CachingStats();
var fileStatSync = cachingStats.fileStat( 'Sample2.js' );
console.log( "\nfileStatSync: ",fileStatSync );

cachingStats.fileStat
({
  pathFile : __filename,
  sync : 0
})
.got( function( err, data )
{
  if( err )
  throw err;
  console.log( "\nfileStatAsync: ", data );
  console.log( "\ncachingStats._cache: ", cachingStats._cache );
})
