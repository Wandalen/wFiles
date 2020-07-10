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
      console.log( '\n' )

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

var testDir = _.path.join( __dirname, 'data/tmp.tmp' );
var testFile = _.path.join( testDir, 'FileStat.txt' );

//

function fileWriteTest( delay )
{
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.fileWrite( testFile, testFile );
  var ostats = _.fileProvider.statRead( testFile );

  waitSync( delay );

  _.fileProvider.fileWrite( { filePath : testFile, data : 'dasd', writeMode : 'rewrite'} );

  waitSync( delay );

  var stats = _.fileProvider.statRead( testFile );

  console.log( '\n' )

  var diff = stats.mtime.getTime() - ostats.mtime.getTime();
  delay = delay * 1000;

  console.log( 'new:', stats.mtime.getTime(), 'old:', ostats.mtime.getTime() )
  console.log( 'diff:', diff )
  console.log( 'delay:', delay )

  var ok = diff >= delay;

  if( !ok )
  ok = _.entityEquivalent( diff, delay, { eps : 20 } );

  if( !ok )
  {
    console.log( '\n--------------------\n' )
    console.log( 'new:', stats.mtime.getTime(), 'old:', ostats.mtime.getTime() )
    console.log( 'diff:', diff )
    console.log( 'delay:', delay )

    console.log( '\n--------------------\n' )

    showStats( ostats );
    showStats( stats, ostats );

    console.log( '\n--------------------\n' )

    throw _.err( 'Delay not working' )
  }

  c--;

  if( !c )
  clearInterval( interval )
}

var c = 25;

console.log( 'Running ', c, ' times' )

var range = [ 0.3, 0.5 ];

// var interval = setInterval( () =>
// {
//   fileWriteTest( range[ 0 ] + Math.random()*( range[ 1 ] - range[ 0 ] ) );
// }, 50 )
