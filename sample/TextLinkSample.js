
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var testDir = _.path.resolve( __dirname, './filesCopy' );

var dst = _.path.join( testDir, 'dst' );
var src = _.path.join( testDir, 'src' );

var filePathDst = _.path.join( dst + '2', 'file.dst' );
var filePathSrc = _.path.join( src, 'file.src' );

var o =
{
  rewriting : 1,
  rewritingDirs : 1,
  srcPath : filePathSrc,
  dstPath : filePathDst,
  resolvingSrcTextLink : 1,
  resolvingDstTextLink : 1,
}

//cleanup
_.fileProvider.filesDelete( testDir );
//making src : dir with file
_.fileProvider.fileWrite( filePathSrc, filePathSrc );
//making dst : dir with file
_.fileProvider.fileWrite( filePathDst, filePathDst );
//making text link to dst
_.fileProvider.fileWrite( o.dstPath, 'link ' + dst + '2' );

_.fileProvider.fileCopy( o );

console.log( _.fileProvider.fileRead( filePathDst ) );

_.fileProvider.filesDelete( testDir );

