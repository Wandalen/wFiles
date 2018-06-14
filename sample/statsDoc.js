
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var waitSync = require( 'wait-sync' );

function showStats( s )
{
    console.log( '\nstats.atime: ', s.atime );
    console.log( 'stats.atime: ', s.atime.getTime() );

    console.log( '\nstats.mtime: ', s.mtime );
    console.log( 'stats.mtime: ', s.mtime.getTime() );

    console.log( '\nstats.ctime: ', s.ctime );
    console.log( 'stats.ctime: ', s.ctime.getTime() );

    console.log( '\nstats.birthtime: ', s.birthtime );
    console.log( 'stats.birthtime: ', s.birthtime.getTime() );
}

var testDir = _.pathJoin( __dirname, 'statsDoc' );
var testFile = _.pathJoin( testDir, 'file' );

//

console.log( '\n\n' )

//

console.log( "\n--> Reading:" );
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );

console.log( "\n----> Stats of the file before read:" )
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> After read with no delay :" );
_.fileProvider.fileRead( testFile );
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> After read with 10ms delay :" );
waitSync( 0.01 );
_.fileProvider.fileRead( testFile );
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> After read with 1000ms delay :" );
waitSync( 1 );
_.fileProvider.fileRead( testFile );
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

//

console.log( "\n--> Content changed:" )
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );

console.log( "\n----> Stats of the file before content change:" )
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

_.fileProvider.fileWrite( testFile, testFile + testFile );

console.log( "\n----> Stats of the file after content change, without delay:" )
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> Stats of the file after content change, with 10 ms delay:" )
waitSync( 0.01 )
_.fileProvider.fileWrite( testFile, 'dasd' );
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

//

console.log( "\n--> Creating two files with sync delay 10ms between fileWrite calls:" )
_.fileProvider.filesDelete( testDir );
console.log( "\n----> Current time:" )
var timeNow = new Date( Date.now() );
console.log( "timeNow: ", timeNow );
console.log( "timeNow.getTime:", timeNow.getTime() );

for( var i = 0; i < 2; i++ )
{
    var filePath = _.pathJoin( testDir, 'file' + i );
    waitSync( 0.010 );
    _.fileProvider.fileWrite( filePath, filePath );
    var stats = _.fileProvider.fileStat( filePath );
    console.log( "\n----> Stats of the file #" + i + ':' );
    showStats( stats );
}

//

console.log( "\n--> Copy file, rewriting dst:" )

var testFile2 = _.pathJoin( testDir, 'file2' );
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );
_.fileProvider.fileWrite( testFile2, testFile2 );

console.log( "\n----> Stats of src before copy:" )
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> Stats of dst before copy:" )
var stats = _.fileProvider.fileStat( testFile2 );
showStats( stats );

_.fileProvider.fileCopy( testFile2, testFile );

console.log( "\n----> Stats of src after copy:" )
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> Stats of dst after copy:" )
var stats = _.fileProvider.fileStat( testFile2 );
showStats( stats );

//

console.log( "\n--> Changing atime/mtime:" );
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );

console.log( "\n----> Stats of the file before changes:" )
var stats = _.fileProvider.fileStat( testFile );
showStats( stats );

console.log( "\n----> Setting same atime/mtime to check precision:" );
_.fileProvider.fileTimeSet( testFile, stats.atime, stats.mtime );
var stats1 = _.fileProvider.fileStat( testFile );
showStats( stats1 );

console.log( "\n----> Diff atime:" );
console.log( stats1.atime.getTime() - stats.atime.getTime() )
console.log( "\n----> Diff mtime:" );
console.log( stats1.mtime.getTime() - stats.mtime.getTime() )

console.log( "\n----> Adding 1 second to original atime/mtime:" );
var atime = new Date( stats.atime.getTime() + 1000 )
var mtime = new Date( stats.mtime.getTime() + 1000 )

_.fileProvider.fileTimeSet( testFile, atime, mtime );
var stats2 = _.fileProvider.fileStat( testFile );
showStats( stats2 );

console.log( "\n----> Diff atime:" );
console.log( stats2.atime.getTime() - stats.atime.getTime() )
console.log( "\n----> Diff mtime:" );
console.log( stats2.mtime.getTime() - stats.mtime.getTime() )

