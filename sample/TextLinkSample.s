if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var testDir = `${__dirname}/data/tmp.tmp`;

var dst = _.path.join( testDir, 'dst' );
var src = _.path.join( testDir, 'src' );

var filePathDst = _.path.join( dst, 'FileDst.txt' );
var filePathSrc = _.path.join( src, 'FileSrc.txt' );

var o =
{
  allowDelete : 1,
  allowWrite : 1,
  allowRewrite : 1,
  allowRewriteFileByDir : 1,
  recursive : 1,
  srcPath : src,
  dstPath : dst,
  resolvingTextLink : 1
}

// cleanup
_.fileProvider.filesDelete( testDir );

// making src : dir with file
_.fileProvider.fileWrite( filePathSrc, filePathSrc );

// making dst : dir with file
_.fileProvider.fileWrite( filePathDst, filePathDst );
debugger;
// making text link to dst
_.fileProvider.fileWrite( o.dstPath, 'link ' + dst + '2' );

_.fileProvider.fileCopy( o );
