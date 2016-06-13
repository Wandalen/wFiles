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
    data = data || 'test';
    fse.createFileSync( pathLib.join( testRootDirectory, path ), data );
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

    },

    verbose : 0,

  };



  Self.__proto__ = Proto;
  wTests[ Self.name ] = Self;


  createTestsDirectory(testRootDirectory, true);

  _.testing.test( Self );

} )( );
