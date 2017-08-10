require( 'wTools' );
require( '../staging/amid/file/FileMid.s' );

var _ = wTools;
var testDir = _.pathResolve( __dirname, '../tmp.tmp/filesCopy' );
var pathDst, pathSrc;

pathDst = _.pathJoin( testDir, 'dst' );
pathSrc = _.pathJoin( testDir, 'src' );

var filePathDst = _.pathJoin( pathDst + '2', 'file.dst' );
var filePathSrc = _.pathJoin( pathSrc, 'file.src' );

var o =
{
  allowDelete : 1,
  allowWrite : 1,
  allowRewrite : 1,
  allowRewriteFileByDir : 1,
  recursive : 1,
  src : pathSrc,
  dst : pathDst,
  resolvingTextLink : 1
}

//cleanup
_.fileProvider.fileDelete( testDir );
//making src : dir with file
_.fileProvider.fileWrite( filePathSrc, filePathSrc );
//making dst : dir with file
_.fileProvider.fileWrite( filePathDst, filePathDst );
//making text link to dst
_.fileProvider.fileWrite( o.dst, 'link ' + pathDst + '2' );

_.fileProvider.filesCopy( o );
