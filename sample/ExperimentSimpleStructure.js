if( typeof module !== 'undefined' )
{
  // require( '../../wTools/staging/abase/wTools.s' )
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
  require( '../staging/amid/file/provider/FileProviderSimpleStructure.s' )

}

var _ = wTools;

var tree =
{
 "folder.abc" :
 {
   'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
   'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   'folder2.x' :
   {
     'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   }
 }
}

var files = _.FileProvider.SimpleStructure( { filesTree : tree } );

//read

//fileRead sync

// var data = files.fileRead( { pathFile : '/folder.abc/folder2.x/test1.txt', sync : 1 } );
// console.log('\nfiles.fileRead, syncronous : \n', data );

//fileRead async

// var con = files.fileRead( { pathFile : '/folder.abc/folder2.x/test1.txt' } );
// con.doThen( function( err,data )
// {
//   console.log( '\nfiles.fileRead :' );
//   if( err )
//   throw _.err( err );
//   else
//   console.log( data );
// });


//fileStat sync

// var stats = files.fileStat( 'folder.abc' );
// if( stats )
// console.log( stats );

//fileStat async

// files.fileStat
// ({
//    pathFile : 'folder.abc',
//    throwing : 1,
//    sync : 0
// })
// .got( function( err, stats )
// {
//   if( err )
//   throw err;
//   console.log( stats );
// });

// directoryRead sync

// var dir = files.directoryRead({ pathFile : 'folder.abc' });
// console.log( dir );

//directoryRead async

// var con = files.directoryRead({ pathFile : 'folder.abc', sync : 0 });
// con.got( function( err, dir )
// {
//   if( err )
//   throw err;
//   console.log( dir );
// });

// write

//fileCopy sync

// files.fileCopy(  '/folder/test1.txt','/folder.abc/folder2.x/test1.txt' );
// console.log( '\nfiles.fileCopy: \n',files._tree );

//fileCopy async

// var con = files.fileCopy( { dst : '/folder.abc/test1.txt',src : '/folder.abc/folder2.x/test1.txt' , sync : 0  } );
// con.got( function ( err )
// { if(err)
//   throw err;
//   console.log( '\nfiles.fileCopy: \n',files._tree );
// } )

//fileRename sync

// files.fileRename( { dst : '/folder.abc/test2.js', src : '/folder.abc/test2.js', sync : 1 } );
// console.log( '\nfiles.fileCopy: \n',files._tree );

//fileRename async

// var con = files.fileRename( { dst : '/folder.abc/test2.js', src : '/folder.abc/test1.js' } );
// con.got( function ( err )
// { if(err)
//   throw err;
//   console.log( '\nfiles.fileRename: \n',files._tree );
// } )
//

//directoryMake sync

// files.directoryMake( { pathFile : '/folder.abc/folder2.x/', sync : 1, force : 1 } );
// console.log( '\nfiles.directoryMake: \n',files._tree );

//directoryMake async

// var con = files.directoryMake( { pathFile : '/folder.abc/folder2.x/test1.txt', sync : 0, force : 0 } );
// con.got( function ( err )
// { if(err)
//   throw err;
//   console.log( '\nfiles.directoryMake: \n',files._tree );
// } )
