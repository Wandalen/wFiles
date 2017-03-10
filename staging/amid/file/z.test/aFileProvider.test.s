( function _FileProvider_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  try
  {
    require( '../../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  // _.assert( !_.fileProvider );
  require( '../Files.ss' );

  _.include( 'wTesting' );

  var crypto = require( 'crypto' );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

//

function makePath( pathFile )
{
  return pathFile;
}

function shouldWriteOnlyOnce( test, pathFile, expected )
{
  var self = this;

  test.description = 'shouldWriteOnlyOnce test';
  var files = self.provider.directoryRead( self.makePath( pathFile ) );
  test.identical( files, expected );
}

// --
// tests
// --

function testDelaySample( test )
{
  var self = this;

  debugger;

  test.description = 'delay test';

  var con = _.timeOut( 1000 );

  test.identical( 1,1 );

  con.doThen( function( ){ logger.log( '1000ms delay' ) } );

  con.doThen( _.routineSeal( _,_.timeOut,[ 1000 ] ) );

  con.doThen( function( ){ logger.log( '2000ms delay' ) } );

  con.doThen( function( ){ test.identical( 1,1 ); } );

  return con;
}

//

function mustNotThrowError( test )
{

  test.description = 'if passes dont appears in output/passed test cases/total counter';
  test.mustNotThrowError( function ()
  {
  });

  test.description = 'if not passes then appears in output/total counter';
  test.mustNotThrowError( function ()
  {
    throw _.err( 'test' );
  });
}

//

function readWriteSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var dir = test.special.makePath( 'written/readWriteSync' );
  var got, pathFile, readOptions, writeOptions;
  var testData = 'Lorem ipsum dolor sit amet';

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'fileRead, invalid path';

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      pathFile : 'invalid path',
      sync : 1,
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.fileRead
    ({
      pathFile : 'invalid path',
      sync : 1,
      throwing : 0,
    })
  })

  //

  test.description = 'fileRead, path ways to not a terminal file';
  pathFile = test.special.makePath( 'written/readWriteSync/dir' );
  self.provider.directoryMake( pathFile );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1,
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1,
      throwing : 0,
    })
  });

  //

  test.description = 'fileRead,simple file read ';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/readWriteSync/file' );
  self.provider.fileWrite( pathFile, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1,
      returnRead : 0,
      encoding : 'utf8',
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1,
      returnRead : 1,
      encoding : 'utf8',
      throwing : 1,
    })
  });
  test.identical( got, testData );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1,
      returnRead : 1,
      encoding : 'unknown',
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1,
      returnRead : 1,
      encoding : 'unknown',
      throwing : 0,
    })
  });

  //

  test.description = 'fileRead,file read with common encodings';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/readWriteSync/file' );

  /**/

  testData = { a : 'abc' };
  self.provider.fileWrite( pathFile, JSON.stringify( testData ) );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1,
    returnRead : 1,
    encoding : 'json',
    throwing : 1,
  });
  test.identical( got , testData );

  /**/

  testData = ' 1 + 2';
  self.provider.fileWrite( pathFile, testData );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1,
    returnRead : 1,
    encoding : 'js',
    throwing : 1,
  });
  test.identical( got , _.exec( testData ) );

  //

  test.description = 'fileRead,onBegin,onEnd,onError';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  function onBegin( err, o )
  {
    self.provider.fileWrite( pathFile, testData );
    if( o )
    got = o;
  }
  function onEnd( err, data )
  {
    got = data;
  }
  function onError( err )
  {
    got = err;
  }

  /*onBegin wrap 0*/

  got = self.provider.fileRead
  ({
    sync : 1,
    wrap : 0,
    returnRead : 1,
    throwing : 1,
    pathFile : pathFile,
    encoding : 'utf8',
    onBegin : onBegin,
    onEnd : null,
    onError : null,
  });
  test.identical( got, testData );

  /*onBegin wrap 1*/

  self.provider.fileRead
  ({
    sync : 1,
    wrap : 1,
    returnRead : 1,
    throwing : 1,
    pathFile : pathFile,
    encoding : 'utf8',
    onBegin : onBegin,
    onEnd : null,
    onError : null,
  });
  test.identical( _.objectIs( got.options ), true );

  /*onEnd wrap 0*/

  self.provider.fileRead
  ({
    sync : 1,
    wrap : 0,
    returnRead : 1,
    throwing : 1,
    pathFile : pathFile,
    encoding : 'utf8',
    onBegin : null,
    onEnd : onEnd,
    onError : null,
  });
  test.identical( got, testData );

  /*onEnd wrap 1*/

  self.provider.fileRead
  ({
    sync : 1,
    wrap : 1,
    returnRead : 1,
    throwing : 1,
    pathFile : pathFile,
    encoding : 'utf8',
    onBegin : null,
    onEnd : onEnd,
    onError : null,
  });
  test.identical( got.data, testData );

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      wrap : 0,
      returnRead : 1,
      throwing : 1,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errorIs( got ), true )

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      wrap : 1,
      returnRead : 1,
      throwing : 1,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errorIs( got ), true );

  /*onError is no called*/

  test.mustNotThrowError( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      wrap : 0,
      returnRead : 1,
      throwing : 0,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errorIs( got ), true );

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      wrap : 0,
      returnRead : 1,
      throwing : 1,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errorIs( got ), true );

  //fileWrite

  //

  test.description = 'fileWrite, path not exist,default settings';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';

  /**/

  self.provider.fileWrite( pathFile, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  /*path includes not existing directory*/
  pathFile = test.special.makePath( 'written/readWriteSync/file/file.txt' );
  self.provider.fileWrite( pathFile, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.description = 'fileWrite, path already exist,default settings';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  self.provider.fileWrite( pathFile, testData );

  /**/

  self.provider.fileWrite( pathFile, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  /*try rewrite folder*/
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileWrite( dir, testData );
  });

  //

  test.description = 'fileWrite, path already exist';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  self.provider.fileWrite( pathFile, testData );

  /**/

  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    makingDirectory : 1,
    purging : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  /**/

  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    makingDirectory : 0,
    purging : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  /**/

  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    makingDirectory : 0,
    purging : 0,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.description = 'fileWrite, path not exist';
  self.provider.fileDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  pathFile = test.special.makePath( 'written/readWriteSync/file' );


  /*path includes not existing directory*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 1,
      makingDirectory : 0,
      purging : 0,
    });
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, null );

  /*file not exist*/

  self.provider.directoryMake( dir );
  test.mustNotThrowError( function()
  {
    self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 1,
      makingDirectory : 0,
      purging : 0,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  /*purging non existing filePath*/

  self.provider.fileDelete( pathFile );
  test.mustNotThrowError( function()
  {
    self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 1,
      makingDirectory : 0,
      purging : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.description = 'fileWrite, different write modes';
  self.provider.fileDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  pathFile = test.special.makePath( 'written/readWriteSync/file' );

  /*rewrite*/

  self.provider.fileWrite( pathFile, '' );
  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    writeMode : 'rewrite'
  });
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  /*prepend*/

  self.provider.fileWrite( pathFile, testData );
  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    writeMode : 'prepend'
  });
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData+testData );

  /*append*/

  self.provider.fileWrite( pathFile, testData );
  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    writeMode : 'append'
  });
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData+testData );

  //

  test.description = 'fileWrite, any writeMode should create file it not exist';
  self.provider.fileDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  pathFile = test.special.makePath( 'written/readWriteSync/file' );

  /*rewrite*/

  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    writeMode : 'rewrite'
  });
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  /*prepend*/

  self.provider.fileDelete( pathFile );
  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    writeMode : 'prepend'
  });
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  /*append*/

  self.provider.fileDelete( pathFile );
  self.provider.fileWrite
  ({
    pathFile : pathFile,
    data : testData,
    sync : 1,
    writeMode : 'append'
  });
  got = self.provider.fileRead
  ({
    pathFile : pathFile,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  //

  if( !isBrowser )
  {
    test.description = 'fileWrite, data is node buffer';
    self.provider.fileDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    var buffer = new Buffer( testData );
    pathFile = test.special.makePath( 'written/readWriteSync/file' );

    /**/

    self.provider.fileWrite( pathFile,buffer );
    got = self.provider.fileRead
    ({
     pathFile : pathFile,
     sync : 1,
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  }

  // var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  // self.provider.fileWrite
  // ({
  //   pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
  //   data : data1,
  //   sync : 1,
  // });
  //
  // test.description = 'single file is written';
  // var files = self.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.description = 'synchronous, writeMode : rewrite';
  // var got = self.provider.fileRead
  // ({
  //   pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
  //   sync : 1
  // });
  // var expected = data1;
  // test.identical( got, expected );
  //
  // var data2 = 'LOREM';
  // self.provider.fileWrite
  // ({
  //   pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
  //   data : data2,
  //   sync : 1,
  //   writeMode : 'append'
  // });
  //
  // test.description = 'single file is written';
  // var files = self.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.description = 'synchronous, writeMode : append';
  // var got = self.provider.fileRead
  // ({
  //   pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
  //   sync : 1
  // });
  // var expected = data1 + data2;
  // test.identical( got, expected );
  //
  // var data2 = 'LOREM';
  // self.provider.fileWrite
  // ({
  //   pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
  //   data : data2,
  //   sync : 1,
  //   writeMode : 'prepend'
  // });
  //
  // test.description = 'single file is written';
  // var files = self.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.description = 'synchronous, writeMode : prepend';
  // var got = self.provider.fileRead
  // ({
  //   pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
  //   sync : 1
  // });
  // var expected = data2 + data1 + data2;
  // test.identical( got, expected );
  //
  // if( Config.debug )
  // {
  //   test.description = 'file doesn`t exist';
  //   test.shouldThrowErrorSync( function( )
  //   {
  //     self.provider.fileRead
  //     ({
  //       pathFile : test.special.makePath( 'unknown' ),
  //       sync : 1
  //     });
  //   });
  //
  //   test.description = 'try to read dir';
  //   test.shouldThrowErrorSync( function( )
  //   {
  //     self.provider.fileRead
  //     ({
  //       pathFile : test.special.makePath( './' ),
  //       sync : 1
  //     });
  //   });
  // }
}

//

function readWriteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var dir = test.special.makePath( 'written/readWriteAsync' );
  var got, pathFile, readOptions, writeOptions,onBegin,onEnd,onError,buffer;
  var testData = 'Lorem ipsum dolor sit amet';

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();
  consequence

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileRead, invalid path';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : 'invalid path',
      sync : 0,
      throwing : 1,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : 'invalid path',
      sync : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileRead, path ways to not a terminal file';
    pathFile = test.special.makePath( 'written/readWriteAsync/dir' );
    self.provider.directoryMake( pathFile );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 1,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileRead,simple file read ';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
    self.provider.fileWrite( pathFile, testData );
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      returnRead : 0,
      encoding : 'utf8',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, testData );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      returnRead : 0,
      encoding : 'unknown',
      throwing : 1,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      returnRead : 0,
      encoding : 'unknown',
      throwing : 0,
    });
    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileRead,file read with common encodings';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    testData = { a : 'abc' };
    self.provider.fileWrite( pathFile, JSON.stringify( testData ) );
    var con = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      returnRead : 0,
      encoding : 'json',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got , testData );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    testData = ' 1 + 2';
    self.provider.fileWrite( pathFile, testData );
    var con  = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 0,
      returnRead : 0,
      encoding : 'js',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got , _.exec( testData ) );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileRead,onBegin,onEnd,onError';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    onBegin = function onBegin( err, o )
    {
      self.provider.fileWrite( pathFile, testData );
      if( o )
      got = o;
    }
    onEnd = function onEnd( err, data )
    {
      got = data;
    }
    onError = function onError( err )
    {
      got = err;
    }
  })

  /*onBegin wrap 0*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
      returnRead : 0,
      throwing : 1,
      pathFile : pathFile,
      encoding : 'utf8',
      onBegin : onBegin,
      onEnd : null,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.objectIs( got), true );
    });
  })

  /*onBegin wrap 1*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 1,
      returnRead : 0,
      throwing : 1,
      pathFile : pathFile,
      encoding : 'utf8',
      onBegin : onBegin,
      onEnd : null,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.objectIs( got.options ), true );
    });
  })

  /*onEnd wrap 0*/

  .ifNoErrorThen( function ()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
      returnRead : 0,
      throwing : 1,
      pathFile : pathFile,
      encoding : 'utf8',
      onBegin : null,
      onEnd : onEnd,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( got, testData );
    });
  })

  /*onEnd wrap 1*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 1,
      returnRead : 0,
      throwing : 1,
      pathFile : pathFile,
      encoding : 'utf8',
      onBegin : null,
      onEnd : onEnd,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( got.data, testData );
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function ()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
      returnRead : 0,
      throwing : 1,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.errorIs( got ), true )
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 1,
      returnRead : 0,
      throwing : 1,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function ()
    {
      test.identical( _.errorIs( got ), true );
    });
  })

  /*onError is no called*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
      returnRead : 0,
      throwing : 0,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.errorIs( got ), true );
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
      returnRead : 0,
      throwing : 1,
      pathFile : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.errorIs( got ), true );
    });
  })

  //fileWrite

  .ifNoErrorThen( function()
  {
    test.description = 'fileWrite, path not exist,default settings';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
       sync : 0,
       pathFile : pathFile,
       data : testData,
    })
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );

    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  /*path includes not existing directory*/

  .ifNoErrorThen( function()
  {
    pathFile = test.special.makePath( 'written/readWriteAsync/file/file.txt' );
    return self.provider.fileWrite
    ({
       sync : 0,
       pathFile : pathFile,
       data : testData
    })
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  .ifNoErrorThen( function()
  {
    test.description = 'fileWrite, path already exist,default settings';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    self.provider.fileWrite( pathFile, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
       sync : 0,
       pathFile : pathFile,
       data : testData
    })
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  /*try rewrite folder*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileWrite
    ({
       sync : 0,
       pathFile : dir,
       data : testData
    });
    return test.shouldThrowErrorAsync( con );
  })

  //

  .ifNoErrorThen( function ()
  {
    test.description = 'fileWrite, path already exist';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    self.provider.fileWrite( pathFile, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      makingDirectory : 1,
      purging : 1,
    });
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 1,
    });

  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileWrite, path not exist';
    self.provider.fileDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
  })

  /*path includes not existing directory*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
    return test.shouldThrowErrorAsync( con );
  })
  .ifNoErrorThen( function ()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, null );
  })

  /*file not exist*/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( dir );
    var con = self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
    return test.mustNotThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  /*purging non existing filePath*/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathFile );
    var con = self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 1,
    });
    return test.mustNotThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    test.identical( got, testData );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileWrite, different write modes';
    self.provider.fileDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
  })

  /*rewrite*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile, '' );
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      writeMode : 'rewrite'
    });

  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /*prepend*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile, testData );
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      writeMode : 'prepend'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData+testData );
  })

  /*append*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile, testData );
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      writeMode : 'append'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData+testData );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileWrite, any writeMode should create file it not exist';
    self.provider.fileDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    pathFile = test.special.makePath( 'written/readWriteAsync/file' );
  })

  /*rewrite*/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      writeMode : 'rewrite'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /*prepend*/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathFile );
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      writeMode : 'prepend'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /*append*/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathFile );
    return self.provider.fileWrite
    ({
      pathFile : pathFile,
      data : testData,
      sync : 0,
      writeMode : 'append'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      pathFile : pathFile,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  //

  if( !isBrowser )
  {
    consequence.ifNoErrorThen( function()
    {
      test.description = 'fileWrite, data is node buffer';
      self.provider.fileDelete( dir );
      testData = 'Lorem ipsum dolor sit amet';
      buffer = new Buffer( testData );
      pathFile = test.special.makePath( 'written/readWriteAsync/file' );
    })

    /**/

    consequence.ifNoErrorThen( function()
    {
      return self.provider.fileWrite
      ({
        pathFile : pathFile,
        data : testData,
        sync : 0,
      });
    })
    .ifNoErrorThen( function()
    {
      got = self.provider.fileRead
      ({
         pathFile : pathFile,
         sync : 1,
      });
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'file' ] );
      test.identical( got, testData );
    });
  }

 return consequence;
}

//

// function writeAsyncThrowingError( test )
// {
//   var self = this;
//
//   if( !_.routineIs( self.provider.fileWrite ) )
//   return;
//
//   var consequence = new wConsequence().give();
//
//   try
//   {
//     self.provider.directoryMake
//     ({
//       pathFile : test.special.makePath( 'dir' ),
//       sync : 1
//     });
//   }
//   catch( err )
//   {
//   }
//
//
//   consequence
//   .ifNoErrorThen( function()
//   {
//
//     test.description = 'async, try to rewrite dir';
//
//     var data1 = 'data1';
//     var con = self.provider.fileWrite
//     ({
//       pathFile : test.special.makePath( 'dir' ),
//       data : data1,
//       sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   })
//
//   return consequence;
// }

//

function fileCopySync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopy ) )
  return;

  var got;

  var dir = test.special.makePath( 'written/fileCopy' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'src not exist';

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 1,
      throwing : 0,
    });
  });
  test.identical( got, false );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 0,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 0,
      throwing : 0,
    });
  });
  test.identical( got, false );

  //

  test.description = 'dst path not exist';
  var pathSrc = test.special.makePath( 'written/fileCopy/src.txt' );
  var pathDst = test.special.makePath( 'written/fileCopy/dst.txt' );
  self.provider.fileWrite( pathSrc, '' );

  /**/

  self.provider.fileCopy
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.fileDelete( pathDst );
  self.provider.fileCopy
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.fileDelete( pathDst );
  self.provider.fileCopy
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.fileDelete( pathDst );
  self.provider.fileCopy
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  //

  test.description = 'dst path exist';
  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc, '' );
  self.provider.fileWrite( pathDst, '' );

  /**/

  self.provider.fileCopy
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.fileCopy
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  //

  test.description = 'src is equal to dst';
  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc, '' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );
}

//

function fileCopyAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopy ) )
  return;

  var dir = test.special.makePath( 'written/fileCopyAsync' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var pathSrc = test.special.makePath( 'written/fileCopyAsync/src.txt' );
  var pathDst = test.special.makePath( 'written/fileCopyAsync/dst.txt' );

  var consequence = new wConsequence().give();

  //

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'src not exist';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 1,
      throwing : 1,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 1,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 0,
      throwing : 1,
    });
    return test.shouldThrowErrorAsync( con )
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'dst path not exist';
    self.provider.fileWrite( pathSrc, '' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathDst );
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathDst );
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathDst );
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'dst path exist';
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc, '' );
    self.provider.fileWrite( pathDst, '' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    })
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'src is equal to dst';
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc, '' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  return consequence;
}

//

// function fileCopyAsyncThrowingError( test )
// {
//   var self = this;
//
//   if( !_.routineIs( self.provider.fileCopy ) )
//   return;
//
//   var dir = test.special.makePath( 'written/fileCopyAsync' );
//
//   if( !self.provider.fileStat( dir ) )
//   self.provider.directoryMake( dir );
//
//   var consequence = new wConsequence().give();
//
//   consequence
//   .ifNoErrorThen( function()
//   {
//     test.description = 'async, throwing error';
//     var con = self.provider.fileCopy
//     ({
//       pathSrc : test.special.makePath( 'invalid.txt' ),
//       pathDst : test.special.makePath( 'pathDst.txt' ),
//       sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   })
//   .ifNoErrorThen( function()
//   {
//     test.description = 'async,try rewrite dir';
//     var con = self.provider.fileCopy
//     ({
//       pathSrc : test.special.makePath( 'invalid.txt' ),
//       pathDst : test.special.makePath( 'tmp' ),
//       sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   })
//   .ifNoErrorThen( function()
//   {
//     test.description = 'async copy dir';
//     try
//     {
//       self.provider.directoryMake
//       ({
//         pathFile : test.special.makePath( 'written/fileCopyAsync/copydir' ),
//         sync : 1
//       });
//       self.provider.fileWrite
//       ({
//         pathFile : test.special.makePath( 'written/fileCopyAsync/copydir/copyfile.txt' ),
//         data : 'Lorem',
//         sync : 1
//       });
//     } catch ( err ) { }
//
//     debugger;
//     var con = self.provider.fileCopy
//     ({
//         pathSrc : test.special.makePath( 'written/fileCopyAsync/copydir' ),
//         pathDst : test.special.makePath( 'written/fileCopyAsync/copydir2' ),
//         sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   });
//
//   return consequence;
// }

//

function fileRenameSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRename ) )
  return;

  var got;
  var pathSrc = test.special.makePath( 'written/fileRename/src' );
  var pathDst = test.special.makePath( 'written/fileRename/dst' );
  var dir  = _.pathDir( pathSrc );

  //

  test.description = 'src not exist';

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 1,
      throwing : 0,
    });
  });
  test.identical( got, false );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 0,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 1,
      rewriting : 0,
      throwing : 0,
    });
  });
  test.identical( got, false );

  //

  test.description = 'rename in same directory,dst not exist';

  /**/

  self.provider.fileWrite( pathSrc, '' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc, '' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc, '' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc, '' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  //

  test.description = 'rename with rewriting in same directory';

  /**/

  self.provider.fileWrite( pathSrc, '' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileWrite( pathSrc, '' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileWrite( pathSrc, '' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );

  //

  test.description = 'rename dir, dst not exist';
  self.provider.fileDelete( dir );

  /**/

  self.provider.directoryMake( pathSrc );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( pathDst );
  self.provider.directoryMake( pathSrc );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( pathDst );
  self.provider.directoryMake( pathSrc );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( pathDst );
  self.provider.directoryMake( pathSrc );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  //

  test.description = 'rename moving to other existing dir';

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( pathDst ) );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( pathDst ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( pathDst ) );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( pathDst ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( pathDst ) );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( pathDst ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( pathDst ) );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( pathDst ) );
  test.identical( files, [ 'dst' ] );

  //

  test.description = 'rename moving to not existing dir';

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, false )
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false )
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.description = 'dst is not empty dir';

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( pathDst,'' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : _.pathDir( pathDst ),
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( pathDst,'' );
  got = self.provider.fileRename
  ({
    pathSrc : pathSrc,
    pathDst : _.pathDir( pathDst ),
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( pathDst,'' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : _.pathDir( pathDst ),
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );
  pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( pathDst,'' );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : _.pathDir( pathDst ),
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir','src' ] );

  //src is equal to dst

  test.description = 'src is equal to dst';

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathSrc,'' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

}

//

function fileRenameAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRename ) )
  return;

  var got;
  var pathSrc = test.special.makePath( 'written/fileRenameAsync/src' );
  var pathDst = test.special.makePath( 'written/fileRenameAsync/dst' );
  var dir  = _.pathDir( pathSrc );


  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'src not exist';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 1,
      throwing : 1,
    });

    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 1,
      throwing : 0,
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 0,
      throwing : 1,
    });

    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : 'not_exising_path',
      pathDst : '',
      sync : 0,
      rewriting : 0,
      throwing : 0,
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function ()
  {
    test.description = 'rename in same directory,dst not exist';
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'rename with rewriting in same directory';
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });

  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });

  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathSrc, '' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function ()
  {
    test.description = 'rename dir, dst not exist';
    self.provider.fileDelete( dir );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( pathSrc );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathDst );
    self.provider.directoryMake( pathSrc );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathDst );
    self.provider.directoryMake( pathSrc );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( pathDst );
    self.provider.directoryMake( pathSrc );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'rename moving to other existing dir';
    pathDst = test.special.makePath( 'written/fileRenameAsync/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.directoryMake( _.pathDir( pathDst ) );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.pathDir( pathDst ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.directoryMake( _.pathDir( pathDst ) );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.pathDir( pathDst ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.directoryMake( _.pathDir( pathDst ) );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.pathDir( pathDst ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.directoryMake( _.pathDir( pathDst ) );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.pathDir( pathDst ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'rename moving to not existing dir';
    pathDst = test.special.makePath( 'written/fileRename/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'dst is not empty dir';
    pathDst = test.special.makePath( 'written/fileRenameAsync/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.fileWrite( pathDst,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : _.pathDir( pathDst ),
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.fileWrite( pathDst,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : _.pathDir( pathDst ),
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.fileWrite( pathDst,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : _.pathDir( pathDst ),
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
    self.provider.fileWrite( pathDst,'' );
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : _.pathDir( pathDst ),
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir','src' ] );
    });
  })

  //src is equal to dst

  .ifNoErrorThen( function()
  {
    test.description = 'src is equal to dst';
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathSrc,'' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  return consequence;
}

//

function fileDeleteSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDelete ) )
  return;

  var dir = test.special.makePath( 'written/fileDelete' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'removing not existing path';

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileDelete
    ({
      pathFile : 'not_exising_path',
      sync : 1,
      force : 0
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.fileDelete
    ({
      pathFile : 'not_exising_path',
      sync : 1,
      force : 1
    });
  });

  //

  test.description = 'removing existing file';
  var pathFile = test.special.makePath( 'written/fileDelete/file.txt');

  /**/

  self.provider.fileWrite( pathFile, '' );
  self.provider.fileDelete
  ({
    pathFile : pathFile,
    sync : 1,
    force : 0
  });
  var stat = self.provider.fileStat( pathFile );
  test.identical( stat, null );

  /**/

  self.provider.fileWrite( pathFile, '' );
  self.provider.fileDelete
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1
  });
  var stat = self.provider.fileStat( pathFile );
  test.identical( stat, null );

  //

  test.description = 'removing empty folder';
  var pathFile = test.special.makePath( 'written/fileDelete/folder');

  /**/

  self.provider.directoryMake( pathFile );
  self.provider.fileDelete
  ({
    pathFile : pathFile,
    sync : 1,
    force : 0
  });
  var stat = self.provider.fileStat( pathFile );
  test.identical( stat, null );

  /**/

  self.provider.directoryMake( pathFile );
  self.provider.fileDelete
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1
  });
  var stat = self.provider.fileStat( pathFile );
  test.identical( stat, null );

  //

  test.description = 'try removing folder with file';
  var pathFile = test.special.makePath( 'written/fileDelete/folder/file.txt');
  var pathFolder = _.pathDir( pathFile );

  /**/

  self.provider.fileWrite( pathFile,'' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileDelete
    ({
      pathFile : pathFolder,
      sync : 1,
      force : 0
    })
  });
  var stat = self.provider.fileStat( pathFolder );
  test.identical( _.objectIs( stat ), true );

  /**/

  self.provider.fileDelete
  ({
    pathFile : pathFolder,
    sync : 1,
    force : 1
  });
  var stat = self.provider.fileStat( pathFolder );
  test.identical( stat, null );

  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDelete/dir' ),
  //     sync : 1
  //   });
  //
  //   self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete' ),[ 'dir' ] );
  //
  // } catch ( err ){ }
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDelete/dir/dir2' ),
  //     sync : 1
  //   });
  //
  //   self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/dir' ),[ 'dir2' ] );
  //
  // } catch ( err ){ }
  //
  // var data1 = 'Excepteur sint occaecat cupidatat non proident';
  // self.provider.fileWrite
  // ({
  //     pathFile : test.special.makePath( 'written/fileDelete/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/' ),[ 'dir','src.txt' ] );
  //
  // self.provider.fileWrite
  // ({
  //     pathFile : test.special.makePath( 'written/fileDelete/dir/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/dir' ),[ 'dir2','src.txt' ] );
  //
  // self.provider.fileWrite
  // ({
  //     pathFile : test.special.makePath( 'written/fileDelete/dir/dir2/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/dir/dir2' ),[ 'src.txt' ] );
  //
  // test.description = 'synchronous delete';
  // self.provider.fileDelete
  // ({
  //   pathFile : test.special.makePath( 'written/fileDelete/src.txt' ),
  //   sync : 1
  // });
  // var got = self.provider.fileStat
  // ({
  //   pathFile : test.special.makePath( 'written/fileDelete/src.txt' ),
  //   sync : 1
  // });
  // var expected = null;
  // test.identical( got, expected );
  //
  // test.description = 'synchronous delete empty dir';
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDelete/empty_dir' ),
  //     sync : 1
  //   });
  // } catch ( err ){ }
  // self.provider.fileDelete
  // ({
  //   pathFile : test.special.makePath( 'written/fileDelete/empty_dir' ),
  //   force : 0,
  //   sync : 1
  // });
  // var got = self.provider.fileStat
  // ({
  //   pathFile : test.special.makePath( 'written/fileDelete/empty_dir' ),
  //   sync : 1
  // });
  // var expected = null;
  // test.identical( got, expected );
  //
  // if( Config.debug )
  // {
  //   test.description = 'invalid path';
  //   test.shouldThrowErrorSync( function()
  //   {
  //     self.provider.fileDelete
  //     ({
  //         pathFile : test.special.makePath( '///bad path///test.txt' ),
  //         sync : 1,
  //     });
  //   });
  //
  //   test.description = 'not empty dir';
  //   test.shouldThrowErrorSync( function()
  //   {
  //     self.provider.fileDelete
  //     ({
  //         pathFile : test.special.makePath( 'written/fileDelete/dir' ),
  //         force : 0,
  //         sync : 1,
  //     });
  //   });
  //
  //   test.description = 'not empty dir inner level';
  //   test.shouldThrowErrorSync( function()
  //   {
  //     self.provider.fileDelete
  //     ({
  //         pathFile : test.special.makePath( 'written/fileDelete/dir/dir2' ),
  //         force : 0,
  //         sync : 1,
  //     });
  //   });
  // }
  //
  // test.description = 'dir with files';
  // self.provider.fileDelete
  // ({
  //   pathFile : test.special.makePath( 'written/fileDelete/dir' ),
  //   force : 1,
  //   sync : 1
  // });
  // var got = self.provider.fileStat
  // ({
  //   pathFile : test.special.makePath( 'written/fileDelete/dir' ),
  //   sync : 1
  // });
  // var expected = null;
  // test.identical( got, expected );

}

//

function fileDeleteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDelete ) )
  return;

  var pathFile,pathFolder;

  var dir = test.special.makePath( 'written/fileDeleteAsync' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'removing not existing path';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileDelete
    ({
      pathFile : 'not_exising_path',
      sync : 0,
      force : 0
    });

    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileDelete
    ({
      pathFile : 'not_exising_path',
      sync : 0,
      force : 1
    });

    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'removing file';
    pathFile = test.special.makePath( 'written/fileDeleteAsync/file.txt');
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile,'' );
    var con = self.provider.fileDelete
    ({
      pathFile : pathFile,
      sync : 0,
      force : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( pathFile );
      test.identical( stat, null );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile,'' );
    var con = self.provider.fileDelete
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( pathFile );
      test.identical( stat, null );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'removing existing empty folder';
    pathFile = test.special.makePath( 'written/fileDeleteAsync/folder');
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( pathFile );
    var con = self.provider.fileDelete
    ({
      pathFile : pathFile,
      sync : 0,
      force : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( pathFile );
      test.identical( stat, null );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( pathFile );
    var con = self.provider.fileDelete
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( pathFile );
      test.identical( stat, null );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'removing existing folder with file';
    pathFile = test.special.makePath( 'written/fileDeleteAsync/folder/file.txt');

  })

  /**/

  .ifNoErrorThen( function()
  {
    pathFolder = _.pathDir( pathFile );
    self.provider.fileWrite( pathFile,'' );
    var con = self.provider.fileDelete
    ({
      pathFile : pathFolder,
      sync : 0,
      force : 0
    });

    return test.shouldThrowErrorAsync( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( pathFolder );
      test.identical( _.objectIs( stat ), true );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileDelete
    ({
      pathFile : pathFolder,
      sync : 0,
      force : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( pathFolder );
      test.identical( stat, null );
    });
  })

  return consequence;

  // var consequence = new wConsequence().give();
  // var data1 = 'Excepteur sint occaecat cupidatat non proident';
  //
  // var dir = test.special.makePath( 'written/fileDeleteAsync' );
  //
  // if( !self.provider.fileStat( dir ) )
  // self.provider.directoryMake( dir );
  //
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/dir' ),
  //     sync : 1
  //   });
  //
  // } catch ( err ){ }
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync' ),[ 'dir' ] );
  //
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/dir2' ),
  //     sync : 1
  //   });
  //
  // } catch ( err ){ }
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync/dir' ),[ 'dir2' ] );
  //
  //
  // self.provider.fileWrite
  // ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/dir2/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync/dir/dir2' ),[ 'src.txt' ] );
  //
  // var data1 = 'Excepteur sint occaecat cupidatat non proident';
  // self.provider.fileWrite
  // ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync' ),[ 'dir','src.txt' ] );
  //
  // consequence
  // .ifNoErrorThen( function()
  // {
  //   self.provider.fileWrite
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/src.txt' ),
  //     data : data1,
  //     sync : 1,
  //   });
  //
  //   self.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync/dir' ),[ 'dir2','src.txt' ] );
  //
  //   test.description = 'asynchronous delete';
  //   var con = self.provider.fileDelete
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/src.txt' ),
  //     sync : 0
  //   });
  //
  //   return test.shouldMessageOnlyOnce( con );
  // })
  // .ifNoErrorThen( function( err )
  // {
  //   var got = self.provider.fileStat
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/src.txt' ),
  //     sync : 1
  //   });
  //   var expected = null;
  //   test.identical( got, expected );
  // })
  // .ifNoErrorThen( function ()
  // {
  //   test.description = 'synchronous delete empty dir';
  //   try
  //   {
  //     self.provider.directoryMake
  //     ({
  //       pathFile : test.special.makePath( 'written/fileDeleteAsync/empty_dir' ),
  //       sync : 1
  //     });
  //   } catch ( err ){ }
  //
  //   var con = self.provider.fileDelete
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/empty_dir' ),
  //     sync : 0
  //   });
  //
  //   return test.shouldMessageOnlyOnce( con );
  // })
  // .ifNoErrorThen( function( err )
  // {
  //   var got = self.provider.fileStat
  //   ({
  //     pathFile : test.special.makePath( 'written/fileDeleteAsync/empty_dir' ),
  //     sync : 1
  //   });
  //   var expected = null;
  //   test.identical( got, expected );
  // })
  // .ifNoErrorThen( function()
  // {
  //
  //   //!!!something wrong here
  //
  //   test.description = 'invalid path';
  //   var con = self.provider.fileDelete
  //   ({
  //     pathFile : test.special.makePath( 'somefile.txt' ),
  //     sync : 0,
  //     force : 0,
  //   });
  //
  //   return test.shouldThrowErrorSync( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'not empty dir';
  //   var con = self.provider.fileDelete
  //   ({
  //       pathFile : test.special.makePath( 'written/fileDeleteAsync/dir' ),
  //       force : 0,
  //       sync : 0,
  //   });
  //
  //   return test.shouldThrowErrorSync( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'not empty dir inner level';
  //   var con = self.provider.fileDelete
  //   ({
  //       pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/dir2' ),
  //       force : 0,
  //       sync : 0,
  //   });
  //
  //   return test.shouldThrowErrorSync( con );
  // });
  //
  // return consequence;
}

//

function fileStatSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStat ) )
  return;

  var dir = test.special.makePath( 'read/fileStat' );
  var pathFile,expected;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  pathFile = test.special.makePath( 'read/fileStat/src.txt' );
  self.provider.fileWrite( pathFile, 'Excepteur sint occaecat cupidatat non proident' );
  test.description = 'synchronous file stat default options';

  /**/

  var got = self.provider.fileStat( pathFile );
  if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
  {
    expected = 46;
  }
  else if( self.provider instanceof _.FileProvider.SimpleStructure )
  {
    expected = null;
  }
  test.identical( got.size, expected );

  /**/

  var got = self.provider.fileStat
  ({
    sync : 1,
    pathFile : pathFile,
    throwing : 1
  });
  if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
  {
    expected = 46;
  }
  else if( self.provider instanceof _.FileProvider.SimpleStructure )
  {
    expected = null;
  }
  test.identical( got.size, expected );

  //

  test.description = 'invalid path';
  pathFile = test.special.makePath( '///bad path///test.txt' );

  /**/

  var got = self.provider.fileStat
  ({
    sync : 1,
    pathFile : pathFile,
    throwing : 0
  });
  var expected = null;
  test.identical( got, expected );

  /**/

  test.shouldThrowErrorSync( function()
  {
    var got = self.provider.fileStat
    ({
      sync : 1,
      pathFile : pathFile,
      throwing : 1
    });
  });
}

//

function fileStatAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStat ) )
  return;

  var dir = test.special.makePath( 'read/fileStatAsync' );
  var pathFile,expected;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  //

  consequence
  .ifNoErrorThen( function()
  {
    pathFile = test.special.makePath( 'read/fileStatAsync/src.txt' );
    self.provider.fileWrite( pathFile, 'Excepteur sint occaecat cupidatat non proident' );
    test.description = 'synchronous file stat default options';
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileStat
    ({
      sync : 0,
      pathFile : pathFile,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
      {
        expected = 46;
      }
      else if( self.provider instanceof _.FileProvider.SimpleStructure )
      {
        expected = null;
      }
      test.identical( got.size, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileStat
    ({
      sync : 0,
      pathFile : pathFile,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
      {
        expected = 46;
      }
      else if( self.provider instanceof _.FileProvider.SimpleStructure )
      {
        expected = null;
      }
      test.identical( got.size, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'invalid path';
    pathFile = test.special.makePath( '///bad path///test.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileStat
    ({
      sync : 0,
      pathFile : pathFile,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = null;
      test.identical( got, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileStat
    ({
      sync : 0,
      pathFile : pathFile,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con );
  });

  return consequence;
}

//

function directoryMakeSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryMake ) )
  return;

  var dir = test.special.makePath( 'written/directoryMake' );
  var pathFile;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'synchronous mkdir';
  pathFile = test.special.makePath( 'written/directoryMake/make_dir' );

  /**/

  self.provider.directoryMake( pathFile );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'make_dir' ] );

  //

  test.description = 'synchronous mkdir force';
  self.provider.fileDelete( pathFile );
  pathFile = test.special.makePath( 'written/directoryMake/make_dir/dir1/' );

  /**/

  self.provider.directoryMake
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1
  });
  var files = self.provider.directoryRead( _.pathDir( pathFile ) );
  test.identical( files, [ 'dir1' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileDelete( _.pathDir( pathFile ) );
    self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 1,
      force : 0
    });
  })

  //

  test.description = 'try to rewrite terminal file';
  pathFile = test.special.makePath( 'written/directoryMake/terminal.txt' );
  self.provider.fileWrite( pathFile, '' );

  /**/

  self.provider.directoryMake
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( _.pathDir( pathFile ) );
  test.identical( files, [ 'terminal.txt' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.fileWrite( pathFile, '' );
  test.shouldThrowErrorSync( function ()
  {
    self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 1,
      force : 1,
      rewritingTerminal : 0
    });
  })

  //

  test.description = 'try to rewrite empty dir';
  pathFile = test.special.makePath( 'written/directoryMake/empty' );

  /**/

  self.provider.fileDelete( dir )
  self.provider.directoryMake( pathFile );
  self.provider.directoryMake
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( _.pathDir( pathFile ) );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.fileDelete( dir )
  self.provider.directoryMake( pathFile );
  self.provider.directoryMake
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.fileDelete( dir )
  self.provider.directoryMake( pathFile );
  self.provider.directoryMake
  ({
    pathFile : pathFile,
    sync : 1,
    force : 1,
    rewritingTerminal : 0
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.fileDelete( dir )
  self.provider.directoryMake( pathFile );
  test.shouldThrowErrorSync( function ()
  {
    self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 1,
      force : 0,
      rewritingTerminal : 1
    });
  });

  /**/

  self.provider.fileDelete( dir )
  self.provider.directoryMake( pathFile );
  test.shouldThrowErrorSync( function ()
  {
    self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  //

  test.description = 'dir exists, no rewritingTerminal, no force';
  pathFile = test.special.makePath( 'written/directoryMake/make_dir/' );

  /**/

  self.provider.fileDelete( pathFile );
  self.provider.directoryMake( pathFile );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  //

  test.description = 'try to rewrite folder with files';
  pathFile = test.special.makePath( 'written/directoryMake/make_dir/file' );
  self.provider.fileDelete( dir );

  /**/

  self.provider.fileWrite( pathFile, '' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 1,
      force : 0,
      rewritingTerminal : 1
    });
  });

  /**/

  self.provider.fileWrite( pathFile, '' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  /**/

  self.provider.fileWrite( pathFile, '' );
  self.provider.directoryMake
  ({
    pathFile : _.pathDir( pathFile ),
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'make_dir' ] );


  //

  test.description = 'folders structure not exist';
  self.provider.fileDelete( dir );
  pathFile = test.special.makePath( 'written/directoryMake/dir' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
        pathFile : pathFile,
        sync : 1,
        force : 0,
        rewritingTerminal : 0
    });
  });

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
        pathFile : pathFile,
        sync : 1,
        force : 0,
        rewritingTerminal : 1
    });
  });

  /**/

  self.provider.directoryMake
  ({
      pathFile : pathFile,
      sync : 1,
      force : 1,
      rewritingTerminal : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.fileDelete( dir );
  self.provider.directoryMake
  ({
      pathFile : pathFile,
      sync : 1,
      force : 1,
      rewritingTerminal : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );
}

//

function directoryMakeAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryMake ) )
  return;

  var dir = test.special.makePath( 'written/directoryMakeAsync' );
  var pathFile;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  //

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'synchronous mkdir';
    pathFile = test.special.makePath( 'written/directoryMakeAsync/make_dir' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function ()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'make_dir' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'synchronous mkdir force';
    self.provider.fileDelete( pathFile );
    pathFile = test.special.makePath( 'written/directoryMakeAsync/make_dir/dir1/' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function ()
    {
      var files = self.provider.directoryRead( _.pathDir( pathFile ) );
      test.identical( files, [ 'dir1' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( _.pathDir( pathFile ) );
    var con = self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 0,
      rewritingTerminal : 1
    });
   return test.shouldThrowErrorAsync( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'try to rewrite terminal file';
    pathFile = test.special.makePath( 'written/directoryMakeAsync/terminal.txt' );
    self.provider.fileWrite( pathFile, '' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function ()
    {
      var files = self.provider.directoryRead( _.pathDir( pathFile ) );
      test.identical( files, [ 'terminal.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    self.provider.fileWrite( pathFile, '' );
    var con = self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1,
      rewritingTerminal : 0
    });
    return test.shouldThrowErrorAsync( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'try to rewrite empty dir';
    pathFile = test.special.makePath( 'written/directoryMakeAsync/empty' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir )
    self.provider.directoryMake( pathFile );
    return self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( _.pathDir( pathFile ) );
      test.identical( files, [ 'empty' ] );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir )
    self.provider.directoryMake( pathFile );
    return self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 1,
      rewritingTerminal : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'empty' ] );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir )
    self.provider.directoryMake( pathFile );
    var con = self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir )
    self.provider.directoryMake( pathFile );
    var con = self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowErrorAsync( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'dir exists, no rewritingTerminal, no force';
    pathFile = test.special.makePath( 'written/directoryMakeAsync/make_dir/' );
  })

  /**/

  .ifNoErrorThen( function ()
  {
    self.provider.fileDelete( pathFile );
    self.provider.directoryMake( pathFile );
    var con = self.provider.directoryMake
    ({
      pathFile : pathFile,
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowErrorAsync( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'try to rewrite folder with files';
    pathFile = test.special.makePath( 'written/directoryMakeAsync/make_dir/file' );
    self.provider.fileDelete( dir );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile, '' );
    var con = self.provider.directoryMake
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 0,
      force : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function ()
  {
    self.provider.fileWrite( pathFile, '' );
    var con = self.provider.directoryMake
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile, '' );
    return self.provider.directoryMake
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'make_dir' ] );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'folders structure not exist';
    self.provider.fileDelete( dir );
    pathFile = test.special.makePath( 'written/directoryMakeAsync/dir' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.directoryMake
    ({
        pathFile : pathFile,
        sync : 0,
        force : 0,
        rewritingTerminal : 0
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.directoryMake
    ({
        pathFile : pathFile,
        sync : 0,
        force : 0,
        rewritingTerminal : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
        pathFile : pathFile,
        sync : 0,
        force : 1,
        rewritingTerminal : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileDelete( dir );
    return self.provider.directoryMake
    ({
        pathFile : pathFile,
        sync : 0,
        force : 1,
        rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  return consequence;
}



function fileHashSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileHash ) )
  return;

  var dir = test.special.makePath( 'read/fileHash' );
  var got,pathFile,data;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  if( isBrowser )
  return;

  //

  test.description = 'synchronous filehash';
  data = 'Excepteur sint occaecat cupidatat non proident';
  pathFile = test.special.makePath( 'read/fileHash/src.txt' );

  /**/

  self.provider.fileWrite( pathFile, data );
  got = self.provider.fileHash( pathFile );
  var md5sum = crypto.createHash( 'md5' );
  md5sum.update( data );
  var expected = md5sum.digest( 'hex' );
  test.identical( got, expected );

  //

  test.description = 'invalid path';
  pathFile = test.special.makePath( 'invalid.txt' );

  /**/

  got = self.provider.fileHash( pathFile );
  var expected = NaN;
  test.identical( got, expected );

  /*invalid path throwing enabled*/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileHash
    ({
      pathFile : pathFile,
      sync : 1,
      throwing : 1
    });
  });

  /*invalid path throwing disabled*/

  test.mustNotThrowError( function( )
  {
    got = self.provider.fileHash
    ({
      pathFile : pathFile,
      sync : 1,
      throwing : 0
    });
    var expected = NaN;
    test.identical( got, expected );
  });

  /*is not terminal file*/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileHash
    ({
      pathFile : test.special.makePath( './' ),
      sync : 1,
      throwing : 1
    });
  });

  /*is not terminal file, throwing disabled*/

  test.mustNotThrowError( function( )
  {
    got = self.provider.fileHash
    ({
      pathFile : test.special.makePath( './' ),
      sync : 1,
      throwing : 0
    });
    var expected = NaN;
    test.identical( got, expected );
  });


}

//

function fileHashAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileHash ) )
  return;

  var dir = test.special.makePath( 'read/fileHashAsync' );
  var got,pathFile,data;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  if( isBrowser )
  return;

  var consequence = new wConsequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.description = 'async filehash';
    data = 'Excepteur sint occaecat cupidatat non proident';
    pathFile = test.special.makePath( 'read/fileHashAsync/src.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile, data );
    return self.provider.fileHash
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var md5sum = crypto.createHash( 'md5' );
      md5sum.update( data );
      var expected = md5sum.digest( 'hex' );
      test.identical( got, expected );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'invalid path';
    pathFile = test.special.makePath( 'invalid.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileHash
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = NaN;
      test.identical( got, expected );
    });
  })

  /*invalid path throwing enabled*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileHash
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /*invalid path throwing disabled*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileHash
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      var expected = NaN;
      test.identical( got, expected );
    });
  })

  /*is not terminal file*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileHash
    ({
      pathFile : test.special.makePath( './' ),
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /*is not terminal file, throwing disabled*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileHash
    ({
      pathFile : test.special.makePath( './' ),
      sync : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      var expected = NaN;
      test.identical( got, expected );
    })

  })

  return consequence;
}

//

function directoryReadSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryRead ) )
  return;

  var dir = test.special.makePath( 'read/directoryRead' );
  var got,pathFile;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'synchronous read';
  pathFile = test.special.makePath( 'read/directoryRead/1.txt' ),

  /**/

  self.provider.fileWrite( pathFile,'' );
  var got = self.provider.directoryRead( _.pathDir( pathFile ) );
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  /**/

  self.provider.fileWrite( pathFile,'' );
  var got = self.provider.directoryRead
  ({
    pathFile : _.pathDir( pathFile ),
    sync : 1,
    throwing : 1
  })
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  //

  test.description = 'synchronous, pathFile points to file';
  pathFile = test.special.makePath( 'read/directoryRead/1.txt' );

  /**/

  self.provider.fileWrite( pathFile,'' )
  var got = self.provider.directoryRead( pathFile );
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  /**/

  self.provider.fileWrite( pathFile,'' )
  var got = self.provider.directoryRead
  ({
    pathFile : pathFile,
    sync : 1,
    throwing : 1
  })
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  //

  test.description = 'path not exist';
  pathFile = test.special.makePath( 'non_existing_folder' );

  /**/

  var got = self.provider.directoryRead( pathFile );
  var expected = null;
  test.identical( got, expected );

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.directoryRead
    ({
      pathFile : pathFile,
      sync : 1,
      throwing : 1
    });
  })
}

//

function directoryReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryRead ) )
  return;

  var dir = test.special.makePath( 'read/directoryReadAsync' );
  var got,pathFile;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.description = 'synchronous read';
    pathFile = test.special.makePath( 'read/directoryReadAsync/1.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile,'' );
    return self.provider.directoryRead
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = [ "1.txt" ];
      test.identical( got.sort(), expected.sort() );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile,'' );
    return self.provider.directoryRead
    ({
      pathFile : _.pathDir( pathFile ),
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var expected = [ "1.txt" ];
      test.identical( got.sort(), expected.sort() );
    })
  })

  //
  .ifNoErrorThen( function()
  {
    test.description = 'synchronous, pathFile points to file';
    pathFile = test.special.makePath( 'read/directoryReadAsync/1.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile,'' );
    return self.provider.directoryRead
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var got = self.provider.directoryRead( pathFile );
      var expected = [ '1.txt' ];
      test.identical( got, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( pathFile,'' );
    return self.provider.directoryRead
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var got = self.provider.directoryRead( pathFile );
      var expected = [ '1.txt' ];
      test.identical( got, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'path not exist';
    pathFile = test.special.makePath( 'non_existing_folder' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryRead
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = null;
      test.identical( got, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.directoryRead
    ({
      pathFile : pathFile,
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  return consequence;
}

//

function fileWriteSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  /*writeMode rewrite*/
  try
  {
    self.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'write_test' ),
      sync : 1
    })
  }
  catch ( err ) { }

  /*writeMode rewrite*/
  var data = "LOREM"
  test.description ='rewrite, file not exist ';
  self.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected )

  test.description ='rewrite existing file ';
  data = "LOREM LOREM";
  self.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try write to non existing folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'unknown/dst.txt' ),
        data : data,
        sync : 1
      });
    });

    test.description ='try to rewrite folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'write_test' ),
        data : data,
        sync : 1
      });
    });
  }

  /*writeMode append*/
  try
  {
    self.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'write_test/append.txt' ),
      sync : 1
    })
  }
  catch ( err ) { }
  var data = 'APPEND';
  test.description ='append, file not exist ';
  self.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  test.description ='append, to file ';
  self.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = 'APPENDAPPEND';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try append to non existing folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'append',
        sync : 1
      });
    });

    test.description ='try to append to folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'write_test' ),
        data : data,
        writeMode : 'append',
        sync : 1
      });
    });
  }
  /*writeMode prepend*/
  try
  {
    self.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'write_test/prepend.txt' ),
      sync : 1
    })
  }
  catch ( err ) { }
  var data = 'Lorem';
  test.description ='prepend, file not exist ';
  self.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  data = 'new text';
  test.description ='prepend to file ';
  self.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = 'new textLorem';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try prepend to non existing folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'prepend',
        sync : 1
      });
    });

    test.description ='try to prepend to folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'write_test' ),
        data : data,
        writeMode : 'prepend',
        sync : 1
      });
    });
  }
}

//

function fileWriteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var consequence = new wConsequence().give();
  /*writeMode rewrite*/
  try
  {
    self.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'write_test' ),
      sync : 1
    })
  }
  catch ( err ) { }

  /*writeMode rewrite*/
  var data = "LOREM"
  consequence
  .ifNoErrorThen( function()
  {
    test.description ='rewrite, file not exist ';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      pathFile : test.special.makePath( 'write_test/dst.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected )
  })
  .ifNoErrorThen( function()
  {
    test.description ='rewrite existing file ';
    data = "LOREM LOREM";
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      pathFile : test.special.makePath( 'write_test/dst.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try write to non existing folder';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'unknown/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldThrowErrorSync( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try to rewrite folder';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test' ),
      data : data,
      sync : 0
    });

    return test.shouldThrowErrorSync( con );
  })
  /*writeMode append*/
  .ifNoErrorThen( function()
  {
    try
    {
      self.provider.fileDelete
      ({
        pathFile : test.special.makePath( 'write_test/append.txt' ),
        sync : 1
      })
    }
    catch ( err ) { }

    data = 'APPEND';
    test.description ='append, file not exist ';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/append.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      pathFile : test.special.makePath( 'write_test/append.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='append, to file ';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/append.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      pathFile : test.special.makePath( 'write_test/append.txt' ),
      sync : 1
    });
    var expected = 'APPENDAPPEND';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try append to non existing folder';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'unknown/dst.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldThrowErrorSync( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try to append to folder';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldThrowErrorSync( con );
  })
  /*writeMode prepend*/
  .ifNoErrorThen( function()
  {
    try
    {
      self.provider.fileDelete
      ({
        pathFile : test.special.makePath( 'write_test/prepend.txt' ),
        sync : 1
      })
    }
    catch ( err ) { }

    data = 'Lorem';
    test.description ='prepend, file not exist ';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/prepend.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      pathFile : test.special.makePath( 'write_test/prepend.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    data = 'new text';
    test.description ='prepend to file ';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/prepend.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      pathFile : test.special.makePath( 'write_test/prepend.txt' ),
      sync : 1
    });
    var expected = 'new textLorem';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try prepend to non existing folder';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'unknown/dst.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldThrowErrorSync( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try prepend to folder';
    var con = self.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    test.shouldThrowErrorSync( con );
  });

  return consequence;
}

//

function linkSoftSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoft ) )
  return;

  var dir = test.special.makePath( 'written/linkSoft' );
  var pathSrc,pathDst;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'make link sync';
  pathSrc  = test.special.makePath( 'written/linkSoft/link_test.txt' );
  pathDst = test.special.makePath( 'written/linkSoft/link.txt' );
  self.provider.fileWrite( pathSrc, '000' );

  /**/

  self.provider.linkSoft
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
  });
  self.provider.fileWrite
  ({
    pathFile : pathSrc,
    writeMode : 'append',
    data : 'new text',
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )
  var got = self.provider.fileRead( pathDst );
  var expected = '000new text';
  test.identical( got, expected );

  //

  test.description = 'make for file that not exist';
  self.provider.fileDelete( dir );
  pathSrc  = test.special.makePath( 'written/linkSoft/no_file.txt' );
  pathDst = test.special.makePath( 'written/linkSoft/link2.txt' );

  /**/

  test.shouldThrowErrorSync( function ()
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  })

  /**/

  test.mustNotThrowError( function ()
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, null );

  //

  test.description = 'link already exists';
  pathSrc = test.special.makePath( 'written/linkSoft/link_test.txt' );
  pathDst = test.special.makePath( 'written/linkSoft/link.txt' );
  self.provider.fileWrite( pathSrc, 'abc' );
  self.provider.linkSoft
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  });

  //

  test.description = 'src is equal to dst';
  self.provider.fileDelete( dir );
  pathSrc = test.special.makePath( 'written/linkSoft/link_test.txt' );
  self.provider.fileWrite( pathSrc, '' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  //

  test.description = 'try make hardlink for folder';
  self.provider.fileDelete( dir );
  pathSrc = test.special.makePath( 'written/linkSoft/link_test' );
  pathDst = test.special.makePath( 'written/linkSoft/link' );
  self.provider.directoryMake( pathSrc );

  /**/

  self.provider.linkSoft
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link', 'link_test' ]  );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  self.provider.linkSoft
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    rewriting : 1,
    throwing : 0,
    sync : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link', 'link_test' ]  );

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  })
}

//

function linkSoftAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoft ) )
  return;

  var dir = test.special.makePath( 'written/linkSoftAsync' );
  var pathSrc,pathDst;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();
  consequence

  //

  .ifNoErrorThen( function()
  {
    test.description = 'make link async';
    pathSrc  = test.special.makePath( 'written/linkSoftAsync/link_test.txt' );
    pathDst = test.special.makePath( 'written/linkSoftAsync/link.txt' );
    self.provider.fileWrite( pathSrc, '000' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite
      ({
        pathFile : pathSrc,
        writeMode : 'append',
        data : 'new text',
        sync : 1
      });
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      var got = self.provider.fileRead( pathDst );
      var expected = '000new text';
      test.identical( got, expected );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'make for file that not exist';
    self.provider.fileDelete( dir );
    pathSrc  = test.special.makePath( 'written/linkSoftAsync/no_file.txt' );
    pathDst = test.special.makePath( 'written/linkSoftAsync/link2.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function( )
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function ()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, null );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'link already exists';
    pathSrc = test.special.makePath( 'written/linkSoftAsync/link_test.txt' );
    pathDst = test.special.makePath( 'written/linkSoftAsync/link.txt' );
    self.provider.fileWrite( pathSrc, 'abc' );
    self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  .ifNoErrorThen( function ()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function ()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function ()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function ()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  //
  .ifNoErrorThen( function ()
  {
    test.description = 'src is equal to dst';
    self.provider.fileDelete( dir );
    pathSrc = test.special.makePath( 'written/linkSoftAsync/link_test.txt' );
    self.provider.fileWrite( pathSrc, '' );
  })

  /**/

  .ifNoErrorThen( function ()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    })
  })

  /**/

  .ifNoErrorThen( function ()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    })
  })

  /**/

  .ifNoErrorThen( function ()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    })
  })

  /**/

  .ifNoErrorThen( function ()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'try make hardlink for folder';
    self.provider.fileDelete( dir );
    pathSrc = test.special.makePath( 'written/linkSoftAsync/link_test' );
    pathDst = test.special.makePath( 'written/linkSoftAsync/link' );
    self.provider.directoryMake( pathSrc );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link', 'link_test' ]  );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link', 'link_test' ]  );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  return consequence;
}

//

function fileReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRead ) )
  return;

  var consequence = new wConsequence().give();

  if( isBrowser )
  return;

  function encode( src, encoding )
  {
    return new Buffer( src ).toString( encoding );
  }

  function decode( src, encoding )
  {
    return Buffer.from( src, encoding ).toString( 'utf8' );
  }

  var src = 'Excepteur sint occaecat cupidatat non proident';

  consequence
  .ifNoErrorThen( function()
  {
    test.description ='read from file';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
    });
    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = src;
    // why slice ???
    // var got = data.slice( 0, expected.length );
    var got = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : ascii';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'ascii'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'ascii' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : utf16le';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'utf16le'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'utf16le' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : ucs2';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'ucs2'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'ucs2' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : base64';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'base64'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = src;
    data = decode( data, 'base64' );
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : arraybuffer';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'arraybuffer'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = [ true, src ];
    var result  = Buffer.from( data ).toString().slice( 0, src.length );
    var got = [ _.bufferRawIs( data ), result ];
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : buffer';
    var con = self.provider.fileRead
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'buffer'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = [ true, src ];
    var result  = Buffer.from( data ).toString().slice( 0, src.length );
    var got = [ _.bufferNodeIs( data ), result ];
    test.identical( got , expected );
  })

  return consequence;
}

//

function linkHardSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoft ) )
  return;

  var dir = test.special.makePath( 'written/linkHard' );
  var pathSrc,pathDst;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'make link async';
  pathSrc  = test.special.makePath( 'written/linkHard/link_test.txt' );
  pathDst = test.special.makePath( 'written/linkHard/link.txt' );
  self.provider.fileWrite( pathSrc, '000' );

  /**/

  self.provider.linkHard
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    sync : 1,
  });
  self.provider.fileWrite
  ({
    pathFile : pathSrc,
    sync : 1,
    data : 'new text',
    writeMode : 'append'
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )
  var got = self.provider.fileRead( pathDst );
  var expected = '000new text';
  test.identical( got, expected );

  //

  test.description = 'make for file that not exist';
  self.provider.fileDelete( dir );
  pathSrc  = test.special.makePath( 'written/linkHard/no_file.txt' );
  pathDst = test.special.makePath( 'written/linkHard/link2.txt' );

  /**/

  test.shouldThrowErrorSync( function ()
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  })

  /**/

  test.mustNotThrowError( function ()
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, null );

  //

  test.description = 'link already exists';
  pathSrc = test.special.makePath( 'written/linkHard/link_test.txt' );
  pathDst = test.special.makePath( 'written/linkHard/link.txt' );
  self.provider.fileWrite( pathSrc, 'abc' );
  self.provider.linkHard
  ({
    pathSrc : pathSrc,
    pathDst : pathDst,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  });

  //

  test.description = 'src is equal to dst';
  self.provider.fileDelete( dir );
  pathSrc = test.special.makePath( 'written/linkHard/link_test.txt' );
  self.provider.fileWrite( pathSrc, '' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  //

  test.description = 'try make hardlink for folder';
  self.provider.fileDelete( dir );
  pathSrc = test.special.makePath( 'written/linkHard/link_test' );
  pathDst = test.special.makePath( 'written/linkHard/link' );
  self.provider.directoryMake( pathSrc );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  })

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  })
}

//

function linkHardAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoft ) )
  return;

  var dir = test.special.makePath( 'written/linkHardAsync' );
  var pathSrc,pathDst;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.description = 'make link async';
    pathSrc  = test.special.makePath( 'written/linkHardAsync/link_test.txt' );
    pathDst = test.special.makePath( 'written/linkHardAsync/link.txt' );
    self.provider.fileWrite( pathSrc, '000' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite
      ({
        pathFile : pathSrc,
        sync : 1,
        data : 'new text',
        writeMode : 'append'
      });
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      var got = self.provider.fileRead( pathDst );
      var expected = '000new text';
      test.identical( got, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'make for file that not exist';
    self.provider.fileDelete( dir );
    pathSrc  = test.special.makePath( 'written/linkHardAsync/no_file.txt' );
    pathDst = test.special.makePath( 'written/linkHardAsync/link2.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, null );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'link already exists';
    pathSrc = test.special.makePath( 'written/linkHardAsync/link_test.txt' );
    pathDst = test.special.makePath( 'written/linkHardAsync/link.txt' );
    self.provider.fileWrite( pathSrc, 'abc' );
    self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'src is equal to dst';
    self.provider.fileDelete( dir );
    pathSrc = test.special.makePath( 'written/linkHardAsync/link_test.txt' );
    self.provider.fileWrite( pathSrc, '' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathSrc,
      sync : 0,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'try make hardlink for folder';
    self.provider.fileDelete( dir );
    pathSrc = test.special.makePath( 'written/linkHardAsync/link_test' );
    pathDst = test.special.makePath( 'written/linkHardAsync/link' );
    self.provider.directoryMake( pathSrc );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowErrorAsync( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      pathSrc : pathSrc,
      pathDst : pathDst,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  return consequence;
}

// --
// proto
// --

var Self =
{

  name : 'FileProvider',
  sourceFilePath : sourceFilePath,
  verbosity : 1,
  abstract : 1,

  special :
  {
    makePath : makePath,
    shouldWriteOnlyOnce : shouldWriteOnlyOnce
  },

  tests :
  {

    //testDelaySample : testDelaySample,
    mustNotThrowError : mustNotThrowError,

    readWriteSync : readWriteSync,
    readWriteAsync : readWriteAsync,

    // writeAsyncThrowingError : writeAsyncThrowingError,

    fileCopySync : fileCopySync,
    fileCopyAsync : fileCopyAsync,
    // fileCopyAsyncThrowingError : fileCopyAsyncThrowingError,/* last case dont throw error */

    fileRenameSync : fileRenameSync,
    fileRenameAsync : fileRenameAsync,

    fileDeleteSync : fileDeleteSync,
    fileDeleteAsync : fileDeleteAsync,

    fileStatSync : fileStatSync,
    fileStatAsync : fileStatAsync,

    directoryMakeSync : directoryMakeSync,
    directoryMakeAsync : directoryMakeAsync,

    fileHashSync : fileHashSync,
    fileHashAsync : fileHashAsync,

    directoryReadSync : directoryReadSync,
    directoryReadAsync : directoryReadAsync,

    // fileWriteSync : fileWriteSync,
    // fileWriteAsync : fileWriteAsync,

    // fileReadAsync : fileReadAsync,

    linkSoftSync : linkSoftSync,
    linkSoftAsync : linkSoftAsync,

    linkHardSync : linkHardSync,
    linkHardAsync : linkHardAsync

  },

};

// _.mapExtend( Self,Proto );
// Object.setPrototypeOf( Self, Parent );

wTestSuite( Self );

} )( );
