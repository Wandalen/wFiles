if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

var cachingStats = _.FileFilter.Caching();

/* get stat for current dir and cache them */

var fileStatSync = cachingStats.fileStat( _.pathRealMainDir() );
console.log( "\nfileStatSync: ",fileStatSync );
console.log( "cacheStats: ",cachingStats._cacheStats );

/* creating of new file invokes stats caching */

cachingStats.fileWrite( '1.txt', 'abc' );
var fileStatSync = cachingStats.fileStat( '1.txt' );
console.log( "\nfileStatSync: ",fileStatSync );
console.log( "cacheStats: ",cachingStats._cacheStats );

/* updating of existing file invokes updating of chached stats */

cachingStats.fileWrite
({
  filePath : '1.txt',
  data : 'abc',
  writeMode : 'append'
});
var fileStatSync = cachingStats.fileStat( '1.txt' );
console.log( "\nfileStatSync: ",fileStatSync );

/* deleting of existing file invokes deleting of chached stats */

cachingStats.fileDelete( '1.txt' );
var fileStatSync = cachingStats.fileStat( '1.txt' );
console.log( "\nfileStatSync: ",fileStatSync );
