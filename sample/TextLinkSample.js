
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var testDir = _.resolve( __dirname, '../tmp.tmp/filesCopy' );
var dst, src;

dst = _.join( testDir, 'dst' );
src = _.join( testDir, 'src' );

var filePathDst = _.join( dst + '2', 'file.dst' );
var filePathSrc = _.join( src, 'file.src' );

var o =
{
  allowDelete : 1,
  allowWrite : 1,
  allowRewrite : 1,
  allowRewriteFileByDir : 1,
  recursive : 1,
  src : src,
  dst : dst,
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

_.fileProvider.filesCopy( o );
