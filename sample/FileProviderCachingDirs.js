if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

var cachingDirs = _.FileFilter.Caching();

var dir = _.pathJoin( _.pathDir( _.pathRealMainFile() ), 'cachingDirsSample' );
_.fileProvider.fileDelete( dir );
var filePath = _.pathJoin( dir, 'file.txt' );

/* new file */

// _.fileProvider.fileWrite( filePath, 'abc' );
// var files = cachingDirs.directoryRead( _.pathDir( _.pathRealMainFile() ) );
// var files = cachingDirs.directoryRead( filePath );
// console.log( cachingDirs._cacheDir );

/* delete */

// cachingDirs.fileWrite( filePath, 'abc' );
// cachingDirs.fileDelete( filePath );
// var files = cachingDirs.directoryRead( dir );
// console.log( files );

/* new dir */

// cachingDirs.directoryMake( filePath );
// var files = cachingDirs.directoryRead( dir );
// console.log( files );

/* rename */

// cachingDirs.fileWrite( filePath, 'abc' );
// cachingDirs.fileRename( _.pathJoin( dir, 'file.js' ), dir );
// console.log( cachingDirs._cacheDir );

/* copy */

cachingDirs.fileWrite( filePath, 'abc' );
cachingDirs.fileCopy( _.pathJoin( dir, 'file.js' ), filePath );
console.log( cachingDirs._cacheDir );
