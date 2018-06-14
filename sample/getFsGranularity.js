if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;
var waitSync = require( 'wait-sync' );

var testFile = _.pathJoin( __dirname, 'testFile' );

//

var delay;
var delays = [ 0.01, 0.05, 0.1, 0.5, 1 ];

for( var i = 0; i < delays.length; i++ )
{
    delay = delays[ i ];
    _.fileProvider.fileWrite( testFile, 'a' );
    var stat1 = _.fileProvider.fileStat( testFile );
    waitSync( delay );
    _.fileProvider.fileWrite( testFile, 'b' );
    var stat2 = _.fileProvider.fileStat( testFile );
    console.log( stat1.mtime.getTime() )
    console.log( stat2.mtime.getTime() )
    var diff = stat2.mtime.getTime() - stat1.mtime.getTime();
    if( diff >= delay * 1000 )
    {
       break;
    }
}

console.log( delay )




