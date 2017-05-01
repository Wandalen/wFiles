( function _FileProvider_CachingDir_test_ss_( ) {

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

var testDirectory = __dirname + '/../../../../tmp.tmp/cachingDir';
var cachingDirs = _.FileFilter.Caching({ cachingStats : 0, cachingRecord : 0 });

_.assert( Parent );

//


function simple( t )
{
  t.description = 'CachingDir test';
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileFilter.Caching({ original : provider, cachingDirs : 0 });

  var path = _.pathRefine( _.pathDir( _.diagnosticLocation().path ) );
  logger.log( 'path',path );

  var timeSingle = _.timeNow();
  provider.directoryRead( path );
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    provider.directoryRead( path );
  }
  logger.log( _.timeSpent( 'Spent to make provider.directoryRead 10k times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    filter.directoryRead( path );
  }
  logger.log( _.timeSpent( 'Spent to make filter.directoryRead 10k times',time2-timeSingle ) );

  t.identical( 1, 1 )
}

//

function filesFind( t )
{
  t.description = 'CachingDir filesFind';
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileFilter.Caching({ original : provider, cachingDirs : 0 });

  var path = _.pathRefine( _.pathDir( _.diagnosticLocation().path ) );
  logger.log( 'path',path );

  var timeSingle = _.timeNow();
  provider.filesFind({ filePath : path });
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    provider.filesFind({ filePath : path });
  }
  logger.log( _.timeSpent( 'Spent to make provider.filesFind 100 times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    filter.filesFind({ filePath : path });
  }
  logger.log( _.timeSpent( 'Spent to make filter.filesFind 100 times',time2-timeSingle ) );

  t.identical( 1, 1 )
}

//

function fileWrite( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';
  var pathDir = _.pathDir( filePath );

  //

  t.description = 'fileWrite updates dirs cache';

  /* file not exist in cache, dir creation in write process not affects on cache */

  _.fileProvider.fileDelete( testDirectory );
  cachingDirs.fileWrite( filePath, testData );
  var pathDir = _.pathResolve( _.pathDir( filePath ) );
  var got = cachingDirs._cacheDir;
  t.identical( got, {} );

  /* dir cached, writing file into that dir updates cache */

  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.directoryMake( pathDir );
  cachingDirs.directoryRead( pathDir );
  cachingDirs.fileWrite( filePath, testData );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDir ) ];
  t.identical( got, [ 'file' ] );

  /* rewriting existing file, dir not cached */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingDirs.fileWrite( filePath, testData );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDir ) ]
  var expected = undefined;
  t.identical( got, expected );
  //rewriting
  cachingDirs.fileWrite( filePath, testData + testData );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDir ) ];
  t.identical( got, expected );

  /* rewriting existing file, dir cached */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingDirs.fileWrite( filePath, testData );
  var got = cachingDirs.directoryRead( pathDir );
  var expected = [ 'file' ];
  t.identical( got, expected );
  //rewriting
  cachingDirs.fileWrite( filePath, testData + testData );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDir ) ];
  t.identical( got, expected );

  /* purging file before write */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingDirs.fileWrite( filePath, testData );
  var got = cachingDirs.directoryRead( pathDir );
  var expected = [ 'file' ];
  t.identical( got, expected );
  cachingDirs.fileWrite({ filePath : filePath, data :  testData + testData, purging : 1 });
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDir ) ];
  t.identical( got, expected );
}

//

function fileDelete( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'file deleting updates existing stat cache';
  var pathDir = _.pathDir( filePath );

  /* file is not cached */
  cachingDirs._cacheDir = {};
  _.fileProvider.directoryMake( pathDir );
  cachingDirs.fileDelete( filePath );
  var got = cachingDirs._cacheDir;
  t.identical( got, {});

  /* file cached befor delete */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs.directoryRead( pathDir );
  cachingDirs.fileDelete( filePath );
  var got = cachingDirs.directoryRead( pathDir );
  t.identical( got, [] );

  /* delete empty folder */

  cachingDirs._cacheDir = {};
  _.fileProvider.directoryMake( pathDir );
  cachingDirs.directoryRead( pathDir );
  cachingDirs.fileDelete( pathDir );
  var got = cachingDirs.directoryRead( pathDir );
  t.identical( got, null );

  /* deleting folder with file, stat cached */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs.directoryRead( pathDir );
  cachingDirs.directoryRead( filePath );
  cachingDirs.fileDelete( pathDir );
  var got = cachingDirs.directoryRead( pathDir );
  t.identical( got, null );
  var got = cachingDirs.directoryRead( filePath );
  t.identical( got, null );
}

//

function directoryMake( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'dir creation updates existing stat cache';
  var pathDir = _.pathDir( filePath );

  /* defaults, dir not cached */
  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingDirs.directoryMake( testDirectory );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, undefined );

  /* defaults, dir cached */
  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  cachingDirs.directoryRead( testDirectory );
  cachingDirs.directoryMake( testDirectory );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, [] );

  /* rewritingTerminal, terminal cached */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( testDirectory, testData );
  cachingDirs.directoryRead( testDirectory );
  cachingDirs.directoryMake( testDirectory );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, [] );

  /* rewritingTerminal disabled, terminal cached */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( testDirectory, testData );
  cachingDirs.directoryRead( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.directoryMake({ filePath : testDirectory, rewritingTerminal : 0 });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, [ _.pathName( testDirectory )] );


  /* force disabled, rewritingTerminal check caches file stat */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.directoryMake({ filePath : filePath, force : 0 });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  /* force and rewritingTerminal disabled */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.directoryMake({ filePath : filePath, force : 0, rewritingTerminal : 0 });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
}

//

function fileRename( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'src not exist';

  /**/

  _.fileProvider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileRename
    ({
      pathSrc : filePath,
      pathDst : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  /**/

  _.fileProvider.fileDelete( testDirectory );
  cachingDirs._cacheDir = {};
  cachingDirs.fileRename
  ({
    pathSrc : filePath,
    pathDst : ' ',
    sync : 1,
    rewriting : 1,
    throwing : 0,
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  //

  t.description = 'rename in same directory';
  var pathDst = _.pathJoin( testDirectory,'_file' );

  /* dst not exist */

  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs._cacheDir = {};
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( _.pathDir( filePath  ) );
  cachingDirs.fileRename
  ({
    pathSrc : filePath,
    pathDst : pathDst,
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDst ) ];
  var expected = _.fileProvider.directoryRead( pathDst );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathDir( filePath ) ) ];
  var expected = _.fileProvider.directoryRead( _.pathDir( filePath ) );
  t.identical( got, expected );

  /* rewriting existing dst*/

  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( pathDst, testData + testData );
  cachingDirs._cacheDir = {};
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( _.pathDir( filePath  ) );
  cachingDirs.fileRename
  ({
    pathSrc : filePath,
    pathDst : pathDst,
    rewriting : 1
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDst ) ];
  var expected = _.fileProvider.directoryRead( pathDst );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathDir( filePath ) ) ];
  var expected = _.fileProvider.directoryRead( _.pathDir( filePath ) );
  t.identical( got, expected );

  //

  t.description = 'rename dir';
  var pathDst = _.pathJoin( testDirectory,'_file' );

  /* dst not exist */

  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs._cacheDir = {};
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( testDirectory );
  cachingDirs.directoryRead( testDirectory + '_' );
  cachingDirs.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, null );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory + '_' ) ];
  var expected = _.fileProvider.directoryRead( testDirectory + '_' );
  t.identical( got, expected );

  /* dst is empty dir */

  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.directoryMake( testDirectory + '_' );
  cachingDirs._cacheDir = {};
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( testDirectory );
  cachingDirs.directoryRead( testDirectory + '_' );
  cachingDirs.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
    rewriting : 1,
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, null );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory + '_' ) ];
  var expected = _.fileProvider.directoryRead( testDirectory + '_' );
  t.identical( got, expected );

  /* dst is dir with files */

  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  cachingDirs._cacheDir = {};
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( _.pathJoin( testDirectory + '_', 'file' ) );
  cachingDirs.directoryRead( testDirectory );
  cachingDirs.directoryRead( testDirectory + '_' );
  cachingDirs.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
    rewriting : 1
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  t.identical( got, null );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory + '_' ) ];
  var expected = _.fileProvider.directoryRead( testDirectory + '_' );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathJoin( testDirectory + '_', 'file' ) ) ];
  t.identical( got, undefined );

  /* dst is dir with files, rewriting off, error expected, src/dst must not be changed */

  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  cachingDirs._cacheDir = {};
  var expected1 = cachingDirs.directoryRead( testDirectory );
  var expected2 = cachingDirs.directoryRead( testDirectory + '_' );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileRename
    ({
      pathSrc : testDirectory,
      pathDst : testDirectory + '_',
    });
  })
  var got1 = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  var got2 = cachingDirs._cacheDir[ _.pathResolve( testDirectory + '_' ) ];
  t.identical( got1, expected1 );
  t.identical( got2, expected2 );

  /* dst is dir with files, rewriting off, throwing off, src/dst must not be changed */

  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  cachingDirs._cacheDir = {};
  var expected1 = cachingDirs.directoryRead( testDirectory );
  var expected2 = cachingDirs.directoryRead( testDirectory + '_' );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileRename
    ({
      pathSrc : testDirectory,
      pathDst : testDirectory + '_',
      rewriting : 0
    });
  })
  var got1 = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  var got2 = cachingDirs._cacheDir[ _.pathResolve( testDirectory + '_' ) ];
  t.identical( got1, expected1 );
  t.identical( got2, expected2 );

  /* dst exist, file from src dir is cached before rename, must be deleted  */

  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  cachingDirs._cacheDir = {};
  cachingDirs.directoryRead( filePath );
  cachingDirs.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
    rewriting : 1
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory + '_' ) ];
  t.identical( got, undefined );
}

//

function fileCopy( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';
  _.fileProvider.fileDelete( testDirectory );

  //

  t.description = 'src not exist';

  /**/

  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileCopy
    ({
      pathSrc : filePath,
      pathDst : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  var expected = undefined;
  t.identical( got, expected );

  /**/

  cachingDirs._cacheDir = {};
  t.mustNotThrowError( function()
  {
    cachingDirs.fileCopy
    ({
      pathSrc : filePath,
      pathDst : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 0,
    });
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  var expected = undefined;
  t.identical( got, expected );

  //

  t.description = 'dst not exist';
  var pathDst = _.pathJoin( testDirectory, 'dst' );

  /* file */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( pathDst );
  cachingDirs.fileCopy
  ({
    pathSrc : filePath,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1,
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  var expected = _.fileProvider.directoryRead( filePath );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDst ) ];
  var expected = _.fileProvider.directoryRead( pathDst );
  t.identical( got, expected );

  /* file, rewriting dst - terminal file  */

  cachingDirs._cacheDir = {};
  var pathDst = _.pathJoin( testDirectory, 'dst' );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( pathDst, testData + testData );
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( pathDst );
  cachingDirs.fileCopy
  ({
    pathSrc : filePath,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1,
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  var expected = _.fileProvider.directoryRead( filePath );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDst ) ];
  var expected = _.fileProvider.directoryRead( pathDst );
  t.identical( got, expected );

  /* file, rewriting dst - terminal file, rewriting off  */

  cachingDirs._cacheDir = {};
  var pathDst = _.pathJoin( testDirectory, 'dst' );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( pathDst, testData + testData );
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( pathDst );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileCopy
    ({
      pathSrc : filePath,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 1,
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  var expected = _.fileProvider.directoryRead( filePath );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDst ) ];
  var expected = _.fileProvider.directoryRead( pathDst );
  t.identical( got, expected );

  /* copy folders */

  cachingDirs._cacheDir = {};
  pathDst = testDirectory + '_';
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( pathDst );
  cachingDirs.directoryRead( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileCopy
    ({
      pathSrc : testDirectory,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  var expected = _.fileProvider.directoryRead( filePath );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( testDirectory ) ];
  var expected = _.fileProvider.directoryRead( testDirectory );
  t.identical( got, expected );
  var got = cachingDirs._cacheDir[ _.pathResolve( pathDst ) ];
  var expected = _.fileProvider.directoryRead( pathDst );
  t.identical( got, expected );

}

//

function fileExchange( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var filePath2 = _.pathJoin( testDirectory + '_','file2' );
  var testData = 'Lorem ipsum dolor sit amet';
  _.fileProvider.fileDelete( testDirectory );

  //

  t.description = 'swap two files content';

  /* not cached */
  cachingDirs._cacheDir = {};
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( filePath2, testData + testData );
  cachingDirs.fileExchange( filePath2, filePath );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /* cached */

  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( filePath2, testData + testData );
  var expected1 = cachingDirs.directoryRead( filePath );
  var expected2 = cachingDirs.directoryRead( filePath2 );
  cachingDirs.fileExchange( filePath2, filePath );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, expected1 );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, expected2 );

  //

  t.description = 'swap content of two dirs';

  /**/

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( filePath2, testData + testData );
  var expected1 = cachingDirs.directoryRead( _.pathDir( filePath ) );
  var expected2 = cachingDirs.directoryRead( _.pathDir( filePath2 ) );
  cachingDirs.fileExchange( _.pathDir( filePath2 ), _.pathDir( filePath ) );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathDir( filePath ) ) ];
  t.identical( got, expected2 );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathDir( filePath2 ) ) ];
  t.identical( got, expected1 );

  /* files from dirs are cached before exchange */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( testDirectory );
  _.fileProvider.fileWrite( filePath, testData );
  _.fileProvider.fileWrite( filePath2, testData + testData );
  var expected1 = cachingDirs.directoryRead( _.pathDir( filePath ) );
  var expected2 = cachingDirs.directoryRead( _.pathDir( filePath2 ) );
  cachingDirs.directoryRead( filePath );
  cachingDirs.directoryRead( filePath2 );
  cachingDirs.fileExchange( _.pathDir( filePath2 ), _.pathDir( filePath ) );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathDir( filePath ) ) ];
  t.identical( got, expected2 );
  var got = cachingDirs._cacheDir[ _.pathResolve( _.pathDir( filePath2 ) ) ];
  t.identical( got, expected1 );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  //

  t.description = 'src not exist';

  /* allowMissing off, throwing on */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 0
    });
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /* allowMissing off, throwing off */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 0
    });
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /* allowMissing on, throwing on */

  cachingDirs._cacheDir = {};
  var filePath2 = _.pathJoin( testDirectory, 'file2' )
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath2, testData + testData );
  cachingDirs.directoryRead( filePath2 );
  cachingDirs.fileExchange
  ({
    pathDst : filePath2,
    pathSrc : filePath,
    throwing : 1,
    allowMissing : 1
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, [ _.pathName( filePath ) ] );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  //

  t.description = 'dst not exist';
  var filePath2 = _.pathJoin( testDirectory, 'file2' );

  /**/

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  cachingDirs.directoryRead( filePath );
  cachingDirs.fileExchange
  ({
    pathDst : filePath2,
    pathSrc : filePath,
    throwing : 1,
    allowMissing : 1
  });
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, [ _.pathName( filePath2 ) ] );

  /**/

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 0
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /**/

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  _.fileProvider.fileWrite( filePath, testData );
  t.mustNotThrowError( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 0
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  //

  t.description = 'src & dst not exist';
  var filePath2 = _.pathJoin( testDirectory, 'file2' );

  /**/

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 1
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /* throwing 0, allowMissing 1 */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 1
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /* throwing 1, allowMissing 0 */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  t.shouldThrowErrorSync( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 0
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  /* throwing 0, allowMissing 0 */

  cachingDirs._cacheDir = {};
  _.fileProvider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingDirs.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 0
    });
  })
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingDirs._cacheDir[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

}

//

// --
// proto
// --

var Self =
{

  name : 'FileFilter.CachingDir',

  tests :
  {
    simple : simple,
    filesFind : filesFind,

    fileWrite : fileWrite,
    fileDelete : fileDelete,
    directoryMake : directoryMake,
    fileRename : fileRename,
    fileCopy : fileCopy,
    fileExchange : fileExchange,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
