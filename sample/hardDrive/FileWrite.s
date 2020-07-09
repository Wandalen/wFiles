if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileWrite sync

// files.fileWrite
// ({
//   file : 'my_file',
//   data : 'some data'
// });

// fileWrite async

// files.fileWrite
// ({
//   file : 'my_file',
//   data : 'some data',
//   sync : 0
// })
// .got( function( err )
// {
//   if( err )
//   throw err;
//   console.log( 'Success' );
// });
