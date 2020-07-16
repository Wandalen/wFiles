
if( typeof module !== 'undefined' )
require( 'wFiles' )

let _ = wTools;

// var fs = require( 'fs' );

// var file = _.join(  __dirname, 'file' );

// _.fileProvider.fileWrite( file, file );

// var fileNative = _.fileProvider.nativize( file );

// var time = new Date( Date.now() );

// // var fd = fs.openSync( fileNative, 'w' );
// // fs.futimesSync( fd, time, time );

// // console.log( '\n------------------------\n' );

// // var stat = _.fileProvider.fileStat( fileNative );
// // console.log( time.getTime() )
// // console.log( stat.mtime.getTime() )
// // console.log( stat.mtime.getTime() - time.getTime() );


// console.log( '\n------------------------\n' );

// _.fileProvider.fileTimeSet( file, time, time );
// var stat = _.fileProvider.fileStat( fileNative );
// console.log( time.getTime() )
// console.log( stat.mtime.getTime() )
// console.log( stat.mtime.getTime() - time.getTime() );


var minDelay = _.fileProvider.systemBitrateTimeGet();
console.log( minDelay );
