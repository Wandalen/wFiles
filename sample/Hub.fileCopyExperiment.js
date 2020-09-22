
if( typeof module !== 'undefined' )
require( 'wFiles' )

let _ = wTools;

let hub = new _.FileProvider.Hub
({
  verbosity : 2,
  providers : [],
});

hub.providerRegister( new _.FileProvider.Extract({ protocol : 'src'  }) );
hub.providerRegister( new _.FileProvider.HardDrive({ protocol : 'dst' }) );

var srcPath = 'src:///file';
var dstPath = _.uri.join( 'dst://', __dirname, 'file' );

var data = '\xA9\xA9';
console.log( 'string chars: ', data.length );

hub.fileWrite( srcPath, data );
hub.fileCopy( dstPath, srcPath );

var srcStat = hub.fileStat( srcPath );
var dstStat = hub.fileStat( dstPath );

// problem : extract calculates size as length of the string
// 2 chars, extract : 2 bytes, hd : 4 bytes

console.log( 'srcFile.size:', srcStat.size );
console.log( 'dstFile.size:', dstStat.size );

//encoding is not a problem, files are same

var srcFile = hub.fileRead( srcPath );
var dstFile = hub.fileRead( dstPath );
console.log( 'srcFile.length:', srcFile.length )
console.log( 'dstFile.length:', dstFile.length  )
console.log( 'Diff: ', _.entityDiff( srcFile, dstFile ) )

