( function _FileProvider_test_ss_( ) {

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

  var File = require( 'fs-extra' );
  var crypto = require( 'crypto' );
  // var Path = require( 'path' );

}

//

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

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
 },
 "test_dir" :
 {
   'test3.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
 }
}

var testRootDirectory = __dirname + '/../../../tmp.tmp/hard-drive';
var hardDrive = _.FileProvider.HardDrive();
var simpleStructure = _.FileProvider.SimpleStructure( { tree : tree } );
var provider = hardDrive;
var Self = {};

//

var testDelaySample = function testDelaySample( test )
{

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

var makePath  = function ( pathFile )
{
  if( provider === hardDrive )
  {
    return _.pathJoin( testRootDirectory,  pathFile );
  }
  if( provider === simpleStructure )
  {
    return  pathFile;
  }
}


//

var readWriteSync = function ( test )
{
  test.description = 'syncronous, writeMode : rewrite';
  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });
  var got = provider.fileReadAct
  ({
      pathFile : makePath( 'test.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  test.description = 'syncronous, writeMode : append';
  var data2 = 'LOREM';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data2,
      sync : 1,
      writeMode : 'append'
  });
  var got = provider.fileReadAct
  ({
      pathFile : makePath( 'test.txt' ),
      sync : 1
  });
  var expected = data1 + data2;
  test.identical( got, expected );

  test.description = 'syncronous, writeMode : prepend';
  var data2 = 'LOREM';
  provider.fileWriteAct
  ({
    pathFile : makePath( 'test.txt' ),
    data : data2,
    sync : 1,
    writeMode : 'prepend'
  });
  var got = provider.fileReadAct
  ({
    pathFile : makePath( 'test.txt' ),
    sync : 1
  });
  var expected = data2 + data1 + data2;
  test.identical( got, expected );

}

//

var readWriteAsync = function ( test )
{
  test.description = 'async, writeMode : rewrite';

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  var data2 = 'LOREM';

  return provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 0,
  })
  .ifNoErrorThen( function( err )
  {
    var got = provider.fileReadAct
    ({
      pathFile : makePath( 'test.txt' ),
      sync : 1,
    });

    test.identical( got, data1 );

  })
  .ifNoErrorThen( function( err )
  {

    test.description = 'async, writeMode : append';
    return provider.fileWriteAct
    ({
      pathFile : makePath( 'test.txt' ),
      data : data2,
      sync : 0,
      writeMode : 'append'
    });

  })
  .ifNoErrorThen( function( err )
  {

    var got = provider.fileReadAct
    ({
      pathFile : makePath( 'test.txt' ),
      sync : 1,
    });

    var expected = data1 + data2;
    test.identical( got, expected );

  });

}

//

var writeAsyncThrowingError = function ( test )
{
  if( provider === hardDrive )
  {
    File.removeSync( makePath( 'test_dir2' ) );
  }
  try
  {
    provider.directoryMakeAct
    ({
      pathFile : makePath( 'dir' ),
      sync : 1
    })
  }
  catch ( err ) { }
  test.description = 'async, try to rewrite dir';


  var data1 = 'data1';
  var con = provider.fileWriteAct
  ({
    pathFile : makePath( 'dir' ),
    data : data1,
    sync : 0,
  });

  test.shouldThrowError( con );

  return con;
}

//

var fileCopyActSync = function ( test )
{
  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous copy';
  provider.fileCopyAct
  ({
      pathSrc : makePath( 'test.txt' ),
      pathDst : makePath( 'pathDst.txt' ),
      sync : 1,
  });
  var got = provider.fileReadAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  test.description = 'syncronous rewrite existing file';
  provider.fileCopyAct
  ({
      pathSrc : makePath( 'pathDst.txt' ),
      pathDst : makePath( 'test.txt' ),
      sync : 1,
  });
  var got = provider.fileReadAct
  ({
      pathFile : makePath( 'test.txt' ),
      sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid pathSrc path';
    test.shouldThrowError( function()
    {
      provider.fileCopyAct
      ({
          pathSrc : makePath( 'invalid.txt' ),
          pathDst : makePath( 'pathDst.txt' ),
          sync : 1,
      });
    });

    test.description = 'try to rewrite dir';
    test.shouldThrowError( function()
    {
      provider.fileCopyAct
      ({
          pathSrc : makePath( 'invalid.txt' ),
          pathDst : makePath( 'tmp' ),
          sync : 1,
      });
    });
  }
}

//

var fileCopyActAsync = function( test )
{
  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous copy';
  return provider.fileCopyAct
  ({
      pathSrc : makePath( 'test.txt' ),
      pathDst : makePath( 'pathDst.txt' ),
      sync : 0,
  })
  .ifNoErrorThen( function( err )
  {
    var got = provider.fileReadAct
    ({
      pathFile : makePath( 'pathDst.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function( err )
  {
    test.description = 'syncronous rewrite existing file';

    return provider.fileCopyAct
    ({
        pathSrc : makePath( 'pathDst.txt' ),
        pathDst : makePath( 'test.txt' ),
        sync : 0,
    });
  })
  .ifNoErrorThen( function ( err )
  {
    var got = provider.fileReadAct
    ({
      pathFile : makePath( 'test.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  });
}

//

var fileCopyActAsyncThrowingError = function( test )
{
  test.description = 'async, throwing error';
  var con =  provider.fileCopyAct
  ({
    pathSrc : makePath( 'invalid.txt' ),
    pathDst : makePath( 'pathDst.txt' ),
    sync : 0,
  })
  test.shouldThrowError( con );

  test.description = 'async,try rewrite dir';
  var con1 =  provider.fileCopyAct
  ({
    pathSrc : makePath( 'invalid.txt' ),
    pathDst : makePath( 'tmp' ),
    sync : 0,
  })
  test.shouldThrowError( con1 );
  return con;
}

//

var fileRenameActSync = function ( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous rename';
  provider.fileRenameAct
  ({
    pathSrc : makePath( 'pathDst.txt' ),
    pathDst : makePath( 'newfile.txt' ),
    sync : 1
  });
  var got = provider.fileReadAct
  ({
    pathFile : makePath( 'newfile.txt' ),
    sync : 1
  });
  var expected = data1;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid pathSrc path';
    test.shouldThrowError( function()
    {
      provider.fileRenameAct
      ({
          pathSrc : makePath( 'invalid.txt' ),
          pathDst : makePath( 'newfile.txt' ),
          sync : 1,
      });
    });
  }

}


//

var fileRenameActAsync = function ( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous rename';
  return provider.fileRenameAct
  ({
    pathSrc : makePath( 'pathDst.txt' ),
    pathDst : makePath( 'newfile2.txt' ),
    sync : 0
  })
  .ifNoErrorThen( function ( err )
  {
    var got = provider.fileReadAct
    ({
      pathFile : makePath( 'newfile2.txt' ),
      sync : 1
    });
    var expected = data1;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ( err )
  {
    test.description = 'invalid pathSrc path';

    var con = provider.fileRenameAct
    ({
      pathSrc : makePath( '///bad path///test.txt' ),
      pathDst : makePath( 'pathDst.txt' ),
      sync : 0,
    });

    test.shouldThrowError( con );

    return con;
  });
}

//

var fileDeleteActSync = function ( test )
{
  try
  {
    provider.directoryMakeAct
    ({
      pathFile : makePath( 'dir' ),
      sync : 1
    });
  } catch ( err ){ }

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'dir/pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous delete';
  provider.fileDeleteAct
  ({
    pathFile : makePath( 'pathDst.txt' ),
    sync : 1
  });
  var got = provider.fileStatAct
  ({
    pathFile : makePath( 'pathDst.txt' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

  if( Config.debug )
  {
    test.description = 'invalid path';
    test.shouldThrowError( function()
    {
      provider.fileDeleteAct
      ({
          pathFile : makePath( '///bad path///test.txt' ),
          sync : 1,
      });
    });

    test.description = 'not empty dir';
    test.shouldThrowError( function()
    {
      provider.fileDeleteAct
      ({
          pathFile : makePath( 'dir' ),
          sync : 1,
      });
    });
  }

}

//

var fileDeleteActAsync = function ( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'dir/pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous delete';
  return provider.fileDeleteAct
  ({
    pathFile : makePath( 'pathDst.txt' ),
    sync : 0
  })
  .ifNoErrorThen( function ( err )
  {
    var got = provider.fileStatAct
    ({
      pathFile : makePath( 'pathDst.txt' ),
      sync : 1
    });
    var expected = null;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function ( err )
  {
    test.description = 'invalid  path';
    var con = provider.fileDeleteAct
    ({
        pathFile : makePath( 'somefile.txt' ),
        sync : 0,
    });
    test.shouldThrowError( con );

    test.description = 'not empty dir';
    var con1 = provider.fileDeleteAct
    ({
        pathFile : makePath( 'dir' ),
        sync : 0,
    });
    test.shouldThrowError( con1 );
    return con;
  });
}

//

var fileStatActSync = function ( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'syncronous file stat';
  var got = provider.fileStatAct
  ({
    pathFile : makePath( 'pathDst.txt' ),
    sync : 1
  });
  var expected;
  if( provider === hardDrive )
  {
    var stat =  File.statSync( makePath( 'pathDst.txt' ) );
    expected = stat.size;
  }
  else if( provider === simpleStructure )
  {
    expected = null;
  }
  test.identical( got.size, expected );

  test.description = 'invalid path';
  var got = provider.fileStatAct
  ({
    pathFile : makePath( '///bad path///test.txt' ),
    sync : 1,
  });
  var expected = null;
  test.identical( got, expected );
}

//

var fileStatActAsync = function ( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'pathDst.txt' ),
      data : data1,
      sync : 1,
  });

  test.description = 'asyncronous file stat';
  return provider.fileStatAct
  ({
    pathFile : makePath( 'pathDst.txt' ),
    sync : 0
  })
  .ifNoErrorThen( function ( stats )
  {
    var expected;
    if( provider === hardDrive )
    {
      var stat = File.statSync( makePath( 'pathDst.txt' ) );
      expected = stat.size;
    }
    else if( provider === simpleStructure )
    {
      expected = null;
    }
    test.identical( stats.size, expected );
  })
  .ifNoErrorThen( function ( err )
  {
    test.description = 'invalid path';
    var con =  provider.fileStatAct
    ({
        pathFile : makePath( '../1.txt' ),
        sync : 0,
    });
    if( provider === hardDrive )
    test.shouldThrowError( con );
    if( provider === simpleStructure )
    con.ifNoErrorThen( function ( stats )
    {
      test.identical( stats, null );
    });

  });


}

//

var directoryMakeActSync = function ( test )
{
  if( provider === hardDrive )
  {
    File.removeSync( makePath( 'test_dir2' ) );
  }

  test.description = 'syncronous mkdir';
  provider.directoryMakeAct
  ({
    pathFile : makePath( 'test_dir2' ),
    sync : 1
  });
  var stat = provider.fileStatAct
  ({
    pathFile : makePath( 'test_dir2' ),
    sync : 1
  });
  if( provider === hardDrive )
  test.identical( stat.isDirectory(), true );
  else if( provider === simpleStructure  )
  test.identical( stat.size, null );

  if( Config.debug )
  {
    test.description = 'dir already exist';
    test.shouldThrowError( function()
    {
      provider.directoryMakeAct
      ({
          pathFile : makePath( 'test_dir2' ),
          sync : 1,
      });
    });
  }
}

//

var directoryMakeActAsync = function ( test )
{
  if( provider === hardDrive )
  {
    File.removeSync( makePath( 'test_dir2' ) );
  }

  try
  {
    provider.fileDeleteAct
    ({
      pathFile : makePath( 'test_dir2' ),
      sync : 1
    })
  }
  catch ( err ){}


  test.description = 'asyncronous mkdir';
  return provider.directoryMakeAct
  ({
    pathFile : makePath( 'test_dir2' ),
    sync : 0
  })
  .ifNoErrorThen( function ( err )
  {
    var stat = provider.fileStatAct
    ({
      pathFile : makePath( 'test_dir2' ),
      sync : 1
    });
    if( provider === hardDrive )
    test.identical( stat.isDirectory(), true );
    else if( provider === simpleStructure  )
    test.identical( stat.size, null );
  })
  .ifNoErrorThen( function ( err )
  {
    test.description = 'dir already exist';
    var con = provider.directoryMakeAct
    ({
        pathFile : makePath( 'test_dir2' ),
        sync : 0,
    });
    test.shouldThrowError( con );
    return con;
  });
}

//

var fileHashActSync = function( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description= 'syncronous filehash';
  var got = provider.fileHashAct
  ({
    pathFile : makePath( 'test.txt' ),
    sync : 1
  });
  var md5sum = crypto.createHash( 'md5' );
  md5sum.update( data1 );
  var expected = md5sum.digest( 'hex' );
  test.identical( got, expected );

  test.description= 'invalid path';
  var got = provider.fileHashAct
  ({
    pathFile : makePath( 'invalid.txt' ),
    sync : 1
  });
  var expected = null;
  test.identical( got, expected );

}

//

var fileHashActAsync = function( test )
{
  var data1 = 'Excepteur sint occaecat cupidatat non proident';
  provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 1,
  });

  test.description= 'asyncronous filehash';
  return provider.fileHashAct
  ({
    pathFile : makePath( 'test.txt' ),
    sync : 0
  })
  .ifNoErrorThen( function ( hash )
  {
    var md5sum = crypto.createHash( 'md5' );
    md5sum.update( data1 );
    var expected = md5sum.digest( 'hex' );
    test.identical( hash, expected );
  })
  .ifNoErrorThen( function ( err )
  {
    test.description= 'invalid path';
    return provider.fileHashAct
    ({
      pathFile : makePath( 'invalid.txt' ),
      sync : 0
    });
  })
  .thenDo( function ( hash )
  {
    test.identical( hash, null );
  });
}

//

var directoryReadActSync = function ( test )
{
  test.description= 'syncronous read';
  var got = provider.directoryReadAct
  ({
    pathFile : makePath( './' ),
    sync : 1
  });
  if( provider === hardDrive )
  var expected = File.readdirSync( makePath( './' ) );
  if( provider === simpleStructure )
  var expected = [ "dir", "pathDst.txt", "folder.abc", "newfile.txt", "newfile2.txt", "test.txt", "test_dir", "test_dir2" ];
  test.identical( got.sort(), expected.sort() );

  test.description= 'syncronous, pathFile points to file';
  var got = provider.directoryReadAct
  ({
    pathFile : makePath( 'dir/pathDst.txt' ),
    sync : 1
  });
  var expected = [ 'pathDst.txt' ];
  test.identical( got, expected );
}

//

var directoryReadActAsync = function( test )
{
  test.description= ' async read';
  return provider.directoryReadAct
  ({
    pathFile : makePath( './' ),
    sync : 0
  })
  .ifNoErrorThen( function( result )
  {
    if( provider === hardDrive )
    var expected = File.readdirSync( makePath( './' ) );
    if( provider === simpleStructure )
    var expected = [ "dir", "pathDst.txt", "folder.abc", "newfile.txt", "newfile2.txt", "test.txt", "test_dir", "test_dir2" ];
    test.identical( result.sort(), expected.sort() );
  })
  .ifNoErrorThen(function ( err )
  {
    test.description= 'async, pathFile points to file';
    return provider.directoryReadAct
    ({
      pathFile : makePath( 'dir/pathDst.txt' ),
      sync : 1
    });
  })
  .ifNoErrorThen( function( result )
  {
    var expected = [ 'pathDst.txt' ];
    test.identical( result, expected );
  });
}


// --
// proto
// --

var Proto =
{

  name : 'FileProvider',

  tests :
  {

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
    // testDelaySample : testDelaySample,

  },

  verbose : 0,

};

_.mapExtend( Self,Proto );
wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.testing.test( Self );

} )( );
