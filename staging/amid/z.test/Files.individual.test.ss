( function _File_individual_test_ss_( ) {

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

    require( 'wTesting' );

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
    rmIfExists && fse.existsSync( path ) && fse.removeSync( path );
    return fse.mkdirsSync( path );
  }

  function createInTD( path )
  {
    return createTestsDirectory( pathLib.join( testRootDirectory, path ) );
  }

  function createTestFile( path, data, decoding )
  {
    var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
    fse.createFileSync( pathLib.join( testRootDirectory, path ) );
    dataToWrite && fse.writeFileSync( pathLib.join( testRootDirectory, path ), dataToWrite );
  }

  function createTestSymLink( path, target, type, data )
  {
    var origin,
      typeOrigin;

    if( target === void 0 )
    {
      origin = pathLib.parse( path )
      origin.name = origin.name + '_orig';
      origin.base = origin.name + origin.ext;
      origin = pathLib.format( origin );
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

    path = pathLib.join( testRootDirectory, path );
    origin = pathLib.resolve( pathLib.join( testRootDirectory, origin ) );

    fse.existsSync( path ) && fse.removeSync( path );
    fse.symlinkSync( origin, path, typeOrigin );
  }

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
            path = dir ? pathLib.join( dir, path ) : path;
            if( testCase.createResource !== void 0 )
            {
              let res =
                ( Array.isArray( testCase.createResource ) && testCase.createResource[i] ) || testCase.createResource;
              createTestFile( path, res );
            }
            createTestFile( path );
          } );
          break;

        case 'd' :
          paths = Array.isArray( testCase.path ) ? testCase.path : [ testCase.path ];
          paths.forEach( ( path, i ) =>
          {
            path = dir ? pathLib.join( dir, path ) : path;
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
          let path, target;
          if( Array.isArray( testCase.path ) )
          {
            path = dir ? pathLib.join( dir, testCase.path[0] ) : testCase.path[0];
            target = dir ? pathLib.join( dir, testCase.path[1] ) : testCase.path[1];
          }
          else
          {
            path = dir ? pathLib.join( dir, testCase.path ) : testCase.path;
            target = dir ? pathLib.join( dir, testCase.linkTarget ) : testCase.linkTarget;
          }
          createTestSymLink( path, target, testCase.type, testCase.createResource );
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
          name : 'simple directory',
          path : 'tmp/sample/', // dir
          type : 'd', // type for create test resource
          expected : true // test expected
        },
        {
          name : 'simple hidden directory',
          path : 'tmp/.hidden', // hidden dir,
          type : 'd',
          expected : true
        },
        {
          name : 'file',
          path : 'tmp/text.txt',
          type : 'f',
          expected : false
        },
        {
          name : 'symlink to directory',
          path : 'tmp/sample2',
          type : 'sd',
          expected : false
        },
        {
          name : 'symlink to file',
          path : 'tmp/text2.txt',
          type : 'sf',
          expected : false
        },
        {
          name : 'not existing path',
          path : 'tmp/notexisting.txt',
          type : 'na',
          expected : false
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
          name : 'simple directory',
          path : 'tmp/sample/', // dir
          type : 'd', // type for create test resource
          expected : false // test expected
        },
        {
          name : 'simple hidden file',
          path : 'tmp/.hidden.txt', // hidden dir,
          type : 'f',
          expected : true
        },
        {
          name : 'file',
          path : 'tmp/text.txt',
          type : 'f',
          expected : true
        },
        {
          name : 'symlink to directory',
          path : 'tmp/sample2',
          type : 'sd',
          expected : false
        },
        {
          name : 'symlink to file',
          path : 'tmp/text2.txt',
          type : 'sf',
          expected : false
        },
        {
          name : 'not existing path',
          path : 'tmp/notexisting.txt',
          type : 'na',
          expected : false
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
          name : 'simple directory',
          path : 'tmp/sample/', // dir
          type : 'd', // type for create test resource
          expected : false // test expected
        },
        {
          name : 'simple hidden file',
          path : 'tmp/.hidden.txt', // hidden dir,
          type : 'f',
          expected : false
        },
        {
          name : 'file',
          path : 'tmp/text.txt',
          type : 'f',
          expected : false
        },
        {
          name : 'symlink to directory',
          path : 'tmp/sample2',
          type : 'sd',
          expected : true
        },
        {
          name : 'symlink to file',
          path : 'tmp/text2.txt',
          type : 'sf',
          expected : true
        },
        {
          name : 'not existing path',
          path : 'tmp/notexisting.txt',
          type : 'na',
          expected : false
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
        defaults :
        {
          pathFile : null,
          sync : null
        }
      },
      options1 =
        {
          sync : 0
        },
      wrongOptions =
        {
          pathFile : 'path',
          sync : 0,
          extraOptions : 1
        },
      path1 = '',
      path2 = '/sample/tmp',
      path3 = '/ample/temp.txt',
      path4 = { pathFile : 'some/abc', sync : 1 },
      expected2 =
        {
          pathFile : '/sample/tmp',
          sync : 1
        },
      expected3 =
      {
        pathFile : '/ample/temp.txt',
        sync : 0
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
      test.shouldThrowError( function( )
      {
        _._fileOptionsGet.call( defaultContextObj );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _._fileOptionsGet.call( defaultContextObj, path2, options1, {} );
      } );

      test.description = 'empty path';
      test.shouldThrowError( function( )
      {
        _._fileOptionsGet.call( defaultContextObj, path1 );
      } );

      test.description = 'extra options ';
      test.shouldThrowError( function( )
      {
        _._fileOptionsGet.call( defaultContextObj, path3, wrongOptions );
      } );
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
          path : 'tmp/text1.txt',
          expected :
          {
            instance : true,
            content : '',
            exist : true
          },
          readOptions : defReadOptions
        },
        {
          name : 'write text to file',
          data : textData1,
          path : 'tmp/text2.txt',
          expected :
          {
            instance : true,
            content : textData1,
            exist : true
          },
          readOptions : defReadOptions
        },
        {
          name : 'append text to existing file',
          data :
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
          path : 'tmp/text3.txt',
          createResource : textData1,
          expected :
          {
            instance : true,
            content : textData1 + textData2,
            exist : true
          },
          readOptions : defReadOptions
        },
        {
          name : 'rewrite existing file',
          data :
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
          path : 'tmp/text4.txt',
          createResource : textData1,
          expected :
          {
            instance : true,
            content : textData2,
            exist : true
          },
          readOptions : defReadOptions
        },

        {
          name : 'force create unexisting path file',
          data :
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
          path : 'tmp/unexistingDir1/unexsitingDir2/text5.txt',
          expected :
          {
            instance : true,
            content : textData2,
            exist : true
          },
          readOptions : defReadOptions
        },

        {
          name : 'write file async',
          data :
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
          path : 'tmp/text6.txt',
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
            pathFile : 'tmp/data1',
            data : bufferData1,
            append : false,
            sync : true,
            force : false,
            silentError : false,
            usingLogging : false,
            clean : false,
          },
          path : 'tmp/data1',
          expected :
          {
            instance : true,
            content : bufferData1,
            exist : true
          },
          readOptions : void 0
        },
        {
          name : 'append buffer data to existing file',
          data :
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
          path : 'tmp/data1',
          createResource : bufferData1,
          expected :
          {
            instance : true,
            content : Buffer.concat( [ bufferData1, bufferData2 ] ),
            exist : true
          },
          readOptions : void 0
        },
        {
          name : 'append buffer data to existing file async',
          data :
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
          path : 'tmp/data1',
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
        path = pathLib.join( testRootDirectory, testCase.path );

      // clear
      fse.existsSync( path ) && fse.removeSync( path );

      // prepare to write if need
      testCase.createResource && createTestFile( testCase.path, testCase.createResource );



      let gotFW = typeof testCase.data === 'object'
        ? ( testCase.data.pathFile = mergePath( testCase.data.pathFile ) ) && _.fileWrite( testCase.data )
        : _.fileWrite( path, testCase.data );

      // fileWtrite must returns wConsequence
      got.instance = gotFW instanceof wConsequence;

      if ( testCase.data && testCase.data.sync === false )
      {
        gotFW.got( ( ) =>
        {
          // recorded file should exists
          got.exist = fse.existsSync( path );

          // check content of created file.
          got.content = fse.readFileSync( path, testCase.readOptions );

          test.description = testCase.name;
          test.identical( got, testCase.expected );

        } );
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
      test.shouldThrowError( function( )
      {
        _.fileWrite( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.fileWrite( 'temp/sample.txt', 'hello', 'world' );
      } );

      test.description = 'path is not string';
      test.shouldThrowError( function( )
      {
        _.fileWrite( 3, 'hello' );
      } );

      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function( )
      {
        _.fileWrite( { pathFile : 'temp/some.txt', data : 'hello', parentDir : './work/project' } );
      } );

      test.description = 'data is not string or buffer';
      test.shouldThrowError( function( )
      {
        _.fileWrite( { pathFile : 'temp/some.txt', data : { count : 1 } } );
      } );
    }

  };

  var fileWriteJson = function( test )
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
          path : 'tmp/data1.json',
          expected :
          {
            instance : true,
            content : '',
            exist : true
          },
          readOptions : defReadOptions
        },
        {
          name : 'write array to file',
          data : dataToJSON1,
          path : 'tmp/data1.json',
          expected :
          {
            instance : true,
            content : dataToJSON1,
            exist : true
          },
          readOptions : defReadOptions
        },
        {
          name : 'write object using options',
          data :
          {
            pathFile : 'tmp/data2.json',
            data : dataToJSON2,
          },
          path : 'tmp/data2.json',
          expected :
          {
            instance : true,
            content : dataToJSON2,
            exist : true
          },
          readOptions : defReadOptions
        },
        {
          name : 'write jason string',
          data :
          {
            pathFile : 'tmp/data3.json',
            data : dataToJSON3,
          },
          path : 'tmp/data3.json',
          expected :
          {
            instance : true,
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
      got.content = JSON.parse( fse.readFileSync( path, testCase.readOptions ) );

      test.description = testCase.name;
      test.identical( got, testCase.expected );
    }

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.fileWriteJson( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.fileWriteJson( 'temp/sample.txt', { a : 'hello' }, { b : 'world' } );
      } );

      test.description = 'path is not string';
      test.shouldThrowError( function( )
      {
        _.fileWriteJson( 3, 'hello' );
      } );

      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function( )
      {
        _.fileWriteJson( { pathFile : 'temp/some.txt', data : 'hello', parentDir : './work/project' } );
      } );
    }
  };

  var fileRead = function( test )
  {
    var wrongReadOptions0 =
      {

        sync : 0,
        wrap : 0,
        returnRead : 0,
        silent : 0,

        pathFile : 'tmp/text2.txt',
        filePath : 'tmp/text2.txt',
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
        silent : 0,

        pathFile : null,
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
        returnRead : 0,
        silent : 0,

        pathFile : null,
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
        silent : 0,

        pathFile : null,
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
        returnRead : 0,
        silent : 0,

        pathFile : null,
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
        silent : 0,

        pathFile : null,
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
        returnRead : 0,
        silent : 0,

        pathFile : null,
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
          path : 'tmp/rtext1.txt',
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
          path : 'tmp/text2.txt',
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
          path : 'tmp/text3.txt',
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
          path : 'tmp/data1',
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
          path : 'tmp/data2',
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
          path : 'tmp/jason1.json',
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
          path : 'tmp/json2.json',
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
        fse.existsSync( path ) && fse.removeSync( path );

        // prepare to write if need
        testCase.createResource !== undefined
        && createTestFile( testCase.path, testCase.createResource, testCase.readOptions.encoding );

        testCase.readOptions.pathFile = path;
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
          if( fileContent instanceof ArrayBuffer )
          {
            fileContent = Buffer.from( fileContent );
          }
          got.content = fileContent;

          test.description = testCase.name;
          test.identical( got, testCase.expected );

        };

        let gotFR = _.fileRead( testCase.readOptions );
      } )( _.entityClone( testCase ) );

    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.fileRead( );
      } );


      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function( )
      {
        _.fileRead( wrongReadOptions0 );
      } );

    }

  };

  var fileReadSync = function( test )
  {
    var wrongReadOptions0 =
      {

        silent : 0,

        pathFile : 'tmp/text2.txt',
        filePath : 'tmp/text2.txt',
        encoding : 'utf8',
      },
      fileReadOptions0 =
      {

        wrap : 0,
        silent : 0,

        pathFile : null,
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
        silent : 0,

        pathFile : null,
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
        silent : 0,

        pathFile : null,
        encoding : 'arraybuffer',

        onBegin : null,
        onEnd : null,
        onError : null,

      },

      fileReadOptions3 =
      {

        sync : 0,
        wrap : 0,
        returnRead : 0,
        silent : 0,

        pathFile : null,
        encoding : 'arraybuffer',

        onBegin : null,
        onEnd : null,
        onError : null,

      },

      fileReadOptions4 =
      {

        wrap : 0,
        silent : 0,

        pathFile : null,
        name : null,
        encoding : 'json',

        onBegin : null,
        onEnd : null,
        onError : null,

      },
      fileReadOptions5 =
      {

        wrap : 0,
        silent : 0,

        pathFile : null,
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
          path : 'tmp/rtext1.txt',
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
          path : 'tmp/text2.txt',
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
          path : 'tmp/text3.txt',
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
          path : 'tmp/data1',
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
          path : 'tmp/data2',
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
          path : 'tmp/jason1.json',
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
          path : 'tmp/json2.json',
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
      fse.existsSync( path ) && fse.removeSync( path );

      // prepare to write if need
      testCase.createResource !== undefined
      && createTestFile( testCase.path, testCase.createResource, testCase.readOptions.encoding );

      let got = _.fileReadSync( path, testCase.readOptions );

      if( got instanceof ArrayBuffer )
      {
        got = Buffer.from( got );
      }

      test.identical( got, testCase.expected.content );
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.fileReadSync( );
      } );

      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function( )
      {
        _.fileReadSync( wrongReadOptions0 );
      } );

      test.description = 'pathFile is not defined';
      test.shouldThrowError( function( )
      {
       _.fileReadSync( { encoding : 'json' } );
      } );

    }

  };

  var fileReadJson = function( test )
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
          path : 'tmp/rtext1.txt',
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
          path : 'tmp/text2.txt',
          expected :
          {
            error : true,
            content : void 0
          }
        },
        {
          name : 'try to parse buffer as json',
          createResource : bufferData1,
          path : 'tmp/data1',
          expected :
          {
            error : true,
            content : void 0
          }
        },
        {
          name : 'read json from file',
          createResource : dataToJSON1,
          path : 'tmp/jason1.json',
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
          path : 'tmp/json2.json',
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
      fse.existsSync( path ) && fse.removeSync( path );

      // prepare to write if need
      testCase.createResource !== undefined
        && createTestFile( testCase.path, testCase.createResource , testCase.encoding );

      try
      {
        got.content = _.fileReadJson( path );
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
      test.shouldThrowError( function( )
      {
        _.fileReadJson( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.fileReadJson( 'tmp/tmp.json', {} );
      } );
    }

  };

  var filesSame = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
      bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),

    testCases = [

      {
        name : 'same file with empty content',
        path : [ 'tmp/filesSame/sample.txt', 'tmp/filesSame/sample.txt' ],
        type : 'f',
        createResource : '',
        expected : true
      },
      {
        name : 'two different files with empty content',
        path : [ 'tmp/filesSame/.hidden.txt', 'tmp/filesSame/nohidden.txt' ],
        type : 'f',
        createResource : '',
        expected : true
      },
      {
        name : 'same text file',
        path : [ 'tmp/filesSame/same_text.txt', 'tmp/filesSame/same_text.txt' ],
        type : 'f',
        createResource : textData1,
        expected : true
      },
      {
        name : 'files with identical text content',
        path : [ 'tmp/filesSame/identical_text1.txt', 'tmp/filesSame/identical_text2.txt' ],
        type : 'f',
        createResource : textData1,
        expected : true
      },
      {
        name : 'files with identical binary content',
        path : [ 'tmp/filesSame/identical2', 'tmp/filesSame/identical2.txt' ],
        type : 'f',
        createResource : bufferData1,
        expected : true
      },
      {
        name : 'files with non identical text content',
        path : [ 'tmp/filesSame/identical_text3.txt', 'tmp/filesSame/identical_text4.txt' ],
        type : 'f',
        createResource : [ textData1, textData2 ],
        expected : false
      },
      {
        name : 'files with non identical binary content',
        path : [ 'tmp/filesSame/noidentical1', 'tmp/filesSame/noidentical2' ],
        type : 'f',
        createResource : [ bufferData1, bufferData2 ],
        expected : false
      },
      {
        name : 'file and symlink to file',
        path : [ 'tmp/filesSame/testsymlink', 'tmp/filesSame/testfile' ],
        type : 'sf',
        createResource :  bufferData1,
        expected : true
      },
      {
        name : 'not existing path',
        path : [ 'tmp/filesSame/nofile1', 'tmp/filesSame/noidentical2' ],
        type : 'na',
        expected : false
      }
    ];

    createTestResources( testCases )

    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together

      let file1 = mergePath( testCase.path[0] ),
        file2 = mergePath( testCase.path[1] ),
        got;

      test.description = testCase.name;

      try
      {
        got = _.filesSame( file1, file2, testCase.checkTime );
      }
      catch( err ) {}
      test.identical( got, testCase.expected );
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesSame( );
      } );
    }

    // time check
      test.description = 'files with identical content : time check';
      var expected = false,
        file1 = mergePath( 'tmp/filesSame/identical3' ),
        file2 = mergePath( 'tmp/filesSame/identical4' ),
        con, got;

      createTestFile( file1 );
      con = _.timeOut( 50);
      con.then_( () => createTestFile( file2 ) );
      con.then_( () =>
      {
        try
        {
          got = _.filesSame( file1, file2, true );
        }
        catch( err ) {}
        test.identical( got, expected );
      } );

      return con;
  };

  var filesLinked = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),

      testCases = [
        {
          name : 'same text file',
          path : [ 'tmp/filesLinked/same_text.txt', 'tmp/filesLinked/same_text.txt' ],
          type : 'f',
          createResource : textData1,
          expected : true
        },
        {
          name : 'link to file with text content',
          path : [ 'tmp/filesLinked/identical_text1.txt', 'tmp/filesLinked/identical_text2.txt' ],
          type : 'sf',
          createResource : textData1,
          expected : true
        },
        {
          name : 'different files with identical binary content',
          path : [ 'tmp/filesLinked/identical1', 'tmp/filesLinked/identical2' ],
          type : 'f',
          createResource : bufferData1,
          expected : false
        },
        {
          name : 'symlink to file with  binary content',
          path : [ 'tmp/filesLinked/identical3', 'tmp/filesLinked/identical4' ],
          type : 'sf',
          createResource : bufferData1,
          expected : true
        },
        {
          name : 'not existing path',
          path : [ 'tmp/filesLinked/nofile1', 'tmp/filesLinked/noidentical2' ],
          type : 'na',
          expected : false
        }
      ];

    createTestResources( testCases )

    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together

      let file1 = mergePath( testCase.path[ 0 ] ),
        file2 = mergePath( testCase.path[ 1 ] ),
        got;

      test.description = testCase.name;

      try
      {
        got = _.filesLinked( file1, file2 );
      }
      catch ( err ) {}
      finally
      {
        test.identical( got, testCase.expected );
      }
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesSame( );
      } );
    }
  };

  var filesLink = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),

      testCases = [
        {
          name : 'create link to text file with same path',
          path : 'tmp/filesLink/same_text.txt',
          link : 'tmp/filesLink/same_text.txt',
          type : 'f',
          createResource : textData1,
          expected : { result : true, isSym : true, linkPath : 'tmp/filesLink/same_text.txt' }
        },
        {
          name : 'link to file with text content',
          path : [ 'tmp/filesLink/identical_text1.txt', 'tmp/filesLink/identical_text2.txt' ],
          link : 'tmp/filesLink/identical_text2.txt',
          type : 'f',
          createResource : textData2,
          expected : { result : true, isSym : true, linkPath : 'tmp/filesLink/identical_text1.txt' }
        },
        {
          name : 'link to file with binary content',
          path : 'tmp/filesLink/identical1',
          link : 'tmp/filesLink/identical2',
          type : 'f',
          createResource : bufferData1,
          expected : { result : true, isSym : true, linkPath : 'tmp/filesLink/identical1' }
        },
        {
          name : 'not existing path',
          path : 'tmp/filesLink/nofile1',
          link : 'tmp/filesLink/linktonofile',
          type : 'na',
          expected : { result : false, isSym : false, linkPath : null }
        }
      ];

    createTestResources( testCases )

    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together

      let file = mergePath( testCase.path[0] ),
        link = mergePath( testCase.link ),
        got = { result : void 0, isSym : void 0, linkPath : null };

      test.description = testCase.name;

      try
      {
        got.result = _.filesLink( link, file );
        let stat = fse.lstatSync( pathLib.resolve( link ) );
        got.isSym = stat.isSymbolicLink( );
        got.linkPath = fse.readlinkSync( link );
      }
      catch ( err ) { logger.log( err ) }
      finally
      {
        test.identical( got, testCase.expected );
      }
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesLink( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.filesLink( 'tmp/filesLink/identical1', 'tmp/filesLink/same_text.txt', 'tmp/filesLink/same_text.txt' );
      } );

      test.description = 'argumetns is not string';
      test.shouldThrowError( function( )
      {
        _.filesLink( 34, {} );
      } );
    }

  };

  var filesNewer = function( test )
  {
    var file1 = 'tmp/filesNewer/test1',
      file2 = 'tmp/filesNewer/test2',
      file3 = 'tmp/filesNewer/test3';

    createTestFile( file1, 'test1' );
    createTestFile( file2, 'test2' );

    file1 = mergePath( file1 );
    file2 = mergePath( file2 );

    test.description = 'two files created at one time';
    var got = _.filesNewer( file1, file2 );
    test.identical( got, null );

    setTimeout( ( ) =>
    {
      createTestFile( file3, 'test3' );
      file3 = mergePath( file3 );

      test.description = 'two files created at different time';
      var got = _.filesNewer( file1, file3 );
      test.identical( got, file3 );
    }, 0 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesNewer( );
      } );

      test.description = 'type of arguments is not file.Stat or string';
      test.shouldThrowError( function( )
      {
        _.filesNewer( null, '/tmp/s.txt' );
      } );
    }
  };

  var filesOlder = function( test )
  {
    var file1 = 'tmp/filesNewer/test1',
      file2 = 'tmp/filesNewer/test2',
      file3 = 'tmp/filesNewer/test3';

    createTestFile( file1, 'test1' );
    createTestFile( file2, 'test2' );

    file1 = mergePath( file1 );
    file2 = mergePath( file2 );

    test.description = 'two files created at one time';
    var got = _.filesOlder( file1, file2 );
    test.identical( got, null );

    setTimeout( ( ) =>
    {
      createTestFile( file3, 'test3' );
      file3 = mergePath( file3 );

      test.description = 'two files created at different time';
      var got = _.filesOlder( file1, file3 );
      test.identical( got, file1 );
    }, 0 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesOlder( );
      } );

      test.description = 'type of arguments is not file.Stat or string';
      test.shouldThrowError( function( )
      {
        _.filesOlder( null, '/tmp/s.txt' );
      } );
    }
  };

  var filesSpectre = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
      bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),

      testCases = [

        {
          name : 'file with empty content',
          path : 'tmp/filesSpectre/sample.txt',
          type : 'f',
          createResource : '',
          expected :
          {
            length : 0
          }
        },
        {
          name : 'text file 1',
          path : 'tmp/filesSpectre/some.txt',
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
          path : 'tmp/filesSame/text1.txt',
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

      let path = mergePath( testCase.path ),
        got;

      test.description = testCase.name;

      try
      {
        got = _.filesSpectre( path );
      }
      catch( err ) {}
      test.identical( got, testCase.expected );
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesSpectre( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.filesSpectre( 'tmp/filesSame/text1.txt', 'tmp/filesSame/text2.txt' );
      } );
    }
  };

  var filesSimilarity = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
      bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),

      testCases = [

        {
          name : 'two different files with empty content',
          path : [ 'tmp/filesSimilarity/empty1.txt', 'tmp/filesSimilarity/empty2.txt' ],
          type : 'f',
          createResource : '',
          expected : 1
        },
        {
          name : 'same text file',
          path : [ 'tmp/filesSimilarity/same_text.txt', 'tmp/filesSimilarity/same_text.txt' ],
          type : 'f',
          createResource : textData1,
          expected : 1
        },
        {
          name : 'files with identical text content',
          path : [ 'tmp/filesSimilarity/identical_text1.txt', 'tmp/filesSimilarity/identical_text2.txt' ],
          type : 'f',
          createResource : textData1,
          expected : 1
        },
        {
          name : 'files with identical binary content',
          path : [ 'tmp/filesSimilarity/identical2', 'tmp/filesSimilarity/identical2.txt' ],
          type : 'f',
          createResource : bufferData1,
          expected : 1
        },
        {
          name : 'files with identical content',
          path : [ 'tmp/filesSimilarity/identical3', 'tmp/filesSimilarity/identical4' ],
          type : 'f',
          createResource : bufferData2,
          expected : 1
        },
        {
          name : 'files with non identical text content',
          path : [ 'tmp/filesSimilarity/identical_text3.txt', 'tmp/filesSimilarity/identical_text4.txt' ],
          type : 'f',
          createResource : [ textData1, textData2 ],
          expected : 0.375
        },
        {
          name : 'files with non identical binary content',
          path : [ 'tmp/filesSimilarity/noidentical1', 'tmp/filesSimilarity/noidentical2' ],
          type : 'f',
          createResource : [ bufferData1, bufferData2 ],
          expected : 0
        },
        {
          name : 'file and symlink to file',
          path : [ 'tmp/filesSimilarity/testsymlink', 'tmp/filesSimilarity/testfile' ],
          type : 'sf',
          createResource :  bufferData1,
          expected : 1
        },
        // undefined behavior
        // {
        //   name : 'not existing path',
        //   path : [ 'tmp/filesSimilarity/nofile1', 'tmp/filesSimilarity/noidentical2' ],
        //   type : 'na',
        //   expected : NaN
        // }
      ];

    createTestResources( testCases );

    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together

      let path1 = mergePath( testCase.path[0] ),
        path2 = mergePath( testCase.path[1] ),
        got;

      test.description = testCase.name;

      try
      {
        got = _.filesSimilarity( path1, path2 );
      }
      catch( err ) {}
      test.identical( got, testCase.expected );
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.filesSimilarity( );
      } );
    }
  };

  var filesSize = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
      bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),
      testCases =
      [
        {
          name : 'empty file',
          path : 'tmp/filesSize/rtext1.txt',
          type : 'f',
          expected : 0,
          createResource : ''
        },
        {
          name : 'text file1',
          createResource : textData1,
          path : 'tmp/filesSize/text2.txt',
          type : 'f',
          expected : textData1.length
        },
        {
          name : 'text file 2',
          createResource : textData2,
          path : 'tmp/filesSize/text3.txt',
          type : 'f',
          expected : textData2.length
        },
        {
          name : 'file binary',
          createResource : bufferData1,
          path : 'tmp/filesSize/data1',
          type : 'f',
          expected : bufferData1.byteLength
        },
        {
          name : 'binary file 2',
          createResource : bufferData2,
          path : 'tmp/filesSize/data2',
          type : 'f',
          expected : bufferData2.byteLength
        },
        // {
        //   name : 'unexisting file',
        //   createResource : '',
        //   path : 'tmp/filesSize/data3',
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
        got = _.filesSize( path );
      }
      catch( err ) {}
      test.identical( got, testCase.expected );
    }

    var pathes = testCases.map( c => mergePath( c.path ) );
    var expected = testCases.reduce( ( pc, cc ) => { return pc + cc.expected; }, 0 );

    test.description = 'all paths together';
    var got = _.filesSize( pathes );
    test.identical( got, expected );

  };

  var fileSize = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      textData2 = ' Aenean non feugiat mauris',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),
      bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ),
      testCases =
        [
          {
            name : 'empty file',
            path : 'tmp/fileSize/rtext1.txt',
            type : 'f',
            expected : 0,
            createResource : ''
          },
          {
            name : 'text file1',
            createResource : textData1,
            path : 'tmp/fileSize/text2.txt',
            type : 'f',
            expected : textData1.length
          },
          {
            name : 'text file 2',
            createResource : textData2,
            path : 'tmp/fileSize/text3.txt',
            type : 'f',
            expected : textData2.length
          },
          {
            name : 'file binary',
            createResource : bufferData1,
            path : 'tmp/fileSize/data1',
            type : 'f',
            expected : bufferData1.byteLength
          },
          {
            name : 'binary file 2',
            createResource : bufferData2,
            path : 'tmp/fileSize/data2',
            type : 'f',
            expected : bufferData2.byteLength
          },
          {
            name : 'binary file 2',
            createResource : bufferData2,
            path : 'tmp/fileSize/data3',
            type : 'sf',
            expected : false
          },
          // {
          //   name : 'unexisting file',
          //   createResource : '',
          //   path : 'tmp/filesSize/data3',
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
        got = _.fileSize( path );
      }
      catch( err ) {}
      test.identical( got, testCase.expected );
    }

    test.description = 'test onEnd callback : before';
    var path = mergePath( 'tmp/fileSize/data4' );
    _.fileWrite( { pathFile : path, data : bufferData1 } );
    var got = _.fileSize( {
      pathFile : path,
      onEnd : ( size ) =>
      {
        test.description = 'test onEnd callback : after';
        var expected = bufferData1.byteLength + bufferData2.byteLength;
        test.identical( size, expected );
      }
    } );

    _.fileWrite( { pathFile : path, data : bufferData2, append : 1 } );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.fileSize( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.fileSize( mergePath( 'tmp/fileSize/data2' ), mergePath( 'tmp/fileSize/data3' ) );
      } );

      test.description = 'path is not string';
      test.shouldThrowError( function( )
      {
        _.fileSize( { pathFile : null } );
      } );

      test.description = 'passed unexpected property';
      test.shouldThrowError( function( )
      {
        _.fileSize( { pathFile : mergePath( 'tmp/fileSize/data2' ), pathDir : mergePath( 'tmp/fileSize/data3' ) } );
      } );
    }

  };


  var fileDelete = function( test ) {
    var fileDelOptions =
      {
        pathFile : null,
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
          path : 'tmp/fileDelete/text1.txt',
          expected :
          {
            exception : false,
            exist : false
          }
        },
        {
          name : 'delete single text file asynchronously',
          createResource : textData1,
          path : 'tmp/fileDelete/text2.txt',
          expected :
          {
            exception : false,
            exist : false
          },
          delOptions : {
            pathFile : null,
            force : 0,
            sync : 0,
          }
        },
        {
          name : 'delete empty folder',
          type : 'd',
          path : 'tmp/fileDelete/emptyFolder',
          expected :
          {
            exception : false,
            exist : false
          }
        },
        {
          name : 'delete not empty folder : no force',
          type : 'd',
          path : 'tmp/fileDelete/noEmptyFolder',
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
          path : 'tmp/fileDelete/noEmptyFolder2',
          expected :
          {
            exception : false,
            exist : false
          },
          delOptions : {
            pathFile : null,
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
          path : 'tmp/fileDelete/noEmptyFolder3',
          expected :
          {
            exception : false,
            exist : false
          },
          delOptions : {
            pathFile : null,
            force : 1,
            sync : 0,
          }
        },
        {
          name : 'delete symlink',
          path : 'tmp/fileDelete/identical2',
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
            exception : void 0,
            exist : void 0,
          },
          path = mergePath( testCase.path ),
          continueFlag = false;

        try
        {
          let gotFD = typeof testCase.delOptions === 'object'
            ? ( testCase.delOptions.pathFile = path ) && _.fileDelete( testCase.delOptions )
            : _.fileDelete( path );

          if( testCase.delOptions && !!testCase.delOptions.sync === false )
          {
            continueFlag = true;
            gotFD.got( ( err ) =>
            {
              // deleted file should  not exists
              got.exist = fse.existsSync( path );

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
          got.exist = fse.existsSync( path );

          // check content of created file.
          test.description = testCase.name;
          test.identical( got, testCase.expected );
        }
      } )( _.entityClone( testCase ) );
    }

    // exception tests

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function( )
      {
        _.fileDelete( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.fileDelete( 'temp/sample.txt', fileDelOptions );
      } );

      test.description = 'path is not string';
      test.shouldThrowError( function( )
      {
        _.fileDelete( {
          pathFile : null,
          force : 0,
          sync : 1,
        } );
      } );

      test.description = 'passed unexpected property in options';
      test.shouldThrowError( function( )
      {
        _.fileWrite( {
          pathFile : 'temp/some.txt',
          force : 0,
          sync : 1,
          parentDir : './work/project'
        } );
      } );
    }
  };


  var fileHardlink = function( test )
  {
    var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ),

      testCases = [
        {
          name : 'hard link to file with text content',
          path : 'tmp/fileHardlink/text1.txt',
          link : 'tmp/fileHardlink/hard_text1.txt',
          type : 'f',
          createResource : textData1,
          expected : { err : false, ishard : true }
        },
        {
          name : 'hard link to file with binary content',
          path : 'tmp/fileHardlink/data',
          link : 'tmp/fileHardlink/hard_data',
          type : 'f',
          createResource : bufferData1,
          expected : { err : false, ishard : true }
        },
        {
          name : 'try to create hard link to folder',
          path : 'tmp/fileHardlink/folder',
          link : 'tmp/fileHardlink/hard_folder',
          type : 'd',
          expected : { err : true, ishard : false }
        },
        {
          name : 'try to create hard link to not existing file',
          path : 'tmp/fileHardlink/nofile1',
          link : 'tmp/fileHardlink/linktonofile',
          type : 'na',
          expected : { err : true, ishard : false }
        }
      ];

    createTestResources( testCases );

    function checkHardLink( link, src )
    {
      link = pathLib.resolve( link );
      src = pathLib.resolve( src );
      var statLink = fse.lstatSync( link ),
        statSource = fse.lstatSync( src );

      if ( !statLink || !statSource ) return false; // both files should be exists
      if ( statSource.nlink !== 2 ) return false;
      if ( statLink.ino !== statSource.ino ) return false; // both names should be associated with same file on device.

      fse.unlinkSync( link );
      statSource = fse.lstatSync( src );

      if ( statSource.nlink !== 1 ) return false;

      return true;
    }

    // regular tests
    for( let testCase of testCases )
    {
      // join several test aspects together

      let file = mergePath( testCase.path ),
        link = mergePath( testCase.link ),
        got = { ishard : void 0, err : void 0 };

      test.description = testCase.name;

      try
      {
       var con = _.fileHardlink( link, file );

        got.ishard = checkHardLink( link, file );
      }
      catch ( err )
      {
        logger.log( err );
        got.err = !!err;
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
      test.shouldThrowError( function( )
      {
        _.fileHardlink( );
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function( )
      {
        _.fileHardlink( 'tmp/fileHardlink/src1', 'tmp/fileHardlink/hard_text.txt', 'tmp/fileHardlink/hard2.txt' );
      } );

      test.description = 'argumetns is not string';
      test.shouldThrowError( function( )
      {
        _.fileHardlink( 34, {} );
      } );

      test.description = 'passed unexpected property';
      test.shouldThrowError( function( )
      {
        _.fileHardlink( {
          pathDst : 'tmp/fileHardlink/src1',
          pathSrc : 'tmp/fileHardlink/hard_text.txt',
          dir : 'tmp/fileHardlink'
        } );
      } );
    }
  };

  var filesList = function( test )
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
          path : 'tmp/filesList/text1.txt',
          expected :
          {
            list : [ 'text1.txt' ],
            err : false
          }
        },
        {
          name : 'empty folder',
          type : 'd',
          path : 'tmp/filesList/emptyFolder',
          expected :
          {
            list : [],
            err : false
          }
        },
        {
          name : 'folder with several files',
          type : 'd',
          path : 'tmp/filesList/noEmptyFolder',
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
          path : 'tmp/filesList/noEmptyFolder1',
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
          path : 'tmp/filesList/noEmptyFolder2',
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
        logger.log( err );
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

  var filesIsUpToDate = function( test )
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
            path : [ 'tmp/filesIsUpToDate1/file1', 'tmp/filesIsUpToDate1/file2.txt' ],
            type : 'f',
            createResource : [ bufferData1, textData1 ]
          },
          createSecond :
          {
            path : [ 'tmp/filesIsUpToDate1/file3', 'tmp/filesIsUpToDate1/file4.txt' ],
            type : 'f',
            createResource : [ bufferData2, textData2 ]
          },
          src : [ 'tmp/filesIsUpToDate1/file1', 'tmp/filesIsUpToDate1/file2.txt' ],
          dst : [ 'tmp/filesIsUpToDate1/file3', 'tmp/filesIsUpToDate1/file4.txt' ],
          expected : true
        },
        {
          name : 'files is not up to date',
          createFirst :
          {
            path : [ 'tmp/filesIsUpToDate2/file1', 'tmp/filesIsUpToDate2/file2.txt' ],
            type : 'f',
            createResource : [ bufferData1, textData1 ]
          },
          createSecond :
          {
            path : [ 'tmp/filesIsUpToDate2/file3', 'tmp/filesIsUpToDate2/file4.txt' ],
            type : 'f',
            createResource : [ bufferData2, textData2 ]
          },
          src : [ 'tmp/filesIsUpToDate2/file1', 'tmp/filesIsUpToDate2/file4.txt' ],
          dst : [ 'tmp/filesIsUpToDate2/file3', 'tmp/filesIsUpToDate2/file2.txt' ],
          expected : false
        },
      ];

/*
    function createWithDelay( fileLists, delay )
    {
      delay = delay || 0;
      var con = wConsequence();
      setTimeout( function( )
      {
        createTestResources( fileLists );
        console.log( '--> files created second' );
        con.give( );
      }, delay );
      return con;
    }
*/

    var con = new wConsequence().give();
    for( let tc of testCases )
    {
      ( function( tc )
      {
        console.log( 'tc : ' + tc.name );
        createTestResources( tc.createFirst );
        console.log( '--> files create first' );

        con.then_( _.routineSeal( _,_.timeOut,[ 500 ] ) );
        con.then_( _.routineSeal( null,createTestResources,[ tc.createSecond ] ) );
        con.then_( _.routineSeal( console,console.log,[ '--> files created second' ] ) );

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

        con.then_( ( ) =>
        {
          test.description = tc.name;
          try
          {
            var got = _.filesIsUpToDate(
              {
                src : tc.src.map( ( v ) => mergePath( v ) ),
                dst : tc.dst.map( ( v ) => mergePath( v ) )
              } );
          }
          catch( err )
          {
            console.log( err );
          }
          test.identical( got, tc.expected );
        } );
      } )( _.entityClone( tc ) );
    }
    return con;
  };

//

  var testDelaySample = function testDelaySample( test )
  {

    debugger;

    test.description = 'delay test';

    var con = _.timeOut( 1000 );

    test.identical( 1,1 );

    con.then_( function( ){ logger.log( '1000ms delay' ) } );

    con.then_( _.routineSeal( _,_.timeOut,[ 1000 ] ) );

    con.then_( function( ){ logger.log( '2000ms delay' ) } );

    con.then_( function( ){ test.identical( 1,1 ); } );

    return con;
  }

  // --
  // proto
  // --

  var Proto =
  {

    name : 'FilesTest',

    tests :
    {


      directoryIs: directoryIs,
      fileIs: fileIs,
      fileSymbolicLinkIs: fileSymbolicLinkIs,

      _fileOptionsGet: _fileOptionsGet,

      fileWrite: fileWrite,
      // fileWriteJson: fileWriteJson,

      fileRead: fileRead,
      fileReadSync: fileReadSync,
      fileReadJson: fileReadJson,

      filesSame: filesSame,
      filesLinked: filesLinked,
      filesLink: filesLink,
      filesNewer: filesNewer,
      filesOlder: filesOlder,

      filesSpectre: filesSpectre,
      filesSimilarity: filesSimilarity,

      filesSize: filesSize,
      fileSize: fileSize,

      fileDelete: fileDelete,
      fileHardlink: fileHardlink,

      filesList: filesList,
      filesIsUpToDate : filesIsUpToDate,


      // testDelaySample : testDelaySample,

    },

    verbose : 1,

  };



  Self.__proto__ = Proto;
  wTests[ Self.name ] = Self;


  createTestsDirectory( testRootDirectory, true );

  _.testing.test( Self );

} )( );
