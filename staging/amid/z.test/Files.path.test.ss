( function _File_path_test_ss_( ) {

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

  require( '../file/Files.ss' );

  var File = require( 'fs-extra' );
  var Path = require( 'path' );
  var Process = require( 'process' );

}

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

var _ = wTools;
var FileRecord = _.FileRecord;
var testRootDirectory = __dirname + '/../../../tmp.tmp/file-path-test';

var Self = {};

// --
// test
// --

var getSource = function( v )
{
  return ( typeof v === 'string' ) ? v : v.source;
};

var getSourceFromMap = function( resultObj )
{
  var i;
  for( i in resultObj )
  Object.hasOwnProperty.call( resultObj,i ) && ( resultObj[ i ] = resultObj[ i ].map( getSource ) );
};

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
  path = ( path.indexOf( Path.resolve( testRootDirectory ) ) >= 0 ) ? path : Path.join( testRootDirectory, path );
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
  fileRecord = FileRecord( Path.resolve( mergePath( pathStr2 ) ) );

  test.description = 'string argument';
  got = _.pathGet( pathStr1 );
  test.identical( got, expected );

  test.description = 'file record argument';
  got = _.pathGet( fileRecord );
  test.identical( got, expected2 );

  if( Config.debug )
  {
    test.description = 'missed arguments';
    test.shouldThrowError( function( )
    {
      _.pathGet( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathGet( 'temp/sample.txt', 'hello' );
    } );

    test.description = 'path is not string/or file record';
    test.shouldThrowError( function( )
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
    expected1 = { path:  Path.resolve( mergePath( 'tmp/pathCopy/test_original-copy.txt' ) ), error: false },
    path2 = 'tmp/pathCopy/test_original2',
    expected2 = { path: Path.resolve( mergePath( 'tmp/pathCopy/test_original-backup-2.txt' ) ), error: false },
    got = { path: void 0, error: void 0 };

  createTestFile( path1 );
  createTestFile( path2 );

  test.description = 'simple existing file path';
  try
  {
    got.path = _.pathCopy( { srcPath: Path.resolve( mergePath( path1 ) ) } );
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
    var path_tmp = _.pathCopy( { srcPath: Path.resolve( mergePath( path1 ) ), postfix: 'backup' } );
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
    test.shouldThrowError( function( )
    {
      _.pathCopy( );
    } );

    test.description = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathCopy( { srcPath: mergePath( path1 ) }, { srcPath: mergePath( path2 ) } );
    } );

    test.description = 'unexisting file';
    test.shouldThrowError( function( )
    {
      _.pathCopy( { srcPath: 'temp/sample.txt' } );
    } );
  }
};

//

var pathNormalize = function( test )
{
  var path1 = '/foo/bar//baz/asdf/quux/..',
    expected1 = '/foo/bar/baz/asdf',
    path2 = 'C:\\temp\\\\foo\\bar\\..\\',
    expected2 = 'C:/temp//foo/bar/../',
    path3 = '',
    expected3 = '.',
    path4 = 'foo/./bar/baz/',
    expected4 = 'foo/bar/baz/',
    got;

  test.description = 'posix path';
  got = _.pathNormalize( path1 );
  test.identical( got, expected1 );

  test.description = 'winoows path';
  got = _.pathNormalize( path2 );
  test.identical( got, expected2 );

  test.description = 'empty path';
  got = _.pathNormalize( path3 );
  test.identical( got, expected3 );

  test.description = 'path with "." section';
  got = _.pathNormalize( path4 );
  test.identical( got, expected4 );

};

//

var pathRelative = function( test )
{
  var pathFrom1 = '/foo/bar/baz/asdf/quux',
    pathTo1 = '/foo/bar/baz/asdf/quux',
    expected1 = '.',

    pathFrom2 = '/foo/bar/baz/asdf/quux',
    pathTo2 = '/foo/bar/baz/asdf/quux/new1',
    expected2 = 'new1',

    pathFrom3 = '/foo/bar/baz/asdf/quux',
    pathTo3 = '/foo/bar/baz/asdf',
    expected3 = '..',

    pathFrom4 = '/foo/bar/baz/asdf/quux/dir1/dir2',
    pathTo4 =
    [
      '/foo/bar/baz/asdf/quux/dir1/dir2',
      '/foo/bar/baz/asdf/quux/dir1/',
      '/foo/bar/baz/asdf/quux/',
      '/foo/bar/baz/asdf/quux/dir1/dir2/dir3'
    ],
    expected4 = [ '.', '..', '../..', 'dir3' ],

    path5 = 'tmp/pathRelative/foo/bar/test',
    pathTo5 = 'tmp/pathRelative/foo/',
    expected5 = '../..',

    got;

  test.description = 'relative to same path';
  got = _.pathRelative( pathFrom1, pathTo1 );
  test.identical( got, expected1 );

  test.description = 'relative to nested';
  got = _.pathRelative( pathFrom2, pathTo2 );
  test.identical( got, expected2 );

  test.description = 'relative to parent directory';
  got = _.pathRelative( pathFrom3, pathTo3 );
  test.identical( got, expected3 );

  test.description = 'relative to array of paths';
  got = _.pathRelative( pathFrom4, pathTo4 );
  test.identical( got, expected4 );

  test.description = 'using file record';
  createTestFile( path5 );
  var fr = FileRecord( Path.resolve( mergePath( path5 ) ) );
  got =  _.pathRelative( fr, Path.resolve( mergePath( pathTo5 ) ) );
  test.identical( got, expected5 );

  if( Config.debug )
  {
    test.pathRelative = 'missed arguments';
    test.shouldThrowError( function( )
    {
      _.pathRelative( pathFrom1 );
    } );

    test.description = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathRelative( pathFrom3, pathTo3, pathTo4 );
    } );

    test.description = 'second argument is not string or array';
    test.shouldThrowError( function( )
    {
      _.pathRelative( pathFrom3, null );
    } );
  }

};

//

var pathResolve = function( test ) {
  var paths1 = [ '/foo', 'bar/', 'baz' ],
    expected1 = '/foo/bar/baz',

    paths2 = [ '/foo', '/bar/', 'baz' ],
    expected2 = '/bar/baz',

    path3 = '/foo/bar/baz/asdf/quux',
    expected3 = '/foo/bar/baz/asdf/quux',
    got;

  test.description = 'several part of path';
  got = _.pathResolve.apply( _, paths1 );
  test.identical( got, expected1 );

  test.description = 'with root';
  got = _.pathResolve.apply( _, paths2 );
  test.identical( got, expected2 );

  test.description = 'one absolute path';
  got = _.pathResolve( path3 );
  test.identical( got, expected3 );
};

//

var pathIsSafe = function( test )
{
  var path1 = '/home/user/dir1/dir2',
    path2 = 'C:/foo/baz/bar',
    path3 = '/foo/bar/.hidden',
    path4 = '/foo/./somedir',
    path5 = 'c:foo/',
    got;

  test.description = 'safe posix path';
  got = _.pathIsSafe( path1 );
  test.identical( got, true );

  test.description = 'safe windows path';
  got = _.pathIsSafe( path2 );
  test.identical( got, true );

  test.description = 'unsafe posix path ( hidden )';
  got = _.pathIsSafe( path3 );
  test.identical( got, false );

  test.description = 'safe posix path with "." segment';
  got = _.pathIsSafe( path4 );
  test.identical( got, true );

  test.description = 'unsafe windows path';
  got = _.pathIsSafe( path5 );
  test.identical( got, false );

  if( Config.debug )
  {
    test.pathRelative = 'missed arguments';
    test.shouldThrowError( function( )
    {
      _.pathIsSafe( );
    } );

    test.description = 'second argument is not string';
    test.shouldThrowError( function( )
    {
      _.pathIsSafe( null );
    } );
  }
};

//

var pathRegexpSafeShrink = function( test )
{
  var expected1 =
    {
      includeAny: [],
      includeAll: [],
      excludeAny: [
        /node_modules/,
        /\.unique/,
        /\.git/,
        /\.svn/,
        /(^|\/)\.(?!$|\/)/,
        /(^|\/)-(?!$|\/)/
      ],
      excludeAll: []
    },

    path2 = 'foo/bar',
    expected2 =
    {
      includeAny: [ /foo\/bar/ ],
      includeAll: [],
      excludeAny: [
        /node_modules/,
        /\.unique/,
        /\.git/,
        /\.svn/,
        /(^|\/)\.(?!$|\/)/,
        /(^|\/)-(?!$|\/)/,
      ],
      excludeAll: []
    },

    path3 = [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
    expected3 =
    {
      includeAny: [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
      includeAll: [],
      excludeAny: [
        /node_modules/,
        /\.unique/,
        /\.git/,
        /\.svn/,
        /(^|\/)\.(?!$|\/)/,
        /(^|\/)-(?!$|\/)/,
      ],
      excludeAll: []
    },

    paths4 = {
      includeAny: [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
      includeAll: [ 'index.js' ],
      excludeAny: [ 'Gruntfile.js', 'gulpfile.js' ],
      excludeAll: [ 'package.json', 'bower.json' ]
    },
    expected4 =
    {
      includeAny: [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
      includeAll: [ /index\.js/ ],
      excludeAny: [
        /Gruntfile\.js/,
        /gulpfile\.js/,
        /node_modules/,
        /\.unique/,
        /\.git/,
        /\.svn/,
        /(^|\/)\.(?!$|\/)/,
        /(^|\/)-(?!$|\/)/
      ],
      excludeAll: [ /package\.json/, /bower\.json/ ]
    },
    got;

  test.description = 'only default safe paths';
  got = _.pathRegexpSafeShrink( );
  getSourceFromMap( got );
  getSourceFromMap( expected1 );
  test.identical( got, expected1 );

  test.description = 'single path for include any mask';
  got = _.pathRegexpSafeShrink( path2 );
  getSourceFromMap( got );
  getSourceFromMap( expected2 );
  test.identical( got, expected2 );

  test.description = 'array of paths for include any mask';
  got = _.pathRegexpSafeShrink( path3 );
  getSourceFromMap( got );
  getSourceFromMap( expected3 );
  test.identical( got, expected3 );

  test.description = 'regex object passed as mask for include any mask';
  got = _.pathRegexpSafeShrink( paths4 );
  getSourceFromMap( got );
  getSourceFromMap( expected4 );
  test.identical( got, expected4 );


  if( Config.debug )
  {
    test.pathRelative = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathRegexpSafeShrink( 'package.json', 'bower.json' );
    } );
  }
};

//

var pathMainFile = function( test )
{
  var expected1 = __filename;

  test.description = 'compare with __filename path for main file';
  var got = _.pathMainFile( );
  test.identical( got, expected1 );
};

//

var pathMainDir = function( test )
{
  var expected1 = Path.dirname( __filename );

  test.description = 'compare with __filename path dir';
  var got = _.pathMainDir( );
  test.identical( got, expected1 );
};

//

var pathBaseFile = function( test )
{
  var expected1 = __filename;

  test.description = 'compare with __filename path for main file';
  var got = _.pathBaseFile( );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.pathRelative = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathBaseFile( 'package.json' );
    } );
  }
};

//

var pathBaseDir = function( test )
{
  var expected1 = Path.dirname( __filename );

  test.description = 'compare with __filename path dir';
  var got = _.pathBaseDir( );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.pathRelative = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathBaseDir( 'package.json' );
    } );
  }
};

//

var pathCurrent = function( test )
{
  var path1 = 'tmp/pathCurrent/foo',
    expected = Process.cwd( ),
    expected1 = Path.resolve( mergePath( path1 ) );

  test.description = 'get current working directory';
  var got = _.pathCurrent( );
  test.identical( got, expected );

  test.description = 'set new current working directory';
  createInTD( path1 );
  _.pathCurrent( mergePath( path1 ) );
  var got = Process.cwd( );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.pathRelative = 'extra arguments';
    test.shouldThrowError( function( )
    {
      _.pathCurrent( 'tmp/pathCurrent/foo', 'tmp/pathCurrent/foo' );
    } );

    test.pathRelative = 'unexist directory';
    test.shouldThrowError( function( )
    {
      _.pathCurrent( mergePath( 'tmp/pathCurrent/bar' ) );
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

    pathGet : pathGet,
    pathCopy : pathCopy,
    pathNormalize : pathNormalize,
    pathRelative : pathRelative,
    pathResolve : pathResolve,
    pathIsSafe : pathIsSafe,
    pathRegexpSafeShrink : pathRegexpSafeShrink,
    pathMainFile : pathMainFile,
    pathMainDir : pathMainDir,
    pathBaseFile : pathBaseFile,
    pathBaseDir : pathBaseDir,
    pathCurrent : pathCurrent,

  },

  verbose : 1,

};

_.mapExtend( Self,Proto );
wTests[ Self.name ] = Self;

createTestsDirectory( testRootDirectory, true );

if( typeof module !== 'undefined' && !module.parent )
_.testing.test( Self );

} )( );
