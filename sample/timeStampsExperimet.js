
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var time = new Date( Date.now() );
_.fileProvider.fileTimeSet( __filename, time, time );
var stat = _.fileProvider.fileStat( __filename );
console.log( time.getTime() )
console.log( stat.mtime.getTime() )
console.log( stat.mtime.getTime() - time.getTime() )