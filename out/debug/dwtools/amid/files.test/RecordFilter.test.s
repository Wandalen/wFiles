( function _RecordFilter_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = wTester;
var testSuitePath;

// --
// context
// --

function onSuiteBegin()
{
  if( Config.platform === 'nodejs' )
  testSuitePath = _.path.dirTempOpen( _.path.join( __dirname, '../..' ), 'FileRecordFilter' );
  else
  testSuitePath = _.path.current();
}

//

function onSuiteEnd()
{
  if( Config.platform === 'nodejs' )
  {
    _.assert( _.strHas( testSuitePath, 'FileRecordFilter' ) );
    _.path.dirTempClose( testSuitePath );
  }
}

// --
// tests
// --

function make( test )
{
  let provider = new _.FileProvider.Extract();

  /* */

  test.case = 'filter from options map';
  var filter = provider.recordFilter({ filePath : '/src' });
  logger.log( filter );
  test.identical( filter.filePath, '/src' );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.form();
  logger.log( filter );
  test.identical( filter.filePath, { '/src' : null } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, { '/src' : '/src' } );
  test.identical( filter.formed, 5 );

  /* */

  test.case = 'filter copy string';
  var filter = provider.recordFilter( '/src' );
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, '/src' );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.copy( '/dst' );
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, '/dst' );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  /* */

  test.case = 'filter copy array';
  var filter = provider.recordFilter([ '/src1', '/src2' ]);
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, [ '/src1', '/src2' ] );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.copy( [ '/dst1', '/dst2' ] );
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, [ '/dst1', '/dst2' ] );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  /* */

  test.case = 'filter from string';
  var filter = provider.recordFilter( '/src' );
  logger.log( filter );
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, '/src' );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.form();
  logger.log( filter );
  test.identical( filter.filePath, { '/src' : null } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, { '/src' : '/src' } );
  test.identical( filter.formed, 5 );

  /* */

  test.case = 'filter from array';
  var filter = provider.recordFilter([ '/src/a', '/src/b' ]);
  logger.log( filter );
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, [ '/src/a', '/src/b' ] );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.form();
  logger.log( filter );
  test.identical( filter.filePath, { '/src/a' : null, '/src/b' : null } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, { '/src/a' : '/src/a', '/src/b' : '/src/b' } );
  test.identical( filter.formed, 5 );

  /* */

  test.case = 'filter from array, have relative path';
  var filter = provider.recordFilter([ '/src/a', 'src/b' ]);
  logger.log( filter );
  test.identical( filter.filePath, '.' );
  test.identical( filter.prefixPath, [ '/src/a', 'src/b' ] );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.form();
  logger.log( filter );
  test.identical( filter.filePath, { '/src/a' : null, '/src/a/src/b' : null } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, { '/src/a' : '/src/a', '/src/a/src/b' : '/src/a' } );
  test.identical( filter.formed, 5 );

  /* */

  if( !Config.debug )
  return;

  /* */

  test.description = 'bad options';

  test.shouldThrowError( () => provider.recordFilter({ '/xx' : '/src' }) );
  test.shouldThrowError( () => provider.recordFilter( 1 ) );

}

//

function form( test )
{

  test.case = 'base path is relative';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = [ '/a/b/*', '/a/c/*' ];
  filter.basePath = '..';
  filter.form();
  test.identical( filter.formed, 5 );
  test.identical( filter.formedFilePath, { '/a/b' : null, '/a/c' : null } );
  test.identical( filter.formedBasePath, { '/a/b' : '/a', '/a/c' : '/a' } );
  test.identical( filter.filePath, { '/a/b/*' : null, '/a/c/*' : null } );
  test.identical( filter.basePath, { '/a/b/*' : '/a', '/a/c/*' : '/a' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path and file path are relative, without glob';
  var filter = _.fileProvider.recordFilter();
  filter.prefixPath = '/src';
  filter.basePath = '.';
  filter.filePath = { 'd' : true };
  filter.form();
  test.identical( filter.formed, 5 );
  test.identical( filter.formedFilePath, { '/src/d' : '/src' } );
  test.identical( filter.formedBasePath, { '/src/d' : '/src' } );
  test.identical( filter.filePath, { '/src/d' : '/src' } );
  test.identical( filter.basePath, { '/src/d' : '/src' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path and file path are relative, without glob, complex';
  var filter = _.fileProvider.recordFilter();
  filter.prefixPath = '/src';
  filter.basePath = '.';
  filter.filePath = { 'a/b' : true, 'a/c' : true };
  filter.form();
  test.identical( filter.formed, 5 );
  test.identical( filter.formedFilePath, { '/src/a/b' : '/src', '/src/a/c' : '/src' } );
  test.identical( filter.formedBasePath, { '/src/a/b' : '/src', '/src/a/c' : '/src' } );
  test.identical( filter.filePath, { '/src/a/b' : '/src', '/src/a/c' : '/src' } );
  test.identical( filter.basePath, { '/src/a/b' : '/src', '/src/a/c' : '/src' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path and file path are relative, with glob, complex';
  var filter = _.fileProvider.recordFilter();
  filter.prefixPath = '/src/*';
  filter.basePath = '.';
  filter.filePath = { 'a/b' : true, 'a/c' : true };
  filter.form();
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.filePath, { '/src/*/a/b' : '/src', '/src/*/a/c' : '/src' } );
  test.identical( filter.basePath, { '/src/*/a/b' : '/src', '/src/*/a/c' : '/src' } );
  test.identical( filter.formedFilePath, { '/src' : '/src' } );
  test.identical( filter.formedBasePath, { '/src' : '/src' } );
  test.identical( filter.formed, 5 );

  if( Config.debug )
  {

    test.case = 'different base paths for the same file path';
    var filter = _.fileProvider.recordFilter();
    filter.prefixPath = '/src/*';
    filter.basePath = { 'a/b' : '/src', 'a/c' : '/dst' };
    filter.filePath = { 'a/b' : true, 'a/c' : true };
    test.shouldThrowErrorSync( () => filter.form() );
    test.identical( filter.formed, 3 );
    test.identical( filter.formedFilePath, null );
    test.identical( filter.formedBasePath, null );
    test.identical( filter.filePath, { '/src/*/a/b' : '/src', '/src/*/a/c' : '/src' } );
    test.identical( filter.basePath, { '/src/*/a/b' : '/src', '/src/*/a/c' : '/dst' } );
    test.identical( filter.prefixPath, null );
    test.identical( filter.postfixPath, null );

  }

  test.case = 'glob simplification';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = '/a/b/**';
  filter.form();
  test.identical( filter.formed, 5 );
  test.identical( filter.formedFilePath, { '/a/b' : null } );
  test.identical( filter.formedBasePath, { '/a/b' : '/a/b' } );
  test.identical( filter.filePath, { '/a/b' : null } );
  test.identical( filter.basePath, { '/a/b' : '/a/b' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'no glob simplification';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = '/a/**/b';
  filter.form();
  test.identical( filter.formed, 5 );
  test.identical( filter.formedFilePath, { '/a' : null } );
  test.identical( filter.formedBasePath, { '/a' : '/a' } );
  test.identical( filter.filePath, { '/a/**/b' : null } );
  test.identical( filter.basePath, { '/a/**/b' : '/a' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path is dot, absolute file paths';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = [ '/a/b/*x*', '/a/c/*x*' ];
  filter.basePath = '.';
  filter._formPaths();
  test.identical( filter.formed, 3 );
  test.identical( filter.formedFilePath, null );
  test.identical( filter.formedBasePath, null );
  test.identical( filter.filePath, { '/a/b/*x*' : null, '/a/c/*x*' : null } );
  // test.identical( filter.basePath, { '/a/b/*x*' : '.', '/a/c/*x*' : '.' } ); // yyy
  test.identical( filter.basePath, { '/a/b/*x*' : '/a/b', '/a/c/*x*' : '/a/c' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path is dot, relative file paths';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = [ 'a/b/*x*', 'a/c/*x*' ];
  filter.basePath = '.';
  filter._formPaths();
  test.identical( filter.formed, 3 );
  test.identical( filter.formedFilePath, null );
  test.identical( filter.formedBasePath, null );
  test.identical( filter.filePath, { 'a/b/*x*' : null, 'a/c/*x*' : null } );
  // test.identical( filter.basePath, { 'a/b/*x*' : '.', 'a/c/*x*' : '.' } ); // yyy
  test.identical( filter.basePath, { 'a/b/*x*' : 'a/b', 'a/c/*x*' : 'a/c' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path is empty, absolute file paths';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = [ '/a/b/*x*', '/a/c/*x*' ];
  filter.basePath = '';
  filter.form();
  test.identical( filter.formed, 5 );
  test.identical( filter.formedFilePath, { '/a/b' : null, '/a/c' : null } );
  test.identical( filter.formedBasePath, { '/a/b' : '/a/b', '/a/c' : '/a/c' } );
  test.identical( filter.filePath, { '/a/b/*x*' : null, '/a/c/*x*' : null } );
  test.identical( filter.basePath, { '/a/b/*x*' : '/a/b', '/a/c/*x*' : '/a/c' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

  test.case = 'base path is empty, relative file paths';
  var filter = _.fileProvider.recordFilter();
  filter.filePath = [ 'a/b/*x*', 'a/c/*x*' ];
  filter.basePath = '';
  filter._formPaths();
  test.identical( filter.formed, 3 );
  test.identical( filter.formedFilePath, null );
  test.identical( filter.formedBasePath, null );
  test.identical( filter.filePath, { 'a/b/*x*' : null, 'a/c/*x*' : null } );
  test.identical( filter.basePath, { 'a/b/*x*' : 'a/b', 'a/c/*x*' : 'a/c' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

/*
filter.toStr()
"Filter
  filePath : [
  [ '/temp/tmp.tmp/suite-' ... 'Glob/doubledir/d1/ **' ],
  [ '/temp/tmp.tmp/suite-' ... 'Glob/doubledir/d2/ **' ]
]
  basePath : '.'"
*/

}

//

function clone( test )
{
  let provider = _.fileProvider;
  let filter = new _.FileRecordFilter({ defaultFileProvider : provider });

  filter.prefixPath = '/some/path';

  filter.basePath =
  {
    '.module/mod/builder.coffee' : '.module/mod',
  }

  filter.filePath =
  {
    '.module/mod/builder.coffee' : true,
  }

  test.identical( filter.formed, 1 );

  let filter2 = filter.clone().form();
  let filter3 = filter.clone().form();
  filter.form();
  let filter4 = filter.clone();

  test.identical( filter.formed, 5 );
  test.identical( filter2.formed, 5 );
  test.identical( filter3.formed, 5 );
  test.identical( filter4.formed, 1 );

}

//

function reflect( test )
{

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      src :
      {
        f1: '1',
        d : { f2 : '2', f3 : '3' },
      },
      dst :
      {
        f1: 'dst',
        d : 'dst',
      }
    },
  });

  /* - */

  test.case = 'src and dst filters with prefixes and reflect map';

  var files = extract1.filesReflect
  ({
    reflectMap : { 'src' : 'dst' },
    /*srcFilter*/src : { prefixPath : '/' },
    /*dstFilter*/dst : { prefixPath : '/' },
  });

  var expSrc = [ '/src', '/src/f1', '/src/d', '/src/d/f2', '/src/d/f3' ];
  var gotSrc = _.select( files, '*/src/absolute' );
  var expDst = [ '/src', '/src/f1', '/src/d', '/src/d/f2', '/src/d/f3' ];
  var gotDst = _.select( files, '*/src/absolute' );

  test.identical( gotSrc, expSrc );
  test.identical( gotDst, expDst );

  /* - */

  test.case = 'src filter with prefixes and reflect map';

  var files = extract1.filesReflect
  ({
    reflectMap : { 'src' : '/dst' },
    /*srcFilter*/src : { prefixPath : '/' },
  });

  var expSrc = [ '/src', '/src/f1', '/src/d', '/src/d/f2', '/src/d/f3' ];
  var gotSrc = _.select( files, '*/src/absolute' );
  var expDst = [ '/src', '/src/f1', '/src/d', '/src/d/f2', '/src/d/f3' ];
  var gotDst = _.select( files, '*/src/absolute' );

  test.identical( gotSrc, expSrc );
  test.identical( gotDst, expDst );

  /* - */

  test.case = 'dst filter with prefixes and reflect map';

  var files = extract1.filesReflect
  ({
    reflectMap : { '/src' : 'dst' },
    /*dstFilter*/dst : { prefixPath : '/' },
  });

  var expSrc = [ '/src', '/src/f1', '/src/d', '/src/d/f2', '/src/d/f3' ];
  var gotSrc = _.select( files, '*/src/absolute' );
  var expDst = [ '/src', '/src/f1', '/src/d', '/src/d/f2', '/src/d/f3' ];
  var gotDst = _.select( files, '*/src/absolute' );

  test.identical( gotSrc, expSrc );
  test.identical( gotDst, expDst );

  /* */

  if( !Config.debug )
  return;

  /* */

  test.description = 'cant deduce base path';

  test.shouldThrowError( () =>
  {
    extract1.filesReflect
    ({
      reflectMap : { 'src' : 'dst' },
    });
  });

  test.shouldThrowError( () =>
  {
    extract1.filesReflect
    ({
      reflectMap : { 'src' : 'dst' },
      /*srcFilter*/src : { prefixPath : '/' },
    });
  });

  test.shouldThrowError( () =>
  {
    extract1.filesReflect
    ({
      reflectMap : { 'src' : 'dst' },
      /*dstFilter*/dst : { prefixPath : '/' },
    });
  });

}

//

function prefixesApply( test )
{
  let context = this;
  let provider = new _.FileProvider.Extract();
  let path = provider.path;

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  /* - */

  test.open( 'single' );

  /* - */

  test.case = 'trivial';

  var f1 = extract1.recordFilter({});
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/f' : '/dir/filter1', '/dir/filter1/d' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'd' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'prefixPathOnly';

  var f1 = extract1.recordFilter({});

  f1.filePath = null;
  f1.prefixPath = '/dir/filter1';
  f1.basePath = null;

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, '/dir/filter1' );

  /* */

  test.case = 'no filePath, but basePath';

  var f1 = extract1.recordFilter({});

  f1.filePath = null;
  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, '/dir/filter1/proto' );
  test.identical( f1.filePath, '/dir/filter1' );

  /* */

  test.case = 'filePath is empty map';

  var f1 = extract1.recordFilter({});
  var expectedBasePath = '/dir/filter1/proto';

  f1.filePath = {};
  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, {} );

  /* */

  test.case = 'trivial, only bools';

  var f1 = extract1.recordFilter({});
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/f' : true, '/dir/filter1/d' : true, '/dir/filter1/ex' : false }

  f1.filePath = { '/dir/filter1/f' : true, '/dir/filter1/d' : true, '/dir/filter1/ex' : false }
  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'base path is relative and current';

  var f1 = extract1.recordFilter();
  var expectedBasePath = '/dir/filter1';
  var expectedFilePath = { '/dir/filter1/f' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = '.';

  debugger;
  f1.prefixesApply();
  debugger;

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'no base path';

  var f1 = extract1.recordFilter();
  var expectedBasePath = null;
  var expectedFilePath = { '/dir/filter1/f' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = null;

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'prefix is relative';

  var f1 = extract1.recordFilter();
  var expectedBasePath = '/base';
  var expectedFilePath = { './dir/f' : './dir', 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = './dir'
  f1.basePath = '/base';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'some in file paths are absolute';

  var f1 = extract1.recordFilter();
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/d' : '/dir/filter1', '/dir/filter1/f' : '/dir/filter1', '/dir/ex' : false }

  f1.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'base path is absolute';

  var f1 = extract1.recordFilter();
  var expectedBasePath = '/proto';
  var expectedFilePath = { '/dir/filter1/d' : '/dir/filter1', '/dir/filter1/f' : '/dir/filter1', '/dir/ex' : false }

  f1.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = '/proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* - */

  test.close( 'single' );
  test.open( 'source' );

  /* - */

  test.case = 'trivial';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/f' : null, '/dir/filter1/d' : null, 'ex' : false }

  /*srcFilter*/src.filePath = { 'f' : null, 'd' : null, 'ex' : false }
  /*srcFilter*/src.prefixPath = '/dir/filter1'
  /*srcFilter*/src.basePath = './proto';

  /*srcFilter*/src.prefixesApply();

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.basePath, expectedBasePath );
  test.identical( /*srcFilter*/src.filePath, expectedFilePath );

  /* */

  test.case = 'base path is relative and current';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/dir/filter1';
  var expectedFilePath = { '/dir/filter1/f' : null, 'ex' : false }

  /*srcFilter*/src.filePath = { 'f' : null, 'ex' : false }
  /*srcFilter*/src.prefixPath = '/dir/filter1'
  /*srcFilter*/src.basePath = '.';

  /*srcFilter*/src.prefixesApply();

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.basePath, expectedBasePath );
  test.identical( /*srcFilter*/src.filePath, expectedFilePath );

  /* */

  test.case = 'no base path';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = null;
  var expectedFilePath = { '/dir/filter1/f' : null, 'ex' : false }

  /*srcFilter*/src.filePath = { 'f' : null, 'ex' : false }
  /*srcFilter*/src.prefixPath = '/dir/filter1'
  /*srcFilter*/src.basePath = null;

  /*srcFilter*/src.prefixesApply();

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.basePath, expectedBasePath );
  test.identical( /*srcFilter*/src.filePath, expectedFilePath );

  /* */

  test.case = 'prefix is relative';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/base';
  var expectedFilePath = { './dir/f' : null, 'ex' : false }

  /*srcFilter*/src.filePath = { 'f' : null, 'ex' : false }
  /*srcFilter*/src.prefixPath = './dir'
  /*srcFilter*/src.basePath = '/base';

  /*srcFilter*/src.prefixesApply();

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.basePath, expectedBasePath );
  test.identical( /*srcFilter*/src.filePath, expectedFilePath );

  /* */

  test.case = 'some in file paths are absolute';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }

  /*srcFilter*/src.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  /*srcFilter*/src.prefixPath = '/dir/filter1'
  /*srcFilter*/src.basePath = './proto';

  /*srcFilter*/src.prefixesApply();

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.basePath, expectedBasePath );
  test.identical( /*srcFilter*/src.filePath, expectedFilePath );

  /* */

  test.case = 'base path is absolute';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );

  var expectedBasePath = '/proto';
  var expectedFilePath = { '/dir/filter1/f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }

  /*srcFilter*/src.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  /*srcFilter*/src.prefixPath = '/dir/filter1'
  /*srcFilter*/src.basePath = '/proto';

  /*srcFilter*/src.prefixesApply();

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.basePath, expectedBasePath );
  test.identical( /*srcFilter*/src.filePath, expectedFilePath );

  /* */

  test.case = 'no filePath';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  /*srcFilter*/src.prefixPath = '/dir/filter1';
  /*srcFilter*/src.basePath = './proto';
  debugger;
  /*srcFilter*/src.prefixesApply();
  debugger;

  test.identical( /*srcFilter*/src.prefixPath, null );
  test.identical( /*srcFilter*/src.postfixPath, null );
  test.identical( /*srcFilter*/src.basePath, '/dir/filter1/proto' );
  test.identical( /*srcFilter*/src.filePath, { '/dir/filter1' : null } );

  /* - */

  test.close( 'source' );
  test.open( 'destination' );

  /* - */

  test.case = 'trivial';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { 'f' : '/dir/filter1', 'd' : '/dir/filter1', 'ex' : false }

  /*dstFilter*/dst.filePath = { 'f' : null, 'd' : null, 'ex' : false }
  /*dstFilter*/dst.prefixPath = '/dir/filter1';
  /*dstFilter*/dst.basePath = './proto';

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.basePath, expectedBasePath );
  test.identical( /*dstFilter*/dst.filePath, expectedFilePath );

  /* */

  test.case = 'base path is relative and current';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/dir/filter1';
  var expectedFilePath = { 'f' : '/dir/filter1', 'ex' : false }

  /*dstFilter*/dst.filePath = { 'f' : null, 'ex' : false }
  /*dstFilter*/dst.prefixPath = '/dir/filter1';
  /*dstFilter*/dst.basePath = '.';

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.basePath, expectedBasePath );
  test.identical( /*dstFilter*/dst.filePath, expectedFilePath );

  /* */

  test.case = 'no base path';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = null;
  var expectedFilePath = { 'f' : '/dir/filter1', 'ex' : false }

  /*dstFilter*/dst.filePath = { 'f' : null, 'ex' : false }
  /*dstFilter*/dst.prefixPath = '/dir/filter1'
  /*dstFilter*/dst.basePath = null;

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.basePath, expectedBasePath );
  test.identical( /*dstFilter*/dst.filePath, expectedFilePath );

  /* */

  test.case = 'prefix is relative';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/base';
  var expectedFilePath = { 'f' : './dir/dir', 'ex' : false }

  /*dstFilter*/dst.filePath = { 'f' : './dir', 'ex' : false }
  /*dstFilter*/dst.prefixPath = './dir'
  /*dstFilter*/dst.basePath = '/base';

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.basePath, expectedBasePath );
  test.identical( /*dstFilter*/dst.filePath, expectedFilePath );

  /* */

  test.case = 'some in file paths are absolute';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { 'f' : '/dir/filter1', '/dir/filter1/d' : '/dir/filter1', '/dir/ex' : false }

  /*dstFilter*/dst.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  /*dstFilter*/dst.prefixPath = '/dir/filter1';
  /*dstFilter*/dst.basePath = './proto';

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.basePath, expectedBasePath );
  test.identical( /*dstFilter*/dst.filePath, expectedFilePath );

  /* */

  test.case = 'base path is absolute';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  var expectedBasePath = '/proto';
  var expectedFilePath = { 'f' : '/dir/filter1', '/dir/filter1/d' : '/dir/filter1', '/dir/ex' : false }

  /*dstFilter*/dst.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  /*dstFilter*/dst.prefixPath = '/dir/filter1';
  /*dstFilter*/dst.basePath = '/proto';

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.basePath, expectedBasePath );
  test.identical( /*dstFilter*/dst.filePath, expectedFilePath );

  /* */

  test.case = 'no filePath';

  var /*srcFilter*/src = extract1.recordFilter();
  var /*dstFilter*/dst = extract1.recordFilter();
  /*srcFilter*/src.pairWithDst( /*dstFilter*/dst );
  /*dstFilter*/dst.prefixPath = '/dir/filter1';
  /*dstFilter*/dst.basePath = './proto';

  /*dstFilter*/dst.prefixesApply();

  test.identical( /*dstFilter*/dst.prefixPath, null );
  test.identical( /*dstFilter*/dst.postfixPath, null );
  test.identical( /*dstFilter*/dst.basePath, '/dir/filter1/proto' );
  test.identical( /*dstFilter*/dst.filePath, { '.' : '/dir/filter1' } );

  /* - */

  test.close( 'destination' );

}

//

function prefixesRelative( test )
{

  /* */

  test.case = 'file path - map, single';
  var osrc =
  {
    filePath : { '/src' : '/dst' }
  }
  var src = _.fileProvider.recordFilter( osrc );
  src.prefixesRelative();

  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '.' : '../dst' } );
  test.identical( src.prefixPath, '/src' );

  /* */

  test.case = 'file path - map, single, src relative';
  var osrc =
  {
    filePath : { './src' : '/dst' }
  }
  var src = _.fileProvider.recordFilter( osrc );
  src.prefixesRelative();

  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '.' : '/dst' } );
  test.identical( src.prefixPath, './src' );

  /* */

  test.case = 'file path - map, single, dst relative';
  var osrc =
  {
    filePath : { '/src' : './dst' }
  }
  var src = _.fileProvider.recordFilter( osrc );
  src.prefixesRelative();

  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '.' : './dst' } );
  test.identical( src.prefixPath, '/src' );

  /* */

  test.case = 'file path - map, single, dst is true';
  var osrc =
  {
    filePath : { '/src/a' : true, '/src/b' : '/dst/b' }
  }
  var src = _.fileProvider.recordFilter( osrc );
  src.prefixesRelative();

  test.identical( src.formed, 1 );
  test.identical( src.filePath, { 'a' : true, 'b' : '../dst/b' } );
  test.identical( src.prefixPath, '/src' );

  /* */

  test.case = 'file path - map';
  var osrc =
  {
    filePath : { '/src' : '/dst' }
  }
  var odst =
  {
    filePath : osrc.filePath
  }
  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  src.filePath = dst.filePath;
  test.is( src.filePath === dst.filePath );
  src.pairWithDst( dst );
  test.is( src.filePath === dst.filePath );

  src.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '.' : '/dst' } );
  test.identical( src.prefixPath, '/src' );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '.' : '/dst' } );
  test.identical( dst.prefixPath, null );
  test.is( src.filePath === dst.filePath );

  dst.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '.' : '.' } );
  test.identical( src.prefixPath, '/src' );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '.' : '.' } );
  test.identical( dst.prefixPath, '/dst' );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'file path - map, with bools';
  var osrc =
  {
    filePath : { '/src/a' : '/dst', '/src/b' : true }
  }
  var odst =
  {
    filePath : osrc.filePath
  }
  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  src.filePath = dst.filePath;
  test.is( src.filePath === dst.filePath );
  src.pairWithDst( dst );
  test.is( src.filePath === dst.filePath );

  src.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { 'a' : '/dst', 'b' : true } );
  test.identical( src.prefixPath, '/src' );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { 'a' : '/dst', 'b' : true } );
  test.identical( dst.prefixPath, null );
  test.is( src.filePath === dst.filePath );

  dst.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { 'a' : '.', 'b' : true } );
  test.identical( src.prefixPath, '/src' );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { 'a' : '.', 'b' : true } );
  test.identical( dst.prefixPath, '/dst' );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'file path - absolute map, prefix path - absolute string, base path - absolute map, no argument';
  var osrc =
  {
    filePath : { '/src' : '/dst' },
    prefixPath : '/srcPrefix',
    basePath : { '/src' : '/srcPrefix' },
  }
  var odst =
  {
    filePath : { '/src' : '/dst' },
    prefixPath : '/dstPrefix',
    basePath : { '/dst' : '/dstPrefix' },
  }
  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  src.filePath = dst.filePath;
  test.is( src.filePath === dst.filePath );
  src.pairWithDst( dst );
  test.is( src.filePath === dst.filePath );

  src.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '../src' : '/dst' } );
  test.identical( src.prefixPath, '/srcPrefix' );
  test.identical( src.basePath, { '../src' : '.' } );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '../src' : '/dst' } );
  test.identical( dst.prefixPath, '/dstPrefix' );
  test.identical( dst.basePath, { '/dst' : '/dstPrefix' } );
  test.is( src.filePath === dst.filePath );

  dst.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '../src' : '../dst' } );
  test.identical( src.prefixPath, '/srcPrefix' );
  test.identical( src.basePath, { '../src' : '.' } );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '../src' : '../dst' } );
  test.identical( dst.prefixPath, '/dstPrefix' );
  test.identical( dst.basePath, { '../dst' : '.' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'file path - absolute map, base path - absolute map, argument';
  var osrc =
  {
    filePath : { '/src' : '/dst' },
    prefixPath :  null,
    basePath : { '/src' : '/srcPrefix' },
  }
  var odst =
  {
    filePath : { '/src' : '/dst' },
    prefixPath : null,
    basePath : { '/dst' : '/dstPrefix' },
  }
  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  src.filePath = dst.filePath;
  test.is( src.filePath === dst.filePath );
  src.pairWithDst( dst );
  test.is( src.filePath === dst.filePath );

  src.prefixesRelative( '/srcPrefix' );
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '../src' : '/dst' } );
  test.identical( src.prefixPath, '/srcPrefix' );
  test.identical( src.basePath, { '../src' : '.' } );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '../src' : '/dst' } );
  test.identical( dst.prefixPath, null );
  test.identical( dst.basePath, { '/dst' : '/dstPrefix' } );
  test.is( src.filePath === dst.filePath );

  dst.prefixesRelative( '/dstPrefix' );
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '../src' : '../dst' } );
  test.identical( src.prefixPath, '/srcPrefix' );
  test.identical( src.basePath, { '../src' : '.' } );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '../src' : '../dst' } );
  test.identical( dst.prefixPath, '/dstPrefix' );
  test.identical( dst.basePath, { '../dst' : '.' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'file path - relative map, prefix path - absolute string, base path - relative map, no argument';
  var osrc =
  {
    filePath : { '../src' : '../dst' },
    prefixPath : '/srcPrefix',
    basePath : { '../src' : '.' },
  }
  var odst =
  {
    filePath : { '../src' : '../dst' },
    prefixPath : '/dstPrefix',
    basePath : { '../dst' : '.' },
  }
  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  src.filePath = dst.filePath;
  test.is( src.filePath === dst.filePath );
  src.pairWithDst( dst );
  test.is( src.filePath === dst.filePath );

  src.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '../src' : '../dst' } );
  test.identical( src.prefixPath, '/srcPrefix' );
  test.identical( src.basePath, { '../src' : '.' } );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '../src' : '../dst' } );
  test.identical( dst.prefixPath, '/dstPrefix' );
  test.identical( dst.basePath, { '../dst' : '.' } );
  test.is( src.filePath === dst.filePath );

  dst.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '../src' : '../dst' } );
  test.identical( src.prefixPath, '/srcPrefix' );
  test.identical( src.basePath, { '../src' : '.' } );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '../src' : '../dst' } );
  test.identical( dst.prefixPath, '/dstPrefix' );
  test.identical( dst.basePath, { '../dst' : '.' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'file path - relative map, prefix path - absolute string, base path - relative map, no argument';
  var osrc =
  {
  }
  var odst =
  {
    filePath : '/a/b',
    basePath : '/a/b',
  }
  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  src.pairWithDst( dst );
  test.identical( src.filePath, null );
  test.identical( dst.filePath, '/a/b' );

  dst.prefixesRelative();
  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '.' : '.' } );
  test.identical( src.prefixPath, null );
  test.identical( src.basePath, null );
  test.identical( dst.formed, 1 );
  test.identical( dst.filePath, { '.' : '.' } );
  test.identical( dst.prefixPath, '/a/b' );
  test.identical( dst.basePath, '.' );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'file path - map, single, dst is true';
  var osrc =
  {
    filePath : { '**.test** ' : false }
  }
  var src = _.fileProvider.recordFilter( osrc );
  src.prefixesRelative();

  test.identical( src.formed, 1 );
  test.identical( src.filePath, { '**.test** ' : false } );
  test.identical( src.prefixPath, '.' );
  test.identical( src.basePath, null );

}

//

function pathsExtend2( test )
{
  let context = this;
  let provider = new _.FileProvider.Extract();
  let path = provider.path;
  let extract1 = _.FileProvider.Extract();

  /* */

  test.case = 'two strings';

  var f1 = extract1.recordFilter();
  f1.filePath = '/a';

  var f2 = extract1.recordFilter();
  f2.filePath = '/b';

  var f3 = extract1.recordFilter();
  f3.pathsExtend2( f1 ).pathsExtend2( f2 );

  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, { '/a' : null, '/b' : null } );
  test.identical( f3.basePath, null );

  /* */

  test.case = 'bools only';

  // var extract1 = _.FileProvider.Extract
  // ({
  //   filesTree :
  //   {
  //     f : '1',
  //   },
  // });

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = './proto';
  f1.filePath = { 'f' : true, 'd' : true, 'ex' : false, 'f1' : true, 'd1' : true, 'ex1' : false, 'ex3' : true, 'ex4' : false }

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir/filter2'
  f2.basePath = './proto';
  f2.filePath = { 'f' : true, 'd' : true, 'ex' : false, 'f2' : true, 'd2' : true, 'ex2' : false, 'ex3' : false, 'ex4' : true }

  var f3 = extract1.recordFilter();
  f3.pathsExtend2( f1 ).pathsExtend2( f2 );

  var expectedFilePath =
  {
    'f' : true,
    'd' : true,
    'ex' : false,
    'f1' : true,
    'd1' : true,
    'ex1' : false,
    'ex3' : false,
    'ex4' : true,
    'f2' : true,
    'd2' : true,
    'ex2' : false
  }

  var expectedBasePath =
  {
    'f' : '/commonDir/filter2/proto',
    'd' : '/commonDir/filter2/proto',
    'f1' : '/commonDir/filter1/proto',
    'd1' : '/commonDir/filter1/proto',
    'ex3' : '/commonDir/filter1/proto',
    'f2' : '/commonDir/filter2/proto',
    'd2' : '/commonDir/filter2/proto',
    'ex4' : '/commonDir/filter2/proto'
  }

  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, expectedFilePath );
  test.identical( f3.basePath, expectedBasePath );

  /* */

  test.case = 'nulls';

  // var extract1 = _.FileProvider.Extract
  // ({
  //   filesTree :
  //   {
  //     f : '1',
  //   },
  // });

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = './proto';
  f1.filePath = { 'f' : null, 'd' : null, 'ex' : false, 'f1' : null, 'd1' : null, 'ex1' : false, 'ex3' : null, 'ex4' : false }

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir/filter2'
  f2.basePath = './proto';
  f2.filePath = { 'f' : null, 'd' : null, 'ex' : false, 'f2' : null, 'd2' : null, 'ex2' : false, 'ex3' : false, 'ex4' : null }

  var f3 = extract1.recordFilter();
  f3.pathsExtend2( f1 ).pathsExtend2( f2 );

  var expectedFilePath =
  {
    '/commonDir/filter1/f' : '/commonDir/filter1',
    '/commonDir/filter1/d' : '/commonDir/filter1',
    '/commonDir/filter1/f1' : '/commonDir/filter1',
    '/commonDir/filter1/d1' : '/commonDir/filter1',
    '/commonDir/filter1/ex3' : '/commonDir/filter1',
    '/commonDir/filter2/f' : '/commonDir/filter2',
    '/commonDir/filter2/d' : '/commonDir/filter2',
    '/commonDir/filter2/f2' : '/commonDir/filter2',
    '/commonDir/filter2/d2' : '/commonDir/filter2',
    '/commonDir/filter2/ex4' : '/commonDir/filter2',
    'ex' : false,
    'ex1' : false,
    'ex2' : false,
    'ex3' : false,
    'ex4' : false,
  }
  var expectedBasePath =
  {
    '/commonDir/filter1/f' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d' : '/commonDir/filter1/proto',
    '/commonDir/filter1/f1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/ex3' : '/commonDir/filter1/proto',
    '/commonDir/filter2/f' : '/commonDir/filter2/proto',
    '/commonDir/filter2/d' : '/commonDir/filter2/proto',
    '/commonDir/filter2/f2' : '/commonDir/filter2/proto',
    '/commonDir/filter2/d2' : '/commonDir/filter2/proto',
    '/commonDir/filter2/ex4' : '/commonDir/filter2/proto'
  }
  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, expectedFilePath );
  test.identical( f3.basePath, expectedBasePath );

  /* */

  test.case = 'multiple';

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir';
  f1.filePath = { '*exclude*' : 0 }

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir';
  f2.filePath = { 'filter1/f' : 'out/dir' }
  f1.pathsExtend2( f2 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f2.prefixPath, null );
  test.identical( f2.basePath, null );
  test.identical( f2.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

  var f3 = extract1.recordFilter();
  f3.prefixPath = '/commonDir';
  f3.filePath = { 'filter1/f' : 'out/dir' }
  f1.pathsExtend2( f3 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f3.prefixPath, null );
  test.identical( f3.basePath, null );
  test.identical( f3.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

  var f4 = extract1.recordFilter();
  f4.prefixPath = '/commonDir/filter1'
  f4.filePath = { 'f' : 'out/dir' }
  f1.pathsExtend2( f4 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : [ '/commonDir/out/dir', '/commonDir/filter1/out/dir' ] } );
  test.identical( f4.prefixPath, null );
  test.identical( f4.basePath, null );
  test.identical( f4.filePath, { '/commonDir/filter1/f' : '/commonDir/filter1/out/dir' } );

  var f5 = extract1.recordFilter();
  f5.filePath = { '/commonDir/filter1/f' : '/commonDir/out/dir' }
  f1.pathsExtend2( f5 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : [ '/commonDir/out/dir', '/commonDir/filter1/out/dir' ] } );
  test.identical( f5.prefixPath, null );
  test.identical( f5.basePath, null );
  test.identical( f5.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

  /*  */

  test.case = 'extend dot';

  var f1 = extract1.recordFilter();
  f1.filePath = { '.' : null }

  var f2 = extract1.recordFilter();
  f2.filePath =
  {
    '/a/b1' : null,
    '/a/b2' : null,
  }
  f2.basePath = '/a';

  f1.pathsExtend2( f2 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, '/a' );
  test.identical( f1.filePath, { '/a/b1' : null, '/a/b2' : null, } );
  test.identical( f2.prefixPath, null );
  test.identical( f2.basePath, '/a' );
  test.identical( f2.filePath, { '/a/b1' : null, '/a/b2' : null, } );

  /* */

}

//

function pathsInherit( test )
{
  let context = this;
  let provider = new _.FileProvider.Extract();
  let path = provider.path;
  let extract1 = _.FileProvider.Extract();

  /* */

  test.case = 'src.file = single dot, dst.file = map, dst.base = str';

  var f1 = extract1.recordFilter();
  f1.filePath = { '.' : '/dst/a' };

  var f2 = extract1.recordFilter();
  f2.filePath = { '/src/dir' : null, '/src/dir/a' : null };
  f2.basePath = '/src/dir';

  var f3 = extract1.recordFilter();

  f3.pathsInherit( f1 );
  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, { '.' : '/dst/a' } );
  test.identical( f3.basePath, null );

  f3.pathsInherit( f2 );
  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, { '/src/dir' : '/dst/a', '/src/dir/a' : '/dst/a' } );
  test.identical( f3.basePath, '/src/dir' );

  /* */

  test.case = 'src.file = single dot, dst.file = map, dst.base = map';

  var f1 = extract1.recordFilter();
  f1.filePath = { '.' : '/dst' };

  var f2 = extract1.recordFilter();
  f2.filePath = { '/src/dir' : null, '/src/dir/a' : null, '/src/dir/b' : null };
  f2.basePath = { '/src/dir' : '/src', '/src/dir/a' : '/src', '/src/dir/b' : '/src' };

  var f3 = extract1.recordFilter();

  f3.pathsInherit( f1 );
  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, { '.' : '/dst' } );
  test.identical( f3.basePath, null );

  f3.pathsInherit( f2 );
  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, { '/src/dir' : '/dst', '/src/dir/a' : '/dst', '/src/dir/b' : '/dst' } );
  test.identical( f3.basePath, { '/src/dir' : '/src', '/src/dir/a' : '/src', '/src/dir/b' : '/src' } );

  /* */

  test.case = 'two strings';

  var f1 = extract1.recordFilter();
  f1.filePath = '/a';

  var f2 = extract1.recordFilter();
  f2.filePath = '/b';

  var f3 = extract1.recordFilter();
  f3.pathsInherit( f1 ).pathsInherit( f2 );

  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, '/a' );
  test.identical( f3.basePath, null );

  /* */

  test.case = 'bools only';

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir/filter1';
  f1.basePath = './proto';
  f1.filePath = { 'f' : true, 'd' : true, 'ex' : false, 'f1' : true, 'd1' : true, 'ex1' : false, 'ex3' : true, 'ex4' : false }

  var f3 = extract1.recordFilter();
  f3.pathsInherit( f1 )

  var expectedFilePath =
  {
    'f' : true,
    'd' : true,
    'ex' : false,
    'f1' : true,
    'd1' : true,
    'ex1' : false,
    'ex3' : true,
    'ex4' : false,
  }

  var expectedBasePath = './proto';

  test.identical( f3.prefixPath, '/commonDir/filter1' );
  test.identical( f3.filePath, expectedFilePath );
  test.identical( f3.basePath, expectedBasePath );

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir/filter2';
  f2.basePath = './proto';
  f2.filePath = { 'f' : true, 'd' : true, 'ex' : false, 'f2' : true, 'd2' : true, 'ex2' : false, 'ex3' : false, 'ex4' : true }

  var expectedFilePath =
  {
    'f' : true,
    'd' : true,
    'ex' : false,
    'f1' : true,
    'd1' : true,
    'ex1' : false,
    'ex3' : false,
    'ex4' : true,
    'f2' : true,
    'd2' : true,
    'ex2' : false
  }

  var expectedBasePath =
  {
    'f' : '/commonDir/filter1/proto',
    'd' : '/commonDir/filter1/proto',
    'f1' : '/commonDir/filter1/proto',
    'd1' : '/commonDir/filter1/proto',
    'f2' : '/commonDir/filter2/proto',
    'd2' : '/commonDir/filter2/proto',
    'ex4' : '/commonDir/filter2/proto'
  }

  f3.pathsInherit( f2 );

  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, expectedFilePath );
  test.identical( f3.basePath, expectedBasePath );

  /* */

  test.case = 'nulls';

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = './proto';
  f1.filePath = { 'f' : null, 'd' : null, 'ex' : false, 'f1' : null, 'd1' : null, 'ex1' : false, 'ex3' : null, 'ex4' : false }

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir/filter2'
  f2.basePath = './proto';
  f2.filePath = { 'f' : null, 'd' : null, 'ex' : false, 'f2' : null, 'd2' : null, 'ex2' : false, 'ex3' : false, 'ex4' : null }

  var f3 = extract1.recordFilter();
  f3.pathsInherit( f1 ).pathsInherit( f2 );

  var expectedFilePath =
  {
    '/commonDir/filter1/f' : '/commonDir/filter1',
    '/commonDir/filter1/d' : '/commonDir/filter1',
    'ex' : false,
    '/commonDir/filter1/f1' : '/commonDir/filter1',
    '/commonDir/filter1/d1' : '/commonDir/filter1',
    'ex1' : false,
    '/commonDir/filter1/ex3' : '/commonDir/filter1',
    'ex4' : false,
    'ex2' : false,
    'ex3' : false,
  }
  var expectedBasePath =
  {
    '/commonDir/filter1/f' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d' : '/commonDir/filter1/proto',
    '/commonDir/filter1/f1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/ex3' : '/commonDir/filter1/proto',
  }
  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, expectedFilePath );
  test.identical( f3.basePath, expectedBasePath );

  /* */

  test.case = 'multiple';

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir';
  f1.filePath = { '/commonDir/*exclude*' : 0 }

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir';
  f2.filePath = { 'filter1/f' : 'out/dir' }
  f1.pathsInherit( f2 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '/commonDir/*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f2.prefixPath, null );
  test.identical( f2.basePath, null );
  test.identical( f2.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

  var f3 = extract1.recordFilter();
  f3.prefixPath = '/commonDir';
  f3.filePath = { 'filter1/f' : 'out/dir' }
  f1.pathsInherit( f3 );
  test.identical( f1.prefixPath, '/commonDir' );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '/commonDir/*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f3.prefixPath, '/commonDir' );
  test.identical( f3.basePath, null );
  test.identical( f3.filePath, { 'filter1/f' : 'out/dir' } );

  var f4 = extract1.recordFilter();
  f4.prefixPath = '/commonDir/filter1'
  f4.filePath = { 'f' : 'out/dir' }
  f1.pathsInherit( f4 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '/commonDir/*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f4.prefixPath, null );
  test.identical( f4.basePath, null );
  test.identical( f4.filePath, { '/commonDir/filter1/f' : '/commonDir/filter1/out/dir' } );

  var f5 = extract1.recordFilter();
  f5.filePath = { '/commonDir/filter1/f' : '/commonDir/out/dir' }
  f1.pathsInherit( f5 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '/commonDir/*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f5.prefixPath, null );
  test.identical( f5.basePath, null );
  test.identical( f5.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

}

// //
//
// function pairRefine( test )
// {
//
//   /* */
//
//   test.case = 'src.file - only map';
//
//   var osrc =
//   {
//     filePath : { '/src' : '/dst' }
//   }
//   var odst =
//   {
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - only map, with only true';
//
//   var osrc =
//   {
//     filePath : { '/src' : true }
//   }
//   var odst =
//   {
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : true } );
//   test.identical( dst.filePath, { '/src' : true } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - only map with bools';
//
//   var osrc =
//   {
//     filePath : { '/src' : true, '/src2' : '/dst2' }
//   }
//   var odst =
//   {
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : true, '/src2' : '/dst2' } );
//   test.identical( dst.filePath, { '/src' : true, '/src2' : '/dst2' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'dst.file - only map';
//
//   var osrc =
//   {
//   }
//   var odst =
//   {
//     filePath : { '/src' : '/dst' }
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'dst.file - only map, with only true';
//
//   var osrc =
//   {
//   }
//   var odst =
//   {
//     filePath : { '/src' : true }
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : true } );
//   test.identical( dst.filePath, { '/src' : true } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'dst.file - only map, with true';
//
//   var osrc =
//   {
//   }
//   var odst =
//   {
//     filePath : { '/src' : true, '/src2' : '/dst' }
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : true, '/src2' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : true, '/src2' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'dst.file - only map, with null';
//
//   var osrc =
//   {
//   }
//   var odst =
//   {
//     filePath : { '/src' : null, '/src2' : '/dst' }
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst', '/src2' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst', '/src2' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - map, dst.file - map';
//
//   var osrc =
//   {
//     filePath : { '/src' : '/dst' }
//   }
//   var odst =
//   {
//     filePath : { '/src' : '/dst' }
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - map, dst.file - string';
//
//   var osrc =
//   {
//     filePath : { '/src' : '/dst' }
//   }
//   var odst =
//   {
//     filePath : '/dst'
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - string, dst.file - map';
//
//   var osrc =
//   {
//     filePath : '/src'
//   }
//   var odst =
//   {
//     filePath : { '/src' : '/dst' }
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - string, dst.file - string';
//
//   var osrc =
//   {
//     filePath : '/src'
//   }
//   var odst =
//   {
//     filePath : '/dst'
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : '/dst' } );
//   test.identical( dst.filePath, { '/src' : '/dst' } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'src.file - only string';
//
//   var osrc =
//   {
//     filePath : '/src'
//   }
//   var odst =
//   {
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '/src' : null } );
//   test.identical( dst.filePath, { '/src' : null } );
//   test.is( src.filePath === dst.filePath );
//
//   /* */
//
//   test.case = 'dst.file - only string';
//
//   var osrc =
//   {
//   }
//   var odst =
//   {
//     filePath : '/dst'
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, null );
//   test.identical( dst.filePath, '/dst' );
//
//   /* */
//
//   test.case = 'dst.file - map without dst, src.file - map without dst';
//
//   var osrc =
//   {
//     filePath : { '.' : true },
//   }
//   var odst =
//   {
//     filePath : { '.' : true },
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.filePath, { '.' : true } );
//   test.identical( dst.filePath, { '.' : true } );
//
//   /* */
//
//   test.case = 'dst.file - map without dst, src.file - map without dst, src.prefix';
//
//   var osrc =
//   {
//     filePath : { '.' : true },
//     prefixPath : '/a/b',
//   }
//   var odst =
//   {
//     filePath : { '.' : true },
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.prefixPath, '/a/b' );
//   test.identical( src.filePath, { '.' : true } );
//   test.identical( dst.filePath, { '.' : true } );
//   test.is( dst.filePath === src.filePath );
//
//   /* */
//
//   test.case = 'dst.file - map without dst, dst.prefix, src.file - map without dst';
//
//   var osrc =
//   {
//     filePath : { '.' : null },
//   }
//   var odst =
//   {
//     filePath : { '.' : null },
//     prefixPath : '/a/b',
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//   test.identical( src.prefixPath, null );
//   test.identical( src.filePath, { '.' : '/a/b' } );
//   test.identical( dst.filePath, { '.' : '/a/b' } );
//   test.is( dst.filePath === src.filePath );
//
//   /* */
//
//   test.case = 'src.file - map, dst.file - string, both prefixes';
//
//   var osrc =
//   {
//     prefixPath : '/',
//     filePath : { '**.js' : null, '**.s' : null },
//   }
//   var odst =
//   {
//     prefixPath : '/',
//     filePath : '/dst/dir',
//   }
//
//   var src = _.fileProvider.recordFilter( osrc );
//   var dst = _.fileProvider.recordFilter( odst );
//   test.identical( src.formed, 1 );
//   test.identical( dst.formed, 1 );
//
//   src.pairWithDst( dst );
//   src.pairRefine();
//
//   test.identical( src.formed, 1 );
//   test.identical( src.prefixPath, null );
//   test.identical( src.filePath, { '/**.js' : '/dst/dir', '/**.s' : '/dst/dir' } );
//   test.identical( src.basePath, null );
//
//   test.identical( dst.formed, 1 );
//   test.identical( dst.prefixPath, null );
//   test.identical( dst.filePath, { '/**.js' : '/dst/dir', '/**.s' : '/dst/dir' } );
//   test.identical( dst.basePath, null );
//
//   test.is( dst.filePath === src.filePath );
//
//   /* */
//
//   test.case = 'pair, src.file - map, src.prefix - str, dst.file - string, dst.prefix - string, dst.file - .';
//
//   var src = _.fileProvider.recordFilter();
//   src.filePath = { c : 'c2', d : null };
//   src.prefixPath = '/src';
//   src.postfixPath = null;
//   src.basePath = null;
//
//   var dst = _.fileProvider.recordFilter();
//   dst.filePath = '.';
//   dst.prefixPath = '/dst';
//   dst.postfixPath = null;
//   dst.basePath = null;
//
//   test.identical( src.hasAnyPath(), true );
//   test.identical( dst.hasAnyPath(), true );
//   src.pairWithDst( dst )
//   src.pairRefine();
//   test.identical( src.hasAnyPath(), true );
//   test.identical( dst.hasAnyPath(), true );
//   test.is( src.filePath === dst.filePath );
//   test.is( _.mapIs( src.filePath ) );
//
//   test.identical( src.filePath, { '/src/c' : '/dst/c2', '/src/d' : '/dst' } );
//   test.identical( src.prefixPath, null );
//   test.identical( src.postfixPath, null );
//   test.identical( src.basePath, null );
//   test.identical( dst.filePath, { '/src/c' : '/dst/c2', '/src/d' : '/dst' } );
//   test.identical( dst.prefixPath, null );
//   test.identical( dst.postfixPath, null );
//   test.identical( dst.basePath, null );
//
//   /* - */
//
//   if( Config.debug )
//   {
//     test.open( 'throwing' );
//
//     test.case = 'src.file - map, dst.file - map, inconsistant src';
//     var src = _.fileProvider.recordFilter({ filePath : { '/src1' : '/dst' } });
//     var dst = _.fileProvider.recordFilter({ filePath : { '/src2' : '/dst' } });
//     src.pairWithDst( dst );
//     test.shouldThrowErrorSync( () => src.pairRefine() );
//
//     test.case = 'src.file - string, dst.file - map, inconsistant src';
//     var src = _.fileProvider.recordFilter({ filePath : '/src1' });
//     var dst = _.fileProvider.recordFilter({ filePath : { '/src2' : '/dst' } });
//     src.pairWithDst( dst );
//     test.shouldThrowErrorSync( () => src.pairRefine() );
//
//     test.case = 'src.file - map, dst.file - map, inconsistant dst';
//     var src = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst1' } });
//     var dst = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst2' } });
//     src.pairWithDst( dst );
//     test.shouldThrowErrorSync( () => src.pairRefine() );
//
//     test.case = 'src.file - map, dst.file - map, inconsistant dst';
//     var src = _.fileProvider.recordFilter({ filePath : { '/src' : true } });
//     var dst = _.fileProvider.recordFilter({ filePath : { '/src' : null } });
//     src.pairWithDst( dst );
//     test.shouldThrowErrorSync( () => src.pairRefine() );
//
//     test.case = 'src.file - map, dst.file - string, inconsistant dst';
//     var src = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst1' } });
//     var dst = _.fileProvider.recordFilter({ filePath : '/dst2' });
//     src.pairWithDst( dst );
//     test.shouldThrowErrorSync( () => src.pairRefine() );
//
//     test.close( 'throwing' );
//   }
//
// }

//

function pairRefineLight( test )
{

  /* */

  test.case = 'empty';
  var src = _.fileProvider.recordFilter();
  var dst = _.fileProvider.recordFilter();
  src.pairWithDst( dst )
  src.pairRefineLight();

  test.identical( src.hasAnyPath(), false );
  test.identical( src.filePath, null );
  test.identical( src.prefixPath, null );
  test.identical( src.postfixPath, null );
  test.identical( src.basePath, null );

  test.identical( dst.hasAnyPath(), false );
  test.identical( dst.filePath, null );
  test.identical( dst.prefixPath, null );
  test.identical( dst.postfixPath, null );
  test.identical( dst.basePath, null );

  /* */

  test.case = 'pair, src.file - map, dst.file - string, dst.prefix - string';

  var src = _.fileProvider.recordFilter();
  src.filePath = { '.' : null };
  src.prefixPath = '/a/b';
  src.postfixPath = null;
  src.basePath = null;

  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/a/dst/file';
  dst.prefixPath = '/a/dst';
  dst.postfixPath = null;
  dst.basePath = null;

  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), true );
  src.pairWithDst( dst )
  src.pairRefineLight();
  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), true );
  test.is( src.filePath === dst.filePath );
  test.is( _.mapIs( src.filePath ) );

  test.identical( src.filePath, { '.' : '/a/dst/file' } );
  test.identical( src.prefixPath, '/a/b' );
  test.identical( src.postfixPath, null );
  test.identical( src.basePath, null );
  test.identical( dst.filePath, { '.' : '/a/dst/file' } );
  test.identical( dst.prefixPath, '/a/dst' );
  test.identical( dst.postfixPath, null );
  test.identical( dst.basePath, null );

  /* */

  test.case = 'pair, src.file - map, src.prefix - str, dst.file - string, dst.prefix - string, dst.file - str';

  var src = _.fileProvider.recordFilter();
  src.filePath = { c : 'c2', d : null };
  src.prefixPath = '/src';
  src.postfixPath = null;
  src.basePath = null;

  var dst = _.fileProvider.recordFilter();
  dst.filePath = 'dir';
  dst.prefixPath = '/dst';
  dst.postfixPath = null;
  dst.basePath = null;

  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), true );
  src.pairWithDst( dst )
  src.pairRefineLight();
  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), true );
  test.is( src.filePath === dst.filePath );
  test.is( _.mapIs( src.filePath ) );

  test.identical( src.filePath, { 'c' : 'c2', 'd' : 'dir' } );
  test.identical( src.prefixPath, '/src' );
  test.identical( src.postfixPath, null );
  test.identical( src.basePath, null );
  test.identical( dst.filePath, { 'c' : 'c2', 'd' : 'dir' } );
  test.identical( dst.prefixPath, '/dst' );
  test.identical( dst.postfixPath, null );
  test.identical( dst.basePath, null );

  /* */

  test.case = 'pair, src.file - map, src.prefix - str, dst.file - string, dst.prefix - string, dst.file - .';

  var src = _.fileProvider.recordFilter();
  src.filePath = { c : 'c2', d : null };
  src.prefixPath = '/src';
  src.postfixPath = null;
  src.basePath = null;

  var dst = _.fileProvider.recordFilter();
  dst.filePath = '.';
  dst.prefixPath = '/dst';
  dst.postfixPath = null;
  dst.basePath = null;

  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), true );
  src.pairWithDst( dst )
  src.pairRefineLight();
  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), true );
  test.is( src.filePath === dst.filePath );
  test.is( _.mapIs( src.filePath ) );

  test.identical( src.filePath, { 'c' : 'c2', 'd' : '.' } );
  test.identical( src.prefixPath, '/src' );
  test.identical( src.postfixPath, null );
  test.identical( src.basePath, null );
  test.identical( dst.filePath, { 'c' : 'c2', 'd' : '.' } );
  test.identical( dst.prefixPath, '/dst' );
  test.identical( dst.postfixPath, null );
  test.identical( dst.basePath, null );

  /* */

  test.case = 'src.file - only map';

  var osrc =
  {
    filePath : { '/src' : '/dst' }
  }
  var odst =
  {
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - only map, with only true';

  var osrc =
  {
    filePath : { '/src' : true }
  }
  var odst =
  {
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true } );
  test.identical( dst.filePath, { '/src' : true } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - only map with bools';

  var osrc =
  {
    filePath : { '/src' : true, '/src2' : '/dst2' }
  }
  var odst =
  {
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true, '/src2' : '/dst2' } );
  test.identical( dst.filePath, { '/src' : true, '/src2' : '/dst2' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.file - only map';

  var osrc =
  {
  }
  var odst =
  {
    filePath : { '/src' : '/dst' }
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.file - only map, with only true';

  var osrc =
  {
  }
  var odst =
  {
    filePath : { '/src' : true }
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true } );
  test.identical( dst.filePath, { '/src' : true } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.file - only map, with true';

  var osrc =
  {
  }
  var odst =
  {
    filePath : { '/src' : true, '/src2' : '/dst' }
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true, '/src2' : '/dst' } );
  test.identical( dst.filePath, { '/src' : true, '/src2' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.file - only map, with null';

  var osrc =
  {
  }
  var odst =
  {
    filePath : { '/src' : null, '/src2' : '/dst' }
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : null, '/src2' : '/dst' } );
  test.identical( dst.filePath, { '/src' : null, '/src2' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - map, dst.file - map';

  var osrc =
  {
    filePath : { '/src' : '/dst' }
  }
  var odst =
  {
    filePath : { '/src' : '/dst' }
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - map, dst.file - string';

  var osrc =
  {
    filePath : { '/src' : '/dst' }
  }
  var odst =
  {
    filePath : '/dst'
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - string, dst.file - map';

  var osrc =
  {
    filePath : '/src'
  }
  var odst =
  {
    filePath : { '/src' : '/dst' }
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - string, dst.file - string';

  var osrc =
  {
    filePath : '/src'
  }
  var odst =
  {
    filePath : '/dst'
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.file - only string';

  var osrc =
  {
    filePath : '/src'
  }
  var odst =
  {
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  debugger;
  src.pairRefineLight();
  debugger;

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : null } );
  test.identical( dst.filePath, { '/src' : null } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.file - only string';

  var osrc =
  {
  }
  var odst =
  {
    filePath : '/dst'
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '.' : '/dst' } );
  test.identical( dst.filePath, { '.' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.file - map without dst, src.file - map without dst';

  var osrc =
  {
    filePath : { '.' : true },
  }
  var odst =
  {
    filePath : { '.' : true },
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '.' : true } );
  test.identical( dst.filePath, { '.' : true } );

  /* */

  test.case = 'dst.file - map without dst, src.file - map without dst, src.prefix';

  var osrc =
  {
    filePath : { '.' : true },
    prefixPath : '/a/b',
  }
  var odst =
  {
    filePath : { '.' : true },
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.prefixPath, '/a/b' );
  test.identical( src.filePath, { '.' : true } );
  test.identical( dst.filePath, { '.' : true } );
  test.is( dst.filePath === src.filePath );

  /* */

  test.case = 'dst.file - map without dst, dst.prefix, src.file - map without dst';

  var osrc =
  {
    filePath : { '.' : null },
  }
  var odst =
  {
    filePath : { '.' : null },
    prefixPath : '/a/b',
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( src.prefixPath, null );
  test.identical( src.filePath, { '.' : null } );
  test.identical( dst.formed, 1 );
  test.identical( dst.prefixPath, '/a/b' );
  test.identical( dst.filePath, { '.' : null } );
  test.is( dst.filePath === src.filePath );

  /* */

  test.case = 'src.file - map, dst.file - string, both prefixes';

  var osrc =
  {
    prefixPath : '/',
    filePath : { '**.js' : null, '**.s' : null },
  }
  var odst =
  {
    prefixPath : '/',
    filePath : '/dst/dir',
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( src.prefixPath, '/' );
  test.identical( src.filePath, { '**.js' : '/dst/dir', '**.s' : '/dst/dir' } );
  test.identical( src.basePath, null );

  test.identical( dst.formed, 1 );
  test.identical( dst.prefixPath, '/' );
  test.identical( dst.filePath, { '**.js' : '/dst/dir', '**.s' : '/dst/dir' } );
  test.identical( dst.basePath, null );

  test.is( dst.filePath === src.filePath );

  /* */

  test.case = 'src.file - map, dst.file - string, redundant dst';

  var osrc =
  {
    filePath : { '/src' : '/dst1' },
  }
  var odst =
  {
    filePath : '/dst2',
  }

  var src = _.fileProvider.recordFilter( osrc );
  var dst = _.fileProvider.recordFilter( odst );
  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );

  src.pairWithDst( dst );
  src.pairRefineLight();

  test.identical( src.formed, 1 );
  test.identical( src.prefixPath, null );
  test.identical( src.filePath, { '/src' : '/dst1' } );
  test.identical( src.basePath, null );

  test.identical( dst.formed, 1 );
  test.identical( dst.prefixPath, null );
  test.identical( dst.filePath, { '/src' : '/dst1' } );
  test.identical( dst.basePath, null );

  test.is( dst.filePath === src.filePath );

  /* - */

  if( Config.debug )
  {
    test.open( 'throwing' );

    test.case = 'src.file - map, dst.file - map, inconsistant src';
    var src = _.fileProvider.recordFilter({ filePath : { '/src1' : '/dst' } });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src2' : '/dst' } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefineLight() );

    test.case = 'src.file - string, dst.file - map, inconsistant src';
    var src = _.fileProvider.recordFilter({ filePath : '/src1' });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src2' : '/dst' } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefineLight() );

    test.case = 'src.file - map, dst.file - map, inconsistant dst';
    var src = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst1' } });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst2' } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefineLight() );

    test.case = 'src.file - map, dst.file - map, inconsistant dst';
    var src = _.fileProvider.recordFilter({ filePath : { '/src' : true } });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src' : null } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefineLight() );

    test.close( 'throwing' );
  }

}

//

function moveTextualReport( test )
{

  /* */

  test.case = 'empty';
  var src = _.fileProvider.recordFilter();
  var dst = _.fileProvider.recordFilter();
  src.pairWithDst( dst )
  src.pairRefineLight();
  var expected = '{null} : . <- .';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

  test.case = 'src.file, no refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/src';
  var dst = _.fileProvider.recordFilter();
  src.pairWithDst( dst )
  var expected = '/{null} <- /src';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

  test.case = 'dst.file, no refine';
  var src = _.fileProvider.recordFilter();
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/dst';
  src.pairWithDst( dst )
  var expected = '/dst <- /{null}';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

  test.case = 'src.file, dst.file, no refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/src';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/dst';
  src.pairWithDst( dst )
  var expected = '/dst <- /src';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

  test.case = 'src.file, dst.file, refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/src';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/dst';
  src.pairWithDst( dst )
  var expected = '/dst <- /src';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

  test.case = 'src.file, dst.file, refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/common/src';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/common/dst';
  src.pairWithDst( dst )
  var expected = '/common/ : dst <- src';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

  test.case = 'src.file, dst.file, src.prefix, dst.prefix, refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = './src';
  src.prefixPath = '/common';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = './dst';
  dst.prefixPath = '/common';
  src.pairWithDst( dst )
  var expected = '/common/ : dst <- src';
  var got = src.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );
  var got = dst.moveTextualReport();
  test.identical( _.color.strStrip( got ), expected );

  /* */

}

//

function filePathSimplest( test )
{

  /* */

  test.case = 'empty';
  var src = _.fileProvider.recordFilter();
  var dst = _.fileProvider.recordFilter();
  src.pairWithDst( dst )
  src.pairRefineLight();
  var expected = null;
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = null;
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

  test.case = 'src.file, no refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/src';
  var dst = _.fileProvider.recordFilter();
  src.pairWithDst( dst )
  var expected = '/src';
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = null;
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

  test.case = 'dst.file, no refine';
  var src = _.fileProvider.recordFilter();
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/dst';
  src.pairWithDst( dst )
  var expected = null;
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = '/dst';
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

  test.case = 'src.file, dst.file, no refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/src';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/dst';
  src.pairWithDst( dst )
  var expected = '/src';
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = '/dst';
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

  test.case = 'src.file, dst.file, refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/src';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/dst';
  src.pairWithDst( dst )
  var expected = '/src';
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = '/dst';
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

  test.case = 'src.file, dst.file, refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/common/src';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/common/dst';
  src.pairWithDst( dst )
  var expected = '/common/src';
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = '/common/dst';
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

  test.case = 'src.file, dst.file, src.prefix, dst.prefix, refine';
  var src = _.fileProvider.recordFilter();
  src.filePath = './src';
  src.prefixPath = '/common';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = './dst';
  dst.prefixPath = '/common';
  src.pairWithDst( dst )
  var expected = './src';
  var got = src.filePathSimplest();
  test.identical( got, expected );
  var expected = './dst';
  var got = dst.filePathSimplest();
  test.identical( got, expected );

  /* */

}

//

function hasAnyPath( test )
{

  var src = _.fileProvider.recordFilter();
  test.identical( src.formed, 1 );

  test.case = 'trivial';
  test.identical( src.hasAnyPath(), false );

  test.case = 'file path';
  src.filePath = '/a/b';
  src.prefixPath = null;
  src.postfixPath = null;
  src.basePath = null;
  test.identical( src.hasAnyPath(), true );

  test.case = 'prefix path';
  src.filePath = null;
  src.prefixPath = '/a/b';
  src.postfixPath = null;
  src.basePath = null;
  test.identical( src.hasAnyPath(), true );

  test.case = 'posftix path';
  src.filePath = null;
  src.prefixPath = null;
  src.postfixPath = '/a/b';
  src.basePath = null;
  test.identical( src.hasAnyPath(), true );

  test.case = 'bae path';
  src.filePath = null;
  src.prefixPath = null;
  src.postfixPath = null;
  src.basePath = '/a/b';
  test.identical( src.hasAnyPath(), true );

  test.case = 'pair, file path map';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/a/b';
  src.prefixPath = null;
  src.postfixPath = null;
  src.basePath = null;
  var dst = _.fileProvider.recordFilter();
  dst.filePath = null;
  dst.prefixPath = null;
  dst.postfixPath = null;
  dst.basePath = null;
  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), false );
  src.pairWithDst( dst )
  src.pairRefineLight();
  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), false );
  test.is( src.filePath === dst.filePath );
  test.is( _.mapIs( src.filePath ) );

  test.case = 'src.file = dot, dst.file = null';
  var src = _.fileProvider.recordFilter();
  src.filePath = '.';
  src.prefixPath = null;
  src.postfixPath = null;
  src.basePath = null;
  var dst = _.fileProvider.recordFilter();
  dst.filePath = null;
  dst.prefixPath = null;
  dst.postfixPath = null;
  dst.basePath = null;
  test.identical( src.hasAnyPath(), false );
  test.identical( dst.hasAnyPath(), false );
  src.pairWithDst( dst )
  src.pairRefineLight();
  test.identical( src.hasAnyPath(), false );
  test.identical( dst.hasAnyPath(), false );
  test.identical( src.filePath, { '.' : null } );
  test.is( src.filePath === dst.filePath );

  test.case = 'src.file = dot, dst.file = dot';
  var src = _.fileProvider.recordFilter();
  src.filePath = '.';
  src.prefixPath = null;
  src.postfixPath = null;
  src.basePath = null;
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '.';
  dst.prefixPath = null;
  dst.postfixPath = null;
  dst.basePath = null;
  test.identical( src.hasAnyPath(), false );
  test.identical( dst.hasAnyPath(), false );
  src.pairWithDst( dst )
  test.identical( src.hasAnyPath(), false );
  test.identical( dst.hasAnyPath(), true );
  src.pairRefineLight();
  test.identical( src.hasAnyPath(), false );
  test.identical( dst.hasAnyPath(), true );
  test.identical( src.filePath, { '.' : '.' } );
  test.is( src.filePath === dst.filePath );

}

//

function filePathSelect( test )
{

  var filter = _.fileProvider.recordFilter();
  filter.filePath =
  {
    '/src' : '/dst',
    '/src/**.test*' : true,
    '/src/**.release*' : false,
  }
  filter.basePath = '/';
  test.identical( filter.formed, 1 );

  var srcPath =
  {
    '/src' : '/dst',
    '/src/**.test*' : true,
    '/src/**.release*' : false,
  }
  var dstPath = '/dst';

  filter.filePathSelect( srcPath, dstPath );

  test.identical( filter.formed, 5 );
  test.identical( filter.filePath, { '/src' : '/dst', '/src/**.test*' : true, '/src/**.release*' : false } );
  test.identical( filter.basePath, { '/src' : '/' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );

}

//

function filePathArrayGet( test )
{

  /* */

  test.case = 'src.file - string, not refined paring';
  var src = _.fileProvider.recordFilter();
  src.filePath = '/ab';
  var dst = _.fileProvider.recordFilter();
  dst.filePath = null;
  src.pairWithDst( dst )

  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 0';
  var expected = [ null ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ null ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 0';
  var expected = [ '/ab' ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ '/ab' ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathDstArrayBoolGet';
  var expected = [];
  var got = src.filePathDstArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathDstArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayBoolGet';
  var expected = [];
  var got = src.filePathSrcArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  /* */

  test.case = 'dst.file - string, not refined paring';
  var src = _.fileProvider.recordFilter();
  src.filePath = null;
  var dst = _.fileProvider.recordFilter();
  dst.filePath = '/ab';
  src.pairWithDst( dst )

  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 0';
  var expected = [];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var expected = [ '/ab' ];
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 1';
  var expected = [];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var expected = [ '/ab' ];
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 0';
  var expected = [];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var expected = [ null ];
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 1';
  var expected = [];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var expected = [ null ];
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathDstArrayBoolGet';
  var expected = [];
  var got = src.filePathDstArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathDstArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayBoolGet';
  var expected = [];
  var got = src.filePathSrcArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  /* */

  test.case = 'src.file - complex array, not refined paring';
  var src = _.fileProvider.recordFilter();
  src.filePath = [ '/ab', '/cd', '/ab', null ];
  var dst = _.fileProvider.recordFilter();
  dst.filePath = null;
  src.pairWithDst( dst )

  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 0';
  var expected = [ null ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ null ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 0';
  var expected = [ '/ab', '/cd', null ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ '/ab', '/cd', null ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var expected = [];
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathDstArrayBoolGet';
  var expected = [];
  var got = src.filePathDstArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathDstArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayBoolGet';
  var expected = [];
  var got = src.filePathSrcArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  /* */

  test.case = 'src.file - single-key map with true in dst';
  var src = _.fileProvider.recordFilter();
  src.filePath = { '/' : true };
  var dst = _.fileProvider.recordFilter();
  dst.filePath = null;
  src.pairWithDst( dst )
  src.pairRefineLight();

  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 0';
  var expected = [];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ null ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 0';
  var expected = [];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ '/' ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathDstArrayBoolGet';
  var expected = [ true ];
  var got = src.filePathDstArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathDstArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayBoolGet';
  var expected = [ '/' ];
  var got = src.filePathSrcArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  /* */

  test.case = 'src.file - complex map';
  var src = _.fileProvider.recordFilter();
  src.filePath = { 'True' : true, 'False' : false, 'Zero' : 0, 'One' : 1, 'Null' : null, 'str' : 'str', 'Array' : [ 'a', 'b' ] };
  var dst = _.fileProvider.recordFilter();
  dst.filePath = null;
  src.pairWithDst( dst )
  src.pairRefineLight();

  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 0';
  var expected = [ null, 'str', 'a', 'b' ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathDstArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ null, 'str', 'a', 'b' ];
  var got = src.filePathDstArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var got = dst.filePathDstArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 0';
  var expected = [ 'Null', 'str', 'Array' ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 0 );
  test.identical( got, expected );
  test.description = 'filePathSrcArrayNonBoolGet, boolFallingBack : 1';
  var expected = [ 'Null', 'str', 'Array' ];
  var got = src.filePathSrcArrayNonBoolGet( src.filePath, 1 );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayNonBoolGet( dst.filePath, 1 );
  test.identical( got, expected );

  test.description = 'filePathDstArrayBoolGet';
  var expected = [ true, false ];
  var got = src.filePathDstArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathDstArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  test.description = 'filePathSrcArrayBoolGet';
  var expected = [ 'True', 'False', 'Zero', 'One' ];
  var got = src.filePathSrcArrayBoolGet( src.filePath );
  test.identical( got, expected );
  var got = dst.filePathSrcArrayBoolGet( dst.filePath );
  test.identical( got, expected );

  /* */

}

// //
//
// function _eachCombination( o )
// {
//   let test = o.test;
//
//   _.routineOptions( _eachCombination, arguments );
//
//   /* */
//
//   test.case = 'src.file - string';
//   var src = _.fileProvider.recordFilter();
//   src.filePath = '/a/b';
//   var dst = _.fileProvider.recordFilter();
//   dst.filePath = null;
//   handleEach( dst, src );
//
//   /* */
//
//   test.case = 'src.file - map with dst=true';
//   var src = _.fileProvider.recordFilter();
//   src.filePath = { '/' : true };
//   var dst = _.fileProvider.recordFilter();
//   dst.filePath = null;
//   handleEach( dst, src );
//
//   /* */
//
//   function handleEach( dst, src )
//   {
//     if( o.pairing )
//     {
//       src.pairWithDst( dst )
//       src.pairRefine();
//     }
//     o.onEach( dst, src );
//   }
//
// }
//
// _eachCombination.defaults =
// {
//   test : test,
//   onEach : null,
//   pairing : 1,
// }

// --
// proto
// --

var Self =
{

  name : 'Tools/mid/files/RecordFilter',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  tests :
  {

    make,
    form,

    reflect,
    clone,
    prefixesApply,
    prefixesRelative,
    pathsExtend2,
    pathsInherit,

    pairRefineLight,
    moveTextualReport,
    filePathSimplest,

    hasAnyPath,
    filePathSelect,
    filePathArrayGet,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
