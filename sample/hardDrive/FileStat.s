if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileStat sync

// var stats = files.fileStat( 'my_dir' );
// if( stats )
// console.log( stats );

// fileStat async

// files.fileStat
// ({
//    file : 'my_dir',
//    throwing : 1,
//    sync : 0
// })
// .got( function( err, stats )
// {
//   if( err )
//   throw err;
//   console.log( stats );
// });
