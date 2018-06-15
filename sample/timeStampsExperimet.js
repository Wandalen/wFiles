
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var fs = require( 'fs' );

var file = _.pathJoin(  __dirname, 'file' );

_.fileProvider.fileWrite( file, file );

var fileNative = _.fileProvider.pathNativize( file );

var time = new Date( Date.now() );

var fd = fs.openSync( fileNative, 'w' );
fs.futimesSync( fd, time, time );

// _.fileProvider.fileTimeSet( __filename, time, time );
var stat = _.fileProvider.fileStat( fileNative );
console.log( time.getTime() )
console.log( stat.mtime.getTime() )
console.log( stat.mtime.getTime() - time.getTime() )