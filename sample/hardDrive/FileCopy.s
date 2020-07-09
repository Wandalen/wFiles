if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileCopy sync

// require( 'fs' ).writeFileSync( 'file.txt');
// files.fileCopy( { dst : 'text1.txt', src : 'file.txt', sync : 1 } );

// fileCopy async

// require( 'fs' ).writeFileSync( 'file.txt');
// var con = files.fileCopy( { dst : './tmp/text1.txt', src : 'file.txt'  } );
//
// con.got( function( err )
// {
//   if( err )
//   throw err;
// } )
