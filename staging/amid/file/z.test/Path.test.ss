( function _Path_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

  var _ = wTools;

  _.include( 'wTesting' );

  var File = require( 'fs-extra' );
  var Path = require( 'path' );
  var Process = require( 'process' );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

var FileRecord = _.fileProvider.fileRecord;
var testRootDirectory = _.fileProvider.pathNativize( _.pathResolve( __dirname + '/../../../../tmp.tmp/file-path-test' ) );


// --
// routines
// --

function createTestsDirectory( path, rmIfExists )
{
  // rmIfExists && File.existsSync( path ) && File.removeSync( path );
  // return File.mkdirsSync( path );
  if( rmIfExists && _.fileProvider.fileStat( path ) )
  _.fileProvider.fileDelete( path );
  return _.fileProvider.directoryMake( path );
}

function createInTD( path )
{
  return createTestsDirectory( _.pathJoin( testRootDirectory, path ) );
}

function createTestFile( path, data, decoding )
{
  var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
  // File.createFileSync( _.pathJoin( testRootDirectory, path ) );
  // dataToWrite && File.writeFileSync( _.pathJoin( testRootDirectory, path ), dataToWrite );
  _.fileProvider.fileWrite({ filePath : _.pathJoin( testRootDirectory, path ), data : dataToWrite })
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

  path = _.pathJoin( testRootDirectory, path );
  origin = _.pathResolve( _.pathJoin( testRootDirectory, origin ) );

  // File.existsSync( path ) && File.removeSync( path );
  if( _.fileProvider.fileStat( path ) )
  _.fileProvider.fileDelete( path );
  // File.symlinkSync( origin, path, typeOrigin );
  _.fileProvider.linkSoft( path, origin );
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

function pathGet( test )
{
  var pathStr1 = '/foo/bar/baz',
      pathStr2 = 'tmp/pathGet/test.txt',
    expected = pathStr1,
    expected2 = _.pathResolve( mergePath( pathStr2 ) ),
    got,
    fileRecord;

  createTestFile( pathStr2 );
  fileRecord = _.fileProvider.fileRecord( _.pathResolve( mergePath( pathStr2 ) ) );

  test.description = 'string argument';
  got = _.pathGet( pathStr1 );
  test.identical( got, expected );

  test.description = 'file record argument';
  got = _.pathGet( fileRecord );
  test.identical( got, expected2 );

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathGet( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathGet( 'temp/sample.txt', 'hello' );
    } );

    test.description = 'path is not string/or file record';
    test.shouldThrowErrorSync( function( )
    {
      _.pathGet( 3 );
    } );
  }
};

//

function pathForCopy( test )
{
  var defaults =
    {
      postfix : 'copy',
      srcPath : null
    },
    path1 = 'tmp/pathForCopy/test_original.txt',
    expected1 = { path:  _.pathResolve( mergePath( 'tmp/pathForCopy/test_original-copy.txt' ) ), error: false },
    path2 = 'tmp/pathForCopy/test_original2',
    expected2 = { path: _.pathResolve( mergePath( 'tmp/pathForCopy/test_original-backup-2.txt' ) ), error: false },
    got = { path: void 0, error: void 0 };

  createTestFile( path1 );
  createTestFile( path2 );

  test.description = 'simple existing file path';
  try
  {
    got.path = _.pathForCopy( { srcPath: _.pathResolve( mergePath( path1 ) ) } );
  }
  catch( err )
  {
    _.errLogOnce( err )
    got.error = !!err;
  }
  got.error = !!got.error;
  test.identical( got, expected1 );

  test.description = 'generate names for several copies';
  try
  {
    var path_tmp = _.pathForCopy( { srcPath: _.pathResolve( mergePath( path1 ) ), postfix: 'backup' } );
    createTestFile( path_tmp );
    path_tmp = _.pathForCopy( { srcPath: path_tmp, postfix: 'backup' } );
    createTestFile( path_tmp );
    got.path = _.pathForCopy( { srcPath: path_tmp, postfix: 'backup' } );
  }
  catch( err )
  {
    _.errLogOnce( err )
    got.error = !!err;
  }
  got.error = !!got.error;
  test.identical( got, expected2 );


  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathForCopy( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathForCopy( { srcPath: mergePath( path1 ) }, { srcPath: mergePath( path2 ) } );
    } );

    test.description = 'unexisting file';
    test.shouldThrowErrorSync( function( )
    {
      _.pathForCopy( { srcPath: 'temp/sample.txt' } );
    } );
  }
};

//

function pathRegexpMakeSafe( test )
{

  test.description = 'only default safe paths'; //
  var expected1 =
  {
    includeAny : [],
    includeAll : [],
    excludeAny :
    [
      /node_modules/,
      /\.unique/,
      /\.git/,
      /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-(?!$|\/)/
    ],
    excludeAll: []
  };
  var got = _.pathRegexpMakeSafe();
  // logger.log( 'got',_.toStr( got,{ levels : 3 } ) );
  // logger.log( 'expected1',_.toStr( expected1,{ levels : 3 } ) );
  test.contain( got, expected1 );

  test.description = 'single path for include any mask'; //
  var path2 = 'foo/bar';
  var expected2 =
  {
    includeAny : [ /foo\/bar/ ],
    includeAll : [],
    excludeAny :
    [
      /node_modules/,
      /\.unique/,
      /\.git/,
      /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-(?!$|\/)/,
    ],
    excludeAll: []
  };
  var got = _.pathRegexpMakeSafe( path2 );
  test.contain( got, expected2 );

  test.description = 'array of paths for include any mask'; //
  var path3 = [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ];
  var expected3 =
  {
    includeAny: [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
    includeAll: [],
    excludeAny: [
      /node_modules/,
      /\.unique/,
      /\.git/,
      /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-(?!$|\/)/,
    ],
    excludeAll: []
  };
  var got = _.pathRegexpMakeSafe( path3 );
  test.contain( got, expected3 );

  test.description = 'regex object passed as mask for include any mask'; //
  var paths4 =
  {
    includeAny : [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
    includeAll : [ 'index.js' ],
    excludeAny : [ 'aa.js', 'bb.js' ],
    excludeAll : [ 'package.json', 'bower.json' ]
  };
  var expected4 =
  {
    includeAny : [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
    includeAll : [ /index\.js/ ],
    excludeAny :
    [
      /aa\.js/,
      /bb\.js/,
      /node_modules/,
      /\.unique/,
      /\.git/,
      /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-(?!$|\/)/
    ],
    excludeAll : [ /package\.json/, /bower\.json/ ]
  };
  var got = _.pathRegexpMakeSafe( paths4 );
  test.contain( got, expected4 );

  if( Config.debug ) //
  {
    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathRegexpMakeSafe( 'package.json', 'bower.json' );
    });
  }

}

//

function pathRealMainFile( test )
{
  var expected1 = __filename;

  test.description = 'compare with __filename path for main file';
  var got = _.fileProvider.pathNativize( _.pathRealMainFile( ) );
  test.identical( got, expected1 );
};

//

function pathRealMainDir( test )
{
  var expected1 = Path.dirname( __filename );

  test.description = 'compare with __filename path dir';
  var got = _.fileProvider.pathNativize( _.pathRealMainDir( ) );
  test.identical( got, expected1 );
};

//

function pathEffectiveMainFile( test )
{
  var expected1 = __filename;

  test.description = 'compare with __filename path for main file';
  var got = _.fileProvider.pathNativize( _.pathEffectiveMainFile( ) );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathEffectiveMainFile( 'package.json' );
    } );
  }
};

//

function pathEffectiveMainDir( test )
{
  var expected1 = Path.dirname( __filename );

  test.description = 'compare with __filename path dir';
  var got = _.fileProvider.pathNativize( _.pathEffectiveMainDir( ) );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathEffectiveMainDir( 'package.json' );
    } );
  }
};

//

function pathCurrent( test )
{
  var path1 = 'tmp/pathCurrent/foo',
    expected = Process.cwd( ),
    expected1 = _.fileProvider.pathNativize( _.pathResolve( mergePath( path1 ) ) );

  test.description = 'get current working directory';
  var got = _.fileProvider.pathNativize( _.pathCurrent( ) );
  test.identical( got, expected );

  test.description = 'set new current working directory';
  createInTD( path1 );
  _.pathCurrent( mergePath( path1 ) );
  var got = Process.cwd( );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.description = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathCurrent( 'tmp/pathCurrent/foo', 'tmp/pathCurrent/foo' );
    } );

    test.description = 'unexist directory';
    test.shouldThrowErrorSync( function( )
    {
      _.pathCurrent( mergePath( 'tmp/pathCurrent/bar' ) );
    } );
  }
};

// --
// proto
// --

var Self =
{

  name : 'FilesPathTest',
  sourceFilePath : sourceFilePath,
  verbosity : 1,

  tests :
  {

    pathGet : pathGet,
    pathForCopy : pathForCopy,

    pathRegexpMakeSafe : pathRegexpMakeSafe,

    pathRealMainFile : pathRealMainFile,
    pathRealMainDir : pathRealMainDir,
    pathEffectiveMainFile : pathEffectiveMainFile,
    pathEffectiveMainDir : pathEffectiveMainDir,
    pathCurrent : pathCurrent,


  },

}

createTestsDirectory( testRootDirectory, true );

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
