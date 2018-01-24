if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var filePath = _.pathJoin( __dirname, 'file' );

_.fileProvider.fileWrite( filePath, 'data' );

var newMtime = new Date( 1516791641389 );
var newAtime = new Date( 1516791641389 );

_.fileProvider.fileTimeSet( filePath, newAtime, newMtime );

var statAfter = _.fileProvider.fileStat( filePath );

var mtimeIdentical =  statAfter.mtime.getTime() === newMtime.getTime();
_.EPS = 500;
var mtimeEquivalent =  _.numbersAreEquivalent( statAfter.mtime.getTime(),newMtime.getTime() )

console.log( "mtimeIdentical: ", mtimeIdentical )
console.log( "mtimeEquivalent: ", mtimeEquivalent )
console.log( "statAfter.mtime: ", statAfter.mtime.getTime() )
console.log( "newMtime: ", newMtime.getTime() )

debugger
