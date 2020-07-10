if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var testDir = `${__dirname}/tmp.tmp/textLinkSample`;

var dst = _.path.s.join( testDir, 'dst' );
var src = _.path.s.join( testDir, 'src' );

var filePathDst = _.path.s.join( dst + '2', 'file.dst' );
var filePathSrc = _.path.s.join( src, 'file.src' );

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

//cleanup
_.fileProvider.fileDelete( testDir );

//making src : dir with file
_.fileProvider.fileWrite( filePathSrc, filePathSrc );

//making dst : dir with file
_.fileProvider.fileWrite( filePathDst, filePathDst );

//making text link to dst
_.fileProvider.fileWrite( o.dst, 'link ' + dst + '2' );

_.fileProvider.fileCopy( o );
