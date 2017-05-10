( function _FileProvider_CachingStats_test_ss_( ) {

'use strict';
var isBrowser = true;
if( typeof module !== 'undefined' )
{
  isBrowser = false;
  require( '../FileMid.s' );

  var _ = wTools;

  _.include( 'wTesting' );

  // console.log( 'provider :',provider );

  var testDirectory = __dirname + '/../../../../tmp.tmp/cachingStats';

}

var _ = wTools;

if( !isBrowser )
{
  var testDirectory = __dirname + '/../../../../tmp.tmp/cachingStats';
  var provider = _.FileProvider.HardDrive();
}
else
{ var testTree = {};
  var provider = _.FileProvider.SimpleStructure({ filesTree : testTree });
  var testDirectory = '/tmp.tmp/cachingStats';
}

//

var Parent = wTools.Testing;
var cachingStats= _.FileFilter.Caching({ original : provider, cachingDirs : 0, cachingRecord : 0 });
_.assert( Parent );

//

function simple( t )
{
  t.description = 'CachingStats test';
  var path = _.pathRefine( _.diagnosticLocation().path );
  logger.log( 'path',path );

  var timeSingle = _.timeNow();
  provider.fileStat( path );
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    provider.fileStat( path );
  }
  logger.log( _.timeSpent( 'Spent to make provider.fileStat 10k times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    cachingStats.fileStat( path );
  }
  logger.log( _.timeSpent( 'Spent to make cachingStats.fileStat 10k times',time2-timeSingle ) );

  t.identical( 1, 1 );
}

//

function fileStat( t )
{
  var path = _.pathRefine( _.pathJoin( testDirectory, 'file' ) );
  logger.log( 'path',path );

  var consequence = new wConsequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    t.description = 'cachingStats.fileStat work like original provider';
    provider.fileWrite( path, 'test' )
  })

  /* compare results sync*/

  .ifNoErrorThen( function()
  {
    var expected = provider.fileStat( path );
    var got = cachingStats.fileStat( path );
    t.identical( _.objectIs( got ), true );
    t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
  })

  /*compare results async*/

  .ifNoErrorThen( function()
  {
    var expected;
    provider.fileStat({ filePath : path, sync : 0 })
    .ifNoErrorThen( function( got )
    {
      expected = got;
      cachingStats.fileStat({ filePath : path, sync : 0 })
      .ifNoErrorThen( function( got )
      {
        t.identical( _.objectIs( got ), true );
        //negative number in expected.dev
        t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
      })
    });
  })

  /*path not exist in file system, default setting*/

  .ifNoErrorThen( function()
  {
    var expected = provider.fileStat( 'invalid path' );
    var got = cachingStats.fileStat( 'invalid path' );
    t.identical( got, expected );
  })

  /*path not exist in file system, sync, throwing enabled*/

  .ifNoErrorThen( function()
  {
    cachingStats._cacheStats = {}
    t.shouldThrowErrorSync( function()
    {
      cachingStats.fileStat({ filePath : 'invalid path', sync : 1, throwing : 1 });
    });
  })

  /*path not exist in file system, async, throwing disabled*/

  .ifNoErrorThen( function()
  {
    var expected;
    provider.fileStat({ filePath : 'invalid path', sync : 0, throwing : 0 })
    .ifNoErrorThen( function( got )
    {
      expected  = got;
      cachingStats.fileStat({ filePath : 'invalid path', sync : 0, throwing : 0 })
      .ifNoErrorThen( function( got )
      {
        t.identical( got, expected );
      })
    });
  })

  /*path not exist in file system, async, throwing enabled*/

  .ifNoErrorThen( function()
  {
    var con = cachingStats.fileStat({ filePath : '_invalid path_', sync : 0, throwing : 1 });
    return t.shouldThrowErrorAsync( con )
    .doThen( function ()
    {
    })
  })


  return consequence;
}

//

function filesFind( t )
{
  var path = _.pathRefine( _.pathDir( _.diagnosticLocation().path ) );
  logger.log( 'path',path );

  t.description = 'filesFind test';

  var timeSingle = _.timeNow();
  provider.filesFind
  ({
    filePath : path,
  });
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    provider.filesFind
    ({
      filePath : path,
    });
  }
  logger.log( _.timeSpent( 'Spent to make provider.filesFind 100 times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    cachingStats.filesFind
    ({
      filePath : path,
    });
  }
  logger.log( _.timeSpent( 'Spent to make cachingStats.filesFind 100 times',time2-timeSingle ) );

  t.identical( 1, 1 );
}

//

function fileRead( t )
{
  if( !cachingStats )
  var cachingStats= _.FileFilter.Caching({ original : provider, cachingDirs : 0, cachingRecord : 0 });

  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'updateOnRead disabled '

  /**/

  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  cachingStats.fileRead( filePath );
  t.identical( cachingStats._cacheStats, {} )

  /* previously cached stat */

  provider.fileDelete( testDirectory );
  cachingStats.fileStat( filePath );
  provider.fileWrite( filePath, testData );
  cachingStats.fileRead( filePath );
  var expected = {};
  expected[ _.pathResolve( filePath ) ] = null;
  t.identical( cachingStats._cacheStats, expected )

  /* previously cached stat, file not exist */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  cachingStats.fileStat( filePath );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileRead( filePath );
  })
  var expected = null;
  got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, expected );

  //

  t.description = 'updateOnRead enabled'
  var cachingStats = _.FileFilter.Caching({ original : provider, cachingDirs : 0, cachingRecord : 0, updateOnRead : 1 });

  /* cache is clean, nothing to update */

  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  cachingStats.fileRead( filePath );
  t.identical( cachingStats._cacheStats, {} )

  /* previously cached stat */

  provider.fileDelete( testDirectory );
  cachingStats.fileStat( filePath );
  var expected = null;
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, expected )
  provider.fileWrite( filePath, testData );
  cachingStats.fileRead( filePath );
  expected = provider.fileStat( filePath );
  got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( _.objectIs( got ), true );
  t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );

  /* previously cached stat, file not exist */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  cachingStats.fileStat( filePath );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileRead( filePath );
  })
  var expected = null;
  got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, expected );

  /* stat cached, file was removed before read */

  cachingStats._cacheStats = {};
  provider.fileWrite( filePath, testData );
  cachingStats.fileStat( filePath );
  provider.fileDelete( filePath )
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileRead( filePath );
  })
  var expected = null;
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, expected );

  cachingStats.updateOnRead = false;
}

//

function fileWrite( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'fileWrite updates stat cache';

  /* file not exist in cache, dir creation in write process updates it stat */

  provider.fileDelete( testDirectory );
  cachingStats.fileWrite( filePath, testData );
  var pathDir = _.pathResolve( _.pathDir( filePath ) );
  var got = cachingStats._cacheStats[ pathDir ];
  t.identical( _.objectIs( got ), true );
  t.identical( got.isDirectory(), true );

  /* file exist in cache, dir creation in write process updates it stat */

  provider.fileDelete( testDirectory );
  cachingStats.fileStat( filePath );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null )
  cachingStats.fileWrite( filePath, testData );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( _.objectIs( got ), true );
  t.identical( got.isFile(), true );

  /* rewriting existing file, file stat cached */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  cachingStats.fileWrite( filePath, testData );
  var got = cachingStats.fileStat( filePath );
  var expected = provider.fileStat( filePath );
  t.identical( got.size, expected.size )
  //rewriting
  cachingStats.fileWrite( filePath, testData + testData );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( got.size, expected.size )

  /* purging file before write */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  cachingStats.fileWrite( filePath, testData );
  cachingStats.fileStat( filePath );
  cachingStats.fileWrite({ filePath : filePath, purging : 1, data : testData });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
}

//

function fileDelete( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'file deleting updates existing stat cache';
  var pathDir = _.pathDir( filePath );

  /* file stat is not cached */

  cachingStats._cacheStats = {};
  provider.fileWrite( filePath, testData );
  cachingStats.fileDelete( filePath );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );

  /* file stat cached before delete */

  provider.fileWrite( filePath, testData );
  cachingStats.fileStat( filePath );
  cachingStats.fileDelete( filePath );
  var got = cachingStats.fileStat( filePath );
  t.identical( got, null );

  /* deleting empty folder, stat cached */

  provider.fileDelete( pathDir );
  provider.directoryMake( pathDir  );
  cachingStats.fileStat( pathDir );
  cachingStats.fileDelete( pathDir );
  var got = cachingStats.fileStat( filePath );
  t.identical( got, null );

  /* deleting folder with file, stat cached */

  provider.fileWrite( filePath, testData );
  cachingStats.fileStat( pathDir );
  cachingStats.fileStat( filePath );
  cachingStats.fileDelete( pathDir );
  var got = [ cachingStats.fileStat( pathDir ), cachingStats.fileStat( filePath ) ];
  t.identical( got, [ null, null ] );
}

//

function directoryMake( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';

  //

  t.description = 'dir creation updates existing stat cache';

  /* rewritingTerminal enabled, it calls fileStat that creates dir cache */

  provider.fileDelete( testDirectory );
  cachingStats.directoryMake( testDirectory );
  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory ) ];
  t.identical( got.isDirectory(), true );

  /* rewritingTerminal disabled */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  cachingStats.directoryMake({ filePath : testDirectory, rewritingTerminal : 0 });
  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory ) ];
  t.identical( got, undefined );

  /* rewritingTerminal enabled, update of existing file cache */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  cachingStats.fileStat( filePath );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got.isFile(), true );
  cachingStats.directoryMake( filePath );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got.isDirectory(), true );

  /* rewritingTerminal disable, file prevents dir creation */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  cachingStats.fileStat( filePath );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.directoryMake({ filePath : filePath, rewritingTerminal : 0 });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got.isFile(), true );

  /* force disabled, rewritingTerminal check caches file stat */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.directoryMake({ filePath : filePath, force : 0 });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );

  /* force and rewritingTerminal disabled */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.directoryMake({ filePath : filePath, force : 0, rewritingTerminal : 0 });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
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

  provider.fileDelete( testDirectory );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileRename
    ({
      pathSrc : filePath,
      pathDst : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );

  /**/

  provider.fileDelete( testDirectory );
  cachingStats._cacheStats = {};
  cachingStats.fileRename
  ({
    pathSrc : filePath,
    pathDst : ' ',
    sync : 1,
    rewriting : 1,
    throwing : 0,
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );

  //

  t.description = 'rename in same directory';
  var pathDst = _.pathJoin( testDirectory,'_file' );

  /* dst not exist */

  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  cachingStats._cacheStats = {};
  cachingStats.fileRename
  ({
    pathSrc : filePath,
    pathDst : pathDst,
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( pathDst ) ];
  var expected = provider.fileStat( pathDst );
  t.identical( got.isFile(), true );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* rewriting existing dst*/

  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( pathDst, testData + testData );
  cachingStats._cacheStats = {};
  cachingStats.fileRename
  ({
    pathSrc : filePath,
    pathDst : pathDst,
    rewriting : 1
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( pathDst ) ];
  var expected = provider.fileStat( pathDst );
  t.identical( got.isFile(), true );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  //

  t.description = 'rename dir';
  var pathDst = _.pathJoin( testDirectory,'_file' );

  /* dst not exist */

  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  cachingStats._cacheStats = {};
  cachingStats.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
  });
  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory + '_' ) ];
  var expected = provider.fileStat( testDirectory + '_' );
  t.identical( got.isDirectory(), true );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* dst is empty dir */

  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  provider.directoryMake( testDirectory + '_' );
  cachingStats._cacheStats = {};
  cachingStats.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
    rewriting : 1,
  });
  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory + '_' ) ];
  var expected = provider.fileStat( testDirectory + '_' );
  t.identical( got.isDirectory(), true );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* dst is dir with files */

  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  cachingStats._cacheStats = {};
  cachingStats.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
    rewriting : 1
  });
  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory + '_' ) ];
  var expected = provider.fileStat( testDirectory + '_' );
  t.identical( got.isDirectory(), true );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* dst is dir with files, rewriting off, error expected, src/dst must not be changed */

  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  var expected1 = provider.fileStat( testDirectory );
  var expected2 = provider.fileStat( testDirectory + '_' );
  cachingStats._cacheStats = {};
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileRename
    ({
      pathSrc : testDirectory,
      pathDst : testDirectory + '_',
    });
  })
  var got1 = cachingStats._cacheStats[ _.pathResolve( testDirectory ) ];
  var got2 = cachingStats._cacheStats[ _.pathResolve( testDirectory + '_' ) ];
  t.identical( got1.isDirectory(), true );
  t.identical([ got1.dev, got1.ino,got1.size ], [ expected1.dev, expected1.ino, expected1.size ] );
  t.identical( got2.isDirectory(), true );
  t.identical([ got2.dev, got2.ino,got2.size ], [ expected2.dev, expected2.ino, expected2.size ] );

  /* dst is dir with files, rewriting off, throwing off, src/dst must not be changed */

  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  var expected1 = provider.fileStat( testDirectory );
  var expected2 = provider.fileStat( testDirectory + '_' );
  cachingStats._cacheStats = {};
  t.mustNotThrowError( function()
  {
    cachingStats.fileRename
    ({
      pathSrc : testDirectory,
      pathDst : testDirectory + '_',
      throwing : 0
    });
  })
  var got1 = cachingStats._cacheStats[ _.pathResolve( testDirectory ) ];
  var got2 = cachingStats._cacheStats[ _.pathResolve( testDirectory + '_' ) ];
  t.identical( got1.isDirectory(), true );
  t.identical([ got1.dev, got1.ino,got1.size ], [ expected1.dev, expected1.ino, expected1.size ] );
  t.identical( got2.isDirectory(), true );
  t.identical([ got2.dev, got2.ino,got2.size ], [ expected2.dev, expected2.ino, expected2.size ] );

  /* dst exist, stat of file from src dir is cached befpre rename, must be deleted  */

  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( _.pathJoin( testDirectory + '_', 'file' ), testData );
  cachingStats._cacheStats = {};
  cachingStats.fileStat( filePath );
  cachingStats.fileRename
  ({
    pathSrc : testDirectory,
    pathDst : testDirectory + '_',
    rewriting : 1
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory + '_' ) ];
  var expected = provider.fileStat( testDirectory + '_' );
  t.identical( got.isDirectory(), true );
  t.identical([ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
}

//

function fileCopy( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var testData = 'Lorem ipsum dolor sit amet';
  provider.fileDelete( testDirectory );

  //

  t.description = 'src not exist';

  /**/

  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileCopy
    ({
      pathSrc : filePath,
      pathDst : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = null;
  t.identical( got, expected );

  /**/

  cachingStats._cacheStats = {};
  t.mustNotThrowError( function()
  {
    cachingStats.fileCopy
    ({
      pathSrc : filePath,
      pathDst : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 0,
    });
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = null;
  t.identical( got, expected );

  //

  t.description = 'dst not exist';
  var pathDst = _.pathJoin( testDirectory, 'dst' );

  /* file */

  cachingStats._cacheStats = {};
  provider.fileWrite( filePath, testData );
  cachingStats.fileCopy
  ({
    pathSrc : filePath,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1,
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( pathDst ) ];
  var expected = provider.fileStat( pathDst );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* file, rewriting dst - terminal file  */

  cachingStats._cacheStats = {};
  var pathDst = _.pathJoin( testDirectory, 'dst' );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( pathDst, testData + testData );
  cachingStats.fileCopy
  ({
    pathSrc : filePath,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1,
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( pathDst ) ];
  var expected = provider.fileStat( pathDst );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* file, rewriting dst - terminal file, rewriting off  */

  cachingStats._cacheStats = {};
  var pathDst = _.pathJoin( testDirectory, 'dst' );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( pathDst, testData + testData );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileCopy
    ({
      pathSrc : filePath,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 1,
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( pathDst ) ];
  var expected = provider.fileStat( pathDst );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );

  /* copy folders, src is not a terminal file */

  cachingStats._cacheStats = {};
  pathDst = testDirectory + '_';
  provider.fileWrite( filePath, testData );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileCopy
    ({
      pathSrc : testDirectory,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  })

  var got = cachingStats._cacheStats[ _.pathResolve( testDirectory ) ];
  var expected = provider.fileStat( testDirectory );
  t.identical( [ got.dev, got.ino,got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( pathDst ) ];
  t.identical( got, undefined );
}

//

function fileExchange( t )
{
  var filePath = _.pathJoin( testDirectory,'file' );
  var filePath2 = _.pathJoin( testDirectory + '_','file2' );
  var testData = 'Lorem ipsum dolor sit amet';
  provider.fileDelete( testDirectory );

  //

  t.description = 'swap two files content';

  /**/

  provider.fileWrite( filePath, testData );
  provider.fileWrite( filePath2, testData + testData );
  var expected1 = provider.fileStat( filePath );
  var expected2 = provider.fileStat( filePath2 );
  cachingStats.fileExchange( filePath2, filePath );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( [ got.dev, got.ino,got.size ], [ expected2.dev, expected2.ino, expected2.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( [ got.dev, got.ino,got.size ], [ expected1.dev, expected1.ino, expected1.size ] );

  //

  t.description = 'swap content of two dirs';

  /**/

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( filePath2, testData + testData );
  var expected1 = provider.fileStat( _.pathDir( filePath ) );
  var expected2 = provider.fileStat( _.pathDir( filePath2 ) );
  cachingStats.fileExchange( _.pathDir( filePath2 ), _.pathDir( filePath ) );
  var got = cachingStats._cacheStats[ _.pathResolve( _.pathDir( filePath ) ) ];
  t.identical( [ got.dev, got.ino,got.size ], [ expected2.dev, expected2.ino, expected2.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( _.pathDir( filePath2 ) ) ];
  t.identical( [ got.dev, got.ino,got.size ], [ expected1.dev, expected1.ino, expected1.size ] );

  /* stat of files from dirs are cached before exchange */

  cachingStats._cacheStats = {};
  provider.fileDelete( testDirectory );
  provider.fileWrite( filePath, testData );
  provider.fileWrite( filePath2, testData + testData );
  var expected1 = provider.fileStat( _.pathDir( filePath ) );
  var expected2 = provider.fileStat( _.pathDir( filePath2 ) );
  cachingStats.fileStat( filePath );
  cachingStats.fileStat( filePath2 );
  cachingStats.fileExchange( _.pathDir( filePath2 ), _.pathDir( filePath ) );
  var got = cachingStats._cacheStats[ _.pathResolve( _.pathDir( filePath ) ) ];
  t.identical( [ got.dev, got.ino,got.size ], [ expected2.dev, expected2.ino, expected2.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( _.pathDir( filePath2 ) ) ];
  t.identical( [ got.dev, got.ino,got.size ], [ expected1.dev, expected1.ino, expected1.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, undefined );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, undefined );

  //

  t.description = 'src not exist';

  /* allowMissing off, throwing on */

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 0
    });
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  /* allowMissing off, throwing off */

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 0
    });
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  /* allowMissing on, throwing on */

  cachingStats._cacheStats = {};
  var filePath2 = _.pathJoin( testDirectory, 'file2' )
  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath2, testData + testData );
  var expected = provider.fileStat( filePath2 );
  cachingStats.fileExchange
  ({
    pathDst : filePath2,
    pathSrc : filePath,
    throwing : 1,
    allowMissing : 1
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  //

  t.description = 'dst not exist';
  var filePath2 = _.pathJoin( testDirectory, 'file2' );

  /**/

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  var expected = provider.fileStat( filePath );
  cachingStats.fileExchange
  ({
    pathDst : filePath2,
    pathSrc : filePath,
    throwing : 1,
    allowMissing : 1
  });
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );

  /**/

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 0
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  /**/

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  provider.fileWrite( filePath, testData );
  t.mustNotThrowError( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 0
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( [ got.dev, got.ino, got.size ], [ expected.dev, expected.ino, expected.size ] );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  //

  t.description = 'src & dst not exist';
  var filePath2 = _.pathJoin( testDirectory, 'file2' );

  /**/

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 1
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  /* throwing 0, allowMissing 1 */

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 1
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  /* throwing 1, allowMissing 0 */

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  t.shouldThrowErrorSync( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 1,
      allowMissing : 0
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

  /* throwing 0, allowMissing 0 */

  cachingStats._cacheStats = {};
  provider.fileDelete( _.pathDir( testDirectory ) );
  t.mustNotThrowError( function()
  {
    cachingStats.fileExchange
    ({
      pathDst : filePath2,
      pathSrc : filePath,
      throwing : 0,
      allowMissing : 0
    });
  })
  var got = cachingStats._cacheStats[ _.pathResolve( filePath ) ];
  var expected = provider.fileStat( filePath );
  t.identical( got, null );
  var got = cachingStats._cacheStats[ _.pathResolve( filePath2 ) ];
  t.identical( got, null );

}

// --
// proto
// --

var Self =
{

  name : 'FileFilter.CachingStats',

  tests :
  {
    simple : simple,
    fileStat : fileStat,
    filesFind : filesFind,

    fileRead : fileRead,
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
