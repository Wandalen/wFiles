( function( ) {

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
      require( '../wTools.ss' );
    }
    catch( err )
    {
      require( 'wTools' );
    }

    try
    {
      require( 'wTesting' );
    }
    catch( err )
    {
      require( 'include/abase/object/Testing.debug.s' );
    }

    require( '../file/Files.ss' );

    var fse = require( 'fs-extra' );
    var pathLib = require( 'path' )

  }

  _global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

  var _ = wTools;
  var Self = {};

  var testRootDirectory = './tmp/sample/FilesIndividualTest';

  function createTestsDirectory( path, rmIfExists )
  {
    rmIfExists && fse.existsSync(path) && fse.removeSync( path );
    return fse.mkdirsSync( path );
  }

  function createInTD( path )
  {
    return createTestsDirectory( pathLib.join(testRootDirectory, path) );
  }

  function createTestFile( path, data )
  {
    fse.createFileSync( pathLib.join( testRootDirectory, path ) );
    data && fse.writeFileSync( pathLib.join( testRootDirectory, path ), data );
  }

  function createTestSymLink( path, type )
  {
    var origin = pathLib.parse(path),
      typeOrigin;
    origin.name = origin.name + '_orig';
    origin.base = origin.name + origin.ext;
    origin = pathLib.format(origin);
    if( 'sf' === type)
    {
      typeOrigin = 'file';
      createTestFile( origin, 'test origin' );
    }
    else if( 'sd' === type )
    {
      typeOrigin = 'dir';
      createInTD( origin );
    }
    else throw new Error( 'unexpected type' );

    path = pathLib.join( testRootDirectory, path );
    origin = pathLib.resolve(pathLib.join( testRootDirectory, origin ));

    fse.existsSync( path ) && fse.removeSync( path );
    fse.symlinkSync( origin, path, typeOrigin);
  }

  function createTestResources( cases )
  {
    var l = cases.length,
      testCase;

    while ( l-- )
    {
      testCase = cases[ l ];
      switch(testCase.type)
      {
        case 'f':
          createTestFile( testCase.path );
          break;

        case 'd':
          createInTD( testCase.path );
          break;

        case 'sd':
        case 'sf':
          createTestSymLink( testCase.path, testCase.type );
          break;
      }
    }
  }

  function mergePath( path )
  {
    return pathLib.join( testRootDirectory, path );
  }


  // --
  // test
  // --

  var directoryIs = function( test )
  {
    // regular tests
    var testCases =
      [
        {
          name: 'simple directory',
          path: 'tmp/sample/', // dir
          type: 'd', // type for create test resource
          expected: true // test expected
        },
        {
          name: 'simple hidden directory',
          path: 'tmp/.hidden', // hidden dir,
          type: 'd',
          expected: true
        },
        {
          name: 'file',
          path: 'tmp/text.txt',
          type: 'f',
          expected: false
        },
        {
          name: 'symlink to directory',
          path: 'tmp/sample2',
          type: 'sd',
          expected: false
        },
        {
          name: 'symlink to file',
          path: 'tmp/text2.txt',
          type: 'sf',
          expected: false
        },
        {
          name: 'not existing path',
          path: 'tmp/notexisting.txt',
          type: 'na',
          expected: false
        }
      ];

    createTestResources( testCases );

    for( let testCase of testCases )
    {
      test.description = testCase.name;
      let got = !! _.directoryIs( pathLib.join( testRootDirectory, testCase.path ) );
      test.identical( got , testCase.expected );
    }

  };

  var fileIs = function( test )
  {
    // regular tests
    var testCases =
      [
        {
          name: 'simple directory',
          path: 'tmp/sample/', // dir
          type: 'd', // type for create test resource
          expected: false // test expected
        },
        {
          name: 'simple hidden file',
          path: 'tmp/.hidden.txt', // hidden dir,
          type: 'f',
          expected: true
        },
        {
          name: 'file',
          path: 'tmp/text.txt',
          type: 'f',
          expected: true
        },
        {
          name: 'symlink to directory',
          path: 'tmp/sample2',
          type: 'sd',
          expected: false
        },
        {
          name: 'symlink to file',
          path: 'tmp/text2.txt',
          type: 'sf',
          expected: false
        },
        {
          name: 'not existing path',
          path: 'tmp/notexisting.txt',
          type: 'na',
          expected: false
        }
      ];

    createTestResources( testCases );

    for( let testCase of testCases )
    {
      test.description = testCase.name;
      let got = !! _.fileIs( pathLib.join( testRootDirectory, testCase.path ) );
      test.identical( got , testCase.expected );
    }

  };

  var fileSymbolicLinkIs = function( test )
  {
    // regular tests
    var testCases =
      [
        {
          name: 'simple directory',
          path: 'tmp/sample/', // dir
          type: 'd', // type for create test resource
          expected: false // test expected
        },
        {
          name: 'simple hidden file',
          path: 'tmp/.hidden.txt', // hidden dir,
          type: 'f',
          expected: false
        },
        {
          name: 'file',
          path: 'tmp/text.txt',
          type: 'f',
          expected: false
        },
        {
          name: 'symlink to directory',
          path: 'tmp/sample2',
          type: 'sd',
          expected: true
        },
        {
          name: 'symlink to file',
          path: 'tmp/text2.txt',
          type: 'sf',
          expected: true
        },
        {
          name: 'not existing path',
          path: 'tmp/notexisting.txt',
          type: 'na',
          expected: false
        }
      ];

    createTestResources( testCases );

    for( let testCase of testCases )
    {
      test.description = testCase.name;
      let got = !! _.fileSymbolicLinkIs( pathLib.join( testRootDirectory, testCase.path ) );
      test.identical( got , testCase.expected );
    }

  };

  //

  var _fileOptionsGet = function( test ) {
    var defaultContextObj =
      {
        defaults:
        {
          pathFile: null,
          sync: null
        }
      },
      options1 =
        {
          sync: 0
        },
      wrongOptions =
        {
          pathFile: 'path',
          sync: 0,
          extraOptions: 1
        },
      path1 = '',
      path2 = '/sample/tmp',
      path3 = '/ample/temp.txt',
      path4 = { pathFile: 'some/abc', sync: 1 },
      expected2 =
        {
          pathFile: '/sample/tmp',
          sync: 1
        },
      expected3 =
      {
        pathFile: '/ample/temp.txt',
        sync: 0
      },
      expected4 = path4;

    test.description = 'non empty path';
    var got = _._fileOptionsGet.call( defaultContextObj, path2 );
    test.identical( got , expected2 );

    test.description = 'non empty path, call with options';
    var got = _._fileOptionsGet.call( defaultContextObj, path3, options1 );
    test.identical( got , expected3 );

    test.description = 'path is object';
    var got = _._fileOptionsGet.call( defaultContextObj, path4, options1 );
    test.identical( got , expected4 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _._fileOptionsGet.call( defaultContextObj);
      });

      test.description = 'extra arguments';
      test.shouldThrowError( function()
      {
        _._fileOptionsGet.call( defaultContextObj, path2, options1, {});
      });

      test.description = 'empty path';
      test.shouldThrowError( function()
      {
        _._fileOptionsGet.call( defaultContextObj, path1 );
      });

      test.description = 'extra options ';
      test.shouldThrowError( function()
      {
        _._fileOptionsGet.call( defaultContextObj, path3, wrongOptions );
      });
    }
  };

  //

  var fileWrite = function( test )
  {
    var fileOptions =
      {
        pathFile : null,
        data : '',
        append : false,
        sync : true,
        force : true,
        silentError : false,
        usingLogging : false,
        clean : false,
      },
      defReadOptions =
      {
        encoding: 'utf8'
      },
      textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
      bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] );


    // regular tests
    var testCases =
      [
        {
          name: 'write empty text file',
          data: '',
          path: 'tmp/text1.txt',
          expected:
          {
            instance: true,
            content: '',
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'write text to file',
          data: textData1,
          path: 'tmp/text2.txt',
          expected:
          {
            instance: true,
            content: textData1,
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'append text to existing file',
          data:
          {
            pathFile : 'tmp/text3.txt',
            data : textData2,
            append : true,
            sync : true,
            force : false,
            silentError : false,
            usingLogging : true,
            clean : false,
          },
          path: 'tmp/text3.txt',
          createResource: textData1,
          expected:
          {
            instance: true,
            content: textData1 + textData2,
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'rewrite existing file',
          data:
          {
            pathFile : 'tmp/text4.txt',
            data : textData2,
            append : false,
            sync : true,
            force : false,
            silentError : false,
            usingLogging : true,
            clean : false,
          },
          path: 'tmp/text4.txt',
          createResource: textData1,
          expected:
          {
            instance: true,
            content: textData2,
            exist: true
          },
          readOptions: defReadOptions
        },

        {
          name: 'force create unexisting path file',
          data:
          {
            pathFile : 'tmp/unexistingDir1/unexsitingDir2/text5.txt',
            data : textData2,
            append : false,
            sync : true,
            force : true,
            silentError : false,
            usingLogging : true,
            clean : false,
          },
          path: 'tmp/unexistingDir1/unexsitingDir2/text5.txt',
          expected:
          {
            instance: true,
            content: textData2,
            exist: true
          },
          readOptions: defReadOptions
        },

        {
          name: 'write file async',
          data:
          {
            pathFile : 'tmp/text6.txt',
            data : textData2,
            append : false,
            sync : false,
            force : true,
            silentError : false,
            usingLogging : true,
            clean : false,
          },
          path: 'tmp/text6.txt',
          expected:
          {
            instance: true,
            content: textData2,
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'create file and write buffer data',
          data:
          {
            pathFile : 'tmp/data1',
            data : bufferData1,
            append : false,
            sync : true,
            force : false,
            silentError : false,
            usingLogging : false,
            clean : false,
          },
          path: 'tmp/data1',
          expected:
          {
            instance: true,
            content: bufferData1,
            exist: true
          },
          readOptions: void 0
        },
        {
          name: 'append buffer data to existing file',
          data:
          {
            pathFile : 'tmp/data1',
            data : bufferData2,
            append : true,
            sync : true,
            force : false,
            silentError : false,
            usingLogging : false,
            clean : false,
          },
          path: 'tmp/data1',
          createResource: bufferData1,
          expected:
          {
            instance: true,
            content: Buffer.concat( [ bufferData1, bufferData2 ] ),
            exist: true
          },
          readOptions: void 0
        },
        {
          name: 'append buffer data to existing file async',
          data:
          {
            pathFile : 'tmp/data1',
            data : bufferData1,
            append : true,
            sync : false,
            force : false,
            silentError : false,
            usingLogging : false,
            clean : false,
          },
          path: 'tmp/data1',
          createResource: bufferData2,
          expected:
          {
            instance: true,
            content: Buffer.concat( [ bufferData2, bufferData1 ] ),
            exist: true
          },
          readOptions: void 0
        },
      ];


    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together
      let got =
        {
          instance: null,
          content: null,
          exist: null
        },
        path = pathLib.join( testRootDirectory, testCase.path );

      // clear
      fse.existsSync( path ) && fse.removeSync( path );

      // prepare to write if need
      testCase.createResource && createTestFile(testCase.path, testCase.createResource);



      let gotFW = typeof testCase.data === 'object'
        ? ( testCase.data.pathFile = mergePath( testCase.data.pathFile ) ) && _.fileWrite( testCase.data )
        : _.fileWrite( path, testCase.data );

      // fileWtrite must returns wConsequence
      got.instance = gotFW instanceof wConsequence;

      if (testCase.data && testCase.data.sync === false)
      {
        gotFW.got( () =>
        {
          // recorded file should exists
          got.exist = fse.existsSync( path );

          // check content of created file.
          got.content = fse.readFileSync( path, testCase.readOptions );

          test.description = testCase.name;
          test.identical( got, testCase.expected );

        });
        continue;
      }

      // recorded file should exists
      got.exist = fse.existsSync( path );

      // check content of created file.
      got.content = fse.readFileSync( path, testCase.readOptions );

      test.description = testCase.name;
      test.identical( got, testCase.expected );
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.fileWrite();
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function()
      {
        _.fileWrite('temp/sample.txt', 'hello', 'world');
      } );

      test.description = 'path is not string';
      test.shouldThrowError( function()
      {
        _.fileWrite( 3, 'hello' );
      } );

      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function()
      {
        _.fileWrite( { pathFile: 'temp/some.txt', data: 'hello', parentDir: './work/project' } );
      } );

      test.description = 'data is not string or buffer';
      test.shouldThrowError( function()
      {
        _.fileWrite( { pathFile: 'temp/some.txt', data: { count: 1 } } );
      } );
    }

  };

  var fileWriteJson = function( test )
  {
    var defReadOptions =
      {
        encoding: 'utf8'
      },
      dataToJSON1 = [ 1, 'a', { b: 34 } ],
      dataToJSON2 = { a: 1, b: 's', c: [ 1, 3, 4 ] },
      dataToJSON3 = '{ "a": "3" }';

    // regular tests
    var testCases =
      [
        {
          name: 'write empty JSON string file',
          data: '',
          path: 'tmp/data1.json',
          expected:
          {
            instance: true,
            content: '',
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'write array to file',
          data: dataToJSON1,
          path: 'tmp/data1.json',
          expected:
          {
            instance: true,
            content: dataToJSON1,
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'write object using options',
          data:
          {
            pathFile : 'tmp/data2.json',
            data : dataToJSON2,
          },
          path: 'tmp/data2.json',
          expected:
          {
            instance: true,
            content: dataToJSON2,
            exist: true
          },
          readOptions: defReadOptions
        },
        {
          name: 'write jason string',
          data:
          {
            pathFile : 'tmp/data3.json',
            data : dataToJSON3,
          },
          path: 'tmp/data3.json',
          expected:
          {
            instance: true,
            content: dataToJSON3,
            exist: true
          },
          readOptions: defReadOptions
        }
      ];


    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together
      let got =
        {
          instance: null,
          content: null,
          exist: null
        },
        path = pathLib.join( testRootDirectory, testCase.path );

      // clear
      fse.existsSync( path ) && fse.removeSync( path );

      let gotFW = testCase.data.pathFile !== void 0
        ? ( testCase.data.pathFile = mergePath( testCase.data.pathFile ) ) && _.fileWriteJson( testCase.data )
        : _.fileWriteJson( path, testCase.data );

      // fileWtrite must returns wConsequence
      got.instance = gotFW instanceof wConsequence;

      // recorded file should exists
      got.exist = fse.existsSync( path );

      // check content of created file.
      got.content = JSON.parse(fse.readFileSync( path, testCase.readOptions ));

      test.description = testCase.name;
      test.identical( got, testCase.expected );
    }

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.fileWriteJson();
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function()
      {
        _.fileWriteJson('temp/sample.txt', { a: 'hello' }, { b: 'world' } );
      } );

      test.description = 'path is not string';
      test.shouldThrowError( function()
      {
        _.fileWriteJson( 3, 'hello' );
      } );

      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function()
      {
        _.fileWriteJson( { pathFile: 'temp/some.txt', data: 'hello', parentDir: './work/project' } );
      } );
    }
  };

  // --
  // proto
  // --

  var Proto =
  {

    name : 'FilesTest',

    tests:
    {

      directoryIs: directoryIs,
      fileIs: fileIs,
      fileSymbolicLinkIs: fileSymbolicLinkIs,

      _fileOptionsGet: _fileOptionsGet,

      fileWrite: fileWrite,
      // fileWriteJson: fileWriteJson,

    },

    verbose : 0,

  };



  Self.__proto__ = Proto;
  wTests[ Self.name ] = Self;


  createTestsDirectory(testRootDirectory, true);

  _.testing.test( Self );

} )( );
