if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )

}

var _ = wTools;

var files = _.FileProvider.HardDrive();

//read

//fileRead sync

// var data = files.fileRead
// ({
//   pathFile : 'my_file',
//   sync : 1
// });
// console.log( data );

//fileRead async

// files.fileRead({ pathFile : 'my_file' })
// .got( function( err, data )
// {
//   if( err )
//   throw err;
//   console.log( data );
// });

//directoryRead sync

// var dir = files.directoryRead({ pathFile : __dirname });
// console.log( dir );

//directoryRead async

// var con = files.directoryRead({ pathFile : __dirname, sync : 0 });
// con.got( function( err, dir )
// {
//   if( err )
//   throw err;
//   console.log( dir );
// });

//fileStat sync

// var stats = files.fileStat( 'my_dir' );
// if( stats )
// console.log( stats );

//fileStat async

// files.fileStat
// ({
//    pathFile : 'my_dir',
//    throwing : 1,
//    sync : 0
// })
// .got( function( err, stats )
// {
//   if( err )
//   throw err;
//   console.log( stats );
// });

//write

//fileWrite sync

// files.fileWrite
// ({
//   pathFile : 'my_file',
//   data : 'some data'
// });

//fileWrite async

// files.fileWrite
// ({
//   pathFile : 'my_file',
//   data : 'some data',
//   sync : 0
// })
// .got( function( err )
// {
//   if( err )
//   throw err;
//   console.log( 'Success' );
// });

//fileCopy sync

// require( 'fs' ).writeFileSync( 'file.txt');
// files.fileCopy( { dst : 'text1.txt', src : 'file.txt', sync : 1 } );

//fileCopy async

// require( 'fs' ).writeFileSync( 'file.txt');
// var con = files.fileCopy( { dst : './tmp/text1.txt', src : 'file.txt'  } );
//
// con.got( function( err )
// {
//   if( err )
//   throw err;
// } )

//fileRename sync

// require( 'fs' ).writeFileSync( 'file.txt');
// files.fileRename( { dst : 'text1.txt', src : 'file.txt', sync : 1 } );

// files.directoryMake( { pathFile : __dirname + '/test_folder', sync : 1, force : 1 } );
// files.fileRename( { dst : 'new_test_folder', src : 'test_folder', sync : 1 } );

//fileRename async

// require( 'fs' ).writeFileSync( 'file.txt');
// var con = files.fileRename( 'text1.txt', 'file.txt' );
// con.got( function( err )
// {
//   console.log( err );
// });

//directoryMake sync

// files.directoryMake( { pathFile : __dirname + '/test_folder', sync : 1, force : 1 } );

//no structure same with path throws error
// files.directoryMake( { pathFile : __dirname + '/test_folder/inner_folder/folder/', sync : 1, force : 1 } );

//replaces file with dir same name
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/file.txt');
// files.directoryMake( { pathFile : __dirname + '/test_folder/file.txt', sync : 1, force : 1 } );


//dir exists throws error
// files.directoryMake( { pathFile : __dirname + 'test_folder', sync : 1, force : 1 } );

//throws error, force 0 cant replace file with dir
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/file.txt');
// files.directoryMake( { pathFile : __dirname + 'test_folder/file.txt', sync : 1, force : 0 } );

//directoryMake async

// var con = files.directoryMake( { pathFile : __dirname + '/test/', sync : 0, force : 1 } );
//
// //replaces file with dir same name
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/test.txt');
// var con = files.directoryMake( { pathFile : __dirname + '/test/test.txt/', sync : 0, force : 1 } );
//
// con.got( function( err )
// {
//   console.log( err ); // false (file does not exist)
// });
