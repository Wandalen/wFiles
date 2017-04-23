( function _File_individual_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

  var _ = wTools;

  _.include( 'wTesting' );

  var File = require( 'fs-extra' );
  var Path = require( 'path' )
  var toBuffer = require( 'typedarray-to-buffer' );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

var FileRecord = _.FileRecord;
var testRootDirectory = _.fileProvider.pathNativize( _.pathResolve( __dirname + '/../../../../tmp.tmp/sample/FilesIndividualTest' ) );

//

function createTestsDirectory( path, rmIfExists )
{
  // rmIfExists && File.existsSync( path ) && File.removeSync( path );
  // return File.mkdirsSync( path );
  if( rmIfExists && _.fileProvider.fileStat( path ) )
  _.fileProvider.fileDelete( path );
  return _.fileProvider.directoryMake( path );
}

//

function createInTD( path )
{
  return createTestsDirectory( _.pathJoin( testRootDirectory, path ) );
}

//

function createTestFile( path, data, decoding )
{
  var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
  // File.createFileSync( _.pathJoin( testRootDirectory, path ) );
  // dataToWrite && File.writeFileSync( _.pathJoin( testRootDirectory, path ), dataToWrite );
  _.fileProvider.fileWrite({ filePath : _.pathJoin( testRootDirectory, path ), data : dataToWrite })
}

//

function createTestSymLink( path, target, type, data )
{
  var origin,
    typeOrigin;

  if( target === void 0 )
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
    createTestFile( origin, data );
  }
  else if( 'sd' === type )
  {
    typeOrigin = 'dir';
    createInTD( origin );
  }
  else throw new Error( 'unexpected type' );

  path = _.pathJoin( testRootDirectory, path );
  origin = _.pathResolve( _.pathJoin( testRootDirectory, origin ) );

  // File.existsSync( path ) && File.removeSync( path );
  if( _.fileProvider.fileStat( path ) )
  _.fileProvider.fileDelete( path );
  // File.symlinkSync( origin, path, typeOrigin );
  _.fileProvider.linkSoft( path, origin );
}

//

function createTestHardLink( path, target, data )
{
  var origin;

  if( target === void 0 )
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
  createTestFile( origin, data );

  path = _.pathJoin( testRootDirectory, path );
  origin = _.pathResolve( _.pathJoin( testRootDirectory, origin ) );

  // File.existsSync( path ) && File.removeSync( path );
  if( _.fileProvider.fileStat( path ) )
  _.fileProvider.fileDelete( path );
  // File.linkSync( origin, path );
  _.fileProvider.linkHard( path, origin )
}

//

function createTestResources( cases, dir )
{
  if( !Array.isArray( cases ) ) cases = [ cases ];

  var l = cases.length,
    testCase,
    paths;

  while ( l-- )
  {
    testCase = cases[ l ];
    switch( testCase.type )
    {
      case 'f' :
        paths = Array.isArray( testCase.path ) ? testCase.path : [ testCase.path ];
        paths.forEach( ( path, i ) => {
          path = dir ? _.pathJoin( dir, path ) : path;
          if( testCase.createResource !== void 0 )
          {
            let res =
              ( Array.isArray( testCase.createResource ) && testCase.createResource[i] ) || testCase.createResource;
            createTestFile( path, res );
          }
          else
          createTestFile( path );
        } );
        break;

      case 'd' :
        paths = Array.isArray( testCase.path ) ? testCase.path : [ testCase.path ];
        paths.forEach( ( path, i ) =>
        {
          path = dir ? _.pathJoin( dir, path ) : path;
          createInTD( path );
          if ( testCase.folderContent )
          {
            var res = Array.isArray( testCase.folderContent ) ? testCase.folderContent : [ testCase.folderContent ];
            createTestResources( res, path );
          }
        } );
        break;

      case 'sd' :
      case 'sf' :
        var path, target;
        if( Array.isArray( testCase.path ) )
        {
          path = dir ? _.pathJoin( dir, testCase.path[0] ) : testCase.path[0];
          target = dir ? _.pathJoin( dir, testCase.path[1] ) : testCase.path[1];
        }
        else
        {
          path = dir ? _.pathJoin( dir, testCase.path ) : testCase.path;
          target = dir ? _.pathJoin( dir, testCase.linkTarget ) : testCase.linkTarget;
        }
        createTestSymLink( path, target, testCase.type, testCase.createResource );
        break;
      case 'hf' :
        var path, target;
        if( Array.isArray( testCase.path ) )
        {
          path = dir ? _.pathJoin( dir, testCase.path[0] ) : testCase.path[0];
          target = dir ? _.pathJoin( dir, testCase.path[1] ) : testCase.path[1];
        }
        else
        {
          path = dir ? _.pathJoin( dir, testCase.path ) : testCase.path;
          target = dir ? _.pathJoin( dir, testCase.linkTarget ) : testCase.linkTarget;
        }
        createTestHardLink( path, target, testCase.createResource );
        break;
    }
  }
}

//

function mergePath( path )
{
  return _.pathJoin( testRootDirectory, path );
}

// --
// test
// --

function directoryIs( test )
{
  // regular tests
  var testCases =
    [
      {
        name : 'simple directory',
        path : 'tmp.tmp/sample/', // dir
        type : 'd', // type for create test resource
        expected : true // test expected
      },
      {
        name : 'simple hidden directory',
        path : 'tmp.tmp/.hidden', // hidden dir,
        type : 'd',
        expected : true
      },
      {
        name : 'file',
        path : 'tmp.tmp/text.txt',
        type : 'f',
        expected : false
      },
      {
        name : 'symlink to directory',
        path : 'tmp.tmp/sample2',
        type : 'sd',
        expected : false
      },
      {
        name : 'symlink to file',
        path : 'tmp.tmp/text2.txt',
        type : 'sf',
        expected : false
      },
      {
        name : 'not existing path',
        path : 'tmp.tmp/notexisting.txt',
        type : 'na',
        expected : false
      }
    ];

  createTestResources( testCases );

  for( let testCase of testCases )
  {
    test.description = testCase.name;
    let got = !! _.fileProvider.directoryIs( _.pathJoin( testRootDirectory, testCase.path ) );
    test.identical( got , testCase.expected );
  }

};

function fileIs( test )
{
  // regular tests
  var testCases =
    [
      {
        name : 'simple directory',
        path : 'tmp.tmp/sample/', // dir
        type : 'd', // type for create test resource
        expected : false // test expected
      },
      {
        name : 'simple hidden file',
        path : 'tmp.tmp/.hidden.txt', // hidden dir,
        type : 'f',
        expected : true
      },
      {
        name : 'file',
        path : 'tmp.tmp/text.txt',
        type : 'f',
        expected : true
      },
      {
        name : 'symlink to directory',
        path : 'tmp.tmp/sample2',
        type : 'sd',
        expected : false
      },
      {
        name : 'symlink to file',
        path : 'tmp.tmp/text2.txt',
        type : 'sf',
        expected : false
      },
      {
        name : 'not existing path',
        path : 'tmp.tmp/notexisting.txt',
        type : 'na',
        expected : false
      }
    ];

  createTestResources( testCases );

  for( let testCase of testCases )
  {
    test.description = testCase.name;
    let got = !! _.fileProvider.fileIsTerminal( _.pathJoin( testRootDirectory, testCase.path ) );
    test.identical( got , testCase.expected );
  }

};

function fileSymbolicLinkIs( test )
{
  // regular tests
  var testCases =
    [
      {
        name : 'simple directory',
        path : 'tmp.tmp/sample/', // dir
        type : 'd', // type for create test resource
        expected : false // test expected
      },
      {
        name : 'simple hidden file',
        path : 'tmp.tmp/.hidden.txt', // hidden dir,
        type : 'f',
        expected : false
      },
      {
        name : 'file',
        path : 'tmp.tmp/text.txt',
        type : 'f',
        expected : false
      },
      {
        name : 'symlink to directory',
        path : 'tmp.tmp/sample2',
        type : 'sd',
        expected : true
      },
      {
        name : 'symlink to file',
        path : 'tmp.tmp/text2.txt',
        type : 'sf',
        expected : true
      },
      {
        name : 'not existing path',
        path : 'tmp.tmp/notexisting.txt',
        type : 'na',
        expected : false
      }
    ];

  createTestResources( testCases );

  for( let testCase of testCases )
  {
    test.description = testCase.name;
    let got = !! _.fileProvider.fileIsSoftLink( _.pathJoin( testRootDirectory, testCase.path ) );
    test.identical( got , testCase.expected );
  }

};

//

function _fileOptionsGet( test ) {
  var defaultContextObj =
    {
      defaults :
      {
        filePath : null,
        sync : null
      }
    },
    options1 =
      {
        sync : 0
      },
    wrongOptions =
      {
        filePath : 'path',
        sync : 0,
        extraOptions : 1
      },
    path1 = '',
    path2 = '/sample/tmp.tmp',
    path3 = '/ample/temp.txt',
    path4 = { filePath : 'some/abc', sync : 1 },
    expected2 =
      {
        filePath : '/sample/tmp.tmp',
        sync : 1
      },
    expected3 =
    {
      filePath : '/ample/temp.txt',
      sync : 0
    },
    expected4 = path4;

  test.description = 'non empty path';
  var got = _.fileProvider._fileOptionsGet.call( defaultContextObj, path2 );
  test.identical( got , expected2 );

  test.description = 'non empty path, call with options';
  var got = _.fileProvider._fileOptionsGet.call( defaultContextObj, path3, options1 );
  test.identical( got , expected3 );

  test.description = 'path is object';
  var got = _.fileProvider._fileOptionsGet.call( defaultContextObj, path4, options1 );
  test.identical( got , expected4 );

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider._fileOptionsGet.call( defaultContextObj );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider._fileOptionsGet.call( defaultContextObj, path2, options1, {} );
    } );

    test.description = 'empty path';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider._fileOptionsGet.call( defaultContextObj, path1 );
    } );

    test.description = 'extra options ';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider._fileOptionsGet.call( defaultContextObj, path3, wrongOptions );
    } );
  }
};

//

function fileWrite( test )
{
  var fileOptions =
    {
      filePath : null,
      data : '',
      append : false,
      sync : true,
      force : true,
      silentError : false,
      verbosity : false,
      clean : false,
    },
    defReadOptions =
    {
      encoding : 'utf8'
    },
    textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] );


  // regular tests
  var testCases =
    [
      {
        name : 'write empty text file',
        data : '',
        path : 'tmp.tmp/text1.txt',
        expected :
        {
          instance : false,
          content : '',
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'write text to file',
        data : textData1,
        path : 'tmp.tmp/text2.txt',
        expected :
        {
          instance : false,
          content : textData1,
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'append text to existing file',
        data :
        {
          filePath : 'tmp.tmp/text3.txt',
          data : textData2,
          append : true,
          sync : true,
          force : false,
          silentError : false,
          verbosity : true,
          clean : false,
        },
        path : 'tmp.tmp/text3.txt',
        createResource : textData1,
        expected :
        {
          instance : false,
          content : textData1 + textData2,
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'rewrite existing file',
        data :
        {
          filePath : 'tmp.tmp/text4.txt',
          data : textData2,
          append : false,
          sync : true,
          force : false,
          silentError : false,
          verbosity : true,
          clean : false,
        },
        path : 'tmp.tmp/text4.txt',
        createResource : textData1,
        expected :
        {
          instance : false,
          content : textData2,
          exist : true
        },
        readOptions : defReadOptions
      },

      {
        name : 'force create unexisting path file',
        data :
        {
          filePath : 'tmp.tmp/unexistingDir1/unexsitingDir2/text5.txt',
          data : textData2,
          append : false,
          sync : true,
          force : true,
          silentError : false,
          verbosity : true,
          clean : false,
        },
        path : 'tmp.tmp/unexistingDir1/unexsitingDir2/text5.txt',
        expected :
        {
          instance : false,
          content : textData2,
          exist : true
        },
        readOptions : defReadOptions
      },

      {
        name : 'write file async',
        data :
        {
          filePath : 'tmp.tmp/text6.txt',
          data : textData2,
          append : false,
          sync : false,
          force : true,
          silentError : false,
          verbosity : true,
          clean : false,
        },
        path : 'tmp.tmp/text6.txt',
        expected :
        {
          instance : true,
          content : textData2,
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'create file and write buffer data',
        data :
        {
          filePath : 'tmp.tmp/data9',
          data : bufferData1,
          append : false,
          sync : true,
          force : false,
          silentError : false,
          verbosity : false,
          clean : false,
        },
        path : 'tmp.tmp/data9',
        expected :
        {
          instance : false,
          content : bufferData1,
          exist : true
        },
        readOptions : void 0
      },
      {
        name : 'append buffer data to existing file',
        data :
        {
          filePath : 'tmp.tmp/data9',
          data : bufferData2,
          append : true,
          sync : true,
          force : false,
          silentError : false,
          verbosity : false,
          clean : false,
        },
        path : 'tmp.tmp/data9',
        createResource : bufferData1,
        expected :
        {
          instance : false,
          content : Buffer.concat( [ bufferData1, bufferData2 ] ),
          exist : true
        },
        readOptions : void 0
      },
      {
        name : 'append buffer data to existing file async',
        data :
        {
          filePath : 'tmp.tmp/data9',
          data : bufferData1,
          append : true,
          sync : false,
          force : false,
          silentError : false,
          verbosity : false,
          clean : false,
        },
        path : 'tmp.tmp/data9',
        createResource : bufferData2,
        expected :
        {
          instance : true,
          content : Buffer.concat( [ bufferData2, bufferData1 ] ),
          exist : true
        },
        readOptions : void 0
      },
    ];


  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together
    let got =
      {
        instance : null,
        content : null,
        exist : null
      },
      path = _.pathJoin( testRootDirectory, testCase.path );

    // clear
    // File.existsSync( path ) && File.removeSync( path );
    if( _.fileProvider.fileStat( path ) )
    _.fileProvider.fileDelete( path );

    // prepare to write if need
    testCase.createResource && createTestFile( testCase.path, testCase.createResource );


    var writeMode = testCase.data.append ? 'append' : 'rewrite';
    let gotFW = typeof testCase.data === 'object'
      ? ( testCase.data.filePath = mergePath( testCase.data.filePath ) ) && _.fileProvider.fileWrite({ filePath :  path, writeMode : writeMode,sync : testCase.data.sync, data : testCase.data.data })
      : _.fileProvider.fileWrite({ filePath :  path, data : testCase.data })

    // fileWtrite must returns wConsequence
    got.instance = gotFW instanceof wConsequence;

    path = _.fileProvider.pathNativize( path );

    if ( testCase.data && testCase.data.sync === false )
    {
      gotFW.got( ( ) =>
      {
        // recorded file should exists
        // got.exist = File.existsSync( path );
        got.exist = !!_.fileProvider.fileStat( path );
        // check content of created file.
        got.content = File.readFileSync( path, testCase.readOptions )
        test.description = testCase.name;
        test.identical( got, testCase.expected );

      } );
      continue;
    }

    // recorded file should exists
    // got.exist = File.existsSync( path );
    got.exist = !!_.fileProvider.fileStat( path );
    // check content of created file.
    got.content = File.readFileSync( path, testCase.readOptions )
    test.description = testCase.name;
    test.identical( got, testCase.expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWrite( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWrite( 'temp/sample.txt', 'hello', 'world' );
    } );

    test.description = 'path is not string';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWrite( 3, 'hello' );
    } );

    test.description = 'passed unexpected property in options';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWrite( { filePath : 'temp/some.txt', data : 'hello', parentDir : './work/project' } );
    } );

    test.description = 'data is not string or buffer';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWrite( { filePath : 'temp/some.txt', data : { count : 1 } } );
    } );
  }

};

function fileWriteJson( test )
{
  var defReadOptions =
    {
      encoding : 'utf8'
    },
    dataToJSON1 = [ 1, 'a', { b : 34 } ],
    dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] },
    dataToJSON3 = '{ "a" : "3" }';

  // regular tests
  var testCases =
    [
      {
        name : 'write empty JSON string file',
        data : '',
        path : 'tmp.tmp/data1.json',
        expected :
        {
          instance : false,
          content : '',
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'write array to file',
        data : dataToJSON1,
        path : 'tmp.tmp/data1.json',
        expected :
        {
          instance : false,
          content : dataToJSON1,
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'write object using options',
        data :
        {
          filePath : 'tmp.tmp/data2.json',
          data : dataToJSON2,
        },
        path : 'tmp.tmp/data2.json',
        expected :
        {
          instance : false,
          content : dataToJSON2,
          exist : true
        },
        readOptions : defReadOptions
      },
      {
        name : 'write jason string',
        data :
        {
          filePath : 'tmp.tmp/data3.json',
          data : dataToJSON3,
        },
        path : 'tmp.tmp/data3.json',
        expected :
        {
          instance : false,
          content : dataToJSON3,
          exist : true
        },
        readOptions : defReadOptions
      }
    ];


  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together
    let got =
      {
        instance : null,
        content : null,
        exist : null
      },
      path = _.pathJoin( testRootDirectory, testCase.path );

    // clear
    File.existsSync( path ) && File.removeSync( path );

    let gotFW = testCase.data.filePath !== void 0
      ? ( testCase.data.filePath = mergePath( testCase.data.filePath ) ) && _.fileProvider.fileWriteJson( testCase.data )
      : _.fileProvider.fileWriteJson( path, testCase.data );

    // fileWtrite must returns wConsequence
    got.instance = gotFW instanceof wConsequence;

    // recorded file should exists
    got.exist = !!_.fileProvider.fileStat( path );
    // got.exist = File.existsSync( path );

    // check content of created file.
    got.content = JSON.parse( _.fileProvider.fileRead( path, testCase.readOptions ) );

    test.description = testCase.name;
    test.identical( got, testCase.expected );
  }

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWriteJson( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWriteJson( 'temp/sample.txt', { a : 'hello' }, { b : 'world' } );
    } );

    test.description = 'path is not string';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWriteJson( 3, 'hello' );
    } );

    test.description = 'passed unexpected property in options';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWriteJson( { filePath : 'temp/some.txt', data : 'hello', parentDir : './work/project' } );
    } );
  }
};

//

function fileRead( test )
{
  var wrongReadOptions0 =
    {

      sync : 1,
      wrap : 0,
      returnRead : 0,
      silent : 0,

      filePath : 'tmp.tmp/text2.txt',
      filePath : 'tmp.tmp/text2.txt',
      name : null,
      encoding : 'utf8',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },
    fileReadOptions0 =
    {

      sync : 0,
      wrap : 0,
      returnRead : 0,
      //silent : 0,

      filePath : null,
      name : null,
      encoding : 'utf8',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    fileReadOptions1 =
    {

      sync : 1,
      wrap : 0,
      returnRead : 1,
      //silent : 0,

      filePath : null,
      name : null,
      encoding : 'utf8',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    fileReadOptions2 =
    {

      sync : 0,
      wrap : 0,
      returnRead : 0,
      //silent : 0,

      filePath : null,
      name : null,
      encoding : 'arraybuffer',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    fileReadOptions3 =
    {

      sync : 1,
      wrap : 0,
      returnRead : 1,
      //silent : 0,

      filePath : null,
      name : null,
      encoding : 'arraybuffer',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    fileReadOptions4 =
    {

      sync : 0,
      wrap : 0,
      returnRead : 0,
      //silent : 0,

      filePath : null,
      name : null,
      encoding : 'json',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },
    fileReadOptions5 =
    {

      sync : 1,
      wrap : 0,
      returnRead : 1,
      //silent : 0,

      filePath : null,
      name : null,
      encoding : 'json',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),
    dataToJSON1 = [ 1, 'a', { b : 34 } ],
    dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };

  // regular tests

  var testCases =
    [
      {
        name : 'read empty text file',
        data : '',
        path : 'tmp.tmp/rtext10.txt',
        expected :
        {
          error : null,
          content : '',
        },
        createResource : '',
        readOptions : fileReadOptions0
      },
      {
        name : 'read text from file',
        createResource : textData1,
        path : 'tmp.tmp/text20.txt',
        expected :
        {
          error : null,
          content : textData1,
        },
        readOptions : fileReadOptions0
      },
      {
        name : 'read text from file synchronously',
        createResource : textData2,
        path : 'tmp.tmp/text30.txt',
        expected :
        {
          error : null,
          content : textData2,
        },
        readOptions : fileReadOptions1
      },
      {
        name : 'read buffer from file',
        createResource : bufferData1,
        path : 'tmp.tmp/data99',
        expected :
        {
          error : null,
          content : bufferData1,
        },
        readOptions : fileReadOptions2
      },

      {
        name : 'read buffer from file synchronously',
        createResource : bufferData2,
        path : 'tmp.tmp/data011',
        expected :
        {
          error : null,
          content : bufferData2,
        },
        readOptions : fileReadOptions3
      },

      {
        name : 'read json from file',
        createResource : dataToJSON1,
        path : 'tmp.tmp/jason10.json',
        expected :
        {
          error : null,
          content : dataToJSON1,
        },
        readOptions : fileReadOptions4
      },
      {
        name : 'read json from file synchronously',
        createResource : dataToJSON2,
        path : 'tmp.tmp/json20.json',
        expected :
        {
          error : null,
          content : dataToJSON2,
        },
        readOptions : fileReadOptions5
      },
    ];



  // regular tests
  for( let testCase of testCases )
  {
    ( function ( testCase )
    {
      console.log( '----------->' + testCase.name );
      // join several test aspects together
      let got =
        {
          error : null,
          content : null
        },
        path = mergePath( testCase.path );

      // clear
      File.existsSync( path ) && File.removeSync( path );

      // prepare to write if need
      testCase.createResource !== undefined
      && createTestFile( testCase.path, testCase.createResource, testCase.readOptions.encoding );

      testCase.readOptions.filePath = path;
      testCase.readOptions.onBegin = function( err, data )
      {
        got.error = err;
      };
      testCase.readOptions.onError = function( err, data )
      {
        got.error = err;
      };
      testCase.readOptions.onEnd = function( err, fileContent )
      {
        got.error = err;

        // check content of read file.
        // +++ have a look om _.bufferTypedIs _.bufferRawIs _.bufferNodeIs
        if( fileContent instanceof ArrayBuffer )
        {
          debugger;
          //fileContent = Buffer.from( fileContent );
          fileContent = toBuffer( fileContent );
        }
        got.content = fileContent;

        test.description = testCase.name;
        test.identical( got, testCase.expected );

      };

      let gotFR = _.fileProvider.fileRead( testCase.readOptions );
    } )( _.cloneJust( testCase ) );

  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileRead( );
    } );


    test.description = 'passed unexpected property in options';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileRead( wrongReadOptions0 );
    } );

  }

};

//

function fileReadSync( test )
{

  var wrongReadOptions0 =
    {

      silent : 0,

      filePath : 'tmp.tmp/text2.txt',
      filePath : 'tmp.tmp/text2.txt',
      encoding : 'utf8',
    },

    fileReadOptions0 =
    {

      wrap : 0,
      //silent : 0,
      returnRead : 1,

      filePath : null,
      name : null,
      encoding : 'utf8',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    fileReadOptions1 =
    {

      wrap : 0,
      //silent : 0,
      returnRead : 1,

      filePath : null,
      name : null,
      encoding : 'utf8',

      onBegin : null,
      onEnd : null,
      onError : null,

      advanced : null,

    },

    fileReadOptions2 =
    {

      wrap : 0,
      //silent : 0,
      returnRead : 1,

      filePath : null,
      encoding : 'arraybuffer',

      onBegin : null,
      onEnd : null,
      onError : null,

    },

    fileReadOptions3 =
    {

      // sync : 0,
      wrap : 0,
      returnRead : 1,
      //silent : 0,

      filePath : null,
      encoding : 'arraybuffer',

      onBegin : null,
      onEnd : null,
      onError : null,

    },

    fileReadOptions4 =
    {

      wrap : 0,
      //silent : 0,
      returnRead : 1,

      filePath : null,
      name : null,
      encoding : 'json',

      onBegin : null,
      onEnd : null,
      onError : null,

    },
    fileReadOptions5 =
    {

      wrap : 0,
      //silent : 0,
      returnRead : 1,

      filePath : null,
      name : null,
      encoding : 'json',

      onBegin : null,
      onEnd : null,
      onError : null,

    },

    textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),
    dataToJSON1 = [ 1, 'a', { b : 34 } ],
    dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };


  // regular tests
  var testCases =
    [
      {
        name : 'read empty text file',
        data : '',
        path : 'tmp.tmp/rtext1.txt',
        expected :
        {
          error : null,
          content : '',
        },
        createResource : '',
        readOptions : fileReadOptions0
      },
      {
        name : 'read text from file',
        createResource : textData1,
        path : 'tmp.tmp/text2.txt',
        expected :
        {
          error : null,
          content : textData1,
        },
        readOptions : fileReadOptions0
      },
      {
        name : 'read text from file 2',
        createResource : textData2,
        path : 'tmp.tmp/text3.txt',
        expected :
        {
          error : null,
          content : textData2,
        },
        readOptions : fileReadOptions1
      },
      {
        name : 'read buffer from file',
        createResource : bufferData1,
        path : 'tmp.tmp/data0',
        expected :
        {
          error : null,
          content : bufferData1,
        },
        readOptions : fileReadOptions2
      },

      {
        name : 'read buffer from file 2',
        createResource : bufferData2,
        path : 'tmp.tmp/data2',
        expected :
        {
          error : null,
          content : bufferData2,
        },
        readOptions : fileReadOptions3
      },

      {
        name : 'read json from file',
        createResource : dataToJSON1,
        path : 'tmp.tmp/jason1.json',
        expected :
        {
          error : null,
          content : dataToJSON1,
        },
        readOptions : fileReadOptions4
      },
      {
        name : 'read json from file 2',
        createResource : dataToJSON2,
        path : 'tmp.tmp/json2.json',
        expected :
        {
          error : null,
          content : dataToJSON2,
        },
        readOptions : fileReadOptions5
      },
    ];



  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together
    let path = mergePath( testCase.path );

    // clear
    // File.existsSync( path ) && File.removeSync( path );
    if( _.fileProvider.fileStat( path ) )
    _.fileProvider.fileDelete( path );

    // prepare to write if need
    testCase.createResource !== undefined
    && createTestFile( testCase.path, testCase.createResource, testCase.readOptions.encoding );

    let got = _.fileProvider.fileReadSync( path, testCase.readOptions );

    if( got instanceof ArrayBuffer )
    {
      //got = Buffer.from( got );
      got = toBuffer( got );
    }

    test.description = testCase.name;
    test.identical( got, testCase.expected.content );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileReadSync( );
    } );

    test.description = 'passed unexpected property in options';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileReadSync( wrongReadOptions0 );
    } );

    test.description = 'filePath is not defined';
    test.shouldThrowErrorSync( function( )
    {
     _.fileProvider.fileReadSync( { encoding : 'json' } );
    } );

  }

};

function fileReadJson( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    dataToJSON1 = [ 1, 'a', { b : 34 } ],
    dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };


  // regular tests
  var testCases =
    [
      {
        name : 'try to load empty text file as json',
        data : '',
        path : 'tmp.tmp/rtext1.txt',
        expected :
        {
          error : true,
          content : void 0
        },
        createResource : ''
      },
      {
        name : 'try to read non json string as json',
        createResource : textData1,
        path : 'tmp.tmp/text2.txt',
        expected :
        {
          error : true,
          content : void 0
        }
      },
      {
        name : 'try to parse buffer as json',
        createResource : bufferData1,
        path : 'tmp.tmp/data0',
        expected :
        {
          error : true,
          content : void 0
        }
      },
      {
        name : 'read json from file',
        createResource : dataToJSON1,
        path : 'tmp.tmp/jason1.json',
        encoding : 'json',
        expected :
        {
          error : null,
          content : dataToJSON1
        }
      },
      {
        name : 'read json from file 2',
        createResource : dataToJSON2,
        path : 'tmp.tmp/json2.json',
        encoding : 'json',
        expected :
        {
          error : null,
          content : dataToJSON2
        }
      }
    ];



  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together
    let got =
      {
        error : null,
        content : void 0
      },
      path = mergePath( testCase.path );

    // clear
    // File.existsSync( path ) && File.removeSync( path );
    if( _.fileProvider.fileStat( path ) )
    _.fileProvider.fileDelete( path );

    // prepare to write if need
    testCase.createResource !== undefined
      && createTestFile( testCase.path, testCase.createResource , testCase.encoding );

    try
    {
      got.content = _.fileProvider.fileReadJson( path );
    }
    catch ( err )
    {
      got.error = true;
    }


    test.identical( got, testCase.expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileReadJson( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileReadJson( 'tmp.tmp/tmp.tmp.json', {} );
    } );
  }

};

function filesSame( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),

  testCases = [

    {
      name : 'same file with empty content',
      path : [ 'tmp.tmp/filesSame/sample.txt', 'tmp.tmp/filesSame/sample.txt' ],
      type : 'f',
      createResource : '',
      expected : false
    },
    {
      name : 'two different files with empty content',
      path : [ 'tmp.tmp/filesSame/hidden.txt', 'tmp.tmp/filesSame/nohidden.txt' ],
      type : 'f',
      createResource : '',
      expected : false
    },
    {
      name : 'same text file',
      path : [ 'tmp.tmp/filesSame/same_text.txt', 'tmp.tmp/filesSame/same_text.txt' ],
      type : 'f',
      createResource : textData1,
      expected : true
    },
    {
      name : 'files with identical text content',
      path : [ 'tmp.tmp/filesSame/identical_text1.txt', 'tmp.tmp/filesSame/identical_text2.txt' ],
      type : 'f',
      createResource : textData1,
      expected : true
    },
    {
      name : 'files with identical binary content',
      path : [ 'tmp.tmp/filesSame/identical2', 'tmp.tmp/filesSame/identical2.txt' ],
      type : 'f',
      createResource : bufferData1,
      expected : true
    },
    {
      name : 'files with non identical text content',
      path : [ 'tmp.tmp/filesSame/identical_text3.txt', 'tmp.tmp/filesSame/identical_text4.txt' ],
      type : 'f',
      createResource : [ textData1, textData2 ],
      expected : false
    },
    {
      name : 'files with non identical binary content',
      path : [ 'tmp.tmp/filesSame/noidentical1', 'tmp.tmp/filesSame/noidentical2' ],
      type : 'f',
      createResource : [ bufferData1, bufferData2 ],
      expected : false
    },
    {
      name : 'file and symlink to file',
      path : [ 'tmp.tmp/filesSame/testsymlink', 'tmp.tmp/filesSame/testfile' ],
      type : 'sf',
      createResource :  bufferData1,
      expected : true
    },
    {
      name : 'not existing path',
      path : [ 'tmp.tmp/filesSame/nofile1', 'tmp.tmp/filesSame/noidentical2' ],
      type : 'na',
      expected : false
    }
  ];

  createTestResources( testCases )

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let file1 = _.pathResolve( mergePath( testCase.path[0] ) ),
      file2 = _.pathResolve( mergePath( testCase.path[1] ) ),
      got;

    test.description = testCase.name;

    try
    {
      got = _.fileProvider.filesSame({ ins1 :  file1, ins2 : file2, usingTime : testCase.checkTime, usingSymlink : 1 } );
    }
    catch( err ) {
      console.log( err );
    }
    test.identical( got, testCase.expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.filesSame( );
    } );
  }

  // custom cases

  test.description = 'two file records asociated with two regular files';
  var path1 =  'tmp.tmp/filesSame/rfile1',
    path2 =   'tmp.tmp/filesSame/rfile2';

  createTestFile( path1, textData1 );
  createTestFile( path2, textData1 );

  path1 = _.pathResolve( mergePath( path1 ) ),
  path2 = _.pathResolve( mergePath( path2 ) );

  var file1 = _.fileProvider.fileRecord( path1 ),
    file2 = _.fileProvider.fileRecord( path2 );

  try
  {
    got = _.fileProvider.filesSame( { ins1 : file1, ins2 : file2 } );
  }
  catch( err ) {
    console.log( err );
  }
  test.identical( got, true );

  test.description = 'file record asociated with two symlinks for different files with same content';
  var path1 =  'tmp.tmp/filesSame/lrfile1',
    path2 =  'tmp.tmp/filesSame/lrfile2';

  createTestSymLink( path1, void 0, 'sf', textData1 );
  createTestSymLink( path2, void 0, 'sf', textData1 );

  path1 = _.pathResolve( mergePath( path1 ) ),
    path2 = _.pathResolve( mergePath( path2 ) );

  var file1 = _.fileProvider.fileRecord( path1 ),
    file2 = _.fileProvider.fileRecord( path2 );

  try
  {
    got = _.fileProvider.filesSame( { ins1 : file1, ins2 : file2, usingSymlink : 1 } );
  }
  catch( err ) {
    console.log( err );
  }
  test.identical( got, true );

  test.description = 'file record asociated with regular file, and symlink with relative target value';
  var path1 =  'tmp.tmp/filesSame/rfile3',
    path2 =  'tmp.tmp/filesSame/rfile4',
    link =  'tmp.tmp/filesSame/lfile4';

  createTestFile( path1, textData1 );
  createTestFile( path2, textData1 );

  path1 = _.pathResolve( mergePath( path1 ) );
  link = _.pathResolve( mergePath( link ) );
  path2 = mergePath( path2 );

  var file1 = _.fileProvider.fileRecord( path1 );
  // File.symlinkSync( path2, link, 'file' );
  _.fileProvider.linkSoft( link, path2 );
  try
  {
    got = _.fileProvider.filesSame( { ins1 : file1, ins2 : link } );
  }
  catch( err ) {
    console.log( err );
  }
  test.identical( got, true );

  // time check
    test.description = 'files with identical content : time check';
    var expected = false,
      file1 = _.pathResolve( mergePath( 'tmp.tmp/filesSame/identical3' ) ),
      file2 = _.pathResolve( mergePath( 'tmp.tmp/filesSame/identical4' ) ),
      con, got;

    createTestFile( file1 );
    con = _.timeOut( 50);
    con.doThen( ( ) => createTestFile( file2 ) );
    con.doThen( ( ) =>
    {
      try
      {
        got = _.fileProvider.filesSame( file1, file2, true );
      }
      catch( err ) {}
      test.identical( got, expected );
    } );

    return con;
};

function filesLinked( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),

    testCases = [
      {
        name : 'same text file',
        path : [ 'tmp.tmp/filesLinked/same_text.txt', 'tmp.tmp/filesLinked/same_text.txt' ],
        type : 'f',
        createResource : textData1,
        expected : true
      },
      {
        name : 'symlink to file with text content',
        path : [ 'tmp.tmp/filesLinked/identical_text1.txt', 'tmp.tmp/filesLinked/identical_text2.txt' ],
        type : 'sf',
        createResource : textData1,
        expected : false
      },
      {
        name : 'different files with identical binary content',
        path : [ 'tmp.tmp/filesLinked/identical1', 'tmp.tmp/filesLinked/identical2' ],
        type : 'f',
        createResource : bufferData1,
        expected : false
      },
      {
        name : 'symlink to file with  binary content',
        path : [ 'tmp.tmp/filesLinked/identical3', 'tmp.tmp/filesLinked/identical4' ],
        type : 'sf',
        createResource : bufferData1,
        expected : false
      },
      {
        name : 'hardlink to file with  binary content',
        path : [ 'tmp.tmp/filesLinked/identical5', 'tmp.tmp/filesLinked/identical6' ],
        type : 'hf',
        createResource : bufferData1,
        expected : true
      },
      {
        name : 'hardlink to file with  text content : file record',
        path : [ 'tmp.tmp/filesLinked/identical7', 'tmp.tmp/filesLinked/identical8' ],
        type : 'hf',
        fileRecord : true,
        createResource : textData1,
        expected : true
      },
      // {
      //   name : 'not existing path',
      //   path : [ 'tmp.tmp/filesLinked/nofile1', 'tmp.tmp/filesLinked/noidentical2' ],
      //   type : 'na',
      //   expected : false
      // }
    ];

  createTestResources( testCases )

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let file1 = _.pathResolve( mergePath( testCase.path[ 0 ] ) ),
      file2 = _.pathResolve( mergePath( testCase.path[ 1 ] ) ),
      got;

    if( testCase.fileRecord )
    {
      file1 = _.fileProvider.fileRecord( file1 );
      file2 = _.fileProvider.fileRecord( file2 );
    }

    test.description = testCase.name;

    try
    {
      got = _.fileProvider.filesLinked( file1, file2 );
    }
    catch ( err ) {}
    finally
    {
      test.identical( got, testCase.expected );
    }
  }

  // exception tests

  // if( Config.debug )
  // {
  //   test.description = 'missed arguments';
  //   test.shouldThrowErrorSync( function( )
  //   {
  //     _.fileProvider.linkHarded( );
  //   } );
  // }
};

function filesLink( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),

    testCases = [
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

  createTestResources( testCases );

  function checkHardLink( link, src )
  {
    link = _.pathResolve( link );
    src = _.pathResolve( src );
    // var statLink = File.lstatSync( link ),
    var statLink = _.fileProvider.fileStat({ filePath : link, resolvingSoftLink : 0 }),
      // statSource = File.lstatSync( src );
      statSource = _.fileProvider.fileStat({ filePath : src, resolvingSoftLink : 0 })

    if ( !statLink || !statSource ) return false; // both files should be exists
    if ( statSource.nlink !== 2 ) return false;
    if ( statLink.ino !== statSource.ino ) return false; // both names should be associated with same file on device.

    // File.unlinkSync( link );
    _.fileProvider.fileDelete( link );
    statSource = _.fileProvider.fileStat({ filePath : src, resolvingSoftLink : 0 });

    if ( statSource.nlink !== 1 ) return false;

    return true;
  }

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let file = Array.isArray( testCase.path) ? mergePath( testCase.path[0] ) : mergePath( testCase.path ),
      link = mergePath( testCase.link ),
      got = { result : false, isExists : false, ishard : false, err : false };

    test.description = testCase.name;

    try
    {
      got.result = _.fileProvider.linkHard({ pathDst :  link, pathSrc : file, sync : 1 });
      // got.isExists = File.existsSync(  _.pathResolve( link ) );
      got.isExists = !!_.fileProvider.fileStat(  _.pathResolve( link ) );
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
      test.identical( got, testCase.expected );
    }
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.linkHard( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.linkHard( 'tmp.tmp/filesLink/identical1', 'tmp.tmp/filesLink/same_text.txt', 'tmp.tmp/filesLink/same_text.txt' );
    } );

    test.description = 'argumetns is not string';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.linkHard( 34, {} );
    } );

    test.description = 'passed unexpected property';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.linkHard( {
        pathDst : 'tmp.tmp/fileHardlink/src1',
        pathSrc : 'tmp.tmp/fileHardlink/hard_text.txt',
        dir : 'tmp.tmp/fileHardlink'
      } );
    } );
  }

};

function filesNewer( test )
{
  var file1 = 'tmp.tmp/filesNewer/test1',
    file2 = 'tmp.tmp/filesNewer/test2',
    file3 = 'tmp.tmp/filesNewer/test3';

  createTestFile( file1, 'test1' );
  createTestFile( file2, 'test2' );

  file1 = mergePath( file1 );
  file2 = mergePath( file2 );

  file1 = _.fileProvider.pathNativize( file1 );
  file2 = _.fileProvider.pathNativize( file2 );

  test.description = 'two files created at different time';
  var got = _.filesNewer( file1, file2 );
  test.identical( got, file2 );

  var con = _.timeOut( 50 );
  con.doThen( ( ) =>
  {
    createTestFile( file3, 'test3' );
    file3 = mergePath( file3 );
    file3 = _.fileProvider.pathNativize( file3 );

    test.description = 'two files created at different time';
    var got = _.filesNewer( file1, file3 );
    test.identical( got, file3 );
  });

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.filesNewer( );
    } );

    test.description = 'type of arguments is not file.Stat or string';
    test.shouldThrowErrorSync( function( )
    {
      _.filesNewer( null, '/tmp.tmp/s.txt' );
    } );
  }

  return con;
};

function filesOlder( test )
{
  var file1 = 'tmp.tmp/filesNewer/test1',
    file2 = 'tmp.tmp/filesNewer/test2',
    file3 = 'tmp.tmp/filesNewer/test3';

  createTestFile( file1, 'test1' );
  createTestFile( file2, 'test2' );

  file1 = mergePath( file1 );
  file2 = mergePath( file2 );

  file1 = _.fileProvider.pathNativize( file1 );
  file2 = _.fileProvider.pathNativize( file2 );

  test.description = 'two files created at different time';
  var got = _.filesOlder( file1, file2 );
  test.identical( got, file1 );

  var con = _.timeOut( 50 );
  con.doThen( ( ) =>
  {
    createTestFile( file3, 'test3' );
    file3 = mergePath( file3 );
    file3 = _.fileProvider.pathNativize( file3 );
    test.description = 'two files created at different time';
    var got = _.filesOlder( file1, file3 );
    test.identical( got, file1 );
  });

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.filesOlder( );
    } );

    test.description = 'type of arguments is not file.Stat or string';
    test.shouldThrowErrorSync( function( )
    {
      _.filesOlder( null, '/tmp.tmp/s.txt' );
    } );
  }

  return con;
};

function filesSpectre( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',

    testCases = [

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
          L : 1,
          o : 4,
          r : 3,
          e : 5,
          m : 3,
          ' ' : 7,
          i : 6,
          p : 2,
          s : 4,
          u : 2,
          d : 2,
          l : 2,
          t : 5,
          a : 2,
          ',' : 1,
          c : 3,
          n : 2,
          g : 1,
          '.' : 1,
          length : 56
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
          A : 1,
          e : 3,
          n : 4,
          a : 3,
          o : 1,
          f : 1,
          u : 2,
          g : 1,
          i : 2,
          t : 1,
          m : 1,
          r : 1,
          s : 1,
          length : 26
        }
      }
    ];

  createTestResources( testCases )

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let path = _.pathResolve( mergePath( testCase.path ) ),
      got;

    test.description = testCase.name;

    try
    {
      got = _.filesSpectre( path );
    }
    catch( err )
    {
      _.errLogOnce( err );
    }
    test.identical( got, testCase.expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.filesSpectre( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.filesSpectre( 'tmp.tmp/filesSame/text1.txt', 'tmp.tmp/filesSame/text2.txt' );
    } );
  }
};

//

function filesSimilarity( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),

    testCases = [

      {
        name : 'two different files with empty content',
        path : [ 'tmp.tmp/filesSimilarity/empty1.txt', 'tmp.tmp/filesSimilarity/empty2.txt' ],
        type : 'f',
        createResource : '',
        expected : 1
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
        expected : 0.375
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

  createTestResources( testCases );

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let path1 = _.pathResolve( mergePath( testCase.path[0] ) ),
      path2 = _.pathResolve( mergePath( testCase.path[1] ) ),
      got;

    test.description = testCase.name;

    try
    {
      got = _.filesSimilarity( { src1 : path1, src2 : path2 });
    }
    catch( err )
    {
      _.errLog( err );
    }
    test.identical( got, testCase.expected );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.filesSimilarity( );
    } );
  }
};

function filesSize( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),
    testCases =
    [
      {
        name : 'empty file',
        path : 'tmp.tmp/filesSize/rtext1.txt',
        type : 'f',
        expected : 0,
        createResource : ''
      },
      {
        name : 'text file1',
        createResource : textData1,
        path : 'tmp.tmp/filesSize/text2.txt',
        type : 'f',
        expected : textData1.length
      },
      {
        name : 'text file 2',
        createResource : textData2,
        path : 'tmp.tmp/filesSize/text3.txt',
        type : 'f',
        expected : textData2.length
      },
      {
        name : 'file binary',
        createResource : bufferData1,
        path : 'tmp.tmp/filesSize/data1',
        type : 'f',
        expected : bufferData1.byteLength
      },
      {
        name : 'binary file 2',
        createResource : bufferData2,
        path : 'tmp.tmp/filesSize/data2',
        type : 'f',
        expected : bufferData2.byteLength
      },
      // {
      //   name : 'unexisting file',
      //   createResource : '',
      //   path : 'tmp.tmp/filesSize/data3',
      //   type : 'na',
      //   expected : 0
      // }
    ];

  createTestResources( testCases );

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let path = mergePath( testCase.path ),
      got;

    test.description = testCase.name;

    try
    {
      got = _.fileProvider.filesSize( path );
    }
    catch( err ) {}
    test.identical( got, testCase.expected );
  }

  var pathes = testCases.map( c => mergePath( c.path ) );
  var expected = testCases.reduce( ( pc, cc ) => { return pc + cc.expected; }, 0 );

  test.description = 'all paths together';
  var got = _.fileProvider.filesSize( pathes );
  test.identical( got, expected );

};

function fileSize( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),
    testCases =
      [
        {
          name : 'empty file',
          path : 'tmp.tmp/fileSize/rtext1.txt',
          type : 'f',
          expected : 0,
          createResource : ''
        },
        {
          name : 'text file1',
          createResource : textData1,
          path : 'tmp.tmp/fileSize/text2.txt',
          type : 'f',
          expected : textData1.length
        },
        {
          name : 'text file 2',
          createResource : textData2,
          path : 'tmp.tmp/fileSize/text3.txt',
          type : 'f',
          expected : textData2.length
        },
        {
          name : 'file binary',
          createResource : bufferData1,
          path : 'tmp.tmp/fileSize/data1',
          type : 'f',
          expected : bufferData1.byteLength
        },
        {
          name : 'binary file 2',
          createResource : bufferData2,
          path : 'tmp.tmp/fileSize/data2',
          type : 'f',
          expected : bufferData2.byteLength
        },
        // {
        //   name : 'unexisting file',
        //   createResource : '',
        //   path : 'tmp.tmp/filesSize/data3',
        //   type : 'na',
        //   expected : 0
        // }
      ];

  createTestResources( testCases );

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let path = mergePath( testCase.path ),
      got;

    test.description = testCase.name;

    try
    {
      got = _.fileProvider.fileSize( path );
    }
    catch( err ) {}
    test.identical( got, testCase.expected );
  }

  test.description = 'test onEnd callback : before';
  var path = mergePath( 'tmp.tmp/fileSize/data4' );
  _.fileProvider.fileWrite( { filePath : path, data : bufferData1+bufferData2 } );
  var got = _.fileProvider.fileSize( {
    filePath : path,
    // onEnd : ( size ) =>
    // {
    //   // test.description = 'test onEnd callback : after';
    //   // var expected = bufferData1.byteLength + bufferData2.byteLength;
    //   // test.identical( size, expected );
    // }
  } );

  test.description = 'test onEnd callback : after';
  var expected = bufferData1.byteLength + bufferData2.byteLength;
  test.identical( got, expected );

  _.fileProvider.fileWrite( { filePath : path, data : bufferData2, writeMode : 'append' } );

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileSize( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileSize( mergePath( 'tmp.tmp/fileSize/data2' ), mergePath( 'tmp.tmp/fileSize/data3' ) );
    } );

    test.description = 'path is not string';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileSize( { filePath : null } );
    } );

    test.description = 'passed unexpected property';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileSize( { filePath : mergePath( 'tmp.tmp/fileSize/data2' ), pathDir : mergePath( 'tmp.tmp/fileSize/data3' ) } );
    } );
  }

};


function fileDelete( test ) {
  var fileDelOptions =
    {
      filePath : null,
      force : 0,
      sync : 1,
    },

    textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] );


  // regular tests
  var testCases =
    [
      {
        name : 'delete single empty text file',
        createResource : '',
        type : 'f',
        path : 'tmp.tmp/fileDelete/text1.txt',
        expected :
        {
          exception : false,
          exist : false
        }
      },
      {
        name : 'delete single text file asynchronously',
        createResource : textData1,
        path : 'tmp.tmp/fileDelete/text2.txt',
        type : 'f',
        expected :
        {
          exception : false,
          exist : false
        },
        delOptions : {
          filePath : 'tmp.tmp/fileDelete/text2.txt',
          force : 0,
          sync : 0,
        }
      },
      {
        name : 'delete empty folder',
        type : 'd',
        path : 'tmp.tmp/fileDelete/emptyFolder',
        expected :
        {
          exception : false,
          exist : false
        }
      },
      {
        name : 'delete not empty folder : no force',
        type : 'd',
        path : 'tmp.tmp/fileDelete/noEmptyFolder',
        delOptions :
        {
          filePath : 'tmp.tmp/fileDelete/noEmptyFolder',
          force : 0
        },
        folderContent :
        {
          path : [ 'file1', 'file2.txt' ],
          type : 'f',
          createResource : [ bufferData1, textData2 ]
        },
        expected :
        {
          exception : true,
          exist : true
        },
      },

      {
        name : 'force delete not empty folder',
        type : 'd',
        folderContent :
        {
          path : [ 'file3', 'file4.txt' ],
          type : 'f',
          createResource : [ bufferData2, textData1 ]
        },
        path : 'tmp.tmp/fileDelete/noEmptyFolder2',
        expected :
        {
          exception : false,
          exist : false
        },
        delOptions : {
          filePath : null,
          force : 1,
          sync : 1,
        }
      },

      {
        name : 'force delete not empty folder : async',
        type : 'd',
        folderContent :
        {
          path : [ 'file5', 'file6.txt' ],
          type : 'f',
          createResource : [ bufferData2, textData1 ]
        },
        path : 'tmp.tmp/fileDelete/noEmptyFolder3',
        expected :
        {
          exception : false,
          exist : false
        },
        delOptions : {
          filePath : null,
          force : 1,
          sync : 0,
        }
      },
      {
        name : 'delete symlink',
        path : 'tmp.tmp/fileDelete/identical2',
        type : 'sf',
        createResource : bufferData1,
        expected :
        {
          exception : false,
          exist : false
        },
      }
    ];


  createTestResources( testCases );

  var counter = 0;
  // regular tests
  for( let testCase of testCases )
  {
    ( function ( testCase )
    {
      // join several test aspects together
      var got =
        {
          exception : false,
          exist : false,
        },
        path = mergePath( testCase.path ),
        continueFlag = false;
      path = _.fileProvider.pathNativize( path );
      try
      {
        let gotFD = typeof testCase.delOptions === 'object'
          ? ( testCase.delOptions.filePath = path ) && _.fileProvider.fileDelete( testCase.delOptions )
          : _.fileProvider.fileDelete( path );

        if( testCase.delOptions && !!testCase.delOptions.sync === false )
        {
          continueFlag = true;
          gotFD.got( ( err ) =>
          {
            // deleted file should  not exists
            got.exist = !!_.fileProvider.fileStat( path );

            // check exceptions
            got.exception = !!err;

            test.description = testCase.name;
            test.identical( got, testCase.expected );
          } );
        }
      }
      catch( err )
      {
        got.exception = !!err;
      }
      finally
      {
        got.exception = !!got.exception;
      }
      if ( !continueFlag )
      {
        // deleted file should not exists
        got.exist = !!_.fileProvider.fileStat( path );

        // check content of created file.
        test.description = testCase.name;
        test.identical( got, testCase.expected );
      }
    } )( _.cloneJust( testCase ) );
  }

  // exception tests

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileDelete( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileDelete( 'temp/sample.txt', fileDelOptions );
    } );

    test.description = 'path is not string';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileDelete( {
        filePath : null,
        force : 0,
        sync : 1,
      } );
    } );

    test.description = 'passed unexpected property in options';
    test.shouldThrowErrorSync( function( )
    {
      _.fileProvider.fileWrite( {
        filePath : 'temp/some.txt',
        force : 0,
        sync : 1,
        parentDir : './work/project'
      } );
    } );
  }
};

function filesList( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] );


  // regular tests
  var testCases =
    [
      {
        name : 'single file',
        createResource : textData1,
        type : 'f',
        path : 'tmp.tmp/filesList/text1.txt',
        expected :
        {
          list : [ 'text1.txt' ],
          err : false
        }
      },
      {
        name : 'empty folder',
        type : 'd',
        path : 'tmp.tmp/filesList/emptyFolder',
        expected :
        {
          list : [],
          err : false
        }
      },
      {
        name : 'folder with several files',
        type : 'd',
        path : 'tmp.tmp/filesList/noEmptyFolder',
        folderContent :
        [
          {
            path : [ 'file2', 'file1.txt' ],
            type : 'f',
            createResource : [ bufferData1, textData2 ]
          },
        ],
        expected :
        {
          list : [ 'file1.txt', 'file2' ],
          err : false
        },
      },
      {
        name : 'folder with several files and directories',
        type : 'd',
        path : 'tmp.tmp/filesList/noEmptyFolder1',
        folderContent :
        [
          {
            path : [ 'file4', 'file5.txt' ],
            type : 'f',
            createResource : [ bufferData1, textData2 ]
          },
          {
            type : 'd',
            path : 'noEmptyNestedFolder',
            folderContent :
            [
              {
                path : [ 'file6', 'file7.txt' ],
                type : 'f',
                createResource : [ bufferData2, textData2 ]
              },
            ]
          }
        ],
        expected :
        {
          list : [ 'file4', 'file5.txt', 'noEmptyNestedFolder' ],
          err : false
        },
      },
      {
        name : 'files, folders, symlinks',
        path : 'tmp.tmp/filesList/noEmptyFolder2',
        type : 'd',
        folderContent :
        [
          {
            path : [ 'c_file', 'b_file.txt' ],
            type : 'f',
            createResource : [ bufferData1, textData2 ]
          },
          {
            path : [ 'link.txt', 'target.txt' ],
            type : 'sf',
            createResource : textData2
          },
          {
            type : 'd',
            path : 'folder'
          }
        ],
        expected :
        {
          list : [ 'b_file.txt', 'c_file', 'folder', 'link.txt', 'target.txt' ],
          err : false
        }
      }
    ];


  createTestResources( testCases );

  // regular tests
  for( let testCase of testCases )
  {
    // join several test aspects together

    let path = mergePath( testCase.path ),
      got = { list : void 0, err : void 0 };

    test.description = testCase.name;

    try
    {
      got.list = _.filesList( path );
      console.log( got.list );
    }
    catch ( err )
    {
      _.errLog( err );
      got.err = !!err;
    }
    finally
    {
      got.err = !!got.err;
      test.identical( got, testCase.expected );
    }
  }
};

//

function filesAreUpToDate2( test )
{
  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    textData2 = ' Aenean non feugiat mauris',
    bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
    bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] );

  // regular tests
  var testCases =
    [
      {
        name : 'files is up to date',
        createFirst :
        {
          path : [ 'tmp.tmp/filesIsUpToDate1/file1', 'tmp.tmp/filesIsUpToDate1/file2.txt' ],
          type : 'f',
          createResource : [ bufferData1, textData1 ]
        },
        createSecond :
        {
          path : [ 'tmp.tmp/filesIsUpToDate1/file3', 'tmp.tmp/filesIsUpToDate1/file4.txt' ],
          type : 'f',
          createResource : [ bufferData2, textData2 ]
        },
        src : [ 'tmp.tmp/filesIsUpToDate1/file1', 'tmp.tmp/filesIsUpToDate1/file2.txt' ],
        dst : [ 'tmp.tmp/filesIsUpToDate1/file3', 'tmp.tmp/filesIsUpToDate1/file4.txt' ],
        expected : true
      },
      {
        name : 'files is not up to date',
        createFirst :
        {
          path : [ 'tmp.tmp/filesIsUpToDate2/file1', 'tmp.tmp/filesIsUpToDate2/file2.txt' ],
          type : 'f',
          createResource : [ bufferData1, textData1 ]
        },
        createSecond :
        {
          path : [ 'tmp.tmp/filesIsUpToDate2/file3', 'tmp.tmp/filesIsUpToDate2/file4.txt' ],
          type : 'f',
          createResource : [ bufferData2, textData2 ]
        },
        src : [ 'tmp.tmp/filesIsUpToDate2/file1', 'tmp.tmp/filesIsUpToDate2/file4.txt' ],
        dst : [ 'tmp.tmp/filesIsUpToDate2/file3', 'tmp.tmp/filesIsUpToDate2/file2.txt' ],
        expected : false
      },
    ];

/*
  function createWithDelay( fileLists, delay )
  {
    delay = delay || 0;
    var con = wConsequence( );
    setTimeout( function( )
    {
      createTestResources( fileLists );
      console.log( '--> files created second' );
      con.give( );
    }, delay );
    return con;
  }
*/

  var con = new wConsequence( ).give( );
  for( let tc of testCases )
  {
    ( function( tc )
    {
      console.log( 'tc : ' + tc.name );
      createTestResources( tc.createFirst );
      console.log( '--> files create first' );

      con.doThen( _.routineSeal( _,_.timeOut,[ 50 ] ) );
      con.doThen( _.routineSeal( null,createTestResources,[ tc.createSecond ] ) );
      con.doThen( _.routineSeal( console,console.log,[ '--> files created second' ] ) );

/*
      try
      {
        con = createWithDelay( tc.createSecond, 500 )
      }
      catch( err )
      {
        console.log( err );
      }
*/

      con.doThen( ( ) =>
      {
        test.description = tc.name;
        try
        {
          var got = _.fileProvider.filesAreUpToDate2
          ({
            src : tc.src.map( ( v ) => _.pathResolve( mergePath( v ) ) ),
            dst : tc.dst.map( ( v ) => _.pathResolve( mergePath( v ) ) )
          });
        }
        catch( err )
        {
          console.log( err );
        }
        test.identical( got, tc.expected );
      } );
    } )( _.cloneJust( tc ) );
  }
  return con;
};

//

function testDelaySample( test )
{

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

// --
// proto
// --

var Self =
{

  name : 'OtherFilesTest',
  sourceFilePath : sourceFilePath,
  verbosity : 0,

  tests :
  {


    directoryIs : directoryIs,
    fileIs : fileIs,
    fileSymbolicLinkIs : fileSymbolicLinkIs,

    _fileOptionsGet : _fileOptionsGet,

    fileWrite : fileWrite,
    fileWriteJson : fileWriteJson,

    fileRead : fileRead,

    fileReadSync : fileReadSync,
    fileReadJson : fileReadJson,

    filesSame : filesSame,
    filesLinked : filesLinked,
    filesLink : filesLink,
    filesNewer : filesNewer,
    filesOlder : filesOlder,

    filesSpectre : filesSpectre,
    filesSimilarity : filesSimilarity,

    filesSize : filesSize,
    fileSize : fileSize,

    fileDelete : fileDelete,

    // filesList : filesList,
    filesAreUpToDate2 : filesAreUpToDate2,

    // testDelaySample : testDelaySample,

  },

};

createTestsDirectory( testRootDirectory, true );

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
