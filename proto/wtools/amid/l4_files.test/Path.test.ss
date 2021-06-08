( function _Path_test_ss_()
{

'use strict';

var Path, Process;

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  if( !_global_.wTools.FileProvider )
  require( '../l4_files/entry/Files.s' );
  Path = require( 'path' );
  Process = require( 'process' );

  _.include( 'wTesting' );

}

//

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
const Parent = wTester;

//

function onSuiteBegin()
{
  this.isBrowser = typeof module === 'undefined';

  if( !this.isBrowser )
  {
    this.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'Path' );
    this.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  }
  else
  {
    this.suiteTempPath = _.path.current();
  }
}

//

function onSuiteEnd()
{
  if( !this.isBrowser )
  {
    _.assert( _.strHas( this.suiteTempPath, '.tmp' ), this.suiteTempPath );
    _.path.tempClose( this.suiteTempPath );
  }
}

// --
// implementation
// --

function createTestsDirectory( path, rmIfExists )
{
  if( rmIfExists && _.fileProvider.statResolvedRead( path ) )
  _.fileProvider.filesDelete( path );
  return _.fileProvider.dirMake( path );
}

//

function createInTD( path )
{
  return this.createTestsDirectory( _.path.join( this.suiteTempPath, path ) );
}

//

function createTestFile( path, data, decoding )
{
  if( data === undefined )
  data = path;

  var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
  _.fileProvider.fileWrite({ filePath : _.path.join( this.suiteTempPath, path ), data : dataToWrite })
}

//

function createTestSymLink( /* path, target, type, data */ )
{
  let path = arguments[ 0 ];
  let target = arguments[ 1 ];
  let type = arguments[ 2 ];
  let data = arguments[ 3 ];

  var origin, typeOrigin;

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
    this.createTestFile( origin, data );
  }
  else if( 'sd' === type )
  {
    typeOrigin = 'dir';
    this.createInTD( origin );
  }
  else throw new Error( 'unexpected type' );

  path = _.path.join( this.suiteTempPath, path );
  origin = _.path.resolve( _.path.join( this.suiteTempPath, origin ) );

  if( _.fileProvider.statResolvedRead( path ) )
  _.fileProvider.filesDelete( path );
  _.fileProvider.softLink( path, origin );
}

//

function createTestResources( cases, dir )
{
  if( !Array.isArray( cases ) ) cases = [ cases ];

  var l = cases.length;
  var testCheck, paths;
  let path, target;

  while( l-- )
  {
    testCheck = cases[ l ];
    switch( testCheck.type )
    {
    case( 'f' ) :
      paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
      paths.forEach( ( path, i ) =>
      {
        path = dir ? Path.join( dir, path ) : path;
        // if( testCheck.createResource !== void 0 )
        if( testCheck.createResource !== undefined )
        {
          let res =
            ( Array.isArray( testCheck.createResource ) && testCheck.createResource[ i ] ) || testCheck.createResource;
          this.createTestFile( path, res );
        }
        this.createTestFile( path );
      });
      break;

    case( 'd' ) :
      paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
      paths.forEach( ( path, i ) =>
      {
        path = dir ? Path.join( dir, path ) : path;
        this.createInTD( path );
        if( testCheck.folderContent )
        {
          var res = Array.isArray( testCheck.folderContent ) ? testCheck.folderContent : [ testCheck.folderContent ];
          this.createTestResources( res, path );
        }
      });
      break;

    case( 'sd' ) :
    case( 'sf' ) :
      if( Array.isArray( testCheck.path ) )
      {
        path = dir ? Path.join( dir, testCheck.path[ 0 ] ) : testCheck.path[ 0 ];
        target = dir ? Path.join( dir, testCheck.path[ 1 ] ) : testCheck.path[ 1 ];
      }
      else
      {
        path = dir ? Path.join( dir, testCheck.path ) : testCheck.path;
        target = dir ? Path.join( dir, testCheck.linkTarget ) : testCheck.linkTarget;
      }
      this.createTestSymLink( path, target, testCheck.type, testCheck.createResource );
      break;
    default :
      break;
    }
  }
}

// --
// test
// --

function like( test )
{
  test.case = 'file record';
  var src = _.fileProvider.record( process.env.HOME || process.env.USERPROFILE );
  var expected = true;
  var got = _.path.like( src );
  test.identical( got, expected );

  /* */

  test.case = 'Empty string';
  var expected = true;
  var got = _.path.like( '' );
  test.identical( got, expected );

  test.case = 'Empty path';
  var expected = true;
  var got = _.path.like( '/' );
  test.identical( got, expected );

  test.case = 'Simple string';
  var expected = true;
  var got = _.path.like( 'hello' );
  test.identical( got, expected );

  test.case = 'Simple path string';
  var expected = true;
  var got = _.path.like( '/D/work/f' );
  test.identical( got, expected );

  test.case = 'Relative path';
  var expected = true;
  var got = _.path.like( '/home/user/dir1/dir2' );
  test.identical( got, expected );

  test.case = 'Absolute path';
  var expected = true;
  var got = _.path.like( 'C:/foo/baz/bar' );
  test.identical( got, expected );

  test.case = 'Other path';
  var expected = true;
  var got = _.path.like( 'c:\\foo\\' );
  test.identical( got, expected );

  /* */

  test.case = 'No path - regexp';
  var expected = false;
  var got = _.path.like( /foo/ );
  test.identical( got, expected );

  test.case = 'No path - number';
  var expected = false;
  var got = _.path.like( 3 );
  test.identical( got, expected );

  test.case = 'No path - array';
  var expected = false;
  var got = _.path.like( [ '/C/', 'work/f' ] );
  test.identical( got, expected );

  test.case = 'No path - object';
  var expected = false;
  var got = _.path.like( { Path : 'C:/foo/baz/bar' } );
  test.identical( got, expected );

  test.case = 'No path - undefined';
  var expected = false;
  var got = _.path.like( undefined );
  test.identical( got, expected );

  test.case = 'No path - null';
  var expected = false;
  var got = _.path.like( null );
  test.identical( got, expected );

  test.case = 'No path - NaN';
  var expected = false;
  var got = _.path.like( NaN );
  test.identical( got, expected );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'No arguments';
  test.shouldThrowErrorOfAnyKind( () => _.path.like( ) );

  test.case = 'Two arguments';
  test.shouldThrowErrorOfAnyKind( () => _.path.like( 'a', 'b' ) );
}

//

function from( test )
{
  var str1 = '/foo/bar/baz';
  var str2 = 'tmp/get/test.txt';
  var expected = str1;
  var expected2 = _.path.resolve( _.path.join( test.context.suiteTempPath, str2 ) );
  var got, fileRecord;

  test.context.createTestFile( str2 );
  fileRecord = _.fileProvider.recordFactory().record( _.path.resolve( _.path.join( test.context.suiteTempPath, str2 ) ) );

  test.case = 'string argument';
  got = _.path.from( str1 );
  test.identical( got, expected );

  test.case = 'file record argument';
  got = _.path.from( fileRecord );
  test.identical( got, expected2 );

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.path.from( );
    } );

    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.path.from( 'temp/sample.txt', 'hello' );
    } );

    test.case = 'path is not string/or file record';
    test.shouldThrowErrorSync( function( )
    {
      _.path.from( 3 );
    } );
  }
};

//

function forCopy( test )
{

  var defaults =
  {
    postfix : 'copy',
    srcPath : null
  };
  var path1 = 'tmp/forCopy/test_original.txt';
  var expected1 = { path :  _.path.resolve( _.path.join( test.context.suiteTempPath, 'tmp/forCopy/test_original-copy.txt' ) ), error : false };
  var path2 = 'tmp/forCopy/test_original2';
  var expected2 = { path : _.path.resolve( _.path.join( test.context.suiteTempPath, 'tmp/forCopy/test_original2-backup-2' ) ), error : false };
  var got = { path : undefined, error : undefined };
  // var got = { path : void 0, error : void 0 };

  test.context.createTestFile( path1 );
  test.context.createTestFile( path2 );

  test.case = 'simple existing file path';
  try
  {
    got.path = _.path.forCopy( { filePath : _.path.resolve( _.path.join( test.context.suiteTempPath, path1 ) ) } );
  }
  catch( err )
  {
    _.errLogOnce( err )
    got.error = !!err;
  }
  got.error = !!got.error;
  test.identical( got, expected1 );

  test.case = 'generate names for several copies';
  try
  {
    var path_tmp = _.path.forCopy( { filePath : _.path.resolve( _.path.join( test.context.suiteTempPath, path2 ) ), postfix : 'backup' } );
    test.context.createTestFile( path_tmp );
    path_tmp = _.path.forCopy( { filePath : path_tmp, postfix : 'backup' } );
    test.context.createTestFile( path_tmp );
    got.path = _.path.forCopy( { filePath : path_tmp, postfix : 'backup' } );
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
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.path.forCopy( );
    } );

    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.path.forCopy
      (
        { srcPath : _.path.join( test.context.suiteTempPath, path1 ) },
        { srcPath : _.path.join( test.context.suiteTempPath, path2 ) }
      );
    } );

    test.case = 'unexisting file';
    test.shouldThrowErrorSync( function( )
    {
      _.path.forCopy( { srcPath : 'temp/sample.txt' } );
    } );
  }

}

//

function pathResolve( test )
{

  var provider = _.fileProvider;

  test.case = 'join windows os paths';
  var paths = [ 'c:\\', 'foo\\', 'bar\\' ];
  var expected = '/c/foo/bar/';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  test.case = 'join unix os paths';
  var paths = [ '/bar/', '/baz', 'foo/', '.' ];
  var expected = '/baz/foo';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  /* */

  test.case = 'here cases';

  var paths = [ 'aa', '.', 'cc' ];
  var expected = _.path.join( _.path.current(), 'aa/cc' );
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  'aa', 'cc', '.' ];
  var expected = _.path.join( _.path.current(), 'aa/cc' );
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '.', 'aa', 'cc' ];
  var expected = _.path.join( _.path.current(), 'aa/cc' );
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  /* */

  test.case = 'down cases';

  var paths = [  '.', 'aa', 'cc', '..' ];
  var expected = _.path.join( _.path.current(), 'aa' );
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '.', 'aa', 'cc', '..', '..' ];
  var expected = _.path.current();
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  console.log( '_.path.current()', _.path.current() );
  var paths = [  'aa', 'cc', '..', '..', '..' ];
  var expected = _.strIsolateRightOrNone( _.path.current(), '/' )[ 0 ];
  if( _.path.current() === '/' )
  expected = '/..';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  /* */

  test.case = 'like-down or like-here cases';

  var paths = [  '.x.', 'aa', 'bb', '.x.' ];
  var expected = _.path.join( _.path.current(), '.x./aa/bb/.x.' );
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '..x..', 'aa', 'bb', '..x..' ];
  var expected = _.path.join( _.path.current(), '..x../aa/bb/..x..' );
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  /* */

  test.case = 'period and double period combined';

  var paths = [  '/abc', './../a/b' ];
  var expected = '/a/b';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '/abc', 'a/.././a/b' ];
  var expected = '/abc/a/b';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '/abc', '.././a/b' ];
  var expected = '/a/b';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '/abc', './.././a/b' ];
  var expected = '/a/b';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '/abc', './../.' ];
  var expected = '/';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '/abc', './../../.' ];
  var expected = '/..';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  var paths = [  '/abc', './../.' ];
  var expected = '/';
  var got = provider.path.resolve.apply( provider.path, paths );
  test.identical( got, expected );

  if( !Config.debug ) //
  return;

  test.case = 'nothing passed';
  var expected = provider.path.current();
  var got = provider.path.resolve( '.' );
  test.identical( got, expected )


  test.case = 'non string passed';
  test.shouldThrowErrorSync( function()
  {
    provider.path.resolve( {} );
  });
}

//

function pathsResolve( test )
{
  var provider = _.fileProvider;
  var currentPath = _.path.current();

  test.case = 'paths resolve';

  var got = provider.path.s.resolve( 'c', [ '/a', 'b' ] );
  var expected = [ '/a', _.path.join( currentPath, 'c/b' ) ];
  test.identical( got, expected );

  var got = provider.path.s.resolve( [ '/a', '/b' ], [ '/a', '/b' ] );
  var expected = [ '/a', '/b' ];
  test.identical( got, expected );

  var got = provider.path.s.resolve( '../a', [ 'b', '.c' ] );
  var expected = [ _.path.dirFirst( currentPath ) + 'a/b', _.path.dirFirst( currentPath ) + 'a/.c' ]
  test.identical( got, expected );

  var got = provider.path.s.resolve( '../a', [ '/b', '.c' ], './d' );
  var expected = [ '/b/d', _.path.dirFirst( currentPath ) + 'a/.c/d' ];
  test.identical( got, expected );

  var got = provider.path.s.resolve( [ '/a', '/a' ], [ 'b', 'c' ] );
  var expected = [ '/a/b', '/a/c' ];
  test.identical( got, expected );

  var got = provider.path.s.resolve( [ '/a', '/a' ], [ 'b', 'c' ], 'e' );
  var expected = [ '/a/b/e', '/a/c/e' ];
  test.identical( got, expected );

  var got = provider.path.s.resolve( [ '/a', '/a' ], [ 'b', 'c' ], '/e' );
  var expected = [ '/e', '/e' ];
  test.identical( got, expected );

  var got = provider.path.s.resolve( '.', '../', './', [ 'a', 'b' ] );
  var expected = [ _.path.dirFirst( currentPath ) + 'a', _.path.dirFirst( currentPath ) + 'b' ];
  test.identical( got, expected );

  //

  test.case = 'works like path resolve';

  var got = provider.path.s.resolve( '/a', 'b', 'c' );
  var expected = provider.path.resolve( '/a', 'b', 'c' );
  test.identical( got, expected );

  var got = provider.path.s.resolve( '/a', 'b', 'c' );
  var expected = provider.path.resolve( '/a', 'b', 'c' );
  test.identical( got, expected );

  var got = provider.path.s.resolve( '../a', '.c' );
  var expected = provider.path.resolve( '../a', '.c' );
  test.identical( got, expected );

  var got = provider.path.s.resolve( '/a' );
  var expected = provider.path.resolve( '/a' );
  test.identical( got, expected );

  //

  test.case = 'scalar + array with single argument'

  var got = provider.path.s.resolve( '/a', [ 'b/..' ] );
  var expected = [ '/a' ];
  test.identical( got, expected );

  test.case = 'array + array with single arguments'

  var got = provider.path.s.resolve( [ '/a' ], [ 'b/../' ] );
  var expected = [ '/a/' ];
  test.identical( got, expected );

  test.case = 'single array';

  var got = _.path.s.resolve( [ '/a', 'b', './b', '../b', '../' ] );
  var expected =
  [
    '/a',
    _.path.join( currentPath, 'b' ),
    _.path.join( currentPath, 'b' ),
    _.path.join( _.path.dir( currentPath ), 'b' ),

    _.path.trail( _.path.normalize( _.path.dir( currentPath ) ) )
    //_.path.normalize( _.path.dir( currentPath ) ),
    // routine normalizeStrict does not exist now
    // _.path.normalizeStrict( _.path.dir( currentPath ) )

  ];
  test.identical( got, expected );

  /* - */

  if( !Config.debug )
  return

  test.case = 'empty str'
  test.shouldThrowErrorSync( function()
  {
    rovider.path.s.resolve( '' )
  });

  test.case = 'no arguments'
  test.shouldThrowErrorSync( function()
  {
    rovider.path.s.resolve()
  });

  // test.case = 'without arguments';
  // test.shouldThrowErrorSync( () =>
  // {
  //   debugger;
  //   provider.path.s.resolve();
  //   debugger;
  // });

  test.case = 'arrays with different length'
  test.shouldThrowErrorSync( function()
  {
    provider.path.s.resolve( [ '/b', '.c' ], [ '/b' ] );
  });

  test.case = 'inner arrays'
  test.shouldThrowErrorSync( function()
  {
    provider.path.s.resolve( [ '/b', '.c' ], [ '/b', [ 'x' ] ] );
  });
}

//

function regexpMakeSafe( test )
{

  /* */

  test.case = 'only default safe paths';
  var expected1 =
  {
    includeAny : [],
    includeAll : [],
    excludeAny :
    [
      /\.(?:unique|git|svn|hg|DS_Store|tmp)(?:$|\/)/,
      /(^|\/)-/,
    ],
    excludeAll : []
  };
  var got = _.files.regexpMakeSafe();
  // logger.log( 'got', _.entity.exportString( got,{ levels : 3 } ) );
  // logger.log( 'expected1', _.entity.exportString( expected1,{ levels : 3 } ) );
  test.identical( got.includeAny, expected1.includeAny );
  test.identical( got.includeAll, expected1.includeAll );
  test.identical( got.excludeAny, expected1.excludeAny );
  test.identical( got.excludeAll, expected1.excludeAll );

  /* */

  test.case = 'single path for include any mask';
  var path2 = 'foo/bar';
  var expected2 =
  {
    includeAny : [ /foo\/bar/ ],
    includeAll : [],
    excludeAny :
    [
      /\.(?:unique|git|svn|hg|DS_Store|tmp)(?:$|\/)/,
      /(^|\/)-/,
    ],
    excludeAll : []
  };
  var got = _.files.regexpMakeSafe( path2 );
  test.identical( got.includeAny, expected2.includeAny );
  test.identical( got.includeAll, expected2.includeAll );
  test.identical( got.excludeAny, expected2.excludeAny );
  test.identical( got.excludeAll, expected2.excludeAll );

  /* */

  test.case = 'array of paths for include any mask';
  var path3 = [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ];
  var expected3 =
  {
    includeAny : [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
    includeAll : [],
    excludeAny :
    [
      /\.(?:unique|git|svn|hg|DS_Store|tmp)(?:$|\/)/,
      /(^|\/)-/,
    ],
    excludeAll : []
  };
  var got = _.files.regexpMakeSafe( path3 );
  test.identical( got.includeAny, expected3.includeAny );
  test.identical( got.includeAll, expected3.includeAll );
  test.identical( got.excludeAny, expected3.excludeAny );
  test.identical( got.excludeAll, expected3.excludeAll );

  /* */

  test.case = 'regex object passed as mask for include any mask';
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
      /\.(?:unique|git|svn|hg|DS_Store|tmp)(?:$|\/)/,
      /(^|\/)-/,
      /aa\.js/,
      /bb\.js/
    ],
    excludeAll : [ /package\.json/, /bower\.json/ ]
  };
  var got = _.files.regexpMakeSafe( paths4 );
  test.identical( got.includeAny, expected4.includeAny );
  test.identical( got.includeAll, expected4.includeAll );
  test.identical( got.excludeAny, expected4.excludeAny );
  test.identical( got.excludeAll, expected4.excludeAll );

  /* - */

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.files.regexpMakeSafe( 'package.json', 'bower.json' );
    });
  }

}

//

function effectiveMainDir( test )
{
  if( require.main === module )
  var file = __filename;
  else
  var file = process.argv[ 1 ];

  var expected1 = _.path.dir( file );

  test.case = 'compare with __filename path dir';
  var got = _.fileProvider.path.nativize( _.path.effectiveMainDir( ) );
  test.identical( _.path.normalize( got ), _.path.normalize( expected1 ) );

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.path.effectiveMainDir( 'package.json' );
    } );
  }
};

//

function pathCurrent( test )
{
  var path1 = 'tmp/pathCurrent/foo';
  var expected = Process.cwd();
  var expected1 = _.fileProvider.path.nativize( _.path.resolve( _.path.join( test.context.suiteTempPath, path1 ) ) );

  test.case = 'get pathCurrent working directory';
  var got = _.fileProvider.path.nativize( _.path.current( ) );
  test.identical( got, expected );

  test.case = 'set new pathCurrent working directory';
  test.context.createInTD( path1 );
  var before = _.path.current();
  _.path.current( _.path.normalize( _.path.join( test.context.suiteTempPath, path1 ) ) );
  var got = Process.cwd();
  _.path.current( before );
  test.identical( got, expected1 );

  if( !Config.debug )
  return;

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( function( )
  {
    _.path.current( 'tmp/pathCurrent/foo', 'tmp/pathCurrent/foo' );
  } );

  test.case = 'unexist directory';
  test.shouldThrowErrorSync( function( )
  {
    _.path.current( _.path.join( test.context.suiteTempPath, 'tmp/pathCurrent/bar' ) );
  });

}

//

function pathCurrent2( test )
{
  var got, expected;

  test.case = 'get pathCurrent working dir';

  if( test.context.isBrowser )
  {
    /*default*/

    got = _.path.current();
    expected = '.';
    test.identical( got, expected );

    /*incorrect arguments count*/

    test.shouldThrowErrorSync( function()
    {
      _.path.current( 0 );
    })

  }
  else
  {
    /*default*/

    if( _.fileProvider )
    {

      got = _.path.current();
      expected = _.path.normalize( process.cwd() );
      test.identical( got, expected );

      /*empty string*/

      expected = _.path.normalize( process.cwd() );
      got = _.path.current( '' );
      test.identical( got, expected );

      /*changing cwd*/

      got = _.path.current( '..' );
      expected = _.path.normalize( process.cwd() );
      test.identical( got, expected );

      /*try change cwd to terminal file*/

      // got = _.path.current( './wtools/amid/l3/files/alayer1/Path.ss' );
      got = _.path.current( _.path.normalize( __filename ) );
      expected = _.path.normalize( process.cwd() );
      test.identical( got, expected );

    }

    /*incorrect path*/

    test.shouldThrowErrorSync( function()
    {
      got = _.path.current( './incorrect_path' );
      expected = _.path.normalize( process.cwd() );
      test.identical( got, expected );
    });

    if( Config.debug )
    {
      /*incorrect arguments length*/

      test.shouldThrowErrorSync( function()
      {
        _.path.current( '.', '.' );
      })

      /*incorrect argument type*/

      test.shouldThrowErrorSync( function()
      {
        _.path.current( 123 );
      })
    }

  }

}

//

function relative( test )
{
  test.case = 'path and record';

  var from = _.fileProvider.recordFactory().record( _.path.current() );
  var to = _.path.dir( _.path.current() );
  var expected = '..';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  var from = _.fileProvider.recordFactory().record( _.path.current() );
  var to = _.path.join( _.path.dir( _.path.current() ), 'a' )
  var expected = '../a';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  var from = _.path.dir( _.path.current() );
  var to = _.fileProvider.recordFactory().record( _.path.current() );
  var expected = _.path.name({ path : to.absolute, full : 1 });
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  var from = _.fileProvider.recordFactory().record( _.path.current() );
  var to = _.fileProvider.recordFactory().record( _.path.dir( _.path.current() ) );
  var expected = '..';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  _.fileProvider.fieldPush( 'safe', 0 );

  var from = _.fileProvider.recordFactory().record( '/a/b/c');
  var to = _.fileProvider.recordFactory().record( '/a' );
  var expected = '../..';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  var from = _.fileProvider.recordFactory().record( '/a/b/c' );
  var to = '/a'
  var expected = '../..';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  var from = '/a'
  var to = _.fileProvider.recordFactory().record( '/a/b/c' );
  var expected = 'b/c';
  var got = _.path.relative( from, to );
  test.identical( got, expected );

  // _.path.relative accepts only two arguments

  // /* */

  test.case = 'both relative, long, not direct, resolving : 1';
  // var from = 'a/b/xx/yy/zz';
  // var to = 'a/b/files/x/y/z.txt';
  // var expected = '../../../files/x/y/z.txt';
  // var got = _.path.relative({ relative : from, path : to, resolving : 1 });
  // test.identical( got, expected );

  // /* */

  test.case = 'both relative, long, not direct, resolving 1';
  // var from = 'a/b/xx/yy/zz';
  // var to = 'a/b/files/x/y/z.txt';
  // var expected = '../../../files/x/y/z.txt';
  // var o =
  // {
  //   relative :  from,
  //   path : to,
  //   resolving : 1
  // }
  // var got = _.path.s.relative( o );
  // test.identical( got, expected );

  _.fileProvider.fieldPop( 'safe', 0 );
}

//

// function pathDirTempForTrivial( test )
// {
//   test.case = 'file is on same device with os temp';
//   var filePath = _.path.join( _.path.dirTemp(), 'file' );
//   var tempPath = _.path.tempOpen( filePath );
//   test.identical( pathDeviceGet( tempPath ), pathDeviceGet( filePath ) )
//   test.true( _.path.fileProvider.isDir( tempPath ) );
//   test.will = 'second call should return same temp dir path';
//   var tempPath2 = _.path.tempOpen( filePath );
//   test.identical( pathDeviceGet( tempPath2 ), pathDeviceGet( filePath ) )
//   test.identical( tempPath, tempPath2 );
//   _.path.tempClose( tempPath );
//   test.true( !_.path.fileProvider.fileExists( tempPath ) );
//   test.shouldThrowErrorSync( () => _.path.tempClose( filePath ) )

//   test.case = 'file is on different device';
//   var filePath = _.path.normalize( __filename );
//   var tempPath = _.path.tempOpen( filePath );
//   test.identical( pathDeviceGet( tempPath ), pathDeviceGet( filePath ) )
//   test.true( _.path.fileProvider.isDir( tempPath ) );
//   _.path.tempClose( tempPath );
//   test.true( !_.path.fileProvider.fileExists( tempPath ) );

//   test.case = 'same temp path each call'
//   var filePath = _.path.normalize( __filename );
//   var tempPath = _.path.tempOpen( filePath );
//   var tempPath2 = _.path.tempOpen( filePath );
//   test.identical( pathDeviceGet( tempPath ), pathDeviceGet( tempPath2 ) )
//   test.identical( tempPath, tempPath2 );
//   test.true( _.path.fileProvider.isDir( tempPath ) );
//   _.path.fileProvider.fileDelete({ filePath : tempPath, safe : 0 });
//   _.path.fileProvider.filesDelete({ filePath : tempPath2, safe : 0 });

//   test.case = 'new temp path each call'
//   var filePath = _.path.normalize( __filename );
//   var tempPath = _.path.pathDirTempMake( filePath );
//   var tempPath2 = _.path.pathDirTempMake( filePath );
//   test.true( _.path.fileProvider.isDir( tempPath ) );
//   test.true( _.path.fileProvider.isDir( tempPath2 ) );
//   test.notIdentical( tempPath, tempPath2 );
//   _.path.fileProvider.fileDelete({ filePath : tempPath, safe : 0 });
//   _.path.fileProvider.fileDelete({ filePath : tempPath2, safe : 0 });

//   test.case = 'path to root of device';
//   var filePath = pathDeviceGet( _.path.normalize( __filename ) );
//   var possiblePath = _.path.join( filePath, 'tmp-' + _.idWithGuid() + '.tmp' );
//   var shouldThrowErrorSync = false;
//   try
//   {
//     _.path.fileProvider.dirMake( possiblePath );
//     _.path.fileProvider.fileDelete({ filePath : possiblePath, safe : 0 });
//   }
//   catch( err )
//   {
//     shouldThrowErrorSync = true;
//   }
//   if( shouldThrowErrorSync )
//   {
//     test.shouldThrowErrorSync( () =>
//     {
//       _.path.pathDirTempMake( possiblePath );
//       // routine pathDirTempMake make correct filePath
//       // _.path.pathDirTempMake( filePath );
//     })
//   }
//   else
//   {
//     var tempPath = _.path.pathDirTempMake( filePath );
//     test.true( _.path.fileProvider.isDir( tempPath ) );
//     _.path.fileProvider.fileDelete({ filePath : tempPath, safe : 0 });
//   }


//   test.case = 'close removes only temp dirs made by open';
//   var filePath = _.path.normalize( __filename );
//   var tempPath = _.path.tempOpen( filePath );
//   _.path.tempClose( tempPath );
//   test.true( !_.path.fileProvider.fileExists( tempPath ) );
//   test.will = 'repeat close call on same temp dir path, should throw error'
//   test.shouldThrowErrorSync( () => _.path.tempClose( tempPath ) );
//   test.will = 'try to close other dir, should throw error'
//   test.shouldThrowErrorSync( () => _.path.tempClose( _.path.dir( filePath ) ) );

//   //

//   // var filePath = _.path.join( _.path.dirTemp(), 'file' );
//   // var t1 = _.time.now();
//   // var tempPath;
//   // for( var i = 0; i < 100; i++ )
//   // {
//   //   tempPath = _.path.tempOpen( filePath );
//   // }
//   // var t2 = _.time.now();
//   // logger.log( 'tempOpen:', t2 - t1 )
//   // _.path.tempClose( tempPath );

//   //

//   // var filePath = _.path.join( _.path.dirTemp(), 'file' );
//   // var t1 = _.time.now();
//   // var paths = [];
//   // for( var i = 0; i < 100; i++ )
//   // {
//   //   paths.push( _.path.pathDirTempMake( filePath ) );
//   // }
//   // var t2 = _.time.now();
//   // logger.log( 'pathDirTempMake:', t2 - t1 )
//   // _.each( paths, ( p ) =>
//   // {
//   //   _.path.fileProvider.fileDelete( p );
//   // })

//   /* */

//   function pathDeviceGet( filePath )
//   {
//     return filePath.substring( 0, filePath.indexOf( '/', 1 ) );
//   }
// }

//

function pathDirTemp( test )
{
  let filesTree = Object.create( null );
  let extract = new _.FileProvider.Extract({ filesTree })
  var name = 'tempOpenTest';

  let cache = extract.path.PathDirTempForMap[ extract.id ] = Object.create( null );
  let count = extract.path.PathDirTempCountMap[ extract.id ] = Object.create( null );

  test.notIdentical( extract.id, _.fileProvider.id );

  //

  test.open( 'same drive' );

  var filePath1 = '/dir1'
  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  test.identical( cache[ filePath1 ], got1 );
  test.true( _.strHas( got1, name ) );
  test.true( extract.isDir( got1 ) );

  var filePath2 = '/dir1/dir2'
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.identical( cache[ filePath2 ], got1 );
  test.true( _.strHas( got2, name ) );
  test.identical( got2, got1 );
  test.true( extract.isDir( got2 ) );

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.identical( got2, got1 );
  test.true( extract.isDir( got1 ) );
  test.identical( cache[ filePath1 ], got1 );
  test.identical( cache[ filePath2 ], got2 );

  extract.path.tempClose( filePath1 );
  extract.path.tempClose( filePath2 );
  test.identical( cache[ filePath1 ], got1 );
  test.identical( cache[ filePath2 ], got2 );
  test.true( extract.isDir( got1 ) );
  test.true( extract.isDir( got2 ) );

  extract.path.tempClose( filePath1 );
  test.identical( cache[ filePath1 ], undefined );
  test.identical( cache[ filePath2 ], got2 );
  test.true( extract.isDir( got1 ) );
  test.true( extract.isDir( got2 ) );
  extract.path.tempClose( filePath2 );
  test.identical( cache[ filePath1 ], undefined );
  test.identical( cache[ filePath2 ], undefined );
  test.true( !extract.isDir( got1 ) );
  test.true( !extract.isDir( got2 ) );

  test.identical( count[ got1 ], undefined );
  test.identical( count[ got2 ], undefined );

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.identical( got2, got1 );
  test.true( extract.isDir( got1 ) );
  test.identical( cache[ filePath1 ], got1 );
  test.identical( cache[ filePath2 ], got2 );
  debugger
  extract.path.tempClose();
  test.identical( cache[ filePath1 ], undefined );
  test.identical( cache[ filePath2 ], undefined );
  test.true( !extract.isDir( got1 ) );
  test.true( !extract.isDir( got2 ) );

  test.identical( count[ got1 ], undefined );
  test.identical( count[ got2 ], undefined );

  test.close( 'same drive' );

  /* */

  test.open( 'different drive' );

  var filePath1 = '/dir1'
  var filePath2 = '/dir1/dir2'

  extract.dirMake( filePath1 );
  extract.dirMake( filePath2 );

  extract.extraStats[ filePath1 ] = { dev : 1 }
  extract.extraStats[ filePath2 ] = { dev : 2 }

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.notIdentical( got1, got2 );
  test.identical( extract.path.common( got2, filePath2 ), filePath2 )
  test.true( extract.isDir( got1 ) );
  test.true( extract.isDir( got2 ) );
  test.identical( cache[ filePath1 ], got1 );
  test.identical( cache[ filePath2 ], got2 );

  extract.path.tempClose( filePath1 );
  test.identical( cache[ filePath1 ], undefined );
  test.identical( cache[ filePath2 ], got2 );
  test.true( extract.isDir( got2 ) );
  extract.path.tempClose( filePath2 );
  test.identical( cache[ filePath1 ], undefined );
  test.identical( cache[ filePath2 ], undefined );
  test.true( !extract.isDir( got2 ) );

  test.close( 'different drive' );

  //

  test.open( 'os path' )

  var filePath1 = extract.path.dir( extract.path.dirTemp() );
  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  test.true( extract.isDir( got1 ) );
  test.true( _.strBegins( got1, '/temp' ) )
  test.identical( cache[ filePath1 ], got1 );

  var filePath2 = '/'
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.true( extract.isDir( got2 ) );
  test.identical( got1, got2 );
  test.true( _.strBegins( got2, '/temp' ) );
  test.identical( cache[ filePath2 ], got2 );

  test.case = 'should return os temp path in case of error'

  var filePath3 = '/dir3'
  let originalDirMake = extract.dirMake;
  extract.dirMake = function dirMake( filePath )
  {
    if( _.strHas( filePath, '/dir3' ) )
    throw _.err( 'Test err');
    return originalDirMake.apply( extract, arguments );
  }
  var got2;
  test.mustNotThrowError( () =>
  {
    got2 = extract.path.tempOpen({ filePath : filePath3, name });
  })
  extract.dirMake = _.routineJoin( extract, originalDirMake )
  test.true( extract.isDir( got2 ) );
  test.true( _.strBegins( got2, extract.path.dirTemp() ) );
  test.identical( cache[ filePath3 ], got2 );

  test.close( 'os path' )

  //

  var filePath1 = '/dir1/dir3'
  test.shouldThrowErrorSync( () => extract.path.tempClose( filePath1 ) )

  //

  test.case = 'several runs of tempClose'
  test.mustNotThrowError( () =>
  {
    extract.path.tempClose();
    extract.path.tempClose();
  })
  test.identical( _.props.keys( cache ).length, 0 );

  test.case = 'no args';
  var got = extract.path.tempOpen();
  test.true( _.strHas( got, '/tmp-' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

  test.case = 'single arg';
  var got = extract.path.tempOpen( 'packageName' );
  test.true( _.strHas( got, 'packageName' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

  test.case = 'single arg';
  var got = extract.path.tempOpen( 'someDir/packageName' );
  test.true( _.strHas( got, '/someDir/Temp' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

  test.case = 'two args';
  var got = extract.path.tempOpen( '/dir', 'packageName' );
  test.true( _.strHas( got, '/dir/Temp' ) );
  test.true( _.strHas( got, 'packageName' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

}

//

function tempCloseAfter( test )
{
  let a = test.assetFor( false );
  let toolsPath = __.strEscape( a.path.nativize( a.path.join( __dirname, '../../../node_modules/Tools' ) ) );
//   let programSourceCode =
// `
// var toolsPath = '${toolsPath}';
// ${program.toString()}
// program();
// `

  // a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  let programPath = a.program( program ).programPath;
  // a.appStartNonThrowing({ execPath : a.abs( 'Program.js' ) })
  a.appStartNonThrowing({ execPath : programPath })
  .then( ( op ) =>
  {
    test.identical( _.strCount( op.output, 'tempDirCreated' ), 1 );
    test.identical( _.strCount( op.output, '= Message of Error' ), 1 );
    test.true( _.strHas( op.output, 'Not found temp dir for path' ) );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.include( 'wFiles' );
    var tempPath = _.path.tempOpen( _.path.normalize( __dirname ), 'tempCloseAfter' );
    if( _.fileProvider.isDir( tempPath ) )
    console.log( 'tempDirCreated' );
    _.process.on( _.event.Chain( 'available', 'exit' ), () =>
    {
      _.path.tempClose( tempPath )
    });
  }
}

tempCloseAfter.timeOut = 15000;

tempCloseAfter.description =
`
  Try to manully close temp dir after automatic close leads to an error.
`

function pathDirTempReturnResolved( test )
{
  let extract = new _.FileProvider.Extract()
  var name = 'pathDirTempReturnResolved';

  let cache = extract.path.PathDirTempForMap[ extract.id ] = Object.create( null );
  let count = extract.path.PathDirTempCountMap[ extract.id ] = Object.create( null );

  test.notIdentical( extract.id, _.fileProvider.id );

  extract.dirMake( '/_temp' );
  extract.softLink( '/temp', '/_temp' );

  /* */

  clear();
  var filePath1 = '/temp/dir1'
  var got1 = extract.path.tempOpen({ filePath : filePath1, name, resolving : 0 });
  test.identical( cache[ filePath1 ], got1 );
  test.true( _.strBegins( got1, '/temp' ) );
  test.true( _.strHas( got1, name ) );
  test.true( extract.isDir( got1 ) );

  /* */

  clear();
  var filePath1 = '/temp/dir2'
  var got1 = extract.path.tempOpen({ filePath : filePath1, name, resolving : 1 });
  test.identical( cache[ filePath1 ], got1 );
  test.true( _.strBegins( got1, '/_temp' ) );
  test.true( _.strHas( got1, name ) );
  test.true( extract.isDir( got1 ) );

  /* */

  clear();
  var filePath1 = '/dir1/dir2'
  extract.dirMake( '/dir3' );
  extract.softLink( '/dir1', '/dir3' );
  var got1 = extract.path.tempOpen({ filePath : filePath1, name, resolving : 0 });
  test.identical( cache[ filePath1 ], got1 );
  test.true( _.strBegins( got1, '/dir1' ) );
  test.true( _.strHas( got1, name ) );
  test.true( extract.isDir( got1 ) );

  /* */

  clear();
  var filePath1 = '/dir2/dir3'
  extract.dirMake( '/dir4' );
  extract.softLink( '/dir2', '/dir4' );
  var got1 = extract.path.tempOpen({ filePath : filePath1, name, resolving : 1 });
  test.identical( cache[ filePath1 ], got1 );
  test.true( _.strBegins( got1, '/dir4' ) );
  test.true( _.strHas( got1, name ) );
  test.true( extract.isDir( got1 ) );

  /* */

  function clear()
  {
    for( let k in cache )
    delete cache[ k ]
    for( let k in count )
    delete count[ k ]
  }

}

//

function tempOpenSystemPath( test )
{
  let provider = new _.FileProvider.Extract();
  let name = 'tempOpenSystemPath'
  let osTempPath = provider.path.dirTemp();
  provider.dirMake( osTempPath );

  /* - */

  test.open( 'filePath and Os temp dir are on same device' )

  test.case = 'target path does not exist'
  var filePath = '/dir1';
  var got = provider.path.tempOpen({ filePath, name });
  var expectedBegin = '/dir1/Temp/tempOpenSystemPath-';
  test.true( _.strBegins( got, expectedBegin ) )
  test.true( _.strEnds( got, '.tmp' ) );
  test.true( provider.isDir( got ) );
  provider.path.tempClose();

  test.case = 'target path does not exist, but has common with os temp path'
  var filePath = provider.path.join( osTempPath, 'dir1' );
  var got = provider.path.tempOpen({ filePath, name });
  var expectedBegin = provider.path.join( osTempPath, 'tempOpenSystemPath-' );
  test.true( _.strBegins( got, expectedBegin ) )
  test.true( _.strEnds( got, '.tmp' ) );
  test.true( provider.isDir( got ) );
  provider.path.tempClose();

  /* */

  test.case = 'target path exists'
  var filePath = '/dir1';
  provider.dirMake( filePath );
  var got = provider.path.tempOpen({ filePath, name });
  var expectedBegin = provider.path.join( osTempPath, 'tempOpenSystemPath-' );
  test.true( _.strBegins( got, expectedBegin ) )
  test.true( _.strEnds( got, '.tmp' ) );
  test.true( provider.isDir( got ) );

  /* */

  test.case = 'target path is an empty soft link'
  var filePath = '/dir1/' + _.idWithDateAndTime();
  var srcPath = '/dir1/' + _.idWithDateAndTime();
  provider.softLink({ dstPath : filePath, srcPath, allowingMissed : 1 });
  var got = provider.path.tempOpen({ filePath, name });
  var expectedBegin = provider.path.join( osTempPath, 'tempOpenSystemPath-' );
  console.log( got )
  test.true( _.strBegins( got, expectedBegin ) )
  test.true( _.strEnds( got, '.tmp' ) );
  test.true( provider.isDir( got ) );

  test.close( 'filePath and Os temp dir are on same device' )

  /* - */

  provider.path.tempClose();
  provider.finit();
}

tempOpenSystemPath.description =
`
Checks that routine path.tempOpen returns temp path that includes os temp dir
if both paths are on the same device
`

// --
// next pathDirTemp* tests
// --

function nextPathDirTemp( test )
{
  let filesTree = Object.create( null );
  let extract = new _.FileProvider.Extract({ filesTree })
  var name = 'tempOpenTest';

  //

  test.open( 'same drive' );

  var filePath1 = '/dir1'
  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var tempDir = extract.path.Index.tempDir[ filePath1 ];
  test.identical( tempDir, { namespace : name, tempPath : got1 } );
  test.identical( extract.path.Index.count[ got1 ], [ filePath1 ] );
  test.true( _.strHas( got1, name ) );
  test.true( extract.isDir( got1 ) );

  var filePath2 = '/dir1/dir2'
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  var tempDir = extract.path.Index.tempDir[ filePath2 ];
  test.identical( tempDir, { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got2 ], [ filePath1, filePath2 ] );
  test.true( _.strHas( got2, name ) );
  test.identical( got2, got1 );
  test.true( extract.isDir( got2 ) );

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.identical( got2, got1 );
  test.true( extract.isDir( got1 ) );
  var tempDir1 = extract.path.Index.tempDir[ filePath1 ];
  test.identical( tempDir1, { namespace : name, tempPath : got1 } );
  var tempDir2 = extract.path.Index.tempDir[ filePath2 ];
  test.identical( tempDir2, { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got2 ], [ filePath1, filePath2, filePath1, filePath2 ] );

  extract.path.tempClose( filePath1 );
  extract.path.tempClose( filePath2 );
  var tempDir1 = extract.path.Index.tempDir[ filePath1 ];
  test.identical( tempDir1, { namespace : name, tempPath : got1 } );
  var tempDir2 = extract.path.Index.tempDir[ filePath2 ];
  test.identical( tempDir2, { namespace : name, tempPath : got2 } );
  test.true( extract.isDir( got1 ) );
  test.true( extract.isDir( got2 ) );
  test.identical( extract.path.Index.count[ got1 ], [ filePath1, filePath2 ] );


  extract.path.tempClose( filePath1 );
  test.identical( extract.path.Index.tempDir[ filePath1 ], undefined );
  test.identical( extract.path.Index.tempDir[ filePath2 ], { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got1 ], [ filePath2 ] );
  test.true( extract.isDir( got1 ) );
  test.true( extract.isDir( got2 ) );
  extract.path.tempClose( filePath2 );
  test.identical( extract.path.Index.tempDir[ filePath1 ], undefined );
  test.identical( extract.path.Index.tempDir[ filePath2 ], undefined );
  test.true( !extract.isDir( got1 ) );
  test.true( !extract.isDir( got2 ) );

  test.identical( extract.path.Index.count[ got1 ], undefined );
  test.identical( extract.path.Index.count[ got2 ], undefined );

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.identical( got2, got1 );
  test.true( extract.isDir( got1 ) );
  test.identical( extract.path.Index.tempDir[ filePath1 ], { namespace : name, tempPath : got1 } );
  test.identical( extract.path.Index.tempDir[ filePath2 ], { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got1 ], [ filePath1, filePath2 ] );
  test.identical( extract.path.Index.count[ got2 ], [ filePath1, filePath2 ] );
  extract.path.tempClose();
  test.identical( extract.path.Index.tempDir[ filePath1 ], undefined );
  test.identical( extract.path.Index.tempDir[ filePath2 ], undefined );
  test.true( !extract.isDir( got1 ) );
  test.true( !extract.isDir( got2 ) );

  test.identical( extract.path.Index.count[ got1 ], undefined );
  test.identical( extract.path.Index.count[ got2 ], undefined );

  test.close( 'same drive' );

  /* */

  test.open( 'different drive' );

  var filePath1 = '/dir1'
  var filePath2 = '/dir1/dir2'

  extract.dirMake( filePath1 );
  extract.dirMake( filePath2 );

  extract.extraStats[ filePath1 ] = { dev : 1 }
  extract.extraStats[ filePath2 ] = { dev : 2 }

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.notIdentical( got1, got2 );
  test.identical( extract.path.common( got2, filePath2 ), filePath2 )
  test.true( extract.isDir( got1 ) );
  test.true( extract.isDir( got2 ) );
  test.identical( extract.path.Index.tempDir[ filePath1 ], { namespace : name, tempPath : got1 } );
  test.identical( extract.path.Index.tempDir[ filePath2 ], { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got1 ], [ filePath1 ] );
  test.identical( extract.path.Index.count[ got2 ], [ filePath2 ] );

  extract.path.tempClose( filePath1 );
  test.identical( extract.path.Index.tempDir[ filePath1 ], undefined );
  test.identical( extract.path.Index.tempDir[ filePath2 ], { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got1 ], undefined );
  test.identical( extract.path.Index.count[ got2 ], [ filePath2 ] );
  test.true( extract.isDir( got2 ) );
  extract.path.tempClose( filePath2 );
  test.identical( extract.path.Index.tempDir[ filePath1 ], undefined );
  test.identical( extract.path.Index.tempDir[ filePath2 ], undefined );
  test.identical( extract.path.Index.count[ got1 ], undefined );
  test.identical( extract.path.Index.count[ got2 ], undefined );
  test.true( !extract.isDir( got2 ) );

  test.close( 'different drive' );

  //

  test.open( 'os path' )

  var filePath1 = extract.path.dir( extract.path.dirTemp() );
  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  test.true( extract.isDir( got1 ) );
  test.true( _.strBegins( got1, '/temp' ) )
  test.identical( extract.path.Index.tempDir[ filePath1 ], { namespace : name, tempPath : got1 } );
  test.identical( extract.path.Index.count[ got1 ], [ filePath1 ] );

  var filePath2 = '/'
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });
  test.true( extract.isDir( got2 ) );
  test.identical( got1, got2 );
  test.true( _.strBegins( got2, '/temp' ) );
  test.identical( extract.path.Index.tempDir[ filePath2 ], { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got2 ], [ filePath1, filePath2 ] );

  test.case = 'should return os temp path in case of error'

  var filePath3 = '/dir3'
  let originalDirMake = extract.dirMake;
  extract.dirMake = function dirMake( o )
  {
    let filePath = o;
    if( _.object.isBasic( o ) )
    filePath = o.filePath;
    if( _.strHas( filePath, '/dir3' ) )
    throw _.err( 'Test err');

    return originalDirMake.apply( extract, arguments );
  }
  var got2;
  test.mustNotThrowError( () =>
  {
    got2 = extract.path.tempOpen({ filePath : filePath3, name });
  })
  extract.dirMake = _.routineJoin( extract, originalDirMake )
  test.true( extract.isDir( got2 ) );
  test.true( _.strBegins( got2, extract.path.dirTemp() ) );
  test.identical( extract.path.Index.tempDir[ filePath3 ], { namespace : name, tempPath : got2 } );
  test.identical( extract.path.Index.count[ got2 ], [ filePath3 ] );

  test.close( 'os path' )

  //

  var filePath1 = '/dir1/dir3'
  test.shouldThrowErrorSync( () => extract.path.tempClose( filePath1 ) )

  //

  test.case = 'several runs of tempClose'
  test.mustNotThrowError( () =>
  {
    extract.path.tempClose();
    extract.path.tempClose();
  })
  test.identical( _.props.keys( extract.path.Index.tempDir ).length, 0 );
  test.identical( _.props.keys( extract.path.Index.count ).length, 0 );

  test.case = 'no args';
  var got = extract.path.tempOpen();
  test.true( _.strHas( got, '/tmp-' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

  test.case = 'single arg';
  var got = extract.path.tempOpen( 'packageName' );
  test.true( _.strHas( got, 'packageName' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

  test.case = 'single arg';
  var got = extract.path.tempOpen( 'someDir/packageName' );
  test.true( _.strHas( got, '/someDir/Temp' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

  test.case = 'two args';
  var got = extract.path.tempOpen( '/dir', 'packageName' );
  test.true( _.strHas( got, '/dir/Temp' ) );
  test.true( _.strHas( got, 'packageName' ) );
  test.true( extract.isDir( got ) );
  extract.path.tempClose( got );
  test.true( !extract.fileExists( got ) );

}

//

function nextPathDirTempMultipleNamespacesSamePath( test )
{
  let filesTree = Object.create( null );
  let extract = new _.FileProvider.Extract({ filesTree })

  var filePath1 = '/dir1'
  var name1 = 'space1'
  var name2 = 'space2'
  var got1 = extract.path.tempOpen({ filePath : filePath1, name : name1 });
  var got2 = extract.path.tempOpen({ filePath : filePath1, name : name2 });

  var tempDir = extract.path.Index.tempDir[ filePath1 ];
  test.identical( tempDir, { namespace : [ name1, name2 ], tempPath : got1 } );
  test.identical( tempDir, { namespace : [ name1, name2 ], tempPath : got2 } );

  var namespaces = _.props.keys( extract.path.Index.namespace );
  test.identical( namespaces, [ 'space1', 'space2' ] );

  test.identical( extract.path.Index.namespace.space1, { tempDir : filePath1, tempPath : got1 } )
  test.identical( extract.path.Index.namespace.space2, { tempDir : filePath1, tempPath : got2 } )

  extract.path.tempClose();
}

nextPathDirTempMultipleNamespacesSamePath.description =
`
  Two namespaces are created for single filePath.
  Index contains record for two namespaces and one tempDir.
  Temp dir record contains info about two namespaces.
`

//

function nextPathDirTempMultipleNamespacesDiffPath( test )
{
  let filesTree = Object.create( null );
  let extract = new _.FileProvider.Extract({ filesTree })

  var filePath1 = '/dir1'
  var filePath2 = '/dir2'
  var name1 = 'space1'
  var name2 = 'space2'

  var got1 = extract.path.tempOpen({ filePath : filePath1, name : name1 });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name : name2 });

  var tempDir = extract.path.Index.tempDir[ filePath1 ];
  test.identical( tempDir, { namespace : name1, tempPath : got1 } );
  var tempDir = extract.path.Index.tempDir[ filePath2 ];
  test.identical( tempDir, { namespace : name2, tempPath : got2 } );

  var namespaces = _.props.keys( extract.path.Index.namespace );
  test.identical( namespaces, [ 'space1', 'space2' ] );

  test.identical( extract.path.Index.namespace.space1, { tempDir : filePath1, tempPath : got1 } )
  test.identical( extract.path.Index.namespace.space2, { tempDir : filePath2, tempPath : got2 } )

  extract.path.tempClose();
}

nextPathDirTempMultipleNamespacesDiffPath.description =
`
  Two namespaces are created for different file paths.
  Index contains record for two namespaces and two tempDir's.
  Temp dir records contains info about each namespace.
`

//

function nextPathDirTempMultiplePathSameNamespace( test )
{
  let filesTree = Object.create( null );
  let extract = new _.FileProvider.Extract({ filesTree })

  var filePath1 = '/dir1'
  var filePath2 = '/dir2'
  var name = 'space'

  var got1 = extract.path.tempOpen({ filePath : filePath1, name });
  var got2 = extract.path.tempOpen({ filePath : filePath2, name });

  var tempDir = extract.path.Index.tempDir[ filePath1 ];
  test.identical( tempDir, { namespace : name, tempPath : got1 } );
  var tempDir = extract.path.Index.tempDir[ filePath2 ];
  test.identical( tempDir, { namespace : name, tempPath : got2 } );

  var namespaces = _.props.keys( extract.path.Index.namespace );
  test.identical( namespaces, [ 'space' ] );
  var space = extract.path.Index.namespace.space;
  test.identical( space, { tempDir : [ filePath1, filePath2 ], tempPath : [ got1, got2 ] } )

  extract.path.tempClose();
}

nextPathDirTempMultiplePathSameNamespace.description =
`
  Two different paths are created for signle namespace.
`

//

function nextPathDirTempIndexLock( test )
{
  let a = test.assetFor( false );
  let toolsPath = __.strEscape( a.path.nativize( a.path.join( __dirname, '../../amid/l3/files/UseTop.s' ) ) );
  let programSourceCode =
  [
    `var toolsPath = '${toolsPath}';`,
    program.toString(),
    'program();'
  ]
  .join( '\n' )
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );

  /*  */

  _.path.tempOpen( a.routinePath, 'pathDirTempIndexLock' );
  a.fileProvider.fileLock
  ({
    filePath : _.path.IndexPath,
    sync : 1,
    throwing : 1,
    sharing : 'process',
    waiting : 1
  });
  test.true( a.fileProvider.fileIsLocked( _.path.IndexPath ) );

  _.time.out( 2000, () => a.fileProvider.fileUnlock( _.path.IndexPath ) )
  let t1 = _.time.now();

  a.shellNonThrowing({ execPath : 'node ' + a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    let t2 = _.time.now();
    test.ge( t2 - t1, 2000 );
    test.identical( op.exitCode, 0 );
    test.true( !_.strHas( op.output, 'Lock file is already being held' ) )
    test.true( _.strHas( op.output, 'Temp dir created' ) )
    test.true( !a.fileProvider.fileIsLocked( _.path.IndexPath ) );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.path.IndexLockTimeOut = 5000;
    _.path.tempOpen
    ({
      filePath : _.path.normalize( __dirname ),
      name : 'pathDirTempIndexLock',
    });
    console.log( 'Temp dir created' );
  }
}
nextPathDirTempIndexLock.timeOut = 10000;
nextPathDirTempIndexLock.description =
`
Second process locks file when main releases it after two seconds.
`

//

function nextPathDirTempIndexLockThrowing( test )
{
  let a = test.assetFor( false );
  let toolsPath = __.strEscape( a.path.nativize( a.path.join( __dirname, '../../amid/l3/files/UseTop.s' ) ) );
  let programSourceCode =
  [
    `var toolsPath = '${toolsPath}';`,
    program.toString(),
    'program();'
  ]
  .join( '\n' )
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );

  /*  */

  _.path.tempOpen( a.routinePath, 'pathDirTempIndexLockThrowing' );
  a.fileProvider.fileLock
  ({
    filePath : _.path.IndexPath,
    sync : 1,
    throwing : 1,
    sharing : 'process',
    waiting : 1
  });
  test.true( a.fileProvider.fileIsLocked( _.path.IndexPath ) );
  let t1 = _.time.now();
  a.shellNonThrowing({ execPath : 'node ' + a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    let t2 = _.time.now();
    test.ge( t2 - t1, 5000 );
    test.notIdentical( op.exitCode, 0 );
    test.true( _.strHas( op.output, 'Lock file is already being held' ) )
    a.fileProvider.fileUnlock( _.path.IndexPath )
    test.true( !a.fileProvider.fileIsLocked( _.path.IndexPath ) );
    return null;
  });

  return a.ready;

  function program()
  {
    const _ = require( toolsPath );
    _.path.IndexLockTimeOut = 5000;
    _.path.tempOpen
    ({
      filePath : _.path.normalize( __dirname ),
      name : 'pathDirTempIndexLockThrowing',
    });
  }
}
nextPathDirTempIndexLockThrowing.timeOut = 10000;
nextPathDirTempIndexLockThrowing.description =
`
Second process exits with lock error after timeout.
`

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.Paths',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
    isBrowser : null,
    assetsOriginalPath : null,
    appJsPath : null,

    createTestsDirectory,
    createInTD,
    createTestFile,
    createTestSymLink,
    createTestResources
  },

  tests :
  {

    like,

    from,
    forCopy,

    pathResolve,
    pathsResolve,

    regexpMakeSafe,

    effectiveMainDir,

    pathCurrent,
    pathCurrent2,

    relative,

    // pathDirTempForTrivial,

    pathDirTemp,
    tempCloseAfter,
    pathDirTempReturnResolved,
    tempOpenSystemPath,

    //

    // nextPathDirTemp,
    // nextPathDirTempMultipleNamespacesSamePath,
    // nextPathDirTempMultipleNamespacesDiffPath,
    // nextPathDirTempMultiplePathSameNamespace,
    // nextPathDirTempIndexLock,
    // nextPathDirTempIndexLockThrowing

  },

}

//

const Self = wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
