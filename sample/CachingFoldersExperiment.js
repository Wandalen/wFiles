if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

/* making file tree cache */

var dir = _.pathDir( __dirname );
var tree = _.FileFilter.CachingFolders.filesTreeMake( dir );

var testDir = _.pathJoin( dir, 'sample/cachingFoldersSample' );
_.fileProvider.fileDelete( testDir );
var filePath = _.pathJoin( testDir, 'file.txt' );

/* writting to *.js file */

// var fileName = _.pathChangeExt( _.pathName( dir ), 'js' );
// var fileTreePath = _.pathJoin( dir, fileName );
//
// /* prepare data: rootPath and tree as json object */
// var data = 'var rootPath = ' + _.toStr( dir, { wrap : 1 } );
// data = data + '\nvar wFilesTree = \n' + _.toStr( tree, { json : 1 , multiline : 1 } );
//
// _.fileProvider.fileWrite( fileTreePath, data );
//
// console.log( 'Written to file: ', fileTreePath );

/* making filter*/

var filter = _.FileFilter.CachingFolders
({
  tree : tree,
  rootPath : dir
});

/* getting files list using absolute path */

var files = filter.directoryRead( dir );
console.log( dir + ": \n", files );

var files = filter.directoryRead( _.pathJoin( dir, 'staging/amid/file' ) );
console.log( "staging/amid/file: \n", files );

/* creating new file */

// filter.fileWrite( filePath, 'abc' );
// var files = filter.directoryRead( _.pathDir( filePath ) )
// console.log( files );

/* creating new dir */

// filter.fileDelete( testDir );
// filter.directoryMake( testDir );
// var files = filter.directoryRead( _.pathDir( testDir ) )
// console.log( files );

/* deleting file */

// filter.fileWrite( filePath, 'abc' );
// var files = filter.directoryRead( _.pathDir( filePath ) )
// console.log( files );
// filter.fileDelete( filePath );
// var files = filter.directoryRead( _.pathDir( filePath ) )
// console.log( files );

/* rename file */

// filter.fileWrite( filePath, 'abc' );
// var files = filter.directoryRead( testDir );
// console.log( files );
// filter.fileRename( _.pathJoin( testDir, 'file.js' ), filePath );
// var files = filter.directoryRead( testDir );
// console.log( files );

/* copying */

// filter.fileDelete( testDir );
// filter.fileWrite( filePath, 'abc' );
// var filePath2 = _.pathJoin( testDir, 'file.js' );
// filter.fileCopy( filePath2, filePath );
// var files = filter.directoryRead( testDir );
// console.log( files );

/* exchange files */

// filter.fileDelete( testDir );
// var path1 = _.pathJoin( testDir, 'dir1/file1.txt' );
// var path2 = _.pathJoin( testDir, 'dir2/file2.txt' );
// filter.fileWrite( path1, 'abc' )
// filter.fileWrite( path2, 'bca' )
// filter.fileExchange( _.pathDir( path1 ), _.pathDir( path2 ) );
// console.log( filter.tree[ 'sample' ] );
