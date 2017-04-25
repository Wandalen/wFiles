( function _FileProvider_CachingRecord_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

  var _ = wTools;

  _.include( 'wTesting' );

  // console.log( '_.fileProvider :',_.fileProvider );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var testDirectory = __dirname + '/../../../../tmp.tmp/cachingRecord';
var o = { fileProvider : _.fileProvider };

_.assert( Parent );

//

function fileRead( t )
{
  var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingStats : 0 });
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'updateOnRead disabled '

  /**/

  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRead( filePath );
  t.identical( cachingRecord._cacheRecord, {} );

  /* previously cached record*/

  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  var expected = cachingRecord.fileRecord( filePath, o );
  cachingRecord.fileRead( filePath );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got, expected );

  /* previously cached record, file not exist */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileRecord( filePath, o );
  t.shouldThrowErrorSync( function()
  {
    cachingRecord.fileRead( filePath );
  })
  got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got.stat, null );

  //

  t.description = 'updateOnRead enabled'
  var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingStats: 0, updateOnRead : 1 });

  /* cache is clean, nothing to update */

  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRead( filePath );
  t.identical( cachingRecord._cacheRecord, {} )

  /* previously cached record */

  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileRecord( filePath, o );
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRead( filePath );
  expected = _.fileProvider.fileStat( filePath );
  got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ].stat;
  t.identical( _.objectIs( got ), true );
  t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );

  /* several previously cached records */

  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileRecord( filePath, o );
  var recordOptions1 = _.FileRecordOptions( o, { relative : '/X' } );
  cachingRecord.fileRecord( filePath, recordOptions1 );
  var recordOptions2 = _.FileRecordOptions( o, { dir : '/a', relative : '/x'  } );
  cachingRecord.fileRecord( filePath, recordOptions2 );
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRead( filePath );
  expected = _.fileProvider.fileStat( filePath );
  got = cachingRecord.fileRecord( filePath, o );
  t.identical( _.objectIs( got ), true );
  t.identical( [ got.stat.dev, got.stat.size, got.stat.ino ], [ expected.dev, expected.size, expected.ino ] );
  got = cachingRecord.fileRecord( filePath, recordOptions1 );
  t.identical( [ got.stat.dev, got.stat.size, got.stat.ino ], [ expected.dev, expected.size, expected.ino ] );
  got = cachingRecord.fileRecord( filePath, recordOptions2 );
  t.identical( [ got.stat.dev, got.stat.size, got.stat.ino ], [ expected.dev, expected.size, expected.ino ] );

  /* previously cached record, file not exist */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileRecord( filePath, o );
  t.shouldThrowErrorSync( function()
  {
    cachingRecord.fileRead( filePath );
  })
  got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got.stat, null );

  /* record cached, file was removed before read */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRecord( filePath, o );
  _.fileProvider.fileDelete( filePath )
  t.shouldThrowErrorSync( function()
  {
    cachingRecord.fileRead( filePath );
  })
  var expected = null;
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got.stat, expected );
}

//

function fileWrite( t )
{
  var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingStats : 0 });
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'fileWrite updates stat cache';

  /* file not exist in cache */

  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileWrite( filePath, testData );
  var pathDir = _.pathResolve( _.pathDir( filePath ) );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  /* file exist in cache */

  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileRecord( filePath, o );
  cachingRecord.fileWrite( filePath, testData );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( _.objectIs( got.stat ), true );
  t.identical( got.stat.isFile(), true );

  /* rewriting existing file, updates stats of cached record */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileWrite( filePath, testData );
  cachingRecord.fileRecord( filePath, o );
  //rewriting
  cachingRecord.fileWrite( filePath, testData + testData );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  var expected = _.fileProvider.fileStat( filePath );
  t.identical( got.stat.size, expected.size )

  /* purging file before write */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.fileWrite( filePath, testData );
  cachingRecord.fileRecord( filePath, o );
  cachingRecord.fileWrite({ filePath : filePath, purging : 1, data : testData });
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  var expected = _.fileProvider.fileStat( filePath );
  t.identical([ got.stat.dev, got.stat.ino,got.stat.size ], [ expected.dev, expected.ino, expected.size ] );
}

//

function fileDelete( t )
{
  var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingStats : 0 });
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'file deleting updates existing stat cache';
  var pathDir = _.pathDir( filePath );

  /* file record is not cached */

  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileDelete( filePath );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  /* file record cached before delete */

  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRecord( filePath, o );
  cachingRecord.fileDelete( filePath );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got, null );

  /* deleting empty folder, record cached */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( pathDir );
  _.fileProvider.directoryMake( pathDir  );
  cachingRecord.fileRecord( pathDir, o );
  cachingRecord.fileDelete( pathDir );
  var got = cachingRecord._cacheRecord[ _.pathResolve( pathDir ) ][ 1 ];
  t.identical( got, null );

  /* deleting folder with file, record cached */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRecord( pathDir, o );
  cachingRecord.fileRecord( filePath, o );
  cachingRecord.fileDelete( pathDir );
  var got = cachingRecord._cacheRecord[ _.pathResolve( pathDir ) ][ 1 ];
  t.identical( got, null );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
}

//

function directoryMake( t )
{
  var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingStats : 0 });
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'dir creation updates existing stat cache';

  /* rewritingTerminal enabled */

  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.directoryMake( testDirectory );
  var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory ) ];
  t.identical( got, undefined );

  /* rewritingTerminal disabled */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingRecord.directoryMake({ filePath : testDirectory, rewritingTerminal : 0 });
  var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory ) ];
  t.identical( got, undefined );

  /* rewritingTerminal enabled, update of existing file cache */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  cachingRecord.fileRecord( filePath, o );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got.stat.isFile(), true  );
  cachingRecord.directoryMake( filePath );
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got.stat.isDirectory(), true );

  /* rewritingTerminal disable, file prevents dir creation */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  var expected = cachingRecord.fileRecord( filePath, o );
  t.shouldThrowErrorSync( function()
  {
    cachingRecord.directoryMake({ filePath : filePath, rewritingTerminal : 0 });
  })
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ][ 1 ];
  t.identical( got, expected );

  /* force disabled  */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingRecord.directoryMake({ filePath : filePath, force : 0 });
  })
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  /* force and rewritingTerminal disabled */

  cachingRecord._cacheRecord = {};
  _.fileProvider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingRecord.directoryMake({ filePath : filePath, force : 0, rewritingTerminal : 0 });
  })
  var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
}

//

// function fileRename( t )
// {
//   var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingRecord : 0 });
//   var filePath = _.pathJoin( testDirectory,'file' );
//   var testData = 'Lorem ipsum dolor sit amet';
//
//   //
//
//   t.description = 'src not exist';
//
//   /**/
//
//   _.fileProvider.fileDelete( testDirectory );
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileRename
//     ({
//       pathSrc : filePath,
//       pathDst : ' ',
//       sync : 1,
//       rewriting : 1,
//       throwing : 1,
//     });
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//
//   /**/
//
//   _.fileProvider.fileDelete( testDirectory );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileRename
//   ({
//     pathSrc : filePath,
//     pathDst : ' ',
//     sync : 1,
//     rewriting : 1,
//     throwing : 0,
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//
//   //
//
//   t.description = 'rename in same directory';
//   var pathDst = _.pathJoin( testDirectory,'_file' );
//
//   /* dst not exist */
//
//   _.fileProvider.fileDelete( testDirectory );
//   _.fileProvider.fileWrite( filePath, testData );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileRename
//   ({
//     pathSrc : filePath,
//     pathDst : pathDst,
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( pathDst ) ];
//   var expected = _.fileProvider.fileStat( pathDst );
//   t.identical( got.isFile(), true );
//   t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* rewriting existing dst*/
//
//   _.fileProvider.fileDelete( testDirectory );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( pathDst, testData + testData );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileRename
//   ({
//     pathSrc : filePath,
//     pathDst : pathDst,
//     rewriting : 1
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( pathDst ) ];
//   var expected = _.fileProvider.fileStat( pathDst );
//   t.identical( got.isFile(), true );
//   t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   //
//
//   t.description = 'rename dir';
//   var pathDst = _.pathJoin( testDirectory,'_file' );
//
//   /* dst not exist */
//
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileRename
//   ({
//     pathSrc : testDirectory,
//     pathDst : testDirectory + '_',
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory + '_' ) ];
//   var expected = _.fileProvider.fileStat( testDirectory + '_' );
//   t.identical( got.isDirectory(), true );
//   t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* dst is empty dir */
//
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.directoryMake( testDirectory + '_' );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileRename
//   ({
//     pathSrc : testDirectory,
//     pathDst : testDirectory + '_',
//     rewriting : 1,
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory + '_' ) ];
//   var expected = _.fileProvider.fileStat( testDirectory + '_' );
//   t.identical( got.isDirectory(), true );
//   t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* dst is dir with files */
//
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileRename
//   ({
//     pathSrc : testDirectory,
//     pathDst : testDirectory + '_',
//     rewriting : 1
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory + '_' ) ];
//   var expected = _.fileProvider.fileStat( testDirectory + '_' );
//   t.identical( got.isDirectory(), true );
//   t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* dst is dir with files, rewriting off, error expected, src/dst must not be changed */
//
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
//   var expected1 = _.fileProvider.fileStat( testDirectory );
//   var expected2 = _.fileProvider.fileStat( testDirectory + '_' );
//   cachingRecord._cacheRecord = {};
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileRename
//     ({
//       pathSrc : testDirectory,
//       pathDst : testDirectory + '_',
//     });
//   })
//   var got1 = cachingRecord._cacheRecord[ _.pathResolve( testDirectory ) ];
//   var got2 = cachingRecord._cacheRecord[ _.pathResolve( testDirectory + '_' ) ];
//   t.identical( got1.isDirectory(), true );
//   t.identical([ got1.dev, got1.ino,got1.size ], [ expected1.dev, expected1.ino, expected1.size ] );
//   t.identical( got2.isDirectory(), true );
//   t.identical([ got2.dev, got2.ino,got2.size ], [ expected2.dev, expected2.ino, expected2.size ] );
//
//   /* dst is dir with files, rewriting off, throwing off, src/dst must not be changed */
//
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
//   var expected1 = _.fileProvider.fileStat( testDirectory );
//   var expected2 = _.fileProvider.fileStat( testDirectory + '_' );
//   cachingRecord._cacheRecord = {};
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileRename
//     ({
//       pathSrc : testDirectory,
//       pathDst : testDirectory + '_',
//       throwing : 0
//     });
//   })
//   var got1 = cachingRecord._cacheRecord[ _.pathResolve( testDirectory ) ];
//   var got2 = cachingRecord._cacheRecord[ _.pathResolve( testDirectory + '_' ) ];
//   t.identical( got1.isDirectory(), true );
//   t.identical([ got1.dev, got1.ino,got1.size ], [ expected1.dev, expected1.ino, expected1.size ] );
//   t.identical( got2.isDirectory(), true );
//   t.identical([ got2.dev, got2.ino,got2.size ], [ expected2.dev, expected2.ino, expected2.size ] );
//
//   /* dst exist, stat of file from src dir is cached befpre rename, must be deleted  */
//
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
//   cachingRecord._cacheRecord = {};
//   cachingRecord.fileStat( filePath );
//   cachingRecord.fileRename
//   ({
//     pathSrc : testDirectory,
//     pathDst : testDirectory + '_',
//     rewriting : 1
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, undefined );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory + '_' ) ];
//   var expected = _.fileProvider.fileStat( testDirectory + '_' );
//   t.identical( got.isDirectory(), true );
//   t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
// }
//
// //
//
// function fileCopy( t )
// {
//   var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingRecord : 0 });
//   var filePath = _.pathJoin( testDirectory,'file' );
//   var testData = 'Lorem ipsum dolor sit amet';
//   _.fileProvider.fileDelete( testDirectory );
//
//   //
//
//   t.description = 'src not exist';
//
//   /**/
//
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileCopy
//     ({
//       pathSrc : filePath,
//       pathDst : ' ',
//       sync : 1,
//       rewriting : 1,
//       throwing : 1,
//     });
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = null;
//   t.identical( got, expected );
//
//   /**/
//
//   cachingRecord._cacheRecord = {};
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileCopy
//     ({
//       pathSrc : filePath,
//       pathDst : ' ',
//       sync : 1,
//       rewriting : 1,
//       throwing : 0,
//     });
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = null;
//   t.identical( got, expected );
//
//   //
//
//   t.description = 'dst not exist';
//   var pathDst = _.pathJoin( testDirectory, 'dst' );
//
//   /* file */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileWrite( filePath, testData );
//   cachingRecord.fileCopy
//   ({
//     pathSrc : filePath,
//     pathDst : pathDst,
//     sync : 1,
//     rewriting : 1,
//     throwing : 1,
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( pathDst ) ];
//   var expected = _.fileProvider.fileStat( pathDst );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* file, rewriting dst - terminal file  */
//
//   cachingRecord._cacheRecord = {};
//   var pathDst = _.pathJoin( testDirectory, 'dst' );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( pathDst, testData + testData );
//   cachingRecord.fileCopy
//   ({
//     pathSrc : filePath,
//     pathDst : pathDst,
//     sync : 1,
//     rewriting : 1,
//     throwing : 1,
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( pathDst ) ];
//   var expected = _.fileProvider.fileStat( pathDst );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* file, rewriting dst - terminal file, rewriting off  */
//
//   cachingRecord._cacheRecord = {};
//   var pathDst = _.pathJoin( testDirectory, 'dst' );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( pathDst, testData + testData );
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileCopy
//     ({
//       pathSrc : filePath,
//       pathDst : pathDst,
//       sync : 1,
//       rewriting : 0,
//       throwing : 1,
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( pathDst ) ];
//   var expected = _.fileProvider.fileStat( pathDst );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /* copy folders */
//
//   cachingRecord._cacheRecord = {};
//   pathDst = testDirectory + '_';
//   _.fileProvider.fileWrite( filePath, testData );
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileCopy
//     ({
//       pathSrc : testDirectory,
//       pathDst : pathDst,
//       sync : 1,
//       rewriting : 1,
//       throwing : 1,
//     });
//   })
//
//   var got = cachingRecord._cacheRecord[ _.pathResolve( testDirectory ) ];
//   var expected = _.fileProvider.fileStat( testDirectory );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( pathDst ) ];
//   var expected = _.fileProvider.fileStat( pathDst );
//   t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
// }
//
// //
//
// function fileExchange( t )
// {
//   var cachingRecord = _.FileFilter.Caching({ cachingDirs : 0, cachingRecord : 0 });
//   var filePath = _.pathJoin( testDirectory,'file' );
//   var filePath2 = _.pathJoin( testDirectory + '_','file2' );
//   var testData = 'Lorem ipsum dolor sit amet';
//   _.fileProvider.fileDelete( testDirectory );
//
//   //
//
//   t.description = 'swap two files content';
//
//   /**/
//
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( filePath2, testData + testData );
//   var expected1 = _.fileProvider.fileStat( filePath );
//   var expected2 = _.fileProvider.fileStat( filePath2 );
//   cachingRecord.fileExchange( filePath2, filePath );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( [ got.dev, got.ino,got.size ], [ expected2.dev, expected2.ino, expected2.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( [ got.dev, got.ino,got.size ], [ expected1.dev, expected1.ino, expected1.size ] );
//
//   //
//
//   t.description = 'swap content of two dirs';
//
//   /**/
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( testDirectory );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( filePath2, testData + testData );
//   var expected1 = _.fileProvider.fileStat( _.pathDir( filePath ) );
//   var expected2 = _.fileProvider.fileStat( _.pathDir( filePath2 ) );
//   cachingRecord.fileExchange( _.pathDir( filePath2 ), _.pathDir( filePath ) );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( _.pathDir( filePath ) ) ];
//   t.identical( [ got.dev, got.ino,got.size ], [ expected2.dev, expected2.ino, expected2.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( _.pathDir( filePath2 ) ) ];
//   t.identical( [ got.dev, got.ino,got.size ], [ expected1.dev, expected1.ino, expected1.size ] );
//
//   /* stat of files from dirs are cached before exchange */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( testDirectory );
//   _.fileProvider.fileWrite( filePath, testData );
//   _.fileProvider.fileWrite( filePath2, testData + testData );
//   var expected1 = _.fileProvider.fileStat( _.pathDir( filePath ) );
//   var expected2 = _.fileProvider.fileStat( _.pathDir( filePath2 ) );
//   cachingRecord.fileStat( filePath );
//   cachingRecord.fileStat( filePath2 );
//   cachingRecord.fileExchange( _.pathDir( filePath2 ), _.pathDir( filePath ) );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( _.pathDir( filePath ) ) ];
//   t.identical( [ got.dev, got.ino,got.size ], [ expected2.dev, expected2.ino, expected2.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( _.pathDir( filePath2 ) ) ];
//   t.identical( [ got.dev, got.ino,got.size ], [ expected1.dev, expected1.ino, expected1.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, undefined );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, undefined );
//
//   //
//
//   t.description = 'src not exist';
//
//   /* allowMissing off, throwing on */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 1,
//       allowMissing : 0
//     });
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   /* allowMissing off, throwing off */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 0,
//       allowMissing : 0
//     });
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   /* allowMissing on, throwing on */
//
//   cachingRecord._cacheRecord = {};
//   var filePath2 = _.pathJoin( testDirectory, 'file2' )
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath2, testData + testData );
//   var expected = _.fileProvider.fileStat( filePath2 );
//   cachingRecord.fileExchange
//   ({
//     pathDst : filePath2,
//     pathSrc : filePath,
//     throwing : 1,
//     allowMissing : 1
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   //
//
//   t.description = 'dst not exist';
//   var filePath2 = _.pathJoin( testDirectory, 'file2' );
//
//   /**/
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   var expected = _.fileProvider.fileStat( filePath );
//   cachingRecord.fileExchange
//   ({
//     pathDst : filePath2,
//     pathSrc : filePath,
//     throwing : 1,
//     allowMissing : 1
//   });
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
//
//   /**/
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 1,
//       allowMissing : 0
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   /**/
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   _.fileProvider.fileWrite( filePath, testData );
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 0,
//       allowMissing : 0
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   //
//
//   t.description = 'src & dst not exist';
//   var filePath2 = _.pathJoin( testDirectory, 'file2' );
//
//   /**/
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 1,
//       allowMissing : 1
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   /* throwing 0, allowMissing 1 */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 0,
//       allowMissing : 1
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   /* throwing 1, allowMissing 0 */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   t.shouldThrowErrorSync( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 1,
//       allowMissing : 0
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
//   /* throwing 0, allowMissing 0 */
//
//   cachingRecord._cacheRecord = {};
//   _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
//   t.mustNotThrowError( function()
//   {
//     cachingRecord.fileExchange
//     ({
//       pathDst : filePath2,
//       pathSrc : filePath,
//       throwing : 0,
//       allowMissing : 0
//     });
//   })
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath ) ];
//   var expected = _.fileProvider.fileStat( filePath );
//   t.identical( got, null );
//   var got = cachingRecord._cacheRecord[ _.pathResolve( filePath2 ) ];
//   t.identical( got, null );
//
// }

// --
// proto
// --

var Self =
{

  name : 'FileProvider.cachingRecord',

  tests :
  {
    fileRead : fileRead,
    fileWrite : fileWrite,
    fileDelete : fileDelete,
    directoryMake : directoryMake,
    // fileRename : fileRename,
    // fileCopy : fileCopy,
    // fileExchange : fileExchange,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
