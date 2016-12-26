( function _FileProvider_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  //require( '../../../../wTesting/staging/abase/object/Testing.debug.s' );
  //require( '../../../../wConsequence/staging/abase/syn/Consequence.s' );

  try
  {
    require( '../ServerTools.ss' );
  }
  catch( err )
  {
  }

  try
  {
    require( '../../wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  if( !_global_.wTesting )
  require( 'wTesting' );

  require( '../file/Files.ss' );

  var crypto = require( 'crypto' );

}

//

var _ = wTools;
var Self = {};
var Parent = wTools.Testing;

//

var makePath  = function( pathFile )
{
  return pathFile;
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

  con.thenDo( function( ){ logger.log( '1000ms delay' ) } );

  con.thenDo( _.routineSeal( _,_.timeOut,[ 1000 ] ) );

  con.thenDo( function( ){ logger.log( '2000ms delay' ) } );

  con.thenDo( function( ){ test.identical( 1,1 ); } );

  return con;
}

//

var readWriteSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  return;

  test.description = 'syncronous, writeMode : rewrite';
  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    data : data1,
    sync : 1,
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  test.description = 'syncronous, writeMode : append';
  var data2 = 'LOREM';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    data : data2,
    sync : 1,
    writeMode : 'append'
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    sync : 1
  });
  var expected = data1 + data2;
  test.identical( got, expected );

  test.description = 'syncronous, writeMode : prepend';
  var data2 = 'LOREM';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    data : data2,
    sync : 1,
    writeMode : 'prepend'
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    sync : 1
  });
  var expected = data2 + data1 + data2;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'file doesn`t exist';
    test.shouldThrowError( function( )
    {
      self.provider.fileReadAct
      ({
        pathFile : self.makePath( 'unknown' ),
        sync : 1
      });
    });

    test.description = 'try to read dir';
    test.shouldThrowError( function( )
    {
      self.provider.fileReadAct
      ({
        pathFile : self.makePath( './' ),
        sync : 1
      });
    });
  }
}

//

var readWriteAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  return;

  var consequence = new wConsequence().give();

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  var data2 = 'LOREM';

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'async, writeMode : rewrite';
    var con =  self.provider.fileWriteAct
    ({
        pathFile : self.makePath( 'test.txt' ),
        data : data1,
        sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'test.txt' ),
      sync : 1,
    });

    test.identical( got, data1 );

  })
  .ifNoErrorThen( function()
  {

    test.description = 'async, writeMode : append';
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'test.txt' ),
      data : data2,
      sync : 0,
      writeMode : 'append'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {

    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'test.txt' ),
      sync : 1,
    });

    var expected = data1 + data2;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'file doesn`t exist';
    var con = self.provider.fileReadAct
    ({
      pathFile : makePath( 'unknown' ),
      sync : 0
    });
    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'try to read dir';
    var con = self.provider.fileReadAct
    ({
      pathFile : makePath( './' ),
      sync : 0
    });
    return test.shouldThrowError( con );
  });

  return consequence;
}

//

var writeAsyncThrowingError = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  return;

  var consequence = new wConsequence().give();
  // if( self.provider instanceof _.FileProvider.HardDrive )
  // {
  //   File.removeSync( self.makePath( 'test_dir2' ) );
  // }

  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'dir' ),
      sync : 1
    })
  }
  catch ( err ) { }

  consequence
  .ifNoErrorThen( function()
  {

    test.description = 'async, try to rewrite dir';

    var data1 = 'data1';
    var con = self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'dir' ),
      data : data1,
      sync : 0,
    });

    return test.shouldThrowError( con );
  })

  return consequence;
}

//

var fileCopyActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  return;

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous copy';
  self.provider.fileCopyAct
  ({
      pathSrc : self.makePath( 'test.txt' ),
      pathDst : self.makePath( 'pathDst.txt' ),
      sync : 1,
  });
  var got = self.provider.fileReadAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  test.description = 'syncronous rewrite existing file';
  self.provider.fileCopyAct
  ({
      pathSrc : self.makePath( 'pathDst.txt' ),
      pathDst : self.makePath( 'test.txt' ),
      sync : 1,
  });
  var got = self.provider.fileReadAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid pathSrc path';
    test.shouldThrowError( function()
    {
      self.provider.fileCopyAct
      ({
          pathSrc : self.makePath( 'invalid.txt' ),
          pathDst : self.makePath( 'pathDst.txt' ),
          sync : 1,
      });
    });

    test.description = 'try to rewrite dir';
    test.shouldThrowError( function()
    {
      self.provider.fileCopyAct
      ({
          pathSrc : self.makePath( 'invalid.txt' ),
          pathDst : self.makePath( 'tmp' ),
          sync : 1,
      });
    });

    test.description = 'syncronous copy dir';
    try
    {
      self.provider.directoryMakeAct
      ({
        pathFile : self.makePath( 'copydir' ),
        sync : 1
      });
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'copydir/copyfile.txt' ),
        data : 'Lorem',
        sync : 1
      });
    } catch ( err ) { }

    test.shouldThrowError( function( )
    {
      self.provider.fileCopyAct
      ({
          pathSrc : self.makePath( 'copydir' ),
          pathDst : self.makePath( 'copydir2' ),
          sync : 1,
      });
    })
  }
}

//

var fileCopyActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  return;

  var consequence = new wConsequence().give();
  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';

  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'asyncronous copy';
    var con =  self.provider.fileCopyAct
    ({
      pathSrc : self.makePath( 'test.txt' ),
      pathDst : self.makePath( 'pathDst.txt' ),
      sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'pathDst.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'syncronous rewrite existing file';

    var con =  self.provider.fileCopyAct
    ({
        pathSrc : self.makePath( 'pathDst.txt' ),
        pathDst : self.makePath( 'test.txt' ),
        sync : 0,
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'test.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  });

  return consequence;
}

//

var fileCopyActAsyncThrowingError = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  return;

  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'async, throwing error';
    var con =  self.provider.fileCopyAct
    ({
      pathSrc : self.makePath( 'invalid.txt' ),
      pathDst : self.makePath( 'pathDst.txt' ),
      sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async,try rewrite dir';
    var con =  self.provider.fileCopyAct
    ({
      pathSrc : self.makePath( 'invalid.txt' ),
      pathDst : self.makePath( 'tmp' ),
      sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'syncronous copy dir';
    try
    {
      self.provider.directoryMakeAct
      ({
        pathFile : self.makePath( 'copydir' ),
        sync : 1
      });
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'copydir/copyfile.txt' ),
        data : 'Lorem',
        sync : 1
      });
    } catch ( err ) { }

    var con =  self.provider.fileCopyAct
    ({
        pathSrc : self.makePath( 'copydir' ),
        pathDst : self.makePath( 'copydir2' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

var fileRenameActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRenameAct ) )
  return;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous rename';
  self.provider.fileRenameAct
  ({
    pathSrc : self.makePath( 'pathDst.txt' ),
    pathDst : self.makePath( 'newfile.txt' ),
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'newfile.txt' ),
    sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid pathSrc path';
    test.shouldThrowError( function()
    {
      self.provider.fileRenameAct
      ({
          pathSrc : self.makePath( 'invalid.txt' ),
          pathDst : self.makePath( 'newfile.txt' ),
          sync : 1,
      });
    });
  }
}

//

var fileRenameActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRenameAct ) )
  return;

  var consequence = new wConsequence().give();
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  consequence
  .ifNoErrorThen( function()
  {

    test.description = 'asyncronous rename';
    var con = self.provider.fileRenameAct
    ({
      pathSrc : self.makePath( 'pathDst.txt' ),
      pathDst : self.makePath( 'newfile2.txt' ),
      sync : 0
    });
    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function()
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'newfile2.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'invalid pathSrc path';

    var con = self.provider.fileRenameAct
    ({
      pathSrc : self.makePath( '///bad path///test.txt' ),
      pathDst : self.makePath( 'pathDst.txt' ),
      sync : 0,
    });

    return test.shouldThrowError( con );

    // return con;
  });

  return consequence;
}

//

var fileDeleteActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDeleteAct ) )
  return;

  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'dir' ),
      sync : 1
    });

  } catch ( err ){ }
  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'dir/dir2' ),
      sync : 1
    });

  } catch ( err ){ }

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'dir/pathDst.txt' ),
      data : data1,
      sync : 1,
  });
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'dir/dir2/pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous delete';
  self.provider.fileDeleteAct
  ({
    pathFile : self.makePath( 'pathDst.txt' ),
    sync : 1
  });
  var got = self.provider.fileStatAct
  ({
    pathFile : self.makePath( 'pathDst.txt' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  test.description = 'syncronous delete empty dir';
  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'empty_dir' ),
      sync : 1
    });
  } catch ( err ){ }
  self.provider.fileDeleteAct
  ({
    pathFile : self.makePath( 'empty_dir' ),
    sync : 1
  });
  var got = self.provider.fileStatAct
  ({
    pathFile : self.makePath( 'empty_dir' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path';
    test.shouldThrowError( function()
    {
      self.provider.fileDeleteAct
      ({
          pathFile : self.makePath( '///bad path///test.txt' ),
          sync : 1,
      });
    });

    test.description = 'not empty dir';
    test.shouldThrowError( function()
    {
      self.provider.fileDeleteAct
      ({
          pathFile : self.makePath( 'dir' ),
          sync : 1,
      });
    });

    test.description = 'not empty dir inner level';
    test.shouldThrowError( function()
    {
      self.provider.fileDeleteAct
      ({
          pathFile : self.makePath( 'dir/dir2' ),
          sync : 1,
      });
    });
  }

}

//

var fileDeleteActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDeleteAct ) )
  return;

  var consequence = new wConsequence().give();
  var data1 = 'Excepteur sint occaecat cupidatat non proident';

  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'dir' ),
      sync : 1
    });

  } catch ( err ){ }
  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'dir/dir2' ),
      sync : 1
    });

  } catch ( err ){ }

  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'dir/dir2/pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  consequence
  .ifNoErrorThen( function()
  {
    self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'dir/pathDst.txt' ),
      data : data1,
      sync : 1,
    });

    test.description = 'asyncronous delete';
    var con = self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'pathDst.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileStatAct
    ({
      pathFile : self.makePath( 'pathDst.txt' ),
      sync : 1
    });
    var expected = null;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'syncronous delete empty dir';
    try
    {
      self.provider.directoryMakeAct
      ({
        pathFile : self.makePath( 'empty_dir' ),
        sync : 1
      });
    } catch ( err ){ }

    var con = self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'empty_dir' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileStatAct
    ({
      pathFile : self.makePath( 'empty_dir' ),
      sync : 1
    });
    var expected = null;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'invalid  path';
    var con = self.provider.fileDeleteAct
    ({
        pathFile : self.makePath( 'somefile.txt' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'not empty dir';
    var con = self.provider.fileDeleteAct
    ({
        pathFile : self.makePath( 'dir' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'not empty dir inner level';
    var con = self.provider.fileDeleteAct
    ({
        pathFile : self.makePath( 'dir/dir2' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

var fileStatActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStatAct ) )
  return;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous file stat';
  var got = self.provider.fileStatAct
  ({
    pathFile : self.makePath( 'pathDst.txt' ),
    sync : 1
  });
  var expected;
  if( self.provider instanceof _.FileProvider.HardDrive )
  {
    expected = 46;
  }
  else if( self.provider instanceof _.FileProvider.SimpleStructure )
  {
    expected = null;
  }
  test.identical( got.size, expected );

  test.description = 'invalid path';
  var got = self.provider.fileStatAct
  ({
    pathFile : self.makePath( '///bad path///test.txt' ),
    sync : 1,
  });
  var expected = null;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path throwing enabled';
    test.shouldThrowError( function( )
    {
      self.provider.fileStatAct
      ({
        pathFile : self.makePath( '///bad path///test.txt' ),
        sync : 1,
        throwing : 1
      });
    });
  }

}

//

var fileStatActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStatAct ) )
  return;

  var consequence = new wConsequence().give();

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'asyncronous file stat';
    var con =  self.provider.fileStatAct
    ({
      pathFile : self.makePath( 'pathDst.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( stats )
  {
    var expected;
    if( self.provider instanceof _.FileProvider.HardDrive )
    {
      expected = 46;
    }
    else if( self.provider instanceof _.FileProvider.SimpleStructure )
    {
      expected = null;
    }
    test.identical( stats.size, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'invalid path';
    var con =  self.provider.fileStatAct
    ({
        pathFile : self.makePath( '../1.txt' ),
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
    var con =  self.provider.fileStatAct
    ({
        pathFile : self.makePath( '../1.txt' ),
        sync : 0,
        throwing : 1
    });
    return test.shouldThrowError( con );

    // if( self.provider instanceof _.FileProvider.HardDrive )
    // test.shouldThrowError( con );
    // if( self.provider instanceof _.FileProvider.SimpleStructure )
    // con.ifNoErrorThen( function( stats )
    // {
    //   test.identical( stats, null );
    // });
  });

  return consequence;
}

//

var directoryMakeActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryMakeAct ) )
  return;

  // if( self.provider instanceof _.FileProvider.HardDrive )
  // {
  //   File.removeSync( self.makePath( 'test_dir2' ) );
  // }

  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'make_dir' ),
      sync : 1
    })
  }
  catch ( err ){}

  test.description = 'syncronous mkdir';
  self.provider.directoryMakeAct
  ({
    pathFile : self.makePath( 'make_dir' ),
    sync : 1
  });
  var stat = self.provider.fileStatAct
  ({
    pathFile : self.makePath( 'make_dir' ),
    sync : 1
  });

  if( self.provider instanceof _.FileProvider.HardDrive )
  test.identical( stat.isDirectory(), true );
  else if( self.provider instanceof _.FileProvider.SimpleStructure  )
  test.identical( stat.size, null );

  if( Config.debug )
  {
    test.description = 'dir already exist';
    test.shouldThrowError( function()
    {
      self.provider.directoryMakeAct
      ({
          pathFile : self.makePath( 'make_dir' ),
          sync : 1,
      });
    });

    test.description = 'folders structure not exist';
    test.shouldThrowError( function()
    {
      self.provider.directoryMakeAct
      ({
          pathFile : self.makePath( 'dir1/dir2/make_dir' ),
          sync : 1,
      });
    });
  }
}

//

var directoryMakeActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryMakeAct ) )
  return;

  var consequence = new wConsequence().give();

  // if( self.provider instanceof _.FileProvider.HardDrive )
  // {
  //   File.removeSync( self.makePath( 'test_dir2' ) );
  // }

  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'make_dir' ),
      sync : 1
    })
  }
  catch ( err ){}

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'asyncronous mkdir';
    var con =  self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'make_dir' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var stat = self.provider.fileStatAct
    ({
      pathFile : self.makePath( 'make_dir' ),
      sync : 1
    });
    if( self.provider instanceof _.FileProvider.HardDrive )
    test.identical( stat.isDirectory(), true );
    else if( self.provider instanceof _.FileProvider.SimpleStructure  )
    test.identical( stat.size, null );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'dir already exist';
    var con = self.provider.directoryMakeAct
    ({
        pathFile : self.makePath( 'make_dir' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'folders structure not exist';
    var con = self.provider.directoryMakeAct
    ({
        pathFile : self.makePath( 'dir1/dir2/make_dir' ),
        sync : 0,
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

var fileHashActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileHashAct ) )
  return;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous filehash';
  var got = self.provider.fileHashAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    sync : 1
  });

  var md5sum = crypto.createHash( 'md5' );
  md5sum.update( data1 );
  var expected = md5sum.digest( 'hex' );
  test.identical( got, expected );

  test.description = 'invalid path';
  var got = self.provider.fileHashAct
  ({
    pathFile : self.makePath( 'invalid.txt' ),
    sync : 1
  });
  var expected = NaN;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path throwing enabled';
    test.shouldThrowError( function( )
    {
      self.provider.fileHashAct
      ({
        pathFile : self.makePath( 'invalid.txt' ),
        sync : 1,
        throwing : 1
      });
    });

    test.description = 'is not terminal file';
    test.shouldThrowError( function( )
    {
      self.provider.fileHashAct
      ({
        pathFile : self.makePath( './' ),
        sync : 1,
        throwing : 1
      });
    });
  }


}

//

var fileHashActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileHashAct ) )
  return;

  var consequence = new wConsequence().give();

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  /* */

  consequence
  .ifNoErrorThen( function( hash )
  {

    test.description = 'asyncronous filehash';
    var con = self.provider.fileHashAct
    ({
      pathFile : self.makePath( 'test.txt' ),
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
    var con = self.provider.fileHashAct
    ({
      pathFile : self.makePath( 'invalid.txt' ),
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
    var con = self.provider.fileHashAct
    ({
      pathFile : self.makePath( 'invalid.txt' ),
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {

    test.description = 'is not terminal file';
    var con = self.provider.fileHashAct
    ({
      pathFile : self.makePath( './' ),
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

var directoryReadActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryReadAct ) )
  return;

  //make test
  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'read_dir' ),
      sync : 1
    })
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'read_dir/1' ),
      sync : 1
    })
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'read_dir/2' ),
      sync : 1
    })
    self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'read_dir/1.txt' ),
      sync : 1,
      data : 'data'
    })
  }
  catch( err ) { }

  test.description = 'syncronous read';
  var got = self.provider.directoryReadAct
  ({
    pathFile : self.makePath( 'read_dir' ),
    sync : 1
  });
  var expected = [ "1", "2", "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  test.description = 'syncronous, pathFile points to file';
  var got = self.provider.directoryReadAct
  ({
    pathFile : self.makePath( 'read_dir/1.txt' ),
    sync : 1
  });
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  test.description = 'path not exist';
  var got = self.provider.directoryReadAct
  ({
    pathFile : self.makePath( 'non_existing_folder' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  test.description = 'path not exist throwing enabled';
  test.shouldThrowError( function( )
  {
    self.provider.directoryReadAct
    ({
      pathFile : self.makePath( 'non_existing_folder' ),
      sync : 1,
      throwing : 1
    });
  })
}

//

var directoryReadActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryReadAct ) )
  return;

  var consequence = new wConsequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = ' async read';
    var con =  self.provider.directoryReadAct
    ({
      pathFile : self.makePath( 'read_dir' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })

  .ifNoErrorThen( function( result )
  {
    var expected = [ "1", "2", "1.txt" ];
    test.identical( result.sort(), expected.sort() );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async, pathFile points to file';
    var con =  self.provider.directoryReadAct
    ({
      pathFile : self.makePath( 'read_dir/1.txt' ),
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
    var con  =  self.provider.directoryReadAct
    ({
      pathFile : self.makePath( 'non_existing_folder' ),
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
    var con =  self.provider.directoryReadAct
    ({
      pathFile : self.makePath( 'non_existing_folder' ),
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );
  });

  return consequence;
}

//

var fileWriteActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  return;

  /*writeMode rewrite*/
  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'write_test' ),
      sync : 1
    })
  }
  catch ( err ) { }

  /*writeMode rewrite*/
  var data = "LOREM"
  test.description ='rewrite, file not exist ';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected )

  test.description ='rewrite existing file ';
  data = "LOREM LOREM";
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try write to non existing folder';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'unknown/dst.txt' ),
        data : data,
        sync : 1
      });
    });

    test.description ='try to rewrite folder';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'write_test' ),
        data : data,
        sync : 1
      });
    });
  }

  /*writeMode append*/
  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'write_test/append.txt' ),
      sync : 1
    })
  }
  catch ( err ) { }
  var data = 'APPEND';
  test.description ='append, file not exist ';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  test.description ='append, to file ';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = 'APPENDAPPEND';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try append to non existing folder';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'append',
        sync : 1
      });
    });

    test.description ='try to append to folder';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'write_test' ),
        data : data,
        writeMode : 'append',
        sync : 1
      });
    });
  }
  /*writeMode prepend*/
  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'write_test/prepend.txt' ),
      sync : 1
    })
  }
  catch ( err ) { }
  var data = 'Lorem';
  test.description ='prepend, file not exist ';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  data = 'new text';
  test.description ='prepend to file ';
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = 'new textLorem';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description ='try prepend to non existing folder';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'prepend',
        sync : 1
      });
    });

    test.description ='try to prepend to folder';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'write_test' ),
        data : data,
        writeMode : 'prepend',
        sync : 1
      });
    });
  }
}

//

var fileWriteActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  return;

  var consequence = new wConsequence().give();
  /*writeMode rewrite*/
  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'write_test' ),
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
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'write_test/dst.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected )
  })
  .ifNoErrorThen( function()
  {
    test.description ='rewrite existing file ';
    data = "LOREM LOREM";
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'write_test/dst.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try write to non existing folder';
    var con = self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'unknown/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try to rewrite folder';
    var con = self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test' ),
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
      self.provider.fileDeleteAct
      ({
        pathFile : self.makePath( 'write_test/append.txt' ),
        sync : 1
      })
    }
    catch ( err ) { }

    data = 'APPEND';
    test.description ='append, file not exist ';
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test/append.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'write_test/append.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='append, to file ';
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test/append.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'write_test/append.txt' ),
      sync : 1
    });
    var expected = 'APPENDAPPEND';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try append to non existing folder';
    var con = self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'unknown/dst.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try to append to folder';
    var con = self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test' ),
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
      self.provider.fileDeleteAct
      ({
        pathFile : self.makePath( 'write_test/prepend.txt' ),
        sync : 1
      })
    }
    catch ( err ) { }

    data = 'Lorem';
    test.description ='prepend, file not exist ';
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test/prepend.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'write_test/prepend.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    data = 'new text';
    test.description ='prepend to file ';
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test/prepend.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'write_test/prepend.txt' ),
      sync : 1
    });
    var expected = 'new textLorem';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try prepend to non existing folder';
    var con = self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'unknown/dst.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    test.description ='try prepend to folder';
    var con =  self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'write_test' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    test.shouldThrowError( con );
  });

  return consequence;
}

//

var linkSoftActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoftAct ) )
  return;

  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link.txt' ),
      sync : 1
    });
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  test.description = 'make link sync';
  self.provider.linkSoftAct
  ({
    pathSrc : self.makePath( 'link_test.txt' ),
    pathDst : self.makePath( 'link.txt' ),
  });
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'link_test.txt' ),
    writeMode : 'append',
    data : 'new text',
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'link.txt' ),
    sync : 1
  });
  var expected = '000new text';
  test.identical( got, expected );

  test.description = 'make for file that not exist';
  self.provider.linkSoftAct
  ({
    pathSrc : self.makePath( 'no_file.txt' ),
    pathDst : self.makePath( 'link2.txt' ),
  });
  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'no_file.txt' ),
    data : 'new text',
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'link2.txt' ),
    sync : 1
  });
  var expected = 'new text';
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'link already exists';
    test.shouldThrowError( function( )
    {
      self.provider.linkSoftAct
      ({
        pathSrc : self.makePath( 'link_test.txt' ),
        pathDst : self.makePath( 'link.txt' ),
      });
    });
  }
}

//

var fileReadActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileReadAct ) )
  return;

  var consequence = new wConsequence().give();

  var encode = function( src, encoding )
  {
    return new Buffer( src ).toString( encoding );
  }

  var src = 'Copyright (c) 2013-2016 Kostiantyn Wandalen';

  consequence
  .ifNoErrorThen( function()
  {
    test.description ='read from file';
    var con =  self.provider.fileReadAct
    ({
      pathFile : self.testFile,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = src;
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.description ='read from file, encoding : ascii';
    var con = self.provider.fileReadAct
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
    var con = self.provider.fileReadAct
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
    var con = self.provider.fileReadAct
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
    var con = self.provider.fileReadAct
    ({
      pathFile : self.testFile,
      sync : 0,
      encoding : 'base64'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'base64' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })

  return consequence;
}

//

var linkSoftActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoftAct ) )
  return;

  var consequence = new wConsequence().give();

  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link.txt' ),
      sync : 1
    });
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'make link async';
    var con =  self.provider.linkSoftAct
    ({
      pathSrc : self.makePath( 'link_test.txt' ),
      pathDst : self.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })

  .ifNoErrorThen( function( err )
  {
    self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'link_test.txt' ),
      writeMode : 'append',
      data : 'new text',
      sync : 1
    });
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'link.txt' ),
      sync : 1
    });
    var expected = '000new text';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'make for file that not exist';
    var con =  self.provider.linkSoftAct
    ({
      pathSrc : self.makePath( 'no_file.txt' ),
      pathDst : self.makePath( 'link2.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( err )
  {
    self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'no_file.txt' ),
      data : 'new text',
      sync : 1
    });
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'link2.txt' ),
      sync : 1
    });
    var expected = 'new text';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'link already exists';
    var con = self.provider.linkSoftAct
    ({
      pathSrc : self.makePath( 'link_test.txt' ),
      pathDst : self.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldThrowError( con );
  });

 return consequence;
}

//

var linkHardActSync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  return;

  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link.txt' ),
      sync : 1
    });
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  test.description = 'src is equal dst';
  var got = self.provider.linkHardAct
  ({
    pathSrc : self.makePath( 'link_test.txt' ),
    pathDst : self.makePath( 'link_test.txt' )
  });
  var expected = true;
  test.identical( got, expected );

  test.description = 'make hardlink sync';
  self.provider.linkHardAct
  ({
    pathSrc : self.makePath( 'link_test.txt' ),
    pathDst : self.makePath( 'link.txt' )
  });
  self.provider.fileDeleteAct
  ({
    pathFile : self.makePath( 'link_test.txt' ),
    sync : 1
  });
  var got = self.provider.fileReadAct
  ({
    pathFile : self.makePath( 'link.txt' ),
    sync : 1
  });
  var expected = '000';
  test.identical( got, expected );


  if( Config.debug )
  {
    test.description = 'source file doesn`t exist';
    test.shouldThrowError( function( )
    {
      self.provider.linkHardAct
      ({
        pathSrc : self.makePath( 'not_exist.txt' ),
        pathDst : self.makePath( 'link.txt' )
      });
    });

    test.description = 'target link already exists';
    self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'link_test.txt' ),
      data : '000',
      sync : 1
    });
    test.shouldThrowError( function( )
    {
      self.provider.linkHardAct
      ({
        pathSrc : self.makePath( 'link_test.txt' ),
        pathDst : self.makePath( 'link.txt' )
      });
    });
  }

}

//

var linkHardActAsync = function( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  return;

  var consequence = new wConsequence().give();


  self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'link_test.txt' ),
    data : '000',
    sync : 1
  });

  try
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link.txt' ),
      sync : 1
    });
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link2.txt' ),
      sync : 1
    });
  }
  catch ( err ) { }

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'make hardlink sync';
    var con = self.provider.linkHardAct
    ({
      pathSrc : self.makePath( 'link_test.txt' ),
      pathDst : self.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function ( err )
  {
    self.provider.fileDeleteAct
    ({
      pathFile : self.makePath( 'link_test.txt' ),
      sync : 1
    });
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'link.txt' ),
      sync : 1
    });
    var expected = '000';
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ()
  {

    test.description = 'src is equal dst';
    var con =  self.provider.linkHardAct
    ({
      pathSrc : self.makePath( 'link_test.txt' ),
      pathDst : self.makePath( 'link_test.txt' ),
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
    var con = self.provider.linkHardAct
    ({
      pathSrc : self.makePath( 'not_exist.txt' ),
      pathDst : self.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldThrowError( con );
  })
  .ifNoErrorThen( function ()
  {
    test.description = 'target link already exists';
    self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'link_test.txt' ),
      data : '000',
      sync : 1
    });
    var con = self.provider.linkHardAct
    ({
      pathSrc : self.makePath( 'link_test.txt' ),
      pathDst : self.makePath( 'link.txt' ),
      sync : 0
    });

    return test.shouldThrowError( con );
  });

  return consequence;
}

//

// --
// proto
// --

var Proto =
{

  name : 'FileProvider',
  makePath : makePath,

  tests :
  {

    //testDelaySample : testDelaySample,

    readWriteSync : readWriteSync,
    readWriteAsync : readWriteAsync,
    writeAsyncThrowingError : writeAsyncThrowingError,
    fileCopyActSync : fileCopyActSync,
    fileCopyActAsync : fileCopyActAsync,
    fileCopyActAsyncThrowingError : fileCopyActAsyncThrowingError,
    fileRenameActSync : fileRenameActSync,
    fileRenameActAsync : fileRenameActAsync,
    fileDeleteActSync : fileDeleteActSync,
    fileDeleteActAsync : fileDeleteActAsync,
    fileStatActSync : fileStatActSync,
    fileStatActAsync : fileStatActAsync,
    directoryMakeActSync : directoryMakeActSync,
    directoryMakeActAsync : directoryMakeActAsync,
    fileHashActSync : fileHashActSync,
    fileHashActAsync : fileHashActAsync,
    directoryReadActSync : directoryReadActSync,
    directoryReadActAsync : directoryReadActAsync,
    fileWriteActSync : fileWriteActSync,
    fileWriteActAsync : fileWriteActAsync,
    fileReadActAsync : fileReadActAsync,
    //
    // linkSoftActSync : linkSoftActSync,
    // linkSoftActAsync : linkSoftActAsync,
    linkHardActSync : linkHardActSync,
    linkHardActAsync : linkHardActAsync

  },

  verbose : 0,

};

_.mapExtend( Self,Proto );
Object.setPrototypeOf( Self, Parent );

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;
_global_.wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
