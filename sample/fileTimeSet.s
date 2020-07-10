
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var filePath = _.path.join( __dirname, 'data/tmp.tmp/FileTimeSet.txt' );

_.fileProvider.fileWrite( { filePath, data : 'data', makingDirectory : 1 } );

var statBefore = _.fileProvider.statRead( filePath );

_.fileProvider.timeWrite( filePath, statBefore.atime, statBefore.mtime );

var statAfter = _.fileProvider.statRead( filePath );

var mtimeIdentical =  statAfter.mtime.getTime() === statBefore.mtime.getTime();
_.EPS = 500;
var mtimeEquivalent =  _.numbersAreEquivalent( statAfter.mtime.getTime(), statBefore.mtime.getTime() )

console.log( 'mtimeIdentical: ', mtimeIdentical )
console.log( 'mtimeEquivalent: ', mtimeEquivalent )
console.log( 'statAfter.mtime: ', statAfter.mtime.getTime() )
console.log( 'statBefore: ', statBefore.mtime.getTime() )

var path = _.path.join( __dirname, 'data' );
var time = new Date( 1529332034399 )
console.log( 'time: ', time.getTime() )
_.fileProvider.timeWrite( path, time, time )

var r = _.fileProvider.statRead( path )
console.log( 'atime: ', r.atime.getTime() )
console.log( 'mtime: ', r.mtime.getTime() )
