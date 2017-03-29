if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/FileBase.s' )
  require( '../staging/amid/file/FileMid.s' )
}

var _ = wTools;

var filter = _.FileFilter.CachingFolders();
filter.cache( _.pathDir( __dirname ) );
var res = filter.directoryRead( _.pathRealMainDir() );
console.log(res);

var res = filter.directoryRead( _.pathRelative( './', _.pathRealMainDir() ));
console.log(res);

// var res = filter.directoryRead({ filePath : _.pathRealMainDir() });
// console.log(res);
