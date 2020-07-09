
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

if( _.FileRecord )
{

  debugger;

  //var fileRecord = wFileRecord( 'tmp' );
  //var fileRecord = wFileRecord( 'tmp/sample/FilesPathTest/tmp/copy/test_original.txt' );


  var f1 = wFileRecord({ dir : _.baseDir(), file : '../proto/wtools/amid/l4_files/Uses.ss' });
  var f2 = wFileRecord({ dir : _.baseDir(), file : '../proto/amid/l4_files/Uses.ss' });
  var filesSame = _.filesSame( f1,f2 );
  console.log( 'filesSame :',filesSame );

}

/* qqq : rewrite samples */
