if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

var filePath = _.pathDir( __dirname );
var treePath = _.FileFilter.CachingFolders.filesTree( _.pathDir( __dirname ) );
var tree = _.fileProvider.fileRead
({
  filePath : treePath,
  encoding : 'json'
});
var filter = _.FileFilter.CachingFolders
({
  tree : tree,
  rootPath : filePath
});

var files = filter.directoryRead( filePath );
console.log( files );
