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

  _.include( 'wTesting' );

  require( '../Files.ss' );

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

var testDelaySample = function testDelaySample( test )
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

function readWriteSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileWrite ) )
  return;

  var dir = test.special.makePath( 'written/readWriteSync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
    data : data1,
    sync : 1,
  });

  test.description = 'single file is written';
  var files = self.special.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
  test.identical( files, [ 'test.txt' ] );

  test.description = 'synchronous, writeMode : rewrite';
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
    sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  var data2 = 'LOREM';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
    data : data2,
    sync : 1,
    writeMode : 'append'
  });

  test.description = 'single file is written';
  var files = self.special.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
  test.identical( files, [ 'test.txt' ] );

  test.description = 'synchronous, writeMode : append';
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
    sync : 1
  });
  var expected = data1 + data2;
  test.identical( got, expected );

  var data2 = 'LOREM';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
    data : data2,
    sync : 1,
    writeMode : 'prepend'
  });

  test.description = 'single file is written';
  var files = self.special.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
  test.identical( files, [ 'test.txt' ] );

  test.description = 'synchronous, writeMode : prepend';
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
    sync : 1
  });
  var expected = data2 + data1 + data2;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'file doesn`t exist';
    test.shouldThrowError( function( )
    {
      self.special.provider.fileRead
      ({
        pathFile : test.special.makePath( 'unknown' ),
        sync : 1
      });
    });

    test.description = 'try to read dir';
    test.shouldThrowError( function( )
    {
      self.special.provider.fileRead
      ({
        pathFile : test.special.makePath( './' ),
        sync : 1
      });
    });
  }
}

//

function readWriteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileWrite ) )
  return;

  var dir = test.special.makePath( 'written/readWriteSync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  var data2 = 'LOREM';

  consequence
  .ifNoErrorThen( function()
  {
    var con = self.special.provider.fileWrite
    ({
        pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
        data : data1,
        sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    test.description = 'single file is written';
    var files = self.special.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
    test.identical( files, [ 'test.txt' ] );
  })
  .ifNoErrorThen( function( err )
  {
    test.description = 'async, writeMode : rewrite';
    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
      sync : 1,
    });

    test.identical( got, data1 );

  })
  .ifNoErrorThen( function()
  {
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
      data : data2,
      sync : 0,
      writeMode : 'append'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    test.description = 'single file is written';
    var files = self.special.provider.directoryRead( test.special.makePath( 'written/readWriteSync/' ) );
    test.identical( files, [ 'test.txt' ] );
  })
  .ifNoErrorThen( function( err )
  {
    test.description = 'async, writeMode : append';
    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'written/readWriteSync/test.txt' ),
      sync : 1,
    });

    var expected = data1 + data2;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'file doesn`t exist';
    debugger;
    var con = self.special.provider.fileRead
    ({
      pathFile : makePath( 'unknown' ),
      sync : 0
    });
    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'try to read dir';
    var con = self.special.provider.fileRead
    ({
      pathFile : makePath( './' ),
      sync : 0
    });
    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'async, try to rewrite dir';

    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'written/readWriteSync' ),
      data : '',
      sync : 0,
    });

    return test.shouldThrowError( con );
  })

  // debugger;
  // consequence.doThen( function( err,data )
  // {
  //
  //   console.log( err,data );
  //
  // });

  return consequence;
}

//

// function writeAsyncThrowingError( test )
// {
//   var self = this;
//
//   if( !_.routineIs( self.special.provider.fileWrite ) )
//   return;
//
//   var consequence = new wConsequence().give();
//
//   try
//   {
//     self.special.provider.directoryMake
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
//     var con = self.special.provider.fileWrite
//     ({
//       pathFile : test.special.makePath( 'dir' ),
//       data : data1,
//       sync : 0,
//     });
//
//     return test.shouldThrowError( con );
//   })
//
//   return consequence;
// }

//

function fileCopySync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileCopy ) )
  return;

  var dir = test.special.makePath( 'written/fileCopy' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileCopy/1/src/test.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,makePath( 'written/fileCopy/1/src/' ),[ 'test.txt' ] );

  test.description = 'synchronous copy';
  self.special.provider.fileCopy
  ({
      pathSrc : test.special.makePath( 'written/fileCopy/1/src/test.txt' ),
      pathDst : test.special.makePath( 'written/fileCopy/1/dst/pathDst.txt' ),
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileCopy/1/dst' ),[ 'pathDst.txt' ] );

  var got = self.special.provider.fileRead
  ({
      pathFile : test.special.makePath( 'written/fileCopy/1/dst/pathDst.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  test.description = 'synchronous rewrite existing file';
  self.special.provider.fileCopy
  ({
      pathSrc : test.special.makePath( 'written/fileCopy/1/dst/pathDst.txt' ),
      pathDst : test.special.makePath( 'written/fileCopy/1/src/test.txt' ),
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileCopy/1/src' ),[ 'test.txt' ] );

  var got = self.special.provider.fileRead
  ({
      pathFile : test.special.makePath( 'written/fileCopy/1/src/test.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid pathSrc path';
    test.shouldThrowError( function()
    {
      self.special.provider.fileCopy
      ({
          pathSrc : test.special.makePath( 'invalid.txt' ),
          pathDst : test.special.makePath( 'pathDst.txt' ),
          sync : 1,
      });
    });

    test.description = 'try to rewrite dir';
    test.shouldThrowError( function()
    {
      self.special.provider.fileCopy
      ({
          pathSrc : test.special.makePath( 'written/fileCopy/1/src/test.txt' ),
          pathDst : test.special.makePath( 'written/fileCopy' ),
          sync : 1,
      });
    });

    test.description = 'synchronous copy dir';
    try
    {
      self.special.provider.directoryMake
      ({
        pathFile : test.special.makePath( 'written/fileCopy/copydir' ),
        sync : 1
      });
      self.special.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'written/fileCopy/copydir/copyfile.txt' ),
        data : 'Lorem',
        sync : 1
      });
    } catch ( err ) { }

    test.shouldThrowError( function( )
    {
      self.special.provider.fileCopy
      ({
          pathSrc : test.special.makePath( 'written/fileCopy/copydir' ),
          pathDst : test.special.makePath( 'written/fileCopy/copydir2' ),
          sync : 1,
      });
    })
  }
}

//

function fileCopyAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileCopy ) )
  return;

  var dir = test.special.makePath( 'written/fileCopyAsync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var consequence = new wConsequence().give();
  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';

  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileCopyAsync/1/src/test.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileCopyAsync/1/src' ),[ 'test.txt' ] );

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'asynchronous copy';
    var con = self.special.provider.fileCopy
    ({
      pathSrc : test.special.makePath( 'written/fileCopyAsync/1/src/test.txt' ),
      pathDst : test.special.makePath( 'written/fileCopyAsync/1/dst/pathDst.txt' ),
      sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileCopyAsync/1/dst/' ),[ 'pathDst.txt' ] );

    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'written/fileCopyAsync/1/dst/pathDst.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'synchronous rewrite existing file';

    var con = self.special.provider.fileCopy
    ({
        pathSrc : test.special.makePath( 'written/fileCopyAsync/1/dst/pathDst.txt' ),
        pathDst : test.special.makePath( 'written/fileCopyAsync/1/src/test.txt' ),
        sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileCopyAsync/1/src' ),[ 'test.txt' ] );

    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'written/fileCopyAsync/1/src/test.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  });

  return consequence;
}

//

function fileCopyAsyncThrowingError( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileCopy ) )
  return;

  var dir = test.special.makePath( 'written/fileCopyAsync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'async, throwing error';
    var con = self.special.provider.fileCopy
    ({
      pathSrc : test.special.makePath( 'invalid.txt' ),
      pathDst : test.special.makePath( 'pathDst.txt' ),
      sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async,try rewrite dir';
    var con = self.special.provider.fileCopy
    ({
      pathSrc : test.special.makePath( 'invalid.txt' ),
      pathDst : test.special.makePath( 'tmp' ),
      sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async copy dir';
    try
    {
      self.special.provider.directoryMake
      ({
        pathFile : test.special.makePath( 'written/fileCopyAsync/copydir' ),
        sync : 1
      });
      self.special.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'written/fileCopyAsync/copydir/copyfile.txt' ),
        data : 'Lorem',
        sync : 1
      });
    } catch ( err ) { }

    debugger;
    var con = self.special.provider.fileCopy
    ({
        pathSrc : test.special.makePath( 'written/fileCopyAsync/copydir' ),
        pathDst : test.special.makePath( 'written/fileCopyAsync/copydir2' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

function fileRenameSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileRename ) )
  return;

  var dir = test.special.makePath( 'written/fileRename' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileRename/1/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileRename/1/' ),[ 'src.txt' ] );

  test.description = 'synchronous rename';
  self.special.provider.fileRename
  ({
    pathSrc : test.special.makePath( 'written/fileRename/1/src.txt' ),
    pathDst : test.special.makePath( 'written/fileRename/1/dst.txt' ),
    sync : 1
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileRename/1' ),[ 'dst.txt' ] );

  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'written/fileRename/1/dst.txt' ),
    sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid pathSrc path';
    test.shouldThrowError( function()
    {
      self.special.provider.fileRename
      ({
          pathSrc : test.special.makePath( 'invalid.txt' ),
          pathDst : test.special.makePath( 'newfile.txt' ),
          sync : 1,
      });
    });
  }
}

//

function fileRenameAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileRename ) )
  return;

  var dir = test.special.makePath( 'written/fileRenameAsync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var consequence = new wConsequence().give();
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileRenameAsync/1/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileRenameAsync/1/' ),[ 'src.txt' ] );

  consequence
  .ifNoErrorThen( function()
  {

    test.description = 'asynchronous rename';
    var con = self.special.provider.fileRename
    ({
      pathSrc : test.special.makePath( 'written/fileRenameAsync/1/src.txt' ),
      pathDst : test.special.makePath( 'written/fileRenameAsync/1/dst.txt' ),
      sync : 0
    });
    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function()
  {
    self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileRenameAsync/1/' ),[ 'dst.txt' ] );

    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'written/fileRenameAsync/1/dst.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'invalid pathSrc path';

    var con = self.special.provider.fileRename
    ({
      pathSrc : test.special.makePath( '///bad path///test.txt' ),
      pathDst : test.special.makePath( 'pathDst.txt' ),
      sync : 0,
    });

    return test.shouldThrowError( con );

    // return con;
  });

  return consequence;
}

//

function fileDeleteSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileDelete ) )
  return;

  var dir = test.special.makePath( 'written/fileDelete' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'written/fileDelete/dir' ),
      sync : 1
    });

    self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete' ),[ 'dir' ] );

  } catch ( err ){ }
  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'written/fileDelete/dir/dir2' ),
      sync : 1
    });

    self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/dir' ),[ 'dir2' ] );

  } catch ( err ){ }

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileDelete/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/' ),[ 'dir','src.txt' ] );

  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileDelete/dir/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/dir' ),[ 'dir2','src.txt' ] );

  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileDelete/dir/dir2/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDelete/dir/dir2' ),[ 'src.txt' ] );

  test.description = 'synchronous delete';
  self.special.provider.fileDelete
  ({
    pathFile : test.special.makePath( 'written/fileDelete/src.txt' ),
    sync : 1
  });
  var got = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'written/fileDelete/src.txt' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  test.description = 'synchronous delete empty dir';
  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'written/fileDelete/empty_dir' ),
      sync : 1
    });
  } catch ( err ){ }
  self.special.provider.fileDelete
  ({
    pathFile : test.special.makePath( 'written/fileDelete/empty_dir' ),
    sync : 1
  });
  var got = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'written/fileDelete/empty_dir' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path';
    test.shouldThrowError( function()
    {
      self.special.provider.fileDelete
      ({
          pathFile : test.special.makePath( '///bad path///test.txt' ),
          sync : 1,
      });
    });

    test.description = 'not empty dir';
    test.shouldThrowError( function()
    {
      self.special.provider.fileDelete
      ({
          pathFile : test.special.makePath( 'written/fileDelete/dir' ),
          force : 0,
          sync : 1,
      });
    });

    test.description = 'not empty dir inner level';
    test.shouldThrowError( function()
    {
      self.special.provider.fileDelete
      ({
          pathFile : test.special.makePath( 'written/fileDelete/dir/dir2' ),
          force : 0,
          sync : 1,
      });
    });
  }

}

//

function fileDeleteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileDelete ) )
  return;

  var consequence = new wConsequence().give();
  var data1 = 'Excepteur sint occaecat cupidatat non proident';

  var dir = test.special.makePath( 'written/fileDeleteAsync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/dir' ),
      sync : 1
    });

  } catch ( err ){ }

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync' ),[ 'dir' ] );

  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/dir2' ),
      sync : 1
    });

  } catch ( err ){ }

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync/dir' ),[ 'dir2' ] );


  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/dir2/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync/dir/dir2' ),[ 'src.txt' ] );

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync' ),[ 'dir','src.txt' ] );

  consequence
  .ifNoErrorThen( function()
  {
    self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/src.txt' ),
      data : data1,
      sync : 1,
    });

    self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'written/fileDeleteAsync/dir' ),[ 'dir2','src.txt' ] );


    test.description = 'asynchronous delete';
    var con = self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/src.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/src.txt' ),
      sync : 1
    });
    var expected = null;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'synchronous delete empty dir';
    try
    {
      self.special.provider.directoryMake
      ({
        pathFile : test.special.makePath( 'written/fileDeleteAsync/empty_dir' ),
        sync : 1
      });
    } catch ( err ){ }

    var con = self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/empty_dir' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'written/fileDeleteAsync/empty_dir' ),
      sync : 1
    });
    var expected = null;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    //!!!something wrong here
    test.description = 'invalid  path';
    var con = self.special.provider.fileDelete
    ({
        pathFile : test.special.makePath( 'somefile.txt' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'not empty dir';
    var con = self.special.provider.fileDelete
    ({
        pathFile : test.special.makePath( 'written/fileDeleteAsync/dir' ),
        force : 0,
        sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'not empty dir inner level';
    var con = self.special.provider.fileDelete
    ({
        pathFile : test.special.makePath( 'written/fileDeleteAsync/dir/dir2' ),
        force : 0,
        sync : 0,
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

function fileStatSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileStat ) )
  return;

  // xxx
  // test.identical( 0,1 );

  var dir = test.special.makePath( 'read/fileStat' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'read/fileStat/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'read/fileStat/' ),[ 'src.txt' ] );

  test.description = 'synchronous file stat';
  var got = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'read/fileStat/src.txt' ),
    sync : 1
  });
  var expected;

  if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
  {
    expected = 46;
  }
  else if( self.special.provider instanceof _.FileProvider.SimpleStructure )
  {
    expected = null;
  }
  test.identical( got.size, expected );

  test.description = 'invalid path';
  var got = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( '///bad path///test.txt' ),
    sync : 1,
  });
  var expected = null;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path throwing enabled';
    test.shouldThrowError( function( )
    {
      self.special.provider.fileStat
      ({
        pathFile : test.special.makePath( '///bad path///test.txt' ),
        sync : 1,
        throwing : 1
      });
    });
  }

}

//

function fileStatAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileStat ) )
  return;

  // test.identical( 0,1 );

  var dir = test.special.makePath( 'read/fileStatAsync' );

  if( !self.special.provider.fileStat( dir ) )
  self.special.provider.directoryMake( dir );

  var consequence = new wConsequence().give();

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'read/fileStatAsync/src.txt' ),
      data : data1,
      sync : 1,
  });

  self.special.shouldWriteOnlyOnce( test,test.special.makePath( 'read/fileStatAsync/' ),[ 'src.txt' ] );

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'asynchronous file stat';
    var con = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'read/fileStatAsync/src.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( stats )
  {
    var expected;
    if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
    {
      expected = 46;
    }
    else if( self.special.provider instanceof _.FileProvider.SimpleStructure )
    {
      expected = null;
    }
    test.identical( stats.size, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'invalid path';
    var con = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( '../1.txt' ),
      sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( stats )
  {
    var expected = null;
    test.identical( stats, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'invalid path throwing enabled';
    var con = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( '../1.txt' ),
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );

    // if( self.special.provider instanceof _.FileProvider.HardDrive )
    // test.shouldThrowError( con );
    // if( self.special.provider instanceof _.FileProvider.SimpleStructure )
    // con.ifNoErrorThen( function( stats )
    // {
    //   test.identical( stats, null );
    // });
  });

  return consequence;
}

//

function directoryMakeSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.directoryMake ) )
  return;

  // if( self.special.provider instanceof _.FileProvider.HardDrive )
  // {
  //   File.removeSync( test.special.makePath( 'test_dir2' ) );
  // }

  try
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
      sync : 1
    })
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'make_dir' ),
      sync : 1
    })

  }
  catch ( err ){}

  test.description = 'synchronous mkdir';
  self.special.provider.directoryMake
  ({
    pathFile : test.special.makePath( 'make_dir' ),
    sync : 1
  });
  var stat = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'make_dir' ),
    sync : 1
  });

  if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
  test.identical( stat.isDirectory(), true );
  else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
  test.identical( stat.size, null );

  var stat = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
    sync : 1
  });

  test.identical( stat, null );

  test.description = 'synchronous mkdir force';
  self.special.provider.directoryMake
  ({
    pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
    sync : 1,
    force : 1
  });

  var stat = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
    sync : 1
  });

  if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
  test.identical( stat.isDirectory(), true );
  else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
  test.identical( _.objectIs( stat ), true );

  test.description = 'synchronous mkdir force, try to rewrite terminal file';
  self.special.provider.directoryMake
  ({
    pathFile : test.special.makePath( 'test_dir/test3.js' ),
    sync : 1,
    rewritingTerminal : 1
  });

  var stat = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'test_dir/test3.js' ),
    sync : 1
  });

  if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
  test.identical( stat.isDirectory(), true );
  else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
  test.identical( _.objectIs( stat ), true );

  test.description = 'synchronous mkdir force, try to rewrite empty dir';
  self.special.provider.directoryMake
  ({
    pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
    sync : 1,
    rewritingTerminal : 1
  });

  var stat = self.special.provider.fileStat
  ({
    pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
    sync : 1
  });

  if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
  test.identical( stat.isDirectory(), true );
  else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
  test.identical( _.objectIs( stat ), true );

  if( Config.debug )
  {
    test.description = 'synchronous mkdir,dir path exists no rewritingTerminal, no force';
    test.shouldThrowError( function()
    {
      debugger;
      self.special.provider.directoryMake
      ({
        pathFile : test.special.makePath( 'make_dir/dir1/dir2' ),
        sync : 1,
        force : 0,
        rewritingTerminal : 0
      });
    });

    test.description = 'synchronous mkdir, try to rewrite folder with files';
    test.shouldThrowError( function()
    {
      self.special.provider.directoryMake
      ({
        pathFile : test.special.makePath( 'make_dir' ),
        sync : 1,
        force : 0,
        rewritingTerminal : 1
      });
    });

    test.description = 'dir already exist';
    test.shouldThrowError( function()
    {
      self.special.provider.directoryMake
      ({
          pathFile : test.special.makePath( 'make_dir' ),
          sync : 1,
          force : 0,
          rewritingTerminal : 0
      });
    });

    test.description = 'folders structure not exist';
    test.shouldThrowError( function()
    {
      self.special.provider.directoryMake
      ({
          pathFile : test.special.makePath( 'dir1/dir2/make_dir' ),
          sync : 1,
          force : 0,
          rewritingTerminal : 0
      });
    });
  }
}

//

function directoryMakeAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.directoryMake ) )
  return;

  var consequence = new wConsequence().give();

  // if( self.special.provider instanceof _.FileProvider.HardDrive )
  // {
  //   File.removeSync( test.special.makePath( 'test_dir2' ) );
  // }

  try
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 1
    })
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'make_dir_async' ),
      sync : 1
    })
  }
  catch ( err ){}

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'asynchronous mkdir';
    var con = self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'make_dir_async' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var stat = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'make_dir_async' ),
      sync : 1
    });
    if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
    test.identical( stat.isDirectory(), true );
    else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
    test.identical( stat.size, null );
  })
  .ifNoErrorThen( function( err )
  {
    var stat = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 1
    });

    test.identical( stat, null );

    test.description = 'async mkdir force';
    var con = self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 0,
      force : 1
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function()
  {
    var stat = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 1
    });

    if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
    test.identical( stat.isDirectory(), true );
    else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
    test.identical( _.objectIs( stat ), true );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async mkdir force, try to rewrite terminal file';
    var con = self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'test_dir/test3.js' ),
      sync : 0,
      rewritingTerminal : 1
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function()
  {
    var stat = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'test_dir/test3.js' ),
      sync : 1
    });

    if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
    test.identical( stat.isDirectory(), true );
    else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
    test.identical( _.objectIs( stat ), true );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async mkdir force, try to rewrite empty dir';
    var con = self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 0,
      rewritingTerminal : 1
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function()
  {
    var stat = self.special.provider.fileStat
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 1
    });

    if( !isBrowser && self.special.provider instanceof _.FileProvider.HardDrive )
    test.identical( stat.isDirectory(), true );
    else if( self.special.provider instanceof _.FileProvider.SimpleStructure  )
    test.identical( _.objectIs( stat ), true );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async mkdir,dir path exists no rewritingTerminal';
    var con = self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'make_dir_async/dir1/dir2' ),
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });

    return test.shouldThrowError( con );
  })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'async mkdir, try to rewrite folder with files';
  //   var con = self.special.provider.directoryMake
  //   ({
  //     pathFile : test.special.makePath( 'make_dir_async' ),
  //     sync : 0,
  //     force : 0,
  //     rewritingTerminal : 1
  //   });
  //
  //   return test.shouldThrowError( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'dir already exist';
  //   var con = self.special.provider.directoryMake
  //   ({
  //       pathFile : test.special.makePath( 'make_dir_async' ),
  //       sync : 0,
  //       force : 0,
  //       rewritingTerminal : 0
  //   });
  //
  //   return test.shouldThrowError( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'folders structure not exist';
  //   var con = self.special.provider.directoryMake
  //   ({
  //       pathFile : test.special.makePath( 'dir1/dir2/make_dir_async' ),
  //       sync : 0,
  //       force : 0,
  //       rewritingTerminal : 0
  //   });
  //
  //   return test.shouldThrowError( con );
  // });

  return consequence;
}

//

function fileHashActSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileHashAct ) )
  return;

  if( isBrowser )
  return;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'synchronous filehash';
  var got = self.special.provider.fileHashAct
  ({
    pathFile : test.special.makePath( 'test.txt' ),
    sync : 1
  });

  var md5sum = crypto.createHash( 'md5' );
  md5sum.update( data1 );
  var expected = md5sum.digest( 'hex' );
  test.identical( got, expected );

  test.description = 'invalid path';
  var got = self.special.provider.fileHashAct
  ({
    pathFile : test.special.makePath( 'invalid.txt' ),
    sync : 1
  });
  var expected = NaN;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path throwing enabled';
    test.shouldThrowError( function( )
    {
      self.special.provider.fileHashAct
      ({
        pathFile : test.special.makePath( 'invalid.txt' ),
        sync : 1,
        throwing : 1
      });
    });

    test.description = 'is not terminal file';
    test.shouldThrowError( function( )
    {
      self.special.provider.fileHashAct
      ({
        pathFile : test.special.makePath( './' ),
        sync : 1,
        throwing : 1
      });
    });
  }


}

//

function fileHashActAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileHashAct ) )
  return;

  if( isBrowser )
  return;

  var consequence = new wConsequence().give();

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.special.provider.fileWrite
  ({
      pathFile : test.special.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  /* */

  consequence
  .ifNoErrorThen( function( hash )
  {

    test.description = 'asynchronous filehash';
    var con = self.special.provider.fileHashAct
    ({
      pathFile : test.special.makePath( 'test.txt' ),
      sync : 0
    });
    return test.shouldMessageOnlyOnce( con );

  })
  .ifNoErrorThen( function( hash )
  {

    var md5sum = crypto.createHash( 'md5' );
    md5sum.update( data1 );
    var expected = md5sum.digest( 'hex' );
    test.identical( hash, expected );

  })
  .ifNoErrorThen( function()
  {

    test.description = 'invalid path';
    var con = self.special.provider.fileHashAct
    ({
      pathFile : test.special.makePath( 'invalid.txt' ),
      sync : 0
    });
    return test.shouldMessageOnlyOnce( con );

  })
  .ifNoErrorThen( function( hash )
  {
    test.identical( hash, NaN );
  })
  .ifNoErrorThen( function()
  {

    test.description = 'invalid path throwing enabled';
    var con = self.special.provider.fileHashAct
    ({
      pathFile : test.special.makePath( 'invalid.txt' ),
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {

    test.description = 'is not terminal file';
    var con = self.special.provider.fileHashAct
    ({
      pathFile : test.special.makePath( './' ),
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

function directoryRead( test )
{

}

//

function directoryReadActSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.directoryReadAct ) )
  return;

  //make test
  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'read_dir' ),
      sync : 1
    })
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'read_dir/1' ),
      sync : 1
    })
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'read_dir/2' ),
      sync : 1
    })
    self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'read_dir/1.txt' ),
      sync : 1,
      data : 'data'
    })
  }
  catch( err ) { }

  test.description = 'synchronous read';
  var got = self.special.provider.directoryReadAct
  ({
    pathFile : test.special.makePath( 'read_dir' ),
    sync : 1
  });
  var expected = [ "1", "2", "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  test.description = 'synchronous, pathFile points to file';
  var got = self.special.provider.directoryReadAct
  ({
    pathFile : test.special.makePath( 'read_dir/1.txt' ),
    sync : 1
  });
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  test.description = 'path not exist';
  var got = self.special.provider.directoryReadAct
  ({
    pathFile : test.special.makePath( 'non_existing_folder' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  test.description = 'path not exist throwing enabled';
  test.shouldThrowError( function( )
  {
    self.special.provider.directoryReadAct
    ({
      pathFile : test.special.makePath( 'non_existing_folder' ),
      sync : 1,
      throwing : 1
    });
  })
}

//

function directoryReadActAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.directoryReadAct ) )
  return;

  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {

    debugger;
    test.description = 'async read';
    var con = self.special.provider.directoryReadAct
    ({
      pathFile : test.special.makePath( 'read_dir' ),
      sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  });

  return consequence; // xxx

  consequence
  .ifNoErrorThen( function( result )
  {
    var expected = [ "1", "2", "1.txt" ];
    test.identical( result.sort(), expected.sort() );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async, pathFile points to file';
    var con = self.special.provider.directoryReadAct
    ({
      pathFile : test.special.makePath( 'read_dir/1.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( result )
  {
    var expected = [ '1.txt' ];
    test.identical( result, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'path not exist';
    var con  = self.special.provider.directoryReadAct
    ({
      pathFile : test.special.makePath( 'non_existing_folder' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( result )
  {
    var expected = null;
    test.identical( result, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'path not exist, throwing enabled';
    var con = self.special.provider.directoryReadAct
    ({
      pathFile : test.special.makePath( 'non_existing_folder' ),
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );
  });

  return consequence;
}

//

function fileWriteSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileWrite ) )
  return;

  /*writeMode rewrite*/
  try
  {
    self.special.provider.directoryMake
    ({
      pathFile : test.special.makePath( 'write_test' ),
      sync : 1
    })
  }
  catch ( err ) { }

  /*writeMode rewrite*/
  var data = "LOREM"
  test.description ='rewrite, file not exist ';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected )

  test.description ='rewrite existing file ';
  data = "LOREM LOREM";
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try write to non existing folder';
    test.shouldThrowError( function()
    {
      self.special.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'unknown/dst.txt' ),
        data : data,
        sync : 1
      });
    });

    test.description ='try to rewrite folder';
    test.shouldThrowError( function()
    {
      self.special.provider.fileWrite
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
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'write_test/append.txt' ),
      sync : 1
    })
  }
  catch ( err ) { }
  var data = 'APPEND';
  test.description ='append, file not exist ';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  test.description ='append, to file ';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = 'APPENDAPPEND';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try append to non existing folder';
    test.shouldThrowError( function()
    {
      self.special.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'append',
        sync : 1
      });
    });

    test.description ='try to append to folder';
    test.shouldThrowError( function()
    {
      self.special.provider.fileWrite
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
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'write_test/prepend.txt' ),
      sync : 1
    })
  }
  catch ( err ) { }
  var data = 'Lorem';
  test.description ='prepend, file not exist ';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  data = 'new text';
  test.description ='prepend to file ';
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = 'new textLorem';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try prepend to non existing folder';
    test.shouldThrowError( function()
    {
      self.special.provider.fileWrite
      ({
        pathFile : test.special.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'prepend',
        sync : 1
      });
    });

    test.description ='try to prepend to folder';
    test.shouldThrowError( function()
    {
      self.special.provider.fileWrite
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

  if( !_.routineIs( self.special.provider.fileWrite ) )
  return;

  var consequence = new wConsequence().give();
  /*writeMode rewrite*/
  try
  {
    self.special.provider.directoryMake
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
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.special.provider.fileRead
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
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.special.provider.fileRead
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
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'unknown/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try to rewrite folder';
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test' ),
      data : data,
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  /*writeMode append*/
  .ifNoErrorThen( function()
  {
    try
    {
      self.special.provider.fileDelete
      ({
        pathFile : test.special.makePath( 'write_test/append.txt' ),
        sync : 1
      })
    }
    catch ( err ) { }

    data = 'APPEND';
    test.description ='append, file not exist ';
    var con = self.special.provider.fileWrite
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
    var got = self.special.provider.fileRead
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
    var con = self.special.provider.fileWrite
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
    var got = self.special.provider.fileRead
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
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'unknown/dst.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try to append to folder';
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  /*writeMode prepend*/
  .ifNoErrorThen( function()
  {
    try
    {
      self.special.provider.fileDelete
      ({
        pathFile : test.special.makePath( 'write_test/prepend.txt' ),
        sync : 1
      })
    }
    catch ( err ) { }

    data = 'Lorem';
    test.description ='prepend, file not exist ';
    var con = self.special.provider.fileWrite
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
    var got = self.special.provider.fileRead
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
    var con = self.special.provider.fileWrite
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
    var got = self.special.provider.fileRead
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
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'unknown/dst.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try prepend to folder';
    var con = self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'write_test' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    test.shouldThrowError( con );
  });

  return consequence;
}

//

function linkSoftActSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.linkSoftAct ) )
  return;

  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link.txt' ),
      sync : 1
    });
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  test.description = 'make link sync';
  self.special.provider.linkSoftAct
  ({
    pathSrc : test.special.makePath( 'link_test.txt' ),
    pathDst : test.special.makePath( 'link.txt' ),
  });
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'link_test.txt' ),
    writeMode : 'append',
    data : 'new text',
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'link.txt' ),
    sync : 1
  });
  var expected = '000new text';
  test.identical( got, expected );

  test.description = 'make for file that not exist';
  self.special.provider.linkSoftAct
  ({
    pathSrc : test.special.makePath( 'no_file.txt' ),
    pathDst : test.special.makePath( 'link2.txt' ),
  });
  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'no_file.txt' ),
    data : 'new text',
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'link2.txt' ),
    sync : 1
  });
  var expected = 'new text';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'link already exists';
    test.shouldThrowError( function( )
    {
      self.special.provider.linkSoftAct
      ({
        pathSrc : test.special.makePath( 'link_test.txt' ),
        pathDst : test.special.makePath( 'link.txt' ),
      });
    });
  }
}

//

function fileReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.fileRead ) )
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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
    var con = self.special.provider.fileRead
    ({
      pathFile : self.special.testFile,
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

function linkSoftActAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.linkSoftAct ) )
  return;

  var consequence = new wConsequence().give();

  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link.txt' ),
      sync : 1
    });
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'make link async';
    var con = self.special.provider.linkSoftAct
    ({
      pathSrc : test.special.makePath( 'link_test.txt' ),
      pathDst : test.special.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })

  .ifNoErrorThen( function( err )
  {
    self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'link_test.txt' ),
      writeMode : 'append',
      data : 'new text',
      sync : 1
    });
    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'link.txt' ),
      sync : 1
    });
    var expected = '000new text';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'make for file that not exist';
    var con = self.special.provider.linkSoftAct
    ({
      pathSrc : test.special.makePath( 'no_file.txt' ),
      pathDst : test.special.makePath( 'link2.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'no_file.txt' ),
      data : 'new text',
      sync : 1
    });
    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'link2.txt' ),
      sync : 1
    });
    var expected = 'new text';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'link already exists';
    var con = self.special.provider.linkSoftAct
    ({
      pathSrc : test.special.makePath( 'link_test.txt' ),
      pathDst : test.special.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldThrowError( con );
  });

 return consequence;
}

//

function linkHardActSync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.linkHardAct ) )
  return;

  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link.txt' ),
      sync : 1
    });
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  test.description = 'src is equal dst';
  var got = self.special.provider.linkHardAct
  ({
    pathSrc : test.special.makePath( 'link_test.txt' ),
    pathDst : test.special.makePath( 'link_test.txt' )
  });
  var expected = true;
  test.identical( got, expected );

  test.description = 'make hardlink sync';
  self.special.provider.linkHardAct
  ({
    pathSrc : test.special.makePath( 'link_test.txt' ),
    pathDst : test.special.makePath( 'link.txt' )
  });
  self.special.provider.fileDelete
  ({
    pathFile : test.special.makePath( 'link_test.txt' ),
    sync : 1
  });
  var got = self.special.provider.fileRead
  ({
    pathFile : test.special.makePath( 'link.txt' ),
    sync : 1
  });
  var expected = '000';
  test.identical( got, expected );


  if( Config.debug )
  {
    test.description = 'source file doesn`t exist';
    test.shouldThrowError( function( )
    {
      self.special.provider.linkHardAct
      ({
        pathSrc : test.special.makePath( 'not_exist.txt' ),
        pathDst : test.special.makePath( 'link.txt' )
      });
    });

    test.description = 'target link already exists';
    self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'link_test.txt' ),
      data : '000',
      sync : 1
    });
    test.shouldThrowError( function( )
    {
      self.special.provider.linkHardAct
      ({
        pathSrc : test.special.makePath( 'link_test.txt' ),
        pathDst : test.special.makePath( 'link.txt' )
      });
    });
  }

}

//

function linkHardActAsync( test )
{
  var self = this;

  if( !_.routineIs( self.special.provider.linkHardAct ) )
  return;

  var consequence = new wConsequence().give();

  self.special.provider.fileWrite
  ({
    pathFile : test.special.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link.txt' ),
      sync : 1
    });
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'make hardlink sync';
    var con = self.special.provider.linkHardAct
    ({
      pathSrc : test.special.makePath( 'link_test.txt' ),
      pathDst : test.special.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function ( err )
  {
    self.special.provider.fileDelete
    ({
      pathFile : test.special.makePath( 'link_test.txt' ),
      sync : 1
    });
    var got = self.special.provider.fileRead
    ({
      pathFile : test.special.makePath( 'link.txt' ),
      sync : 1
    });
    var expected = '000';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ()
  {

    test.description = 'src is equal dst';
    var con = self.special.provider.linkHardAct
    ({
      pathSrc : test.special.makePath( 'link_test.txt' ),
      pathDst : test.special.makePath( 'link_test.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function ( result )
  {
    var expected = true;
    test.identical( result, expected );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'source file doesn`t exist';
    var con = self.special.provider.linkHardAct
    ({
      pathSrc : test.special.makePath( 'not_exist.txt' ),
      pathDst : test.special.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'target link already exists';
    self.special.provider.fileWrite
    ({
      pathFile : test.special.makePath( 'link_test.txt' ),
      data : '000',
      sync : 1
    });
    var con = self.special.provider.linkHardAct
    ({
      pathSrc : test.special.makePath( 'link_test.txt' ),
      pathDst : test.special.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldThrowError( con );
  });

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

    readWriteSync : readWriteSync,
    readWriteAsync : readWriteAsync,

    // writeAsyncThrowingError : writeAsyncThrowingError,

    fileCopySync : fileCopySync,
    fileCopyAsync : fileCopyAsync,
    fileCopyAsyncThrowingError : fileCopyAsyncThrowingError,/* last case dont throw error */

    fileRenameSync : fileRenameSync,
    fileRenameAsync : fileRenameAsync,

    fileDeleteSync : fileDeleteSync,
    fileDeleteAsync : fileDeleteAsync,/*dont throw error */

    fileStatSync : fileStatSync,
    fileStatAsync : fileStatAsync,

    // directoryMakeSync : directoryMakeSync,
    // directoryMakeAsync : directoryMakeAsync,
    //
    // fileHashActSync : fileHashActSync,
    // fileHashActAsync : fileHashActAsync,
    //
    // directoryRead : directoryRead,
    //
    // directoryReadActSync : directoryReadActSync,
    // directoryReadActAsync : directoryReadActAsync, /* xxx */
    //
    // fileWriteSync : fileWriteSync,
    // fileWriteAsync : fileWriteAsync,
    //
    // fileReadAsync : fileReadAsync,
    //
    // linkSoftActSync : linkSoftActSync,
    // linkSoftActAsync : linkSoftActAsync,
    //
    // linkHardActSync : linkHardActSync,
    // linkHardActAsync : linkHardActAsync

  },

};

// _.mapExtend( Self,Proto );
// Object.setPrototypeOf( Self, Parent );

wTestSuite( Self );

} )( );
