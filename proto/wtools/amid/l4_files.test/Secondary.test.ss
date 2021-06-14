( function _Secondary_test_ss_()
{

'use strict';

/* xxx : aaa : use sleep instead of waitSync. remove waitSync */ /* Dmytro : replaced */
// var waitSync;

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );
  if( !_global_.wTools.FileProvider )
  require( '../l4_files/entry/Files.s' );
  _.include( 'wTesting' );
  // waitSync = require( 'wait-sync' );
}

//

const _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  let context = this;

  context.suiteTempPath = context.provider.path.tempOpen( context.provider.path.join( __dirname, '../..'  ), 'FilesEtc' );
}

//

function onSuiteEnd()
{
  let path = this.provider.path;
  _.assert( _.strHas( this.suiteTempPath, '.tmp' ) );
  path.tempClose( this.suiteTempPath );
  this.provider.finit();
}

//

function createTestFile( path, data, encoding )
{
  let context = this;
  let provider = context.provider;

  provider.fileWrite
  ({
    filePath : _.path.join( context.suiteTempPath, path ),
    data,
    encoding
  });
}

//

function createTestSymLink( /* path, target, type, data */ )
{
  let path = arguments[ 0 ];
  let target = arguments[ 1 ];
  let type = arguments[ 2 ];
  let data = arguments[ 3 ];

  let context = this;
  let provider = context.provider;

  var origin,
    typeOrigin;

  // if( target === void 0 )
  if( target === undefined )
  {
    origin = Path.parse( path )
    origin.name = origin.name + '_orig';
    origin.base = origin.name + origin.ext;
    origin = Path.format( origin );
  }
  else
  {
    origin = target;
  }

  if( 'sf' === type )
  {
    typeOrigin = 'file';
    data = data || 'test origin';
    context.createTestFile( origin, data );
  }
  else if( 'sd' === type )
  {
    typeOrigin = 'dir';
    provider.dirMake( provider.path.join( context.suiteTempPath, origin ) );
  }
  else throw new Error( 'unexpected type' );

  path = _.path.join( context.suiteTempPath, path );
  origin = _.path.resolve( _.path.join( context.suiteTempPath, origin ) );

  // File.existsSync( path ) && File.removeSync( path );
  if( provider.statResolvedRead( path ) )
  provider.fileDelete( path );
  // File.symlinkSync( origin, path, typeOrigin );
  provider.softLink( path, origin );
}

//

function createTestHardLink( path, target, data )
{
  let context = this;
  let provider = context.provider;
  var origin;

  // if( target === void 0 )
  if( target === undefined )
  {
    origin = Path.parse( path );
    origin.name = origin.name + '_orig';
    origin.base = origin.name + origin.ext;
    origin = Path.format( origin );
  }
  else
  {
    origin = target;
  }

  data = data || 'test origin';
  context.createTestFile( origin, data );

  path = _.path.join( context.suiteTempPath, path );
  origin = _.path.resolve( _.path.join( context.suiteTempPath, origin ) );

  // File.existsSync( path ) && File.removeSync( path );
  if( provider.statResolvedRead( path ) )
  provider.fileDelete( path );
  // File.linkSync( origin, path );
  provider.hardLink( path, origin )
}

//

function createTestResources( cases, dir )
{
  let context = this;
  let provider = context.provider;

  if( !Array.isArray( cases ) ) cases = [ cases ];

  var l = cases.length;
  var testCheck, paths;

  while( l-- )
  {
    testCheck = cases[ l ];
    switch( testCheck.type )
    {
    case( 'f' ) :
      paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
      paths.forEach( ( path, i ) =>
      {
        path = dir ? _.path.join( dir, path ) : path;
        // if( testCheck.createResource !== void 0 )
        if( testCheck.createResource !== undefined )
        {
          let res = ( Array.isArray( testCheck.createResource ) && testCheck.createResource[ i ] ) || testCheck.createResource;
          context.createTestFile( path, res );
        }
        else
        context.createTestFile( path );
      });
      break;

    case( 'd' ) :
      paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
      paths.forEach( ( path, i ) =>
      {
        path = dir ? _.path.join( dir, path ) : path;
        provider.dirMake( provider.path.join( context.suiteTempPath, path ) )
        if( testCheck.folderContent )
        {
          var res = Array.isArray( testCheck.folderContent ) ? testCheck.folderContent : [ testCheck.folderContent ];
          context.createTestResources( res, path );
        }
      });
      break;

    case( 'sd' ) :
    case( 'sf' ) :
      var path, target;
      if( Array.isArray( testCheck.path ) )
      {
        path = dir ? _.path.join( dir, testCheck.path[ 0 ] ) : testCheck.path[ 0 ];
        target = dir ? _.path.join( dir, testCheck.path[ 1 ] ) : testCheck.path[ 1 ];
      }
      else
      {
        path = dir ? _.path.join( dir, testCheck.path ) : testCheck.path;
        target = dir ? _.path.join( dir, testCheck.linkTarget ) : testCheck.linkTarget;
      }
      context.createTestSymLink( path, target, testCheck.type, testCheck.createResource );
      break;
    case( 'hf' ) :
      var path, target;
      if( Array.isArray( testCheck.path ) )
      {
        path = dir ? _.path.join( dir, testCheck.path[ 0 ] ) : testCheck.path[ 0 ];
        target = dir ? _.path.join( dir, testCheck.path[ 1 ] ) : testCheck.path[ 1 ];
      }
      else
      {
        path = dir ? _.path.join( dir, testCheck.path ) : testCheck.path;
        target = dir ? _.path.join( dir, testCheck.linkTarget ) : testCheck.linkTarget;
      }
      context.createTestHardLink( path, target, testCheck.createResource );
      break;
    default :
      break;
    }
  }

  return null;
}

//

function mergePath( path )
{
  let context = this;
  let provider = context.provider;
  return provider.path.join( context.suiteTempPath, path );
}

// --
// test
// --

// function isDir( test )
// {
//   // regular tests
//   var testChecks =
//     [
//       {
//         name : 'simple directory',
//         path : 'tmp.tmp/sample/', // dir
//         type : 'd', // type for create test resource
//         expected : true // test expected
//       },
//       {
//         name : 'simple hidden directory',
//         path : 'tmp.tmp/.hidden', // hidden dir,
//         type : 'd',
//         expected : true
//       },
//       {
//         name : 'file',
//         path : 'tmp.tmp/text.txt',
//         type : 'f',
//         expected : false
//       },
//       {
//         name : 'symlink to directory',
//         path : 'tmp.tmp/sample2',
//         type : 'sd',
//         expected : false
//       },
//       {
//         name : 'symlink to file',
//         path : 'tmp.tmp/text2.txt',
//         type : 'sf',
//         expected : false
//       },
//       {
//         name : 'not existing path',
//         path : 'tmp.tmp/notexisting.txt',
//         type : 'na',
//         expected : false
//       }
//     ];

//   context.createTestResources( testChecks );

//   for( let testCheck of testChecks )
//   {
//     test.description = testCheck.name;
//     let got = !! provider.isDir( _.path.join( context.suiteTempPath, testCheck.path ) );
//     test.identical( got , testCheck.expected );
//   }

// };

//

function _fileOptionsGet( test )
{

  let context = this;
  let provider = context.provider;

  var defaultContextObj =
  {
    defaults :
    {
      filePath : null,
      sync : null
    }
  };
  var  options1 =
  {
    sync : 0
  };
  var wrongOptions =
  {
    filePath : 'path',
    sync : 0,
    extraOptions : 1
  };
  var path1 = '';
  var path2 = '/sample/tmp.tmp';
  var path3 = '/ample/temp.txt';
  var path4 = { filePath : 'some/abc', sync : 1 };
  var expected2 =
  {
    filePath : '/sample/tmp.tmp',
    sync : 1
  };
  var expected3 =
  {
    filePath : '/ample/temp.txt',
    sync : 0
  };
  var expected4 = path4;

  test.description = 'non empty path';
  var got = provider._fileOptionsGet.call( defaultContextObj, path2 );
  test.identical( got, expected2 );

  test.description = 'non empty path, call with options';
  var got = provider._fileOptionsGet.call( defaultContextObj, path3, options1 );
  test.identical( got, expected3 );

  test.description = 'path is object';
  var got = provider._fileOptionsGet.call( defaultContextObj, path4, options1 );
  test.identical( got, expected4 );

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      provider._fileOptionsGet.call( defaultContextObj );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      provider._fileOptionsGet.call( defaultContextObj, path2, options1, {} );
    } );

    test.description = 'empty path';
    test.shouldThrowErrorSync( function( )
    {
      provider._fileOptionsGet.call( defaultContextObj, path1 );
    } );

    test.description = 'extra options ';
    test.shouldThrowErrorSync( function( )
    {
      provider._fileOptionsGet.call( defaultContextObj, path3, wrongOptions );
    } );
  }
}

//

/*
qqq : rewrite test routine for filesNewer, filesOlder. coverage should be Good
*/

function filesNewer( test )
{

  let context = this;
  let provider = context.provider;

  /* files creation */

  var file1 = 'tmp.tmp/filesNewer/test1';
  var file2 = 'tmp.tmp/filesNewer/test2';
  var file3 = 'tmp.tmp/filesNewer/test3';
  var file4 = 'tmp.tmp/filesNewer/test4';

  var delay = provider.systemBitrateTimeGet() / 10;
  // var delay = provider.systemBitrateTimeGet() / 1000;

  context.createTestFile( file1, 'test1' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file2, 'test2' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file3, 'test3' );

  file1 = context.mergePath( file1 );
  file2 = context.mergePath( file2 );
  file3 = context.mergePath( file3 );

  file1 = provider.path.nativize( file1 );
  file2 = provider.path.nativize( file2 );
  file3 = provider.path.nativize( file3 );

  /* tests */

  test.case = 'two files created at different time';
  var got = _.files.filesNewer( file1, file2 );
  test.identical( got, file2 );

  test.case = 'one files modified after creation';
  provider.timeWrite( file1, _.time.now() / 1000, _.time.now() / 1000 );
  var got = _.files.filesNewer( file2, file1 );
  test.identical( got, file1 );

  test.case = 'two files modified at the same time';
  let timeSet = _.time.now() / 1000;
  provider.timeWrite( file1, timeSet, timeSet );
  provider.timeWrite( file2, timeSet, timeSet );
  var got = _.files.filesNewer( file1, file2 );
  test.identical( got, null );

  var con = _.time.out( 50 );
  con.finally( () =>
  {
    context.createTestFile( file4, 'test4' );
    file4 = context.mergePath( file4 );
    file4 = provider.path.nativize( file4 );
    test.case = 'two files created at different time, async test';
    var got = _.files.filesNewer( file3, file4 );
    test.identical( got, file4 );
    return null;
  });

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( () => _.files.filesNewer() );

    test.case = 'extra arguments';
    var path = 'tmp.tmp/s.txt';
    test.shouldThrowErrorSync( () => _.files.filesNewer( path, path, path ) );

    test.case = 'one argument is missed';
    var path = 'tmp.tmp'
    test.shouldThrowErrorSync( () => _.files.filesNewer( path, path + '/file' ) );
    test.shouldThrowErrorSync( () => _.files.filesNewer( path + '/file', path ) );

    test.case = 'type of arguments is not file.Stat or string';
    test.shouldThrowErrorSync( () => _.files.filesNewer( null, '/tmp.tmp/s.txt' ) );
    test.shouldThrowErrorSync( () => _.files.filesNewer( 'tmp.tmp', [ 'tmp.tmp' ] ) );
    test.shouldThrowErrorSync( () => _.files.filesNewer( [ file1 ], [ file2 ] ) );
  }

  return con;
}

filesNewer.timeOut = 20000;

//

function filesOlder( test )
{
  let context = this;
  let provider = context.provider;

  /* files creation */

  var file1 = 'tmp.tmp/filesOlder/test1';
  var file2 = 'tmp.tmp/filesOlder/test2';
  var file3 = 'tmp.tmp/filesOlder/test3';
  var file4 = 'tmp.tmp/filesOlder/test4';

  var delay = provider.systemBitrateTimeGet() / 10;
  // var delay = provider.systemBitrateTimeGet() / 1000;

  context.createTestFile( file1, 'test1' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file2, 'test2' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file3, 'test3' );

  file1 = context.mergePath( file1 );
  file2 = context.mergePath( file2 );
  file3 = context.mergePath( file3 );

  file1 = provider.path.nativize( file1 );
  file2 = provider.path.nativize( file2 );
  file3 = provider.path.nativize( file3 );

  /* tests */

  test.case = 'two files created at different time';
  var got = _.files.filesOlder( file1, file2 );
  test.identical( got, file1 );

  test.case = 'one files modified after creation';
  provider.timeWrite( file1, _.time.now() / 1000, _.time.now() / 1000 );
  var got = _.files.filesOlder( file2, file1 );
  test.identical( got, file2 );

  test.case = 'two files modified at the same time';
  let timeSet = _.time.now() / 1000;
  provider.timeWrite( file1, timeSet, timeSet );
  provider.timeWrite( file2, timeSet, timeSet );
  var got = _.files.filesOlder( file1, file2 );
  test.identical( got, null );

  var con = _.time.out( 50 );
  con.finally( () =>
  {
    context.createTestFile( file4, 'test4' );
    file4 = context.mergePath( file4 );
    file4 = provider.path.nativize( file4 );
    test.case = 'two files created at different time, async test';
    var got = _.files.filesOlder( file3, file4 );
    test.identical( got, file3 );
    return null;
  });

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( () => _.files.filesOlder() );

    test.case = 'extra arguments';
    var path = 'tmp.tmp/s.txt';
    test.shouldThrowErrorSync( () => _.files.filesOlder( path, path, path ) );

    test.case = 'one argument is missed';
    var path = 'tmp.tmp'
    test.shouldThrowErrorSync( () => _.files.filesOlder( path, path + '/file' ) );
    test.shouldThrowErrorSync( () => _.files.filesOlder( path + '/file', path ) );

    test.case = 'type of arguments is not file.Stat or string';
    test.shouldThrowErrorSync( () => _.files.filesOlder( null, '/tmp.tmp/s.txt' ) );
    test.shouldThrowErrorSync( () => _.files.filesOlder( 'tmp.tmp', [ 'tmp.tmp' ] ) );
    test.shouldThrowErrorSync( () => _.files.filesOlder( [ file1 ], [ file2 ] ) );
  }

  return con;
}

filesOlder.timeOut = 20000;

//

function filesSpectre( test )
{
  let context = this;
  let provider = context.provider;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  var textData2 = ' Aenean non feugiat mauris';

  var testChecks =
  [

    {
      name : 'file with empty content',
      path : 'tmp.tmp/filesSpectre/sample.txt',
      type : 'f',
      createResource : '',
      expected :
      {
        length : 0
      }
    },
    {
      name : 'text file 1',
      path : 'tmp.tmp/filesSpectre/some.txt',
      type : 'f',
      createResource : textData1,
      expected :
      {
        'L' : 1,
        'o' : 4,
        'r' : 3,
        'e' : 5,
        'm' : 3,
        ' ' : 7,
        'i' : 6,
        'p' : 2,
        's' : 4,
        'u' : 2,
        'd' : 2,
        'l' : 2,
        't' : 5,
        'a' : 2,
        ',' : 1,
        'c' : 3,
        'n' : 2,
        'g' : 1,
        '.' : 1,
        'length' : 56
      }
    },
    {
      name : 'text file 2',
      path : 'tmp.tmp/filesSpectre/text1.txt',
      type : 'f',
      createResource : textData2,
      expected :
      {
        ' ' : 4,
        'A' : 1,
        'e' : 3,
        'n' : 4,
        'a' : 3,
        'o' : 1,
        'f' : 1,
        'u' : 2,
        'g' : 1,
        'i' : 2,
        't' : 1,
        'm' : 1,
        'r' : 1,
        's' : 1,
        'length' : 26
      }
    }
  ];

  context.createTestResources( testChecks )

  // regular tests
  for( let testCheck of testChecks )
  {
    // join several test aspects together

    let path = _.path.resolve( context.mergePath( testCheck.path ) );
    let got;

    test.description = testCheck.name;

    try
    {
      got = _.files.filesSpectre( path );
    }
    catch( err )
    {
      _.errLogOnce( err );
    }

    var expected = testCheck.expected;

    if( _.objectLike( expected ) )
    {
      var result = new U32x( 257 );
      result[ 256 ] = expected.length;

      delete expected.length;

      for( var k in expected )
      {
        result[ k.charCodeAt() ] = expected[ k ];
      }

      expected = result;
    }

    test.identical( got, expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.files.filesSpectre( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.files.filesSpectre( 'tmp.tmp/filesSame/text1.txt', 'tmp.tmp/filesSame/text2.txt' );
    } );
  }
};

//

// function filesSimilarity( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] ),
//
//     testChecks = [
//
//       {
//         name : 'two different files with empty content',
//         path : [ 'tmp.tmp/filesSimilarity/empty1.txt', 'tmp.tmp/filesSimilarity/empty2.txt' ],
//         type : 'f',
//         createResource : '',
//         expected : 1
//       },
//       {
//         name : 'same text file',
//         path : [ 'tmp.tmp/filesSimilarity/same_text.txt', 'tmp.tmp/filesSimilarity/same_text.txt' ],
//         type : 'f',
//         createResource : textData1,
//         expected : 1
//       },
//       {
//         name : 'files with identical text content',
//         path : [ 'tmp.tmp/filesSimilarity/identical_text1.txt', 'tmp.tmp/filesSimilarity/identical_text2.txt' ],
//         type : 'f',
//         createResource : textData1,
//         expected : 1
//       },
//       {
//         name : 'files with identical binary content',
//         path : [ 'tmp.tmp/filesSimilarity/identical2', 'tmp.tmp/filesSimilarity/identical2.txt' ],
//         type : 'f',
//         createResource : bufferData1,
//         expected : 1
//       },
//       {
//         name : 'files with identical content',
//         path : [ 'tmp.tmp/filesSimilarity/identical3', 'tmp.tmp/filesSimilarity/identical4' ],
//         type : 'f',
//         createResource : bufferData2,
//         expected : 1
//       },
//       {
//         name : 'files with non identical text content',
//         path : [ 'tmp.tmp/filesSimilarity/identical_text3.txt', 'tmp.tmp/filesSimilarity/identical_text4.txt' ],
//         type : 'f',
//         createResource : [ textData1, textData2 ],
//         expected : 0.375
//       },
//       {
//         name : 'files with non identical binary content',
//         path : [ 'tmp.tmp/filesSimilarity/noidentical1', 'tmp.tmp/filesSimilarity/noidentical2' ],
//         type : 'f',
//         createResource : [ bufferData1, bufferData2 ],
//         expected : 0
//       },
//       {
//         name : 'file and symlink to file',
//         path : [ 'tmp.tmp/filesSimilarity/testsymlink', 'tmp.tmp/filesSimilarity/testfile' ],
//         type : 'sf',
//         createResource :  bufferData1,
//         expected : 1
//       },
//       // undefined behavior
//       // {
//       //   name : 'not existing path',
//       //   path : [ 'tmp.tmp/filesSimilarity/nofile1', 'tmp.tmp/filesSimilarity/noidentical2' ],
//       //   type : 'na',
//       //   expected : NaN
//       // }
//     ];
//
//   context.createTestResources( testChecks );
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//
//     let path1 = _.path.resolve( context.mergePath( testCheck.path[0] ) ),
//       path2 = _.path.resolve( context.mergePath( testCheck.path[1] ) ),
//       got;
//
//     test.case = testCheck.name;
//
//     try
//     {
//       got = _.filesSimilarity( { src1 : path1, src2 : path2 });
//     }
//     catch( err )
//     {
//       _.errLog( err );
//     }
//     test.identical( got, testCheck.expected );
//   }
//
//   // exception tests
//
//   if( Config.debug )
//   {
//     test.case = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       _.filesSimilarity( );
//     } );
//   }
// };
//

function filesSimilarity( test )
{
  let context = this;
  let provider = context.provider;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  var textData2 = ' Aenean non feugiat mauris';
  var bufferData1 = new U8x( [ 0x01, 0x02, 0x03, 0x04 ] );
  var bufferData2 = new U8x( [ 0x07, 0x06, 0x05 ] );

  var testChecks =
  [
    {
      name : 'two different files with empty content',
      path : [ 'tmp.tmp/filesSimilarity/empty1.txt', 'tmp.tmp/filesSimilarity/empty2.txt' ],
      type : 'f',
      createResource : '',
      expected : NaN
    },
    {
      name : 'same text file',
      path : [ 'tmp.tmp/filesSimilarity/same_text.txt', 'tmp.tmp/filesSimilarity/same_text.txt' ],
      type : 'f',
      createResource : textData1,
      expected : 1
    },
    {
      name : 'files with identical text content',
      path : [ 'tmp.tmp/filesSimilarity/identical_text1.txt', 'tmp.tmp/filesSimilarity/identical_text2.txt' ],
      type : 'f',
      createResource : textData1,
      expected : 1
    },
    {
      name : 'files with identical binary content',
      path : [ 'tmp.tmp/filesSimilarity/identical2', 'tmp.tmp/filesSimilarity/identical2.txt' ],
      type : 'f',
      createResource : bufferData1,
      expected : 1
    },
    {
      name : 'files with identical content',
      path : [ 'tmp.tmp/filesSimilarity/identical3', 'tmp.tmp/filesSimilarity/identical4' ],
      type : 'f',
      createResource : bufferData2,
      expected : 1
    },
    {
      name : 'files with non identical text content',
      path : [ 'tmp.tmp/filesSimilarity/identical_text3.txt', 'tmp.tmp/filesSimilarity/identical_text4.txt' ],
      type : 'f',
      createResource : [ textData1, textData2 ],
      expected : 0.10714285714285715
    },
    {
      name : 'files with non identical binary content',
      path : [ 'tmp.tmp/filesSimilarity/noidentical1', 'tmp.tmp/filesSimilarity/noidentical2' ],
      type : 'f',
      createResource : [ bufferData1, bufferData2 ],
      expected : 0
    },
    {
      name : 'file and symlink to file',
      path : [ 'tmp.tmp/filesSimilarity/testsymlink', 'tmp.tmp/filesSimilarity/testfile' ],
      type : 'sf',
      createResource :  bufferData1,
      expected : 1
    },
    // undefined behavior
    // {
    //   name : 'not existing path',
    //   path : [ 'tmp.tmp/filesSimilarity/nofile1', 'tmp.tmp/filesSimilarity/noidentical2' ],
    //   type : 'na',
    //   expected : NaN
    // }
  ];

  context.createTestResources( testChecks );

  // regular tests
  for( let testCheck of testChecks )
  {
    // join several test aspects together

    let path1 = _.path.resolve( context.mergePath( testCheck.path[ 0 ] ) );
    let path2 = _.path.resolve( context.mergePath( testCheck.path[ 1 ] ) );
    let got;

    test.description = testCheck.name;

    try
    {
      got = _.files.filesSimilarity( { src1 : path1, src2 : path2 });
    }
    catch( err )
    {
      _.errLog( err );
    }
    test.identical( got, testCheck.expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.files.filesSimilarity( );
    } );
  }
};

//

// function filesSize( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] ),
//     testChecks =
//     [
//       {
//         name : 'read empty text file',
//         data : '',
//         path : 'tmp.tmp/rtext1.txt',
//         expected :
//         {
//           error : null,
//           content : '',
//         },
//         createResource : '',
//         readOptions : fileReadOptions0
//       },
//       {
//         name : 'read text from file',
//         createResource : textData1,
//         path : 'tmp.tmp/text2.txt',
//         expected :
//         {
//           error : null,
//           content : textData1,
//         },
//         readOptions : fileReadOptions0
//       },
//       {
//         name : 'read text from file 2',
//         createResource : textData2,
//         path : 'tmp.tmp/text3.txt',
//         expected :
//         {
//           error : null,
//           content : textData2,
//         },
//         readOptions : fileReadOptions1
//       },
//       {
//         name : 'read buffer from file',
//         createResource : bufferData1,
//         path : 'tmp.tmp/data0',
//         expected :
//         {
//           error : null,
//           content : bufferData1,
//         },
//         readOptions : fileReadOptions2
//       },
//
//       {
//         name : 'read buffer from file 2',
//         createResource : bufferData2,
//         path : 'tmp.tmp/data2',
//         expected :
//         {
//           error : null,
//           content : bufferData2,
//         },
//         readOptions : fileReadOptions3
//       },
//
//       {
//         name : 'read json from file',
//         createResource : dataToJSON1,
//         path : 'tmp.tmp/jason1.json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON1,
//         },
//         readOptions : fileReadOptions4
//       },
//       {
//         name : 'read json from file 2',
//         createResource : dataToJSON2,
//         path : 'tmp.tmp/json2.json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON2,
//         },
//         readOptions : fileReadOptions5
//       },
//     ];
//
//
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//     let path = context.mergePath( testCheck.path );
//
//     // clear
//     // File.existsSync( path ) && File.removeSync( path );
//     if( provider.statResolvedRead( path ) )
//     provider.fileDelete( path );
//
//     // prepare to write if need
//     testCheck.createResource !== undefined
//     && context.createTestFile( testCheck.path, testCheck.createResource, testCheck.readOptions.encoding );
//
//     var o = _.props.extend( null, testCheck.readOptions, { filePath : path } );
//     // let got = provider.fileReadSync( path, testCheck.readOptions );
//     let got = provider.fileReadSync( o );
//
//     if( got instanceof BufferRaw )
//     {
//       //got = BufferNode.from( got );
//     //   got = toBuffer( got );
//       got = _.bufferNodeFrom( got );
//     }
//
//     test.description = testCheck.name;
//     test.identical( got, testCheck.expected.content );
//   }
//
//   // exception tests
//
//   if( Config.debug )
//   {
//     test.description = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileReadSync( );
//     } );
//
//     test.description = 'passed unexpected property in options';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileReadSync( wrongReadOptions0 );
//     } );
//
//     test.description = 'filePath is not defined';
//     test.shouldThrowErrorSync( function( )
//     {
//      provider.fileReadSync( { encoding : 'json' } );
//     } );
//
//   }
//
// };

function filesSize( test )
{
  let context = this;
  let provider = context.provider;

  /* file creation */

  var file1 = 'tmp.tmp/filesAreUpToDate/src/test1';
  var file2 = 'tmp.tmp/filesAreUpToDate/dst/test2';
  var file3 = 'tmp.tmp/filesAreUpToDate/src/test3';
  var file4 = 'tmp.tmp/filesAreUpToDate/dst/test4';

  var delay = provider.systemBitrateTimeGet() / 10;
  // var delay = provider.systemBitrateTimeGet() / 1000;

  context.createTestFile( file1, 'test1, any text' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file2, 'test2' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file3, 'test3' );

  file1 = context.mergePath( file1 );
  file2 = context.mergePath( file2 );
  file3 = context.mergePath( file3 );

  file1 = provider.path.nativize( file1 );
  file2 = provider.path.nativize( file2 );
  file3 = provider.path.nativize( file3 );

  /* - */

  test.case = 'string in arg';
  var got = provider.filesSize( file2 );
  if( provider.UsingBigIntForStat )
  test.equivalent( got, BigInt( 5 ) );
  else
  test.equivalent( got, 5 );

  test.case = 'array in arg';
  var got = provider.filesSize( [ file1, file2, file3 ] );
  if( provider.UsingBigIntForStat )
  test.equivalent( got, BigInt( 25 ) );
  else
  test.equivalent( got, 25 );

  test.case = 'map options, one file';
  var got = provider.filesSize( { filePath : file1 } );
  if( provider.UsingBigIntForStat )
  test.equivalent( got, BigInt( 15 ) );
  else
  test.equivalent( got, 15 );

  test.case = 'map options, aray';
  var got = provider.filesSize( { filePath : [ file1, file2, file3 ] } );
  if( provider.UsingBigIntForStat )
  test.equivalent( got, BigInt( 25 ) );
  else
  test.equivalent( got, 25 );

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => provider.filesSize() );

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( () => provider.filesSize( file1, file2, file3 ) );

  test.case = 'wrong arguments';
  test.shouldThrowErrorSync( () => provider.filesSize( 1 ) );
}

filesSize.timeOut = 20000;

//

function fileSize( test )
{
  let context = this;
  let provider = context.provider;

  /* file creation */

  var file1 = 'tmp.tmp/fileSize/test1';
  var file2 = 'tmp.tmp/fileSize/test2';
  var file3 = 'tmp.tmp/fileSize/test3';

  var delay = provider.systemBitrateTimeGet() / 10;
  // var delay = provider.systemBitrateTimeGet() / 1000;

  context.createTestFile( file1, 'test1, any text' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file2, 'test2' );

  file1 = context.mergePath( file1 );
  file2 = context.mergePath( file2 );

  file1 = provider.path.nativize( file1 );
  file2 = provider.path.nativize( file2 );

  let ready = new _.Consequence().take( null )

  /* asynchronous file creation */

  ready

  /* - */

  .then( () =>
  {
    test.case = 'string path in arg';
    var got = provider.fileSize( file1 );
    if( provider.UsingBigIntForStat )
    test.equivalent( got, BigInt( 15 ) );
    else
    test.equivalent( got, 15 );

    test.case = 'map in arg';
    var got = provider.fileSize( { filePath : file2 } );
    if( provider.UsingBigIntForStat )
    test.equivalent( got, BigInt( 5 ) );
    else
    test.equivalent( got, 5 );

    test.case = 'file is dir';
    var got = provider.fileSize( { filePath : _.path.current() } );
    if( provider.UsingBigIntForStat )
    test.equivalent( got, BigInt( 0 ) );
    else
    test.equivalent( got, 0 );

    return null;
  })

  /* - */

  .then( () =>
  {
    test.case = 'throwing : 0, stat === null';
    var map =
    {
      filePath : '/string',
      throwing : 0,
    }
    var got = provider.fileSize( map );
    test.equivalent( got, null );
    return null;
  })

  .then( () =>
  {
    let filePath = context.mergePath( file3 );

    let fileCreate = _.time.out( 100, function()
    {
      context.createTestFile( file3, 'test3, any text' );
    });

    test.case = 'asynchronous file creation test';
    let check1 = _.time.out( 0, function()
    {
      if( Config.debug )
      test.shouldThrowErrorSync( () => provider.fileSize({ filePath, throwing : 1 }) );
    });
    let check2 = _.time.out( 100, function()
    {
      var got = provider.fileSize( filePath );
      if( provider.UsingBigIntForStat )
      test.equivalent( got, BigInt( 15 ) );
      else
      test.equivalent( got, 15 );
    });
    return _.Consequence.And( check1, check2 );
  })

  return ready;

  // /* - */

  // if( !Config.debug )
  // return;

  // test.case = 'without arguments';
  // test.shouldThrowErrorSync( () => provider.fileSize() );

  // test.case = 'extra arguments';
  // test.shouldThrowErrorSync( () => provider.fileSize( file1, file1 ) );

  // test.case = 'throwing : 1, stats === null';
  // var map =
  // {
  //   filePath : '/string',
  //   throwing : 1,
  // }
  // test.shouldThrowErrorSync( () => provider.fileSize( map ) );

  // test.case = 'wrong argument';
  // test.shouldThrowErrorSync( () => provider.fileSize( 1 ) );
  // test.shouldThrowErrorSync( () => provider.fileSize( [ file1 ] ) );

  // test.case = 'unnecessary field in map';
  // var map =
  // {
  //   filePath : file1,
  //   onUp : () => 0,
  // }
  // test.shouldThrowErrorSync( () => provider.fileSize( map ) );
}

fileSize.timeOut = 20000;

//

// function fileWrite( test )
// {
//   var fileOptions =
//     {
//       filePath : null,
//       data : '',
//       append : false,
//       sync : true,
//       force : true,
//       silentError : false,
//       verbosity : false,
//       clean : false,
//     },
//     defReadOptions =
//     {
//       encoding : 'utf8'
//     },
//     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] );
//
//
//   // regular tests
//   var testChecks =
//     [
//       {
//         name : 'write empty text file',
//         data : '',
//         path : 'tmp.tmp/text1.txt',
//         expected :
//         {
//           instance : false,
//           content : '',
//           exist : true
//         },
//         readOptions : defReadOptions
//       },
//       {
//         name : 'write text to file',
//         data : textData1,
//         path : 'tmp.tmp/text2.txt',
//         expected :
//         {
//           instance : false,
//           content : textData1,
//           exist : true
//         },
//         readOptions : defReadOptions
//       },
//       {
//         name : 'append text to existing file',
//         data :
//         {
//           filePath : 'tmp.tmp/text3.txt',
//           data : textData2,
//           append : true,
//           sync : true,
//           force : false,
//           silentError : false,
//           verbosity : true,
//           clean : false,
//         },
//         path : 'tmp.tmp/text3.txt',
//         createResource : textData1,
//         expected :
//         {
//           instance : false,
//           content : textData1 + textData2,
//           exist : true
//         },
//         readOptions : defReadOptions
//       },
//       {
//         name : 'rewrite existing file',
//         data :
//         {
//           filePath : 'tmp.tmp/text4.txt',
//           data : textData2,
//           append : false,
//           sync : true,
//           force : false,
//           silentError : false,
//           verbosity : true,
//           clean : false,
//         },
//         path : 'tmp.tmp/text4.txt',
//         createResource : textData1,
//         expected :
//         {
//           instance : false,
//           content : textData2,
//           exist : true
//         },
//         readOptions : defReadOptions
//       },

//       {
//         name : 'force create unexisting path file',
//         data :
//         {
//           filePath : 'tmp.tmp/unexistingDir1/unexsitingDir2/text5.txt',
//           data : textData2,
//           append : false,
//           sync : true,
//           force : true,
//           silentError : false,
//           verbosity : true,
//           clean : false,
//         },
//         path : 'tmp.tmp/unexistingDir1/unexsitingDir2/text5.txt',
//         expected :
//         {
//           instance : false,
//           content : textData2,
//           exist : true
//         },
//         readOptions : defReadOptions
//       },

//       {
//         name : 'write file async',
//         data :
//         {
//           filePath : 'tmp.tmp/text6.txt',
//           data : textData2,
//           append : false,
//           sync : false,
//           force : true,
//           silentError : false,
//           verbosity : true,
//           clean : false,
//         },
//         path : 'tmp.tmp/text6.txt',
//         expected :
//         {
//           instance : true,
//           content : textData2,
//           exist : true
//         },
//         readOptions : defReadOptions
//       },
//       {
//         name : 'create file and write buffer data',
//         data :
//         {
//           filePath : 'tmp.tmp/data9',
//           data : bufferData1,
//           append : false,
//           sync : true,
//           force : false,
//           silentError : false,
//           verbosity : false,
//           clean : false,
//         },
//         path : 'tmp.tmp/data9',
//         expected :
//         {
//           instance : false,
//           content : bufferData1,
//           exist : true
//         },
//         readOptions : void 0
//       },
//       {
//         name : 'append buffer data to existing file',
//         data :
//         {
//           filePath : 'tmp.tmp/data9',
//           data : bufferData2,
//           append : true,
//           sync : true,
//           force : false,
//           silentError : false,
//           verbosity : false,
//           clean : false,
//         },
//         path : 'tmp.tmp/data9',
//         createResource : bufferData1,
//         expected :
//         {
//           instance : false,
//           content : BufferNode.concat( [ bufferData1, bufferData2 ] ),
//           exist : true
//         },
//         readOptions : void 0
//       },
//       {
//         name : 'append buffer data to existing file async',
//         data :
//         {
//           filePath : 'tmp.tmp/data9',
//           data : bufferData1,
//           append : true,
//           sync : false,
//           force : false,
//           silentError : false,
//           verbosity : false,
//           clean : false,
//         },
//         path : 'tmp.tmp/data9',
//         createResource : bufferData2,
//         expected :
//         {
//           instance : true,
//           content : BufferNode.concat( [ bufferData2, bufferData1 ] ),
//           exist : true
//         },
//         readOptions : void 0
//       },
//     ];


//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//     let got =
//       {
//         instance : null,
//         content : null,
//         exist : null
//       },
//       path = _.path.join( context.suiteTempPath, testCheck.path );

//     // clear
//     // File.existsSync( path ) && File.removeSync( path );
//     if( provider.statResolvedRead( path ) )
//     provider.fileDelete( path );

//     // prepare to write if need
//     testCheck.createResource && context.createTestFile( testCheck.path, testCheck.createResource );


//     var writeMode = testCheck.data.append ? 'append' : 'rewrite';
//     let gotFW = typeof testCheck.data === 'object'
//       ? ( testCheck.data.filePath = context.mergePath( testCheck.data.filePath ) ) && provider.fileWrite({ filePath :  path, writeMode,sync : testCheck.data.sync, data : testCheck.data.data })
//       : provider.fileWrite({ filePath :  path, data : testCheck.data })

//     // fileWtrite must returns wConsequence
//     got.instance = _.consequenceIs( gotFW );

//     path = provider.path.nativize( path );

//     if ( testCheck.data && testCheck.data.sync === false )
//     {
//       gotFW.give( ( ) =>
//       {
//         // recorded file should exists
//         // got.exist = File.existsSync( path );
//         got.exist = !!provider.statResolvedRead( path );
//         // check content of created file.
//         got.content = File.readFileSync( path, testCheck.readOptions )
//         test.description = testCheck.name;
//         test.identical( got, testCheck.expected );

//       } );
//       continue;
//     }

//     // recorded file should exists
//     // got.exist = File.existsSync( path );
//     got.exist = !!provider.statResolvedRead( path );
//     // check content of created file.
//     got.content = File.readFileSync( path, testCheck.readOptions )
//     test.description = testCheck.name;
//     test.identical( got, testCheck.expected );
//   }

//   // exception tests

//   if( Config.debug )
//   {
//     test.description = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileWrite( );
//     } );

//     test.description = 'extra arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileWrite( 'temp/sample.txt', 'hello', 'world' );
//     } );

//     test.description = 'path is not string';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileWrite( 3, 'hello' );
//     } );

//     test.description = 'passed unexpected property in options';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileWrite( { filePath : 'temp/some.txt', data : 'hello', parentDir : './work/project' } );
//     } );

//     test.description = 'data is not string or buffer';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileWrite( { filePath : 'temp/some.txt', data : { count : 1 } } );
//     } );
//   }

// };

//

// function fileRead( test )
// {
//   var wrongReadOptions0 =
//     {

//       sync : 1,
//       wrap : 0,
//       returnRead : 0,
//       silent : 0,

//       filePath : 'tmp.tmp/text2.txt',
//       filePath : 'tmp.tmp/text2.txt',
//       name : null,
//       encoding : 'utf8',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },
//     fileReadOptions0 =
//     {

//       sync : 0,
//       wrap : 0,
//       returnRead : 0,
//       //silent : 0,

//       filePath : null,
//       name : null,
//       encoding : 'utf8',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     fileReadOptions1 =
//     {

//       sync : 1,
//       wrap : 0,
//       returnRead : 1,
//       //silent : 0,

//       filePath : null,
//       name : null,
//       encoding : 'utf8',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     fileReadOptions2 =
//     {

//       sync : 0,
//       wrap : 0,
//       returnRead : 0,
//       //silent : 0,

//       filePath : null,
//       name : null,
//       encoding : 'buffer.raw',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     fileReadOptions3 =
//     {

//       sync : 1,
//       wrap : 0,
//       returnRead : 1,
//       //silent : 0,

//       filePath : null,
//       name : null,
//       encoding : 'buffer.raw',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     fileReadOptions4 =
//     {

//       sync : 0,
//       wrap : 0,
//       returnRead : 0,
//       //silent : 0,

//       filePath : null,
//       name : null,
//       encoding : 'json',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },
//     fileReadOptions5 =
//     {

//       sync : 1,
//       wrap : 0,
//       returnRead : 1,
//       //silent : 0,

//       filePath : null,
//       name : null,
//       encoding : 'json',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] ),
//     dataToJSON1 = [ 1, 'a', { b : 34 } ],
//     dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };

//   // regular tests

//   var testChecks =
//     [
//       {
//         name : 'read empty text file',
//         data : '',
//         path : 'tmp.tmp/rtext10.txt',
//         expected :
//         {
//           error : null,
//           content : '',
//         },
//         createResource : '',
//         readOptions : fileReadOptions0
//       },
//       {
//         name : 'read text from file',
//         createResource : textData1,
//         path : 'tmp.tmp/text20.txt',
//         expected :
//         {
//           error : null,
//           content : textData1,
//         },
//         readOptions : fileReadOptions0
//       },
//       {
//         name : 'read text from file synchronously',
//         createResource : textData2,
//         path : 'tmp.tmp/text30.txt',
//         expected :
//         {
//           error : null,
//           content : textData2,
//         },
//         readOptions : fileReadOptions1
//       },
//       {
//         name : 'read buffer from file',
//         createResource : bufferData1,
//         path : 'tmp.tmp/data99',
//         expected :
//         {
//           error : null,
//           content : bufferData1,
//         },
//         readOptions : fileReadOptions2
//       },

//       {
//         name : 'read buffer from file synchronously',
//         createResource : bufferData2,
//         path : 'tmp.tmp/data011',
//         expected :
//         {
//           error : null,
//           content : bufferData2,
//         },
//         readOptions : fileReadOptions3
//       },

//       {
//         name : 'read json from file',
//         createResource : dataToJSON1,
//         path : 'tmp.tmp/jason10.json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON1,
//         },
//         readOptions : fileReadOptions4
//       },
//       {
//         name : 'read json from file synchronously',
//         createResource : dataToJSON2,
//         path : 'tmp.tmp/json20.json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON2,
//         },
//         readOptions : fileReadOptions5
//       },
//     ];

//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     ( function( testCheck )
//     {
//       console.log( '----------->' + testCheck.name );
//       // join several test aspects together
//       let got =
//         {
//           error : null,
//           content : null
//         },
//         path = context.mergePath( testCheck.path );

//       // clear
//       File.existsSync( path ) && File.removeSync( path );

//       // prepare to write if need
//       testCheck.createResource !== undefined
//       && context.createTestFile( testCheck.path, testCheck.createResource, testCheck.readOptions.encoding );

//       testCheck.readOptions.filePath = path;
//       testCheck.readOptions.onBegin = function( err, data )
//       {
//         got.error = err;
//       };
//       testCheck.readOptions.onError = function( err, data )
//       {
//         got.error = err;
//       };
//       testCheck.readOptions.onEnd = function( err, fileContent )
//       {
//         got.error = err;

//         // check content of read file.
//         // +++ have a look om _.bufferTypedIs _.bufferRawIs _.bufferNodeIs
//         if( fileContent instanceof BufferRaw )
//         {
//           debugger;
//           //fileContent = BufferNode.from( fileContent );
//           fileContent = toBuffer( fileContent );
//         }
//         got.content = fileContent;

//         test.description = testCheck.name;
//         test.identical( got, testCheck.expected );

//       };

//       let gotFR = provider.fileRead( testCheck.readOptions );
//     } )( _.cloneJust( testCheck ) );

//   }

//   // exception tests

//   if( Config.debug )
//   {
//     test.description = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileRead( );
//     } );


//     test.description = 'passed unexpected property in options';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileRead( wrongReadOptions0 );
//     } );

//   }
// };

//

// function fileReadSync( test )
// {

//   var wrongReadOptions0 =
//     {
//       silent : 0,

//       filePath : 'tmp.tmp/text2.txt',
//       filePath : 'tmp.tmp/text2.txt',
//       encoding : 'utf8',
//     },

//     fileReadOptions0 =
//     {

//     //   wrap : 0,
//       //silent : 0,
//     //   returnRead : 1,

//       filePath : null,
//       name : null,
//       encoding : 'utf8',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     fileReadOptions1 =
//     {

//     //   wrap : 0,
//       //silent : 0,
//     //   returnRead : 1,

//       filePath : null,
//       name : null,
//       encoding : 'utf8',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//       advanced : null,

//     },

//     fileReadOptions2 =
//     {

//     //   wrap : 0,
//       //silent : 0,
//     //   returnRead : 1,

//       filePath : null,
//       encoding : 'buffer.raw',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//     },

//     fileReadOptions3 =
//     {

//       // sync : 0,
//     //   wrap : 0,
//     //   returnRead : 1,
//       //silent : 0,

//       filePath : null,
//       encoding : 'buffer.raw',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//     },

//     fileReadOptions4 =
//     {

//     //   wrap : 0,
//       //silent : 0,
//     //   returnRead : 1,

//       filePath : null,
//       name : null,
//       encoding : 'json',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//     },
//     fileReadOptions5 =
//     {

//     //   wrap : 0,
//       //silent : 0,
//     //   returnRead : 1,

//       filePath : null,
//       name : null,
//       encoding : 'json',

//       onBegin : null,
//       onEnd : null,
//       onError : null,

//     },

//     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] ),
//     dataToJSON1 = [ 1, 'a', { b : 34 } ],
//     dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };
//
//
//   // regular tests
//   var testChecks =
//     [
//       {
//         name : 'read empty text file',
//         data : '',
//         path : 'tmp.tmp/rtext1.txt',
//         expected :
//         {
//           error : null,
//           content : '',
//         },
//         createResource : '',
//         readOptions : fileReadOptions0
//       },
//       {
//         name : 'read text from file',
//         createResource : textData1,
//         path : 'tmp.tmp/text2.txt',
//         expected :
//         {
//           error : null,
//           content : textData1,
//         },
//         readOptions : fileReadOptions0
//       },
//       {
//         name : 'read text from file 2',
//         createResource : textData2,
//         path : 'tmp.tmp/text3.txt',
//         expected :
//         {
//           error : null,
//           content : textData2,
//         },
//         readOptions : fileReadOptions1
//       },
//       {
//         name : 'read buffer from file',
//         createResource : bufferData1,
//         path : 'tmp.tmp/data0',
//         expected :
//         {
//           error : null,
//           content : bufferData1,
//         },
//         readOptions : fileReadOptions2
//       },
//
//       {
//         name : 'read buffer from file 2',
//         createResource : bufferData2,
//         path : 'tmp.tmp/data2',
//         expected :
//         {
//           error : null,
//           content : bufferData2,
//         },
//         readOptions : fileReadOptions3
//       },
//
//       {
//         name : 'read json from file',
//         createResource : dataToJSON1,
//         path : 'tmp.tmp/jason1.json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON1,
//         },
//         readOptions : fileReadOptions4
//       },
//       {
//         name : 'read json from file 2',
//         createResource : dataToJSON2,
//         path : 'tmp.tmp/json2.json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON2,
//         },
//         readOptions : fileReadOptions5
//       },
//     ];
//
//
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//     let path = context.mergePath( testCheck.path );
//
//     // clear
//     // File.existsSync( path ) && File.removeSync( path );
//     if( provider.statResolvedRead( path ) )
//     provider.fileDelete( path );
//
//     // prepare to write if need
//     testCheck.createResource !== undefined
//     && context.createTestFile( testCheck.path, testCheck.createResource, testCheck.readOptions.encoding );
//
//     let got = provider.fileReadSync( path, testCheck.readOptions );
//
//     if( got instanceof BufferRaw )
//     {
//       //got = BufferNode.from( got );
//       got = toBuffer( got );
//     }
//
//     test.case = testCheck.name;
//     test.identical( got, testCheck.expected.content );
//   }
//
//   // exception tests
//
//   if( Config.debug )
//   {
//     test.case = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileReadSync( );
//     } );
//
//     test.case = 'passed unexpected property in options';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileReadSync( wrongReadOptions0 );
//     } );
//
//     test.case = 'filePath is not defined';
//     test.shouldThrowErrorSync( function( )
//     {
//      provider.fileReadSync( { encoding : 'json' } );
//     } );
//
//   }
//
// };
//
// function fileReadJson( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     dataToJSON1 = [ 1, 'a', { b : 34 } ],
//     dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };
//
//
//   // regular tests
//   var testChecks =
//     [
//       {
//         name : 'try to load empty text file as json',
//         data : '',
//         path : 'tmp.tmp/rtext1.txt',
//         expected :
//         {
//           error : true,
//           content : void 0
//         },
//         createResource : ''
//       },
//       {
//         name : 'try to read non json string as json',
//         createResource : textData1,
//         path : 'tmp.tmp/text2.txt',
//         expected :
//         {
//           error : true,
//           content : void 0
//         }
//       },
//       {
//         name : 'try to parse buffer as json',
//         createResource : bufferData1,
//         path : 'tmp.tmp/data0',
//         expected :
//         {
//           error : true,
//           content : void 0
//         }
//       },
//       {
//         name : 'read json from file',
//         createResource : dataToJSON1,
//         path : 'tmp.tmp/jason1.json',
//         encoding : 'json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON1
//         }
//       },
//       {
//         name : 'read json from file 2',
//         createResource : dataToJSON2,
//         path : 'tmp.tmp/json2.json',
//         encoding : 'json',
//         expected :
//         {
//           error : null,
//           content : dataToJSON2
//         }
//       }
//     ];
//
//
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//     let got =
//       {
//         error : null,
//         content : void 0
//       },
//       path = context.mergePath( testCheck.path );
//
//     // clear
//     // File.existsSync( path ) && File.removeSync( path );
//     if( provider.statResolvedRead( path ) )
//     provider.fileDelete( path );
//
//     // prepare to write if need
//     testCheck.createResource !== undefined
//       && context.createTestFile( testCheck.path, testCheck.createResource , testCheck.encoding );
//
//     try
//     {
//       got.content = provider.fileReadJs( path );
//     }
//     catch ( err )
//     {
//       got.error = true;
//     }
//
//
//     test.identical( got, testCheck.expected );
//   }
//
//   // exception tests
//
//   if( Config.debug )
//   {
//     test.case = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileReadJs( );
//     } );
//
//     test.case = 'extra arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileReadJs( 'tmp.tmp/tmp.tmp.json', {} );
//     } );
//   }
//
// };
//
// function filesSame( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] ),
//
//   testChecks = [
//
//     {
//       name : 'same file with empty content',
//       path : [ 'tmp.tmp/filesSame/sample.txt', 'tmp.tmp/filesSame/sample.txt' ],
//       type : 'f',
//       createResource : '',
//       expected : false
//     },
//     {
//       name : 'two different files with empty content',
//       path : [ 'tmp.tmp/filesSame/hidden.txt', 'tmp.tmp/filesSame/nohidden.txt' ],
//       type : 'f',
//       createResource : '',
//       expected : false
//     },
//     {
//       name : 'same text file',
//       path : [ 'tmp.tmp/filesSame/same_text.txt', 'tmp.tmp/filesSame/same_text.txt' ],
//       type : 'f',
//       createResource : textData1,
//       expected : true
//     },
//     {
//       name : 'files with identical text content',
//       path : [ 'tmp.tmp/filesSame/identical_text1.txt', 'tmp.tmp/filesSame/identical_text2.txt' ],
//       type : 'f',
//       createResource : textData1,
//       expected : true
//     },
//     {
//       name : 'files with identical binary content',
//       path : [ 'tmp.tmp/filesSame/identical2', 'tmp.tmp/filesSame/identical2.txt' ],
//       type : 'f',
//       createResource : bufferData1,
//       expected : true
//     },
//     {
//       name : 'files with non identical text content',
//       path : [ 'tmp.tmp/filesSame/identical_text3.txt', 'tmp.tmp/filesSame/identical_text4.txt' ],
//       type : 'f',
//       createResource : [ textData1, textData2 ],
//       expected : false
//     },
//     {
//       name : 'files with non identical binary content',
//       path : [ 'tmp.tmp/filesSame/noidentical1', 'tmp.tmp/filesSame/noidentical2' ],
//       type : 'f',
//       createResource : [ bufferData1, bufferData2 ],
//       expected : false
//     },
//     {
//       name : 'file and symlink to file',
//       path : [ 'tmp.tmp/filesSame/testsymlink', 'tmp.tmp/filesSame/testfile' ],
//       type : 'sf',
//       createResource :  bufferData1,
//       expected : true
//     },
//     {
//       name : 'not existing path',
//       path : [ 'tmp.tmp/filesSame/nofile1', 'tmp.tmp/filesSame/noidentical2' ],
//       type : 'na',
//       expected : false
//     }
//   ];
//
//   context.createTestResources( testChecks )
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//
//     let file1 = _.path.resolve( context.mergePath( testCheck.path[0] ) ),
//       file2 = _.path.resolve( context.mergePath( testCheck.path[1] ) ),
//       got;
//
//     test.case = testCheck.name;
//
//     try
//     {
//       got = provider.filesSame({ ins1 :  file1, ins2 : file2, usingExtraStat : testCheck.checkTime, usingSymlink : 1 } );
//     }
//     catch( err ) {
//       console.log( err );
//     }
//     test.identical( got, testCheck.expected );
//   }
//
//   // exception tests
//
//   if( Config.debug )
//   {
//     test.case = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.filesSame( );
//     } );
//   }
//
//   // custom cases
//
//   test.case = 'two file records asociated with two regular files';
//   var path1 =  'tmp.tmp/filesSame/rfile1',
//     path2 =   'tmp.tmp/filesSame/rfile2';
//
//   context.createTestFile( path1, textData1 );
//   context.createTestFile( path2, textData1 );
//
//   path1 = _.path.resolve( context.mergePath( path1 ) ),
//   path2 = _.path.resolve( context.mergePath( path2 ) );
//
//   var file1 = provider.recordFactory().record( path1 ),
//     file2 = provider.recordFactory().record( path2 );
//
//   try
//   {
//     got = provider.filesSame( { ins1 : file1, ins2 : file2 } );
//   }
//   catch( err ) {
//     console.log( err );
//   }
//   test.identical( got, true );
//
//   test.case = 'file record asociated with two symlinks for different files with same content';
//   var path1 =  'tmp.tmp/filesSame/lrfile1',
//     path2 =  'tmp.tmp/filesSame/lrfile2';
//
//   createTestSymLink( path1, void 0, 'sf', textData1 );
//   createTestSymLink( path2, void 0, 'sf', textData1 );
//
//   path1 = _.path.resolve( context.mergePath( path1 ) ),
//     path2 = _.path.resolve( context.mergePath( path2 ) );
//
//   var file1 = provider.recordFactory().record( path1 ),
//     file2 = provider.recordFactory().record( path2 );
//
//   try
//   {
//     got = provider.filesSame( { ins1 : file1, ins2 : file2, usingSymlink : 1 } );
//   }
//   catch( err ) {
//     console.log( err );
//   }
//   test.identical( got, true );
//
//   test.case = 'file record asociated with regular file, and symlink with relative target value';
//   var path1 =  'tmp.tmp/filesSame/rfile3',
//     path2 =  'tmp.tmp/filesSame/rfile4',
//     link =  'tmp.tmp/filesSame/lfile4';
//
//   context.createTestFile( path1, textData1 );
//   context.createTestFile( path2, textData1 );
//
//   path1 = _.path.resolve( context.mergePath( path1 ) );
//   link = _.path.resolve( context.mergePath( link ) );
//   path2 = context.mergePath( path2 );
//
//   var file1 = provider.recordFactory().record( path1 );
//   // File.symlinkSync( path2, link, 'file' );
//   provider.softLink( link, path2 );
//   try
//   {
//     got = provider.filesSame( { ins1 : file1, ins2 : link } );
//   }
//   catch( err ) {
//     console.log( err );
//   }
//   test.identical( got, true );
//
//   // time check
//     test.case = 'files with identical content : time check';
//     var expected = false,
//       file1 = _.path.resolve( context.mergePath( 'tmp.tmp/filesSame/identical3' ) ),
//       file2 = _.path.resolve( context.mergePath( 'tmp.tmp/filesSame/identical4' ) ),
//       con, got;
//
//     context.createTestFile( file1 );
//     con = _.time.out( 50);
//     con.finally( ( ) => context.createTestFile( file2 ) );
//     con.finally( ( ) =>
//     {
//       try
//       {
//         got = provider.filesSame( file1, file2, true );
//       }
//       catch( err ) {}
//       test.identical( got, expected );
//     } );
//
//     return con;
// };
//
// function filesLinked( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//
//     testChecks = [
//       {
//         name : 'same text file',
//         path : [ 'tmp.tmp/filesLinked/same_text.txt', 'tmp.tmp/filesLinked/same_text.txt' ],
//         type : 'f',
//         createResource : textData1,
//         expected : true
//       },
//       {
//         name : 'symlink to file with text content',
//         path : [ 'tmp.tmp/filesLinked/identical_text1.txt', 'tmp.tmp/filesLinked/identical_text2.txt' ],
//         type : 'sf',
//         createResource : textData1,
//         expected : false
//       },
//       {
//         name : 'different files with identical binary content',
//         path : [ 'tmp.tmp/filesLinked/identical1', 'tmp.tmp/filesLinked/identical2' ],
//         type : 'f',
//         createResource : bufferData1,
//         expected : false
//       },
//       {
//         name : 'symlink to file with  binary content',
//         path : [ 'tmp.tmp/filesLinked/identical3', 'tmp.tmp/filesLinked/identical4' ],
//         type : 'sf',
//         createResource : bufferData1,
//         expected : false
//       },
//       {
//         name : 'hardLink to file with  binary content',
//         path : [ 'tmp.tmp/filesLinked/identical5', 'tmp.tmp/filesLinked/identical6' ],
//         type : 'hf',
//         createResource : bufferData1,
//         expected : true
//       },
//       {
//         name : 'hardLink to file with  text content : file record',
//         path : [ 'tmp.tmp/filesLinked/identical7', 'tmp.tmp/filesLinked/identical8' ],
//         type : 'hf',
//         fileRecord : true,
//         createResource : textData1,
//         expected : true
//       },
//       // {
//       //   name : 'not existing path',
//       //   path : [ 'tmp.tmp/filesLinked/nofile1', 'tmp.tmp/filesLinked/noidentical2' ],
//       //   type : 'na',
//       //   expected : false
//       // }
//     ];
//
//   context.createTestResources( testChecks )
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//
//     let file1 = _.path.resolve( context.mergePath( testCheck.path[ 0 ] ) ),
//       file2 = _.path.resolve( context.mergePath( testCheck.path[ 1 ] ) ),
//       got;
//
//     if( testCheck.fileRecord )
//     {
//       file1 = provider.recordFactory().record( file1 );
//       file2 = provider.recordFactory().record( file2 );
//     }
//
//     test.case = testCheck.name;
//
//     try
//     {
//       got = provider.filesLinked( file1, file2 );
//     }
//     catch ( err ) {}
//     finally
//     {
//       test.identical( got, testCheck.expected );
//     }
//   }
//
//   // exception tests
//
//   // if( Config.debug )
//   // {
//   //   test.case = 'missed arguments';
//   //   test.shouldThrowErrorSync( function( )
//   //   {
//   //     provider.hardLinked( );
//   //   } );
//   // }
// };
//
// //
//
// function fileDelete( test ) {
//   var fileDelOptions =
//     {
//       filePath : null,
//       force : 0,
//       sync : 1,
//     },

//     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] );
//
//
//   // regular tests
//   var testChecks =
//     [
//       {
//         name : 'delete single empty text file',
//         createResource : '',
//         type : 'f',
//         path : 'tmp.tmp/fileDelete/text1.txt',
//         expected :
//         {
//           exception : false,
//           exist : false
//         }
//       },
//       {
//         name : 'delete single text file asynchronously',
//         createResource : textData1,
//         path : 'tmp.tmp/fileDelete/text2.txt',
//         type : 'f',
//         expected :
//         {
//           exception : false,
//           exist : false
//         },
//         delOptions : {
//           filePath : 'tmp.tmp/fileDelete/text2.txt',
//           force : 0,
//           sync : 0,
//         }
//       },
//       {
//         name : 'delete empty folder',
//         type : 'd',
//         path : 'tmp.tmp/fileDelete/emptyFolder',
//         expected :
//         {
//           exception : false,
//           exist : false
//         }
//       },
//       {
//         name : 'delete not empty folder : no force',
//         type : 'd',
//         path : 'tmp.tmp/fileDelete/noEmptyFolder',
//         delOptions :
//         {
//           filePath : 'tmp.tmp/fileDelete/noEmptyFolder',
//           force : 0
//         },
//         folderContent :
//         {
//           path : [ 'file1', 'file2.txt' ],
//           type : 'f',
//           createResource : [ bufferData1, textData2 ]
//         },
//         expected :
//         {
//           exception : true,
//           exist : true
//         },
//       },

//       {
//         name : 'force delete not empty folder',
//         type : 'd',
//         folderContent :
//         {
//           path : [ 'file3', 'file4.txt' ],
//           type : 'f',
//           createResource : [ bufferData2, textData1 ]
//         },
//         path : 'tmp.tmp/fileDelete/noEmptyFolder2',
//         expected :
//         {
//           exception : false,
//           exist : false
//         },
//         delOptions : {
//           filePath : null,
//           force : 1,
//           sync : 1,
//         }
//       },

//       {
//         name : 'force delete not empty folder : async',
//         type : 'd',
//         folderContent :
//         {
//           path : [ 'file5', 'file6.txt' ],
//           type : 'f',
//           createResource : [ bufferData2, textData1 ]
//         },
//         path : 'tmp.tmp/fileDelete/noEmptyFolder3',
//         expected :
//         {
//           exception : false,
//           exist : false
//         },
//         delOptions : {
//           filePath : null,
//           force : 1,
//           sync : 0,
//         }
//       },
//       {
//         name : 'delete symlink',
//         path : 'tmp.tmp/fileDelete/identical2',
//         type : 'sf',
//         createResource : bufferData1,
//         expected :
//         {
//           exception : false,
//           exist : false
//         },
//       }
//     ];


//   context.createTestResources( testChecks );

//   var counter = 0;
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     ( function( testCheck )
//     {
//       // join several test aspects together
//       var got =
//         {
//           exception : false,
//           exist : false,
//         },
//         path = context.mergePath( testCheck.path ),
//         continueFlag = false;
//       path = provider.path.nativize( path );
//       try
//       {
//         let gotFD = typeof testCheck.delOptions === 'object'
//           ? ( testCheck.delOptions.filePath = path ) && provider.fileDelete( testCheck.delOptions )
//           : provider.fileDelete( path );

//         if( testCheck.delOptions && !!testCheck.delOptions.sync === false )
//         {
//           continueFlag = true;
//           gotFD.give( ( err ) =>
//           {
//             // deleted file should  not exists
//             got.exist = !!provider.statResolvedRead( path );

//             // check exceptions
//             got.exception = !!err;

//             test.description = testCheck.name;
//             test.identical( got, testCheck.expected );
//           } );
//         }
//       }
//       catch( err )
//       {
//         got.exception = !!err;
//       }
//       finally
//       {
//         got.exception = !!got.exception;
//       }
//       if ( !continueFlag )
//       {
//         // deleted file should not exists
//         got.exist = !!provider.statResolvedRead( path );

//         // check content of created file.
//         test.description = testCheck.name;
//         test.identical( got, testCheck.expected );
//       }
//     } )( _.cloneJust( testCheck ) );
//   }

//   // exception tests

//   if( Config.debug )
//   {
//     test.description = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileDelete( );
//     } );

//     test.description = 'extra arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileDelete( 'temp/sample.txt', fileDelOptions );
//     } );

//     test.description = 'path is not string';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileDelete( {
//         filePath : null,
//         force : 0,
//         sync : 1,
//       } );
//     } );

//     test.description = 'passed unexpected property in options';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.fileWrite( {
//         filePath : 'temp/some.txt',
//         force : 0,
//         sync : 1,
//         parentDir : './work/project'
//       } );
//     } );
//   }
// };
//
// //
//
// function filesLink( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//
//     testChecks = [
//       {
//         name : 'create link to text file with same path',
//         path : 'tmp.tmp/filesLink/same_text.txt',
//         link : 'tmp.tmp/filesLink/same_text.txt',
//         type : 'f',
//         createResource : textData1,
//         expected : { result : true, isExists : true, err : false, ishard : false }
//       },
//       {
//         name : 'link to file with text content',
//         path : [ 'tmp.tmp/filesLink/identical_text1.txt', 'tmp.tmp/filesLink/identical_text2.txt' ],
//         link : 'tmp.tmp/filesLink/identical_text2.txt',
//         type : 'f',
//         createResource : textData2,
//         expected : { result : true, isExists : true, err : false, ishard : true }
//       },
//       {
//         name : 'link to file with binary content',
//         path : 'tmp.tmp/filesLink/identical1',
//         link : 'tmp.tmp/filesLink/identical2',
//         type : 'f',
//         createResource : bufferData1,
//         expected : { result : true, isExists : true, err : false, ishard : true }
//       },
//       {
//         name : 'not existing path',
//         path : 'tmp.tmp/filesLink/nofile1',
//         link : 'tmp.tmp/filesLink/linktonofile',
//         type : 'na',
//         expected : { result : false, isExists : false, err : true, ishard : false }
//       },
//
//       {
//         name : 'try to create hard link to folder',
//         path : 'tmp.tmp/fileHardlink/folder',
//         link : 'tmp.tmp/fileHardlink/hard_folder',
//         type : 'd',
//         expected : { result : false, isExists : false, err : true, ishard : false }
//       },
//
//     ];
//
//   context.createTestResources( testChecks );
//
//   function checkHardLink( link, src )
//   {
//     link = _.path.resolve( link );
//     src = _.path.resolve( src );
//     // var statLink = File.lstatSync( link ),
//     var statLink = provider.statResolvedRead({ filePath : link, resolvingSoftLink : 0 }),
//       // statSource = File.lstatSync( src );
//       statSource = provider.statResolvedRead({ filePath : src, resolvingSoftLink : 0 })
//
//     if ( !statLink || !statSource ) return false; // both files should be exists
//     if ( statSource.nlink !== 2 ) return false;
//     if ( statLink.ino !== statSource.ino ) return false; // both names should be associated with same file on device.
//
//     // File.unlinkSync( link );
//     provider.fileDelete( link );
//     statSource = provider.statResolvedRead({ filePath : src, resolvingSoftLink : 0 });
//
//     if ( statSource.nlink !== 1 ) return false;
//
//     return true;
//   }
//
//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together
//
//     let file = Array.isArray( testCheck.path) ? context.mergePath( testCheck.path[0] ) : context.mergePath( testCheck.path ),
//       link = context.mergePath( testCheck.link ),
//       got = { result : false, isExists : false, ishard : false, err : false };
//
//     test.case = testCheck.name;
//
//     try
//     {
//       got.result = provider.hardLink({ dstPath :  link, srcPath : file, sync : 1 });
//       // got.isExists = File.existsSync(  _.path.resolve( link ) );
//       got.isExists = !!provider.statResolvedRead(  _.path.resolve( link ) );
//       got.ishard = checkHardLink( link, file );
//     }
//     catch( err )
//     {
//       _.errLog( err );
//       got.err = true;
//     }
//     finally
//     {
//       got.err = !!got.err;
//       got.ishard = !!got.ishard;
//       test.identical( got, testCheck.expected );
//     }
//   }
//
//   // exception tests
//
//   if( Config.debug )
//   {
//     test.case = 'missed arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.hardLink( );
//     } );
//
//     test.case = 'extra arguments';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.hardLink( 'tmp.tmp/filesLink/identical1', 'tmp.tmp/filesLink/same_text.txt', 'tmp.tmp/filesLink/same_text.txt' );
//     } );
//
//     test.case = 'argumetns is not string';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.hardLink( 34, {} );
//     } );
//
//     test.case = 'passed unexpected property';
//     test.shouldThrowErrorSync( function( )
//     {
//       provider.hardLink( {
//         dstPath : 'tmp.tmp/fileHardlink/src1',
//         srcPath : 'tmp.tmp/fileHardlink/hard_text.txt',
//         dir : 'tmp.tmp/fileHardlink'
//       } );
//     } );
//   }
//
// };
//
// //

function filesLink( test )
{
  let context = this;
  let provider = context.provider;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  var textData2 = ' Aenean non feugiat mauris';
  var bufferData1 = new U8x( [ 0x01, 0x02, 0x03, 0x04 ] );
  // To new NodeJS it is not correct syntax
  // bufferData1 = new U8x( [ 0x01, 0x02, 0x03, 0x04 ] ),

  var testChecks =
  [
    {
      name : 'create link to text file with same path',
      path : 'tmp.tmp/filesLink/same_text.txt',
      link : 'tmp.tmp/filesLink/same_text.txt',
      type : 'f',
      createResource : textData1,
      expected : { result : true, isExists : true, err : false, ishard : false }
    },
    {
      name : 'link to file with text content',
      path : [ 'tmp.tmp/filesLink/identical_text1.txt', 'tmp.tmp/filesLink/identical_text2.txt' ],
      link : 'tmp.tmp/filesLink/identical_text2.txt',
      type : 'f',
      createResource : textData2,
      expected : { result : true, isExists : true, err : false, ishard : true }
    },
    {
      name : 'link to file with binary content',
      path : 'tmp.tmp/filesLink/identical1',
      link : 'tmp.tmp/filesLink/identical2',
      type : 'f',
      createResource : bufferData1,
      expected : { result : true, isExists : true, err : false, ishard : true }
    },
    {
      name : 'not existing path',
      path : 'tmp.tmp/filesLink/nofile1',
      link : 'tmp.tmp/filesLink/linktonofile',
      type : 'na',
      expected : { result : false, isExists : false, err : true, ishard : false }
    },

    {
      name : 'try to create hard link to folder',
      path : 'tmp.tmp/fileHardlink/folder',
      link : 'tmp.tmp/fileHardlink/hard_folder',
      type : 'd',
      expected : { result : false, isExists : false, err : true, ishard : false }
    },

  ];

  context.createTestResources( testChecks );

  function checkHardLink( link, src )
  {
    link = _.path.resolve( link );
    src = _.path.resolve( src );
    // var statLink = File.lstatSync( link );
    var statLink = provider.statResolvedRead({ filePath : link, resolvingSoftLink : 0 });
    // var statSource = File.lstatSync( src );
    var statSource = provider.statResolvedRead({ filePath : src, resolvingSoftLink : 0 });

    if( !statLink || !statSource )
    return false; // both files should be exists
    if( Number( statSource.nlink ) !== 2 )
    return false;
    if( statLink.ino !== statSource.ino )
    return false; // both names should be associated with same file on device.

    // File.unlinkSync( link );
    provider.fileDelete( link );
    _.time.out( 100 ).deasync();
    statSource = provider.statResolvedRead({ filePath : src, resolvingSoftLink : 0 });

    if( Number( statSource.nlink ) !== 1 )
    return false;

    return true;
  }

  // regular tests
  for( let testCheck of testChecks )
  {
    // join several test aspects together

    let file = Array.isArray( testCheck.path) ? context.mergePath( testCheck.path[ 0 ] ) : context.mergePath( testCheck.path );
    let link = context.mergePath( testCheck.link );
    let got = { result : false, isExists : false, ishard : false, err : false };

    test.description = testCheck.name;

    try
    {
      got.result = provider.hardLink({ dstPath :  link, srcPath : file, sync : 1 });
      // got.isExists = File.existsSync(  _.path.resolve( link ) );
      got.isExists = !!provider.statResolvedRead(  _.path.resolve( link ) );
      got.ishard = checkHardLink( link, file );
    }
    catch( err )
    {
      _.errLog( err );
      got.err = true;
    }
    finally
    {
      got.err = !!got.err;
      got.ishard = !!got.ishard;
      test.identical( got, testCheck.expected );
    }
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      provider.hardLink( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      provider.hardLink( 'tmp.tmp/filesLink/identical1', 'tmp.tmp/filesLink/same_text.txt', 'tmp.tmp/filesLink/same_text.txt' );
    } );

    test.description = 'argumetns is not string';
    test.shouldThrowErrorSync( function( )
    {
      provider.hardLink( 34, {} );
    } );

    test.description = 'passed unexpected property';
    test.shouldThrowErrorSync( function( )
    {
      provider.hardLink( {
        dstPath : 'tmp.tmp/fileHardlink/src1',
        srcPath : 'tmp.tmp/fileHardlink/hard_text.txt',
        dir : 'tmp.tmp/fileHardlink'
      } );
    } );
  }

};

//

function filesAreUpToDate2( test )
{
  let context = this;
  let provider = context.provider;

  /* file creation */

  var file1 = 'tmp.tmp/filesAreUpToDate/src/test1';
  var file2 = 'tmp.tmp/filesAreUpToDate/dst/test2';
  var file3 = 'tmp.tmp/filesAreUpToDate/src/test3';
  var file4 = 'tmp.tmp/filesAreUpToDate/dst/test4';

  var delay = provider.systemBitrateTimeGet() / 10;
  // var delay = provider.systemBitrateTimeGet() / 1000;

  context.createTestFile( file1, 'test1' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file2, 'test2' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file3, 'test3' );
  // waitSync( delay );
  _.time.sleep( delay );
  context.createTestFile( file4, 'test4' );

  file1 = context.mergePath( file1 );
  file2 = context.mergePath( file2 );
  file3 = context.mergePath( file3 );
  file4 = context.mergePath( file4 );

  file1 = provider.path.nativize( file1 );
  file2 = provider.path.nativize( file2 );
  file3 = provider.path.nativize( file3 );
  file4 = provider.path.nativize( file4 );

  /* - */

  test.description = 'src files is up to date';
  var got = provider.filesAreUpToDate2( { src : file1, dst : file2 } );
  test.identical( got, true );

  var map = { src : [ file1, file2 ], dst : [ file3, file4 ] };
  var got = provider.filesAreUpToDate2( map );
  test.identical( got, true );

  test.description = 'src files is up to date, youngerThan';
  var map =
  {
    src : [ file1, file2 ],
    dst : [ file3, file4 ],
    youngerThan : new Date(),
    verbosity : 3
  };
  var got = provider.filesAreUpToDate2( map );
  test.identical( got, true );


  /* Dmytro : need help to write
  test.description = 'src files is up to date, verbosity';
  var map = { src : [ file1, file2 ], dst : [ file3, file4 ], verbosity : 4 };
  var got = provider.filesAreUpToDate2( map );
  test.identical( got, true );
  */

  /* - */

  test.description = 'src files is outdated';
  var got = provider.filesAreUpToDate2( { src : file2, dst : file1 } );
  test.identical( got, false );

  var map = { src : [ file3, file4 ], dst : [ file1, file2 ] };
  var got = provider.filesAreUpToDate2( map );
  test.identical( got, false );

  test.description = 'src files is up to date, youngerThan';
  var map =
  {
    src : [ file3, file4 ],
    dst : [ file1, file2 ],
    youngerThan : new Date( 2100, 7, 17),
    verbosity : 3
  };
  var got = provider.filesAreUpToDate2( map );
  test.identical( got, true );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => provider.filesAreUpToDate2() );

  test.case = 'extra arguments';
  var map = { src : file1, dst : file2 };
  test.shouldThrowErrorSync( () => provider.filesAreUpToDate2( map, map ) );

  test.case = 'wrong arguments';
  var map = { src : file1, dst : file2 };
  test.shouldThrowErrorSync( () => provider.filesAreUpToDate2( 'str' ) );
  test.shouldThrowErrorSync( () => provider.filesAreUpToDate2( file1 ) );

  test.case = 'o.newer settled, not a date';
  var map = { src : file1, dst : file2, newer : 1 };
  test.shouldThrowErrorSync( () => provider.filesAreUpToDate2( map ) );

}

filesAreUpToDate2.timeOut = 20000;

//

// function filesList( test )
// {
//   var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//     textData2 = ' Aenean non feugiat mauris',
//     bufferData1 = BufferNode.from( [ 0x01, 0x02, 0x03, 0x04 ] ),
//     bufferData2 = BufferNode.from( [ 0x07, 0x06, 0x05 ] );
//
//
//   // regular tests
//   var testChecks =
//     [
//       {
//         name : 'single file',
//         createResource : textData1,
//         type : 'f',
//         path : 'tmp.tmp/filesList/text1.txt',
//         expected :
//         {
//           list : [ 'text1.txt' ],
//           err : false
//         }
//       },
//       {
//         name : 'empty folder',
//         type : 'd',
//         path : 'tmp.tmp/filesList/emptyFolder',
//         expected :
//         {
//           list : [],
//           err : false
//         }
//       },
//       {
//         name : 'folder with several files',
//         type : 'd',
//         path : 'tmp.tmp/filesList/noEmptyFolder',
//         folderContent :
//         [
//           {
//             path : [ 'file2', 'file1.txt' ],
//             type : 'f',
//             createResource : [ bufferData1, textData2 ]
//           },
//         ],
//         expected :
//         {
//           list : [ 'file1.txt', 'file2' ],
//           err : false
//         },
//       },
//       {
//         name : 'folder with several files and dirs',
//         type : 'd',
//         path : 'tmp.tmp/filesList/noEmptyFolder1',
//         folderContent :
//         [
//           {
//             path : [ 'file4', 'file5.txt' ],
//             type : 'f',
//             createResource : [ bufferData1, textData2 ]
//           },
//           {
//             type : 'd',
//             path : 'noEmptyNestedFolder',
//             folderContent :
//             [
//               {
//                 path : [ 'file6', 'file7.txt' ],
//                 type : 'f',
//                 createResource : [ bufferData2, textData2 ]
//               },
//             ]
//           }
//         ],
//         expected :
//         {
//           list : [ 'file4', 'file5.txt', 'noEmptyNestedFolder' ],
//           err : false
//         },
//       },
//       {
//         name : 'files, folders, symlinks',
//         path : 'tmp.tmp/filesList/noEmptyFolder2',
//         type : 'd',
//         folderContent :
//         [
//           {
//             path : [ 'c_file', 'b_file.txt' ],
//             type : 'f',
//             createResource : [ bufferData1, textData2 ]
//           },
//           {
//             path : [ 'link.txt', 'target.txt' ],
//             type : 'sf',
//             createResource : textData2
//           },
//           {
//             type : 'd',
//             path : 'folder'
//           }
//         ],
//         expected :
//         {
//           list : [ 'b_file.txt', 'c_file', 'folder', 'link.txt', 'target.txt' ],
//           err : false
//         }
//       }
//     ];


//   context.createTestResources( testChecks );

//   // regular tests
//   for( let testCheck of testChecks )
//   {
//     // join several test aspects together

//     let path = context.mergePath( testCheck.path ),
//       got = { list : void 0, err : void 0 };

//     test.description = testCheck.name;

//     try
//     {
//       got.list = _.filesList( path );
//       console.log( got.list );
//     }
//     catch ( err )
//     {
//       _.errLog( err );
//       got.err = !!err;
//     }
//     finally
//     {
//       got.err = !!got.err;
//       test.identical( got, testCheck.expected );
//     }
//   }
// };
//
// //

// function testDelaySample( test )
// {
//
//   debugger;
//
//   test.description = 'delay test';
//
//   var con = _.time.out( 1000 );
//
//   test.identical( 1,1 );
//
//   con.finally( function( ){ logger.log( '1000ms delay' ) } );
//
//   con.finally( _.routineSeal( _,_.time.out,[ 1000 ] ) );
//
//   con.finally( function( ){ logger.log( '2000ms delay' ) } );
//
//   con.finally( function( ){ test.identical( 1,1 ); } );
//
//   return con;
// }

//

function filesAreOnSameDevice( test )
{
  let context = this;
  let filesTree =
  {
    a :
    {
      b : 'b',
      c : 'c'
    },
    b :
    {
      d : 'd'
    },

    'softLink1' : [{ softLink : '../a/b'}],
    'softLink2' : [{ softLink : '../a/c'}],
    'softLink3' : [{ softLink : '../b/d'}],
  }

  let extraStats =
  {
    '/a/b' : { dev : 1 },
    '/a/c' : { dev : 1 },
    '/b/d' : { dev : 2 },
  }

  let provider = new _.FileProvider.Extract({ filesTree });
  _.props.supplement( provider.extraStats, extraStats );

  test.case = 'same path, does not exist'
  var testPath = '/a/b';
  var got = provider.filesAreOnSameDevice( testPath, testPath );
  test.identical( got, true );

  test.case = 'same path, exists'
  var testPath = '/a/b';
  var got = provider.filesAreOnSameDevice( testPath, testPath );
  test.identical( got, true );

  test.case = 'different paths, same device, paths do not exist'
  var testPath1 = '/a/b'
  var testPath2 = '/a/c';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, true );

  test.case = 'different paths, same device, paths exist'
  var testPath1 = '/a/b'
  var testPath2 = '/a/c';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );

  test.case = 'different devices, paths do not exist'
  var testPath1 = '/a/x';
  var testPath2 = '/b/x';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, false );

  test.case = 'different devices, paths exist'
  var testPath1 = '/a/b';
  var testPath2 = '/b/d';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, false );

  test.case = 'different devices, first path does not exist'
  var testPath1 = '/a/x';
  var testPath2 = '/b/d';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, false );

  test.case = 'different devices, second path does not exist'
  var testPath1 = '/a/b';
  var testPath2 = '/b/x';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, false );

  test.case = 'soft links on same device'
  var testPath1 = '/softLink1';
  var testPath2 = '/softLink2';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, true );

  test.case = 'soft links to different devices'
  var testPath1 = '/softLink1';
  var testPath2 = '/softLink3';
  var got = provider.filesAreOnSameDevice( testPath1, testPath2 );
  test.identical( got, false );
}

// --
// proto
// --

const Proto =
{

  name : 'Tools.files.Secondary.ss',
  silencing : 1,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    provider : _.FileProvider.HardDrive(),
    suiteTempPath : null,

    createTestFile,
    createTestSymLink,
    createTestHardLink,
    createTestResources,
    mergePath
  },

  tests :
  {
    // from l1/FileRoutines.s

    _fileOptionsGet,

    filesNewer,
    filesOlder,

    filesSpectre,
    filesSimilarity,

    // from l2/Partial.s

    filesSize,
    fileSize,

    // fileWrite,

    // fileRead,

    // fileReadSync,

    filesLink,

    // fileDelete,

    // from l3/SecondaryMixin.s

    filesAreUpToDate2,

    // etc

    // filesList,

    // testDelaySample,

    filesAreOnSameDevice

  }

};

const Self = wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
