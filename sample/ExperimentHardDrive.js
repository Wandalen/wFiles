if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )

}

var _ = wTools;

var files = _.FileProvider.HardDrive();


//fileCopy

require( 'fs' ).writeFileSync( 'file.txt');
files.fileCopy( { dst : 'text1.txt', src : 'file.txt', sync : 1 } );

// require( 'fs' ).writeFileSync( 'file.txt');
// var con = files.fileCopy( { dst : './tmp/text1.txt', src : 'file.txt'  } );
//
// con.got( function( err )
// {
//   if( err )
//   throw err;
// } )

//fileRename

//sync

// require( 'fs' ).writeFileSync( 'file.txt');
// files.fileRename( { dst : 'text1.txt', src : 'file.txt', sync : 1 } );

// files.directoryMake( { pathFile : __dirname + '/test_folder', sync : 1, force : 1 } );
// files.fileRename( { dst : 'new_test_folder', src : 'test_folder', sync : 1 } );

//async

// require( 'fs' ).writeFileSync( 'file.txt');
// var con = files.fileRename( 'text1.txt', 'file.txt' );

// con.got( function(err){
//   console.log( err );
// } );

//directoryMake

//sync

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

//async

// var con = files.directoryMake( { pathFile : __dirname + '/test/', sync : 0, force : 1 } );
//
// //replaces file with dir same name
// require( 'fs' ).writeFileSync( __dirname + '/test_folder/test.txt');
// var con = files.directoryMake( { pathFile : __dirname + '/test/test.txt/', sync : 0, force : 1 } );
//
// con.got( function(err){
//   console.log( err ); // false (file does not exist)
// } );
