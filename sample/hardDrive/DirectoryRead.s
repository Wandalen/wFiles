if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

//directoryRead sync

// var dir = files.directoryRead({ file : __dirname });
// console.log( dir );

// directoryRead async

// var con = files.directoryRead({ file : __dirname, sync : 0 });
// con.got( function( err, dir )
// {
//   if( err )
//   throw err;
//   console.log( dir );
// });
