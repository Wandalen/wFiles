( function _FileProvider_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

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

  require( 'wTesting' );
  //require( '../../../../wTesting/staging/abase/object/Testing.debug.s' );

  require( '../file/Files.ss' );

  // var File = require( 'fs-extra' );
  var crypto = require( 'crypto' );
  // var Path = require( 'path' );

}

//

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

var _ = wTools;


//var testRootDirectory = __dirname + '/../../../tmp.tmp/hard-drive';
// var hardDrive = _.FileProvider.HardDrive();
// var simpleStructure = _.FileProvider.SimpleStructure( { tree : tree } );
// var self.provider = hardDrive;
var Self = {};

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

}

//

var readWriteAsync = function( test )
{
  var self = this;
  test.description = 'async, writeMode : rewrite';

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  var data2 = 'LOREM';

  return self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 0,
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
  .ifNoErrorThen( function( err )
  {

    test.description = 'async, writeMode : append';
    return self.provider.fileWriteAct
    ({
      pathFile : self.makePath( 'test.txt' ),
      data : data2,
      sync : 0,
      writeMode : 'append'
    });

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

  });

}

//

var writeAsyncThrowingError = function( test )
{
  var self = this;

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
  test.description = 'async, try to rewrite dir';


  var data1 = 'data1';
  var con = self.provider.fileWriteAct
  ({
    pathFile : self.makePath( 'dir' ),
    data : data1,
    sync : 0,
  });

  test.shouldThrowError( con );

  return con;
}

//

var fileCopyActSync = function( test )
{
  var self = this;

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
  }
}

//

var fileCopyActAsync = function( test )
{
  var self = this;

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous copy';
  return self.provider.fileCopyAct
  ({
      pathSrc : self.makePath( 'test.txt' ),
      pathDst : self.makePath( 'pathDst.txt' ),
      sync : 0,
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
  .ifNoErrorThen( function( err )
  {
    test.description = 'syncronous rewrite existing file';

    return self.provider.fileCopyAct
    ({
        pathSrc : self.makePath( 'pathDst.txt' ),
        pathDst : self.makePath( 'test.txt' ),
        sync : 0,
    });
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
}

//

var fileCopyActAsyncThrowingError = function( test )
{
  var self = this;

  test.description = 'async, throwing error';
  var con =  self.provider.fileCopyAct
  ({
    pathSrc : self.makePath( 'invalid.txt' ),
    pathDst : self.makePath( 'pathDst.txt' ),
    sync : 0,
  })
  test.shouldThrowError( con );

  test.description = 'async,try rewrite dir';
  var con1 =  self.provider.fileCopyAct
  ({
    pathSrc : self.makePath( 'invalid.txt' ),
    pathDst : self.makePath( 'tmp' ),
    sync : 0,
  })
  test.shouldThrowError( con1 );
  return con;
}

//

var fileRenameActSync = function( test )
{
  var self = this;

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

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous rename';
  return self.provider.fileRenameAct
  ({
    pathSrc : self.makePath( 'pathDst.txt' ),
    pathDst : self.makePath( 'newfile2.txt' ),
    sync : 0
  })
  .ifNoErrorThen( function( err )
  {
    var got = self.provider.fileReadAct
    ({
      pathFile : self.makePath( 'newfile2.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function( err )
  {
    test.description = 'invalid pathSrc path';

    var con = self.provider.fileRenameAct
    ({
      pathSrc : self.makePath( '///bad path///test.txt' ),
      pathDst : self.makePath( 'pathDst.txt' ),
      sync : 0,
    });

    test.shouldThrowError( con );

    return con;
  });
}

//

var fileDeleteActSync = function( test )
{
  var self = this;

  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'dir' ),
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
  }

}

//

var fileDeleteActAsync = function( test )
{
  var self = this;

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

  test.description = 'asyncronous delete';
  return self.provider.fileDeleteAct
  ({
    pathFile : self.makePath( 'pathDst.txt' ),
    sync : 0
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
  .ifNoErrorThen( function( err )
  {
    test.description = 'invalid  path';
    var con = self.provider.fileDeleteAct
    ({
        pathFile : self.makePath( 'somefile.txt' ),
        sync : 0,
    });
    test.shouldThrowError( con );

    test.description = 'not empty dir';
    var con1 = self.provider.fileDeleteAct
    ({
        pathFile : self.makePath( 'dir' ),
        sync : 0,
    });
    test.shouldThrowError( con1 );
    return con;
  });
}

//

var fileStatActSync = function( test )
{
  var self = this;

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
}

//

var fileStatActAsync = function( test )
{
  var self = this;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous file stat';
  return self.provider.fileStatAct
  ({
    pathFile : self.makePath( 'pathDst.txt' ),
    sync : 0
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
  .ifNoErrorThen( function( err )
  {
    test.description = 'invalid path';
    var con =  self.provider.fileStatAct
    ({
        pathFile : self.makePath( '../1.txt' ),
        sync : 0,
    });
    test.shouldThrowError( con );

    // if( self.provider instanceof _.FileProvider.HardDrive )
    // test.shouldThrowError( con );
    // if( self.provider instanceof _.FileProvider.SimpleStructure )
    // con.ifNoErrorThen( function( stats )
    // {
    //   test.identical( stats, null );
    // });

  });

}

//

var directoryMakeActSync = function( test )
{
  var self = this;

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
  }
}

//

var directoryMakeActAsync = function( test )
{
  var self = this;

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


  test.description = 'asyncronous mkdir';
  return self.provider.directoryMakeAct
  ({
    pathFile : self.makePath( 'make_dir' ),
    sync : 0
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
  .ifNoErrorThen( function( err )
  {
    test.description = 'dir already exist';
    var con = self.provider.directoryMakeAct
    ({
        pathFile : self.makePath( 'make_dir' ),
        sync : 0,
    });
    test.shouldThrowError( con );
    return con;
  });
}

//

var fileHashActSync = function( test )
{
  var self = this;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description= 'syncronous filehash';
  var got = self.provider.fileHashAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    sync : 1
  });
  var md5sum = crypto.createHash( 'md5' );
  md5sum.update( data1 );
  var expected = md5sum.digest( 'hex' );
  test.identical( got, expected );

  test.description= 'invalid path';
  var got = self.provider.fileHashAct
  ({
    pathFile : self.makePath( 'invalid.txt' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

}

//

var fileHashActAsync = function( test )
{
  var self = this;

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  self.provider.fileWriteAct
  ({
      pathFile : self.makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description= 'asyncronous filehash';
  return self.provider.fileHashAct
  ({
    pathFile : self.makePath( 'test.txt' ),
    sync : 0
  })
  .ifNoErrorThen( function( hash )
  {
    var md5sum = crypto.createHash( 'md5' );
    md5sum.update( data1 );
    var expected = md5sum.digest( 'hex' );
    test.identical( hash, expected );
  })
  .ifNoErrorThen( function( err )
  {
    test.description= 'invalid path';
    return self.provider.fileHashAct
    ({
      pathFile : self.makePath( 'invalid.txt' ),
      sync : 0
    });
  })
  .thenDo( function( hash )
  {
    test.identical( hash, null );
  });
}

//

var directoryReadActSync = function( test )
{
  var self = this;

  //make test tree
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

  test.description= 'syncronous read';
  var got = self.provider.directoryReadAct
  ({
    pathFile : self.makePath( 'read_dir' ),
    sync : 1
  });
  var expected = [ "1", "2", "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  test.description= 'syncronous, pathFile points to file';
  var got = self.provider.directoryReadAct
  ({
    pathFile : self.makePath( 'read_dir/1.txt' ),
    sync : 1
  });
  var expected = [ '1.txt' ];
  test.identical( got, expected );
}

//

var directoryReadActAsync = function( test )
{
  var self = this;

  test.description= ' async read';
  return self.provider.directoryReadAct
  ({
    pathFile : self.makePath( 'read_dir' ),
    sync : 0
  })
  .ifNoErrorThen( function( result )
  {
    var expected = [ "1", "2", "1.txt" ];
    test.identical( result.sort(), expected.sort() );
  })
  .ifNoErrorThen( function()
  {
    test.description = 'async, pathFile points to file';
    return self.provider.directoryReadAct
    ({
      pathFile : self.makePath( 'read_dir/1.txt' ),
      sync : 0
    });
  })
  .ifNoErrorThen( function( result )
  {
    var expected = [ '1.txt' ];
    test.identical( result, expected );
  });

}

//

var fileWriteActSync = function( test )
{
  var self = this;

  try
  {
    self.provider.directoryMakeAct
    ({
      pathFile : self.makePath( 'write_test' ),
      sync : 1
    })
  }
  catch ( err ) { }

  var data = "LOREM"
  test.description='rewrite, file not exist ';
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

  test.description='rewrite existing file ';
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
    test.description='try write to non existing folder  ';
    test.shouldThrowError( function()
    {
      self.provider.fileWriteAct
      ({
        pathFile : self.makePath( 'unknown/dst.txt' ),
        data : data,
        sync : 1
      });
    });

    test.description='try to rewrite folder  ';
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
}

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
    fileWriteActSync : fileWriteActSync

  },

  verbose : 0,

};

_.mapExtend( Self,Proto );
Object.setPrototypeOf( Self, wTools.Testing );

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;
_global_.wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
