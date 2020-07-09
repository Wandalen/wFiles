if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileRename sync

// require( 'fs' ).writeFileSync( 'file.txt');
// files.fileRename( { dst : 'text1.txt', src : 'file.txt', sync : 1 } );

// files.directoryMake( { file : __dirname + '/test_folder', sync : 1, force : 1 } );
// files.fileRename( { dst : 'new_test_folder', src : 'test_folder', sync : 1 } );

// fileRename async

// require( 'fs' ).writeFileSync( 'file.txt');
// var con = files.fileRename( 'text1.txt', 'file.txt' );
// con.got( function( err )
// {
//   console.log( err );
// });
