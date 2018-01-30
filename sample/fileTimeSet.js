
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var filePath = _.pathJoin( __dirname, 'file' );

_.fileProvider.fileWrite( filePath, 'data' );

var statBefore = _.fileProvider.fileStat( filePath );

_.fileProvider.fileTimeSet( filePath, statBefore.atime, statBefore.mtime );

var statAfter = _.fileProvider.fileStat( filePath );

var mtimeIdentical =  statAfter.mtime.getTime() === statBefore.mtime.getTime();
_.EPS = 500;
var mtimeEquivalent =  _.numbersAreEquivalent( statAfter.mtime.getTime(),statBefore.mtime.getTime() )

console.log( "mtimeIdentical: ", mtimeIdentical )
console.log( "mtimeEquivalent: ", mtimeEquivalent )
console.log( "statAfter.mtime: ", statAfter.mtime.getTime() )
console.log( "statBefore: ", statBefore.mtime.getTime() )

debugger
