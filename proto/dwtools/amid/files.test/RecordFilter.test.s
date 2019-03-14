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
    _.assert( _.strEnds( testSuitePath, 'FileRecordFilter' ) );
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
  logger.log( filter );
  test.identical( filter.filePath, '/src' );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  filter.copy( '/dst' );
  logger.log( filter );
  test.identical( filter.filePath, '/dst' );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  test.identical( filter.basePath, null );
  test.identical( filter.formed, 1 );

  /* */

  test.case = 'filter from string';
  var filter = provider.recordFilter( '/src' );
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

  test.case = 'filter from array';
  var filter = provider.recordFilter([ '/src/a', '/src/b' ]);
  logger.log( filter );
  test.identical( filter.filePath, [ '/src/a', '/src/b' ] );
  test.identical( filter.prefixPath, null );
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
  test.identical( filter.filePath, [ '/src/a', 'src/b' ] );
  test.identical( filter.prefixPath, null );
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
    srcFilter : { prefixPath : '/' },
    dstFilter : { prefixPath : '/' },
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
    srcFilter : { prefixPath : '/' },
    // dstFilter : { prefixPath : '/' },
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
    // srcFilter : { prefixPath : '/' },
    dstFilter : { prefixPath : '/' },
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
      // srcFilter : { prefixPath : '/' },
      // dstFilter : { prefixPath : '/' },
    });
  });

  test.shouldThrowError( () =>
  {
    extract1.filesReflect
    ({
      reflectMap : { 'src' : 'dst' },
      srcFilter : { prefixPath : '/' },
      // dstFilter : { prefixPath : '/' },
    });
  });

  test.shouldThrowError( () =>
  {
    extract1.filesReflect
    ({
      reflectMap : { 'src' : 'dst' },
      // srcFilter : { prefixPath : '/' },
      dstFilter : { prefixPath : '/' },
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

  test.case = 'trivial, only bools';

  var f1 = extract1.recordFilter({});
  var expectedBasePath = '/dir/filter1/proto';
  // var expectedFilePath = { '/dir/filter1/f' : '/dir/filter1', '/dir/filter1/d' : '/dir/filter1', '/dir/filter1/ex' : false }
  var expectedFilePath = { 'f' : true, 'd' : true, 'ex' : false }

  f1.filePath = { 'f' : true, 'd' : true, 'ex' : false }
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
  // var expectedFilePath = { '/dir/filter1/f' : '/dir/filter1', '/dir/filter1/ex' : false }
  var expectedFilePath = { '/dir/filter1/f' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = '.';

  f1.prefixesApply();

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

  /* */

  test.case = 'no filePath';

  var f1 = extract1.recordFilter();
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = '/dir/filter1';

  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.postfixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* - */

  test.close( 'single' );
  test.open( 'source' );

  /* - */

  test.case = 'trivial';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/f' : null, '/dir/filter1/d' : null, 'ex' : false }

  f1.filePath = { 'f' : null, 'd' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'base path is relative and current';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1';
  var expectedFilePath = { '/dir/filter1/f' : null, 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = '.';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'no base path';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = null;
  var expectedFilePath = { '/dir/filter1/f' : null, 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = null;

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'prefix is relative';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = '/base';
  var expectedFilePath = { './dir/f' : null, 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = './dir'
  f1.basePath = '/base';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'some in file paths are absolute';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { '/dir/filter1/f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }

  f1.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'base path is absolute';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = '/proto';
  var expectedFilePath = { '/dir/filter1/f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }

  f1.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = '/proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'no filePath';

  var f1 = extract1.recordFilter({ dstFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = '/dir/filter1';

  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.postfixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* - */

  test.close( 'source' );
  test.open( 'destination' );

  /* - */

  test.case = 'trivial';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { 'f' : '/dir/filter1', 'd' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'd' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'base path is relative and current';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1';
  var expectedFilePath = { 'f' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1';
  f1.basePath = '.';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'no base path';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = null;
  var expectedFilePath = { 'f' : '/dir/filter1', 'ex' : false }

  f1.filePath = { 'f' : null, 'ex' : false }
  f1.prefixPath = '/dir/filter1'
  f1.basePath = null;

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'prefix is relative';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = '/base';
  var expectedFilePath = { 'f' : './dir/dir', 'ex' : false }

  f1.filePath = { 'f' : './dir', 'ex' : false }
  f1.prefixPath = './dir'
  f1.basePath = '/base';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'some in file paths are absolute';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = { 'f' : '/dir/filter1', '/dir/filter1/d' : '/dir/filter1', '/dir/ex' : false }

  f1.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'base path is absolute';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = '/proto';
  var expectedFilePath = { 'f' : '/dir/filter1', '/dir/filter1/d' : '/dir/filter1', '/dir/ex' : false }

  f1.filePath = { 'f' : null, '/dir/filter1/d' : null, '/dir/ex' : false }
  f1.prefixPath = '/dir/filter1';
  f1.basePath = '/proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

  /* */

  test.case = 'no filePath';

  var f1 = extract1.recordFilter({ srcFilter : extract1.recordFilter() });
  var expectedBasePath = '/dir/filter1/proto';
  var expectedFilePath = '/dir/filter1';

  f1.prefixPath = '/dir/filter1';
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.postfixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.filePath, expectedFilePath );

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
  src.filePath = dst.filePath; // xxx
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
  src.filePath = dst.filePath; // xxx
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
  src.filePath = dst.filePath; // xxx
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
  src.filePath = dst.filePath; // xxx
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
  src.filePath = dst.filePath; // xxx
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

}

//

function inherit( test )
{
  let context = this;
  let provider = new _.FileProvider.Extract();
  let path = provider.path;

  /* */

  test.case = 'bools only';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  var f1 = extract1.recordFilter();
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = './proto';
  f1.filePath = { 'f' : true, 'd' : true, 'ex' : false, 'f1' : true, 'd1' : true, 'ex1' : false, 'ex3' : true, 'ex4' : false }

  var f2 = extract1.recordFilter();
  f2.prefixPath = '/commonDir/filter2'
  f2.basePath = './proto';
  f2.filePath = { 'f' : true, 'd' : true, 'ex' : false, 'f2' : true, 'd2' : true, 'ex2' : false, 'ex3' : false, 'ex4' : true }

  var f3 = extract1.recordFilter();
  f3.pathsInherit( f1 ).pathsInherit( f2 );

  var expectedFilePath =
  {
    'f' : true,
    'd' : true,
    'ex' : false,
    'f1' : true,
    'd1' : true,
    'f2' : true,
    'd2' : true,
    'ex1' : false,
    'ex2' : false,
    'ex3' : false,
    'ex4' : true,
  }

  var expectedBasePath =
  {
    'f' : '/commonDir/filter2/proto',
    'd' : '/commonDir/filter2/proto',
    'ex' : '/commonDir/filter2/proto',
    'f1' : '/commonDir/filter1/proto',
    'd1' : '/commonDir/filter1/proto',
    'f2' : '/commonDir/filter2/proto',
    'd2' : '/commonDir/filter2/proto',
    'ex1' : '/commonDir/filter1/proto',
    'ex2' : '/commonDir/filter2/proto',
    'ex3' : '/commonDir/filter2/proto',
    'ex4' : '/commonDir/filter2/proto',
  }

  test.identical( f3.prefixPath, null );
  test.identical( f3.filePath, expectedFilePath );
  test.identical( f3.basePath, expectedBasePath );

  /* */

  test.case = 'nulls';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

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
    'ex' : false,
    'ex1' : false,
    'ex4' : false,
    '/commonDir/filter1/f' : '/commonDir/filter1',
    '/commonDir/filter1/d' : '/commonDir/filter1',
    '/commonDir/filter1/f1' : '/commonDir/filter1',
    '/commonDir/filter1/d1' : '/commonDir/filter1',
    '/commonDir/filter1/ex3' : '/commonDir/filter1',
    'ex2' : false,
    'ex3' : false,
    '/commonDir/filter2/f' : '/commonDir/filter2',
    '/commonDir/filter2/d' : '/commonDir/filter2',
    '/commonDir/filter2/f2' : '/commonDir/filter2',
    '/commonDir/filter2/d2' : '/commonDir/filter2',
    '/commonDir/filter2/ex4' : '/commonDir/filter2'
  }
  var expectedBasePath =
  {
    'ex' : '/commonDir/filter2/proto',
    'ex1' : '/commonDir/filter1/proto',
    'ex4' : '/commonDir/filter1/proto',
    '/commonDir/filter1/f' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d' : '/commonDir/filter1/proto',
    '/commonDir/filter1/f1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/ex3' : '/commonDir/filter1/proto',
    'ex2' : '/commonDir/filter2/proto',
    'ex3' : '/commonDir/filter2/proto',
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
  f1.pathsInherit( f2 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir' } );
  test.identical( f2.prefixPath, null );
  test.identical( f2.basePath, null );
  test.identical( f2.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

  var f3 = extract1.recordFilter();
  f3.prefixPath = '/commonDir';
  f3.filePath = { 'filter1/f' : 'out/dir' }
  f1.pathsInherit( f3 );
  test.identical( f1.prefixPath, '/commonDir' );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : '/commonDir/out/dir', 'filter1/f' : 'out/dir' } );
  test.identical( f3.prefixPath, '/commonDir' );
  test.identical( f3.basePath, null );
  test.identical( f3.filePath, { 'filter1/f' : 'out/dir' } );

  var f4 = extract1.recordFilter();
  f4.prefixPath = '/commonDir/filter1'
  f4.filePath = { 'f' : 'out/dir' }
  f1.pathsInherit( f4 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : [ '/commonDir/out/dir', '/commonDir/filter1/out/dir' ] } );
  test.identical( f4.prefixPath, null );
  test.identical( f4.basePath, null );
  test.identical( f4.filePath, { '/commonDir/filter1/f' : '/commonDir/filter1/out/dir' } );

  var f5 = extract1.recordFilter();
  f5.filePath = { '/commonDir/filter1/f' : '/commonDir/out/dir' }
  f1.pathsInherit( f5 );
  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, null );
  test.identical( f1.filePath, { '*exclude*' : 0, '/commonDir/filter1/f' : [ '/commonDir/out/dir', '/commonDir/filter1/out/dir' ] } );
  test.identical( f5.prefixPath, null );
  test.identical( f5.basePath, null );
  test.identical( f5.filePath, { '/commonDir/filter1/f' : '/commonDir/out/dir' } );

}

//

function pairRefine( test )
{

  /* */

  test.case = 'src.filePath - only map';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - only map, with only true';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true } );
  test.identical( dst.filePath, { '/src' : true } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - only map with bools';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true, '/src2' : '/dst2' } );
  test.identical( dst.filePath, { '/src' : true, '/src2' : '/dst2' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.filePath - only map';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.filePath - only map, with only true';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true } );
  test.identical( dst.filePath, { '/src' : true } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.filePath - only map, with true';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : true, '/src2' : '/dst' } );
  test.identical( dst.filePath, { '/src' : true, '/src2' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.filePath - only map, with null';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst', '/src2' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst', '/src2' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - map, dst.filePath - map';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - map, dst.filePath - string';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - string, dst.filePath - map';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - string, dst.filePath - string';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : '/dst' } );
  test.identical( dst.filePath, { '/src' : '/dst' } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'src.filePath - only string';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '/src' : null } );
  test.identical( dst.filePath, { '/src' : null } );
  test.is( src.filePath === dst.filePath );

  /* */

  test.case = 'dst.filePath - only string';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, null );
  test.identical( dst.filePath, '/dst' );

  /* */

  test.case = 'dst.filePath - map without dst, src.filePath - map without dst';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.filePath, { '.' : true } );
  test.identical( dst.filePath, { '.' : true } );

  /* */

  test.case = 'dst.filePath - map without dst, src.filePath - map without dst, src.prefixPath';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.prefixPath, '/a/b' );
  test.identical( src.filePath, { '.' : true } );
  test.identical( dst.filePath, { '.' : true } );
  test.is( dst.filePath === src.filePath );

  /* */

  test.case = 'dst.filePath - map without dst, dst.prefixPath, src.filePath - map without dst';

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
  src.pairRefine();

  test.identical( src.formed, 1 );
  test.identical( dst.formed, 1 );
  test.identical( src.prefixPath, null );
  test.identical( src.filePath, { '.' : '/a/b' } );
  test.identical( dst.filePath, { '.' : '/a/b' } );
  test.is( dst.filePath === src.filePath );

  if( Config.debug )
  {

    test.case = 'src.filePath - map, dst.filePath - map, inconsistant src';
    var src = _.fileProvider.recordFilter({ filePath : { '/src1' : '/dst' } });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src2' : '/dst' } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefine() );

    test.case = 'src.filePath - string, dst.filePath - map, inconsistant src';
    var src = _.fileProvider.recordFilter({ filePath : '/src1' });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src2' : '/dst' } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefine() );

    test.case = 'src.filePath - map, dst.filePath - map, inconsistant dst';
    var src = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst1' } });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst2' } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefine() );

    test.case = 'src.filePath - map, dst.filePath - map, inconsistant dst';
    var src = _.fileProvider.recordFilter({ filePath : { '/src' : true } });
    var dst = _.fileProvider.recordFilter({ filePath : { '/src' : null } });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefine() );

    test.case = 'src.filePath - map, dst.filePath - string, inconsistant dst';
    var src = _.fileProvider.recordFilter({ filePath : { '/src' : '/dst1' } });
    var dst = _.fileProvider.recordFilter({ filePath : '/dst2' });
    src.pairWithDst( dst );
    test.shouldThrowErrorSync( () => src.pairRefine() );

  }

}

inherit.timeOut = 30000;

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
  src.pairRefine();
  test.identical( src.hasAnyPath(), true );
  test.identical( dst.hasAnyPath(), false );
  test.is( src.filePath === dst.filePath );
  test.is( _.mapIs( src.filePath ) );

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

  debugger;
  filter.filePathSelect( srcPath, dstPath );

  test.identical( filter.formed, 5 );
  test.identical( filter.filePath, { '/src' : '/dst', '/src/**.test*' : true, '/src/**.release*' : false } );
  test.identical( filter.basePath, { '/src' : '/', '/src/**.test*' : '/', '/src/**.release*' : '/' } );
  test.identical( filter.prefixPath, null );
  test.identical( filter.postfixPath, null );
  debugger;

/*
    filePath : {
  /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/concat/proto : [ '/C/pro/web/Dave/git/' ... 't/out/debug.compiled' ],
  /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/concat/proto/**.test* : 1
}
  basePath : {
  /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/concat/proto : [ '/C/pro/web/Dave/git/' ... 't/asset/concat/proto' ],
  /C/pro/web/Dave/git/trunk/builder/include/dwtools/atop/will.test/asset/concat/proto/**.test* : [ '/C/pro/web/Dave/git/' ... 't/asset/concat/proto' ]
*/

}

// --
// proto
// --

var Self =
{

  name : 'Tools/mid/files/RecordFilter',
  silencing : 1,
  routineTimeOut : 3000, // xxx

  onSuiteBegin,
  onSuiteEnd,

  tests :
  {

    make,
    reflect,
    clone,
    prefixesApply,
    prefixesRelative,
    inherit,
    pairRefine,
    hasAnyPath,
    filePathSelect,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
