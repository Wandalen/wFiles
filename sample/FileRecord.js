
if( typeof module !== 'undefined' )
{
  require( 'wFiles' );
  //require( '../staging/amid/file/Files.ss' );
}

var _ = wTools;

if( _.FileRecord )
{

  debugger;
  var fileRecord = wFileRecord( 'tmp' );
  //var fileRecord = wFileRecord( 'tmp/sample/FilesPathTest/tmp/pathCopy/test_original.txt' );

  console.log( 'fileRecord :',fileRecord );

}
