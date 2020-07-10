
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var file1 = '';
var file2 = '';

if( _.FileRecord )
{
  var f1 = _.fileProvider.record({ dir : __dirname, file : '../proto/wtools/amid/l4_files/Uses.ss' });
  var f2 = _.fileProvider.record({ dir : __dirname, file : '../proto/amid/l4_files/Uses.ss' });
  var filesSame = _.filesSame( f1, f2 );
  console.log( 'filesSame :', filesSame );
}

/* qqq : rewrite samples */
