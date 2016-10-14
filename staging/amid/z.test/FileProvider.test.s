( function _FileProvider_test_ss_( ) {

'use strict';

if( typeof module !== undefined )
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

  //require( 'wTesting' );
  require( '../../../../wTesting/staging/abase/object/Testing.debug.s' );

  require( '../file/Files.ss' );

  // var File = require( 'fs-extra' );
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
 }
}

var testRootDirectory = __dirname + '/../../../tmp.tmp/hard-drive';
var HardDrive = _.FileProvider.HardDrive();
var SimpleStructure = _.FileProvider.SimpleStructure( { tree : tree } );
var provider = HardDrive;
var Self = {};

//

// function createTestsDirectory( path, rmIfExists )
// {
//   rmIfExists && File.existsSync( path ) && File.removeSync( './tmp/' );
//   return File.mkdirsSync( path );
// }
//
// //
//
// function createInTD( path )
// {
//   return createTestsDirectory( Path.join( testRootDirectory, path ) );
// }
//
// //
//
// function createTestFile( path, data, decoding )
// {
//   var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
//   File.createFileSync( Path.join( testRootDirectory, path ) );
//   dataToWrite && File.writeFileSync( Path.join( testRootDirectory, path ), dataToWrite );
// }
//
//
// function getLstat( path )
// {
//   var stats;
//   try
//   {
//     stats = File.lstatSync( path );
//   }
//   catch ( error )
//   {
//   }
//   return stats;
// }

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
  if( provider === HardDrive )
  {
    return _.pathJoin( testRootDirectory,  pathFile );
  }
  if( provider === SimpleStructure )
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

  // test.description = 'syncronous, writeMode : prepend';
  // var data2 = 'LOREM';
  // provider.fileWriteAct(
  //   {
  //     pathFile : makePath( 'test.txt' ),
  //     data : data2,
  //     sync : 1,
  //     writeMode : 'prepend'
  //   } );
  // var got = provider.fileReadAct(
  //   {
  //     pathFile : makePath( 'test.txt' ),
  //     sync : 1
  //   } );
  // var expected = data2 + data1 + data2;
  // test.identical( got, expected );

}

//

var readWriteAsync = function ( test )
{
  test.description = 'async, writeMode : rewrite';

  var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  var con = provider.fileWriteAct
  ({
      pathFile : makePath( 'test.txt' ),
      data : data1,
      sync : 0,
  });

  con.got( function( err )
  {
    if( err )
    throw err;

    var got = provider.fileReadAct
    ({
      pathFile : makePath( 'test.txt' ),
      sync : 1,
    });

    test.identical( got, data1 );

    // con.got( function ( err,data )
    // {
    //   if( err )
    //   throw err;
    //   var got = data;
    //   var expected = data1;
    //   test.identical( got, expected );
    // });

  });

  test.description = 'async, writeMode : append';
  var data2 = 'LOREM';
  var con = provider.fileWriteAct
  ({
    pathFile : makePath( 'test.txt' ),
    data : data2,
    sync : 0,
    writeMode : 'append'
  });

  con.thenDo( function( err )
  {

    if( err )
    throw err;

    var con = provider.fileReadAct
    ({
      pathFile : makePath( 'test.txt' ),
      sync : 0,
    });

    return con.thenDo( function ( err,data )
    {
      if( err )
      throw err;
      var got = data;
      var expected = data1 + data2;
      test.identical( got, expected );
    });

  });

  return con;
}

//

var writeAsyncThrowingError = function ( test )
{
  test.description = 'async, throwing error';

  var data1 = 'data1';
  var con = provider.fileWriteAct
  ({
    pathFile : makePath( '///bad path///test.txt' ),
    data : data1,
    sync : 0,
  });

  test.shouldThrowError( con );

  return con;
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
    // testDelaySample : testDelaySample,

  },

  verbose : 0,

};

_.mapExtend( Self,Proto );
wTests[ Self.name ] = Self;

//createTestsDirectory( testRootDirectory, 1 );

if( typeof module !== 'undefined' && !module.parent )
_.testing.test( Self );

} )( );
