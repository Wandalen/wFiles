if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
}

var _ = wTools;
var provider = _.FileProvider.BackUrl();

var url = 'http://github.com/Wandalen/wTools/archive/master.zip';
provider.fileCopyToHardDrive( url )
.got( function( err, data )
{
  if( err )
  throw err;
  else
  console.log( data );
});
