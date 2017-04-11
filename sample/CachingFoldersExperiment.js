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

/* writting to *.js file */
var fileName = _.pathChangeExt( _.pathName( dir ), 'js' );
var filePath = _.pathJoin( dir, fileName );

/* prepare data: rootPath and tree as json object */
var data = 'var rootPath = ' + _.toStr( dir, { wrap : 1 } );
data = data + '\nvar wFilesTree = \n' + _.toStr( tree, { json : 1 , multiline : 1 } );

_.fileProvider.fileWrite( filePath, data );

console.log( 'Written to file: ', filePath );

/* making filter*/
var filter = _.FileFilter.CachingFolders
({
  tree : tree,
  rootPath : dir
});

/* getting files list using absolute path */
var files = filter.directoryRead( dir );
console.log( files );

var files = filter.directoryRead( _.pathJoin( dir, 'staging/amid/file' ) );
console.log( files );

/* creating new file */

filter.fileWrite( _.pathJoin( dir, '1.txt' ), 'abc' );
var files = filter.directoryRead( dir );
console.log( files );

/* deleting file */

filter.fileDelete( _.pathJoin( dir, '1.txt' ) );
var files = filter.directoryRead( dir );
console.log( files );
