if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// directoryMake sync

// files.directoryMake( { file : __dirname + '/test_folder', sync : 1, force : 1 } );

// no structure same with path throws error
// files.directoryMake( { file : __dirname + '/test_folder/inner_folder/folder/', sync : 1, force : 1 } );

// replaces file with dir same name
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/file.txt');
// files.directoryMake( { file : __dirname + '/test_folder/file.txt', sync : 1, force : 1 } );


// dir exists throws error
// files.directoryMake( { file : __dirname + 'test_folder', sync : 1, force : 1 } );

// throws error, force 0 cant replace file with dir
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/file.txt');
// files.directoryMake( { file : __dirname + 'test_folder/file.txt', sync : 1, force : 0 } );

// directoryMake async

// var con = files.directoryMake( { file : __dirname + '/test/', sync : 0, force : 1 } );
//
// //replaces file with dir same name
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/test.txt');
// var con = files.directoryMake( { file : __dirname + '/test/test.txt/', sync : 0, force : 1 } );
//
// con.got( function( err )
// {
//   console.log( err ); // false (file does not exist)
// });
