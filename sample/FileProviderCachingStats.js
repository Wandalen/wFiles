if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

var cachingStats = _.FileFilter.Caching();

var dir = _.pathJoin( _.pathDir( _.pathRealMainFile() ), 'cachingStatsSample' );
_.fileProvider.fileDelete( dir );
var filePath = _.pathJoin( dir, 'file.txt' );

/* get stat for current dir and cache them */

var fileStatSync = cachingStats.fileStat( _.pathRealMainDir() );
console.log( "\nfileStatSync: ",fileStatSync );
console.log( "cacheStats: ",cachingStats._cacheStats );

/* creating of new file invokes stats caching */

// cachingStats.fileWrite( filePath, 'abc' );
// var fileStatSync = cachingStats.fileStat( filePath );
// console.log( "\nfileStatSync: ",fileStatSync );
// console.log( "cacheStats: ",cachingStats._cacheStats );

/* updating of existing file invokes updating of chached stats */

// cachingStats.fileWrite( filePath, 'abc' );
// cachingStats.fileWrite
// ({
//   filePath : filePath,
//   data : 'abc',
//   writeMode : 'append'
// });
// var fileStatSync = cachingStats.fileStat( filePath );
// console.log( "\nfileStatSync: ",fileStatSync );

/* deleting of existing file invokes deleting of chached stats */

// cachingStats.fileWrite( filePath, 'abc' );
// cachingStats.fileDelete( filePath );
// var fileStatSync = cachingStats.fileStat( filePath );
// console.log( "\nfileStatSync: ", fileStatSync );
// console.log( "\ncachedStats: ", cachingStats._cacheStats );

/* creating of new dir invokes stats caching */

// var dirPath = _.pathJoin( dir, 'new_dir' );
// cachingStats.directoryMake( dirPath );
// var fileStatSync = cachingStats.fileStat( dirPath );
// console.log( "\nfileStatSync: ",fileStatSync );
// console.log( "cacheStats: ",cachingStats._cacheStats );

/* renaming invokes stats updating */

// var newPath = _.pathJoin( dir, 'file.js' );
// cachingStats.fileWrite( filePath, 'abc' );
// console.log( "cacheStats: ",cachingStats._cacheStats );
// cachingStats.fileRename( newPath, filePath );
// console.log( "cacheStats: ",cachingStats._cacheStats );

/* copying invokes stats updating */

// var newPath = _.pathJoin( dir, 'file.xx' );
// cachingStats.fileWrite( filePath, 'abc' );
// cachingStats.fileCopy( newPath, filePath );
// console.log( "cacheStats: ",cachingStats._cacheStats );

/* exchanging invokes stats updating */

// var newPath = _.pathJoin( dir, 'file.abc' );
// cachingStats.fileWrite( filePath, 'abc' );
// cachingStats.fileWrite( newPath, 'abcabc' );
// console.log( "cacheStats: ",cachingStats._cacheStats );
// cachingStats.fileExchange( newPath, filePath );
// console.log( "cacheStats: ",cachingStats._cacheStats );
