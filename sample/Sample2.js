
if( typeof module !== 'undefined' )
{
  //require( 'wFiles' );
  require( '../staging/amid/file/Files.ss' );
}

var _ = wTools;

if( _.FileRecord )
{

  debugger;

  //var fileRecord = wFileRecord( 'tmp' );
  //var fileRecord = wFileRecord( 'tmp/sample/FilesPathTest/tmp/pathCopy/test_original.txt' );

  var f1 = wFileRecord({ dir : _.pathBaseDir(), pathFile : '../staging/amid/file/Files.ss' });
  var f2 = wFileRecord({ dir : _.pathBaseDir(), pathFile : '../proto/amid/file/Files.ss' });
  var filesSame = _.filesSame( f1,f2 );
  console.log( 'filesSame :',filesSame );

}
