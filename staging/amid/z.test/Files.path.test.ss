( function _File_path_test_ss_( ) {

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

    var File = require( 'fs-extra' );
    var Path = require( 'path' );

  }

  _global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

  var _ = wTools;
  var FileRecord = _.FileRecord;

  var Self = {};


  var testRootDirectory = './tmp/sample/FilesPathTest';

  function createTestsDirectory( path, rmIfExists )
  {
    rmIfExists && File.existsSync( path ) && File.removeSync( path );
    return File.mkdirsSync( path );
  }

  function createInTD( path )
  {
    return createTestsDirectory( Path.join( testRootDirectory, path ) );
  }

  function createTestFile( path, data, decoding )
  {
    var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
    path = ( path.indexOf( testRootDirectory ) >= 0 ) ? path : Path.join( testRootDirectory, path );
    File.createFileSync( path );
    dataToWrite && File.writeFileSync( path , dataToWrite );
  }

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

    path = Path.join( testRootDirectory, path );
    origin = Path.resolve( Path.join( testRootDirectory, origin ) );

    File.existsSync( path ) && File.removeSync( path );
    File.symlinkSync( origin, path, typeOrigin );
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
            path = dir ? Path.join( dir, path ) : path;
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
            path = dir ? Path.join( dir, path ) : path;
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
            path = dir ? Path.join( dir, testCase.path[0] ) : testCase.path[0];
            target = dir ? Path.join( dir, testCase.path[1] ) : testCase.path[1];
          }
          else
          {
            path = dir ? Path.join( dir, testCase.path ) : testCase.path;
            target = dir ? Path.join( dir, testCase.linkTarget ) : testCase.linkTarget;
          }
          createTestSymLink( path, target, testCase.type, testCase.createResource );
          break;
      }
    }
  }

  function mergePath( path )
  {
    return Path.join( testRootDirectory, path );
  }


  // --
  // test
  // --

  var pathGet = function( test )
  {
    var pathStr1 = '/foo/bar/baz',
        pathStr2 = 'tmp/pathGet/test.txt',
      expected = pathStr1,
      expected2 = Path.resolve( mergePath( pathStr2 ) ),
      got,
      fileRecord;

    createTestFile( pathStr2 );
    fileRecord = FileRecord( mergePath( pathStr2 ) );

    test.description = 'string argument';
    got = _.pathGet( pathStr1 );
    test.identical( got, expected );

    test.description = 'file record argument';
    got = _.pathGet( fileRecord );
    test.identical( got, expected2 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.pathGet();
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function()
      {
        _.pathGet( 'temp/sample.txt', 'hello' );
      } );

      test.description = 'path is not string/or file record';
      test.shouldThrowError( function()
      {
        _.pathGet( 3 );
      } );
    }
  };

  //

  var pathCopy = function( test )
  {
    var defaults =
      {
        postfix : 'copy',
        srcPath : null
      },
      path1 = 'tmp/pathCopy/test_original.txt',
      expected1 = { path: mergePath( 'tmp/pathCopy/test_original-copy.txt' ), error: false },
      path2 = 'tmp/pathCopy/test_original2',
      expected2 = { path: mergePath( 'tmp/pathCopy/test_original2-backup-2' ), error: false },
      got = { path: void 0, error: void 0 };

    createTestFile( path1 );
    createTestFile( path2 );

    test.description = 'simple existing file path';
    try
    {
      got.path = _.pathCopy( { srcPath: mergePath( path1 ) } );
    }
    catch( err )
    {
      got.error = !!err;
    }
    got.error = !!got.error;
    test.identical( got, expected1 );

    test.description = 'generate names for several copies';
    try
    {
      var path_tmp = _.pathCopy( { srcPath: mergePath( path1 ), postfix: 'backup' } );
      createTestFile( path_tmp );
      path_tmp = _.pathCopy( { srcPath: path_tmp, postfix: 'backup' } );
      createTestFile( path_tmp );
      got.path = _.pathCopy( { srcPath: path_tmp, postfix: 'backup' } );
    }
    catch( err )
    {
      got.error = !!err;
    }
    got.error = !!got.error;
    test.identical( got, expected2 );


    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.pathCopy();
      } );

      test.description = 'extra arguments';
      test.shouldThrowError( function()
      {
        _.pathCopy( { srcPath: mergePath( path1 ) }, { srcPath: mergePath( path2 ) } );
      } );

      test.description = 'unexisting file';
      test.shouldThrowError( function()
      {
        _.pathCopy( { srcPath: 'temp/sample.txt' } );
      } );
    }
  };

  // --
  // proto
  // --

  var Proto =
  {

    name : 'FilesTest',

    tests :
    {

      pathGet: pathGet,
      pathCopy: pathCopy,

    },

    verbose : 1,

  };

  debugger;

  Self.__proto__ = Proto;
  wTests[ Self.name ] = Self;


  createTestsDirectory( testRootDirectory, true );

  _.testing.test( Self );

} )( );
