if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

/* making file tree cache */
var dir = _.pathDir( __dirname );
var tree = _.FileFilter.CachingFolders.filesTree( dir );

/* writting to file */
var fileName = _.pathChangeExt( _.pathName( dir ), 'js' );
var filePath = _.pathJoin( dir, fileName );
_.fileProvider.fileWrite
(
  filePath,
  _.toStr( tree, { json : 1 , multiline : 1 } )
);

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
