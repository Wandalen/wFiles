
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var dir = _.path.join( __dirname, '../proto/node_modules/Tools' );
var o =
{
  defaultProvider : _.fileProvider,
  filter : null,
  allowingMissed : 1,
};
var factory = _.FileRecordFactory.TolerantFrom( o, { dirPath : dir } ).form();

if( _.FileRecord )
{

  //var fileRecord = wFileRecord( 'tmp' );
  //var fileRecord = wFileRecord( 'tmp/sample/FilesPathTest/tmp/copy/test_original.txt' );

  // var f1 = wFileRecord({ dir : _.baseDir(), file : '../proto/dwtools/amid/l4_files/Uses.ss' });
  // var f2 = wFileRecord({ dir : _.baseDir(), file : '../proto/amid/l4_files/Uses.ss' });
  var f1 = _.FileRecord({ input : dir, factory });
  var f2 = _.FileRecord({ input : dir, factory });
  var filesSame = _.fileProvider.filesAreSameForSure( f1, f2 );
  console.log( 'filesSame :', filesSame );

}

/* qqq : rewrite samples */
