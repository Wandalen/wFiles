( function _FileProvider_Caching_test_ss_( ) {

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
var testDirectory = __dirname + '/../../../../tmp.tmp/caching';

var provider = _.fileProvider;
var testData = 'data';

_.assert( Parent );

//

function fileWatcher( t )
{
  provider.fileDelete( testDirectory );
  provider.directoryMake( testDirectory );
  var filePath = _.pathResolve( _.pathJoin( testDirectory, 'file' ) );
  var pathDir = provider.pathNativize( testDirectory );

  //

  t.description = 'Caching.fileWatcher test';

  var caching = _.FileFilter.Caching({ watchPath : testDirectory });
  var onReady = caching.fileWatcher.onReady.split();
  var onUpdate = caching.fileWatcher.onUpdate;

  var pathDst = _.pathResolve( _.pathJoin( pathDir, 'dst' ) );

  function _cacheFile( filePath, clear )
  {
    if( clear )
    {
      caching._cacheStats = {};
      caching._cacheDir = {};
      caching._cacheRecord = {};
    }

    caching.fileStat( filePath );
    caching.directoryRead( filePath );
    caching.fileRecord( filePath, { fileProvider : provider } );
  }

  /* write file, file cached */

  onReady
  .got( function ()
  {
    _cacheFile( filePath );
    provider.fileWrite( filePath, testData );
    onUpdate.got( function ()
    {
      var got = caching._cacheStats[ filePath ];
      var expected = provider.fileStat( filePath );
      t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
      var got = caching._cacheRecord[ filePath ][ 1 ].stat;
      t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
      var got = caching._cacheDir[ filePath ];
      var expected = [ _.pathName( filePath ) ];
      t.identical( got, expected );
      onReady.give();
    })
  })

  /* write file, dir cached */

  .got( function ()
  {
    _cacheFile( _.pathResolve( pathDir ), true );
    provider.fileWrite( filePath, testData );
    onUpdate.got( function ()
    {
      var pathDir = _.pathResolve( _.pathDir( filePath ) );
      var got = caching._cacheStats[ pathDir ];
      var expected = provider.fileStat( pathDir );
      t.identical( [ got.dev, got.size, got.ino, got.isDirectory() ], [ expected.dev, expected.size, expected.ino,expected.isDirectory() ] );
      var got = caching._cacheRecord[ pathDir ][ 1 ].stat;
      t.identical( [ got.dev, got.size, got.ino, got.isDirectory() ], [ expected.dev, expected.size, expected.ino,expected.isDirectory() ] );
      var got = caching._cacheDir[ pathDir ];
      var expected = [ _.pathName( filePath ) ];
      t.identical( got, expected );
      onReady.give();
    })
  })

  /* delete file, file cached */

  .got( function ()
  {
    _cacheFile( filePath, true );
    provider.fileDelete( filePath );
    onUpdate.got( function ()
    {
      var got = caching._cacheStats[ filePath ];
      t.identical( got, null );
      var got = caching._cacheRecord[ filePath ][ 1 ];
      t.identical( got, null );
      var got = caching._cacheDir[ filePath ];
      var expected = null;
      t.identical( got, expected );
      onReady.give();
    })
  })

  /* write big file */

  .got( function ()
  {
    _cacheFile( filePath, true );
    var data = _.strDup( testData, 8000000 );
    provider.fileWrite( filePath, data )
    onUpdate.got( function ()
    {
      var got = caching._cacheStats[ filePath ];
      var expected = provider.fileStat( filePath );
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheRecord[ filePath ][ 1 ].stat;
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheDir[ filePath ];
      var expected = [ _.pathName( filePath ) ];
      t.identical( got, expected );
      onReady.give();
    })
  })

  /* copy file */

  .got( function ()
  {
    _cacheFile( pathDst, true );
    provider.fileWrite( filePath, testData );
    onUpdate.got( function ()
    {
      provider.fileCopy( pathDst, filePath );
    })
    onUpdate.got( function ()
    {
      var got = caching._cacheStats[ pathDst ];
      var expected = provider.fileStat( pathDst );
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheRecord[ pathDst ][ 1 ].stat;
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheDir[ pathDst ];
      var expected = [ _.pathName( pathDst ) ];
      t.identical( got, expected );
      onReady.give();
    })
  })

  /* !!! onUpdate is not receiving any messages is call this case in sequence with others */

  .got( function ()
  {
    _cacheFile( pathDst, true );

    provider.fileWrite( filePath, testData );

    /* After fileWrite call, no events emmited by chokidar, can be fixed if add delay.
    Problem appears if run this case in sequence with other cases
    */

    onUpdate = onUpdate.eitherThenSplit( _.timeOutError( 3000 ) );
    t.mustNotThrowError( onUpdate.split() );

    onUpdate.got( function ( err )
    {
      if( err )
      return onReady.give();

      provider.fileCopy( pathDst, filePath );
    })
    onUpdate.got( function ()
    {
      var got = caching._cacheStats[ pathDst ];
      var expected = provider.fileStat( pathDst );
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheRecord[ pathDst ][ 1 ].stat;
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheDir[ pathDst ];
      var expected = [ _.pathName( pathDst ) ];
      t.identical( got, expected );
      onReady.give();
    })
  })

  /* immediate writing and deleting of a file gives timeOutError becase no events emitted by chokidar */

  .got( function ()
  {
    var newFile = _.pathResolve( _.pathJoin( pathDir, 'new' ) );
    _cacheFile( newFile, true );

    provider.fileWrite( newFile, testData );

    onUpdate = onUpdate.eitherThenSplit( _.timeOutError( 3000 ) );
    t.mustNotThrowError( onUpdate.split() );

    onUpdate.got( function ( err, got )
    {
      if( err )
      return onReady.give();

      var got = caching._cacheStats[ newFile ];
      var expected = provider.fileStat( newFile );
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheRecord[ newFile ][ 1 ].stat;
      t.identical( [ got.dev, got.size, got.ino, got.isFile() ], [ expected.dev, expected.size, expected.ino,expected.isFile() ] );
      var got = caching._cacheDir[ pathDst ];
      var expected = [ _.pathName( pathDst ) ];
      t.identical( got, expected );
      onReady.give();
    })

  })

  return onReady;
}

fileWatcher.timeOut = 40000;


//

function fileWatcherOnReady( t )
{
  var filePath = _.pathResolve( _.pathJoin( testDirectory, 'file' ) );
  var pathDir = provider.pathNativize( _.pathDir( filePath ) );

  var caching = _.FileFilter.Caching({ watchPath : pathDir, watchOptions : { skipEvents : true } });
  var onReady = caching.fileWatcher.onReady.eitherThenSplit( _.timeOutError( 30000 ) );

  //

  t.description = 'Caching.fileWatcher onReady consequence test'

  /**/

  return t.shouldThrowErrorAsync( onReady );
}

fileWatcherOnReady.timeOut = 40000;

//

function fileWatcherOnUpdate( t )
{
  var filePath = _.pathResolve( _.pathJoin( testDirectory, 'file' ) );
  var pathDir = provider.pathNativize( _.pathDir( filePath ) );

  var caching = _.FileFilter.Caching({ watchPath : pathDir, watchOptions : {} });
  var onReady = caching.fileWatcher.onReady.split();
  var onUpdate = caching.fileWatcher.onUpdate.eitherThenSplit( _.timeOutError( 30000 ) );

  //

  t.description = 'Caching.fileWatcher onUpdate consequence test'

  /**/

  onReady.doThen( function ( err, got )
  {
    t.identical( got, 'ready' );

    return t.shouldThrowErrorAsync( onUpdate );
  })

  return onReady;
}

fileWatcherOnUpdate.timeOut = 40000;

//

// --
// proto
// --

var Self =
{

  name : 'Filter.Caching',

  tests :
  {
    fileWatcher : fileWatcher,
    fileWatcherOnReady : fileWatcherOnReady,
    fileWatcherOnUpdate : fileWatcherOnUpdate,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
