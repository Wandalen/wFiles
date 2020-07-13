if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var testDir = `${__dirname}/data/tmp.tmp`;

var dst = _.path.join( testDir, 'dst' );
var src = _.path.join( testDir, 'src' );

var filePathDst = _.path.join( dst, 'FileDst.txt' );
var filePathSrc = _.path.join( src, 'FileSrc.txt' );

_.fileProvider.usingTextLink = true;

// cleanup
_.fileProvider.filesDelete( testDir );

// making src : dir with file
_.fileProvider.fileWrite( filePathSrc, filePathSrc );

// making dst : dir with file
_.fileProvider.fileWrite( filePathDst, filePathDst );

// making text link to dst
_.fileProvider.fileWrite( filePathDst, 'link ' + dst + '2' );
var link = _.fileProvider.fileRead({ filePath : filePathDst});
console.log( link );
