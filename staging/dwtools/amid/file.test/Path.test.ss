( function _Path_test_ss_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{

  isBrowser = false;

  try
  {
    require( '../../../Base.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  require( '../file/FileTop.s' );
  var Path = require( 'path' );
  var Process = require( 'process' );

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Tester;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;
var testRootDirectory;

//

function testDirMake()
{
  if( !isBrowser )
  testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..' ) );
  else
  testRootDirectory = _.pathCurrent();
}

//

function testDirClean()
{
  _.fileProvider.fileDelete( testRootDirectory );
}

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
    testCheck,
    paths;

  while ( l-- )
  {
    testCheck = cases[ l ];
    switch( testCheck.type )
    {
      case 'f' :
        paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
        paths.forEach( ( path, i ) => {
          path = dir ? Path.join( dir, path ) : path;
          if( testCheck.createResource !== void 0 )
          {
            let res =
              ( Array.isArray( testCheck.createResource ) && testCheck.createResource[i] ) || testCheck.createResource;
            createTestFile( path, res );
          }
          createTestFile( path );
        } );
        break;

      case 'd' :
        paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
        paths.forEach( ( path, i ) =>
        {
          path = dir ? Path.join( dir, path ) : path;
          createInTD( path );
          if ( testCheck.folderContent )
          {
            var res = Array.isArray( testCheck.folderContent ) ? testCheck.folderContent : [ testCheck.folderContent ];
            createTestResources( res, path );
          }
        } );
        break;

      case 'sd' :
      case 'sf' :
        let path, target;
        if( Array.isArray( testCheck.path ) )
        {
          path = dir ? Path.join( dir, testCheck.path[0] ) : testCheck.path[0];
          target = dir ? Path.join( dir, testCheck.path[1] ) : testCheck.path[1];
        }
        else
        {
          path = dir ? Path.join( dir, testCheck.path ) : testCheck.path;
          target = dir ? Path.join( dir, testCheck.linkTarget ) : testCheck.linkTarget;
        }
        createTestSymLink( path, target, testCheck.type, testCheck.createResource );
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
    debugger
    got.path = _.pathForCopy( { path: _.pathResolve( mergePath( path1 ) ) } );
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
    var path_tmp = _.pathForCopy( { path: _.pathResolve( mergePath( path1 ) ), postfix: 'backup' } );
    createTestFile( path_tmp );
    path_tmp = _.pathForCopy( { path: path_tmp, postfix: 'backup' } );
    createTestFile( path_tmp );
    got.path = _.pathForCopy( { path: path_tmp, postfix: 'backup' } );
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
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
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
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
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
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
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
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
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
  var pathBefore = _.pathCurrent();
  _.pathCurrent( mergePath( path1 ) );
  var got = Process.cwd( );
  _.pathCurrent( pathBefore );
  test.identical( got, expected1 );

  if( !Config.debug )
  return;

  test.description = 'extra arguments';
  test.shouldThrowErrorSync( function( )
  {
    _.pathCurrent( 'tmp/pathCurrent/foo', 'tmp/pathCurrent/foo' );
  } );

  test.description = 'unexist directory';
  test.shouldThrowErrorSync( function( )
  {
    _.pathCurrent( mergePath( 'tmp/pathCurrent/bar' ) );
  });

}

//

function pathCurrent2( test )
{
  var got, expected;

  test.description = 'get current working dir';

  if( isBrowser )
  {
    /*default*/

    got = _.pathCurrent();
    expected = '.';
    test.identical( got, expected );

    /*incorrect arguments count*/

    test.shouldThrowErrorSync( function()
    {
      _.pathCurrent( 0 );
    })

  }
  else
  {
    /*default*/

    if( _.fileProvider )
    {

      got = _.pathCurrent();
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );

      /*empty string*/

      expected = _.pathNormalize( process.cwd() );
      got = _.pathCurrent( '' );
      test.identical( got,expected );

      /*changing cwd*/

      got = _.pathCurrent( './staging' );
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );

      /*try change cwd to terminal file*/

      got = _.pathCurrent( './dwtools/amid/file/base/Path.ss' );
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );

    }

    /*incorrect path*/

    test.shouldThrowErrorSync( function()
    {
      got = _.pathCurrent( './incorrect_path' );
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );
    });

    if( Config.debug )
    {
      /*incorrect arguments length*/

      test.shouldThrowErrorSync( function()
      {
        _.pathCurrent( '.', '.' );
      })

      /*incorrect argument type*/

      test.shouldThrowErrorSync( function()
      {
        _.pathCurrent( 123 );
      })
    }

  }

}

//

function pathRelative( test )
{
  test.description = 'path and record';

  var pathFrom = _.fileProvider.fileRecord( _.pathCurrent() );
  var pathTo = _.pathDir( _.pathCurrent() );
  var expected = '..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( _.pathCurrent() );
  var pathTo = _.pathJoin( _.pathDir( _.pathCurrent() ), 'a' )
  var expected = '../a';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.pathDir( _.pathCurrent() );
  var pathTo = _.fileProvider.fileRecord( _.pathCurrent() );
  var expected = _.pathName( pathTo.absolute );
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( _.pathCurrent() );
  var pathTo = _.fileProvider.fileRecord( _.pathDir( _.pathCurrent() ) );
  var expected = '..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( '/a/b/c', { safe : 0 } );
  var pathTo = _.fileProvider.fileRecord( '/a', { safe : 0 } );
  var expected = '../..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( '/a/b/c', { safe : 0 } );
  var pathTo = '/a'
  var expected = '../..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = '/a'
  var pathTo = _.fileProvider.fileRecord( '/a/b/c', { safe : 0 } );
  var expected = 'b/c';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );
}

// --
// proto
// --

var Self =
{

  name : 'FilesPathTest',
  silencing : 1,
  // verbosity : 1,

  onSuiteBegin : testDirMake,
  onSuiteEnd : testDirClean,

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
    pathCurrent2 : pathCurrent2,

    pathRelative : pathRelative


  },

}

// createTestsDirectory( testRootDirectory, true );

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
