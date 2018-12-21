( function _FilesFind_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );

  // if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  var crypto = require( 'crypto' );
  var waitSync = require( 'wait-sync' );

}

//

var _ = _global_.wTools;
var Parent = wTester;

//

function onSuiteBegin( test )
{
  let path = this.provider.path;
  this.testRootDirectory = path.dirTempOpen( path.join( __dirname, '../..'  ), 'FilesFind/Abstract' );
}

//

function pathFor( filePath )
{
  let path = this.provider.path;
  filePath =  path.join( this.testRootDirectory, filePath );
  return path.normalize( filePath );
}

//

function providerIsInstanceOf( src )
{
  var self = this;

  if(  self.provider instanceof src )
  return true;

  if( _.FileProvider.Hub && self.provider instanceof _.FileProvider.Hub )
  {
    var testPath = self.pathFor( 'testPath' );
    var provider = self.provider.providerForPath( testPath );
    if( provider instanceof src )
    return true;
  }

  return false;
}

//

function symlinkIsAllowed()
{
  var self = this;

  if( Config.platform === 'nodejs' && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allowed = false;
    var dir = self.pathFor( 'symlinkIsAllowed' );
    var srcPath = self.pathFor( 'symlinkIsAllowed/src' );
    var dstPath = self.pathFor( 'symlinkIsAllowed/dst' );

    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );

    try
    {
      self.provider.softLink({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allowed = self.provider.isSoftLink( dstPath );
    }
    catch( err )
    {
      logger.error( err );
    }

    return allowed;
  }

  return true;
}

//

//

function makeStandardExtract( o )
{
  _.assert( arguments.length === 0 || arguments.length === 1 );

  var extract = _.FileProvider.Extract
  ({
    filesTree :
    {
      src1 :
      {
        a : '/src1/a',
        b : '/src1/b',
        c : '/src1/c',
        d :
        {
          a : '/src1/d/a',
          b : '/src1/d/b',
          c : '/src1/d/c',
        }
      },
      src1b :
      {
        a : '/src1b/a',
      },
      src1Terminal : '/src1Terminal',
      srcT : '/srcT',
      src2 :
      {
        a : '/src2/a',
        b : '/src2/b',
        c : '/src2/c',
        d :
        {
          a : '/src2/d/a',
          b : '/src2/d/b',
          c : '/src2/d/c',
        }
      },

      'src3.s' :
      {
        a : '/src3.s/a',
        'b.s' : '/src3.s/b.s',
        'c.js' : '/src3.s/c.js',
        d :
        {
          a : '/src3.s/d/a',
        }
      },
      'src3.js' :
      {
        a : '/src3.js/a',
        'b.s' : '/src3.js/b.s',
        'c.js' : '/src3.js/c.js',
        d :
        {
          a : '/src3.js/d/a',
        }
      },

      src : { f : '/src/f' },

      alt :
      {
        a : '/alt/a',
        d :
        {
          a : '/alt/d/a',
        }
      },
      alt2 :
      {
        a : '/alt2/a',
        d :
        {
          a : '/alt2/d/a',
        }
      },
      altalt :
      {
        a : '/altalt/a',
        d :
        {
          a : '/altalt/d/a',
        }
      },
      altalt2 :
      {
        a : '/altalt2/a',
        d :
        {
          a : '/altalt2/d/a',
        }
      },

      ctrl :
      {
        a : '/ctrl/a',
        d :
        {
          a : '/ctrl/d/a',
        }
      },
      ctrl2 :
      {
        a : '/ctrl2/a',
        d :
        {
          a : '/ctrl2/d/a',
        }
      },
      ctrlctrl :
      {
        a : '/ctrlctrl/a',
        d :
        {
          a : '/ctrlctrl/d/a',
        }
      },
      ctrlctrl2 :
      {
        a : '/ctrlctrl2/a',
        d :
        {
          a : '/ctrlctrl2/d/a',
        }
      },

      altctrl :
      {
        a : '/altctrl/a',
        d :
        {
          a : '/altctrl/d/a',
        }
      },

      altctrl2 :
      {
        a : '/altctrl2/a',
        d :
        {
          a : '/altctrl2/d/a',
        }
      },

      altctrlalt :
      {
        a : '/altctrlalt/a',
        d :
        {
          a : '/altctrlalt/d/a',
        }
      },

      altctrlalt2 :
      {
        a : '/altctrlalt2/a',
        d :
        {
          a : '/altctrlalt2/d/a',
        }
      },

      doubledir :
      {
        a : '/doubledir/a',
        d1 :
        {
          a : '/doubledir/d1/a',
          d11 :
          {
            b : '/doubledir/d1/d11/b',
            c : '/doubledir/d1/d11/c',
          },
        },
        d2 :
        {
          b : '/doubledir/d2/b',
          d22 :
          {
            c : '/doubledir/d2/d22/c',
            d : '/doubledir/d2/d22/d',
          },
        },
      },

    },
  });

  if( o )
  _.mapExtend( extract, o )

  return extract;
}

//

function _generatePath( dir, levels )
{
  var foldersPath = dir;
  var fileName = _.idWithGuid();

  for( var j = 0; j < levels; j++ )
  {
    var temp = _.idWithGuid().substring( 0, Math.random() * levels );
    foldersPath = _.path.join( foldersPath , temp );
  }

  return _.path.join( foldersPath, fileName );
}

//

function symlinkIsAllowed()
{
  var self = this;

  if( Config.platform === 'nodejs' && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allow = false;
    var dir = _.path.join( self.testRootDirectory, 'symlinkIsAllowed' );
    var srcPath = _.path.join( dir, 'src' );
    var dstPath = _.path.join( dir, 'dst' );

    _.fileProvider.filesDelete( dir );
    _.fileProvider.fileWrite( srcPath, srcPath );

    try
    {
      _.fileProvider.softLink({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allow = _.fileProvider.isSoftLink( dstPath );
    }
    catch( err )
    {
      logger.error( err );
    }

    return allow;
  }

  return true;
}

//

/*
!!! implement and cover _.routineExtend( null, routine );
*/

var select = _.routineFromPreAndBody( _.select.pre, _.select.body );
var defaults = select.defaults;
defaults.upToken = [ '/', '.' ];

// --
// filesTree
// --

var filesTree =
{

  initialCommon :
  {
    'src' :
    {
      'a.a' : 'a',
      'b1.b' : 'b1',
      'b2.b' : 'b2x',
      'c' :
      {
        'b3.b' : 'b3x',
        'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
        'srcfile' : 'srcfile',
        'srcdir' : {},
        'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
        'srcfile-dstdir' : 'x',
      },
    },
    'dst' :
    {
      'a.a' : 'a',
      'b1.b' : 'b1',
      'b2.b' : 'b2',
      'c' :
      {
        'b3.b' : 'b3',
        'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
        'dstfile.d' : 'd1',
        'dstdir' : {},
        'srcdir-dstfile' : 'x',
        'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
      },
    },
  },

  //

  exclude :
  {
    'src' :
    {
      'a' : 'a',
      'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
    },
    'dst' :
    {
      'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
      'c' : { 'c1' : 'c1', 'c2' : { 'c22' : 'c22' }, },
    },
  },

  //

  softLink :
  {
    'src' :
    {
      'a' : 'a',
      'b' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
      'c' : [{ softLink : './b' }]
    },
    'dst' :
    {
    },
  },

}

// --
// test
// --

function recordFilterPrefixesApply( test )
{
  var context = this;
  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  /* */

  test.case = 'trivial';

  var f1 = extract1.recordFilter();
  var expectedBasePath = { '/commonDir/filter1/f' : '/commonDir/filter1/proto', '/commonDir/filter1/d' : '/commonDir/filter1/proto', '/commonDir/filter1/ex' : '/commonDir/filter1/proto' }
  var expectedFilePath = { '/commonDir/filter1/f' : true, '/commonDir/filter1/d' : true, '/commonDir/filter1/ex' : false }

  f1.inFilePath = { 'f' : true, 'd' : true, 'ex' : false }
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.inFilePath, expectedFilePath );

  /* */

  test.case = 'trivial';

  var f1 = extract1.recordFilter();
  var expectedBasePath = { '/commonDir/filter1/f' : '/commonDir/filter1', '/commonDir/filter1/d' : '/commonDir/filter1', '/commonDir/filter1/ex' : '/commonDir/filter1' }
  var expectedFilePath = { '/commonDir/filter1/f' : true, '/commonDir/filter1/d' : true, '/commonDir/filter1/ex' : false }

  f1.inFilePath = { 'f' : true, 'd' : true, 'ex' : false }
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = '.';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.inFilePath, expectedFilePath );

  /* */

  test.case = 'some in file paths are absolute';

  var f1 = extract1.recordFilter();
  var expectedBasePath =
  {
    '/commonDir/filter1/f' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d' : '/commonDir/filter1/proto',
    '/commonDir/ex' : '/commonDir/filter1/proto',
  }
  var expectedFilePath = { '/commonDir/filter1/f' : true, '/commonDir/filter1/d' : true, '/commonDir/ex' : false }

  f1.inFilePath = { 'f' : true, '/commonDir/filter1/d' : true, '/commonDir/ex' : false }
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = './proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.inFilePath, expectedFilePath );

  /* */

  test.case = 'base path is absolute';

  var f1 = extract1.recordFilter();
  var expectedBasePath =
  {
    '/commonDir/filter1/d' : '/proto',
    '/commonDir/ex' : '/proto',
    '/commonDir/filter1/f' : '/proto',
  }

  var expectedFilePath = { '/commonDir/filter1/f' : true, '/commonDir/filter1/d' : true, '/commonDir/ex' : false }

  f1.inFilePath = { 'f' : true, '/commonDir/filter1/d' : true, '/commonDir/ex' : false }
  f1.prefixPath = '/commonDir/filter1'
  f1.basePath = '/proto';

  f1.prefixesApply();

  test.identical( f1.prefixPath, null );
  test.identical( f1.basePath, expectedBasePath );
  test.identical( f1.inFilePath, expectedFilePath );

}

//

function recordFilterInherit( test )
{
  var context = this;
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
  f1.inFilePath = { 'f' : true, 'd' : true, 'ex' : false, 'f1' : true, 'd1' : true, 'ex1' : false }

  var f2 = extract1.recordFilter();

  f2.prefixPath = '/commonDir/filter2'
  f2.basePath = './proto';
  f2.inFilePath = { 'f' : true, 'd' : true, 'ex' : false, 'f2' : true, 'd2' : true, 'ex2' : false }

  var f3 = extract1.recordFilter();
  f3.pathsInherit( f1 ).pathsInherit( f2 );

  var expectedBasePath =
  {
    '/commonDir/filter1/f' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d' : '/commonDir/filter1/proto',
    '/commonDir/filter1/ex' : '/commonDir/filter1/proto',
    '/commonDir/filter1/f1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/d1' : '/commonDir/filter1/proto',
    '/commonDir/filter1/ex1' : '/commonDir/filter1/proto',
    '/commonDir/filter2/f' : '/commonDir/filter2/proto',
    '/commonDir/filter2/d' : '/commonDir/filter2/proto',
    '/commonDir/filter2/ex' : '/commonDir/filter2/proto',
    '/commonDir/filter2/f2' : '/commonDir/filter2/proto',
    '/commonDir/filter2/d2' : '/commonDir/filter2/proto',
    '/commonDir/filter2/ex2' : '/commonDir/filter2/proto',
  }

  test.identical( f3.prefixPath, null );
  test.identical( f3.basePath, expectedBasePath );

}

//

function recordFilter( test )
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

  /* */

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

  /* */

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

  /* */

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

function _filesFindTrivial( t, provider )
{
  var context = this;

  /* */

  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });

  t.case = 'setup trivial';

  wasTree1.readToProvider( provider, context.testRootDirectory );
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, context.testRootDirectory );
  t.identical( gotTree.filesTree, wasTree1.filesTree );

  wasTree1.readToProvider( provider, context.testRootDirectory );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  t.case = 'find single terminal file . includingTransient : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 0, includingTerminals : 1 }
  t.case = 'find single terminal file . includingTransient : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 0, includingTransient : 1, includingTerminals : 1 }
  t.case = 'find single terminal file . includingStem : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  t.identical( got, expected );

  /* - */

  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  t.case = 'setup trivial';

  wasTree1.readToProvider( provider, context.testRootDirectory );
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, context.testRootDirectory );
  t.identical( gotTree.filesTree, wasTree1.filesTree );

  wasTree1.readToProvider( provider, context.testRootDirectory );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 1 }
  t.case = 'find single terminal file . includingTerminals : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 0 }
  t.case = 'find single terminal file . includingTerminals : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 0, includingTransient : 1, includingTerminals : 1 }
  t.case = 'find single terminal file . includingStem : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  t.identical( got, expected );

  /* - */

  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : '1', b : '1', dir11 : {} },
      dir2 : { c : '1' },
      d : '1',
    },
  });

  t.case = 'setup trivial';

  wasTree1.readToProvider({ dstProvider : provider, dstPath : context.testRootDirectory, allowDelete : 1 });
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, context.testRootDirectory );
  t.identical( gotTree.filesTree, wasTree1.filesTree );

  wasTree1.readToProvider( provider, context.testRootDirectory );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  t.case = 'find includingStem : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 0, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  t.case = 'find includingStem:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 0 }
  t.case = 'find includingTransient:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './d', './dir1/a', './dir1/b', './dir2/c' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 0, includingDirs : 1 }
  t.case = 'find includingTerminals:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './dir1', './dir1/dir11', './dir2' ];
  t.identical( got, expected );

  //

  // var wasTree1 = _.FileProvider.Extract
  // ({
  //   filesTree :
  //   {
  //     dir1 : { a : '1', b : '1', c : '1', dir11 : {}, dirSoft : [{ softLink : '../../dir3' }], fileSoft : [{ softLink : '../../dir3/dirSoft/c' }] },
  //     dir2 : { c : '2', d : '2' },
  //     dir3 : { c : '3', d : '3', dirSoft : [{ softLink : '../../dir2' }], fileSoft : [{ softLink : '../../dir2/c' }] },
  //   },
  // });
  //
  // t.case = 'setup trivial';
  //
  // wasTree1.readToProvider({ dstProvider : provider, dstPath : context.testRootDirectory, allowDelete : 1 });
  // var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, context.testRootDirectory );
  // t.identical( gotTree.filesTree, wasTree1.filesTree );
  //
  // logger.log( 'context.testRootDirectory', _.fileProvider.path.nativize( context.testRootDirectory ) );

  // /* */
  //
  // // var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  // // var o2 = { recursive : '2', includingStem : 1, includingTransient : 1, includingTerminals : 1 }
  // // t.case = 'find includingTerminals:0';
  // //
  // // var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  // // var expected = [ '.', './dir1', './dir1/dir11', './dir2' ];
  // // t.identical( got, expected );
  //
}

//

function filesFindTrivial( t )
{
  var context = this;

  var provider = _.FileProvider.Extract();
  context._filesFindTrivial( t, provider );

  var provider = _.FileProvider.HardDrive();
  context._filesFindTrivial( t, provider );

}

//

function filesFindMaskTerminal( test )
{
  var context = this;
  var testDir = _.path.join( context.testRootDirectory, test.name );
  var filePath = _.path.join( testDir, 'package.json' );

  _.fileProvider.filesDelete( testDir );
  _.fileProvider.fileWrite( filePath, filePath );

  test.case = 'relative to current dir';

  var filter =  { maskTerminal : './package.json' }
  var got = _.fileProvider.filesFind({ filePath : testDir, filter : filter, recursive : '1' });
  test.identical( got.length, 1 );

  /* */

  test.case = 'relative to parent dir';

  var filter =  { maskTerminal : './filesFindMaskTerminal/package.json' }
  var got = _.fileProvider.filesFind({ filePath : testDir, filter : filter });
  test.identical( got.length, 0 );
  // test.identical( got[ 0 ].absolute, filePath );
  // test.identical( got[ 0 ].relative, './package.json' );
  // test.identical( got[ 0 ].superRelative, './filesFindMaskTerminal/package.json' );
  // test.identical( got[ 0 ].isActual, true );

}

//

function filesFindCriticalCases( test )
{

  test.case = 'extract : empty file path array';

  var extract = _.FileProvider.Extract
  ({
    filesTree : {},
  });

  var got = extract.filesFind([]);
  var expected = [];
  test.identical( got, expected );

  /* */

  test.case = 'hub : empty file path array';

  var hub = _.FileProvider.Hub({ providers : [] });
  _.FileProvider.Extract({ protocol : 'ext1' }).providerRegisterTo( hub );
  _.FileProvider.Extract({ protocol : 'ext2' }).providerRegisterTo( hub );

  var got = hub.filesFind([]);
  var expected = [];
  test.identical( got, expected );

  /* */

  test.case = 'filePath:null';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 },
  });

  var filter = extract.recordFilter
  ({
    basePath : '.',
    prefixPath : '/',
  });

  filter.inFilePath = [ '/dir1', '/dir2' ];
  filter._formBasePath();
  var found = extract.filesFind
  ({
    recursive : '2',
    includingDirs : 1,
    includingTerminals : 1,
    mandatory : 0,
    outputFormat : 'relative',
    // filePath : '/',
    filter : filter,
  });

  var expected = [ './dir1', './dir1/a', './dir1/b', './dir2', './dir2/c' ];
  test.identical( found, expected );

  if( Config.debug )
  {

    var filter = extract.recordFilter
    ({
      basePath : '.',
      prefixPath : '/',
    });

    filter.inFilePath = [ '/dir1', '/dir2' ];
    filter._formBasePath();

    test.shouldThrowErrorSync( () =>
    {

      var found = extract.filesFind
      ({
        mandatory : 0,
        filePath : '/',
        filter : filter,
      });

    });

  }

}

//

function filesFindPreset( test )
{

  test.case = 'preset default.exclude is default';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { '.system' : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 } },
  });

  var found = extract.filesFind
  ({
    filePath : '/.system',
    outputFormat : 'relative',
    recursive : '2',
    // maskPreset : 0,
    filter :
    {
      basePath : '/some/path',
    },
  });

  var expected = [];
  test.identical( found, expected );

  /* */

  test.case = 'off preset';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { '.system' : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 } },
  });

  var found = extract.filesFind
  ({
    filePath : '/.system',
    outputFormat : 'relative',
    recursive : '2',
    maskPreset : 0,

    filter :
    {
      basePath : '/some/path',
    },
  });

  var expected = [ '../../.system/e', '../../.system/dir1/a', '../../.system/dir1/b', '../../.system/dir2/c', '../../.system/dir3/d' ];
  test.identical( found, expected );

}

//

function filesFind( test )
{
  var context = this;
  var testDir = _.path.join( context.testRootDirectory, test.name );

  var fixedOptions =
  {
    // basePath : null,
    // filePath : testDir,
    // strict : 1,
    allowingMissed : 1,
    includingStem : 1,
    result : [],
    orderingExclusion : [],
    sortingWithArray : null,
  }

  /* */

  test.case = 'native path';
  var got = _.fileProvider.filesFind
  ({
    filePath : __filename,
    includingTerminals : 1,
    includingTransient : 0,
    outputFormat : 'absolute'
  });
  var expected = [ _.path.normalize( __filename ) ];
  test.identical( got, expected );

  /* */

  test.case = 'check if onUp/onDown was called once per file';

  var onUpMap = {};
  var onDownMap = {};

  var onUp = ( r ) =>
  {
    test.identical( onUpMap[ r.absolute ], undefined )
    onUpMap[ r.absolute ] = 1;
    return r;
  }

  var onDown = ( r ) =>
  {
    test.identical( onDownMap[ r.absolute ], undefined )
    onDownMap[ r.absolute ] = 1;
    return r;
  }

  var got = _.fileProvider.filesFind
  ({
    filePath : __dirname,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'absolute',
    onUp : onUp,
    onDown : onDown,
    recursive : '2'
  });

  test.is( got.length > 0 );
  test.identical( got.length, _.mapOwnKeys( onUpMap ).length );
  test.identical( got.length, _.mapOwnKeys( onDownMap ).length );

  //

  _.fileProvider.safe = 1;

  var combinations = [];
  var testsInfo = [];

  var levels = 3;
  var filesNames =
  [
    'a.js', 'a.ss', 'a.s',
    'b.js', 'b.ss', 'b.s',
    'c.js', 'c.ss', 'c.s',
  ];

  var outputFormat = [ 'absolute', 'relative', 'record', 'nothing' ];
  var recursive = [ 0, '1', '2' ];
  var includingTerminals = [ 0, 1 ];
  var includingTransient = [ 0, 1 ];
  var filePaths = [ testDir ];

  var globs =
  [
    null,
    '*',
    '**',
    '*.js',
    '*.ss',
    '*.s',
    'a.*',
    'a.j?',
    '[!ab].s',
    // '{x.*, a.*}' // not supported
  ];

  /* */

  outputFormat.forEach( ( _outputFormat ) =>
  {
    filePaths.forEach( ( filePath ) =>
    {
      recursive.forEach( ( _recursive ) =>
      {
        includingTerminals.forEach( ( _includingTerminals ) =>
        {
          includingTransient.forEach( ( _includingTransients ) =>
          {
            globs.forEach( ( glob ) =>
            {
              var o =
              {
                outputFormat : _outputFormat,
                recursive : _recursive,
                includingTerminals : _includingTerminals,
                includingTransient : _includingTransients,
                filePath : filePath
              };

              if( o.outputFormat !== 'nothing' )
              o.glob = glob;

              _.mapSupplement( o, fixedOptions );
              combinations.push( o );
            })
          });
        });
      });
    })
  });

  /* filesFind test */

  var n = 0;
  for( var l = 2; l < levels; l++ )
  {
    prepareFiles( l );
    combinations.forEach( ( c ) =>
    {
      var info = _.cloneJust( c )
      info.level = l;
      info.number = ++n;
      test.case = _.toStr( info, { levels : 3 } )
      var checks = [];
      var options = _.cloneJust( c );

      if( options.glob !== undefined )
      {
        options.filePath = _.path.join( options.filePath, options.glob );
        delete options.glob;
      }

      if( options.filePath === null )
      return test.shouldThrowError( () => _.fileProvider.filesFind( options ) );

      var files = _.fileProvider.filesFind( options );

      if( options.outputFormat === 'nothing' )
      {
        checks.push( test.identical( files.length, 0 ) );
      }
      else
      {
        /* check result */

        var expected = makeExpected( l, info );
        if( options.outputFormat === 'record' )
        {
          var got = [];
          var areRecords = true;
          files.forEach( ( record ) =>
          {
            if( !( record instanceof _.FileRecord ) )
            areRecords = false;
            got.push( record.absolute );
          });
          checks.push( test.identical( got.sort(), expected.sort() ) );
          checks.push( test.identical( areRecords, true ) );
        }

        if( options.outputFormat === 'absolute' || options.outputFormat === 'relative' )
        {
          logger.log( 'Files:', _.toStr( files.sort() ) )
          logger.log( 'Expected:', _.toStr( expected.sort() ) )
          checks.push( test.identical( files.sort(), expected.sort() ) );
        }
      }

      info.passed = true;
      checks.forEach( ( check ) => { info.passed &= check; } )
      testsInfo.push( info );
    })
  }

  var allFiles =  prepareTree( 1 );

  /**/

  var complexGlobs =
  [
    '**/a/a.?',
    '**/b/a.??',
    // '**/c/{x.*, c.*}', // not supported
    // 'a/**/c/{x.*, c.*}', // not supported
    // '**/b/{x, c}/*', // not supported
    '**/[!ab]/*.?s',
    'b/[a-c]/**/a/*',
    '[ab]/**/[!ac]/*',
  ]

  complexGlobs.forEach( ( glob ) =>
  {
    var o =
    {
      outputFormat : 'absolute',
      recursive : '2',
      includingTerminals : 1,
      includingTransient : 0,
      filePath : _.path.join( testDir, glob ),
      filter :
      {
        basePath : testDir,
        prefixPath : testDir
      }
    };

    _.mapSupplement( o, fixedOptions );

    var info = _.cloneJust( o );
    info.level = levels;
    info.number = ++n;
    test.case = _.toStr( info, { levels : 3 } )
    var files = _.fileProvider.filesFind( _.cloneJust( o ) );
    var tester = _.path.globRegexpsForTerminal( glob, testDir, info.filter.basePath );
    var expected = allFiles.slice();
    expected = expected.filter( ( p ) =>
    {
      return tester.test( './' + _.path.relative( testDir, p ) )
    });
    logger.log( 'Got: ', _.toStr( files ) );
    logger.log( 'Expected: ', _.toStr( expected ) );
    var checks = [];
    checks.push( test.identical( files.sort(), expected.sort() ) );

    info.passed = true;
    checks.forEach( ( check ) => { info.passed &= check; } )
    testsInfo.push( info );
  })

  drawInfo( testsInfo );

  /* - */

  function drawInfo( info )
  {
    var t = [];

    info.forEach( ( i ) =>
    {
      // console.log( _.toStr( c, { levels : 3 } ) )
      t.push
      ([
        i.number,
        i.level,
        i.outputFormat,
        !!i.recursive,
        !!i.includingTerminals,
        !!i.includingTransient,
        i.glob || '-',
        !!i.passed
      ])
    })

    var o =
    {
      data : t,
      head : [ '#', 'level', 'outputFormat', 'recursive', 'i.terminals', 'i.dirs', 'glob', 'passed' ],
      colWidths :
      {
        0 : 4,
        1 : 4,
      },
      colWidth : 10
    }

    var output = _.strTable( o );
    console.log( output );
  }

  /* - */

  function prepareFiles( level )
  {
    if( _.fileProvider.statResolvedRead( testDir ) )
    _.fileProvider.filesDelete( testDir );

    var path = testDir;
    for( var i = 0; i <= level; i++ )
    {
      if( i >= 1 )
      path = _.path.join( path, '' + i );

      for( var j = 0; j < filesNames.length; j++ )
      {
        var filePath = _.path.join( path, filesNames[ j ] );
        _.fileProvider.fileWrite( filePath, '' );
      }
    }
  }

  /* - */

  function makeExpected( level, o )
  {
    var expected = [];
    var path = testDir;

    var isDir = _.fileProvider.isDir( o.filePath );

    if( isDir && o._includingDirs && o.includingStem )
    {
      if( o.outputFormat === 'absolute' ||  o.outputFormat === 'record' )
      _.arrayPrependOnce( expected, o.filePath );

      if( o.outputFormat === 'relative' )
      _.arrayPrependOnce( expected, _.path.relative( o.filePath, o.filePath ) );
    }

    if( !isDir )
    {
      if( o.includingTerminals )
      {
        var relative = _.path.dot( _.path.relative( o.basePath || o.filePath, o.filePath ) );
        var passed = true;

        if( o.glob )
        {
          if( relative === '.' )
          var toTest = _.path.dot( _.path.name({ path : o.filePath, withExtension : 1 }) );
          else
          var toTest = relative;

          var passed = _.path.globRegexpsForTerminal( o.glob, o.filePath, o.basePath ).test( toTest );
        }

        if( !passed )
        return expected;

        if( o.outputFormat === 'absolute' ||  o.outputFormat === 'record' )
        {
          expected.push( o.filePath );
        }
        if( o.outputFormat === 'relative' )
        {
          expected.push( relative );
        }
      }

      return expected;
    }

    for( var l = 0; l <= level; l++ )
    {
      var passed = true;

      if( l > 0 )
      {
        path = _.path.join( path, '' + l );
        if( o.includingDirs && o.includingTransient )
        {
          var relative = _.path.dot( _.path.relative( o.basePath || testDir, path ) );

          if( o.glob )
          passed = _.path.globRegexpsForDirectory( o.glob, o.filePath, o.basePath ).test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( path );
            if( o.outputFormat === 'relative' )
            expected.push( relative );
          }
        }
      }

      if( !o.recursive )
      break;

      if( o.includingTerminals )
      {

        filesNames.forEach( ( name ) =>
        {
          // var filePath = _.path.join( path, l + '-' + name );
          var filePath = _.path.join( path, name );
          var passed = true;
          var relative = _.path.dot( _.path.relative( o.basePath || testDir, filePath ) );

          if( o.glob )
          passed = _.path.globRegexpsForTerminal( o.glob, o.filePath, o.basePath || testDir ).test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( filePath );
            if( o.outputFormat === 'relative' )
            expected.push( relative );
          }
        })
      }

      if( o.recursive === '1' && l === 0  )
      break;
    }

    return expected;
  }

  /* - */

  function prepareTree( numberOfDuplicates )
  {
    var part =
    {
      'a' :
      {
        'a' : {  },
        'b' : {  },
        'c' : {  },
      },
      'b' :
      {
        'a' : {  },
        'b' : {  },
        'c' : {  },
      },
      'c' :
      {
        'a' : {  },
        'b' : {  },
        'c' : {  },
      }
    }
    var tree =
    {
      'a' :
      {
        'a' : _.cloneJust( part ),
        'b' : _.cloneJust( part ),
        'c' : _.cloneJust( part ),
      }
    }

    _.fileProvider.filesDelete( testDir );

    for( var i = 0; i < numberOfDuplicates; i++ )
    {
      var keys = _.mapOwnKeys( tree );
      var key = keys.pop();
      tree[ String.fromCharCode( key.charCodeAt(0) + 1 ) ] = _.cloneJust( tree[ key ] );
    }

    var paths = [];
    var filesNames =
    [
      'a.js', 'a.ss', 'a.s',
    ];

    function makePaths( t, _path )
    {
      var keys = _.mapOwnKeys( t );
      keys.forEach( ( key ) =>
      {
        var path;
        if( _.objectIs( t[ key ] ) )
        {
          var path = _.path.join( _path, key );
          filesNames.forEach( ( n ) =>
          {
            paths.push( _.path.join( path, n ) );
          })
          makePaths( t[ key ], path );
        }
      })
    }
    makePaths( tree , testDir );
    paths.sort();
    paths.forEach( ( p ) => _.fileProvider.fileWrite( p, '' ) )
    return paths;
  }

}

filesFind.timeOut = 60000;

//

function filesFind2( t )
{
  var context = this;
  var dir = _.path.join( context.testRootDirectory, t.name );
  var provider = _.FileProvider.HardDrive();
  var filePath, got, expected;

  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  provider.filesDelete( dir );

  _.FileProvider.Extract.readToProvider
  ({
    filesTree : filesTree,
    dstPath : dir,
    dstProvider : provider
  })

  function check( got, expected )
  {
    for( var i = 0; i < got.length; i++ )
    {
      if( _.routineIs( expected ) )
      {
        if( !expected( got[ i ] ) )
        return false;
      }
      else
      {
        if( expected.indexOf( got[ i ].fullName || got[ i ] ) === -1 )
        return false;
      }
    }

    return true;
  }

  /* - */

  function _orderingExclusion( src, orderingExclusion  )
  {
    var result = [];
    orderingExclusion = _.RegexpObject.order( orderingExclusion );
    for( var i = 0; i < orderingExclusion.length; i++ )
    {
      for( var j = 0; j < src.length; j++ )
      {
        if( _.RegexpObject.test( orderingExclusion[ i ], src[ j ]  ) )
        if( _.arrayRightIndex( result, src[ j ] ) >= 0 )
        continue;
        else
        result.push( src[ j ] );
      }
    }
    return result;
  }

  /* - */

  t.description = 'default options';

  /*filePath - directory*/

  got = provider.filesFind( dir );
  expected = provider.dirRead( dir );
  t.identical( check( got, expected ), true );

  /*filePath - terminal file*/

  filePath = _.path.join( dir, __filename );
  got = provider.filesFind( filePath );
  expected = provider.dirRead( filePath );
  t.identical( check( got, expected ), true );

  /*filePath - empty dir*/

  filePath = _.path.join( context.testRootDirectory, 'tmp/empty' );
  provider.dirMake( filePath )
  got = provider.filesFind( filePath );
  t.identical( got, [] );

  /* - */

  t.description = 'allowingMissed option';
  filePath = _.path.join( dir, __filename );
  var nonexistentPath = _.path.join( dir, 'nonexistent' );

  /*filePath - relative path*/
  t.shouldThrowErrorSync( function()
  {
    provider.filesFind
    ({
      filePath : _.path.relative( dir, nonexistentPath ),
      ignoringignoringNonexistent : 0
    });
  })

  t.case = 'filePath - not exist';

  got = provider.filesFind
  ({
    filePath : nonexistentPath,
    allowingMissed : 1,
  });
  // var expected = [ provider.recordFactory({ basePath : '/invalid path', filter : got[ 0 ].context.filter }).record( '/invalid path' ) ];
  var expected = [];
  t.identical( got, expected );

  t.shouldThrowErrorSync( function()
  {
    got = provider.filesFind
    ({
      filePath : nonexistentPath,
      allowingMissed : 0,
    });
  })

  t.case = 'filePath - some paths dont exist';

  got = provider.filesFind
  ({
    filePath : [ nonexistentPath, filePath ],
    allowingMissed : 1,
  });
  expected = provider.dirRead( filePath );
  t.identical( check( got, expected ), true )

  t.shouldThrowErrorSync( function()
  {
    got = provider.filesFind
    ({
      filePath : [ nonexistentPath, filePath ],
      allowingMissed : 0,
    });
  });

  /*filePath - some paths not exist, allowingMissed on*/

  got = provider.filesFind
  ({
    filePath : [ nonexistentPath, filePath ],
    allowingMissed : 1,
  });
  t.identical( got.length, 1 );
  t.is( got[ 0 ] instanceof _.FileRecord );
  t.identical( got[ 0 ].fullName, 'aFilesFind.test.s' );

  /* */

  t.description = 'includingTerminals, includingTransient options';

  /*filePath - empty dir, includingTerminals, includingTransient on*/

  provider.dirMake( _.path.join( context.testRootDirectory, 'empty' ) )
  got = provider.filesFind({ filePath : _.path.join( dir, 'empty' ), includingTerminals : 1, includingTransient : 1, allowingMissed : 1 });
  t.identical( got, [] );

  /*filePath - empty dir, includingTerminals, includingTransient on, includingStem off*/

  provider.dirMake( _.path.join( context.testRootDirectory, 'empty' ) )
  got = provider.filesFind({ filePath : _.path.join( dir, 'empty' ), includingTerminals : 1, includingTransient : 1, includingStem : 0, allowingMissed : 1 });
  t.identical( got, [] );

  /*filePath - empty dir, includingTerminals, includingTransient off*/

  provider.dirMake( _.path.join( context.testRootDirectory, 'empty' ) )
  got = provider.filesFind({ filePath : _.path.join( dir, 'empty' ), includingTerminals : 0, includingTransient : 0, allowingMissed : 1 });
  t.identical( got, [] );

  /*filePath - directory, includingTerminals, includingTransient on*/

  got = provider.filesFind({ filePath : dir, includingTerminals : 1, includingTransient : 1, includingStem : 0 });
  expected = provider.dirRead( dir );
  t.identical( check( got, expected ), true );

  /*filePath - directory, includingTerminals, includingTransient off*/

  got = provider.filesFind({ filePath : dir, includingTerminals : 0, includingTransient : 0 });
  expected = provider.dirRead( dir );
  t.identical( got, [] );

  /*filePath - directory, includingTerminals off, includingTransient on*/

  got = provider.filesFind({ filePath : dir, includingTerminals : 0, includingTransient : 1, includingStem : 0 });
  expected = provider.dirRead( dir );
  t.identical( check( got, expected ), true  );

  /*filePath - terminal file, includingTerminals, includingTransient off*/

  filePath = _.path.join( dir, __filename );
  got = provider.filesFind({ filePath : filePath, includingTerminals : 0, includingTransient : 0 });
  expected = provider.dirRead( dir );
  t.identical( got, [] );

  /*filePath - terminal file, includingTerminals off, includingTransient on*/

  filePath = _.path.join( dir, __filename );
  got = provider.filesFind({ filePath : filePath, includingTerminals : 0, includingTransient : 1 });
  t.identical( got, [] );

  //

  t.description = 'outputFormat option';

  /*filePath - directory, outputFormat absolute */

  got = provider.filesFind({ filePath : dir, outputFormat : 'record' });
  function recordIs( element ){ return element.constructor.name === 'wFileRecord' };
  expected = provider.dirRead( dir );
  t.identical( check( got, recordIs ), true );

  /*filePath - directory, outputFormat absolute */

  got = provider.filesFind({ filePath : dir, outputFormat : 'absolute' });
  expected = provider.dirRead( dir );
  t.identical( check( got, _.path.isAbsolute ), true );

  /*filePath - directory, outputFormat relative */

  got = provider.filesFind({ filePath : dir, outputFormat : 'relative' });
  expected = provider.dirRead( dir );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = _.path.join( './', expected[ i ] );
  t.identical( check( got, expected ), true );

  /*filePath - directory, outputFormat nothing */

  got = provider.filesFind({ filePath : dir, outputFormat : 'nothing' });
  t.identical( got, [] );

  /*filePath - directory, outputFormat unexpected */

  t.shouldThrowErrorSync( function()
  {
    provider.filesFind({ filePath : dir, outputFormat : 'unexpected' });
  })

  //

  t.description = 'result option';

  /*filePath - directory, result not empty array, all existing files must be skipped*/

  got = provider.filesFind( dir );
  expected = got.length;
  provider.filesFind({ filePath : dir, result : got });
  t.identical( got.length, expected );

  /*filePath - directory, result empty array*/

  got = [];
  provider.filesFind({ filePath : dir, result : got });
  expected = provider.dirRead( dir );
  t.identical( check( got, expected ), true );

  /*filePath - directory, result object without push function*/

  t.shouldThrowErrorSync( function()
  {
    got = {};
    provider.filesFind({ filePath : dir, result : got });
  });

  //

  t.description = 'masking'

  /*filePath - directory, maskTerminal, get all files with 'Files' in name*/

  got = provider.filesFind
  ({
    filePath : dir,
    filter :
    {
      maskTerminal : 'Files',
    },
    outputFormat : 'relative'
  });
  expected = provider.dirRead( dir );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.test( 'Files', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  t.identical( got, expected );

  /*filePath - directory, maskDirectory, includingTransient */

  filePath = _.path.join( context.testRootDirectory, 'tmp/dir' );
  provider.dirMake( filePath );

  got = provider.filesFind
  ({
    filePath : filePath,
    filter :
    {
      basePath : _.path.dir( filePath ),
      maskDirectory : 'dir',
    },
    outputFormat : 'relative',
    includingStem : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2'
  });
  expected = provider.dirRead( _.path.dir( filePath ) );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.test( 'dir', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  t.identical( got, expected );

  /*filePath - directory, maskAll with some random expression, no result expected */

  got = provider.filesFind
  ({
    filePath : dir,
    filter :
    {
      maskAll : 'a12b',
    }
  });
  t.identical( got, [] );

  /*filePath - directory, orderingExclusion mask, maskTerminal null, expected order Caching->Files*/

  var orderingExclusion = [ 'src', 'dir3' ];
  got = provider.filesFind
  ({
    filePath : dir,
    orderingExclusion : orderingExclusion,
    includingDirs : 1,
    // maskTerminal : null,
    recursive : '1',
    outputFormat : 'record'
  });
  got = got.map( ( r ) => r.relative );
  expected = _orderingExclusion( provider.dirRead( dir ), orderingExclusion );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  t.identical( got, expected )

  //

  t.description = 'change relative path in record';

  /*change relative to wFiles, relative should be like ./staging/dwtools/amid/files/z.test/'file_name'*/

  var relative = _.path.join( dir, 'src' );
  got = provider.filesFind
  ({
    filePath : _.path.join( dir, 'src/dir' ),
    filter : { basePath : relative },
    recursive : '1'
  });
  got = got[ 0 ].relative;
  var begins = './' + _.path.relative( relative, _.path.join( dir, 'src/dir' ) );
  t.identical( _.strBegins( got, begins ), true );

  /* changing relative path affects only record.relative*/

  got = provider.filesFind
  ({
    filePath : dir,
    filter :
    {
      basePath : '/x/a/b',
    },
    recursive : '2',
    maskPreset : 0,
  });

  t.identical( _.strBegins( got[ 0 ].absolute, '/x' ), false );
  t.identical( _.strBegins( got[ 0 ].real, '/x' ), false );
  t.identical( _.strBegins( got[ 0 ].dir, '/x' ), false );

  //

  t.description = 'etc';

  /*strict mode on - prevents extension of wFileRecord*/

  t.shouldThrowErrorSync( function()
  {
    var records = provider.filesFind( dir );
    records[ 0 ].newProperty = 1;
  })

  /*strict mode off */

  // t.mustNotThrowError( function()
  // {
  //   var records = provider.filesFind({ filePath : dir/*, strict : 0*/ });
  //   records[ 0 ].newProperty = 1;
  // })


}

filesFind2.timeOut = 15000;

//

function filesFindRecursive( test )
{
  var self = this;

  var provider = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', dir : { a1 : '1' } },
      src2 : { ax2 : '20', dirx : { a : '20' } },
    },
  });

  /**/

  test.open( 'directory' );

  var got = provider.filesFind
  ({
    filePath : '/',
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 0,
  })
  test.identical( got, [ '.' ] )

  var got = provider.filesFind
  ({
    filePath : '/',
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : '1',
  })
  var expected = [ '.', './src', './src2' ]
  test.identical( got, expected );

  var got = provider.filesFind
  ({
    filePath : '/',
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : '2',
  })
  var expected = [ '.', './src', './src/a1', './src/dir', './src/dir/a1', './src2', './src2/ax2', './src2/dirx', './src2/dirx/a' ]
  test.identical( got, expected );

  test.close( 'directory' );

  /* */

  test.open( 'terminal' );

  var got = provider.filesFind
  ({
    filePath : '/src/a1',
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : '/src' },
    recursive : 0,
  })
  var expected = [ './a1' ]

  var got = provider.filesFind
  ({
    filePath : '/src/a1',
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : '/src' },
    recursive : '1',
  })
  var expected = [ './a1' ]
  test.identical( got, expected );

  //

  var got = provider.filesFind
  ({
    filePath : '/src/a1',
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : '/src' },
    recursive : '2',
  })
  var expected = [ './a1' ]
  test.identical( got, expected );

  test.close( 'terminal' );

  /* */

  if( !Config.debug )
  return;

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : '/',
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : 1,
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : '/',
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : true,
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : '/',
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : false,
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : '/',
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '0',
    })
  })
}

filesFindRecursive.timeOut = 15000;

//

function filesFindLinked( test )
{
  let self = this;
  let workDir = test.context.pathFor( test.name );
  let provider = self.provider;
  let path = self.provider.path;

  /*
    link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]
  */

  //

  function select( container, path )
  {
    let result = _.select( container, path );
    if( _.strIs( result[ 0 ] ) )
    result = result.map( ( e ) => _.strPrependOnce( _.strRemoveBegin( e, workDir ), '/' ) );
    return result;
  }

  //

  let terminalPath = path.join( workDir, 'terminal' );
  let normalPath = path.join( workDir, 'normal' );
  let doublePath = path.join( workDir, 'double' );
  let brokenPath = path.join( workDir, 'broken' );
  let missingPath = path.join( workDir, 'missing' );
  let selfPath = path.join( workDir, 'self' );
  let onePath = path.join( workDir, 'one' );
  let twoPath = path.join( workDir, 'two' );
  let normalaPath = path.join( workDir, 'normala' );
  let normalbPath = path.join( workDir, 'normalb' );
  let dirPath = path.join( workDir, 'directory' );
  let toDirPath = path.join( workDir, 'toDir' );

  //

  test.open( 'normal' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/terminal' ] );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal' ] );

  test.close( 'normal' );

  /* */

  test.open( 'double' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    double : [{ softLink : '/normal' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );
  self.provider.softLink( doublePath, normalPath );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/double', '/normal', '/terminal' ] );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal', '/terminal' ] );

  test.close( 'double' );

  /* */

  test.open( 'broken' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    broken : [{ softLink : '/missing' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );
  self.provider.softLink({ dstPath : brokenPath, srcPath : missingPath, allowingMissed : 1 });

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 0,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/broken', '/normal', '/terminal' ] );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/broken', '/normal', '/terminal' ] );

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : workDir,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissed : 0,
      includingDirs : 1,
      recursive : '2',
      includingStem : 1,
    })
  })

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/missing', '/terminal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, false, true, true ] );

  test.close( 'broken' );

  /* */

  test.open( 'self cycled' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    self : [{ softLink : '/self' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );
  self.provider.softLink({ dstPath : selfPath, srcPath : '../self', allowingMissed : 1 });

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 0,
    allowingCycled : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/',  '/normal', '/self', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/self', '/terminal' ] );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    allowingCycled : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/self', '/terminal'] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/self', '/terminal' ] );

  test.shouldThrowErrorSync( () =>
  {
    let found = provider.filesFind
    ({
      filePath : workDir,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissed : 0,
      includingDirs : 1,
      recursive : '2',
      includingStem : 1,
    });
  });

  provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    allowingCycled : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  var tree =
  {
    terminal : 'terminal',
    one : [{ softLink : '/two' }],
    two : [{ softLink : '/one' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink({ dstPath : twoPath, srcPath : onePath, allowingMissed : 1 });
  self.provider.softLink({ dstPath : onePath, srcPath : twoPath, allowingMissed : 1 });

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 0,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : workDir,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissed : 0,
      includingDirs : 1,
      recursive : '2',
      includingStem : 1,
    })
  })

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  var tree =
  {
    terminal : 'terminal',
    normala : [{ softLink : '/terminal' }],
    normalb : [{ softLink : '/terminal' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalaPath,terminalPath );
  self.provider.softLink( normalbPath,terminalPath );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normala', '/normalb', '/terminal' ] );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal', '/terminal' ] );

  test.close( 'links to same file' );

  /**/

  test.open( 'link to directory' );

  var tree =
  {
    directory :
    {
      terminal : 'terminal',
    },
    toDir : [{ softLink : '/directory' }],
  }

  var terminalInDirPath = self.provider.path.join( dirPath, 'terminal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  self.provider.softLink( toDirPath,dirPath );

  var got = self.provider.filesFind
  ({
    filePath : toDirPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir'  ] );
  test.identical( select( got, '*/real' ), [ '/toDir' ] );

  // debugger;
  var got = self.provider.filesFind
  ({
    filePath : toDirPath,
    outputFormat : 'record',
    resolvingSoftLink : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : '2',
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/directory', '/directory/terminal'  ] );

  test.close( 'link to directory' );

  /**/

  test.open( 'link to processed directory' );

  var tree =
  {
    directory :
    {
      terminal : 'terminal'
    },
    toDir : [{ softLink : '/directory'}]
  }

  var terminalInDirPath = self.provider.path.join( dirPath, 'terminal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  self.provider.softLink( toDirPath,dirPath );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );

  var got = self.provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/directory', '/directory/terminal', '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/directory', '/directory/terminal', '/directory', '/directory/terminal'  ] );

  test.close( 'link to processed directory' );
}

//

function filesFindResolving( test )
{
  var testDir = _.path.join( context.testRootDirectory, test.name );

  var symlinkIsAllowed = context.symlinkIsAllowed();

  var fixedOptions =
  {
    // basePath : null,
    allowingMissed : 1,
    orderingExclusion : [],
    sortingWithArray : null,
    outputFormat : 'record',
    includingStem : 1,
    includingTerminals : 1,
    includingTransient : 1,
    recursive : '2'
  }

  var filePaths;

  function makeCleanTree( dir )
  {
    _.fileProvider.filesDelete( dir );
    filePaths = [ 'file' ].map( ( name ) =>
    {
      var path = _.path.join( dir, name )
      _.fileProvider.fileWrite( path, path );
      return path;
    });
  }

  function recordSimplify( record )
  {
    var result =
    {
      absolute : record.absolute,
      real : record.real,
      isDir : record.isDir
    }

    return result;
  }

  function findRecord( records, field, value )
  {
    var result = records.filter( ( r ) =>
    {
      if( r[ field ] === value )
      return r;
    });

    _.assert( result.length === 1 );

    return result[ 0 ];
  }

  /*

    resolvingSoftLink : 0, 1
    resolvingTextLink : 0, 1
    provider : usingTextLink : 0, 1

  */

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 0';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : textLinkPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );


  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 0';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 0,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : textLinkPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 0,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

   //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text->text->file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  var textLink2Path = _.path.join( testDir, 'textLink2' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  _.fileProvider.fileWrite( textLink2Path, 'link ' + srcFilePath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLink2Path,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var textLink2Stat = findRecord( files, 'absolute', textLink2Path ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, textLink2Stat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  if( !symlinkIsAllowed )
  return;

  /* soft link */

  test.case = 'soft link to a file, resolvingSoftLink : 0, resolvingTextLink : 0'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : softLink,
      isDir : false
    },
  ]
  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.is( srcFileStat.ino !== softLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a file, resolvingSoftLink : 1, resolvingTextLink : 0'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : filePaths[ 0 ],
      isDir : false
    },
  ]
  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a file, resolvingSoftLink : 1, resolvingTextLink : 1'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var softLink = _.path.join( testDir, 'link' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 0';
  var srcDirPath = _.path.join( testDir, 'dir' );
  var softLink = _.path.join( testDir, 'linkToDir' );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  _.fileProvider.filesDelete( testDir );
  makeCleanTree( srcDirPath );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
    includingStem : 0
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.softLink( softLink, srcDirPath );

  var files = _.fileProvider.filesFind(options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : _.path.join( softLink, _.path.name({ path : filePaths[ 0 ], withExtension : 1 }) ),
      real : _.path.join( softLink, _.path.name({ path : filePaths[ 0 ], withExtension : 1 }) ),
      isDir : false
    }
  ]

  test.identical( filtered, expected )
  var srcDirStat = _.fileProvider.statResolvedRead( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 1';
  var srcDirPath = _.path.join( testDir, 'dir' );
  var softLink = _.path.join( testDir, 'linkToDir' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  _.fileProvider.filesDelete( testDir );
  makeCleanTree( srcDirPath );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.softLink( softLink, srcDirPath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : _.path.join( softLink, _.path.name({ path : filePaths[ 0 ], withExtension : 1 }) ),
      real : _.path.join( softLink, _.path.name({ path : filePaths[ 0 ], withExtension : 1 }) ),
      isDir : false
    }
  ]

  logger.log( _.toStr( files, { levels : 99 } )   )

  test.identical( filtered, expected )
  var srcDirStat = _.fileProvider.statResolvedRead( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'multiple soft links in chain, resolvingSoftLink : 1, resolvingTextLink : 0'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  _.fileProvider.softLink( softLink2, softLink );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink2,
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'multiple soft links in chain, resolvingSoftLink : 1, resolvingTextLink : 1'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  _.fileProvider.softLink( softLink2, softLink );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink2,
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'multiple soft links to single file, resolvingSoftLink : 1, resolvingTextLink : 0'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  _.fileProvider.softLink( softLink2, srcPath );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink2,
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'multiple soft links to single file, resolvingSoftLink : 1, resolvingTextLink : 1'
  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.softLink( softLink, srcPath );
  _.fileProvider.softLink( softLink2, srcPath );
  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink,
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLink2,
      real : filePaths[ 0 ],
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  var softLinkPath = _.path.join( testDir, 'softLinkPath' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  _.fileProvider.softLink( softLinkPath, textLinkPath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : softLinkPath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = _.fileProvider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, softLinkStat.ino );
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  _.fileProvider.filesDelete( testDir );
  var srcDirPath = _.path.join( testDir, 'dir' );
  makeCleanTree( srcDirPath );
  var textLinkPath = _.path.join( testDir, 'textLink' );
  var softLinkPath = _.path.join( testDir, 'softLinkPath' );
  _.fileProvider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcDirPath );
  _.fileProvider.softLink( softLinkPath, textLinkPath );

  var files = _.fileProvider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testDir,
      real : testDir,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : filePaths[ 0 ],
      real : filePaths[ 0 ],
      isDir : false
    },
    {
      absolute : softLinkPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : textLinkPath,
      real : srcDirPath,
      isDir : true
    },
  ]

  test.identical( filtered, expected )
  var srcDirStat = _.fileProvider.statResolvedRead( srcDirPath );
  var srcFileStat = findRecord( files, 'absolute', filePaths[ 0 ] ).stat;
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcDirStat.ino, textLinkStat.ino );
  test.identical( srcDirStat.ino, softLinkStat.ino );
  test.is( srcFileStat.ino !== textLinkStat.ino )
  test.is( srcFileStat.ino !== softLinkStat.ino )
  _.fileProvider.fieldPop( 'usingTextLink', 1 );

}

//

function filesFindPerformance( t )
{
  var context = this;
  t.description = 'filesFind time test';

  /*prepare files */

  var dir = _.path.join( context.testRootDirectory, t.name );
  var provider = _.FileProvider.HardDrive();

  var filesNumber = 2000;
  var levels = 5;

  if( !_.fileProvider.statResolvedRead( dir ) )
  {
    logger.log( 'Creating ', filesNumber, ' random files tree. ' );
    var t1 = _.timeNow();
    for( var i = 0; i < filesNumber; i++ )
    {
      var path = context._generatePath( dir, Math.random() * levels );
      provider.fileWrite({ filePath : path, data : 'abc', writeMode : 'rewrite' } );
    }

    logger.log( _.timeSpent( 'Spent to make ' + filesNumber +' files tree', t1 ) );
  }

  var times = 10;

  /*default filesFind*/

  var t2 = _.timeNow();
  for( var i = 0; i < times; i++)
  {
    var files = provider.filesFind
    ({
      filePath : dir,
      recursive : '2'
    });
  }

  logger.log( _.timeSpent( 'Spent to make  provider.filesFind x' + times + ' times in dir with ' + filesNumber +' files tree', t2 ) );

  t.identical( files.length, filesNumber );

  /*stats filter filesFind*/

  // var filter = _.fileProvider.Caching({ original : filter, cachingDirs : 0 });
  // var times = 10;
  // var t2 = _.timeNow();
  // for( var i = 0; i < times; i++)
  // {
  //   filter.filesFind
  //   ({
  //     filePath : dir,
  //     recursive : '2'
  //   });
  // }
  // logger.log( _.timeSpent( 'Spent to make CachingStats.filesFind x' + times + ' times in dir with ' + filesNumber +' files tree', t2 ) );

  /*stats, dirRead filters filesFind*/

  // var filter = _.FileFilter.Caching();
  // var t2 = _.timeNow();
  // for( var i = 0; i < times; i++)
  // {
  //   var files = filter.filesFind
  //   ({
  //     filePath : dir,
  //     recursive : '2'
  //   });
  // }

  // logger.log( _.timeSpent( 'Spent to make filesFind with three filters x' + times + ' times in dir with ' + filesNumber +' files tree', t2 ) );

  // t.identical( files.length, filesNumber );
}

filesFindPerformance.timeOut = 150000;
filesFindPerformance.rapidity = 1;

//

function filesFindGlob( test )
{
  var context = this;
  var provider = context.makeStandardExtract();

  var onUp = function onUp( record )
  {
    if( record.isTransient )
    onUpAbsoluteTransients.push( record.absolute );
    if( record.isActual )
    onUpAbsoluteActuals.push( record.absolute );
    return record;
  }

  var onDown = function onDown( record )
  {
    if( record.isTransient )
    onDownAbsoluteTransients.push( record.absolute );
    if( record.isActual )
    onDownAbsoluteActuals.push( record.absolute );
    return record;
  }

  function selectTransients( records )
  {
    return _.filter( records, ( record ) => record.isTransient ? record.absolute : undefined );
  }

  function selectActuals( records )
  {
    return _.filter( records, ( record ) => record.isActual ? record.absolute : undefined );
  }

  var onUpAbsoluteTransients = [];
  var onUpAbsoluteActuals = [];
  var onDownAbsoluteTransients = [];
  var onDownAbsoluteActuals = [];

  function clean()
  {
    onUpAbsoluteTransients = [];
    onUpAbsoluteActuals = [];
    onDownAbsoluteTransients = [];
    onDownAbsoluteActuals = [];
  }

  var globTerminals = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : '2',
  });

  var globAll = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : '2',
  });

  /* - */

  test.open( 'extended' );

  test.case = 'globTerminals /src1/**'; /* */

  clean();

  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnUpAbsoluteTransients = [];
  var expectedOnDownAbsoluteTransients = [];
  var expectedOnUpAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnDownAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsoluteTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownAbsoluteTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpAbsoluteActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownAbsoluteActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globAll /src1/**';

  clean();

  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnUpAbsoluteTransients = [ '/src1', '/src1/d' ];
  var expectedOnDownAbsoluteTransients = [ '/src1/d', '/src1' ];
  var expectedOnUpAbsoluteActuals = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnDownAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1/d', '/src1' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsoluteTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownAbsoluteTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpAbsoluteActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownAbsoluteActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globTerminals src1/** relative';

  clean();

  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c' ];
  var expectedOnUpAbsoluteTransients = [];
  var expectedOnDownAbsoluteTransients = [];
  var expectedOnUpAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c' ];
  var expectedOnDownAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c' ];
  var records = globTerminals({ filePath : '*', filter : { prefixPath : '/src1' } });
  var gotAbsolutes = context.select( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsoluteTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownAbsoluteTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpAbsoluteActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownAbsoluteActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globAll src1/** relative';

  clean();

  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var expectedOnUpAbsoluteTransients = [ '/src1', '/src1/d' ];
  var expectedOnDownAbsoluteTransients = [ '/src1/d', '/src1' ];
  var expectedOnUpAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var expectedOnDownAbsoluteActuals = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var records = globAll({ filePath : '*', filter : { prefixPath : '/src1' } });
  var gotAbsolutes = context.select( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsoluteTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownAbsoluteTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpAbsoluteActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownAbsoluteActuals, expectedOnDownAbsoluteActuals );

  test.close( 'extended' );

  /* - */

  test.case = 'globTerminals /src1';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals({ filePath : '/src1' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll({ filePath : '/src1' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/**, prefixPath : /src2';

  clean();
  var expAbsolutes = [];
  var expIsActual = [];
  var expIsTransient = [];
  var expStat = [];
  var records = globTerminals({ filePath : 'src1/**', filter : { prefixPath : '/src2', basePath : '/src2' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotIsActual = context.select( records, '*.isActual' );
  var gotIsTransient = context.select( records, '*.isTransient' );
  var gotStat = context.select( records, '*.stat' ).map( ( e ) => !!e );
  test.identical( gotAbsolutes, expAbsolutes );
  test.identical( gotIsActual, expIsActual );
  test.identical( gotIsTransient, expIsTransient );
  test.identical( gotStat, expStat );

  test.case = 'globAll /src1/**, prefixPath : /src2';

  clean();
  var expectedAbsolutes = [];
  var records = globAll({ filePath : 'src1/**', filter : { prefixPath : '/src2', basePath : '/src2' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals({ filePath : '/src1/**', filter : { prefixPath : '/src2', basePath : '/src2' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll({ filePath : '/src1/**', filter : { prefixPath : '/src2', basePath : '/src2' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals (src1|src2)/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globTerminals({ filePath : '(src1|src2)/**', filter : { prefixPath : '/' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll (src1|src2)/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globAll({ filePath : '(src1|src2)/**', filter : { prefixPath : '/' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1/**';

  /* */

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1**'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b/a' ];
  var records = globTerminals( '/src1**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1**';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b', '/src1b/a' ];
  var records = globAll( '/src1**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1/*'; /* */

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c' ];
  var records = globTerminals( '/src1/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/*';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var records = globAll( '/src1/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1*'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals( '/src1*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1*';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/src1', '/src1b' ];
  var records = globAll( '/src1*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src3/** - nothing'; /* */

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals( '/src3/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src3/** - nothing';

  clean();
  var expectedAbsolutes = [];
  var records = globAll( '/src3/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src?'; /* */

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/src?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src?';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src1', '/src2' ];
  var records = globAll( '/src?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src?*'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT' ];
  var records = globTerminals( '/src?*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src?*';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '/src?*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src*?'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT' ];
  var records = globTerminals( '/src*?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src*?';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '/src*?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src**?'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT', '/src/f', '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b/a', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d/a', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d/a' ];
  var records = globTerminals( '/src**?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src**?';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src', '/src/f', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b', '/src1b/a', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d', '/src3.js/d/a', '/src3.s', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d', '/src3.s/d/a' ];
  var records = globAll( '/src**?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src?**'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT', '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b/a', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d/a', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d/a' ];
  var records = globTerminals( '/src?**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src?**';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b', '/src1b/a', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d', '/src3.js/d/a', '/src3.s', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d', '/src3.s/d/a' ];
  var records = globAll( '/src?**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+(src)2'; /* */

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals( '/+(src)2' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+(src)2';

  clean();
  var expectedAbsolutes = [ '/', '/src2' ];
  var records = globAll( '/+(src)2' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+(alt)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/altalt/a' ];
  var records = globTerminals( '/+(alt)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+(alt)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/altalt', '/altalt/a', '/altalt/d' ];
  var records = globAll( '/+(alt)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+(alt|ctrl)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/altalt/a', '/altctrl/a', '/altctrlalt/a', '/ctrl/a', '/ctrlctrl/a' ]
  var records = globTerminals( '/+(alt|ctrl)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+(alt|ctrl)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/altalt', '/altalt/a', '/altalt/d', '/altctrl', '/altctrl/a', '/altctrl/d', '/altctrlalt', '/altctrlalt/a', '/altctrlalt/d', '/ctrl', '/ctrl/a', '/ctrl/d', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d' ];
  var records = globAll( '/+(alt|ctrl)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /*(alt|ctrl)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/altalt/a', '/altctrl/a', '/altctrlalt/a', '/ctrl/a', '/ctrlctrl/a' ];
  var records = globTerminals( '/*(alt|ctrl)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*(alt|ctrl)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/altalt', '/altalt/a', '/altalt/d', '/altctrl', '/altctrl/a', '/altctrl/d', '/altctrlalt', '/altctrlalt/a', '/altctrlalt/d', '/ctrl', '/ctrl/a', '/ctrl/d', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d' ];
  var records = globAll( '/*(alt|ctrl)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt*(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/altalt2/a', '/altctrl2/a', '/altctrlalt2/a' ];
  var records = globTerminals( '/alt*(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt*(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/altalt2', '/altalt2/a', '/altalt2/d', '/altctrl2', '/altctrl2/a', '/altctrl2/d', '/altctrlalt2', '/altctrlalt2/a', '/altctrlalt2/d' ];
  var records = globAll( '/alt*(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /*(alt|ctrl|2)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/alt2/a', '/altalt/a', '/altalt2/a', '/altctrl/a', '/altctrl2/a', '/altctrlalt/a', '/altctrlalt2/a', '/ctrl/a', '/ctrl2/a', '/ctrlctrl/a', '/ctrlctrl2/a' ];
  var records = globTerminals( '/*(alt|ctrl|2)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*(alt|ctrl|2)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/alt2', '/alt2/a', '/alt2/d', '/altalt', '/altalt/a', '/altalt/d',
    '/altalt2', '/altalt2/a', '/altalt2/d', '/altctrl', '/altctrl/a', '/altctrl/d', '/altctrl2', '/altctrl2/a', '/altctrl2/d',
    '/altctrlalt', '/altctrlalt/a', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/a', '/altctrlalt2/d', '/ctrl', '/ctrl/a',
    '/ctrl/d', '/ctrl2', '/ctrl2/a', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/a', '/ctrlctrl2/d' ];
  var records = globAll( '/*(alt|ctrl|2)/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt?(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/altalt2/a', '/altctrl2/a' ];
  var records = globTerminals( '/alt?(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt?(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/altalt2', '/altalt2/a', '/altalt2/d', '/altctrl2', '/altctrl2/a', '/altctrl2/d' ];
  var records = globAll( '/alt?(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt!(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a' ];
  var records = globTerminals( '/alt!(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt!(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d' ];
  var records = globAll( '/alt!(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt!(ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/altalt/a', '/altalt2/a' ];
  var records = globTerminals( '/alt!(ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt!(ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/altalt', '/altalt/a', '/altalt/d', '/altalt2', '/altalt2/a', '/altalt2/d' ];
  var records = globAll( '/alt!(ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /@(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/ctrl2/a' ];
  var records = globTerminals( '/@(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /@(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/ctrl2', '/ctrl2/a', '/ctrl2/d' ];
  var records = globAll( '/@(alt|ctrl)?/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /*([c-s])?';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/*([c-s])?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*([c-s])?';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src', '/src1', '/src2' ];
  var records = globAll( '/*([c-s])?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+([c-s])?';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/+([c-s])?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+([c-s])?';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src', '/src1', '/src2' ];
  var records = globAll( '/+([c-s])?' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals +([lrtc])';

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals( '/', '+([lrtc])' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([lrtc])';

  clean();
  var expectedAbsolutes = [ '/', '/ctrl', '/ctrlctrl' ];
  var records = globAll( '/', '+([lrtc])' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals +([^lt])';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/', '+([^lt])' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([^lt])';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '/', '+([^lt])' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.case = 'globTerminals +([!lt])';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/', '+([!lt])' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([!lt])';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '/', '+([!lt])' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals doubledir/d1/d11/*';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var records = globTerminals( '/', 'doubledir/d1/d11/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll doubledir/d1/d11/*';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var records = globAll( '/', 'doubledir/d1/d11/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals src1/**/*';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/', 'src1/**/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll src1/**/*';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/', 'src1/**/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals **/*.s';

  clean();
  var expectedAbsolutes = [ '/src3.js/b.s', '/src3.s/b.s' ];
  var records = globTerminals( '/', '**/*.s' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **/*.s';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/d', '/alt2', '/alt2/d', '/altalt', '/altalt/d', '/altalt2', '/altalt2/d', '/altctrl', '/altctrl/d', '/altctrl2', '/altctrl2/d', '/altctrlalt', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/d', '/ctrl', '/ctrl/d', '/ctrl2', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/d', '/doubledir', '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d2', '/doubledir/d2/d22', '/src', '/src1', '/src1/d', '/src1b', '/src2', '/src2/d', '/src3.js', '/src3.js/b.s', '/src3.js/d', '/src3.s', '/src3.s/b.s', '/src3.s/d' ];
  var records = globAll( '/', '**/*.s' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals **/*.js';

  clean();
  var expectedAbsolutes = [ '/src3.js/c.js', '/src3.s/c.js' ];
  var records = globTerminals( '/', '**/*.js' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **/*.js';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/d', '/alt2', '/alt2/d', '/altalt', '/altalt/d', '/altalt2', '/altalt2/d', '/altctrl', '/altctrl/d', '/altctrl2', '/altctrl2/d', '/altctrlalt', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/d', '/ctrl', '/ctrl/d', '/ctrl2', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/d', '/doubledir', '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d2', '/doubledir/d2/d22', '/src', '/src1', '/src1/d', '/src1b', '/src2', '/src2/d', '/src3.js', '/src3.js/c.js', '/src3.js/d', '/src3.s', '/src3.s/c.js', '/src3.s/d' ];
  var records = globAll( '/', '**/*.js' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals **.s/*';

  clean();
  var expectedAbsolutes = [ '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js' ];
  var records = globTerminals( '/', '**.s/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **.s/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/d', '/alt2', '/alt2/d', '/altalt', '/altalt/d', '/altalt2', '/altalt2/d', '/altctrl', '/altctrl/d', '/altctrl2', '/altctrl2/d', '/altctrlalt', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/d', '/ctrl', '/ctrl/d', '/ctrl2', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/d', '/doubledir', '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d2', '/doubledir/d2/d22', '/src', '/src1', '/src1/d', '/src1b', '/src2', '/src2/d', '/src3.js', '/src3.js/d', '/src3.s', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d' ];
  var records = globAll( '/', '**.s/*' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1Terminal/**';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals( '/src1Terminal/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/**';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll( '/src1Terminal/**' );
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** with options map';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ filePath : '/src1Terminal/**' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** with options map';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ filePath : '/src1Terminal/**' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** with basePath and prefixPath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ filePath : '/src1Terminal/**', filter : { basePath : '/src1Terminal', prefixPath : '/src1Terminal' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** with basePath and prefixPath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ filePath : '/src1Terminal/**', filter : { basePath : '/src1Terminal', prefixPath : '/src1Terminal' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal with basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ filePath : '/src1Terminal', filter : { basePath : '/src1Terminal' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal with basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ filePath : '/src1Terminal', filter : { basePath : '/src1Terminal' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** with basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ filePath : '/src1Terminal/**', filter : { basePath : '/src1Terminal' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** with basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ filePath : '/src1Terminal/**', filter : { basePath : '/src1Terminal' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** without basePath and prefixPath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ filePath : '/src1Terminal/**', filter : { basePath : null, prefixPath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** without basePath and prefixPath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ filePath : '/src1Terminal/**', filter : { basePath : null, prefixPath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** without basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ filePath : '/src1Terminal/**', filter : { basePath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** without basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ filePath : '/src1Terminal/**', filter : { basePath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals [ /doubledir/d1/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var expectedRelatives = [ '../a', './b', './c' ];
  var records = globTerminals({ filePath : [ '/doubledir/d1/**' ], filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var expectedRelatives = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filePath : [ '/doubledir/d1/**' ], filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : [ '/doubledir/d2/**' ], filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : [ '/doubledir/d2/**' ], filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [c-s][c-s][c-s][0-9]/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globTerminals({ filter : { prefixPath : '/' }, filePath : '[c-s][c-s][c-s][0-9]/**' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll [c-s][c-s][c-s][0-9]/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globAll({ filter : { prefixPath : '/' }, filePath : '[c-s][c-s][c-s][0-9]/**' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals *([c-s])[0-9]/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globTerminals({ filter : { prefixPath : '/' }, filePath : '*([c-s])[0-9]/**' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll *([c-s])[0-9]/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globAll({ filter : { prefixPath : '/' }, filePath : '*([c-s])[0-9]/**' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals +([crs1])/**/+([abc])';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals({ filter : { prefixPath : '/' }, filePath : '+([crs1])/**/+([abc])' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([crs1])/**/+([abc])';

  clean();
  var expectedAbsolutes = [ '/', '/src', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll({ filter : { prefixPath : '/' }, filePath : '+([crs1])/**/+([abc])' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals **/d11/*';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var records = globTerminals({ filter : { prefixPath : '/' }, filePath : '**/d11/*' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **/d11/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/d', '/alt2', '/alt2/d', '/altalt', '/altalt/d', '/altalt2', '/altalt2/d', '/altctrl', '/altctrl/d', '/altctrl2', '/altctrl2/d', '/altctrlalt', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/d', '/ctrl', '/ctrl/d', '/ctrl2', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/d', '/doubledir', '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/d22', '/src', '/src1', '/src1/d', '/src1b', '/src2', '/src2/d', '/src3.js', '/src3.js/d', '/src3.s', '/src3.s/d' ];
  var records = globAll({ filter : { prefixPath : '/' }, filePath : '**/d11/*' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var expectedRelatives = [ '../a', './b', './c' ];
  var records = globTerminals({ filter : { prefixPath : '/doubledir/d1/**', basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c' ];
  var expectedRelatives = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filter : { prefixPath : '/doubledir/d1/**', basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  /**/

  test.case = 'globTerminals prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, filePath:b';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/d11/b' ];
  var expectedRelatives = [ './b' ];
  var records = globTerminals({ filter : { prefixPath : '/doubledir/d1/**', basePath : '/doubledir/d1/d11' }, filePath : 'b' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, filePath:b';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d1/d11/b' ];
  var expectedRelatives = [ '..', '.', './b' ];
  var records = globAll({ filter : { prefixPath : '/doubledir/d1/**', basePath : '/doubledir/d1/d11' }, filePath : 'b' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  /* - */

  test.open( 'base marker *()' );

  /* - */

  test.case = 'globTerminals /src1*()';

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals({ filePath : '/src1*()' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1*()';

  clean();
  var expectedAbsolutes = [ '/', '/src1' ];
  var records = globAll({ filePath : '/src1*()' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/a*()';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/src1/a*()' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/a*()';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/src1/a*()' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/*()a';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/src1/*()a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/*()a';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/src1/*()a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /*()src1/a';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/*()src1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*()src1/a';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/*()src1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /sr*()c1/a';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/sr*()c1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /sr*()c1/a';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/sr*()c1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* - */

  test.close( 'base marker *()' );

  test.open( 'base marker \\0' );

  /* - */

  test.case = 'globTerminals /src1\\0';

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals({ filePath : '/src1\0' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1\\0';

  clean();
  var expectedAbsolutes = [ '/', '/src1' ];
  var records = globAll({ filePath : '/src1\0' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/a\\0';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/src1/a\0' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/a\\0';

  clean();
  var expectedAbsolutes = [ '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/src1/a\0' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /\\0src1/a';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/\0src1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /\\0src1/a';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/\0src1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /sr\\0c1/a';

  clean();
  var expectedAbsolutes = [ '/src1/a' ];
  var records = globTerminals({ filePath : '/sr\0c1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /sr\\0c1/a';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a' ];
  var records = globAll({ filePath : '/sr\0c1/a' });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* - */

  test.close( 'base marker \\0' );

  test.open( 'several paths' );

  /* - */

  test.case = 'globTerminals [ /src1/d/**, /src2/d/** ]';

  clean();
  var expectedAbsolutes = [ '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globTerminals({ filePath : [ '/src1/d/**', '/src2/d/**' ] });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll [ /src1/d/**, /src2/d/** ]';

  clean();
  var expectedAbsolutes = [ '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globAll({ filePath : [ '/src1/d/**', '/src2/d/**' ] });
  var gotAbsolutes = context.select( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ], no options map';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals([ '/doubledir/d1/**', '/doubledir/d2/**' ]);
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ], no options map';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll([ '/doubledir/d1/**', '/doubledir/d2/**' ]);
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ]';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ] });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ]';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ] });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { basePath : '/' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { basePath : '/' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './d1/a', './d1/d11/b', './d1/d11/c', './d2/b', './d2/d22/c', './d2/d22/d' ];
  var records = globTerminals({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { basePath : '/doubledir' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './d1', './d1/a', './d1/d11', './d1/d11/b', './d1/d11/c', './d2', './d2/b', './d2/d22', './d2/d22/c', './d2/d22/d' ];
  var records = globAll({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { basePath : '/doubledir' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { prefixPath : null, basePath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { prefixPath : null, basePath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  /**/

  test.case = 'globTerminals [ /ctrl/**, /ctrlctrl/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolutes = [ '/ctrl/a', '/ctrl/d/a', '/ctrlctrl/a', '/ctrlctrl/d/a' ];
  var expectedRelatives = [ './a', './d/a', './a', './d/a' ];
  var records = globTerminals({ filePath : [ '/ctrl/**', '/ctrlctrl/**' ], filter : { prefixPath : null, basePath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /ctrl/**, /ctrlctrl/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolutes = [ '/ctrl', '/ctrl/a', '/ctrl/d', '/ctrl/d/a', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d', '/ctrlctrl/d/a' ];
  var expectedRelatives = [ '.', './a', './d', './d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : [ '/ctrl/**', '/ctrlctrl/**' ], filter : { prefixPath : null, basePath : null } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '../a', './b', './c', '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '..', '../a', '.', './b', './c', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  /* zzz */

  // test.case = 'globTerminals **b** : 0, prefixPath : [ /doubledir/d1, /doubledir/d2 ], basePath:/doubledir/d1';
  //
  // clean();
  // var expectedAbsolutes = [ '/doubledir/d1/d11/b', '/doubledir/d2/b' ];
  // var expectedRelatives = [ './b', '../../d2/b' ];
  // var records = globTerminals({ filePath : '**b**', filter : { prefixPath : [ '/doubledir/d1', '/doubledir/d2' ], basePath : '/doubledir/d1/d11' } });
  // var gotAbsolutes = context.select( records, '*.absolute' );
  // var gotRelatives = context.select( records, '*.relative' );
  // test.identical( gotAbsolutes, expectedAbsolutes );
  // test.identical( gotRelatives, expectedRelatives );
  //
  // test.case = 'globAll **b** : 0, prefixPath : [ /doubledir/d1, /doubledir/d2 ], basePath:/doubledir/d1';
  //
  // clean();
  // var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22' ];
  // var expectedRelatives = [ '..', '.', './b', '../../d2', '../../d2/b', '../../d2/d22' ];
  // var records = globAll({ filePath : '**b**', filter : { prefixPath : [ '/doubledir/d1', '/doubledir/d2' ], basePath : '/doubledir/d1/d11' } });
  // var gotAbsolutes = context.select( records, '*.absolute' );
  // var gotRelatives = context.select( records, '*.relative' );
  // test.identical( gotAbsolutes, expectedAbsolutes );
  // test.identical( gotRelatives, expectedRelatives );

  test.close( 'several paths' );

  /* - */

  test.open( 'glob map' );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '../a', './c', '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { '/doubledir/d1/**' : 1, '/doubledir/d2/**' : 1, '**b**' : 0 }, filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '..', '../a', '.', './c', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { '/doubledir/d1/**' : 1, '/doubledir/d2/**' : 1, '**b**' : 0 }, filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/c', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { '/doubledir/d1/**' : 1, '/doubledir/d2/**' : 1, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { '/doubledir/d1/**' : 1, '/doubledir/d2/**' : 1, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : '/doubledir/d1/d11' } });
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  /* zzz */

  // test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath : [ ../../d1, ../../d2 ], basePath:/doubledir/d1/d11';
  //
  // clean();
  // var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/c', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  // var expectedRelatives = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  // var records = globTerminals({ filePath : { '/doubledir/d1/**' : 1, '/doubledir/d2/**' : 1, '**b**' : 0 }, filter : { prefixPath : [ '../../d1', '../../d2' ], basePath : '/doubledir/d1/d11' } });
  // var gotAbsolutes = context.select( records, '*.absolute' );
  // var gotRelatives = context.select( records, '*.relative' );
  // test.identical( gotAbsolutes, expectedAbsolutes );
  // test.identical( gotRelatives, expectedRelatives );
  //
  // test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath : [ ../../d1, ../../d2 ], basePath:/doubledir/d1/d11';
  //
  // clean();
  // var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  // var expectedRelatives = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  // var records = globAll({ filePath : { '/doubledir/d1/**' : 1, '/doubledir/d2/**' : 1, '**b**' : 0 }, filter : { prefixPath : [ '../../d1', '../../d2' ], basePath : '/doubledir/d1/d11' } });
  // var gotAbsolutes = context.select( records, '*.absolute' );
  // var gotRelatives = context.select( records, '*.relative' );
  // test.identical( gotAbsolutes, expectedAbsolutes );
  // test.identical( gotRelatives, expectedRelatives );
  //
  // /* */
  //
  // test.case = 'globTerminals filePath : { . : 1, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  //
  // clean();
  // var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/c', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  // var expectedRelatives = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  // var records = globTerminals({ filePath : { '.' : 1, '**b**' : 0 }, filter : { prefixPath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], basePath : '/doubledir/d1/d11' } });
  // var gotAbsolutes = context.select( records, '*.absolute' );
  // var gotRelatives = context.select( records, '*.relative' );
  // test.identical( gotAbsolutes, expectedAbsolutes );
  // test.identical( gotRelatives, expectedRelatives );
  //
  // test.case = 'globAll filePath : { . : 1, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  //
  // clean();
  // var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  // var expectedRelatives = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  // var records = globAll({ filePath : { '.' : 1, '**b**' : 0 }, filter : { prefixPath : [ '/doubledir/d1/**', '/doubledir/d2/**' ], basePath : '/doubledir/d1/d11' } } );
  // var gotAbsolutes = context.select( records, '*.absolute' );
  // var gotRelatives = context.select( records, '*.relative' );
  // test.identical( gotAbsolutes, expectedAbsolutes );
  // test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll filePath : { /ctrl2** : 1, /alt2** : 1 }';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/alt2/d/a', '/ctrl2', '/ctrl2/a', '/ctrl2/d', '/ctrl2/d/a' ];
  var expectedRelatives = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ];
  var records = globAll({ filePath : { '/ctrl2/**' : 1, '/alt2**' : 1 }, filter : { prefixPath : null, basePath : null } } );
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll filePath : { /ctrl2** : 1, /alt2** : 1 }';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/alt2/d/a', '/ctrl2', '/ctrl2/a', '/ctrl2/d', '/ctrl2/d/a' ];
  var expectedRelatives = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ];
  var records = globAll({ filePath : { '/alt2**' : 1, '/ctrl2/**' : 1 }, filter : { prefixPath : null, basePath : null } } );
  var gotAbsolutes = context.select( records, '*.absolute' );
  var gotRelatives = context.select( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.close( 'glob map' );

  /* - */

}

filesFindGlob.timeOut = 45000;

/*

ctrl :
{
  a : '/ctrl/a',
  d :
  {
    a : '/ctrl/d/a',
  }
}

ctrl2 :
{
  a : '/ctrl2/a',
  d :
  {
    a : '/ctrl2/d/a',
  }
}

ctrlctrl :
{
  a : '/ctrlctrl/a',
  d :
  {
    a : '/ctrlctrl/d/a',
  }
},

*/

//

function filesGlob( test )
{
  var context = this;
  var filesTree =
  {
    'a' :
    {
      'a.js' : '',
      'a.s' : '',
      'a.ss' : '',
      'a.txt' : '',
      'c' :
      {
        'c.js' : '',
        'c.s' : '',
        'c.ss' : '',
        'c.txt' : '',
      }
    },
    'b' :
    {
      'a' :
      {
        'x' :
        {
          'a' :
          {
            'a.js' : '',
            'a.s' : '',
            'a.ss' : '',
            'a.txt' : '',
          }
        }
      }
    },

    'a.js' : '',
    'a.s' : '',
    'a.ss' : '',
    'a.txt' : '',
  }

  var testDir = _.path.join( context.testRootDirectory, test.name );

  _.fileProvider.safe = 0;
  _.FileProvider.Extract.readToProvider
  ({
    dstProvider : _.fileProvider,
    dstPath : testDir,
    filesTree : filesTree,
    allowWrite : 1,
    allowDelete : 1,
  });

  var commonOptions  =
  {
    outputFormat : 'relative',
  }

  function completeOptions( glob )
  {
    var options = _.mapExtend( null, commonOptions );
    options.filePath = _.path.join( testDir, glob );
    return options
  }

  /* - */

  test.case = 'simple glob';

  var glob = '*'
  var got = _.fileProvider.filesGlob( completeOptions( glob ) );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt'
  ];
  test.identical( got, expected );

  var glob = '**'
  var got = _.fileProvider.filesGlob( completeOptions( glob ) );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt',
    './a/a.js',
    './a/a.s',
    './a/a.ss',
    './a/a.txt',
    './a/c/c.js',
    './a/c/c.s',
    './a/c/c.ss',
    './a/c/c.txt',
    './b/a/x/a/a.js',
    './b/a/x/a/a.s',
    './b/a/x/a/a.ss',
    './b/a/x/a/a.txt'
  ]
  test.identical( got, expected );

  var  glob = 'a/*.js';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a.js',
  ]
  test.identical( got, expected );

  var  glob = 'a/a.*';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt'
  ]
  test.identical( got, expected );

  var  glob = 'a/a.j?';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a.js',
  ]
  test.identical( got, expected );

  var  glob = 'a/[!cb].s';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a.s',
  ]
  test.identical( got, expected );

  /**/

  test.case = 'complex glob';

  var  glob = '**/a/a.?';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a/a.s', './b/a/x/a/a.s'
  ]
  test.identical( got, expected );

  var  glob = '**/x/**/a.??';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './b/a/x/a/a.js',
    './b/a/x/a/a.ss',
  ]
  test.identical( got, expected );

  var  glob = '**/[!ab]/*.?s';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a/c/c.js',
    './a/c/c.ss',
  ]
  test.identical( got, expected );

  var  glob = 'b/[a-c]/**/a/*';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a/x/a/a.js',
    './a/x/a/a.s',
    './a/x/a/a.ss',
    './a/x/a/a.txt'
  ]
  test.identical( got, expected );

  var glob = '[ab]/**/[!xc]/*';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected = [ './b/a/x/a/a.js', './b/a/x/a/a.s', './b/a/x/a/a.ss', './b/a/x/a/a.txt' ];
  test.identical( got, expected );

  /**/

  var glob = '**/*.s';
  var options =
  {
    filePath : _.path.join( testDir, 'a/c', glob ),
    outputFormat : 'relative',
    filter: { basePath : testDir }
  }
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a/c/c.s',
  ]
  test.identical( got, expected );

  /**/

  /* {} are not supported, yet zzz */

  // var  glob = 'a/{x.*, a.*}';
  // var options = completeOptions( glob );
  // var got = _.fileProvider.filesGlob( options );
  // var expected =
  // [
  //   './a.js',
  //   './a.s',
  //   './a.ss',
  //   './a.txt'
  // ]
  // test.identical( got, expected );
  //
  // var  glob = '**/c/{x.*, c.*}';
  // var options = completeOptions( glob );
  // var got = _.fileProvider.filesGlob( options );
  // var expected =
  // [
  //   './a/c/c.js',
  //   './a/c/c.s',
  //   './a/c/c.ss',
  //   './a/c/c.txt',
  // ]
  // test.identical( got, expected );
  //
  // var  glob = 'b/*/{x, c}/a/*';
  // var options = completeOptions( glob );
  // var got = _.fileProvider.filesGlob( options );
  // var expected =
  // [
  //   './a/x/a/a.js',
  //   './a/x/a/a.s',
  //   './a/x/a/a.ss',
  //   './a/x/a/a.txt'
  // ]
  // test.identical( got, expected );

}

//

function filesReflectTrivial( t )
{
  var context = this;

  /* */

  t.case = 'deleting enabled, included files should be deleted'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst',
    },
    filter :
    {
      maskAll : { includeAny : /file2$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file2 : 'file2', dir : { file : 'file' } }
  }
  t.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/file2', '/dst/dir', '/dst/dir/file2' ];
  var expectedSrcAbsolute = [ '/src', '/src/file2', '/src/dir', '/src/dir/file2' ];
  var expectedEffAbsolute = [ '/src', '/src/file2', '/dst/dir', '/dst/dir/file2' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, false, true ];
  var expectedPreserve = [ true, false, true, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'deleting enabled, no filter';

  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  // debugger;
  t.mustNotThrowError( () => provider.filesReflect( o ) );
  // debugger;

  var expectedTree =
  {
    dst : { file : 'file', file2 : 'file2' }
  }
  t.identical( provider.filesTree, expectedTree );

  /* */

  t.case = 'deleting disabled, separate filters'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : 'file' }
    },
    dstFilter :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  t.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst' ];
  var expectedSrcAbsolute = [ '/src' ];
  var expectedEffAbsolute = [ '/src' ];
  var expectedAction = [ 'dirMake' ];
  var expectedAllow = [ true ];
  var expectedPreserve = [ true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'deleting enabled, separate filters'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } },
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : 'file' }
    },
    dstFilter :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : {},
  }
  t.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/file', '/dst/dir/file2' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/file', '/src/dir/file2' ];
  var expectedEffAbsolute = [ '/src', '/dst/dir', '/dst/dir/file', '/dst/dir/file2' ];
  var expectedAction = [ 'dirMake', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'src deleting enabled, no filter, all files from src should be deleted'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    dst :
    {
      file : 'file',
      file2 : 'file2',
      dir : { file : 'file', file2 : 'file2' }
    }
  }
  t.identical( provider.filesTree, expectedTree );

  /* */

  t.case = 'dst deleting enabled, no filter, all files from dst should be deleted'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { file : 'file', file2 : 'file2' }
  }
  t.identical( provider.filesTree, expectedTree );

  /* */

  t.case = 'deleting enabled, filtered files in dst are preserved'
  var tree =
  {
    src : { file2 : 'file2' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    dstFilter :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file2 : 'file2' },
    dst : { file2 : 'file2', dir : { file : 'file'} }
  }
  t.identical( provider.filesTree, expectedTree )

  /* */

  t.case = 'dstDeleting:1 srcDeleting:0 dstFilter only'
  var tree =
  {
    src : { file2 : 'file2' },
    dst : { dir : { file : 'file' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    dstFilter :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { file2 : 'file2' },
    dst : { file2 : 'file2' },
  }
  t.identical( provider.filesTree, expectedTree )

  var expectedDstAbsolute = [ '/dst', '/dst/file2', '/dst/dir', '/dst/dir/file' ];
  var expectedSrcAbsolute = [ '/src', '/src/file2', '/src/dir', '/src/dir/file' ];
  var expectedEffAbsolute = [ '/src', '/src/file2', '/dst/dir', '/dst/dir/file' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'src contains filtered file, directory must be preserved'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  t.identical( provider.filesTree, expectedTree )

  /* */

  t.case = 'deleting disabled, srcFilter excludes file'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  t.identical( provider.filesTree, expectedTree )

  /* */

  t.case = 'deleting disabled, dstFilter excludes file'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    dstFilter :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file : 'file', dir : { file : 'file'} }
  }
  t.identical( provider.filesTree, expectedTree )

  /* */

  t.case = 'deleting disabled, common filter excludes file'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    filter :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  t.identical( provider.filesTree, expectedTree )

  /* */

  t.case = 'deleting disabled, no filters'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file : 'file', dir : { file : 'file'} }
  }
  t.identical( provider.filesTree, expectedTree );

  /* */

  t.case = 'try to rewrite file.b, file should not be deleted, filter points only to file.a'
  var tree =
  {
    src :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.b'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c'
    }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    writing : 1,
    includingDirs : 1,
    dstRewriting : 1,
    srcFilter : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  t.mustNotThrowError( () => provider.filesReflect( o ) );

  var expectedTree =
  {
    src :
    {
      'file.b' : 'file.b'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c'
    }
  }
  t.identical( provider.filesTree, expectedTree );

  /*  */

  t.case = 'dst/srcfile-dstdir should not be deleted';
  var tree =
  {
    src :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c',
      'srcfile-dstdir' : { 'file' : 'file' }
    }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    writing : 1,
    dstRewriting : 1,
    srcFilter : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 0,
    includingDst : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  provider.filesReflect( o )

  var expectedTree =
  {
    src :
    {
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c',
      'srcfile-dstdir' : { 'file' : 'file' }
    }
  }
  t.identical( provider.filesTree, expectedTree );

  /*  */

  t.case = 'dst/srcfile-dstdir should be deleted';
  var tree =
  {
    src :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c',
      'srcfile-dstdir' : { 'file' : 'file' }
    }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    writing : 1,
    dstRewriting : 1,
    srcFilter : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 1,
    includingDst : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  provider.filesReflect( o )

  var expectedTree =
  {
    src :
    {
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
    }
  }
  t.identical( provider.filesTree, expectedTree );

  //

  var tree =
  {
    'src' :
    {
      'dir' :
      {
        a : 'a'
      },
    },
    'dst' :
    {
      'dir' :
      {
        'file' : 'file',
      },
    },
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    srcFilter : { ends : '.b' },
    includingDst : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    writing : 1,
    dstRewriting : 1,
    dstDeleting : 0,
    srcDeleting : 1,
    dstRewritingByDistinct : 0
  }
  provider.filesReflect( o );

  var expectedTree =
  {
    'src' :
    {
      'dir' :
      {
        a : 'a'
      },
    },
    'dst' :
    {
      'dir' :
      {
        'file' : 'file',
      },
    },
  }
  t.identical( provider.filesTree, expectedTree );

  /**/

  var tree =
  {
    'src' :
    {
      'dir' :
      {
        'b.b' : 'b',
        'file' : { a : 'a' }
      },
    },
    'dst' :
    {
      'dir' :
      {
        'b.b' : 'c',
        'file' : 'file',
      },
    },
  }

  var provider = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    srcFilter : { ends : '.b' },
    includingDst : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    writing : 1,
    dstRewriting : 1,
    dstDeleting : 0,
    srcDeleting : 1,
    dstRewritingByDistinct : 0
  }
  provider.filesReflect( o );

  var expectedTree =
  {
    'src' :
    {
      'dir' :
      {
        'file' : { a : 'a' }
      },
    },
    'dst' :
    {
      'dir' :
      {
        'b.b' : 'b',
        'file' : 'file',
      },
    },
  }

  t.identical( provider.filesTree, expectedTree );

  //

  t.case = 'onUp should return original record'
  var tree =
  {
    'src' :
    {
       a : 'a',
       b : 'b'
    },
    'dst' :
    {
    },
  }

  function onUp( record )
  {
    record.dst.absolute = record.dst.absolute + '.ext';
    return record;
  }

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onUp : onUp,
    includingDst : 0,
    includingTerminals : 1,
    includingDirs : 0,
    recursive : '2',
    writing : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  t.shouldThrowError( () => provider.filesReflect( o ) );
  t.identical( provider.filesTree, tree );

  //

  t.case = 'linking : nop, dst files will be deleted for rewriting after onWriteDstUp call'
  var tree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'dst',
      a1 : 'dst',
    },
  }

  function onWriteDstUp1( record )
  {
    if( !record.dst.isDir )
    record.dst.factory.fileProvider.fileWrite( record.dst.absolute, 'onWriteDstUp' );
    return record;
  }

  var provider = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onWriteDstUp : onWriteDstUp1,
    srcFilter : { maskTerminal : { includeAny : 'a' } },
    recursive : '2',
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  provider.filesReflect( o )
  var expectedTree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
    }
  }

  t.identical( provider.filesTree, expectedTree );

  //

  t.case = 'linking : nop, return _.dont from onWriteDstUp to prevent any action'
  var tree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'dst',
      a1 : 'dst',
    },
  }

  function onWriteDstUp2( record )
  {
    if( !record.dst.isDir )
    record.dst.factory.fileProvider.fileWrite( record.dst.absolute, 'onWriteDstUp' );
    return _.dont;
  }

  var provider = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onWriteDstUp : onWriteDstUp2,
    srcFilter : { maskTerminal : { includeAny : 'a' } },
    recursive : '2',
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  provider.filesReflect( o )
  var expectedTree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'onWriteDstUp',
      a1 : 'onWriteDstUp',
    }
  }

  t.identical( provider.filesTree, expectedTree );

}  /* end of filesReflectTrivial */

//

function filesReflectRecursive( t )
{
  var tree =
  {
    src : { a1 : '1', dir1 : { a2 : '2', dir2 : { a3 : '3' } } },
  }

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : 0,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : {}
  }
  t.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : '1',
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : { a1 : '1', dir1 : {} }
  }
  t.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : '2',
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src
  }
  t.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : 0,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src.a1
  }
  t.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : '1',
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src.a1
  }
  t.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : '2',
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src.a1
  }
  t.identical( provider.filesTree, expected );

  //

  if( Config.debug )
  {
    var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });

    t.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : 1 }) );
    t.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '3' }) );
    t.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : false }) );
    t.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : true }) );
  }
}

//

function filesReflectMutuallyExcluding( t )
{
  var context = this;
  var precise = true;

  /* */

  t.case = 'terminals, no dst, exclude src root'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src' },
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { src : 'src-src' },
    dst : { srcM : 'srcM-src' }
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/srcM' ];
  var expectedSrcAbsolute = [ '/src', '/src/srcM' ];
  var expectedEffAbsolute = [ '/src', '/src/srcM' ];
  var expectedAction = [ 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];
  var expectedSrcAction = [ null, 'fileDelete' ];
  var expectedSrcAllow = [ true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'terminals, no dst, exclude dst root'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src' },
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcM : 'srcM-src' },
    dst : { src : 'src-src' }
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/src' ];
  var expectedSrcAbsolute = [ '/src', '/src/src' ];
  var expectedEffAbsolute = [ '/src', '/src/src' ];
  var expectedAction = [ 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ false, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'terminals'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src', bothM : 'bothM-src', both : 'both-src' },
    dst : { dstM : 'dstM', dst : 'dst', bothM : 'bothM', both : 'both' }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcM : 'srcM-src', bothM : 'bothM-src' },
    dst : { dst : 'dst', both : 'both-src', src : 'src-src' }
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/both', '/dst/bothM', '/dst/src', '/dst/dst', '/dst/dstM' ];
  var expectedSrcAbsolute = [ '/src', '/src/both', '/src/bothM', '/src/src', '/src/dst', '/src/dstM' ];
  var expectedEffAbsolute = [ '/src', '/src/both', '/src/bothM', '/src/src', '/dst/dst', '/dst/dstM' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileCopy', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, 'fileDelete', null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'empty dirs';

  var tree =
  {
    src :
    {
      srcDirM : {}, srcDir : {}, bothDirM : {}, bothDir : {},
    },
    dst :
    {
      dstDirM : {}, dstDir : {}, bothDirM : {}, bothDir : {},
    }
  }

  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src :
    {
      srcDirM : {}, bothDirM : {},
    },
    dst :
    {
      dstDir : {}, bothDir : {}, srcDir : {},
    },
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/bothDir', '/dst/srcDir', '/dst/bothDirM', '/dst/dstDir', '/dst/dstDirM' ];
  var expectedSrcAbsolute = [ '/src', '/src/bothDir', '/src/srcDir', '/src/bothDirM', '/src/dstDir', '/src/dstDirM' ];
  var expectedEffAbsolute = [ '/src', '/src/bothDir', '/src/srcDir', '/dst/bothDirM', '/dst/dstDir', '/dst/dstDirM' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'fileDelete', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, false, true ];
  var expectedPreserve = [ true, true, false, false, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', 'fileDelete', null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'src dirs with two terms';

  var tree =
  {
    src :
    {
      fM : { term : 'src', termM : 'src' },
      f : { term : 'src', termM : 'src' },
    },
    dst :
    {
      fM : 'dst',
      f : 'dst',
    }
  }

  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src :
    {
      fM : { termM : 'src' }, f : { term : 'src', termM : 'src' },
    },
    dst :
    {
      fM : { term : 'src' }, f : 'dst',
    },
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/fM', '/dst/fM/term' ];
  var expectedSrcAbsolute = [ '/src', '/src/fM', '/src/fM/term' ];
  var expectedEffAbsolute = [ '/src', '/src/fM', '/src/fM/term' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true ];
  var expectedPreserve = [ true, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete' ];
  var expectedSrcAllow = [ false, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'dst dirs with two terms';

  var tree =
  {
    src :
    {
      dM : 'dst',
      d : 'dst',
    },
    dst :
    {
      dM : { term : 'dst', termM : 'dst' },
      d : { term : 'dst', termM : 'dst' },
    }
  }

  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src :
    {
      dM : 'dst',
    },
    dst :
    {
      dM : { term : 'dst' }, d : 'dst',
    },
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/d', '/dst/d/term', '/dst/d/termM', '/dst/dM', '/dst/dM/term', '/dst/dM/termM' ];
  var expectedSrcAbsolute = [ '/src', '/src/d', '/src/d/term', '/src/d/termM', '/src/dM', '/src/dM/term', '/src/dM/termM' ];
  var expectedEffAbsolute = [ '/src', '/src/d', '/dst/d/term', '/dst/d/termM', '/dst/dM', '/dst/dM/term', '/dst/dM/termM' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'dirMake', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'dst dirs with two terms';

  var tree =
  {
    src :
    {
      dM : 'dst', d : 'dst',
    },
    dst :
    {
      dM : { term : 'dst', termM : 'dst' }, d : { term : 'dst', termM : 'dst' },
    }
  }

  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src :
    {
      dM : 'dst',
    },
    dst :
    {
      dM : { term : 'dst' }, d : 'dst',
    },
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/d', '/dst/d/term', '/dst/d/termM', '/dst/dM', '/dst/dM/term', '/dst/dM/termM' ];
  var expectedSrcAbsolute = [ '/src', '/src/d', '/src/d/term', '/src/d/termM', '/src/dM', '/src/dM/term', '/src/dM/termM' ];
  var expectedEffAbsolute = [ '/src', '/src/d', '/dst/d/term', '/dst/d/termM', '/dst/dM', '/dst/dM/term', '/dst/dM/termM' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'dirMake', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'src dirs with single term';

  var tree =
  {
    src :
    {
      dWithM : { termM : 'src' },
      dWithoutM : { term : 'src' },
      dWith : { termM : 'src' },
      dWithout : { term : 'src' },
    },
    dst :
    {
      dWithM : 'dst',
      dWithoutM : 'dst',
      dWith : 'dst',
      dWithout : 'dst',
    }
  }

  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src :
    {
      dWithM : { termM : 'src' },
      dWithoutM : {},
      dWith : { termM : 'src' },
      dWithout : { term : 'src' }
    },
    dst :
    {
      dWithoutM : { term : 'src' },
      dWith : 'dst',
      dWithout : 'dst',
    },
  }
  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dWithM', '/dst/dWithoutM', '/dst/dWithoutM/term' ];
  var expectedSrcAbsolute = [ '/src', '/src/dWithM', '/src/dWithoutM', '/src/dWithoutM/term' ];
  var expectedEffAbsolute = [ '/src', '/src/dWithM', '/src/dWithoutM', '/src/dWithoutM/term' ];
  var expectedAction = [ 'dirMake', 'fileDelete', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, null, 'fileDelete' ];
  var expectedSrcAllow = [ false, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  t.case = 'dst dirs with single term';

  var tree =
  {
    src :
    {
      dWithM : 'src',
      dWithoutM : 'src',
      dWith : 'src',
      dWithout : 'src',
    },
    dst :
    {
      dWithM : { termM : 'dst' },
      dWithoutM : { term : 'dst' },
      dWith : { termM : 'dst' },
      dWithout : { term : 'dst' },
    }
  }

  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcFilter :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dstFilter :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src :
    {
      dWithM : 'src',
      dWithoutM : 'src',
      // dWith : 'src',
      // dWithout : 'src',
    },
    dst :
    {
      // dWithM : { termM : 'dst' },
      dWithoutM : { term : 'dst' },
      // dWith : { termM : 'dst' },
      dWith : 'src',
      // dWithout : { term : 'dst' },
      dWithout : 'src',
    }
  }

  t.identical( provider.filesTree.src, expectedTree.src );
  t.identical( provider.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dWith', '/dst/dWith/termM', '/dst/dWithout', '/dst/dWithout/term', '/dst/dWithM', '/dst/dWithM/termM', '/dst/dWithoutM', '/dst/dWithoutM/term' ];
  var expectedSrcAbsolute = [ '/src', '/src/dWith', '/src/dWith/termM', '/src/dWithout', '/src/dWithout/term', '/src/dWithM', '/src/dWithM/termM', '/src/dWithoutM', '/src/dWithoutM/term' ];
  var expectedEffAbsolute = [ '/src', '/src/dWith', '/dst/dWith/termM', '/src/dWithout', '/dst/dWithout/term', '/dst/dWithM', '/dst/dWithM/termM', '/dst/dWithoutM', '/dst/dWithoutM/term' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'dirMake', 'ignore' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, false ];
  var expectedPreserve = [ true, false, false, false, false, false, false, true, true ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );
  var srcAction = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  if( precise )
  {
    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );
    t.identical( preserve, expectedPreserve );
    t.identical( srcAction, expectedSrcAction );
    t.identical( srcAllow, expectedSrcAllow );
  }

}

//

function filesReflectWithFilter( t )
{
  var context = this;

  function prepareSingle()
  {

    var tree = _.FileProvider.Extract
    ({
    });

    return { src : tree, dst : tree, hub : tree };
  }

  function prepareTwo()
  {
    var dst = _.FileProvider.Extract
    ({
      filesTree :
      {
      },
    });
    var src = _.FileProvider.Extract
    ({
      filesTree :
      {
      },
    });
    var hub = new _.FileProvider.Hub({ empty : 1 });
    src.originPath = 'extract+src://';
    dst.originPath = 'extract+dst://';
    hub.providerRegister( src );
    hub.providerRegister( dst );
    return { src : src, dst : dst, hub : hub };
  }

  /* */

  var o =
  {
    prepare : prepareSingle,
  }

  context._filesReflectWithFilter( t, o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  context._filesReflectWithFilter( t, o );

}

filesReflectWithFilter.timeOut = 30000;

//

function _filesReflectWithFilter( t, o )
{
  var context = this;

  function makeOptions()
  {
    var o1 =
    {
      reflectMap :
      {
        [ '/srcExt' ] : '/dstExt'
      },
      srcFilter :
      {
        effectiveFileProvider : p.src,
        hasExtension : 'js',
      },
      dstFilter :
      {
        effectiveFileProvider : p.dst,
        hasExtension : 'js',
      },
    };
    return o1;
  }

  /* - */

  var p = o.prepare();

  p.src.filesTree.src =
  {
    'a' : '/srcExt/a',
    'b.s' : '/srcExt/b.s',
    'c.js' : '/srcExt/c.js',
    srcEmptyDir :
    {
    },
    'srcEmptyDir.js' :
    {
    },
  }

  p.dst.filesTree.dst =
  {
    'a' : '/dstExt/a',
    'b.s' : '/dstExt/b.s',
    'c.js' : '/dstExt/c.js',
    dstEmptyDir :
    {
    },
    'dstEmptyDir.js' :
    {
    },
  }

  var o1 = makeOptions();
  o1.reflectMap = { [ '/src' ] : '/dst' }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 0,
  }

  t.case = 'trivial \n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      'srcExt' :
      {
        'a' : '/srcExt/a',
        'b.s' : '/srcExt/b.s',
        'c.js' : '/srcExt/c.js',
        'srcEmptyDir' : {},
        'srcEmptyDir.js' : {},
      },

      'dstExt' :
      {
        'a' : '/dstExt/a',
        'b.s' : '/dstExt/b.s',
        'c.js' : '/srcExt/c.js',
        'dstEmptyDir' : {},
        'srcEmptyDir.js' : {},
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.srcExt );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dstExt );

  var expectedDstAbsolute = [ '/dst', '/dst/c.js', '/dst/srcEmptyDir.js', '/dst/dstEmptyDir.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/c.js', '/src/srcEmptyDir.js', '/src/dstEmptyDir.js' ];
  var expectedEffAbsolute = [ '/src', '/src/c.js', '/src/srcEmptyDir.js', '/dst/dstEmptyDir.js' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* - */

  var p = o.prepare();

  p.src.filesTree.src =
  {
    d1a :
    {
      d1b :
      {
        'a' : '/srcExt/d1a/d1b/a',
        'b.s' : '/srcExt/d1a/d1b/b.s',
        'c.js' : '/srcExt/d1a/d1b/c.js',
      }
    },
  }

  p.dst.filesTree.dst =
  {
    d1a :
    {
      d1b :
      {
        'a' : '/dstExt/d1a/d1b/a',
        'b.js' : '/dstExt/d1a/d1b/b.js',
        'c.s' : '/dstExt/d1a/d1b/c.s',
      }
    },
    d2a :
    {
      d2b :
      {
        'a.js' : '/dstExt/d2a/d2b/a.js',
      }
    },
    d3a :
    {
      d3b :
      {
        'a.s' : '/dstExt/d3a/d3b/a.s',
      }
    },
    'd4a.js' :
    {
      'd4b.js' :
      {
        'a.s' : '/dstExt/d4a.js/d4b.js/a.s',
      }
    },
  }

  // '/dst/d3a', '/dst/d3a/d3b', '/dst/d4a.js', '/dst/d4a.js/d4b.js'

  var o1 = makeOptions();
  o1.reflectMap = { [ '/src' ] : '/dst' }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 1,
  }

  t.case = 'trivial \n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      'src' :
      {
        d1a :
        {
          d1b :
          {
            'a' : '/srcExt/d1a/d1b/a',
            'b.s' : '/srcExt/d1a/d1b/b.s',
            'c.js' : '/srcExt/d1a/d1b/c.js',
          }
        },
      },

      'dst' :
      {
        d1a :
        {
          d1b :
          {
            'a' : '/dstExt/d1a/d1b/a',
            'c.s' : '/dstExt/d1a/d1b/c.s',
            'c.js' : '/srcExt/d1a/d1b/c.js',
          }
        },
        d3a :
        {
          d3b :
          {
            'a.s' : '/dstExt/d3a/d3b/a.s',
          }
        },
        'd4a.js' :
        {
          'd4b.js' :
          {
            'a.s' : '/dstExt/d4a.js/d4b.js/a.s',
          }
        },
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/d1a', '/dst/d1a/d1b', '/dst/d1a/d1b/c.js', '/dst/d1a/d1b/b.js', '/dst/d2a', '/dst/d2a/d2b', '/dst/d2a/d2b/a.js', '/dst/d3a', '/dst/d3a/d3b', '/dst/d4a.js', '/dst/d4a.js/d4b.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/d1a', '/src/d1a/d1b', '/src/d1a/d1b/c.js', '/src/d1a/d1b/b.js', '/src/d2a', '/src/d2a/d2b', '/src/d2a/d2b/a.js', '/src/d3a', '/src/d3a/d3b', '/src/d4a.js', '/src/d4a.js/d4b.js' ];
  var expectedEffAbsolute = [ '/src', '/src/d1a', '/src/d1a/d1b', '/src/d1a/d1b/c.js', '/dst/d1a/d1b/b.js', '/dst/d2a', '/dst/d2a/d2b', '/dst/d2a/d2b/a.js', '/dst/d3a', '/dst/d3a/d3b', '/dst/d4a.js', '/dst/d4a.js/d4b.js' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'ignore', 'ignore', 'ignore', 'ignore' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, false, false, false, false ];
  var expectedPreserve = [ true, true, true, false, false, false, false, false, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* - */

  var p = o.prepare();

  p.src.filesTree.src =
  {
    dSrcDirDstFile :
    {
      'a.js' :
      {
        'a' : '/srcExt/dSrcDirDstFile/a.js/a',
      }
    },
    dSrcFileDstDir :
    {
      'a.js' : '/srcExt/dSrcFileDstDir/a.js',
    },
    dSrcFileDstDir2 :
    {
      'a' : '/srcExt/dSrcFileDstDir2/a',
    },
  }

  p.dst.filesTree.dst =
  {
    dSrcDirDstFile :
    {
      'a.js' : '/dstExt/dSrcDirDstFile/a.js',
    },
    dSrcFileDstDir :
    {
      'a.js' :
      {
        'a.s' : '/dstExt/dSrcFileDstDir/a.js/a.s',
      }
    },
    dSrcFileDstDir2 :
    {
      'a' :
      {
        'a.js' : '/dstExt/dSrcFileDstDir2/a/a.js',
      }
    },
  }

  var o1 = makeOptions();
  o1.reflectMap = { [ '/src' ] : '/dst' }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
  }

  t.case = 'dir by term and vice-versa \n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      'src' :
      {
        dSrcDirDstFile :
        {
          'a.js' :
          {
            'a' : '/srcExt/dSrcDirDstFile/a.js/a',
          }
        },
        dSrcFileDstDir :
        {
          'a.js' : '/srcExt/dSrcFileDstDir/a.js'
        },
        dSrcFileDstDir2 :
        {
          'a' : '/srcExt/dSrcFileDstDir2/a'
        },
      },

      'dst' :
      {
        dSrcDirDstFile :
        {
          'a.js' : {}
        },
        dSrcFileDstDir :
        {
          'a.js' : '/srcExt/dSrcFileDstDir/a.js'
        },

      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dSrcDirDstFile', '/dst/dSrcDirDstFile/a.js', '/dst/dSrcFileDstDir', '/dst/dSrcFileDstDir/a.js', '/dst/dSrcFileDstDir/a.js/a.s', '/dst/dSrcFileDstDir2', '/dst/dSrcFileDstDir2/a', '/dst/dSrcFileDstDir2/a/a.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/dSrcDirDstFile', '/src/dSrcDirDstFile/a.js', '/src/dSrcFileDstDir', '/src/dSrcFileDstDir/a.js', '/src/dSrcFileDstDir/a.js/a.s', '/src/dSrcFileDstDir2', '/src/dSrcFileDstDir2/a', '/src/dSrcFileDstDir2/a/a.js' ];
  var expectedEffAbsolute = [ '/src', '/src/dSrcDirDstFile', '/src/dSrcDirDstFile/a.js', '/src/dSrcFileDstDir', '/src/dSrcFileDstDir/a.js', '/dst/dSrcFileDstDir/a.js/a.s', '/src/dSrcFileDstDir2', '/dst/dSrcFileDstDir2/a', '/dst/dSrcFileDstDir2/a/a.js' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, true, false, true, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

}

//

function filesReflect( t )
{
  var context = this;

  function prepareSingle()
  {

    var tree = _.FileProvider.Extract
    ({
      filesTree :
      {
        dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst2 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst3 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
        src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
        src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
      },
    });

    return { src : tree, dst : tree, hub : tree };
  }

  function prepareTwo()
  {
    var dst = _.FileProvider.Extract
    ({
      filesTree :
      {
        dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst2 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst3 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
      },
    });
    var src = _.FileProvider.Extract
    ({
      filesTree :
      {
        src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
        src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
        src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
      },
    });
    var hub = new _.FileProvider.Hub({ empty : 1 });
    src.originPath = 'extract+src://';
    dst.originPath = 'extract+dst://';
    hub.providerRegister( src );
    hub.providerRegister( dst );
    return { src : src, dst : dst, hub : hub };
  }

  /* */

  var o =
  {
    prepare : prepareSingle,
  }

  context._filesReflect( t, o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  context._filesReflect( t, o );

}

filesReflect.timeOut = 30000;

//

function _filesReflect( t, o )
{
  var context = this;

  function optionsMake()
  {
    var options =
    {
      reflectMap : { '/src' : '/dst' },
      srcFilter : { effectiveFileProvider : p.src },
      dstFilter : { effectiveFileProvider : p.dst },
    }
    return options;
  }

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, true, false, false, false, false, false, false, false, true, false, true, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/a1' ), p.dst.globalFromLocal( '/dst/a1' ) ]), false );
  t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/a1' ), p.src.globalFromLocal( '/src/a1' ) ]), false );
  t.identical( p.hub.filesAreHardLinked([ p.src.globalFromLocal( '/src/a1' ), p.dst.globalFromLocal( '/dst/a1' ) ]), false );
  t.identical( p.hub.filesAreHardLinked([ p.src.globalFromLocal( '/src/a1' ), p.src.globalFromLocal( '/src/a1' ) ]), true );

  debugger; return; xxx

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'softlink',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with linking : softlink\n' + _.toStr( o2 );

  // if( p.src === p.dst )
  {

    var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

    var expected = _.FileProvider.Extract
    ({
      filesTree :
      {
        src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
        dst : { a2 : '2', a1 : [{ softLink : p.src.globalFromLocal( '/src/a1' ) }], b : [{ softLink : p.src.globalFromLocal( '/src/b' ) }], c : [{ softLink : p.src.globalFromLocal( '/src/c' ) }], dir : { a2 : '2', a1 : [{ softLink : p.src.globalFromLocal( '/src/dir/a1' ) }], b : [{ softLink : p.src.globalFromLocal( '/src/dir/b' ) }], c : [{ softLink : p.src.globalFromLocal( '/src/dir/c' ) }] }, dirSame : { d : [{ softLink : p.src.globalFromLocal( '/src/dirSame/d' ) }] }, dir1 : { a1 : [{ softLink : p.src.globalFromLocal( '/src/dir1/a1' ) }], b : [{ softLink : p.src.globalFromLocal( '/src/dir1/b' ) }], c : [{ softLink : p.src.globalFromLocal( '/src/dir1/c' ) }] }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : [{ softLink : p.src.globalFromLocal( '/src/srcFile' ) }], dstFile : { f : [{ softLink : p.src.globalFromLocal( '/src/dstFile/f' ) }] } },
      },
    });

    t.identical( p.src.filesTree.src, expected.filesTree.src );
    t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

    var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
    var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
    var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
    var expectedAction = [ 'dirMake', 'softlink', 'softlink', 'softlink', 'softlink', 'dirMake', 'softlink', 'softlink', 'softlink', 'dirMake', 'softlink', 'softlink', 'softlink', 'dirMake', 'dirMake', 'dirMake', 'softlink', 'dirMake', 'softlink' ];
    var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

    var dstAbsolute = context.select( records, '*.dst.absolute' );
    var srcAbsolute = context.select( records, '*.src.absolute' );
    var effAbsolute = context.select( records, '*.effective.absolute' );
    var action = context.select( records, '*.action' );
    var allow = context.select( records, '*.allow' );

    t.identical( dstAbsolute, expectedDstAbsolute );
    t.identical( srcAbsolute, expectedSrcAbsolute );
    t.identical( effAbsolute, expectedEffAbsolute );
    t.identical( action, expectedAction );
    t.identical( allow, expectedAllow );

    t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/a1' ), p.dst.globalFromLocal( '/dst/a1' ) ]), true );
    t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/a2' ), p.dst.globalFromLocal( '/dst/a2' ) ]), false );
    t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/b' ), p.dst.globalFromLocal( '/dst/b' ) ]), true );
    t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/dir/a1' ), p.dst.globalFromLocal( '/dst/dir/a1' ) ]), true );
    t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/dir/a2' ), p.dst.globalFromLocal( '/dst/dir/a2' ) ]), false );
    t.identical( p.hub.filesAreSoftLinked([ p.src.globalFromLocal( '/src/dir/b' ), p.dst.globalFromLocal( '/dst/dir/b' ) ]), true );

  }
  // // else
  // {
  //
  //   // t.shouldThrowErrorSync( function()
  //   // {
  //   //   var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  //   // });
  //
  // }

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 0,
    preservingTime : 0,
  }

  t.case = 'complex move with dstRewriting:0, includingNonAllowed:0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with dstRewriting:0, includingNonAllowed:1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();

  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 0,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with writing : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();

  var o1 = optionsMake();
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with writing : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', dir : { a2 : '2' }, dirSame : {}, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : {} },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'nop', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake', 'nop', 'dirMake', 'nop' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 0,
  }

  t.case = 'complex move with writing : 1, dstRewriting : 0, includingNonAllowed : 0, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedAction = [ 'dirMake', 'nop', 'dirMake', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 1,
  }

  t.case = 'complex move with writing : 1, dstRewriting : 0, includingNonAllowed : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  var expectedAction = [ 'dirMake', 'nop', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake', 'nop', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    preservingSame : 1,
  }

  t.case = 'complex move with preservingSame : 1, linking : fileCopy\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, true, false, false, true, false, true, false, false, false, false, false, true, false, true, true, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with srcDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var srcActions = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( srcActions, expectedSrcActions );
  t.identical( srcAllow, expectedSrcAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with srcDeleting : 1, dstRewriting : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', null, null, null, 'fileDelete', 'fileDelete', null, null, 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, false, true, true, true, true, true, true, true, true, true, false, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var srcActions = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( srcActions, expectedSrcActions );
  t.identical( srcAllow, expectedSrcAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 0,
  }

  t.case = 'complex move with srcDeleting : 1, dstRewriting : 0, includingNonAllowed : 0\n' + _.toStr( o2 );

  debugger;
  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ false, true, false, true, true, true, true, true, true, true, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var srcActions = context.select( records, '*.srcAction' );
  var srcAllow = context.select( records, '*.srcAllow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( srcActions, expectedSrcActions );
  t.identical( srcAllow, expectedSrcAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'complex move with dstDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/dst/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/dst/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 0,
  }

  t.case = 'complex move with dstDeleting : 1, dstRewriting : 0, srcDeleting : 1, includingNonAllowed : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst :
      {
        b : '1', c : '2', dirSame : { d : '1' }, dstFile : '1', srcFile : { f : '2' },
        dir : { b : '1', c : '2', a1 : '1' },
        dir3 : {},
        a1 : '1',
        dir1 : { a1 : '1', b : '1', c : '1' },
        dir4 : {},
      },
    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/dst/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, true, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir' : [ '/dst', '/dstNew' ],
    '/src/dirSame' : [ '/dst', '/dstNew' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

      dstNew :
      {
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  t.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst', '/dst/d', '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];
  var expectedEffAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, true, false, false, false, false, false, true, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**' : '/dstNew',
    '/src/dirSame/**' : '/dstNew',
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dstNew :
      {
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];
  var expectedEffAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, true, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

      dstNew :
      {
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  t.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d', '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];
  var expectedEffAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**b**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**d**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        // a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        // dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        // dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        // /**/
        b : '1',
        d : '1',
      },

      dstNew :
      {
        b : '1',
        d : '1',
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  t.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/b', '/dstNew', '/dstNew/d', '/dst', '/dst/b', '/dst/a2', '/dst/dir', '/dst/dir/a2', '/dst/dir/b', '/dst/dir/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir5', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/srcFile', '/dst/srcFile/f', '/dst', '/dst/d', '/dst/c' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dir/a2', '/src/dir/dir', '/src/dir/dir/a2', '/src/dir/dir/b', '/src/dir/dir/c', '/src/dir/dir2', '/src/dir/dir2/a2', '/src/dir/dir2/b', '/src/dir/dir2/c', '/src/dir/dir3', '/src/dir/dir5', '/src/dir/dirSame', '/src/dir/dirSame/d', '/src/dir/dstFile', '/src/dir/srcFile', '/src/dir/srcFile/f', '/src/dirSame', '/src/dirSame/d', '/src/dirSame/c' ];
  var expectedEffAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/dst/a2', '/dst/dir', '/dst/dir/a2', '/dst/dir/b', '/dst/dir/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir5', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/srcFile', '/dst/srcFile/f', '/src/dirSame', '/src/dirSame/d', '/dst/c' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'dirMake', 'fileCopy', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**b**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**d**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        b : '1',
        d : '1',
      },

      dstNew :
      {
        b : '1',
        d : '1',
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  t.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/b', '/dstNew', '/dstNew/d', '/dst', '/dst/b', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d' ];
  var expectedEffAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, true, false, true, false, true, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

/*
dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
*/

  /* xxx */

  // var p = o.prepare();
  // var o1 = optionsMake();
//   o1.reflectMap =
//   {
//     '/src/*()dir/**b**' : [ '/dstNew', '/dst' ],
//     '/src/dirSame/**d**' : [ '/dstNew', '/dst' ],
//   },
  //
  // var o2 =
  // {
  //   linking : 'fileCopy',
  //   srcDeleting : 0,
  //   dstDeleting : 0,
  //   writing : 1,
  //   dstRewriting : 1,
  //   dstRewritingByDistinct : 1,
  //   preservingTime : 0,
  // }
  //
  // t.case = 'base marker *()\n' + _.toStr( o2 );
  //
  // var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  //
  // var expected = _.FileProvider.Extract
  // ({
  //   filesTree :
  //   {
  //
  //     src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
  //
  //     dst :
  //     {
  //       a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
  //       dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
  //       dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
  //       /**/
  //       b : '1',
  //       d : '1',
  //     },
  //
  //     dstNew :
  //     {
  //       b : '1',
  //       d : '1',
  //     },
  //
  //   },
  // });
  //
  // t.identical( p.src.filesTree.src, expected.filesTree.src );
  // t.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  // t.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );
  //                           // [ '/dstNew/dir/b', '/dstNew/dirSame/d', '/dst/dir/b', '/dst/dirSame/d' ]
  // var expectedDstAbsolute = [ '/dstNew/b', '/dstNew/d', '/dst/b', '/dst/d' ];
  // var expectedSrcAbsolute = [ '/src/dir/b', '/src/dirSame/d', '/src/dir/b', '/src/dirSame/d' ];
  // var expectedEffAbsolute = [ '/src/dir/b', '/src/dirSame/d', '/src/dir/b', '/src/dirSame/d' ];
  // var expectedAction = [];
  // var expectedAllow = [];
  //
  // var dstAbsolute = context.select( records, '*.dst.absolute' );
  // var srcAbsolute = context.select( records, '*.src.absolute' );
  // var effAbsolute = context.select( records, '*.effective.absolute' );
  // var action = context.select( records, '*.action' );
  // var allow = context.select( records, '*.allow' );
  //
  // // t.identical( dstAbsolute, expectedDstAbsolute );
  // t.identical( srcAbsolute, expectedSrcAbsolute );
  // t.identical( effAbsolute, expectedEffAbsolute );
  // t.identical( action, expectedAction );
  // t.identical( allow, expectedAllow );

} /* eof _filesReflect */

//

function filesReflectGrab( t )
{
  var context = this;

  /* */

  t.case = 'nothing to grab + prefix';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();
  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/dir**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  var expectedDstAbsolute = [ '/' ];
  var expectedSrcAbsolute = [ '/' ];
  var expectedEffAbsolute = [ '/' ];
  var expectedAction = [ 'dirMake' ];
  var expectedAllow = [ true ];
  var expectedPreserve = [ true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'nothing to grab + dst';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();
  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/dir**' : '/',
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src },
    dstFilter : { hubFileProvider : dst },
  });

  var expectedDstAbsolute = [ '/' ];
  var expectedSrcAbsolute = [ '/' ];
  var expectedEffAbsolute = [ '/' ];
  var expectedAction = [ 'dirMake' ];
  var expectedAllow = [ true ];
  var expectedPreserve = [ true ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'trivial + src.basePath';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/src1/d**' : true,
    '/src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src, basePath : '/' },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  var expectedDstAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'trivial + not defined src.basePath';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/src1/d**' : true,
    '/src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  var expectedDstAbsolute = [ '/', '/d', '/d/a', '/d/b', '/d/c', '/', '/a', '/b', '/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, true, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'trivial + URIs';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    'extract+src:///src1/d**' : true,
    'extract+src:///src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { basePath : '/' },
    dstFilter : { prefixPath : 'extract+dst:///' },
  });

  var expectedDstAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'negative + src basePath';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/src1/d**' : true,
    '/src2/d/**' : true,
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src, basePath : '/' },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  var expectedDstAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'negative + dst';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/src1/d**' : '/src1x/',
    '/src2/d/**' : '/src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  var expectedDstAbsolute = [ '/src1x', '/src1x/d', '/src1x/d/a', '/src1x/d/c', '/src2x', '/src2x/a', '/src2x/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'negative + dst + src base path';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/src1/d**' : '/src1x/',
    '/src2/d/**' : '/src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src, basePath : '/' },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  var expectedDstAbsolute = [ '/src1x/src1', '/src1x/src1/d', '/src1x/src1/d/a', '/src1x/src1/d/c', '/src2x/src2/d', '/src2x/src2/d/a', '/src2x/src2/d/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

  /* */

  t.case = 'negative + dst + uri';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    'extract+src:///src1/d**' : 'extract+dst:///src1x/',
    'extract+src:///src2/d/**' : 'extract+dst:///src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
  });

  var expectedDstAbsolute = [ '/src1x', '/src1x/d', '/src1x/d/a', '/src1x/d/c', '/src2x', '/src2x/a', '/src2x/c' ];
  var expectedSrcAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );
  var action = context.select( records, '*.action' );
  var allow = context.select( records, '*.allow' );
  var preserve = context.select( records, '*.preserve' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );
  t.identical( action, expectedAction );
  t.identical( allow, expectedAllow );
  t.identical( preserve, expectedPreserve );

}


//

function filesReflector( t )
{
  var context = this;

  /* */

  t.case = 'setup';

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    reflectMap : recipe,
    srcFilter : { hubFileProvider : src /*, basePath : '/'*/ },
    dstFilter : { hubFileProvider : dst, prefixPath : '/' },
  });

  t.case = 'negative + dst + src base path';

  var recipe =
  {
    '/src1/d**' : '/src1x/',
    '/src2/d/**' : '/src2x/',
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
  });

  var expectedDstAbsolute = [ '/src1x', '/src1x/d', '/src1x/d/a', '/src1x/d/c', '/src2x', '/src2x/a', '/src2x/c' ];
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );

  /* */

  t.case = 'negative + dst';

  var recipe =
  {
    '/src1/d**' : '/src1x/',
    '/src2/d/**' : '/src2x/',
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
    srcFilter : { basePath : null },
  });

  var expectedDstAbsolute = [ '/src1x', '/src1x/d', '/src1x/d/a', '/src1x/d/c', '/src2x', '/src2x/a', '/src2x/c' ];
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );

  t.case = 'negative';

  var recipe =
  {
    '/src1/d**' : true,
    '/src2/d/**' : true,
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
    srcFilter : { basePath : null },
  });

  var expectedDstAbsolute = [ '/', '/d', '/d/a', '/d/c', '/', '/a', '/c' ];
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];
  var expectedEffAbsolute = [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = context.select( records, '*.dst.absolute' );
  var srcAbsolute = context.select( records, '*.src.absolute' );
  var effAbsolute = context.select( records, '*.effective.absolute' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );

  /**/

  t.open( 'reflect current dir' );

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : {},
    dstFilter : {},
  });
  t.shouldThrowError( () => reflect( '.' ) );
  t.identical( dst.filesTree, {} )

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { basePath : 'src:///' },
    dstFilter : { basePath : 'dst:///' },
  });
  t.shouldThrowError( () => reflect( '.' ) );
  t.identical( dst.filesTree, {} )

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { prefixPath : 'src:///' },
    dstFilter : { prefixPath : 'dst:///' },
  });
  reflect( '.' );
  t.identical( dst.filesTree, src.filesTree );

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { prefixPath : 'src:///', basePath : 'src:///' },
    dstFilter : { prefixPath : 'dst:///', basePath : 'dst:///' },
  });
  reflect( '/alt/a' );
  t.identical( dst.filesTree, { alt : { a : '/alt/a' } } );

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { prefixPath : 'src:///', basePath : 'src:///' },
    dstFilter : { prefixPath : 'dst:///', basePath : 'dst:///' },
  });
  reflect( '/alt/alt' );
  t.identical( dst.filesTree, {} );

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { prefixPath : 'src:///', basePath : 'src:///a/b' },
    dstFilter : { prefixPath : 'dst:///', basePath : 'dst:///' },
  });
  t.shouldThrowError( () => reflect( 'alt' ) )
  t.identical( dst.filesTree, {} );

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { prefixPath : 'src:///', basePath : 'src:///' },
    dstFilter : { prefixPath : 'dst:///', basePath : 'dst:///a/b' },
  });
  reflect( 'alt/a' )
  t.identical( dst.filesTree.a.b, { alt : { a : '/alt/a' } } );

  //

  var dst = _.FileProvider.Extract({ originPath : 'dst://' });
  var src = context.makeStandardExtract({ originPath : 'src://' });
  var hub = new _.FileProvider.Hub({ providers : [ dst, src ] });

  var reflect = hub.filesReflector
  ({
    srcFilter : { prefixPath : 'src:///', basePath : 'src:///' },
    dstFilter : { prefixPath : 'dst:///', basePath : 'dst:///' },
    linking : 'softLink',
    mandatory : 1,
  });
  reflect( 'alt/a' )
  t.identical( dst.filesTree, { alt : { a : [{ softLink : 'src:///alt/a' }] } } );

  t.close( 'reflect current dir' );
}

//

function filesReflectWithHub( test )
{
  var context = this;
  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  var srcProvider = _.FileProvider.Extract({ filesTree : filesTree, protocols : [ 'extract' ] });
  var dstProvider = new _.FileProvider.HardDrive();
  var srcPath = '/src';
  var dstPath = _.path.join( context.testRootDirectory, test.name, 'dst' );
  var hub = new _.FileProvider.Hub({ empty : 1 });
  hub.providerRegister( srcProvider );
  hub.providerRegister( dstProvider );

  /* */

  // test.case = 'filesReflect: copy files from Extract to HardDrive, using absolute paths'
  // dstProvider.filesDelete( dstPath );
  // var o1 = { reflectMap : { [ srcPath ] : dstPath }, srcProvider : srcProvider, dstProvider : dstProvider };
  // var o2 =
  // {
  //   linking : 'fileCopy',
  //   srcDeleting : 0,
  //   dstDeleting : 1,
  //   writing : 1,
  //   dstRewriting : 1
  // }
  //
  // var records = hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  // test.is( records.length >= 0 );
  //
  // var got = _.FileProvider.Extract.filesTreeRead({ srcPath : dstPath, srcProvider : dstProvider });
  // test.identical( got, context.select( filesTree, srcPath ) )

  /* */

  test.case = 'filesReflect: copy files from Extract to HardDrive, using global uris'
  dstProvider.filesDelete( dstPath );
  var srcUrl = srcProvider.globalFromLocal( srcPath );
  var dstUrl = dstProvider.globalFromLocal( dstPath );
  var o1 = { reflectMap : { [ srcUrl ] : dstUrl } /*, srcProvider : srcProvider, dstProvider : dstProvider*/ };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  // debugger;
  var records = hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  test.is( records.length >= 0 );

  var got = _.FileProvider.Extract.filesTreeRead({ srcPath : dstPath, srcProvider : dstProvider });
  debugger;
  test.identical( got, context.select( filesTree, '/src' ) )
  debugger;
}

//

function filesReflectWithPrefix( t )
{
  var c = this;

  t.case = 'both prefixes defined, relative dst';

  var tree =
  {
    src : { srcDir : { a : 'dst/a', b : 'dst/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', b : 'dst/b' } },
  }

  var o =
  {
    reflectMap :
    {
      '/src/srcDir' : '.',
    },
    srcFilter :
    {
      prefixPath : '/src/srcDir2',
    },
    dstFilter :
    {
      prefixPath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  debugger;
  var records = provider.filesReflect( o );
  debugger;

  var expectedTree =
  {
    src : { srcDir : { a : 'dst/a', b : 'dst/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', b : 'dst/b' }, dstDir2 : { a : 'dst/a', b : 'dst/b' } },
  }
  t.identical( provider.filesTree, expectedTree );

  debugger;

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];
  var expectedEffAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];

  var dstAbsolute = c.select( records, '*.dst.absolute' );
  var srcAbsolute = c.select( records, '*.src.absolute' );
  var effAbsolute = c.select( records, '*.effective.absolute' );

  t.identical( dstAbsolute, expectedDstAbsolute );
  t.identical( srcAbsolute, expectedSrcAbsolute );
  t.identical( effAbsolute, expectedEffAbsolute );

  debugger;

}

//

function filesReflectDstPreserving( test )
{
  var context = this;
  var filesTree =
  {
    src :
    {
      'file' : 'file',
      'file-d' : 'file-diff-content',
      'dir-e' : { 'dir-e' : {} },
      'dir-t' : { 'file' : 'file', 'dir-t' : { 'file' : 'file' } },
      'dir-t-inner' : { 'dir-t' : { 'file' : 'file' } },
      'dir-d' : { 'file-d' : 'file-diff-content' },
      'dir-s' : { 'file' : 'file' },
    },
    dst :
    {
      'file' : 'file',
      'file-d' : 'file-diff-content',
      'dir-e' : { 'dir-e' : {} },
      'dir-t' : { 'file' : 'file', 'dir-t' : { 'file' : 'file' } },
      'dir-t-inner' : { 'dir-t' : { 'file' : 'file' } },
      'dir-d' : { 'file-d' : 'file-content-diff' },
      'dir-s' : { 'file' : 'file' },
    }
  }

  /* */

  test.case = 'terminal - terminal, same content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/file' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - terminal, same content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/file' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );


  test.case = 'terminal - terminal, diff content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file-d' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file-d' );
  var dst = extract.fileRead( '/dst/file' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file-d' ) );

  test.case = 'terminal - terminal, diff content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file-d' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file-d' );
  var dst = extract.fileRead( '/dst/file' );
  test.notIdentical( src, dst );

  /* */

  test.case = 'terminal - empty dir, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e/dir-e' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir without terminals, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - empty dir, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e/dir-e' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir without terminals, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-t' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-t' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals inner level, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-t-inner' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-t-inner' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-t' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/file' ) );
  test.is( extract.isDir( '/dst/dir-t' ) );
  test.identical( context.select( extract.filesTree, '/src/file' ), context.select( filesTree, '/src/file' ) );
  test.identical( context.select( extract.filesTree, '/dst/dir-t' ), context.select( filesTree, '/dst/dir-t' ) );

  test.case = 'terminal - dir with terminals inner level, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-t-inner' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/file' ) );
  test.is( extract.isDir( '/dst/dir-t-inner' ) );
  test.identical( context.select( extract.filesTree, '/src/file' ), context.select( filesTree, '/src/file' ) );
  test.identical( context.select( extract.filesTree, '/dst/dir-t-inner' ), context.select( filesTree, '/dst/dir-t-inner' ) );

  /* */

  test.case = 'dir empty - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e/dir-e' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-e/dir-e' ), context.select( filesTree, '/src/dir-e/dir-e' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-e/dir-e' ), context.select( extract.filesTree, '/dst/file' ) );

  test.case = 'dir empty - terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e/dir-e' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-e/dir-e' ), context.select( filesTree, '/src/dir-e/dir-e' ) );
  test.identical( context.select( extract.filesTree, '/dst/file' ), context.select( filesTree, '/dst/file' ) );

  test.case = 'dir without terminal - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-e' ), context.select( filesTree, '/src/dir-e' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-e' ), context.select( extract.filesTree, '/dst/file' ) );

  test.case = 'dir without terminal - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-e' ), context.select( filesTree, '/src/dir-e' ) );
  test.identical( context.select( extract.filesTree, '/dst/file' ), context.select( filesTree, '/dst/file' ) );

  test.case = 'dir with files - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-t' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-t' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-t' ), context.select( filesTree, '/src/dir-t' ) );
  test.identical( context.select( extract.filesTree, '/dst/file' ), context.select( extract.filesTree, '/src/dir-t' ) );

  test.case = 'dir with files - terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-t' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-t' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-t' ), context.select( filesTree, '/src/dir-t' ) );
  test.identical( context.select( extract.filesTree, '/dst/file' ), context.select( filesTree, '/dst/file' ) );

  /**/

  test.case = 'reflect dir - dir, both with same terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-s' : '/dst/dir-s' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-s' ), context.select( extract.filesTree, '/dst/dir-s' ) );

  test.case = 'reflect dir - dir, both with same terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-s' : '/dst/dir-s' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-s' ), context.select( extract.filesTree, '/dst/dir-s' ) );

  test.case = 'reflect dir - dir, both have terminal with diff content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-d' : '/dst/dir-d' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-s' ), context.select( extract.filesTree, '/dst/dir-s' ) );

  test.case = 'reflect dir - dir, both have terminal with diff content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-d' : '/dst/dir-d' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-d/file-d' ), context.select( filesTree, '/src/dir-d/file-d' ) );
  test.identical( context.select( extract.filesTree, '/dst/dir-d/file-d' ), context.select( filesTree, '/dst/dir-d/file-d' ) );
}

//

function filesReflectDstDeletingDirs( test )
{
  var self = this;

  /* */

  test.case = 'dst/dir is actual, will be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir is actual, will be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir is excluded, will not be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir is excluded, will not be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, not actual, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, actual, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { includeAny : [ 'file', 'dir' ] } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, not actual, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, actual, dstDeletingCleanedDirs : 0 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { includeAny : [ 'file', 'dir' ] } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
   test.identical( extract.filesTree, expected );

  //

  test.case = 'file included, parent dir excluded, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { includeAny : 'file', excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'file included, parent dir excluded, dstDeletingCleanedDirs : 0 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { includeAny : 'file', excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'cleaned dir have files, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { includeAny : 'file1' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file2 : 'file2' } }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'cleaned dir have files, dstDeletingCleanedDirs : 0 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { includeAny : 'file1' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file2 : 'file2' } }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, dstDeletingCleanedDirs : 1';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, dstDeletingCleanedDirs : 1';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dstFilter : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : { dir : {} },
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dstFilter : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : { dir : {} },
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, srcDeleting : 1, dstDeletingCleanedDirs : 1';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    srcDeleting : 1,
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, srcDeleting : 1, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    srcDeleting : 1,
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );
}

//

function filesReflectLinked( test )
{
  let self = this;
  let workDir = test.context.pathFor( test.name );
  let provider = self.provider;
  let path = self.provider.path;

  var srcDir = path.join( workDir, 'src' );
  var dstDir = path.join( workDir, 'dst' );

  logger.log( 'workDir', workDir );

  provider.filesDelete( workDir );

  provider.dirMake( srcDir );

  provider.fileWrite( path.join( srcDir, 'file' ), 'file' );

  provider.softLink
  ({
    srcPath : path.join( srcDir, 'fileNotExists' ),
    dstPath : path.join( srcDir, 'link' ),
    allowingMissed : 1,
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissed : 1,
  });

  test.is( provider.fileExists( path.join( dstDir, 'file' ) ) )
  test.is( !provider.fileExists( path.join( dstDir, 'link' ) ) )

  /**/

  provider.filesDelete( workDir );

  provider.dirMake( srcDir );
  provider.dirMake( dstDir );

  provider.fileWrite( path.join( srcDir, 'link' ), 'file' );

  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissed : 1
  });

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissed : 1,
  });

  /*
    !!! qqq : dstDir/link should be link and dstDir/fileNotExists should exists if resolvingDstSoftLink : 1
    but resolvingDstSoftLink is 0 by default
    so resolvingDstSoftLink option is NOT COVERED by tests at all!

    seems File.copyFileSync works if resolvingDstSoftLink is always 1
  */

  test.is( !provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  test.identical( provider.fileRead( path.join( dstDir, 'link' ) ), 'file' );

  /* */

  test.case = 'src - link to missing, dst - link to missing'
  provider.filesDelete( workDir );
  provider.softLink
  ({
    srcPath : path.join( srcDir, 'fileNotExists' ),
    dstPath : path.join( srcDir, 'link' ),
    allowingMissed : 1,
    makingDirectory : 1
  })
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissed : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  var dstLink1 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink1, path.join( dstDir, 'fileNotExists' ) );

  /* */

  test.case = 'src - link to missing, dst - link to terminal'
  provider.filesDelete( workDir );
  provider.softLink
  ({
    srcPath : path.join( srcDir, 'fileNotExists' ),
    dstPath : path.join( srcDir, 'link' ),
    allowingMissed : 1,
    makingDirectory : 1
  })
  provider.fileWrite( path.join( dstDir, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'file' ),
    dstPath : path.join( dstDir, 'link' ),
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissed : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  var dstLink1 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink1, path.join( dstDir, 'file' ) );

  /* */

  test.case = 'src - link to terminal, dst - link to missing'
  provider.filesDelete( workDir );
  provider.fileWrite( path.join( srcDir, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( srcDir, 'file' ),
    dstPath : path.join( srcDir, 'link' ),
    makingDirectory : 1
  })
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissed : 1,
  })

  test.will = 'dstDir/link should be rewritten by srcDir/link'
  test.is( !provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  test.is( provider.isTerminal( path.join( dstDir, 'link' ) ) );
  var read = provider.fileRead({ filePath : path.join( dstDir, 'link' ) });
  test.identical( read, 'file' );

  /* */

  test.case = 'src - no files, dst - link to missing'
  provider.filesDelete( workDir );
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissed : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  var dstLink4 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink4, path.join( dstDir, 'fileNotExists' ) );

  //

  // /* old test case */

  // provider.filesDelete( workDir );

  // provider.dirMake( srcDir );
  // provider.dirMake( dstDir );

  // provider.fileWrite( path.join( srcDir, 'file' ), 'file' );
  // provider.fileWrite( path.join( dstDir, 'file' ), 'file' );

  // provider.softLink
  // ({
  //   srcPath : path.join( srcDir, 'fileNotExists' ),
  //   dstPath : path.join( srcDir, 'link' ),
  //   allowingMissed : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( srcDir, 'fileNotExists' ),
  //   dstPath : path.join( srcDir, 'link2' ),
  //   allowingMissed : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( srcDir, 'file' ),
  //   dstPath : path.join( srcDir, 'link3' ),
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'fileNotExists' ),
  //   dstPath : path.join( dstDir, 'link' ),
  //   allowingMissed : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'file' ),
  //   dstPath : path.join( dstDir, 'link2' ),
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'fileNotExists' ),
  //   dstPath : path.join( dstDir, 'link3' ),
  //   allowingMissed : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'fileNotExists' ),
  //   dstPath : path.join( dstDir, 'link4' ),
  //   allowingMissed : 1
  // })

  // provider.filesReflect
  // ({
  //   reflectMap : { [ srcDir ] : dstDir },
  //   allowingMissed : 1,
  // })

  // test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  // var dstLink1 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  // test.identical( dstLink1, path.join( dstDir, 'fileNotExists' ) );

  // test.is( provider.isSoftLink( path.join( dstDir, 'link2' ) ) );
  // var dstLink2 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link2' )/*, readLink : 1*/ });
  // test.identical( dstLink2, path.join( dstDir, 'file' ) );

  // test.is( !provider.isSoftLink( path.join( dstDir, 'link3' ) ) );
  // var read = provider.fileRead({ filePath : path.join( dstDir, 'link3' ) });
  // test.identical( read, 'file' );

  // test.is( provider.isSoftLink( path.join( dstDir, 'link4' ) ) );
  // var dstLink4 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link4' )/*, readLink : 1*/ });
  // test.identical( dstLink4, path.join( dstDir, 'fileNotExists' ) );

  xxx

}

//

function filesDelete( test )
{
  var context = this;
  var symlinkIsAllowed = context.symlinkIsAllowed();
  var testDir = _.path.join( context.testRootDirectory, test.name );
  var filePath = _.path.join( testDir, 'file' );
  var dirPath = _.path.join( testDir, 'dir' );

  test.case = 'delete terminal file';
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.filesDelete( filePath );
  debugger;
  var stat = _.fileProvider.statResolvedRead( filePath );
  debugger;
  test.identical( stat, null );

  test.case = 'delete empty dir';
  _.fileProvider.dirMake( dirPath );
  _.fileProvider.filesDelete( dirPath );
  var stat = _.fileProvider.statResolvedRead( dirPath );
  test.identical( stat, null );

  test.case = 'delete hard link';
  _.fileProvider.filesDelete( testDir );
  var dst = _.path.join( testDir, 'link' );
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.hardLink( dst, filePath );
  _.fileProvider.filesDelete( dst );
  var stat = _.fileProvider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = _.fileProvider.statResolvedRead( filePath );
  test.is( !!stat );

  test.case = 'delete tree';
  var tree =
  {
    'src' :
    {
      'a.a' : 'a',
      'b1.b' : 'b1',
      'b2.b' : 'b2x',
      'c' :
      {
        'b3.b' : 'b3x',
        'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
        'srcfile' : 'srcfile',
        'srcdir' : {},
        'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
        'srcfile-dstdir' : 'x',
      }
    }
  }

  _.fileProvider.filesDelete( testDir );
  // _.fileProvider.filesTreeWrite
  _.FileProvider.Extract.readToProvider
  ({
    dstProvider : _.fileProvider,
    dstPath : testDir,
    filesTree : tree,
    allowWrite : 1,
    allowDelete : 1,
    sameTime : 1,
  });

  _.fileProvider.filesDelete( testDir );
  var stat = _.fileProvider.statResolvedRead( testDir );
  test.identical( stat, null );

  //

  if( !symlinkIsAllowed )
  return;

  test.case = 'delete soft link, resolvingSoftLink 1';
  _.fileProvider.fieldPush( 'resolvingSoftLink', 1 );
  var dst = _.path.join( testDir, 'link' );
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.softLink( dst, filePath );
  _.fileProvider.filesDelete( dst )
  var stat = _.fileProvider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = _.fileProvider.statResolvedRead( filePath );
  test.is( !!stat );
  _.fileProvider.fieldPop( 'resolvingSoftLink', 1 );

  test.case = 'delete soft link, resolvingSoftLink 0';
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.fieldPush( 'resolvingSoftLink', 0 );
  var dst = _.path.join( testDir, 'link' );
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.softLink( dst, filePath );
  _.fileProvider.filesDelete( dst )
  var stat = _.fileProvider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = _.fileProvider.statResolvedRead( filePath );
  test.is( !!stat );
  _.fileProvider.fieldPop( 'resolvingSoftLink', 0 );
}

//

function filesDeleteEmptyDirs( test )
{
  var tree =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    }
  }

  //

  test.case = 'defaults'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.filesDeleteEmptyDirs( '/' );
  var expected =
  {
    file : 'file',
    dir :
    {
      file : 'file',
      dir :
      {
        file : 'file',
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'not recursive'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.filesDeleteEmptyDirs({ filePath : '/', recursive : '1' });
  var expected =
  {
    file : 'file',
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'filter'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var filter = { maskDirectory : /empty2$/ };
  provider.filesDeleteEmptyDirs({ filePath : '/', filter : filter });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'filter for not existing dir'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var filter = { maskDirectory : 'emptyDir' };
  provider.filesDeleteEmptyDirs({ filePath : '/', filter : filter });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'filter for terminals'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var filter = { maskTerminal : 'file' };
  provider.filesDeleteEmptyDirs({ filePath : '/', filter : filter });
  var expected =
  {
    file : 'file',
    dir :
    {
      file : 'file',
      dir :
      {
        file : 'file',
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'glob for dir'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.filesDeleteEmptyDirs({ filePath : '/**/empty3' });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'glob for terminals'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.filesDeleteEmptyDirs({ filePath : '/**/file' });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'glob not existing file'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.filesDeleteEmptyDirs({ filePath : '/**/emptyDir' });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    }
  }
  test.identical( provider.filesTree, expected );

  //

  test.case = 'resolvingSoftLink : 1'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.softLink( '/dstDir', '/dir' )
  provider.filesDeleteEmptyDirs({ filePath : '/dstDir', resolvingSoftLink : 1  });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    },
    dstDir : [{ softLink : '/dir'}]
  }
  test.identical( provider.filesTree, expected );

  test.case = 'resolvingSoftLink : 0'
  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  provider.softLink( '/dstDir', '/dir' )
  provider.filesDeleteEmptyDirs({ filePath : '/dstDir', resolvingSoftLink : 0  });
  var expected =
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      empty2 : {},
      dir :
      {
        file : 'file',
        empty3 : {},
      }
    },
    dstDir : [{ softLink : '/dir'}]
  }
  test.identical( provider.filesTree, expected );

  //

  if( !Config.debug )
  {
    test.case = 'including of terminals is not allow';
    test.shouldThrowError( () => provider.filesDeleteEmptyDirs({ filePath : '/', includingTerminals : 1 }) )

    test.case = 'including of transients is not allow';
    test.shouldThrowError( () => provider.filesDeleteEmptyDirs({ filePath : '/', includingTransient : 1 }) )
  }
}

//

function filesDeleteAndAsyncWrite( test )
{

  test.case = 'try to delete dir before async write will be completed';

  var testDir = _.path.join( context.testRootDirectory, test.name );


  var cons = [];

  for( var i = 0; i < 10; i++ )
  {
    var filePath = _.path.join( testDir, 'file' + i );
    var con = _.fileProvider.fileWrite({ filePath : filePath, data : filePath, sync : 0 });
    cons.push( con );
  }

  _.timeOut( 2, () =>
  {
    test.shouldThrowError( () =>
    {
      _.fileProvider.filesDelete( testDir );
    });
  });

  var mainCon = new _.Consequence().give( null );
  mainCon.andThen( cons );
  mainCon.doThen( () =>
  {
    test.mustNotThrowError( () =>
    {
      _.fileProvider.filesDelete( testDir );
    });

    var files = _.fileProvider.dirRead( testDir );
    test.identical( files, null );
  })
  return mainCon;
}

//

function filesFindDifference( test )
{
  var self = this;

  /* zzz Needs repair. Files tree is written with "sameTime" option enabled, but files are not having same timestamps anyway,
     probably problem is in method used by HardDrive.fileTimeSetAct
  */

  var testRoutineDir = _.path.join( context.testRootDirectory, test.name );

  var samples =
  [

    //

    {
      name : 'simple1',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
      },
      expected :
      [
        { src : { relative : '.' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './a.a' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './b1.b' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './b2.b' }, /*same : undefined, del : undefined*/ },
      ],
    },

    //

    {
      name : 'file-file-same',
      filesTree :
      {
        initial :
        {
          'src' : 'text',
          'dst' : 'text',
        },
      },
      expected :
      [
        { src : { relative : '.' }, same : true/* , del : undefined */ },
      ],
    },

    //

    {
      name : 'file-file-different',
      filesTree :
      {
        initial :
        {
          'src' : 'text1',
          'dst' : 'text2',
        },
      },
      expected :
      [
        { src : { relative : '.' }, same : false/* , del : undefined */ },
      ],
    },

    //

    {
      name : 'file-dir',
      filesTree :
      {
        initial :
        {
          'src' : 'text1',
          'dst' : { 'd2.d' : 'd2', 'e1.e' : 'e1' },
        },
      },
      expected :
      [
        { src : { relative : './d2.d' }, /* same : undefined, */ del : true },
        { src : { relative : './e1.e' }, /* same : undefined, */ del : true },
        { src : { relative : '.' }, same : false, /* del : undefined */ },
      ],
    },

    //

    {
      name : 'dir-file',
      filesTree :
      {
        initial :
        {
          'src' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
          'dst' : 'text1',
        },
      },
      expected :
      [
        { src : { relative : '.' }, same : false, /* del : undefined */ },
        { src : { relative : './d2.d' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './e1.e' }, /*same : undefined, del : undefined*/ },
      ],
    },

    //

    {
      name : 'not-same',
      filesTree :
      {

        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
            },
          },
          'dst' :
          {
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
            },
          },
        },

      },
      expected :
      [
        { src : { relative : '.' }, /*same : undefined, del : undefined, */ newer :null, older : null },
        { src : { relative : './a.a' }, /*same : undefined, del : undefined, */ newer :  { side : 'src' }, older : null },
        { src : { relative : './b1.b' }, same : true, /* del : undefined, */ newer : null, older : null   },
        { src : { relative : './b2.b' }, same : false, /*  del : undefined, */ newer : null, older : null   },
        { src : { relative : './c' }, /*same : undefined, del : undefined, */ newer : null, older : null   },
        { src : { relative : './c/d1.d' }, /* same : undefined, */ del : true, newer : { side : 'dst' }, older : null },
        { src : { relative : './c/b3.b' }, same : false, /* del : undefined, */ newer : null, older : null   },
      ],
    },

    //

    {
      name : 'levels-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { relative : './a.a', /*same : undefined, del : undefined*/ },
        { relative : './b1.b', /*same : undefined, del : undefined*/ },
        { relative : './b2.b', /*same : undefined, del : undefined*/ },
        { relative : './c', /*same : undefined, del : undefined*/ },
        { relative : './c/b3.b', /*same : undefined, del : undefined*/ },
        { relative : './c/d1.d', /*same : undefined, del : undefined*/ },
      ],
    },

    //

    {
      name : 'same-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { src : { relative : './a.a' }, /* del : undefined */ },
        { src : { relative : './b1.b' }, /* del : undefined */ },
        { src : { relative : './b2.b' }, /* del : undefined */ },
        { src : { relative : './c' }, /* del : undefined */ },
        { src : { relative : './c/b3.b' }, /* del : undefined */ },
        { src : { relative : './c/d1.d' }, /* del : undefined */ },
      ],
    },

    //

    {
      name : 'lacking-files-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'd1.d' : 'd1',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { src : { relative : './a.a' }, del : true },
        { src : { relative : './b1.b' }, /* del : undefined */ },
        { src : { relative : './b2.b' }, /* del : undefined */ },
        { src : { relative : './c' }, /* del : undefined */ },
        { src : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, /* del : undefined */ },
      ],
    },

    //

    {
      name : 'lacking-dir-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { src : { relative : './c' }, del : true },
        { src : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, del : true },
        { src : { relative : './c/e' }, del : true },
        { src : { relative : './c/e/d2.d' }, del : true },
        { src : { relative : './c/e/e1.e' }, del : true },

        { src : { relative : './a.a' }, /* del : undefined */ },
        { src : { relative : './b1.b' }, /* del : undefined */ },
        { src : { relative : './b2.b' }, /* del : undefined */ },

      ],
    },

    //

    {
      name : 'dir-to-file-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' : 'c',
          },
        },
      },
      expected :
      [

        { relative : '.', /*same : undefined, del : undefined*/ },

        { src : { relative : './a.a' }, same : true },
        { src : { relative : './b1.b' }, same : true },
        { src : { relative : './b2.b' }, same : true },

        { src : { relative : './c' }, /* del : undefined, */ same : false },
        { src : { relative : './c/b3.b' }, /* del : undefined */ },
        { src : { relative : './c/d1.d' }, /* del : undefined */ },
        { src : { relative : './c/e' }, /* del : undefined */ },
        { src : { relative : './c/e/d2.d' }, /* del : undefined */ },
        { src : { relative : './c/e/e1.e' }, /* del : undefined */ },

      ],
    },

    //

    {
      name : 'file-to-dir-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' : 'c',
            'f' : { 'f1' : 'f1' },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',

           'c' :
           {
             'b3.b' : 'b3',
             'd1.d' : 'd1',
             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
           },
          'f' : { 'f1' : { 'f11' : 'f11' } },
          },
        },
      },
      expected :
      [

        { relative : '.', src : { relative : '.' }, dst : { relative : '.' }, /*same : undefined, del : undefined*/ },

        { src : { relative : './c/b3.b' }, dst : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, dst : { relative : './c/d1.d' }, del : true },
        { src : { relative : './c/e' }, dst : { relative : './c/e' }, del : true },
        { src : { relative : './c/e/d2.d' }, dst : { relative : './c/e/d2.d' }, del : true },
        { src : { relative : './c/e/e1.e' }, dst : { relative : './c/e/e1.e' }, del : true },

        { src : { relative : './a.a' }, src : { relative : './a.a' }, same : true },
        { src : { relative : './b1.b' }, src : { relative : './b1.b' }, same : true },
        { src : { relative : './b2.b' }, src : { relative : './b2.b' }, same : true },

        { src : { relative : './c' }, dst : { relative : './c' }, /* del : undefined, */ same : false },

        { src : { relative : './f' }, dst : { relative : './f' }, /* same : undefined */ },
        { src : { relative : './f/f1/f11' }, dst : { relative : './f/f1/f11' }, /* same : undefined, */ del : true },
        { src : { relative : './f/f1' }, dst : { relative : './f/f1' }, same : false },

      ],
    },

    //

    {
      name : 'not-lacking-but-masked-1',
      ends : '.b',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
        },
      },
      expected :
      [

        { relative : '.', newer : null, older : null },
        { relative : './a.a', del : true, newer : null, older : null },
        { relative : './c', del : true, newer : null, older : null },
        { relative : './c/b3.b', del : true, newer : null, older : null },
        { relative : './c/d1.d', del : true, newer : null, older : null },
        { relative : './c/e', del : true, newer : null, older : null },
        { relative : './c/e/d2.d', del : true, newer : null, older : null },
        { relative : './c/e/e1.e', del : true, newer : null, older : null },
        { relative : './b1.b', newer : null, older : null, same : true, link : false },
        { relative : './b2.b', newer : null, older : null, same : true, link : false }
      ],
    },

    //

    {
      name : 'complex-1',

      expected :
      [

        { relative : '.', /*same : undefined, del : undefined, */ older : null, newer : null  },

        { relative : './a.a', same : true, /*  del : undefined, */ older : null, newer : null  },
        { relative : './b1.b', same : true, /* del : undefined, */ older : null, newer : null  },
        { relative : './b2.b', same : false, /* del : undefined, */ older : null, newer : null  },

        { relative : './c', /*same : undefined, del : undefined, */ older : null, newer : null  },

        { relative : './c/dstfile.d', /* same : undefined,  */del : true, older : null, newer : { side : 'dst' } },
        { relative : './c/dstdir', /* same : undefined, */ del : true, older : null, newer : { side : 'dst' }  },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', /* same : undefined, */ del : true, older : null, newer : { side : 'dst' } },

        { relative : './c/b3.b', same : false, /*  del : undefined, */ older : null, newer : null  },

        { relative : './c/srcfile', /*same : undefined, del : undefined, */ older : null, newer : { side : 'src' } },
        { relative : './c/srcfile-dstdir', same : false, /* del : undefined, */ older : null , newer : null },

        { relative : './c/e', /*same : undefined, del : undefined, */ older : null , newer : null },
        { relative : './c/e/d2.d', same : false, /* del : undefined, */ older : null, newer : null  },
        { relative : './c/e/e1.e', same : true, /* del : undefined, */ older : null, newer : null  },

        { relative : './c/srcdir', /*same : undefined, del : undefined, */ older : null, newer : { side : 'src' } },
        { relative : './c/srcdir-dstfile', same : false, /* del : undefined, */ older : null , newer : null },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', /*same : undefined, del : undefined, */ older : null, newer : { side : 'src' } },

      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

      },

    },

    //

    {
      name : 'exclude-1',
      expected :
      [

        { relative : '.', /*same : undefined, del : undefined*/ },

        { relative : './c', /* same : undefined, */ del : true },
        { relative : './c/c1', /*  same : undefined, */ del : true },
        { relative : './c/c2', /* same : undefined, */ del : true },
        { relative : './c/c2/c22', /* same : undefined, */ del : true },

        { relative : './a', /*same : undefined, del : undefined*/ },

        { relative : './b', /*same : undefined, del : undefined*/ },
        { relative : './b/b1', same : true/* , del : undefined */ },
        { relative : './b/b2', /*same : undefined, del : undefined*/ },
        { relative : './b/b2/b22', same : true/* , del : undefined */ },
        { relative : './b/b2/x', same : true/* , del : undefined */ },

      ],

      filesTree :
      {

        initial : filesTree.exclude,

      },

    },

   /*  {
      name : 'exclude-2',
      options :
      {
        maskAll : { excludeAny : /b/ }
      },

      expected :
      [
        { relative : '.', same : undefined, del : undefined },

        { relative : './c', same : undefined, del : true },
        { relative : './c/c1', same : undefined, del : true },
        { relative : './c/c2', same : undefined, del : true },
        { relative : './c/c2/c22', same : undefined, del : true },

        { relative : './a', same : undefined, del : undefined },


        { relative : './b', same : undefined, del : true },
        { relative : './b/b1', same : undefined, del : true },
        { relative : './b/b2', same : undefined, del : true },
        { relative : './b/b2/b22', same : undefined, del : true },
        { relative : './b/b2/x', same : undefined, del : true },

      ],

      filesTree :
      {

        initial : filesTree.exclude,

      },

    }, */

  ];

  //

  for( var s = 0 ; s < samples.length ; s++ )
  {

    var sample = samples[ s ];
    var dir = _.path.join( testRoutineDir, './tmp/sample/' + sample.name );
    test.case = sample.name;

    // if( sample.name !== 'exclude-2' )
    // continue;

    _.FileProvider.Extract.readToProvider
    ({
      dstProvider : _.fileProvider,
      dstPath : dir,
      filesTree : sample.filesTree,
      allowWrite : 1,
      allowDelete : 1,
      sameTime : 1,
    });

    // var files = _.fileProvider.filesFind({ filePath : dir, includingStem : 1, recursive : '2', includingTransient : 1 } );

    // logger.log( context.select( files, '*.relative' ) )
    // logger.log( context.select( files, '*.stat.mtime' ).map( ( t ) => t.getTime() ) )

    var o =
    {
      src : _.path.join( dir, 'initial/src' ),
      dst : _.path.join( dir, 'initial/dst' ),
      includingTerminals : 1,
      includingDirs : 1,
      recursive : '2',
      onDown : function( record ){ test.identical( _.objectIs( record ), true ); },
      onUp : function( record ){ test.identical( _.objectIs( record ), true ); },
      srcFilter : { ends : sample.ends }
    }

    _.mapExtend( o, sample.options || {} );

    var files = _.FileProvider.HardDrive();

    var got = files.filesFindDifference( o );

    var passed = true;
    passed = passed && test.contains( got, sample.expected );
    passed = passed && test.identical( got.length, sample.expected.length );

    if( !passed )
    {

      // logger.log( 'got :\n' + _.toStr( got, { levels : 3 } ) );
      // logger.log( 'expected :\n' + _.toStr( sample.expected, { levels : 3 } ) );

      // logger.log( 'got :\n' + _.toStr( got, { levels : 2 } ) );

      logger.log( 'relative :\n' + _.toStr( context.select( got, '*.src.relative' ), { levels : 2 } ) );
      logger.log( 'same :\n' + _.toStr( context.select( got, '*.same' ), { levels : 2 } ) );
      logger.log( 'del :\n' + _.toStr( context.select( got, '*.del' ), { levels : 2 } ) );

      logger.log( 'newer :\n' + _.toStr( context.select( got, '*.newer.side' ), { levels : 1 } ) );
      logger.log( 'older :\n' + _.toStr( context.select( got, '*.older' ), { levels : 1 } ) );

    }

    test.case = '';

  }

}

//

function filesCopyWithAdapter( test )
{
  var context = this;
  var testRoutineDir = _.path.join( context.testRootDirectory, test.name );

  var samples =
  [

    {
      name : 'simple-1',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory new' },
        { relative : './a.a', action : 'copied' },
        { relative : './b1.b', action : 'copied' },
        { relative : './b2.b', action : 'copied' },
      ],
    },

    //

    {
      name : 'root-exist',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : {},
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved' },
        { relative : './a.a', action : 'copied' },
        { relative : './b1.b', action : 'copied' },
        { relative : './b2.b', action : 'copied' },
      ],
    },

    //

    {
      name : 'simple-2',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1x' },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved' },
        { relative : './a.a', action : 'same' },
        { relative : './b1.b', action : 'copied' },
        { relative : './b2.b', action : 'copied' },
        { relative : './c', action : 'directory new' },
        { relative : './c/c1.c', action : 'copied' },
      ],
    },

    //

    {
      name : 'remove-source-1',
      options : { removingSource : 1, allowWrite : 1, allowDelete : 0, tryingPreserve : 0 },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1x' },
        },
        got :
        {
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'copied', allow : true },
        { relative : './b1.b', action : 'copied', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory new', allow : true },
        { relative : './c/c1.c', action : 'copied', allow : true }
      ],
    },

    //

    {
      name : 'remove-source-files-1',
      options : { includingDirs : 0, removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1,  allowDelete : 0, filter : { ends : '.b' } },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '', 'b3.b' : 'b3' }, 'e' : { 'b4.b' : 'b4' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'e' : 'e', 'f1.f' : 'f1', 'g' : {}, 'h' : { 'h1.h' : 'h1' } },
        },
        got :
        {
          'src' : { 'a.a' : 'a', /* 'b1.b' : 'b1', */ 'c' : { 'c1.c' : '' }, 'e' : {} },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' , 'c' : { 'b3.b' : 'b3' }, 'e' : { 'b4.b' : 'b4' }, 'f1.f' : 'f1', 'g' : {}, 'h' : { 'h1.h' : 'h1' } },
        },
      },
      expected :
      [
        {
          relative : './b1.b',
          action : 'same',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        },
        {
          relative : './b2.b',
          action : 'copied',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        },
        {
          relative : './c/b3.b',
          action : 'copied',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        },
        {
          relative : './e/b4.b',
          action : 'copied',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        }
      ],
    },



    {

      name : 'remove-sorce-files-2',
      options : { includingDirs : 0, removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowDelete : 0, filter : { ends : '.b' } },

      expected :
      [
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'same',
          allow : true,
          relative : './b1.b'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './b2.b'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './c/b3.b'
        }

      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'c' :
            {
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
              'srcfile-dstdir' : 'x',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'dstfile.d' : 'd1',
              'srcdir-dstfile' : 'x',
              'dstdir' : {},
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' }
            },
          },
        },

      },

    },



    {

      name : 'allow-rewrite-file-by-dir',
      options : { removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowRewriteFileByDir : 0, allowDelete : 0, filter : { ends : '.b' } },

      expected :
      [

        {
          srcAction : 'fileDelete',
          srcAllow : false,
          reason : 'srcLooking',
          action : 'directory preserved',
          allow : true,
          relative : '.'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'same',
          allow : true,
          relative : './b1.b'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './b2.b'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'directory preserved',
          allow : true,
          relative : './c'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'copied',
          allow : true,
          relative : './c/b3.b'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/dstfile.d'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/srcdir-dstfile'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/dstdir'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'directory preserved',
          allow : true,
          relative : './c/e'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/srcfile-dstdir'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/srcfile-dstdir/srcfile-dstdir-file'
        }

      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'dstfile.d': 'd1',
              'srcdir-dstfile' : 'x',
              'dstdir' : {},
              'e': { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' }
            }
          },
          'src' :
          {
            'a.a' : 'a',
            'c' :
            {
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : 'x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' }
            }
          }
        },

      },

    },

    //

    {
      name : 'levels-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
            },
          },
        },
        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
              'g' : {},
            },
          },
        },
      },
      expected :
      [

        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'same', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/g', action : 'directory new', allow : true },
        { relative : './c/d1.d', action : 'fileDelete', allow : false },
        { relative : './c/f', action : 'fileDelete', allow : false }

      ],
    },

    //

    {
      name : 'remove-source-files-2',
      options : { removingSourceTerminals : 1, tryingPreserve : 1 },
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
            },
          },
        },
        got :
        {

          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
              'e': { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
              'g': {}
            },
          },
        },
      },
      expected :
      [

        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'same', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/g', action : 'directory new', allow : true },
        { relative : './c/d1.d', action : 'fileDelete', allow : false },
        { relative : './c/f', action : 'fileDelete', allow : false }

      ],
    },

    //

    {
      name : 'remove-source-2',
      options : { removingSource : 1, tryingPreserve : 0 },
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
            },
          },
        },
        got :
        {
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
              'g' : {},
            },
          },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'copied', allow : true },
        { relative : './b1.b', action : 'copied', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'copied', allow : true },
        { relative : './c/e/e1.e', action : 'copied', allow : true },
        { relative : './c/g', action : 'directory new', allow : true },
        { relative : './c/d1.d', action : 'fileDelete', allow : false },
        { relative : './c/f', action : 'fileDelete', allow : false }
      ],
    },

    //

    {

      name : 'complex-allow-delete-0',
      options : { allowRewrite : 1, allowDelete : 0 },

      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/srcfile', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'fileDelete', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'copied', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/srcdir', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'copied', allow : true },
        { relative : './c/dstdir', action : 'fileDelete', allow : false },
        { relative : './c/dstfile.d', action : 'fileDelete', allow : false }
      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',

              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
              'srcfile-dstdir' : 'x',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'dstfile.d' : 'd1',
              'dstdir' : {},
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : 'x',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            },
          },
        },

      },

    },

    //

    {

      name : 'complex-allow-all',
      options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1 },

      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/srcfile', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'fileDelete', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'copied', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/srcdir', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'copied', allow : true },
        { relative : './c/dstdir', action : 'fileDelete', allow : true },
        { relative : './c/dstfile.d', action : 'fileDelete', allow : true }
      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
              'srcfile-dstdir' : 'x',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : 'x',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            },
          },
        },

      },

    },

    //

    // {

    //   name : 'complex-allow-only-rewrite',
    //   options : { allowRewrite : 1, allowDelete : 0, allowWrite : 0 },

    //   expected :
    //   [

    //     { relative : '.', action : 'directory preserved', },

    //     { relative : './a.a', action : 'same', },
    //     { relative : './b1.b', action : 'same', allow : true },
    //     { relative : './b2.b', action : 'cant rewrite', allow : false },

    //     { relative : './c', action : 'directory preserved', },

    //     { relative : './c/dstfile.d', action : 'deleted', allow : false },
    //     { relative : './c/dstdir', action : 'deleted', allow : false },
    //     { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : false },

    //     { relative : './c/b3.b', action : 'cant rewrite', allow : false },

    //     { relative : './c/srcfile', action : 'copied', allow : false },
    //     { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

    //     { relative : './c/e', action : 'directory preserved', },
    //     { relative : './c/e/d2.d', action : 'cant rewrite', allow : false },
    //     { relative : './c/e/e1.e', action : 'same', },

    //     { relative : './c/srcdir', action : 'directory new', allow : false },
    //     { relative : './c/srcdir-dstfile', action : 'cant rewrite', allow : false },
    //     { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allow : false },

    //   ],

    //   filesTree :
    //   {

    //     initial : filesTree.initialCommon,

    //     got :
    //     {
    //       'src' :
    //       {
    //         'a.a' : 'a',
    //         'b1.b' : 'b1',
    //         'b2.b' : 'b2x',
    //         'c' :
    //         {
    //           'b3.b' : 'b3x',
    //           'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
    //           'srcfile' : 'srcfile',
    //           'srcdir' : {},
    //           'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
    //           'srcfile-dstdir' : 'x',
    //         },
    //       },
    //       'dst' :
    //       {
    //         'a.a' : 'a',
    //         'b1.b' : 'b1',
    //         'b2.b' : 'b2',
    //         'c' :
    //         {
    //           'b3.b' : 'b3',
    //           'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
    //           'dstfile.d' : 'd1',
    //           'dstdir' : {},
    //           'srcdir-dstfile' : 'x',
    //           'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
    //         },
    //       },
    //     },

    //   },

    // },

    //

  //   {

  //     name : 'complex-allow-only-delete',
  //     options : { allowRewrite : 0, allowDelete : 1, allowWrite : 0 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', allow : true },
  //       { relative : './b2.b', action : 'cant rewrite', allow : false },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : true },
  //       { relative : './c/dstdir', action : 'deleted', allow : true },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : true },

  //       { relative : './c/b3.b', action : 'cant rewrite', allow : false },

  //       { relative : './c/srcfile', action : 'copied', allow : false },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', allow : false },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new', allow : false },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', allow : false },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allow : false },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'srcdir-dstfile' : 'x',
  //             'srcfile-dstdir' : {},
  //           },
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {

  //     name : 'complex-not-allow-only-rewrite',
  //     options : { allowRewrite : 0, allowDelete : 1, allowWrite : 1 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : true },
  //       { relative : './c/dstdir', action : 'deleted', allow : true },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : true },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied' },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new' },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcfile-dstdir' : {},
  //             'srcdir' : {},
  //             'srcdir-dstfile' : 'x',
  //           },
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {

  //     name : 'complex-not-allow-rewrite-and-delete',
  //     options : { allowRewrite : 0, allowDelete : 0, allowWrite : 1 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : false },
  //       { relative : './c/dstdir', action : 'deleted', allow : false },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : false },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied' },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new' },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'dstfile.d' : 'd1',
  //             'dstdir' : {},
  //             'srcfile' : 'srcfile',
  //             'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
  //             'srcdir' : {},
  //             'srcdir-dstfile' : 'x',
  //           },
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {

  //     name : 'complex-not-allow',
  //     options : { allowRewrite : 0, allowDelete : 0, allowWrite : 0 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : false },
  //       { relative : './c/dstdir', action : 'deleted', allow : false },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : false },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied', allow : false },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', allow : false },
  //       { relative : './c/e/e1.e', action : 'same', allow : true },

  //       { relative : './c/srcdir', action : 'directory new' },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite' },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'dstfile.d' : 'd1',
  //             'dstdir' : {},
  //             'srcdir-dstfile' : 'x',
  //             'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
  //           },
  //         },

  //       },

  //     },

  //   },

  //   //

  //   {
  //     name : 'filtered-out-dst-empty-1',
  //     options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1, maskAll : 'x' },
  //     filesTree :
  //     {
  //       initial :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //       },
  //       got :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //         'dst' : {},
  //       },
  //     },
  //     expected :
  //     [
  //       { relative : '.', action : 'directory new', allow : true },
  //     ],
  //   },

  //   //

  //   {
  //     name : 'filtered-out-dst-filled-1',
  //     options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1, maskAll : 'x' },
  //     filesTree :
  //     {
  //       initial :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //         'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //       },
  //       got :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //         'dst' : {},
  //       },
  //     },
  //     expected :
  //     [
  //       { relative : '.', action : 'directory preserved', allow : true },
  //       { relative : './a.a', action : 'deleted', allow : true },
  //       { relative : './b1.b', action : 'deleted', allow : true },
  //       { relative : './b2.b', action : 'deleted', allow : true },
  //     ],
  //   },

  //   //

  //   {
  //     name : 'filtered-out-dst-filled-1',
  //     options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1 },
  //     filesTree :
  //     {
  //       initial :
  //       {
  //         'src' : {},
  //         'dst' : { 'a' : {}, 'b' : { 'b1' : 'b1', 'b2' : 'b2' } },
  //       },
  //       got :
  //       {
  //         'src' : {},
  //         'dst' : {},
  //       },
  //     },
  //     expected :
  //     [
  //       { relative : '.', action : 'directory preserved', allow : true },
  //       { relative : './a', action : 'deleted', allow : true },
  //       { relative : './b', action : 'deleted', allow : true },
  //       { relative : './b/b1', action : 'deleted', allow : true },
  //       { relative : './b/b2', action : 'deleted', allow : true },
  //     ],
  //   },

  //   //

  //   {
  //     name : 'exclude-1',
  //     options :
  //     {
  //       allowDelete : 1,
  //       maskAll : { excludeAny : /b/ }
  //     },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved' },

  //       { relative : './b', action : 'deleted', allow : true },
  //       { relative : './b/b1', action : 'deleted', allow : true },
  //       { relative : './b/b2', action : 'deleted', allow : true },
  //       { relative : './b/b2/b22', action : 'deleted', allow : true },
  //       { relative : './b/b2/x', action : 'deleted', allow : true },

  //       { relative : './c', action : 'deleted', allow : true },
  //       { relative : './c/c1', action : 'deleted', allow : true },
  //       { relative : './c/c2', action : 'deleted', allow : true },
  //       { relative : './c/c2/c22', action : 'deleted', allow : true },

  //       { relative : './a', action : 'copied', allow : true },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.exclude,
  //       got :
  //       {
  //         'src' :
  //         {
  //           'a' : 'a',
  //           'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
  //         },
  //         'dst' :
  //         {
  //           'a' : 'a',
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {
  //     name : 'exclude-2',
  //     options :
  //     {
  //       allowDelete : 1,
  //       maskAll : { includeAny : /x/ }
  //     },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved' },

  //       { relative : './b', action : 'deleted', allow : true },
  //       { relative : './b/b1', action : 'deleted', allow : true },
  //       { relative : './b/b2', action : 'deleted', allow : true },
  //       { relative : './b/b2/b22', action : 'deleted', allow : true },
  //       { relative : './b/b2/x', action : 'deleted', allow : true },

  //       { relative : './c', action : 'deleted', allow : true },
  //       { relative : './c/c1', action : 'deleted', allow : true },
  //       { relative : './c/c2', action : 'deleted', allow : true },
  //       { relative : './c/c2/c22', action : 'deleted', allow : true },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.exclude,
  //       got :
  //       {
  //         'src' :
  //         {
  //           'a' : 'a',
  //           'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
  //         },
  //         'dst' :
  //         {
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {
  //     name : 'softLink-1',
  //     options :
  //     {
  //       allowDelete : 1,
  //       maskAll : { excludeAny : /(^|\/)\.(?!$|\/|\.)/ },
  //     },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved' },

  //       { relative : './a', action : 'copied', allow : true },

  //       { relative : './b', action : 'directory new', allow : true },
  //       //{ relative : './b/.b1', action : 'copied', allow : true },
  //       { relative : './b/b2', action : 'directory new', allow : true },
  //       { relative : './b/b2/b22', action : 'copied', allow : true },

  //       { relative : './c', action : 'directory new', allow : true },
  //       { relative : './c/b2', action : 'directory new', allow : true },
  //       { relative : './c/b2/b22', action : 'copied', allow : true },

  //     ],

  //     filesTree :
  //     {
  //       initial : filesTree.softLink,
  //       got :
  //       {
  //         'src' :
  //         {
  //           'a' : 'a',
  //           'b' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
  //           'c' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
  //         },
  //         'dst' :
  //         {
  //           'a' : 'a',
  //           'b' : { 'b2' : { 'b22' : 'b22' } },
  //           'c' : { 'b2' : { 'b22' : 'b22' } },
  //         },
  //       },
  //     },

  //   },

  // //

    {
      name : 'preserve-filtered-1',
      options :
      {
        allowDelete : 1,
        removingSource : 1,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file : 'file' },
          dst : {}
        },
      },
    },

    {
      name : 'preserve-filtered-2',
      options :
      {
        allowDelete : 1,
        removingSource : 0,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { file2 : 'file2' }
        },
      },
    },
    {
      name : 'preserve-filtered-3',
      options :
      {
        allowDelete : 0,
        removingSource : 1,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          dst :
          {
            file2 : 'file2',
            dir : { file : 'file', file2 : 'file2' }
          },
          src : { file : 'file' }
        },
      },
    },
    {
      name : 'delete-filtered-1',
      options :
      {
        allowDelete : 0,
        removingSource : 1,
        filter :
        {
          maskAll : { includeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file2 : 'file2' },
          dst : { file : 'file', dir : { file : 'file', file2 : 'file2' } }
        },
      },
    },
    {
      name : 'delete-filtered-2',
      options :
      {
        allowDelete : 1,
        removingSource : 1,
        filter :
        {
          maskAll : { includeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file2 : 'file2' },
          dst :
          {
          }
        },
      },
    },
    {
      name : 'preserve-all',
      options :
      {
        allowDelete : 0,
        removingSource : 0,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          dst :
          {
            file2 : 'file2',
            dir : { file : 'file', file2 : 'file2' }
          },
          src : { file : 'file', file2 : 'file2' }
        },
      },
    },
    {
      name : 'remove-all',
      options :
      {
        allowDelete : 1,
        removingSource : 1,
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          dst : {}
        },
      },
    },

  ];

  //

  for( var s = 0 ; s < samples.length ; s++ )
  {

    var sample = samples[ s ];
    if( !sample ) break;

    var dir = _.path.join( testRoutineDir, './tmp/sample/' + sample.name );
    test.case = sample.name;

    _.FileProvider.Extract.readToProvider
    ({
      dstProvider : _.fileProvider,
      dstPath : dir,
      filesTree : sample.filesTree,
      allowWrite : 1,
      allowDelete : 1,
      sameTime : 1,
    });

/*
    var treeWriten = _.filesTreeRead
    ({
      filePath : dir,
      read : 0,
    });
    logger.log( 'treeWriten :', _.toStr( treeWriten, { levels : 99 } ) );
*/

    var copyOptions =
    {
      src : _.path.join( dir, 'initial/src' ),
      dst : _.path.join( dir, 'initial/dst' ),
      // filter : { ends : sample.ends },
      investigateDestination : 1,
      includingTerminals : 1,
      includingDirs : 1,
      recursive : '2',
      allowWrite : 1,
      allowRewrite : 1,
      allowDelete : 0,
    }

    _.mapExtend( copyOptions, sample.options || {} );

    var got = _.fileProvider.filesCopyWithAdapter( copyOptions );

    var treeGot = _.FileProvider.Extract.filesTreeRead({ srcPath : dir, srcProvider : _.fileProvider });
    // var treeGot = _.fileProvider.filesTreeRead( dir );

    var passed = true;
    if( sample.expected )
    {
      passed = passed && test.contains( got, sample.expected );
      passed = passed && test.identical( got.length, sample.expected.length );
    }
    passed = passed && test.contains( treeGot.initial, sample.filesTree.got );

    if( !passed )
    {
      logger.log( 'return :\n' + _.toStr( got, { levels : 2 } ) );
      // logger.log( 'got :\n' + _.toStr( treeGot.initial, { levels : 99 } ) );
      // logger.log( 'expected :\n' + _.toStr( sample.filesTree.got, { levels : 99 } ) );

      logger.log( 'relative :\n' + _.toStr( context.select( got, '*.relative' ), { levels : 2 } ) );
      logger.log( 'action :\n' + _.toStr( context.select( got, '*.action' ), { levels : 2 } ) );
      // logger.log( 'length :\n' + got.length + ' / ' + sample.expected.length );

      //logger.log( 'same :\n' + _.toStr( context.select( got, '*.same' ), { levels : 2 } ) );
      //logger.log( 'del :\n' + _.toStr( context.select( got, '*.del' ), { levels : 2 } ) );

    }

    test.case = '';

  }


}

filesCopyWithAdapter.timeOut = 15000;

//

function experiment( test )
{

  var testDir = _.path.join( context.testRootDirectory, test.name );
  var src = _.path.join( testDir, 'src' );
  var dst = _.path.join( testDir, 'dst' );
  _.fileProvider.fileWrite( src, 'data' );
  _.fileProvider.softLink( dst, src );
  _.fileProvider.resolvingSoftLink = 1;

  var files = _.fileProvider.filesFind( dst );
  console.log( _.toStr( files, { levels : 99 } ) );

  // var got2 = _.fileProvider.filesFind( { filePath : __dirname, recursive : '2' } );
  // console.log( got2[ 0 ] );

}

experiment.experimental = 1;

//

//
// function experiment2( test )
// {
//   var expected =
//   [
//     './Provider.Extract.html',
//     './Provider.Extract.test.s',
//     './Provider.HardDrive.test.ss',
//     './Provider.Hub.Extract.test.s',
//     './Provider.Hub.HardDrive.test.ss',
//     './Provider.Url.test.ss'
//   ]
//
//   test.case = 'glob without absolute path';
//
//   var result = _.fileProvider.filesFind
//   ({
//     filePath : __dirname,
//     filePath : 'Provider*',
//     outputFormat : 'relative'
//   })
//   test.identical( result, expected );
//
//   // this works
//
//   test.case = 'glob with absolute path';
//
//   var result = _.fileProvider.filesFind
//   ({
//     filePath : __dirname,
//     filePath : _.path.join( __dirname, 'Provider*' ),
//     outputFormat : 'relative'
//   })
//   test.identical( result, expected );
// }
//
// experiment2.experimental = 1;
//
// //
//
// function filesFindExperiment( test )
// {
//
//   var testDir = _.path.join( context.testRootDirectory, test.name );
//   var filePath = _.path.join( testDir, 'package.json' );
//
//   _.fileProvider.filesDelete( testDir );
//
//   _.fileProvider.fileWrite( filePath, filePath );
//
//   var maskTerminal =
//   {
//     includeAny : [ './package.json' ]
//   }
//
//   var filter =  { maskTerminal : maskTerminal }
//
//   var got = _.fileProvider.filesFind({ filePath : testDir, filter : filter });
//
//   test.identical( got.length, 1 );
//
//   /**/
//
//   var maskTerminal =
//   {
//     includeAny : [ './filesFindExperiment/package.json' ]
//   }
//
//   var filter =  { maskTerminal : maskTerminal }
//
//   var got = _.fileProvider.filesFind({ filePath : testDir, filter : filter });
//
//   test.identical( got.length, 1 );
//
// }
//
// filesFindExperiment.experimental = 1;

// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/FilesFind/Abstract',
  abstract : 1,
  silencing : 1,
  // verbosity : 7,

  onSuiteBegin : onSuiteBegin,

  context :
  {
    pathFor : pathFor,
    providerIsInstanceOf : providerIsInstanceOf,
    symlinkIsAllowed : symlinkIsAllowed,
    testRootDirectory : null,

    // from old suite

    makeStandardExtract : makeStandardExtract,
    _generatePath : _generatePath,
    _filesFindTrivial : _filesFindTrivial,
    _filesReflect : _filesReflect,
    _filesReflectWithFilter : _filesReflectWithFilter,
    symlinkIsAllowed : symlinkIsAllowed,
    select : select
  },

  tests :
  {
    recordFilterPrefixesApply : recordFilterPrefixesApply,
    recordFilterInherit : recordFilterInherit,
    recordFilter : recordFilter,

    filesFindTrivial : filesFindTrivial,
    filesFindMaskTerminal : filesFindMaskTerminal,
    filesFindCriticalCases : filesFindCriticalCases,
    filesFindPreset : filesFindPreset,

    filesFind : filesFind,
    filesFind2 : filesFind2,
    filesFindRecursive : filesFindRecursive,
    filesFindLinked : filesFindLinked,

    // filesFindResolving : filesFindResolving,
    filesFindPerformance : filesFindPerformance,

    filesFindGlob : filesFindGlob,
    filesGlob : filesGlob,

    filesReflectTrivial : filesReflectTrivial,
    filesReflectMutuallyExcluding : filesReflectMutuallyExcluding,
    filesReflectWithFilter : filesReflectWithFilter,
    filesReflect : filesReflect, // xxx
    filesReflectRecursive : filesReflectRecursive,
    filesReflectGrab : filesReflectGrab,
    filesReflector : filesReflector,
    filesReflectWithHub : filesReflectWithHub,
    filesReflectWithPrefix : filesReflectWithPrefix,
    filesReflectDstPreserving : filesReflectDstPreserving,
    filesReflectDstDeletingDirs : filesReflectDstDeletingDirs,
    filesReflectLinked : filesReflectLinked,

    filesDelete : filesDelete,
    filesDeleteEmptyDirs : filesDeleteEmptyDirs,
    // filesDeleteAndAsyncWrite : filesDeleteAndAsyncWrite,

    // filesFindDifference : filesFindDifference,
    filesCopyWithAdapter : filesCopyWithAdapter,

    // experiment : experiment,
    // experiment2 : experiment2,
    // filesFindExperiment : filesFindExperiment,
  },

};

wTestSuite( Self );

})();
