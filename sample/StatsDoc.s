
if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var waitSync = require( 'wait-sync' );

function showStats( s, o )
{
  console.log( '\nstats.atime: ', s.atime );
  console.log( 'stats.atime: ', s.atime.getTime() );

  console.log( '\nstats.mtime: ', s.mtime );
  console.log( 'stats.mtime: ', s.mtime.getTime() );

  console.log( '\nstats.ctime: ', s.ctime );
  console.log( 'stats.ctime: ', s.ctime.getTime() );

  console.log( '\nstats.birthtime: ', s.birthtime );
  console.log( 'stats.birthtime: ', s.birthtime.getTime() );

  if( o )
  {
    console.log( '\n' );

    if( s.atime.getTime() !== o.atime.getTime() )
    console.log( '   atime changed' );

    if( s.mtime.getTime() !== o.mtime.getTime() )
    console.log( '   mtime changed' );

    if( s.ctime.getTime() !== o.ctime.getTime() )
    console.log( '   ctime changed' );

    if( s.birthtime.getTime() !== o.birthtime.getTime() )
    console.log( '   birthtime changed' );
  }
}

var testDir = _.path.join( __dirname, 'statsDoc' );
var testFile = _.path.join( testDir, 'file' );

//

console.log( '\n\n' )

//

console.log( '\n--> Reading:' );
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );

console.log( '\n----> Stats of the file before read:' )
var ostats = _.fileProvider.statRead( testFile );
showStats( ostats );

console.log( '\n----> After read with no delay :' );
_.fileProvider.fileRead( testFile );
var stats = _.fileProvider.statRead( testFile );
showStats( stats, ostats );

console.log( '\n----> After read with 10ms delay :' );
waitSync( 0.01 );
_.fileProvider.fileRead( testFile );
var stats = _.fileProvider.statRead( testFile );
showStats( stats, ostats );

console.log( '\n----> After read with 1000ms delay :' );
waitSync( 1 );
_.fileProvider.fileRead( testFile );
var stats = _.fileProvider.statRead( testFile );
showStats( stats, ostats );

//

console.log( '\n--> Content changed:' )
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );

console.log( '\n----> Stats of the file before content change:' )
var ostats = _.fileProvider.statRead( testFile );
showStats( ostats );

_.fileProvider.fileWrite( testFile, testFile + testFile );

console.log( '\n----> Stats of the file after content change, without delay:' )
var stats = _.fileProvider.statRead( testFile );
showStats( stats, ostats );

console.log( '\n----> Stats of the file after content change, with 10 ms delay:' )
waitSync( 0.01 )
_.fileProvider.fileWrite( testFile, 'dasd' );
var stats = _.fileProvider.statRead( testFile );
showStats( stats, ostats );

//

console.log( '\n--> Creating two files with sync delay 10ms between fileWrite calls:' )
_.fileProvider.filesDelete( testDir );
console.log( '\n----> Current time:' )
var timeNow = new Date( Date.now() );
console.log( 'timeNow: ', timeNow );
console.log( 'timeNow.getTime:', timeNow.getTime() );

for( var i = 0; i < 2; i++ )
{
  var filePath = _.path.join( testDir, 'file' + i );
  waitSync( 0.010 );
  _.fileProvider.fileWrite( filePath, filePath );
  var statsN = _.fileProvider.statRead( filePath );
  console.log( '\n----> Stats of the file #' + i + ':' );
  showStats( statsN );
}

//

console.log( '\n--> Copy file, rewriting dst:' )

var testFile2 = _.path.join( testDir, 'file2' );
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, 'abc' );
waitSync( 0.1 )
_.fileProvider.fileWrite( testFile2, 'cda' );

console.log( '\n----> Stats of src before copy:' )
var ostatsSrc = _.fileProvider.statRead( testFile );
showStats( ostatsSrc );

console.log( '\n----> Stats of dst before copy:' )
var ostatsDst = _.fileProvider.statRead( testFile2 );
showStats( ostatsDst );

waitSync( 0.01 )

var fs = require( 'fs' )
fs.copyFileSync( _.fileProvider.path.nativize( testFile ), _.fileProvider.path.nativize( testFile2 ) );

console.log( '\n----> Stats of src after copy:' )
var stats = _.fileProvider.statRead( testFile );
showStats( stats, ostatsSrc );

console.log( '\n----> Stats of dst after copy:' )
var stats = _.fileProvider.statRead( testFile2 );
showStats( stats, ostatsDst );

//

console.log( '\n--> Changing atime/mtime:' );
_.fileProvider.filesDelete( testDir );
_.fileProvider.fileWrite( testFile, testFile );

console.log( '\n----> Stats of the file before changes:' )
var ostats = _.fileProvider.statRead( testFile );
showStats( ostats );

console.log( '\n----> Setting same atime/mtime to check precision:' );
_.fileProvider.timeWriteAct({ filePath : testFile, atime : stats.atime, mtime : stats.mtime });
var stats1 = _.fileProvider.statRead( testFile );
showStats( stats1, ostats );

console.log( '\n-----> Diff atime:' );
console.log( stats1.atime.getTime() - stats.atime.getTime() )
console.log( '\n-----> Diff mtime:' );
console.log( stats1.mtime.getTime() - stats.mtime.getTime() )

console.log( '\n----> Adding 10ms to original atime/mtime:' );
var atime = new Date( stats.atime.getTime() + 10 )
var mtime = new Date( stats.mtime.getTime() + 10 )

_.fileProvider.timeWriteAct({ filePath : testFile, atime, mtime });
var stats2 = _.fileProvider.statRead( testFile );
showStats( stats2, ostats );

console.log( '\n-----> Diff atime:' );
console.log( stats2.atime.getTime() - stats.atime.getTime() )
console.log( '\n-----> Diff mtime:' );
console.log( stats2.mtime.getTime() - stats.mtime.getTime() )

console.log( '\n----> Adding 100ms to original atime/mtime:' );
var atime = new Date( stats.atime.getTime() + 100 )
var mtime = new Date( stats.mtime.getTime() + 100 )

_.fileProvider.timeWriteAct({ filePath : testFile, atime, mtime });
var stats2 = _.fileProvider.statRead( testFile );
showStats( stats2, ostats );

console.log( '\n-----> Diff atime:' );
console.log( stats2.atime.getTime() - stats.atime.getTime() )
console.log( '\n-----> Diff mtime:' );
console.log( stats2.mtime.getTime() - stats.mtime.getTime() )

console.log( '\n----> Adding 1000ms to original atime/mtime:' );
var atime = new Date( stats.atime.getTime() + 1000 )
var mtime = new Date( stats.mtime.getTime() + 1000 )

_.fileProvider.timeWriteAct({ filePath : testFile, atime, mtime });
var stats2 = _.fileProvider.statRead( testFile );
showStats( stats2, ostats );

console.log( '\n-----> Diff atime:' );
console.log( stats2.atime.getTime() - stats.atime.getTime() )
console.log( '\n-----> Diff mtime:' );
console.log( stats2.mtime.getTime() - stats.mtime.getTime() )

_.fileProvider.filesDelete( testDir );

