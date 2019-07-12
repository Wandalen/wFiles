( function _FilesFind_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );

  require( '../files/UseTop.s' );

  var crypto = require( 'crypto' );
  var waitSync = require( 'wait-sync' );

}

//

var _ = _global_.wTools;
var Parent = wTester;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;
}

//

function onSuiteEnd()
{
  let path = this.provider.path;
  _.assert( Object.keys( this.hub.providersWithProtocolMap ).length === 1, 'Hub should have single registered provider at the end of testing' );
  _.assert( _.strHas( this.testSuitePath, 'tmp.tmp' ) );
  path.dirTempClose( this.testSuitePath );
  this.provider.finit();
  this.hub.finit();
}

//

function onRoutineEnd( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  _.sure( _.entityIdentical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] ), test.name, 'has not restored hub!' );
}

//

function softLinkIsSupported()
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;

  if( Config.platform === 'nodejs' && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allowed = false;
    var dir = path.join( context.testSuitePath, 'softLinkIsSupported' );
    var srcPath = path.join( context.testSuitePath, 'softLinkIsSupported/src' );
    var dstPath = path.join( context.testSuitePath, 'softLinkIsSupported/dst' );

    context.provider.filesDelete( dir );
    context.provider.fileWrite( srcPath, srcPath );

    try
    {
      context.provider.softLink({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allowed = context.provider.isSoftLink( dstPath );
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
  let context = this;
  let path = context.provider.path;
  var foldersPath = dir;
  var fileName = _.idWithGuid();

  for( var j = 0; j < levels; j++ )
  {
    var temp = _.idWithGuid().substring( 0, Math.random() * levels );
    foldersPath = path.join( foldersPath , temp );
  }

  return path.join( foldersPath, fileName );
}

//

function softLinkIsSupported()
{
  let context = this;
  let path = context.provider.path;

  if( Config.platform === 'nodejs' && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allow = false;
    var dir = path.join( context.testSuitePath, 'softLinkIsSupported' );
    var srcPath = path.join( dir, 'src' );
    var dstPath = path.join( dir, 'dst' );

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

function filesFindTrivial( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs( filePath )
  {
    return path.join( testPath, filePath );
  }

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });

  test.case = 'setup';

  extract1.filesReflectTo( provider, testPath );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find single terminal file . includingTransient : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 0, includingTerminals : 1 }
  test.case = 'find single terminal file . includingTransient : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 0, includingTransient : 1, includingTerminals : 1 }
  test.case = 'find single terminal file . includingStem : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* - */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  test.case = 'setup trivial';

  extract1.readToProvider( provider, testPath );
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, testPath );
  test.identical( gotTree.filesTree, extract1.filesTree );

  extract1.readToProvider( provider, testPath );

  /* */

  var o1 = { filePath : path.join( testPath, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1 }
  test.case = 'find single terminal file . includingTerminals : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 0 }
  test.case = 'find single terminal file . includingTerminals : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 0, includingTransient : 1, includingTerminals : 1 }
  test.case = 'find single terminal file . includingStem : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* - */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : '1', b : '1', dir11 : {} },
      dir2 : { c : '1' },
      d : '1',
    },
  });

  test.case = 'setup trivial';

  extract1.readToProvider({ dstProvider : provider, dstPath : testPath, allowDelete : 1 });
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, testPath );
  test.identical( gotTree.filesTree, extract1.filesTree );
  extract1.readToProvider( provider, testPath );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find includingStem : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 0, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find includingStem:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 0 }
  test.case = 'find includingTransient:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './d', './dir1/a', './dir1/b', './dir2/c' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( testPath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 0, includingDirs : 1 }
  test.case = 'find includingTerminals:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './dir1', './dir1/dir11', './dir2' ];
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : null, '**b**' : 0 };
  var filter = { prefixPath : path.join( testPath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ];
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : true, '**b**' : 0 };
  var filter = { prefixPath : path.join( testPath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ];
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : null, '**b**' : 0, '**a**' : 1 };
  var filter = { prefixPath : path.join( testPath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ];
  test.identical( got, expected );

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : 'dir1', b : 'dir1', dir11 : { a : 'dir11', b : 'dir11', c : 'dir11' }, dira : {}, dirb : {} },
      dir2 : { a : 'dir2', b : 'dir2', c : 'dir2' },
      d : '/',
    },
  });

  test.case = 'setup trivial';
  provider.filesDelete( testPath );
  extract1.readToProvider( provider, testPath );

  test.case = 'several nulls';
  var filePath = { [ abs( 'dir1/' + '**a**' ) ] : null, [ abs( 'dir1/' + '**b**' ) ] : null };
  var filter = { filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 0, includingTerminals : 1, includingDirs : 1 }
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './a', './b', './dir11/a', './dir11/b', './dira', './dirb' ];
  test.identical( got, expected );

  test.case = 'several nulls : { dir1/**a** : null, dir2**b** : null }';
  var filePath = { [ abs( 'dir1/' + '**a**' ) ] : null, [ abs( 'dir2' + '**b**' ) ] : null };
  var filter = { filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 0, includingTerminals : 1, includingDirs : 1 }
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './dir2/b', './a', './dir11/a', './dira' ];
  test.identical( got, expected );

}

//

function filesFindTrivialAsync( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let con = new _.Consequence().take( null );

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : '1', b : '1', dir11 : {} },
      dir2 : { c : '1' },
      d : '1',
    },
  });

  test.case = 'setup trivial';

  extract1.readToProvider({ dstProvider : provider, dstPath : context.testSuitePath, allowDelete : 1 });
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, context.testSuitePath );
  test.identical( gotTree.filesTree, extract1.filesTree );

  extract1.readToProvider( provider, context.testSuitePath );

  //

  con.thenKeep( () =>
  {
    test.case = 'trivial async';
    var o =
    {
      filePath : path.join( context.testSuitePath ),
      outputFormat : 'relative',
      sync : 0,
      recursive : 2,
      includingTerminals : 1,
      includingDirs : 1
    }

    return provider.filesFind( _.mapExtend( null, o ) )
    .finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      var expected =
      [
        '.',
        './d',
        './dir1',
        './dir1/a',
        './dir1/b',
        './dir1/dir11',
        './dir2',
        './dir2/c'
      ]
      test.identical( got, expected )
      return null;
    })
  })

  return con;
}

//

function filesFindMaskTerminal( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  var terminalPath = path.join( testPath, 'package.json' );

  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );

  test.case = 'relative to current dir';

  var filter =  { maskTerminal : './package.json' }
  var got = provider.filesFind({ filePath : testPath, filter : filter, recursive : 1 });
  test.identical( got.length, 1 );

  /* */

  test.case = 'relative to parent dir';

  var filter =  { maskTerminal : './filesFindMaskTerminal/package.json' }
  var got = provider.filesFind({ filePath : testPath, filter : filter });
  test.identical( got.length, 0 );

}

//

function filesFindCriticalCases( test )
{
  let context = this
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let provider = context.provider;
  let hub = context.hub;

  /* */

  test.case = 'base path + empty file path';

  var extract = _.FileProvider.Extract
  ({
    filesTree : {},
  });

  var got = extract.filesFind
  ({
    filter : { basePath : '/' },
    filePath : [],
  });
  var expected = [];
  test.identical( got, expected );

  /* */

  test.case = 'filePath : filter';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { dir1 : { a : '1', b : '2' }, e : '5' },
  });

  extract.protocol = 'src';
  extract.providerRegisterTo( hub );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  extract.finit();

  var filter = provider.recordFilter({ filePath : testPath + '/dir1' });
  var got = provider.filesFind({ filePath : filter });
  var relative = _.select( got, '*/relative' );
  var expectedRelative = [ './a', './b' ];

  test.identical( relative, expectedRelative );

  /* */

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

  var hub2 = _.FileProvider.Hub({ providers : [] });
  _.FileProvider.Extract({ protocol : 'ext1' }).providerRegisterTo( hub2 );
  _.FileProvider.Extract({ protocol : 'ext2' }).providerRegisterTo( hub2 );

  var got = hub2.filesFind([]);
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

  filter.filePath = [ '/dir1', '/dir2' ];
  filter._formPaths();
  var found = extract.filesFind
  ({
    recursive : 2,
    includingDirs : 1,
    includingTerminals : 1,
    mandatory : 0,
    outputFormat : 'relative',
    filter : filter,
  });

  var expected = [ './dir1', './dir1/a', './dir1/b', './dir2', './dir2/c' ];
  test.identical( found, expected );

  /* */

  test.case = 'base path + empty file path';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 },
  });

  let op =
  {
    'filePath' : '/dir1',
    'recursive' : null,
    'filter' :
    {
      'maskTerminal' :
      {
        'excludeAny' :
        [
          /\.DS_Store$/,
          /(^|\/)-/,
          /\.out(\.|$)/,
        ],
        'includeAll' : []
      }
    },
    'maskPreset' : 0,
    'outputFormat' : 'relative',
  }

  var got = extract.filesFind( op );
  var expected = [ './a', './b' ];
  test.identical( got, expected );

  /* */

  var filesTree =
  {
    src :
    {
      dir1 : {},
      dir2 :
      {
        '-Excluded.js' : `console.log( 'dir2/-Ecluded.js' );`,
        'File.js' : `console.log( 'dir2/File.js' );`,
        'File.test.js' : `console.log( 'dir2/File.test.js' );`,
        'File1.debug.js' : `console.log( 'dir2/File1.debug.js' );`,
        'File1.release.js' : `console.log( 'dir2/File1.release.js' );`,
        'File2.debug.js' : `console.log( 'dir2/File2.debug.js' );`,
        'File2.release.js' : `console.log( 'dir2/File2.release.js' );`,
      },
      dir3 :
      {
        'File.js' : `console.log( 'dir3/File.js' );`,
        'File.test.js' : `console.log( 'dir3/File.test.js' );`,
      },
    }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });

  var filter =
  {
    filePath : { '**.test*' : true, '.' : '.' },
    prefixPath : '/src',
    maskAll : { excludeAny : [ /(^|\/)-/, /\.release($|\.|\/)/i ] },
  }

  var got = extract.filesFind({ filter : filter, 'outputFormat' : 'relative' });
  var expected = [ './dir2/File.test.js', './dir3/File.test.js' ];
  test.identical( got, expected );

  var filter =
  {
    filePath : { '**.test*' : false, '**.test/**' : false, '.' : '.' },
    prefixPath : '/src',
    maskAll : { excludeAny : [ /(^|\/)-/, /\.release($|\.|\/)/i ] },
  }

  var got = extract.filesFind({ filter : filter, 'outputFormat' : 'relative' });
  var expected = [ './dir2/File.js', './dir2/File1.debug.js', './dir2/File2.debug.js', './dir3/File.js' ];
  test.identical( got, expected );

  /* */

  if( Config.debug )
  {

    var filter = extract.recordFilter
    ({
      basePath : '.',
      prefixPath : '/',
    });

    filter.filePath = [ '/dir1', '/dir2' ];
    filter._formPaths();

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
    recursive : 2,
    filter :
    {
      basePath : '/some/path',
    },
  });

  var expected = [];
  test.identical( found, expected );

  /* */

  test.case = 'double preset';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { '.system' : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 } },
  });

  var o =
  {
    filePath : '/.system',
    outputFormat : 'relative',
    recursive : 2,
    filter :
    {
      basePath : '/some/path',
      maskAll : _.files.regexpMakeSafe( null ),
    },
  }
  var found = extract.filesFind( o );
  var expected = [];
  test.identical( found, expected );

  var maskAll = _.files.regexpMakeSafe();
  test.identical( o.filter.maskAll, maskAll );

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
    recursive : 2,
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
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

/*
qqq : adjust for both providers
*/

  if( provider instanceof _.FileProvider.Extract )
  return test.is( true );

  var fixedOptions =
  {
    // basePath : null,
    // filePath : testPath,
    // strict : 1,
    allowingMissed : 1,
    includingStem : 1,
    result : [],
    orderingExclusion : [],
    sortingWithArray : null,
  }

  /* */

  test.case = 'native path';
  var got = provider.filesFind
  ({
    filePath : __filename,
    includingTerminals : 1,
    includingTransient : 0,
    outputFormat : 'absolute'
  });
  var expected = [ path.normalize( __filename ) ];
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

  var got = provider.filesFind
  ({
    filePath : __dirname,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'absolute',
    onUp : onUp,
    onDown : onDown,
    recursive : 2
  });

  test.is( got.length > 0 );
  test.identical( got.length, _.mapOwnKeys( onUpMap ).length );
  test.identical( got.length, _.mapOwnKeys( onDownMap ).length );

  //

  provider.safe = 1;

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
  var recursive = [ 0, 1, 2 ];
  var includingTerminals = [ 0, 1 ];
  var includingTransient = [ 0, 1 ];
  var terminalPaths = [ testPath ];

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
    terminalPaths.forEach( ( terminalPath ) =>
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
                filePath : terminalPath
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
        options.filePath = path.join( options.filePath, options.glob );
        delete options.glob;
      }

      if( options.filePath === null )
      return test.shouldThrowError( () => provider.filesFind( options ) );

      var files = provider.filesFind( options );

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
          logger.log( 'Files:', _.toStr( files.sort() ) );
          logger.log( 'Expected:', _.toStr( expected.sort() ) );
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
      recursive : 2,
      includingTerminals : 1,
      includingTransient : 0,
      filePath : path.join( testPath, glob ),
      filter :
      {
        basePath : testPath,
        prefixPath : testPath
      }
    };

    _.mapSupplement( o, fixedOptions );

    var info = _.cloneJust( o );
    info.level = levels;
    info.number = ++n;
    test.case = _.toStr( info, { levels : 3 } )
    var files = provider.filesFind( _.cloneJust( o ) );

    // var tester = path.globRegexpsForTerminal( glob, testPath, info.filter.basePath );
    var tester = path.globsFullToRegexps( glob, testPath, info.filter.basePath ).actual;

    var expected = allFiles.slice();
    expected = expected.filter( ( p ) =>
    {
      return tester.test( './' + path.relative( testPath, p ) )
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
    var test = [];

    info.forEach( ( i ) =>
    {
      test.push
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
      data : test,
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
    if( provider.statResolvedRead( testPath ) )
    provider.filesDelete( testPath );

    var dirForFile = testPath;
    for( var i = 0; i <= level; i++ )
    {
      if( i >= 1 )
      dirForFile = path.join( dirForFile, '' + i );

      for( var j = 0; j < filesNames.length; j++ )
      {
        let terminalPath = path.join( dirForFile, filesNames[ j ] );
        provider.fileWrite( terminalPath, '' );
      }

    }

  }

  /* - */

  function makeExpected( level, o )
  {
    var expected = [];
    var dirPath = testPath;
    var isDir = provider.isDir( o.filePath );

    if( isDir && o._includingDirs && o.includingStem )
    {
      if( o.outputFormat === 'absolute' ||  o.outputFormat === 'record' )
      _.arrayPrependOnce( expected, o.filePath );

      if( o.outputFormat === 'relative' )
      _.arrayPrependOnce( expected, path.relative( o.filePath, o.filePath ) );
    }

    if( !isDir )
    {
      if( o.includingTerminals )
      {
        var relative = path.dot( path.relative( o.basePath || o.filePath, o.filePath ) );
        var passed = true;

        if( o.glob )
        {
          if( relative === '.' )
          var toTest = path.dot( path.name({ path : o.filePath, full : 1 }) );
          else
          var toTest = relative;

          // var passed = path.globRegexpsForTerminal( o.glob, o.filePath, o.basePath ).test( toTest );
          var passed = path.globsFullToRegexps( o.glob, o.filePath, o.basePath ).actual.test( toTest );
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
        dirPath = path.join( dirPath, '' + l );
        if( o.includingDirs && o.includingTransient )
        {
          var relative = path.dot( path.relative( o.basePath || testPath, dirPath ) );

          if( o.glob )
          passed = path.globRegexpsForDirectory( o.glob, o.filePath, o.basePath ).test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( dirPath );
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
          var terminalPath = path.join( dirPath, name );
          var passed = true;
          var relative = path.dot( path.relative( o.basePath || testPath, terminalPath ) );

          // if( o.glob )
          // passed = path.globRegexpsForTerminal( o.glob, o.filePath, o.basePath || testPath ).test( relative );
          if( o.glob )
          passed = path.globsFullToRegexps( o.glob, o.filePath, o.basePath || testPath ).actual.test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( terminalPath );
            if( o.outputFormat === 'relative' )
            expected.push( relative );
          }
        })
      }

      if( o.recursive === 1 && l === 0  )
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

    provider.filesDelete( testPath );

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

    function makePaths( test, _path )
    {
      var keys = _.mapOwnKeys( test );
      keys.forEach( ( key ) =>
      {
        if( _.objectIs( test[ key ] ) )
        {
          var terminalPath = path.join( _path, key );
          filesNames.forEach( ( n ) =>
          {
            paths.push( path.join( terminalPath, n ) );
          })
          makePaths( test[ key ], terminalPath );
        }
      })
    }
    makePaths( tree , testPath );
    paths.sort();
    paths.forEach( ( p ) => provider.fileWrite( p, '' ) )
    return paths;
  }

}

filesFind.timeOut = 60000;

//

function filesFind2( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  var terminalPath, got, expected;

  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  provider.filesDelete( testPath );

  _.FileProvider.Extract.readToProvider
  ({
    filesTree : filesTree,
    dstPath : testPath,
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

  test.description = 'default options';

  /*terminalPath - directory*/

  got = provider.filesFind( testPath );
  expected = provider.dirRead( testPath );
  test.identical( check( got, expected ), true );

  /*terminalPath - terminal file*/

  terminalPath = path.join( testPath, 'terminal' );
  provider.fileWrite( terminalPath, 'terminal' );
  got = provider.filesFind( terminalPath );
  expected = provider.dirRead( terminalPath );
  test.identical( check( got, expected ), true );

  /*terminalPath - empty dir*/

  terminalPath = path.join( context.testSuitePath, 'tmp/empty' );
  provider.dirMake( terminalPath )
  got = provider.filesFind( terminalPath );
  test.identical( got, [] );

  /* - */

  test.description = 'allowingMissed option';
  terminalPath = path.join( testPath, 'terminal' );
  var nonexistentPath = path.join( testPath, 'nonexistent' );

  /*terminalPath - relative path*/
  test.shouldThrowErrorSync( function()
  {
    provider.filesFind
    ({
      filePath : path.relative( testPath, nonexistentPath ),
      ignoringignoringNonexistent : 0
    });
  })

  test.case = 'terminalPath - not exist';

  got = provider.filesFind
  ({
    filePath : nonexistentPath,
    allowingMissed : 1,
  });
  // var expected = [ provider.recordFactory({ basePath : '/invalid path', filter : got[ 0 ].context.filter }).record( '/invalid path' ) ];
  var expected = [];
  test.identical( got, expected );

  test.shouldThrowErrorSync( function()
  {
    got = provider.filesFind
    ({
      filePath : nonexistentPath,
      allowingMissed : 0,
    });
  })

  test.case = 'terminalPath - some paths dont exist';

  got = provider.filesFind
  ({
    filePath : [ nonexistentPath, terminalPath ],
    allowingMissed : 1,
  });
  expected = provider.dirRead( terminalPath );
  test.identical( check( got, expected ), true )

  test.shouldThrowErrorSync( function()
  {
    got = provider.filesFind
    ({
      filePath : [ nonexistentPath, terminalPath ],
      allowingMissed : 0,
    });
  });

  /*terminalPath - some paths not exist, allowingMissed on*/

  got = provider.filesFind
  ({
    filePath : [ nonexistentPath, terminalPath ],
    allowingMissed : 1,
  });
  test.identical( got.length, 1 );
  test.is( got[ 0 ] instanceof _.FileRecord );
  test.identical( got[ 0 ].fullName, 'terminal' );

  /* */

  test.description = 'includingTerminals, includingTransient options';

  /*terminalPath - empty dir, includingTerminals, includingTransient on*/

  provider.dirMake( path.join( context.testSuitePath, 'empty' ) )
  got = provider.filesFind({ filePath : path.join( testPath, 'empty' ), includingTerminals : 1, includingTransient : 1, allowingMissed : 1 });
  test.identical( got, [] );

  /*terminalPath - empty dir, includingTerminals, includingTransient on, includingStem off*/

  provider.dirMake( path.join( context.testSuitePath, 'empty' ) )
  got = provider.filesFind({ filePath : path.join( testPath, 'empty' ), includingTerminals : 1, includingTransient : 1, includingStem : 0, allowingMissed : 1 });
  test.identical( got, [] );

  /*terminalPath - empty dir, includingTerminals, includingTransient off*/

  provider.dirMake( path.join( context.testSuitePath, 'empty' ) )
  got = provider.filesFind({ filePath : path.join( testPath, 'empty' ), includingTerminals : 0, includingTransient : 0, allowingMissed : 1 });
  test.identical( got, [] );

  /*terminalPath - directory, includingTerminals, includingTransient on*/

  got = provider.filesFind({ filePath : testPath, includingTerminals : 1, includingTransient : 1, includingStem : 0 });
  expected = provider.dirRead( testPath );
  test.identical( check( got, expected ), true );

  /*terminalPath - directory, includingTerminals, includingTransient off*/

  got = provider.filesFind({ filePath : testPath, includingTerminals : 0, includingTransient : 0 });
  expected = provider.dirRead( testPath );
  test.identical( got, [] );

  /*terminalPath - directory, includingTerminals off, includingTransient on*/

  got = provider.filesFind({ filePath : testPath, includingTerminals : 0, includingTransient : 1, includingStem : 0 });
  expected = provider.dirRead( testPath );
  test.identical( check( got, expected ), true  );

  /*terminalPath - terminal file, includingTerminals, includingTransient off*/

  terminalPath = path.join( testPath, 'terminal' );
  got = provider.filesFind({ filePath : terminalPath, includingTerminals : 0, includingTransient : 0 });
  expected = provider.dirRead( testPath );
  test.identical( got, [] );

  /*terminalPath - terminal file, includingTerminals off, includingTransient on*/

  terminalPath = path.join( testPath, 'terminal' );
  got = provider.filesFind({ filePath : terminalPath, includingTerminals : 0, includingTransient : 1 });
  test.identical( got, [] );

  //

  test.description = 'outputFormat option';

  /*terminalPath - directory, outputFormat absolute */

  got = provider.filesFind({ filePath : testPath, outputFormat : 'record' });
  function recordIs( element ){ return element.constructor.name === 'wFileRecord' };
  expected = provider.dirRead( testPath );
  test.identical( check( got, recordIs ), true );

  /*terminalPath - directory, outputFormat absolute */

  got = provider.filesFind({ filePath : testPath, outputFormat : 'absolute' });
  expected = provider.dirRead( testPath );
  // test.identical( check( got, path.isAbsolute ), true );
  test.identical( path.s.allAreAbsolute( got ), true );

  /*terminalPath - directory, outputFormat relative */

  got = provider.filesFind({ filePath : testPath, outputFormat : 'relative' });
  expected = provider.dirRead( testPath );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = path.join( './', expected[ i ] );
  test.identical( check( got, expected ), true );

  /*terminalPath - directory, outputFormat nothing */

  got = provider.filesFind({ filePath : testPath, outputFormat : 'nothing' });
  test.identical( got, [] );

  /*terminalPath - directory, outputFormat unexpected */

  test.shouldThrowErrorSync( function()
  {
    provider.filesFind({ filePath : testPath, outputFormat : 'unexpected' });
  })

  //

  test.description = 'result option';

  /*terminalPath - directory, result not empty array, all existing files must be skipped*/

  expected = provider.filesFind({ filePath : testPath, result : got });
  test.identical( got.length, expected.length );
  test.is( got === expected );

  /*terminalPath - directory, result empty array*/

  got = [];
  provider.filesFind({ filePath : testPath, result : got });
  expected = provider.dirRead( testPath );
  test.identical( check( got, expected ), true );

  /*terminalPath - directory, result object without push function*/

  test.shouldThrowErrorSync( function()
  {
    got = {};
    provider.filesFind({ filePath : testPath, result : got });
  });

  //

  test.description = 'masking'

  /*terminalPath - directory, maskTerminal, get all files with 'Files' in name*/

  got = provider.filesFind
  ({
    filePath : testPath,
    filter :
    {
      maskTerminal : 'Files',
    },
    outputFormat : 'relative'
  });
  expected = provider.dirRead( testPath );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.test( 'Files', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  test.identical( got, expected );

  /* terminalPath - directory, maskDirectory, includingTransient */

  terminalPath = path.join( context.testSuitePath, 'tmp/dir' );
  provider.dirMake( terminalPath );

  got = provider.filesFind
  ({
    filePath : terminalPath,
    filter :
    {
      basePath : path.dir( terminalPath ),
      maskDirectory : 'dir',
    },
    outputFormat : 'relative',
    includingStem : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2
  });
  expected = provider.dirRead( path.dir( terminalPath ) );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.test( 'dir', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  test.identical( got, expected );

  /*terminalPath - directory, maskAll with some random expression, no result expected */

  got = provider.filesFind
  ({
    filePath : testPath,
    filter :
    {
      maskAll : 'a12b',
    }
  });
  test.identical( got, [] );

  /*terminalPath - directory, orderingExclusion mask, maskTerminal null, expected order Caching->terminals*/

  var orderingExclusion = [ 'src', 'dir3' ];
  got = provider.filesFind
  ({
    filePath : testPath,
    orderingExclusion : orderingExclusion,
    includingDirs : 1,
    // maskTerminal : null,
    recursive : 1,
    outputFormat : 'record'
  });
  got = got.map( ( r ) => r.relative );
  expected = _orderingExclusion( provider.dirRead( testPath ), orderingExclusion );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  test.identical( got, expected )

  //

  test.description = 'change relative path in record';

  /*change relative to wFiles, relative should be like ./staging/dwtools/amid/files/z.test/'file_name'*/

  var relative = path.join( testPath, 'src' );
  got = provider.filesFind
  ({
    filePath : path.join( testPath, 'src/dir' ),
    filter : { basePath : relative },
    recursive : 1
  });
  got = got[ 0 ].relative;
  var begins = './' + path.relative( relative, path.join( testPath, 'src/dir' ) );
  test.identical( _.strBegins( got, begins ), true );

  /* changing relative path affects only record.relative*/

  got = provider.filesFind
  ({
    filePath : testPath,
    filter :
    {
      basePath : '/x/a/b',
    },
    recursive : 2,
    maskPreset : 0,
  });

  test.identical( _.strBegins( got[ 0 ].absolute, '/x' ), false );
  test.identical( _.strBegins( got[ 0 ].real, '/x' ), false );
  test.identical( _.strBegins( got[ 0 ].dir, '/x' ), false );

  //

  test.description = 'etc';

  /*strict mode on - prevents extension of wFileRecord*/

  test.shouldThrowErrorSync( function()
  {
    var records = provider.filesFind( testPath );
    records[ 0 ].newProperty = 1;
  })

  /*strict mode off */

  // test.mustNotThrowError( function()
  // {
  //   var records = provider.filesFind({ filePath : dir/*, strict : 0*/ });
  //   records[ 0 ].newProperty = 1;
  // })


}

filesFind2.timeOut = 15000;

//

function filesFindRecursive( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs( filePath )
  {
    return path.s.join( testPath, filePath )
  }

  var extract = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', dir : { a1 : '1' } },
      src2 : { ax2 : '20', dirx : { a : '20' } },
    },
  });

  extract.filesReflectTo( provider, testPath );

  /**/

  test.open( 'directory' );

  var got = provider.filesFind
  ({
    filePath : testPath,
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 0,
  })
  test.identical( got, [ '.' ] )

  var got = provider.filesFind
  ({
    filePath : testPath,
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 1,
  })
  var expected = [ '.', './src', './src2' ]
  test.identical( got, expected );

  var got = provider.filesFind
  ({
    filePath : testPath,
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 2,
  })
  var expected = [ '.', './src', './src/a1', './src/dir', './src/dir/a1', './src2', './src2/ax2', './src2/dirx', './src2/dirx/a' ]
  test.identical( got, expected );

  test.close( 'directory' );

  /* */

  test.open( 'terminal' );

  var got = provider.filesFind
  ({
    filePath : path.join( testPath, './src/a1' ),
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : path.join( testPath, './src' ) },
    recursive : 0,
  })
  var expected = [ './a1' ]

  var got = provider.filesFind
  ({
    filePath : abs( './src/a1' ),
    filter : { basePath : abs( './src' ) },
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 1,
  })
  var expected = [ './a1' ]
  test.identical( got, expected );

  //

  var got = provider.filesFind
  ({
    filePath : path.join( testPath, './src/a1' ),
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : path.join( testPath, './src' ) },
    recursive : 2,
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
      filePath : path.join( testPath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '0',
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( testPath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '1',
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( testPath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '2',
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( testPath ),
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
      filePath : path.join( testPath ),
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
      filePath : path.join( testPath ),
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
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  /*
    link : [ normal, double, broken, context cycled, cycled, dst and src resolving to the same file ]
  */

  //

  function select( container, path )
  {
    let result = _.select( container, path );
    if( _.strIs( result[ 0 ] ) )
    result = result.map( ( e ) => _.strPrependOnce( _.strRemoveBegin( e, testPath ), '/' ) );
    return result;
  }

  //

  let terminalPath = path.join( testPath, 'terminal' );
  let normalPath = path.join( testPath, 'normal' );
  let doublePath = path.join( testPath, 'double' );
  let brokenPath = path.join( testPath, 'broken' );
  let missingPath = path.join( testPath, 'missing' );
  let autoPath = path.join( testPath, 'auto' );
  let onePath = path.join( testPath, 'one' );
  let twoPath = path.join( testPath, 'two' );
  let normalaPath = path.join( testPath, 'normala' );
  let normalbPath = path.join( testPath, 'normalb' );
  let dirPath = path.join( testPath, 'directory' );
  let toDirPath = path.join( testPath, 'toDir' );

  //

  test.open( 'normal' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
  }

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/terminal' ] );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  console.log( got[ 1 ].real );

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

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );
  context.provider.softLink( doublePath, normalPath );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/double', '/normal', '/terminal' ] );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
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

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );
  context.provider.softLink({ dstPath : brokenPath, srcPath : missingPath, allowingMissed : 1 });

  test.case = 'resolvingSoftLink : 0, allowingMissed : 0, allowingCycled : 0';

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 0,
    allowingMissed : 0,
    allowingCycled : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, true, true, true ] );

  test.case = 'resolvingSoftLink : 1, allowingMissed : 1, allowingCycled : 0';

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 1,
    allowingMissed : 1,
    allowingCycled : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/missing', '/terminal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, false, true, true ] );

  test.case = 'resolvingSoftLink : 1, allowingMissed : 0, allowingCycled : 1';

  test.shouldThrowErrorSync( () =>
  {
    var got = context.provider.filesFind
    ({
      filePath : testPath,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      includingDirs : 1,
      includingStem : 1,
      recursive : 2,
      resolvingSoftLink : 1,
      allowingMissed : 0,
      allowingCycled : 1,
    })
  });

  test.close( 'broken' );

  /* */

  test.open( 'context cycled' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    auto : [{ softLink : '/auto' }],
  }

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );
  context.provider.softLink({ dstPath : autoPath, srcPath : '../auto', allowingMissed : 1 });

  /* */

  test.case = 'resolvingSoftLink : 0, allowingMissed : 0, allowingCycled : 0';

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 0,
    allowingMissed : 0,
    allowingCycled : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/auto', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/auto', '/normal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, true, true, true ] );

  /* */

  test.case = 'resolvingSoftLink : 1, allowingMissed : 0, allowingCycled : 1';

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 1,
    allowingMissed : 0,
    allowingCycled : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/auto', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/auto', '/terminal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, true, true, true ] );

  /* */

  test.case = 'resolvingSoftLink : 1, allowingMissed : 1, allowingCycled : 0';

  test.shouldThrowErrorSync( () =>
  {
    var got = context.provider.filesFind
    ({
      filePath : testPath,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      includingDirs : 1,
      includingStem : 1,
      recursive : 2,
      resolvingSoftLink : 1,
      allowingMissed : 1,
      allowingCycled : 0,
    })
  });

  test.close( 'context cycled' );

  /* */

  test.open( 'cycled' );

  var tree =
  {
    terminal : 'terminal',
    one : [{ softLink : '/two' }],
    two : [{ softLink : '/one' }],
  }

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink({ dstPath : twoPath, srcPath : onePath, allowingMissed : 1 });
  context.provider.softLink({ dstPath : onePath, srcPath : twoPath, allowingMissed : 1 });

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 0,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : testPath,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissed : 0,
      includingDirs : 1,
      recursive : 2,
      includingStem : 1,
    })
  })

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    includingDirs : 1,
    recursive : 2,
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

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalaPath, terminalPath );
  context.provider.softLink( normalbPath, terminalPath );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normala', '/normalb', '/terminal' ] );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
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

  var terminalInDirPath = context.provider.path.join( dirPath, 'terminal' );

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  context.provider.softLink( toDirPath, dirPath );

  var got = context.provider.filesFind
  ({
    filePath : toDirPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir'  ] );
  test.identical( select( got, '*/real' ), [ '/toDir' ] );

  var got = context.provider.filesFind
  ({
    filePath : toDirPath,
    outputFormat : 'record',
    resolvingSoftLink : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
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

  var terminalInDirPath = context.provider.path.join( dirPath, 'terminal' );

  context.provider.filesDelete( testPath );
  context.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  context.provider.softLink( toDirPath, dirPath );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );

  var got = context.provider.filesFind
  ({
    filePath : testPath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/directory', '/directory/terminal', '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/directory', '/directory/terminal', '/directory', '/directory/terminal'  ] );

  test.close( 'link to processed directory' );
}

//

function filesFindResolving( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let terminalPath = path.join( testPath, 'terminal' );

  var softLinkIsSupported = context.softLinkIsSupported();

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
    includingDirs : 1,
    recursive : 2
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

  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 0 );

  //

  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 0 );

  //

  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 0 );

  //

  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 0';
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 0 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );


  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 0';
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 0 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 0,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 0,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

   //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text->text->terminal, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  var textLink2Path = path.join( testPath, 'textLink2' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  provider.fileWrite( textLink2Path, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var textLink2Stat = findRecord( files, 'absolute', textLink2Path ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, textLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  if( !softLinkIsSupported )
  return;

  /* soft link */

  test.case = 'soft link to a file, resolvingSoftLink : 0, resolvingTextLink : 0'
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var o2 = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( testPath, 'link' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  var files = provider.filesFind( o2 );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true,
    },
    {
      absolute : softLink,
      real : softLink,
      isDir : false,
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false,
    }
  ]
  test.identical( filtered, expected );
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.is( srcFileStat.ino !== softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a file, resolvingSoftLink : 1, resolvingTextLink : 0'
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( testPath, 'link' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]
  test.identical( filtered, expected );
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a file, resolvingSoftLink : 1, resolvingTextLink : 1'
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var softLink = path.join( testPath, 'link' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 0';
  var srcDirPath = path.join( testPath, 'dir' );
  var softLink = path.join( testPath, 'linkToDir' );
  provider.fieldPush( 'usingTextLink', 0 );
  provider.filesDelete( testPath );
  terminalPath = path.join( srcDirPath, 'terminal' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
    includingStem : 0
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.softLink( softLink, srcDirPath );

  var files = provider.filesFind(options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( softLink, path.name({ path : terminalPath, full : 1 }) ),
      real : path.join( srcDirPath, path.name({ path : terminalPath, full : 1 }) ),
      isDir : false
    }
  ]

  test.identical( filtered, expected )
  var srcDirStat = provider.statResolvedRead( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 1';
  var srcDirPath = path.join( testPath, 'dir' );
  var softLink = path.join( testPath, 'linkToDir' );
  provider.fieldPush( 'usingTextLink', 1 );
  provider.filesDelete( testPath );
  terminalPath = path.join( srcDirPath, 'terminal' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.softLink( softLink, srcDirPath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( softLink, path.name({ path : terminalPath, full : 1 }) ),
      real : path.join( srcDirPath, path.name({ path : terminalPath, full : 1 }) ),
      isDir : false
    }
  ]

  logger.log( _.toStr( files, { levels : 99 } )   )

  test.identical( filtered, expected )
  var srcDirStat = provider.statResolvedRead( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'multiple soft links in chain, resolvingSoftLink : 1, resolvingTextLink : 0'
  provider.filesDelete( testPath );
  terminalPath = path.join( testPath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( testPath, 'link' );
  var softLink2 = path.join( testPath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, softLink );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'multiple soft links in chain, resolvingSoftLink : 1, resolvingTextLink : 1'
  provider.filesDelete( testPath );
  terminalPath = path.join( testPath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var softLink = path.join( testPath, 'link' );
  var softLink2 = path.join( testPath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, softLink );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'multiple soft links to single file, resolvingSoftLink : 1, resolvingTextLink : 0'
  provider.filesDelete( testPath );
  terminalPath = path.join( testPath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( testPath, 'link' );
  var softLink2 = path.join( testPath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'multiple soft links to single file, resolvingSoftLink : 1, resolvingTextLink : 1'
  provider.filesDelete( testPath );
  terminalPath = path.join( testPath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var softLink = path.join( testPath, 'link' );
  var softLink2 = path.join( testPath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->terminal, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( testPath );
  terminalPath = path.join( testPath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( testPath, 'textLink' );
  var softLinkPath = path.join( testPath, 'softLinkPath' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  provider.softLink( softLinkPath, textLinkPath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
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
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->terminal, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  var srcDirPath = path.join( testPath, 'dir' );
  terminalPath = path.join( srcDirPath, 'terminal' );
  // terminalPath = path.join( srcDirPath, 'file' ); /* qqq : should be terminal. it confuses */
  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  var textLinkPath = path.join( testPath, 'textLink' );
  var softLinkPath = path.join( testPath, 'softLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : testPath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcDirPath );
  provider.softLink( softLinkPath, textLinkPath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : testPath,
      real : testPath,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLinkPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( softLinkPath, 'terminal' ),
      real : terminalPath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( textLinkPath, 'terminal' ),
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  console.log( _.toStr( filtered, { levels : 99 }))
  var srcDirStat = provider.statResolvedRead( srcDirPath );
  var srcFileStat = findRecord( files, 'absolute', terminalPath ).stat;
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcDirStat.ino, textLinkStat.ino );
  test.identical( srcDirStat.ino, softLinkStat.ino );
  test.is( srcFileStat.ino !== textLinkStat.ino )
  test.is( srcFileStat.ino !== softLinkStat.ino )
  provider.fieldPop( 'usingTextLink', 1 );

}

//

function filesFindResolvingExperiment( test )
{
  let context = this;
  let provider = context.provider;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  test.case = 'textLink->dir, resolvingTextLink : 1, usingTextLink : 1';
  let srcDirPath = path.join( testPath, 'dir' );
  let terminalPath = path.join( srcDirPath, 'terminal' );
  let textLinkPath = path.join( testPath, 'textLink' );

  provider.filesDelete( testPath );
  provider.fileWrite( terminalPath, terminalPath );
  provider.fieldPush( 'usingTextLink', 1 );
  provider.textLink( textLinkPath, srcDirPath );

  var o =
  {
    filePath : textLinkPath,
    resolvingTextLink : 1,
    includingStem : 1,
    includingTerminals : 1,
    includingTransient : 1,
    includingDirs : 1,
    recursive : 2
  }

  var files = provider.filesFind( o );

  provider.fieldPop( 'usingTextLink', 1 );


}

//

function filesFindPerformance( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  test.description = 'filesFind time test';

  /*prepare files */

  var dir = path.join( context.testSuitePath, test.name );
  var provider = _.FileProvider.HardDrive();

  var filesNumber = 2000;
  var levels = 5;

  if( !_.fileProvider.statResolvedRead( dir ) )
  {
    logger.log( 'Creating ', filesNumber, ' random files tree. ' );
    var t1 = _.timeNow();
    for( var i = 0; i < filesNumber; i++ )
    {
      terminalPath = context._generatePath( dir, Math.random() * levels );
      provider.fileWrite({ filePath : terminalPath, data : 'abc', writeMode : 'rewrite' } );
    }

    logger.log( _.timeSpent( 'Spent to make ' + filesNumber +' files tree', t1 ) );
  }

  var times = 10;

  /* default filesFind */

  var t2 = _.timeNow();
  for( var i = 0; i < times; i++)
  {
    var files = provider.filesFind
    ({
      filePath : dir,
      recursive : 2
    });
  }

  logger.log( _.timeSpent( 'Spent to make  provider.filesFind x' + times + ' times in dir with ' + filesNumber +' files tree', t2 ) );

  test.identical( files.length, filesNumber );

  /*stats filter filesFind*/

  // var filter = _.fileProvider.Caching({ original : filter, cachingDirs : 0 });
  // var times = 10;
  // var t2 = _.timeNow();
  // for( var i = 0; i < times; i++)
  // {
  //   filter.filesFind
  //   ({
  //     filePath : dir,
  //     recursive : 2
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
  //     recursive : 2
  //   });
  // }

  // logger.log( _.timeSpent( 'Spent to make filesFind with three filters x' + times + ' times in dir with ' + filesNumber +' files tree', t2 ) );

  // test.identical( files.length, filesNumber );
}

filesFindPerformance.timeOut = 150000;
filesFindPerformance.rapidity = 1;

//

function filesFindGlob( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  var src = context.makeStandardExtract();
  src.filesReflectTo( provider, testPath );

  var onUp = function onUp( record )
  {
    if( record.isTransient )
    onUpRelativeTransients.push( record.relative );
    if( record.isActual )
    onUpRelativeActuals.push( record.relative );
    return record;
  }

  var onDown = function onDown( record )
  {
    if( record.isTransient )
    onDownRelativeTransients.push( record.relative );
    if( record.isActual )
    onDownRelativeActuals.push( record.relative );
    return record;
  }

  function selectTransients( records )
  {
    return _.filter( records, ( record ) => record.isTransient ? record.relative : undefined );
  }

  function selectActuals( records )
  {
    return _.filter( records, ( record ) => record.isActual ? record.relative : undefined );
  }

  var onUpRelativeTransients = [];
  var onUpRelativeActuals = [];
  var onDownRelativeTransients = [];
  var onDownRelativeActuals = [];

  function clean()
  {
    onUpRelativeTransients = [];
    onUpRelativeActuals = [];
    onDownRelativeTransients = [];
    onDownRelativeActuals = [];
  }

  function abs( filePath )
  {
    return path.s.join( testPath, filePath )
  }

  var globTerminals = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : testPath },
  });

  var globAll = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : testPath },
  });

  /* - */

  test.open( 'extended' );

  test.case = 'globTerminals src1/**'; /* */

  clean();

  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnUpAbsoluteTransients = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteTransients = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnUpAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globAll src1/**';

  clean();

  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnUpAbsoluteTransients = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteTransients = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1/d', './src1' ];
  var expectedOnUpAbsoluteActuals = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1/d', './src1' ];
  var records = globAll( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globTerminals src1/** relative';

  clean();

  var expectedRelative = [ './src1/a', './src1/b', './src1/c' ];
  var expectedOnUpAbsoluteTransients = [];
  var expectedOnDownAbsoluteTransients = [];
  var expectedOnUpAbsoluteActuals = [ './src1/a', './src1/b', './src1/c' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c' ];
  var records = globTerminals({ filePath : '*', filter : { prefixPath : abs( 'src1' ) } });
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globAll src1/** relative';

  clean();

  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d' ];
  var expectedOnUpAbsoluteTransients = [ './src1', './src1/d' ];
  var expectedOnDownAbsoluteTransients = [ './src1/d', './src1' ];
  var expectedOnUpAbsoluteActuals = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d', './src1' ];
  var records = globAll({ filePath : '*', filter : { prefixPath : abs( 'src1' ) } });
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.close( 'extended' );

  /* - */

  test.case = 'globTerminals doubledir/*/*';

  clean();
  var expectedRelative = [ './doubledir/a', './doubledir/d1/a', './doubledir/d2/b' ];
  var records = globTerminals({ filePath : abs( 'doubledir/*/*' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll doubledir/*/*';

  clean();
  var expectedRelative = [ './doubledir', './doubledir/a', './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22' ];
  var records = globAll({ filePath : abs( 'doubledir/*/*' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.case = 'globTerminals src1';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals({ filePath : abs( 'src1' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1';

  clean();
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll({ filePath : abs( 'src1' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**, prefixPath : /src2';

  clean();
  var expAbsolutes = [];
  var expIsActual = [];
  var expIsTransient = [];
  var expStat = [];
  var records = globTerminals({ filePath : 'src1/**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotIsActual = _.select( records, '*/isActual' );
  var gotIsTransient = _.select( records, '*/isTransient' );
  var gotStat = _.select( records, '*/stat' ).map( ( e ) => !!e );
  test.identical( gotRelative, expAbsolutes );
  test.identical( gotIsActual, expIsActual );
  test.identical( gotIsTransient, expIsTransient );
  test.identical( gotStat, expStat );

  test.case = 'globAll src1/**, prefixPath : /src2';

  clean();
  var expectedRelative = [];
  var records = globAll({ filePath : 'src1/**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**';

  clean();
  var expectedRelative = [ './a', './b', './c', './d/a', './d/b', './d/c' ];
  var records = globTerminals({ filePath : './**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**';

  clean();
  var expectedRelative = [ '.', './a', './b', './c', './d', './d/a', './d/b', './d/c' ];
  var records = globAll({ filePath : './**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals (src1|src2)/**';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filePath : '(src1|src2)/**', filter : { prefixPath : abs( '.' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll (src1|src2)/**';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filePath : '(src1|src2)/**', filter : { prefixPath : abs( '.' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**';

  clean();
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1**'; /* */

  clean();
  var expectedRelative = [ './src1Terminal', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1b/a' ];
  var records = globTerminals( abs( 'src1**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1**';

  clean();
  var expectedRelative = [ '.', './src1Terminal', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src1b', './src1b/a' ];
  var records = globAll( abs( 'src1**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1/*'; /* */

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c' ];
  var records = globTerminals( abs( 'src1/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/*';

  clean();
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d' ];
  var records = globAll( abs( 'src1/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1*'; /* */

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals( abs( 'src1*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1*';

  clean();
  var expectedRelative = [ '.', './src1Terminal', './src1', './src1b' ];
  var records = globAll( abs( 'src1*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src3/** - nothing'; /* */

  clean();
  var expectedRelative = [];
  var records = globTerminals( abs( 'src3/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src3/** - nothing';

  clean();
  var expectedRelative = [];
  var records = globAll( abs( 'src3/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src?'; /* */

  clean();
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( 'src?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src?';

  clean();
  var expectedRelative = [ '.', './srcT', './src1', './src2' ];
  var records = globAll( abs( 'src?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src?*'; /* */

  clean();
  var expectedRelative = [ './src1Terminal', './srcT' ];
  var records = globTerminals( abs( 'src?*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src?*';

  clean();
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( 'src?*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src*?'; /* */

  clean();
  var expectedRelative = [ './src1Terminal', './srcT' ];
  var records = globTerminals( abs( 'src*?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src*?';

  clean();
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( 'src*?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src**?'; /* */

  clean();
  var expectedRelative = [ './src1Terminal', './srcT', './src/f', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1b/a', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d/a', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d/a' ];
  var records = globTerminals( abs( 'src**?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src**?';

  clean();
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src', './src/f', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src1b', './src1b/a', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d', './src3.js/d/a', './src3.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d', './src3.s/d/a' ];
  var records = globAll( abs( 'src**?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src?**'; /* */

  clean();
  var expectedRelative = [ './src1Terminal', './srcT', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1b/a', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d/a', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d/a' ];
  var records = globTerminals( abs( 'src?**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src?**';

  clean();
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src1b', './src1b/a', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d', './src3.js/d/a', './src3.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d', './src3.s/d/a' ];
  var records = globAll( abs( 'src?**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +(src)2'; /* */

  clean();
  var expectedRelative = [];
  var records = globTerminals( abs( '+(src)2' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +(src)2';

  clean();
  var expectedRelative = [ '.', './src2' ];
  var records = globAll( abs( '+(src)2' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +(alt)/*'; /* */

  clean();
  var expectedRelative = [ './alt/a', './altalt/a' ];
  var records = globTerminals( abs( '+(alt)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +(alt)/*';

  clean();
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './altalt', './altalt/a', './altalt/d' ];
  var records = globAll( abs( '+(alt)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +(alt|ctrl)/*'; /* */

  clean();
  var expectedRelative = [ './alt/a', './altalt/a', './altctrl/a', './altctrlalt/a', './ctrl/a', './ctrlctrl/a' ]
  var records = globTerminals( abs( '+(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +(alt|ctrl)/*';

  clean();
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './altalt', './altalt/a', './altalt/d', './altctrl', './altctrl/a', './altctrl/d', './altctrlalt', './altctrlalt/a', './altctrlalt/d', './ctrl', './ctrl/a', './ctrl/d', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d' ];
  var records = globAll( abs( '+(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *(alt|ctrl)/*'; /* */

  clean();
  var expectedRelative = [ './alt/a', './altalt/a', './altctrl/a', './altctrlalt/a', './ctrl/a', './ctrlctrl/a' ];
  var records = globTerminals( abs( '*(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *(alt|ctrl)/*';

  clean();
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './altalt', './altalt/a', './altalt/d', './altctrl', './altctrl/a', './altctrl/d', './altctrlalt', './altctrlalt/a', './altctrlalt/d', './ctrl', './ctrl/a', './ctrl/d', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d' ];
  var records = globAll( abs( '*(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt*(alt|ctrl)?/*'; /* */

  clean();
  var expectedRelative = [ './alt2/a', './altalt2/a', './altctrl2/a', './altctrlalt2/a' ];
  var records = globTerminals( abs( 'alt*(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt*(alt|ctrl)?/*';

  clean();
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './altalt2', './altalt2/a', './altalt2/d', './altctrl2', './altctrl2/a', './altctrl2/d', './altctrlalt2', './altctrlalt2/a', './altctrlalt2/d' ];
  var records = globAll( abs( 'alt*(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *(alt|ctrl|2)/*'; /* */

  clean();
  var expectedRelative = [ './alt/a', './alt2/a', './altalt/a', './altalt2/a', './altctrl/a', './altctrl2/a', './altctrlalt/a', './altctrlalt2/a', './ctrl/a', './ctrl2/a', './ctrlctrl/a', './ctrlctrl2/a' ];
  var records = globTerminals( abs( '*(alt|ctrl|2)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *(alt|ctrl|2)/*';

  clean();
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './alt2', './alt2/a', './alt2/d', './altalt', './altalt/a', './altalt/d',
    './altalt2', './altalt2/a', './altalt2/d', './altctrl', './altctrl/a', './altctrl/d', './altctrl2', './altctrl2/a', './altctrl2/d',
    './altctrlalt', './altctrlalt/a', './altctrlalt/d', './altctrlalt2', './altctrlalt2/a', './altctrlalt2/d', './ctrl', './ctrl/a',
    './ctrl/d', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/a', './ctrlctrl2/d' ];
  var records = globAll( abs( '*(alt|ctrl|2)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt?(alt|ctrl)?/*'; /* */

  clean();
  var expectedRelative = [ './alt2/a', './altalt2/a', './altctrl2/a' ];
  var records = globTerminals( abs( 'alt?(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt?(alt|ctrl)?/*';

  clean();
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './altalt2', './altalt2/a', './altalt2/d', './altctrl2', './altctrl2/a', './altctrl2/d' ];
  var records = globAll( abs( 'alt?(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt!(alt|ctrl)?/*'; /* */

  clean();
  var expectedRelative = [ './alt2/a' ];
  var records = globTerminals( abs( 'alt!(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt!(alt|ctrl)?/*';

  clean();
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d' ];
  var records = globAll( abs( 'alt!(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt!(ctrl)?/*'; /* */

  clean();
  var expectedRelative = [ './alt2/a', './altalt/a', './altalt2/a' ];
  var records = globTerminals( abs( 'alt!(ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt!(ctrl)?/*';

  clean();
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './altalt', './altalt/a', './altalt/d', './altalt2', './altalt2/a', './altalt2/d' ];
  var records = globAll( abs( 'alt!(ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals @(alt|ctrl)?/*'; /* */

  clean();
  var expectedRelative = [ './alt2/a', './ctrl2/a' ];
  var records = globTerminals( abs( '@(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll @(alt|ctrl)?/*';

  clean();
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './ctrl2', './ctrl2/a', './ctrl2/d' ];
  var records = globAll( abs( '@(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *([c-s])?';

  clean();
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '*([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *([c-s])?';

  clean();
  var expectedRelative = [ '.', './srcT', './src', './src1', './src2' ];
  var records = globAll( abs( '*([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([c-s])?';

  clean();
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '+([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([c-s])?';

  clean();
  var expectedRelative = [ '.', './srcT', './src', './src1', './src2' ];
  var records = globAll( abs( '+([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([lrtc])';

  clean();
  var expectedRelative = [];
  var records = globTerminals( abs( '.' ), '+([lrtc])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([lrtc])';

  clean();
  var expectedRelative = [ '.', './ctrl', './ctrlctrl' ];
  var records = globAll( abs( '.' ), '+([lrtc])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([^lt])';

  clean();
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '.' ), '+([^lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([^lt])';

  clean();
  var expectedRelative = [ '.', './srcT', './src', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( '.' ), '+([^lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.case = 'globTerminals +([!lt])';

  clean();
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '.' ), '+([!lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([!lt])';

  clean();
  var expectedRelative = [ '.', './srcT', './src', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( '.' ), '+([!lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals doubledir/d1/d11/*';

  clean();
  var expectedRelative = [ './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var records = globTerminals( abs( '.' ), 'doubledir/d1/d11/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll doubledir/d1/d11/*';

  clean();
  var expectedRelative = [ './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var records = globAll( abs( '.' ), 'doubledir/d1/d11/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**/*';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( '.' ), 'src1/**/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**/*';

  clean();
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll( abs( '.' ), 'src1/**/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals **/*.s';

  clean();
  var expectedRelative = [ './src3.js/b.s', './src3.s/b.s' ];
  var records = globTerminals( abs( '.' ), '**/*.s' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **/*.s';

  clean();
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/b.s', './src3.js/d', './src3.s', './src3.s/b.s', './src3.s/d' ];
  var records = globAll( abs( '.' ), '**/*.s' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals **/*.js';

  clean();
  var expectedRelative = [ './src3.js/c.js', './src3.s/c.js' ];
  var records = globTerminals( abs( '.' ), '**/*.js' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **/*.js';

  clean();
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/c.js', './src3.js/d', './src3.s', './src3.s/c.js', './src3.s/d' ];
  var records = globAll( abs( '.' ), '**/*.js' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals **.s/*';

  clean();
  var expectedRelative = [ './src3.js/b.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js' ];
  var records = globTerminals( abs( '.' ), '**.s/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **.s/*';

  clean();
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/b.s', './src3.js/d', './src3.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d' ];
  var records = globAll( abs( '.' ), '**.s/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**';

  clean();
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1Terminal/**';

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals( './src1Terminal/**' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/**';

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll( abs( 'src1Terminal/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with options map';

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals({ filePath : './src1Terminal/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with options map';

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll({ filePath : './src1Terminal/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath and prefixPath';

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals({ filePath : './**', filter : { basePath : '.', prefixPath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath and prefixPath';

  clean();
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll({ filePath : './**', filter : { basePath : '.', prefixPath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal with basePath and relative filePath';

  clean();
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : '.', filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal with basePath and relative filePath';

  clean();
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : '.', filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal with basePath and absolute filePath';

  clean();
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal with basePath and absolute filePath';

  clean();
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath';

  clean();
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath';

  clean();
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** without basePath and prefixPath';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null, prefixPath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** without basePath and prefixPath';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null, prefixPath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** without basePath';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** without basePath';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ] );
  var expectedRelative = [ '../a', './b', './c' ];
  var records = globTerminals({ filePath : [ abs( './doubledir/d1/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ] );
  var expectedRelative = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filePath : [ abs( './doubledir/d1/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolute = path.s.join( testPath, [ './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ] );
  var expectedRelative = [ '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : [ abs( './doubledir/d2/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedRelative = [ './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var expectedRelative = [ '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : [ abs( './doubledir/d2/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [c-s][c-s][c-s][0-9]/**';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '[c-s][c-s][c-s][0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [c-s][c-s][c-s][0-9]/**';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '[c-s][c-s][c-s][0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *([c-s])[0-9]/**';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '*([c-s])[0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *([c-s])[0-9]/**';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '*([c-s])[0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([crs1])/**/+([abc])';

  clean();
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '+([crs1])/**/+([abc])' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([crs1])/**/+([abc])';

  clean();
  var expectedRelative = [ '.', './src', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '+([crs1])/**/+([abc])' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals **/d11/*';

  clean();
  var expectedRelative = [ './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '**/d11/*' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **/d11/*';

  clean();
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/d', './src3.s', './src3.s/d' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '**/d11/*' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals filePath : **, prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11';

  clean();
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '../a', './b', './c' ];
  var records = globTerminals({ filter : { filePath : '**', prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : **, prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11';

  clean();
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filter : { filePath : '**', prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, no filePath';

  clean();
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '../a', './b', './c' ];
  var records = globTerminals({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, no filePath';

  clean();
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'globTerminals prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, filePath:b';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/d11/b' ]);
  var expectedRelative = [ './b' ];
  var records = globTerminals({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) }, filePath : 'b' });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, filePath:b';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b' ]);
  var expectedRelative = [ '..', '.', './b' ];
  var records = globAll({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) }, filePath : 'b' });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.open( 'base marker *()' );

  /* - */

  test.case = 'globTerminals src1*()';

  clean();
  var expectedRelative = [];
  var records = globTerminals({ filePath : './src1*()' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1*()';

  clean();
  var expectedRelative = [ '.', './src1' ];
  var records = globAll({ filePath : './src1*()' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/a*()';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './src1/a*()' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/a*()';

  clean();
  var expectedRelative = [ './src1', './src1/a' ];
  var records = globAll({ filePath : './src1/a*()' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/*()a';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './src1/*()a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/*()a';

  clean();
  var expectedRelative = [ './src1', './src1/a' ];
  var records = globAll({ filePath : './src1/*()a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals *()src1/a';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './*()src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *()src1/a';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var records = globAll({ filePath : './*()src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals sr*()c1/a';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './sr*()c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll sr*()c1/a';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var records = globAll({ filePath : './sr*()c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'base marker *()' );

  test.open( 'base marker \\0' );

  /* - */

  test.case = 'globTerminals src1\\0';

  clean();
  var expectedRelative = [];
  var records = globTerminals({ filePath : './src1\0' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1\\0';

  clean();
  var expectedRelative = [ '.', './src1' ];
  var records = globAll({ filePath : './src1\0' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/a\\0';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './src1/a\0' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/a\\0';

  clean();
  var expectedRelative = [ './src1', './src1/a' ];
  var records = globAll({ filePath : './src1/a\0' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals \\0src1/a';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './\0src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll \\0src1/a';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var records = globAll({ filePath : './\0src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals sr\\0c1/a';

  clean();
  var expectedRelative = [ './src1/a' ];
  var records = globTerminals({ filePath : './sr\0c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll sr\\0c1/a';

  clean();
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var records = globAll({ filePath : './sr\0c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'base marker \\0' );

  test.open( 'several paths' );

  /* - */

  test.case = 'globTerminals [ /src1/d/**, /src2/d/** ]';

  clean();
  var expectedRelative = [ './src1/d/a', './src1/d/b', './src1/d/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filePath : [ './src1/d/**', './src2/d/**' ] });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /src1/d/**, /src2/d/** ]';

  clean();
  var expectedRelative = [ './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filePath : [ './src1/d/**', './src2/d/**' ] });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ], no options map';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ], no options map';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll([ './doubledir/d1/**', './doubledir/d2/**' ]);
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ]';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ]';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals( { filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : testPath } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll({ filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : testPath } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:empty';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:empty';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  // if( Config.debug )
  // {
  //
  //   test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:.';
  //   clean();
  //   test.shouldThrowErrorSync( () => globTerminals( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '.' } } ) );
  //
  //   test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:.';
  //   clean();
  //   test.shouldThrowErrorSync( () => globAll( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '.' } } ) );
  //
  // }

  // zzz

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:.';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '.' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:.';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '.' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  // zzz

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:+/doubledir';

  clean();
  var expectedAbsolute = abs([]);
  var expectedRelative = [];
  var records = globTerminals({ filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : './doubledir' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:+/doubledir';

  clean();
  var expectedAbsolute = abs([]);
  var expectedRelative = [];
  var records = globAll({ filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : './doubledir' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './d1/a', './d1/d11/b', './d1/d11/c', './d2/b', './d2/d22/c', './d2/d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : abs( './doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './d1', './d1/a', './d1/d11', './d1/d11/b', './d1/d11/c', './d2', './d2/b', './d2/d22', './d2/d22/c', './d2/d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : abs( './doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { prefixPath : null, basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { prefixPath : null, basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals [ /ctrl/**, /ctrlctrl/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolute = abs([ './ctrl/a', './ctrl/d/a', './ctrlctrl/a', './ctrlctrl/d/a' ]);
  var expectedRelative = [ './a', './d/a', './a', './d/a' ];
  var records = globTerminals({ filePath : abs([ './ctrl/**', './ctrlctrl/**' ]), filter : { prefixPath : null, basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /ctrl/**, /ctrlctrl/** ] with prefixPath:null, basePath : null';

  clean();
  var expectedAbsolute = abs([ './ctrl', './ctrl/a', './ctrl/d', './ctrl/d/a', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d', './ctrlctrl/d/a' ]);
  var expectedRelative = [ '.', './a', './d', './d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs([ './ctrl/**', './ctrlctrl/**' ]), filter : { prefixPath : null, basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', './c', '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { prefixPath : null, basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', './c', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { prefixPath : null, basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* zzz */

  test.case = 'globTerminals **b** : 0, prefixPath : [ /doubledir/d1, /doubledir/d2 ], basePath:/doubledir/d1';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1/d11/b', './doubledir/d2/b' ]);
  var expectedRelative = [ './b', '../../d2/b' ];
  var records = globTerminals({ filePath : '**b**', filter : { prefixPath : abs([ './doubledir/d1', './doubledir/d2' ]), basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **b** : 0, prefixPath : [ /doubledir/d1, /doubledir/d2 ], basePath:/doubledir/d1';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22' ]);
  var expectedRelative = [ '..', '.', './b', '../../d2', '../../d2/b', '../../d2/d22' ];
  var records = globAll({ filePath : '**b**', filter : { prefixPath : abs([ './doubledir/d1', './doubledir/d2' ]), basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* zzz */

  test.close( 'several paths' );

  /* - */

  test.open( 'glob map' );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : null, /doubledir/d2/** : null, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : null, /doubledir/d2/** : null, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([]);
  var expectedRelative = [];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22' ]);
  var expectedRelative = [ '..', '.', '../../d2', '../../d2/d22' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**c** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d2/b', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', '../../d2/b', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**c**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**c** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**c**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([]);
  var expectedRelative = [];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ 'doubledir/d1', 'doubledir/d1/d11', 'doubledir/d2', 'doubledir/d2/d22' ]);
  var expectedRelative = [ '..', '.', '../../d2', '../../d2/d22' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, /doubledir/**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, [ abs( './doubledir/**b**' ) ] : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, /doubledir/**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';

  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, [ abs( './doubledir/**b**' ) ] : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with basePath:/doubledir/d1/d11';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '**b**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath : [ ../../d1, ../../d2 ], basePath:/doubledir/d1/d11';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '**b**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals filePath : { . : 1, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { '.' : 1, '**b**' : 0 }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { . : 1, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  clean();
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { '.' : 1, '**b**' : 0 }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : './doubledir/d1/d11' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : null, /alt2** : null }';

  clean();
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './ctrl2/**' : null, './alt2**' : null }), filter : { prefixPath : null, basePath : null } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : null, /alt2** : null }';

  clean();
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './alt2**' : null, './ctrl2/**' : null }), filter : { prefixPath : null, basePath : null } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : 1, /alt2** : 1 }';

  clean();
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './ctrl2/**' : 1, './alt2**' : 1 }), filter : { prefixPath : null, basePath : null } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : 1, /alt2** : 1 }';

  clean();
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './alt2**' : 1, './ctrl2/**' : 1 }), filter : { prefixPath : null, basePath : null } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.close( 'glob map' );

  /* - */

}

filesFindGlob.timeOut = 300000;

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
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

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

  // var testPath = path.join( context.testSuitePath, test.name );

  // _.fileProvider.safe = 0; /* no */
  // _.FileProvider.Extract.readToProvider
  // ({
  //   dstProvider : _.fileProvider,
  //   dstPath : testPath,
  //   filesTree : filesTree,
  //   allowWrite : 1,
  //   allowDelete : 1,
  // });

  var extract1 = new _.FileProvider.Extract({ filesTree : filesTree });
  extract1.filesReflectTo( provider, testPath );

  var commonOptions  =
  {
    outputFormat : 'relative',
  }

  function completeOptions( glob )
  {
    var options = _.mapExtend( null, commonOptions );
    options.filePath = path.join( testPath, glob );
    return options
  }

  /* - */

  test.case = 'simple glob';

  var glob = '*';
  var got = provider.filesGlob( completeOptions( glob ) );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt'
  ];
  test.identical( got, expected );

  var glob = '**'
  var got = provider.filesGlob( completeOptions( glob ) );
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
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.js',
  ]
  test.identical( got, expected );

  var  glob = 'a/a.*';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
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
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.js',
  ]
  test.identical( got, expected );

  var  glob = 'a/[!cb].s';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.s',
  ]
  test.identical( got, expected );

  /**/

  test.case = 'complex glob';

  var  glob = '**/a/a.?';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/a.s', './b/a/x/a/a.s'
  ]
  test.identical( got, expected );

  var  glob = '**/x/**/a.??';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './b/a/x/a/a.js',
    './b/a/x/a/a.ss',
  ]
  test.identical( got, expected );

  var  glob = '**/[!ab]/*.?s';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/c/c.js',
    './a/c/c.ss',
  ]
  test.identical( got, expected );

  var  glob = 'b/[a-c]/**/a/*';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
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
  var got = provider.filesGlob( options );
  var expected = [ './b/a/x/a/a.js', './b/a/x/a/a.s', './b/a/x/a/a.ss', './b/a/x/a/a.txt' ];
  test.identical( got, expected );

  /**/

  var glob = '**/*.s';
  var options =
  {
    filePath : path.join( testPath, 'a/c', glob ),
    outputFormat : 'relative',
    filter: { basePath : testPath }
  }
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/c/c.s',
  ]
  test.identical( got, expected );

  /**/

  /* {} are not supported, yet zzz */

  // var  glob = 'a/{x.*, a.*}';
  // var options = completeOptions( glob );
  // var got = provider.filesGlob( options );
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
  // var got = provider.filesGlob( options );
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
  // var got = provider.filesGlob( options );
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

function filesFindGroups( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs( filePath )
  {
    return path.s.join( testPath, filePath )
  }

  var filesTree =
  {
    'a.js' : 'a.js',
    'b.js' : 'b.js',
    'a.txt' : 'a.txt',
    'b.txt' : 'b.txt',
    'dir' :
    {
      'a.js' : 'dir/a.js',
      'b.js' : 'dir/b.js',
      'a.txt' : 'dir/a.txt',
      'b.txt' : 'dir/b.txt',
    }
  }

  var extract1 = new _.FileProvider.Extract({ filesTree : filesTree });
  extract1.filesReflectTo( provider, testPath );

  var expected =
  {
    'pathsGrouped' :
    {
      [ abs( 'Produced.txt' ) ] : { [ abs( '**.txt' ) ] : null },
      [ abs( 'Produced.js' ) ] : { [ abs( '**.js' ) ] : null }
    },
    'filesGrouped' :
    {
      [ abs( 'Produced.txt' ) ] :
      [
        './a.txt', './b.txt', './dir/a.txt', './dir/b.txt'
      ],
      [ abs( 'Produced.js' ) ] :
      [
        './a.js', './b.js', './dir/a.js', './dir/b.js'
      ]
    },
    'srcFiles' :
    {
      './a.txt' : './a.txt',
      './b.txt' : './b.txt',
      './dir/a.txt' : './dir/a.txt',
      './dir/b.txt' : './dir/b.txt',
      './a.js' : './a.js',
      './b.js' : './b.js',
      './dir/a.js' : './dir/a.js',
      './dir/b.js' : './dir/b.js',
    },
    'errors' : [],
    'options' : true,
  }
  var filePath =
  {
    '**.txt' : 'Produced.txt',
    '**.js' : 'Produced.js',
  }
  var src =
  {
    filePath : filePath,
    prefixPath : testPath,
  }

  var found = provider.filesFindGroups({ src : src, outputFormat : 'relative' });
  found.options = !!found.options;

  test.identical( found, expected );

}

//

function filesReflectEvaluate( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs( filePath )
  {
    return path.reroot( testPath, filePath );
  }

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir' :
      {
        a : 'dir/a',
        b : 'dir/b',
        c :
        {
          a : 'dir/c/a'
        }
      }
    },
  });

  test.case = 'setup';
  provider.filesDelete( testPath );
  extract1.filesReflectTo( provider, testPath );

  var o1 =
  {
    /*srcFilter*/src : abs( '/dir' ),
    /*dstFilter*/dst : abs( '/dir/dst' ),
  }

  var records = provider.filesReflectEvaluate( _.mapExtend( null, o1 ) );

  var expectedDstRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedSrcRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  var extract2 = provider.filesExtract( testPath );
  test.identical( extract2.filesTree, extract1.filesTree );

}

//

function filesReflectTrivial( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'deleting enabled, included files should be deleted'
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
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file2 : 'file2', dir : { file : 'file' } }
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/file2', '/dst/dir', '/dst/dir/file2' ];
  var expectedSrcAbsolute = [ '/src', '/src/file2', '/src/dir', '/src/dir/file2' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, false, true ];
  var expectedPreserve = [ true, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'deleting enabled, no filter';

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

  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    dst : { file : 'file', file2 : 'file2' }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'deleting disabled, separate filters'
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
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : 'file' }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst' ];
  var expectedSrcAbsolute = [ '/src' ];

  var expectedAction = [ 'dirMake' ];
  var expectedAllow = [ true ];
  var expectedPreserve = [ true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'deleting enabled, separate filters'
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
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : 'file' }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : {},
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/file', '/dst/dir/file2' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/file', '/src/dir/file2' ];

  var expectedAction = [ 'dirMake', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'src deleting enabled, no filter, all files from src should be deleted'
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
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    dst :
    {
      file : 'file',
      file2 : 'file2',
      dir : { file : 'file', file2 : 'file2' }
    }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'dst deleting enabled, no filter, all files from dst should be deleted'
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
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { file : 'file', file2 : 'file2' }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'deleting enabled, filtered files in dst are preserved'
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
    /*dstFilter*/dst :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file2 : 'file2' },
    dst : { file2 : 'file2', dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'dstDeleting:1 srcDeleting:0 /*dstFilter*/dst only'
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
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file2 : 'file2' },
    dst : { file2 : 'file2' },
  }
  test.identical( extract.filesTree, expectedTree )

  var expectedDstAbsolute = [ '/dst', '/dst/file2', '/dst/dir', '/dst/dir/file' ];
  var expectedSrcAbsolute = [ '/src', '/src/file2', '/src/dir', '/src/dir/file' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'src contains filtered file, directory must be preserved'
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
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, /*srcFilter*/src excludes file'
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
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, /*dstFilter*/dst excludes file'
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
    /*dstFilter*/dst :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file : 'file', dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, common filter excludes file'
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
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, no filters'
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
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file : 'file', dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'try to rewrite file.b, file should not be deleted, filter points only to file.a'
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
    /*srcFilter*/src : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

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
  test.identical( extract.filesTree, expectedTree );

  /*  */

  test.case = 'dst/srcfile-dstdir should not be deleted';
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
    /*srcFilter*/src : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 0,
    includingDst : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflect( o )

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
  test.identical( extract.filesTree, expectedTree );

  /*  */

  test.case = 'dst/srcfile-dstdir should be deleted';
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
    /*srcFilter*/src : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 1,
    includingDst : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflect( o )

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
  test.identical( extract.filesTree, expectedTree );

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
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    /*srcFilter*/src : { ends : '.b' },
    includingDst : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    writing : 1,
    dstRewriting : 1,
    dstDeleting : 0,
    srcDeleting : 1,
    dstRewritingByDistinct : 0
  }
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    'src' :
    {
      'dir' :
      {
        a : 'a',
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
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/file' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/file' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileDelete' ];
  var expectedAllow = [ true, true, false ];
  var expectedPreserve = [ true, true, false ];
  var expectedSrcAction = [ 'fileDelete', null, null ];
  var expectedSrcAllow = [ false, true, true ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'dstDeleting' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( srcAction, expectedSrcAction );
  test.identical( srcAllow, expectedSrcAllow );
  test.identical( reason, expectedReason );

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

  var extract = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    /*srcFilter*/src : { ends : '.b' },
    includingDst : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    writing : 1,
    dstRewriting : 1,
    dstDeleting : 0,
    srcDeleting : 1,
    dstRewritingByDistinct : 0
  }
  var records = extract.filesReflect( o );

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

  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/b.b', '/dst/dir/file' ]
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/b.b', '/src/dir/file' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileDelete' ];
  var expectedAllow = [ true, true, true, false ];
  var expectedPreserve = [ true, true, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete', null ];
  var expectedSrcAllow = [ false, true, true, true ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( srcAction, expectedSrcAction );
  test.identical( srcAllow, expectedSrcAllow );
  test.identical( reason, expectedReason );

  // //
  //
  // test.case = 'onUp should return original record'
  // var tree =
  // {
  //   'src' :
  //   {
  //      a : 'a',
  //      b : 'b'
  //   },
  //   'dst' :
  //   {
  //   },
  // }
  //
  // function onUp1( record )
  // {
  //   debugger;
  //   record.dst.absolute = record.dst.absolute + '.ext';
  //   return {};
  //   return null;
  // }
  //
  // var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  // var o =
  // {
  //   reflectMap : { '/src' : '/dst' },
  //   onUp : onUp1,
  //   includingDst : 0,
  //   includingTerminals : 1,
  //   includingDirs : 0,
  //   recursive : 2,
  //   writing : 1,
  //   srcDeleting : 0,
  //   linking : 'nop'
  // }
  //
  // test.shouldThrowError( () => extract.filesReflect( o ) );
  // test.identical( extract.filesTree, tree );
  //
  // debugger; return;
  //
  // //

  test.case = 'onUp changes dst path'
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

  var expectedTree =
  {
    'src' :
    {
       a : 'a',
       b : 'b'
    },
    'dst' :
    {
      'a.ext' : 'a',
      'b.ext' : 'b'
    },
  }

  function onUp2( record )
  {
    record.dst.absolute = record.dst.absolute + '.ext';
    return record;
  }

  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onUp : onUp2,
    includingDst : 0,
    includingTerminals : 1,
    includingDirs : 0,
    recursive : 2,
    writing : 1,
    srcDeleting : 0,
    // linking : 'nop'
  }

  extract.filesReflect( o );
  test.identical( extract.filesTree, expectedTree );

  //

  test.case = 'linking : nop, dst files will be deleted for rewriting after onWriteDstUp call'
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
    record.dst.factory.hubFileProvider.fileWrite( record.dst.absolute, 'onWriteDstUp' );
    return record;
  }

  var extract = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onWriteDstUp : onWriteDstUp1,
    /*srcFilter*/src : { maskTerminal : { includeAny : 'a' } },
    recursive : 2,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  extract.filesReflect( o )
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

  test.identical( extract.filesTree, expectedTree );

  //

  test.case = 'linking : nop, return _.dont from onWriteDstUp to prevent any action'
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
    record.dst.factory.hubFileProvider.fileWrite( record.dst.absolute, 'onWriteDstUp' );
    return _.dont;
  }

  var extract = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onWriteDstUp : onWriteDstUp2,
    /*srcFilter*/src : { maskTerminal : { includeAny : 'a' } },
    recursive : 2,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  extract.filesReflect( o )
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

  test.identical( extract.filesTree, expectedTree );

}  /* end of filesReflectTrivial */

//

function filesReflectRecursive( test )
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
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : 1,
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
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : 2,
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
  test.identical( provider.filesTree, expected );

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
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : 1,
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
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : 2,
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
  test.identical( provider.filesTree, expected );

  //

  if( Config.debug )
  {
    var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });

    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '0' }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '1' }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '2' }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : false }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : true }) );
  }
}

//

function filesReflectMutuallyExcluding( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  var precise = true;

  function abs( filePath )
  {
    return path.s.join( testPath, filePath )
  }

  function filesTreeAdapt( extract )
  {
    //simplifies trees comparison by converting terminals to strings

    if( !( provider instanceof _.FileProvider.HardDrive ) )
    return;

    extract.filesFindRecursive
    ({
      filePath : '/',
      includingTerminals : 1,
      includingDirs : 0,
      includingStem : 0,
      onDown : handleDown
    })

    function handleDown( record )
    {
      extract.fileWrite( record.absolute, extract.fileRead( record.absolute ) )
      return record;
    }
  }

  /* */

  test.case = 'terminals, no dst, exclude src root'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src' },
  }
  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { includeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { excludeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

  var expectedTree =
  {
    src : { src : 'src-src' },
    dst : { srcM : 'srcM-src' }
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/srcM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/srcM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];
  var expectedSrcAction = [ null, 'fileDelete' ];
  var expectedSrcAllow = [ true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'terminals, no dst, exclude dst root'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src' },
  }
  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

  var expectedTree =
  {
    src : { srcM : 'srcM-src' },
    dst : { src : 'src-src' }
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/src' ]);
  var expectedSrcAbsolute = abs([ './src', './src/src' ]);
  var expectedAction = [ 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ false, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'terminals'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src', bothM : 'bothM-src', both : 'both-src' },
    dst : { dstM : 'dstM', dst : 'dst', bothM : 'bothM', both : 'both' }
  }
  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

  var expectedTree =
  {
    src : { srcM : 'srcM-src', bothM : 'bothM-src' },
    dst : { dst : 'dst', both : 'both-src', src : 'src-src' }
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  // [
  //   './dst',
  //   './dst/both',
  //   './dst/src',
  //   './dst/bothM',
  //   './dst/dstM'
  // ]
  // [
  //   './dst',
  //   './dst/both',
  //   './dst/bothM',
  //   './dst/src',
  //   './dst/dst',
  //   './dst/dstM'
  // ]

  // [ 'dirMake', 'fileCopy', 'fileCopy', 'fileDelete', 'fileDelete' ]

/*
'./dst',
'./dst/both',
'./dst/bothM',
'./dst/src',
'./dst/dst',
'./dst/dstM'
*/

  // [ 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting' ]

  var expectedDstAbsolute = abs([ './dst', './dst/both', './dst/src', './dst/bothM', './dst/dst', './dst/dstM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/both', './src/src', './src/bothM', './src/dst', './src/dstM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileDelete', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting' ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', 'fileDelete', null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( reason, expectedReason );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'empty dirs';

  var tree =
  {
    src :
    {
      srcDirM : {}, srcPath : {}, bothDirM : {}, bothDir : {},
    },
    dst :
    {
      dstDirM : {}, dstPath : {}, bothDirM : {}, bothDir : {},
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var found = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'absolute' });
  test.identical( found.length, 11 );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  provider.filesDelete( testPath );

  var expectedTree =
  {
    src :
    {
      srcDirM : {}, bothDirM : {},
    },
    dst :
    {
      dstPath : {}, bothDir : {}, srcPath : {},
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/bothDir', './dst/srcPath', './dst/bothDirM', './dst/dstDirM', './dst/dstPath' ]);
  var expectedSrcAbsolute = abs([ './src', './src/bothDir', './src/srcPath', './src/bothDirM', './src/dstDirM', './src/dstPath' ]);
  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'fileDelete', 'fileDelete', 'ignore' ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting' ];
  var expectedAllow = [ true, true, true, true, true, false ];
  var expectedPreserve = [ true, true, false, false, false, true ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', 'fileDelete', null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var reason = _.select( records, '*/reason' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( reason, expectedReason );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'src dirs with two terms';

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
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

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
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/fM', './dst/fM/term' ]);
  var expectedSrcAbsolute = abs([ './src', './src/fM', './src/fM/term' ]);

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true ];
  var expectedPreserve = [ true, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete' ];
  var expectedSrcAllow = [ false, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );

    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'dst dirs with two terms';

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
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

  var expectedTree =
  {
    src :
    {
      dM : 'dst',
    },
    dst :
    {
      dM : { term : 'dst' },
      d : 'dst',
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/d', './dst/d/term', './dst/d/termM', './dst/dM', './dst/dM/term', './dst/dM/termM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/d', './src/d/term', './src/d/termM', './src/dM', './src/dM/term', './src/dM/termM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'dirMake', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'dst dirs with two terms';

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
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

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
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/d', './dst/d/term', './dst/d/termM', './dst/dM', './dst/dM/term', './dst/dM/termM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/d', './src/d/term', './src/d/termM', './src/dM', './src/dM/term', './src/dM/termM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'dirMake', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'src dirs with single term';

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
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

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
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  // var expectedDstAbsolute = abs([ './dst', './dst/dWithM', './dst/dWithoutM', './dst/dWithoutM/term' ]);
  var expectedDstAbsolute = abs([ './dst', './dst/dWithoutM', './dst/dWithoutM/term', './dst/dWithM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/dWithoutM', './src/dWithoutM/term', './src/dWithM' ]);

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete', null ];
  var expectedSrcAllow = [ false, true, true, true ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting' ];
  var expectedDeleteFirst = [ false, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );
  var reason = _.select( records, '*/reason' );
  var deleteFirst = _.select( records, '*/deleteFirst' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );

    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
    test.identical( reason, expectedReason );
    test.identical( deleteFirst, expectedDeleteFirst );
  }

  /* */

  test.case = 'dst dirs with single term';

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
      [ abs( './src' ) ] : abs( './dst' )
    },
    /*srcFilter*/src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    /*dstFilter*/dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, testPath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( testPath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( testPath );

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

  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/dWith', './dst/dWith/termM', './dst/dWithout', './dst/dWithout/term', './dst/dWithM', './dst/dWithM/termM', './dst/dWithoutM', './dst/dWithoutM/term' ]);
  var expectedSrcAbsolute = abs([ './src', './src/dWith', './src/dWith/termM', './src/dWithout', './src/dWithout/term', './src/dWithM', './src/dWithM/termM', './src/dWithoutM', './src/dWithoutM/term' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'dirMake', 'ignore' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, false ];
  var expectedPreserve = [ true, false, false, false, false, false, false, true, true ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

}

//

function filesReflectWithFilter( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

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

  context._filesReflectWithFilter( test, o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  context._filesReflectWithFilter( test, o );

}

//

function _filesReflectWithFilter( test, o )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function makeOptions()
  {
    var o1 =
    {
      reflectMap :
      {
        [ '/srcExt' ] : '/dstExt'
      },
      /*srcFilter*/src :
      {
        effectiveFileProvider : p.src,
        hasExtension : 'js',
      },
      /*dstFilter*/dst :
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

  test.case = 'trivial \n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.srcExt );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dstExt );

  var expectedDstAbsolute = [ '/dst', '/dst/c.js', '/dst/srcEmptyDir.js', '/dst/dstEmptyDir.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/c.js', '/src/srcEmptyDir.js', '/src/dstEmptyDir.js' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'trivial \n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/d1a', '/dst/d1a/d1b', '/dst/d1a/d1b/c.js', '/dst/d1a/d1b/b.js', '/dst/d2a', '/dst/d2a/d2b', '/dst/d2a/d2b/a.js', '/dst/d3a', '/dst/d3a/d3b', '/dst/d4a.js', '/dst/d4a.js/d4b.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/d1a', '/src/d1a/d1b', '/src/d1a/d1b/c.js', '/src/d1a/d1b/b.js', '/src/d2a', '/src/d2a/d2b', '/src/d2a/d2b/a.js', '/src/d3a', '/src/d3a/d3b', '/src/d4a.js', '/src/d4a.js/d4b.js' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'ignore', 'ignore', 'ignore', 'ignore' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, false, false, false, false ];
  var expectedPreserve = [ true, true, true, false, false, false, false, false, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'dir by term and vice-versa \n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dSrcDirDstFile', '/dst/dSrcDirDstFile/a.js', '/dst/dSrcFileDstDir', '/dst/dSrcFileDstDir/a.js', '/dst/dSrcFileDstDir/a.js/a.s', '/dst/dSrcFileDstDir2', '/dst/dSrcFileDstDir2/a', '/dst/dSrcFileDstDir2/a/a.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/dSrcDirDstFile', '/src/dSrcDirDstFile/a.js', '/src/dSrcFileDstDir', '/src/dSrcFileDstDir/a.js', '/src/dSrcFileDstDir/a.js/a.s', '/src/dSrcFileDstDir2', '/src/dSrcFileDstDir2/a', '/src/dSrcFileDstDir2/a/a.js' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, true, false, true, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

}

//

function filesReflect( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

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

  context._filesReflect( test, o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  context._filesReflect( test, o );

}

filesReflect.timeOut = 300000;

//

function _filesReflect( test, o )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function optionsMake()
  {
    var options =
    {
      reflectMap : { '/src' : '/dst' },
      /*srcFilter*/src : { effectiveFileProvider : p.src },
      /*dstFilter*/dst : { effectiveFileProvider : p.dst },
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

  test.case = 'complex move\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, true, false, false, false, false, false, false, false, true, false, true, false, false, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'dstRewriting', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( reason, expectedReason );

  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/a1' ), p.dst.path.globalFromLocal( '/dst/a1' ) ]), false );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/a1' ), p.src.path.globalFromLocal( '/src/a1' ) ]), false );
  test.identical( p.hub.filesAreHardLinked([ p.src.path.globalFromLocal( '/src/a1' ), p.dst.path.globalFromLocal( '/dst/a1' ) ]), false );
  test.identical( p.hub.filesAreHardLinked([ p.src.path.globalFromLocal( '/src/a1' ), p.src.path.globalFromLocal( '/src/a1' ) ]), true );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'softLink',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with linking : softLink\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : [{ softLink : p.src.path.globalFromLocal( '/src/a1' ) }], b : [{ softLink : p.src.path.globalFromLocal( '/src/b' ) }], c : [{ softLink : p.src.path.globalFromLocal( '/src/c' ) }], dir : { a2 : '2', a1 : [{ softLink : p.src.path.globalFromLocal( '/src/dir/a1' ) }], b : [{ softLink : p.src.path.globalFromLocal( '/src/dir/b' ) }], c : [{ softLink : p.src.path.globalFromLocal( '/src/dir/c' ) }] }, dirSame : { d : [{ softLink : p.src.path.globalFromLocal( '/src/dirSame/d' ) }] }, dir1 : { a1 : [{ softLink : p.src.path.globalFromLocal( '/src/dir1/a1' ) }], b : [{ softLink : p.src.path.globalFromLocal( '/src/dir1/b' ) }], c : [{ softLink : p.src.path.globalFromLocal( '/src/dir1/c' ) }] }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : [{ softLink : p.src.path.globalFromLocal( '/src/srcFile' ) }], dstFile : { f : [{ softLink : p.src.path.globalFromLocal( '/src/dstFile/f' ) }] } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'softLink', 'softLink', 'softLink', 'softLink', 'fileDelete', 'dirMake', 'softLink', 'softLink', 'softLink', 'dirMake', 'softLink', 'softLink', 'softLink', 'dirMake', 'dirMake', 'dirMake', 'softLink', 'dirMake', 'softLink' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/a1' ), p.dst.path.globalFromLocal( '/dst/a1' ) ]), true );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/a2' ), p.dst.path.globalFromLocal( '/dst/a2' ) ]), false );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/b' ), p.dst.path.globalFromLocal( '/dst/b' ) ]), true );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/dir/a1' ), p.dst.path.globalFromLocal( '/dst/dir/a1' ) ]), true );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/dir/a2' ), p.dst.path.globalFromLocal( '/dst/dir/a2' ) ]), false );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromLocal( '/src/dir/b' ), p.dst.path.globalFromLocal( '/dst/dir/b' ) ]), true );

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

  test.case = 'complex move with dstRewriting:0, includingNonAllowed:0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

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

  test.case = 'complex move with dstRewriting:0, includingNonAllowed:1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

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

  test.case = 'complex move with writing : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

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

  test.case = 'complex move with writing : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst :
      {
        a2 : '2',
        b : '1',
        c : '2',
        dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' },
        dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {},
        dir5 : {},
        dir1 : {},
        dir4 : {},
        dstFile : {},
      },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'nop', 'nop', 'nop', 'nop', 'fileDelete', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake', 'nop', 'dirMake', 'nop' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  // logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

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

  test.case = 'complex move with writing : 1, dstRewriting : 0, includingNonAllowed : 0, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];

  var expectedAction = [ 'dirMake', 'nop', 'dirMake', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  // logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

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

  test.case = 'complex move with writing : 1, dstRewriting : 0, includingNonAllowed : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var expectedAction = [ 'dirMake', 'nop', 'nop', 'nop', 'nop', 'fileDelete', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake', 'nop', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  // logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

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

  test.case = 'complex move with preservingSame : 1, linking : fileCopy\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, true, false, false, false, true, false, true, false, false, false, false, false, true, false, true, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'complex move with srcDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', null, 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var srcActions = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( srcActions, expectedSrcActions );
  test.identical( srcAllow, expectedSrcAllow );

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

  test.case = 'complex move with srcDeleting : 1, dstRewriting : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', null, null, null, null, 'fileDelete', 'fileDelete', null, null, 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, false, true, true, true, true, true, true, true, true, true, false, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var srcActions = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( srcActions, expectedSrcActions );
  test.identical( srcAllow, expectedSrcAllow );

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

  test.case = 'complex move with srcDeleting : 1, dstRewriting : 0, includingNonAllowed : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ false, true, false, true, true, true, true, true, true, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var srcActions = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( srcActions, expectedSrcActions );
  test.identical( srcAllow, expectedSrcAllow );

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

  test.case = 'complex move with dstDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'complex move with dstDeleting : 1, dstRewriting : 0, srcDeleting : 1, includingNonAllowed : 0\n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, true, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst', '/dst/d', '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, true, false, false, false, false, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

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

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d', '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  test.case = 'strange behavior fix';

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/*()dir/**b**' : '/dst',
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

  test.case = 'base marker *()\n' + _.toStr( o2 );

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
        dir : { a2 : '2', b : '1', c : '2' },
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/b' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/b' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true ];
  var expectedPreserve = [ true, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

/*

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

*/

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**b**' : '/dst',
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

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) ); // yyy

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
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/b', '/dst/a2', '/dst/c', '/dst/dir', '/dst/dir/a2', '/dst/dir/b', '/dst/dir/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir5', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/srcFile', '/dst/srcFile/f' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dir/a2', '/src/dir/c', '/src/dir/dir', '/src/dir/dir/a2', '/src/dir/dir/b', '/src/dir/dir/c', '/src/dir/dir2', '/src/dir/dir2/a2', '/src/dir/dir2/b', '/src/dir/dir2/c', '/src/dir/dir3', '/src/dir/dir5', '/src/dir/dirSame', '/src/dir/dirSame/d', '/src/dir/dstFile', '/src/dir/srcFile', '/src/dir/srcFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( reason, expectedReason );

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

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) ); // yyy

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/b', '/dstNew', '/dstNew/d', '/dst', '/dst/b', '/dst/a2', '/dst/c', '/dst/dir', '/dst/dir/a2', '/dst/dir/b', '/dst/dir/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir5', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/srcFile', '/dst/srcFile/f', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dir/a2', '/src/dir/c', '/src/dir/dir', '/src/dir/dir/a2', '/src/dir/dir/b', '/src/dir/dir/c', '/src/dir/dir2', '/src/dir/dir2/a2', '/src/dir/dir2/b', '/src/dir/dir2/c', '/src/dir/dir3', '/src/dir/dir5', '/src/dir/dirSame', '/src/dir/dirSame/d', '/src/dir/dstFile', '/src/dir/srcFile', '/src/dir/srcFile/f', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'srcLooking', 'srcLooking' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( reason, expectedReason );

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

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

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

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/b', '/dstNew', '/dstNew/d', '/dst', '/dst/b', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, true, false, true, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

/*
dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
*/

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/*()dir/**b**' : [ '/dstNew', '/dst' ],
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

  test.case = 'base marker *()\n' + _.toStr( o2 );

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
        dir : { a2 : '2', b : '1', c : '2' },
        d : '1',
      },

      dstNew :
      {
        dir : { b : '1' },
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/dir', '/dstNew/dir/b', '/dstNew', '/dstNew/d', '/dst', '/dst/dir', '/dst/dir/b', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, true, false, true, true, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

} /* eof _filesReflect */

//

function filesReflectToItself( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs( filePath )
  {
    return path.reroot( testPath, filePath );
  }

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir' :
      {
        a : 'dir/a',
        b : 'dir/b',
        c :
        {
          a : 'dir/c/a'
        }
      }
    },
  });

  test.case = 'setup';
  provider.filesDelete( testPath );
  extract1.filesReflectTo( provider, testPath );

  var o1 =
  {
    /*srcFilter*/src : abs( '/dir' ),
    /*dstFilter*/dst : abs( '/dir/dst' ),
  }

  var records = provider.filesReflect( _.mapExtend( null, o1 ) );

  var expectedDstRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedSrcRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  var expectedTree =
  {
    'dir' :
    {
      'a' : 'dir/a',
      'b' : 'dir/b',
      'c' : { 'a' : 'dir/c/a' },
      'dst' :
      {
        'a' : 'dir/a',
        'b' : 'dir/b',
        'c' : { 'a' : 'dir/c/a' },
      }
    }
  }
  var extract2 = provider.filesExtract( testPath );
  test.identical( extract2.filesTree, expectedTree );

  /* */

  test.case = 'some sources does not exist';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir' :
      {
        'proto' :
        {
          'File.js' : '/dir/proto/File.js',
          'File.s' : '/dir/proto/File.s',
        }
      }
    }
  });

  provider.filesDelete( testPath );
  extract1.filesReflectTo( provider, testPath );

  var o1 =
  {
    /*srcFilter*/src :
    {
      filePath :
      {
        [abs( '/dir/proto/File.js' )] : abs( '/dir/out2' ),
        [abs( '/dir/proto/File.s' )] : abs( '/dir/out2' ),
      },
      basePath : abs( '/dir/proto' ),
    }
  }

  var records = provider.filesReflect( _.mapExtend( null, o1 ) );

  var expectedDstRelative = [ './File.js', './File.s' ];
  var expectedSrcRelative = [ './File.js', './File.s' ];
  var expectedAction = [ 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  var o1 =
  {
    /*srcFilter*/src :
    {
      filePath :
      {
        [abs( '/dir/src1' )] : abs( '/dir/dst1' ),
        [abs( '/dir/proto/File.js' )] : abs( '/dir/out2' ),
        [abs( '/dir/proto/File.s' )] : abs( '/dir/out2' ),
      },
      basePath : abs( '/dir/proto' ),
    }
  }

  test.shouldThrowErrorSync( () => provider.filesReflect( _.mapExtend( null, o1 ) ) );

/*
"#foreground : blue#module::reflect-inherit / reflector::reflect.files1#foreground : default#
  src :
    filePath :
      /dir/src1 : /dir/dst1
      /dir/proto/File.js : /dir/out2
      /dir/proto/File.s : /dir/out2
    basePath : /dir/proto
  mandatory : 1
  inherit :
    reflector::files3"
*/

}

//

function filesReflectGrab( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'nothing to grab + prefix';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    '/dir**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
    mandatory : 0,
  });
  var found = provider.filesFindRecursive( testPath );
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [];
  var expectedSrcRelative = [];
  var expectedEffRelative = [];
  var expectedAction = [];
  var expectedAllow = [];
  var expectedPreserve = [];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'nothing to grab + dst';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    '/dir**' : testPath,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src },
    /*dstFilter*/dst : { hubFileProvider : provider },
    mandatory : 0,
  });
  var found = provider.filesFindRecursive( testPath );
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [];
  var expectedSrcRelative = [];
  var expectedEffRelative = [];
  var expectedAction = [];
  var expectedAllow = [];
  var expectedPreserve = [];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + src.basePath, dst null';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : null,
    './src2/d/**' : null,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });

  var found = provider.filesFindRecursive( testPath );

  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  test.case = 'trivial + src.basePath, dst true';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });

  var found = provider.filesFindRecursive( testPath );

  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + not defined src.basePath, did not exist';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, prefixPath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });
  var found = provider.filesFindRecursive( testPath );
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedSrcRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedEffRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, true, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + not defined src.basePath, did exist';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
  }

  provider.dirMake( testPath );
  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, prefixPath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });
  var found = provider.filesFindRecursive( testPath );
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedSrcRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedEffRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, true, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + URIs';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    'extract+src:///src1/d**' : true,
    'extract+src:///src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { basePath : '/' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath },
  });
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + src basePath';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + prefixPath + basePath';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, prefixPath : '/', basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + base path only';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : './src1x/',
    './src2/d/**' : './src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });

  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + dst + src base path + dst base path';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : './src1x/',
    './src2/d/**' : './src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath, basePath : testPath },
  });
  src.finit();
  provider.filesDelete( testPath );

  var expectedDstRelative = [ './src1x/src1', './src1x/src1/d', './src1x/src1/d/a', './src1x/src1/d/c', './src2x/src2/d', './src2x/src2/d/a', './src2x/src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + dst + src base path - dst base path';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : './src1x/',
    './src2/d/**' : './src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { hubFileProvider : src, basePath : '/' },
    /*dstFilter*/dst : { hubFileProvider : provider, prefixPath : testPath },
  });
  var found = provider.filesFindRecursive( testPath );
  src.finit();
  provider.filesDelete( testPath );

  var expectedFound = [ '.', './src1x', './src1x/src1', './src1x/src1/d', './src1x/src1/d/a', './src1x/src1/d/c', './src2x', './src2x/src2', './src2x/src2/d', './src2x/src2/d/a', './src2x/src2/d/c' ];
  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var found = _.select( found, '*/relative' );
  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( found, expectedFound );
  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + dst + uri';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    'extract+src:///src1/d**' : 'current://' + testPath + '/src1x/',
    'extract+src:///src2/d/**' : 'current://' + testPath + '/src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
  });
  var found = provider.filesFindRecursive( testPath );
  src.finit();
  provider.filesDelete( testPath );

  var expectedFound = [ '.', './src1x', './src1x/d', './src1x/d/a', './src1x/d/c', './src2x', './src2x/a', './src2x/c' ]
  var expectedDstRelative = [ '.', './d', './d/a', './d/c', '.', './a', './c' ];
  var expectedSrcRelative = [ '.', './d', './d/a', './d/c', '.', './a', './c' ];
  var expectedEffRelative = [ '.', './d', './d/a', './d/c', '.', './a', './c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var found = _.select( found, '*/relative' );
  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( found, expectedFound );
  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

}

//

function filesReflector( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let dst = provider;

  function abs( filePath )
  {
    return path.s.normalizeCanonical( path.s.reroot( testPath, filePath ) );
  }

  /* */

  test.case = 'first';

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { hubFileProvider : src },
    /*dstFilter*/dst : { hubFileProvider : dst, prefixPath : testPath },
  });

  test.case = 'negative + dst + src base path';

  var recipe =
  {
    '/src1/d**' : testPath + '/src1x/',
    '/src2/d/**' : testPath + '/src2x/',
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
  });

  var expectedDstAbsolute = abs([ '/src1x', '/src1x/d', '/src1x/d/a', '/src1x/d/c', '/src2x', '/src2x/a', '/src2x/c' ]);
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'negative + dst';

  var recipe =
  {
    '/src1/d**' : testPath + '/src1x/',
    '/src2/d/**' : testPath + '/src2x/',
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { basePath : null },
  });

  var expectedDstAbsolute = abs([ '/src1x', '/src1x/d', '/src1x/d/a', '/src1x/d/c', '/src2x', '/src2x/a', '/src2x/c' ]);
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.case = 'negative';

  var recipe =
  {
    '/src1/d**' : true,
    '/src2/d/**' : true,
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
    /*srcFilter*/src : { basePath : null },
  });

  var expectedDstAbsolute = abs([ '/', '/d', '/d/a', '/d/c', '/', '/a', '/c' ]);
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  test.open( 'reflect current dir' );

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : {},
    /*dstFilter*/dst : {},
  });
  test.shouldThrowError( () => reflect( '/' ) );
  var found = dst.filesFind({ filePath : testPath, allowingMissed : 1 });
  test.identical( found.length, 0 );

  dst.filesDelete( testPath );
  src.finit();

  /* yyy */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { basePath : 'src:///' },
    /*dstFilter*/dst : { filePath : 'current:///' },
  });
  reflect( '/' );
  var found = dst.filesFind({ filePath : testPath, allowingMissed : 1 });
  test.identical( found.length, 0 );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  if( Config.debug )
  {

    var src = context.makeStandardExtract({ originPath : 'src://' });
    src.providerRegisterTo( hub );

    var reflect = hub.filesReflector
    ({
      /*srcFilter*/src : { basePath : 'src:///' },
      /*dstFilter*/dst : { basePath : 'current:///' },
    });
    test.shouldThrowErrorSync( () => reflect( '/' ) );

    dst.filesDelete( testPath );
    src.finit();

  }

  /* */

  if( Config.debug )
  {

    var src = context.makeStandardExtract({ originPath : 'src://' });
    src.providerRegisterTo( hub );

    var reflect = hub.filesReflector
    ({
      /*srcFilter*/src : { basePath : 'src:///' },
      /*dstFilter*/dst : { basePath : 'current:///' },
    });
    test.shouldThrowError( () => reflect( '/' ) );

    dst.filesDelete( testPath );
    src.finit();

  }

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { prefixPath : 'src:///' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath },
  });
  reflect( '/' );
  var extract = provider.filesExtract( testPath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, src.filesTree );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { prefixPath : 'src:///', basePath : 'src:///' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath, basePath : 'current://' + testPath },
  });
  reflect( '/alt/a' );
  var extract = provider.filesExtract( testPath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, { alt : { a : '/alt/a' } } );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { prefixPath : 'src:///', basePath : 'src:///' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath, basePath : 'current://' + testPath },
    mandatory : 0,
  });
  reflect( '/alt/alt' );
  var extract = provider.filesExtract( testPath );
  test.identical( extract.filesTree, {} );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { prefixPath : 'src:///', basePath : 'src:///a/b' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath + '/1/2', basePath : 'current://' + testPath + '/1/2' },
  });
  reflect( 'alt' );
  var expected =
  {
    alt :
    {
      a : '/alt/a',
      d : { a : '/alt/d/a' }
    }
  }
  var extract = provider.filesExtract( testPath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, expected );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { prefixPath : 'src:///', basePath : 'src:///' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath, basePath : 'current://' + testPath + '/a/b' },
  });
  reflect( '/alt/a' )
  var extract = provider.filesExtract( testPath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, { alt : { a : '/alt/a' } } );

  dst.filesDelete( testPath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    /*srcFilter*/src : { prefixPath : 'src:///', basePath : 'src:///' },
    /*dstFilter*/dst : { prefixPath : 'current://' + testPath, basePath : 'current://' + testPath },
    linking : 'softLink',
    mandatory : 1,
  });

  reflect( '/alt/a' );

  if( provider instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () => provider.fileRead( abs( '/alt/a' ) ))
  }
  else
  {
    var extract = provider.filesExtract( testPath );
    test.identical( extract.filesTree, { alt : { a : '/alt/a' } } );
    test.identical( provider.statRead( testPath + '/alt/a' ).isSoftLink(), true );
  }

  dst.filesDelete( testPath );
  src.finit();

  test.close( 'reflect current dir' );
}

//

function filesReflectWithHub( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let dstProvider = provider;
  let dstPath = testPath;

  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  var srcProvider = _.FileProvider.Extract({ filesTree : filesTree, protocols : [ 'extract' ] });
  srcProvider.providerRegisterTo( hub );
  // var dstProvider = new _.FileProvider.HardDrive();
  var srcPath = '/src';

  // var dstPath = path.join( context.testSuitePath, test.name, 'dst' );
  // var hub = new _.FileProvider.Hub({ empty : 1 });
  // hub.providerRegister( srcProvider );
  // hub.providerRegister( dstProvider );

  /* */

  test.case = 'from Extract to HardDrive, using local absolute paths'
  dstProvider.filesDelete( dstPath );
  var o1 =
  {
    reflectMap : { [ srcPath ] : dstPath },
    /*srcFilter*/src : { effectiveFileProvider : srcProvider },
    /*dstFilter*/dst : { effectiveFileProvider : dstProvider },
  };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  var records = hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  test.is( records.length >= 0 );

  var got = _.FileProvider.Extract.filesTreeRead({ srcPath : dstPath, srcProvider : dstProvider });
  test.identical( got, context.select( filesTree, srcPath ) )

  /* */

  test.case = 'files from Extract to HardDrive, using global uris'
  dstProvider.filesDelete( dstPath );
  var srcUrl = srcProvider.path.globalFromLocal( srcPath );
  var dstUrl = dstProvider.path.globalFromLocal( dstPath );
  var o1 = { reflectMap : { [ srcUrl ] : dstUrl } };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  var records = hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  test.is( records.length >= 0 );

  var got = _.FileProvider.Extract.filesTreeRead({ srcPath : dstPath, srcProvider : dstProvider });
  test.identical( got, context.select( filesTree, '/src' ) );

  dstProvider.filesDelete( dstPath );
  srcProvider.finit();
}

//

function filesReflectLinkWithHub( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let dstPath = testPath;
  let dst = provider;

  var filesTree =
  {
    'terminal' : 'terminal',
    'link' : [{ softLink : '/terminal' }]
  }
  var src = new _.FileProvider.Extract({ protocol : 'src', filesTree : filesTree });

  src.providerRegisterTo( hub );

  /* */

  test.case = 'resolvingSrcSoftLink : default, with prefixPath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    /*dstFilter*/dst :
    {
      prefixPath : _.uri.join( 'current://', dstPath ),
    },
    /*srcFilter*/src :
    {
      prefixPath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : null,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  test.case = 'resolvingSrcSoftLink : default, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    /*dstFilter*/dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    /*srcFilter*/src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : null,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  test.case = 'resolvingSrcSoftLink : 1, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    /*dstFilter*/dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    /*srcFilter*/src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 1,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  test.case = 'resolvingSrcSoftLink : 0, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    /*dstFilter*/dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    /*srcFilter*/src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 0,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( !dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  if( dst instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () =>
    {
      dst.fileRead( _.path.join( dstPath, 'link' ) )
    })
  }
  else
  {
    var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
    var expected = 'terminal';
    test.identical( got, expected );
  }

  /* */

  test.case = 'resolvingSrcSoftLink : default, with reflector';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  var reflect = hub.filesReflector
  ({
    /*dstFilter*/dst :
    {
      prefixPath : _.uri.join( 'current://', dstPath ),
    },
    /*srcFilter*/src :
    {
      prefixPath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : null,
  });

  reflect( '.' );

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  src.finit();
  dst.filesDelete( testPath );

}

//

function filesReflectDeducing( test )
{
  var c = this;

  /* */

  test.case = 'both prefixes defined, relative dst and src';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap :
    {
      '.' : '.',
    },
    /*srcFilter*/src :
    {
      prefixPath : '/src/srcDir',
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'both prefixes defined, relative dst';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap :
    {
      '/src/srcDir' : '.',
    },
    /*srcFilter*/src :
    {
      prefixPath : '/src/srcDir2',
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, single path';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    /*srcFilter*/src :
    {
      filePath : '/src/srcDir',
    },
    /*dstFilter*/dst :
    {
      filePath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, single path';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      filePath : { 'srcDir' : 'dstDir2' },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, multiple paths';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    /*srcFilter*/src :
    {
      filePath : [ '/src/srcDir', '/src/srcDir2' ],
    },
    /*dstFilter*/dst :
    {
      filePath : [ '/dst/dstDir', '/dst/dstDir2' ]
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'src/a', b : 'src/b', c : 'dst/c', e : 'src/e' }, dstDir2 : { a : 'src/a', b : 'src/b', e : 'src/e' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/b', '/dst/dstDir', '/dst/dstDir/e', '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b', '/dst/dstDir2', '/dst/dstDir2/e' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e', '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, multiple paths, hub';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    /*srcFilter*/src :
    {
      filePath : [ 'extract:///src/srcDir', 'extract:///src/srcDir2' ],
    },
    /*dstFilter*/dst :
    {
      filePath : [ 'extract:///dst/dstDir', 'extract:///dst/dstDir2' ]
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var hub = new _.FileProvider.Hub({ providers : [ provider ] });
  var records = hub.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'src/a', b : 'src/b', c : 'dst/c', e : 'src/e' }, dstDir2 : { a : 'src/a', b : 'src/b', e : 'src/e' } },
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/b', '/dst/dstDir', '/dst/dstDir/e', '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b', '/dst/dstDir2', '/dst/dstDir2/e' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e', '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'no reflect map, multiple paths, hub';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      filePath : { '.' : true },
      basePath : { '.' : '.' },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
      filePath : '.',
      basePath : { '.' : '.' },
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/c', '/dst/d', '/dst/srcDir', '/dst/srcDir/a', '/dst/srcDir/b', '/dst/srcDir2', '/dst/srcDir2/e' ];
  var expectedSrcAbsolute = [ '/src', '/src/c', '/src/d', '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, single src, no src base';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      filePath : { 'd' : true },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
      filePath : '.',
      basePath : { '.' : '.' },
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/c', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/d', '/src/d/c', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, single src, src base';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      basePath : '.',
      filePath : { 'd' : true },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
      basePath : { '.' : '.' },
      filePath : '.',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'src/d' },
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/d' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, single src, no src base, no dst base, no dst';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      filePath : { 'd' : true },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/c', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/d', '/src/d/c', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, multiple src';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      filePath : { 'c' : 'c2', 'd' : null },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
      filePath : '.',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  /*
    xxx qqq : problem with option dstRewritingPreserving here also!
    should throw error because of overwriting!
  */

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/c2', '/dst', '/dst/c', '/dst/c2', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/c', '/src/d', '/src/d/c', '/src/d/c2', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, multiple src';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    /*srcFilter*/src :
    {
      prefixPath : '/src',
      filePath : { 'srcDir2' : null, 'c' : 'c2', 'd' : null },
    },
    /*dstFilter*/dst :
    {
      prefixPath : '/dst',
      filePath : '.',
      basePath : { '.' : '.' },
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  test.shouldThrowErrorSync( () =>
  {
    var records = provider.filesReflect( o );
  });

}

//

function filesReflectDstPreserving( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  var filesTree =
  {
    src :
    {
      'file' : 'file',
      'file-d' : 'file-diff-content',
      'dir-e' : { 'dir-e' : {} },
      'dir-test' : { 'file' : 'file', 'dir-test' : { 'file' : 'file' } },
      'dir-test-inner' : { 'dir-test' : { 'file' : 'file' } },
      'dir-d' : { 'file-d' : 'file-diff-content' },
      'dir-s' : { 'file' : 'file' },
    },
    dst :
    {
      'file' : 'file',
      'file-d' : 'file-diff-content',
      'dir-e' : { 'dir-e' : {} },
      'dir-test' : { 'file' : 'file', 'dir-test' : { 'file' : 'file' } },
      'dir-test-inner' : { 'dir-test' : { 'file' : 'file' } },
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
    reflectMap : { '/src/file' : '/dst/dir-test' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-test' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals inner level, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test-inner' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-test-inner' );
  test.identical( src, dst );
  test.identical( src, context.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/file' ) );
  test.is( extract.isDir( '/dst/dir-test' ) );
  test.identical( context.select( extract.filesTree, '/src/file' ), context.select( filesTree, '/src/file' ) );
  test.identical( context.select( extract.filesTree, '/dst/dir-test' ), context.select( filesTree, '/dst/dir-test' ) );

  test.case = 'terminal - dir with terminals inner level, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test-inner' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/file' ) );
  test.is( extract.isDir( '/dst/dir-test-inner' ) );
  test.identical( context.select( extract.filesTree, '/src/file' ), context.select( filesTree, '/src/file' ) );
  test.identical( context.select( extract.filesTree, '/dst/dir-test-inner' ), context.select( filesTree, '/dst/dir-test-inner' ) );

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
    reflectMap : { '/src/dir-test' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-test' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-test' ), context.select( filesTree, '/src/dir-test' ) );
  test.identical( context.select( extract.filesTree, '/dst/file' ), context.select( extract.filesTree, '/src/dir-test' ) );

  test.case = 'dir with files - terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-test' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-test' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/dir-test' ), context.select( filesTree, '/src/dir-test' ) );
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

  /*  */

  var filesTree =
  {
    src :
    {
      file1 : 'file1',
      file2 : 'file2',
    },
    dst :
    {
    }
  }

  test.case = 'reflect two terminals to same dst path, src termianls have different content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file2' ), context.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect two terminals to same dst path, src termianls have different content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowErrorSync( () => extract.filesReflect( o ) );
  test.is( !extract.fileExists( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file1' ), 'file1' );
  test.identical( context.select( extract.filesTree, '/src/file2' ), 'file2' );
  test.is( !context.select( extract.filesTree, '/dst/file' ) );

  /*  */

  var filesTree =
  {
    src :
    {
      file1 : 'file',
      file2 : 'file',
      file3 : 'file3',
    },
    dst :
    {
    }
  }

  test.case = 'reflect two terminals to same dst path, src termianls have same content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file1' ), context.select( extract.filesTree, '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/file2' ), context.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect two terminals to same dst path, src termianls have same content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file1' ), context.select( extract.filesTree, '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/file2' ), context.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls has diff content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.notIdentical( context.select( extract.filesTree, '/src/file1' ), context.select( extract.filesTree, '/dst/file' ) );
  test.notIdentical( context.select( extract.filesTree, '/src/file2' ), context.select( extract.filesTree, '/dst/file' ) );
  test.identical( context.select( extract.filesTree, '/src/file3' ), context.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls has diff content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowErrorSync( () => extract.filesReflect( o ) );
  test.is( !extract.fileExists( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file1' ), 'file' );
  test.identical( context.select( extract.filesTree, '/src/file2' ), 'file' );
  test.identical( context.select( extract.filesTree, '/src/file3' ), 'file3' );

  /*  */

  var filesTree =
  {
    src :
    {
      file1 : 'file',
      file2 : [{ softLink : '/src/file4' }],
      file3 : 'file',
      file4 : 'file3',
    },
    dst :
    {
    }

  }

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls is a softLink, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }

  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file3' ), context.select( extract.filesTree, '/dst/file' ) );
  test.notIdentical( context.select( extract.filesTree, '/src/file4' ), context.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls is a softLink, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }

  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( context.select( extract.filesTree, '/src/file3' ), context.select( extract.filesTree, '/dst/file' ) );
  test.notIdentical( context.select( extract.filesTree, '/src/file4' ), context.select( extract.filesTree, '/dst/file' ) );

  /*  */

  test.case = 'mixed file path, multiple src, dstRewritingPreserving : 0';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'c' : '/dst/c2', 'd' : '/dst' },
    },
    dstRewritingPreserving : 0
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/c2', '/dst', '/dst/c', '/dst/c2', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/c', '/src/d', '/src/d/c', '/src/d/c2', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  //

  test.case = 'mixed file path, multiple src, dstRewritingPreserving : 1';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'c' : '/dst/c2', 'd' : '/dst' },
    },
    dstRewritingPreserving : 1
  }

  var extract = new _.FileProvider.Extract({ filesTree : _.cloneJust( tree ), protocol : 'extract' });
  test.shouldThrowErrorSync( () => extract.filesReflect( o ) );

  /*
    xxx qqq : problem with option dstRewritingPreserving here also!
    should throw error because of overwriting!
  */

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', c2 : 'src/c', d : 'dst/d' },
  }

  test.identical( extract.filesTree, expectedTree );
}

//

function filesReflectDstDeletingDirs( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

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
    /*dstFilter*/dst : { maskAll : { excludeAny : 'dir' } }
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
    /*dstFilter*/dst : { maskAll : { excludeAny : 'dir' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : [ 'file', 'dir' ] } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : [ 'file', 'dir' ] } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file', excludeAny : 'dir' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file', excludeAny : 'dir' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file1' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file1' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file' } }
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
    /*dstFilter*/dst : { maskAll : { includeAny : 'file' } }
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
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  var srcPath = path.join( testPath, 'src' );
  var dstPath = path.join( testPath, 'dst' );
  var dstLinkPath = path.join( dstPath, 'link' );
  var srcLinkPath = path.join( srcPath, 'link' );

  /* - */

  test.case = 'first';

  logger.log( 'testPath', testPath );

  provider.filesDelete( testPath );

  provider.dirMake( srcPath );

  provider.fileWrite( path.join( srcPath, 'file' ), 'file' );

  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
  });

  test.is( provider.fileExists( path.join( dstPath, 'file' ) ) )
  test.is( !provider.fileExists( dstLinkPath ) )

  /**/

  provider.filesDelete( testPath );

  provider.dirMake( srcPath );
  provider.dirMake( dstPath );

  provider.fileWrite( srcLinkPath, 'file' );

  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1
  });

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
  });

  /*
    !!! qqq : dstPath/link should be link and dstPath/fileNotExists should exists if resolvingDstSoftLink : 1
    but resolvingDstSoftLink is 0 by default
    so resolvingDstSoftLink option is NOT COVERED by tests at all!

    seems File.copyFileSync works if resolvingDstSoftLink is always 1
  */

  test.is( !provider.isSoftLink( dstLinkPath ) );
  test.identical( provider.fileRead( dstLinkPath ), 'file' );

  /* */

  test.case = 'src - link to missing, dst - link to missing';
  provider.filesDelete( testPath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })

  test.is( provider.isSoftLink( dstLinkPath ) );

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 1,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link';
  test.is( !provider.fileExists( dstLinkPath ) );
  // var dstLink1 = provider.pathResolveSoftLink( dstLinkPath );
  // test.identical( dstLink1, path.join( dstPath, 'fileNotExists' ) );

  /* */

  test.case = 'src - link to missing, dst - link to missing';
  provider.filesDelete( testPath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 0,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link';
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink1 = provider.pathResolveSoftLink( dstLinkPath );
  test.identical( dstLink1, path.join( srcPath, 'fileNotExists' ) );

  /* */

  test.case = 'src link is broken, src resolving is on'
  provider.filesDelete( testPath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })
  provider.fileWrite( path.join( dstPath, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'file' ),
    dstPath : dstLinkPath,
    makingDirectory : 1
  })

  var records = provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 1,
  });

  test.will = 'delete dst link file';
  test.is( !provider.fileExists( dstLinkPath ) );

  /* */

  test.case = 'replace dst link by broken link'
  provider.filesDelete( testPath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })
  provider.fileWrite( path.join( dstPath, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'file' ),
    dstPath : dstLinkPath,
    makingDirectory : 1
  })

  var records = provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 0,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link';
  test.is( provider.fileExists( dstLinkPath ) );
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink1 = provider.pathResolveSoftLink({ filePath : dstLinkPath });
  test.identical( dstLink1, path.join( srcPath, 'fileNotExists' ) );

  /* */

  test.case = 'src - link to terminal, dst - link to missing'
  provider.filesDelete( testPath );
  provider.fileWrite( path.join( srcPath, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'file' ),
    dstPath : srcLinkPath,
    makingDirectory : 1
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
  })

  test.will = 'dstPath/link should be rewritten by srcPath/link'
  test.is( !provider.isSoftLink( dstLinkPath ) );
  test.is( provider.isTerminal( dstLinkPath ) );
  var read = provider.fileRead({ filePath : dstLinkPath });
  test.identical( read, 'file' );

  /* */

  test.case = 'src - no files, dst - link to missing'
  provider.filesDelete( testPath );
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    mandatory : 0,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link'
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink4 = provider.pathResolveSoftLink({ filePath : dstLinkPath });
  test.identical( dstLink4, path.join( dstPath, 'fileNotExists' ) );

}

//

function filesReflectTo( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'empty';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });

  var extract2 = _.FileProvider.Extract();

  extract1.filesReflectTo( extract2 );
  test.identical( extract1.filesTree, extract2.filesTree );

  extract1.filesReflectTo( extract2, '/' );
  test.identical( extract1.filesTree, extract2.filesTree );

  extract1.filesReflectTo({ dstProvider : extract2, dstPath : '/' });
  test.identical( extract1.filesTree, extract2.filesTree );

  /* */

  test.case = 'trivial';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  var extract2 = _.FileProvider.Extract();

  extract1.filesReflectTo( extract2 );
  test.identical( extract1.filesTree, extract2.filesTree );
  extract2.filesDelete( '/' );

  extract1.filesReflectTo( extract2, '/' );
  test.identical( extract1.filesTree, extract2.filesTree );
  extract2.filesDelete( '/' );

  extract1.filesReflectTo({ dstProvider : extract2, dstPath : '/' });
  test.identical( extract1.filesTree, extract2.filesTree );
  extract2.filesDelete( '/' );

  /* */

  test.case = 'to current';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  extract1.filesReflectTo( provider, testPath );
  var expected = [ '.', './f', './dir', './dir/df' ];
  var found = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.identical( found, expected );
  provider.filesDelete( testPath );

  extract1.filesReflectTo({ dstProvider : provider, dstPath : testPath });
  var expected = [ '.', './f', './dir', './dir/df' ];
  var found = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.identical( found, expected );
  provider.filesDelete( testPath );

  /* */

  test.case = 'with srcPath current';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  extract1.filesReflectTo({ dstProvider : provider, dstPath : testPath, srcPath : '/dir' });
  var expected = [ '.', './df' ];
  var found = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.identical( found, expected );
  provider.filesDelete( testPath );

}

//

function filesDeleteTrivial( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  var softLinkIsSupported = context.softLinkIsSupported();
  var terminalPath = path.join( testPath, 'terminal' );
  var dirPath = path.join( testPath, 'dir' );

  var find = provider.filesFinder
  ({
    recursive : 2,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    outputFormat : 'relative',
  });

  /* */

  test.case = 'delete all files of extract';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  extract1.filesDelete( '/' );
  test.identical( extract1.filesTree, {} );

  /* */

  test.case = 'delete terminal file';
  provider.fileWrite( terminalPath, 'a' );
  var deleted = provider.filesDelete( terminalPath );
  test.identical( _.select( deleted, '*/relative' ), [ './terminal' ] );
  var stat = provider.statResolvedRead( terminalPath );
  test.identical( stat, null );

  var found = find( terminalPath );
  test.identical( found, [] );

  /* */

  test.case = 'delete empty dir';
  provider.dirMake( dirPath );
  provider.filesDelete( dirPath );
  var stat = provider.statResolvedRead( dirPath );
  test.identical( stat, null );

  /* */

  test.case = 'delete hard link';
  provider.filesDelete( testPath );
  var dst = path.join( testPath, 'link' );
  provider.fileWrite( terminalPath, 'a');
  provider.hardLink( dst, terminalPath );
  provider.filesDelete( dst );
  var stat = provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( terminalPath );
  test.is( !!stat );

  /* */

  test.case = 'delete tree';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
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

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var deleted = provider.filesDelete( testPath );
  var expectedDeleted =
  [
    '.',
    './src',
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file'
  ];
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( testPath ), null );
  var stat = provider.statResolvedRead( testPath );
  test.identical( stat, null );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* */

  test.case = 'delete tree with filter';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
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

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var deleted = provider.filesDelete({ filter : { filePath : testPath, maskAll : { excludeAny : '/c' } } });
  var expectedDeleted =
  [
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
  ];
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var stat = provider.statResolvedRead( testPath );
  test.is( !!stat );
  var expectedFiles =
  [
    '.',
    './src',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file',
  ];
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.identical( files, expectedFiles );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* */

  test.case = 'delete tree with filter, exclude all';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
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

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var deleted = provider.filesDelete({ filter : { filePath : testPath, maskAll : { excludeAny : '/src' } } });
  var expectedDeleted =
  [
  ];
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var stat = provider.statResolvedRead( testPath );
  test.is( !!stat );
  var expectedFiles =
  [
    '.',
    './src',
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file'
  ];
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.identical( files, expectedFiles );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* */

  test.case = 'delete tree with transient filter';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
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

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var deleted = provider.filesDelete({ filter : { filePath : testPath, maskTransientDirectory : { excludeAny : '/c' } } });
  var expectedDeleted =
  [
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
  ]
  ;
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( testPath ), [ 'src' ] );
  var stat = provider.statResolvedRead( testPath );
  test.is( !!stat );
  var expectedFiles =
  [
    '.',
    './src',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file'
  ];
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.identical( files, expectedFiles );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* - */

  test.case = 'deletingEmptyDirs : 1';
  var extract = _.FileProvider.Extract
  ({
    protocol : 'src',
    filesTree :
    {
      'd1' :
      {
        'd2a' :
        {
          'd3' :
          {
            'd4' : { 'test' : 'test' },
          },
        },
        'd2b' :
        {
          'test' : 'test'
        },
      },
    },
  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });

  var deleted = provider.filesDelete
  ({
    filePath : path.join( testPath, 'd1/d2a/d3/d4' ),
    deletingEmptyDirs : 1,
  });

  var expected = [ '../..', '..', '.', './test' ];
  test.identical( _.select( deleted, '*/relative' ), expected );
  var stat = provider.statResolvedRead( path.join( testPath, 'd1/d2a' ) );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( path.join( testPath, 'd1/d2b' ) );
  test.is( !!stat );

  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* - */

  if( !softLinkIsSupported )
  return;

  /* */

  test.case = 'delete soft link, resolvingSoftLink 1';
  provider.fieldPush( 'resolvingSoftLink', 1 );
  var dst = path.join( testPath, 'link' );
  provider.fileWrite( terminalPath, ' ');
  provider.softLink( dst, terminalPath );
  provider.filesDelete( dst )
  var stat = provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( terminalPath );
  test.is( !!stat );
  provider.fieldPop( 'resolvingSoftLink', 1 );

  /* */

  test.case = 'delete soft link, resolvingSoftLink 0';
  provider.filesDelete( testPath );
  provider.fieldPush( 'resolvingSoftLink', 0 );
  var dst = path.join( testPath, 'link' );
  provider.fileWrite( terminalPath, ' ');
  provider.softLink( dst, terminalPath );
  provider.filesDelete( dst )
  var stat = provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( terminalPath );
  test.is( !!stat );
  provider.fieldPop( 'resolvingSoftLink', 0 );

  /* */

}

//

function filesDelete( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;
  let hub = context.hub;

  var testPath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    protocol : 'src',
    filesTree :
    {
      file : 'file',
      empty1 : {},
      dir1 :
      {
        file : 'file',
        empty2 : {},
        dir2 :
        {
          file : 'file',
          empty3 : {},
        }
      }
    }
  })
  tree.providerRegisterTo( hub );

  //

  test.case = 'mask single directory';
  var tree2 = _.FileProvider.Extract
  ({
    protocol : 'src2',
    filesTree :
    {
      dir :
      {
        dir1 : { file : 'file' },
        dir2 : {},
      }
    }
  })
  tree2.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src2:///' : 'current://' + testPath } });
  var filter =
  {
    maskDirectory : /dir1$/g
  }
  var got = provider.filesDelete({ filePath : testPath, recursive : 2, throwing : 1, filter : filter });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir/dir1',
    './dir/dir1/file'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.will = 'nothing deleted';
  var expected =
  [
    '.',
    './dir',
    './dir/dir2'
  ]
  test.identical( files, expected );
  tree2.finit();

  //

  test.case = 'mask single terminal';
  var tree2 = _.FileProvider.Extract
  ({
    protocol : 'src2',
    filesTree :
    {
      dir :
      {
        file1 : 'file1',
        file2 : 'file2',
      }
    }
  })
  tree2.providerRegisterTo( hub );
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src2:///' : 'current://' + testPath } });
  var filter =
  {
    maskTerminal : /file1$/g
  }
  var got = provider.filesDelete({ filePath : testPath, recursive : 2, throwing : 1, filter : filter });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir/file1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.will = 'nothing deleted';
  var expected =
  [
    '.',
    './dir',
    './dir/file2',
  ]
  test.identical( files, expected );
  tree2.finit();

  //

  test.open( 'recursive' );

  test.case = 'recursive : 0';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  test.shouldThrowErrorSync( () => provider.filesDelete({ filePath : testPath, recursive : 0 }) );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  test.will = 'nothing deleted';
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( files, expected );

  test.case = 'recursive : 1';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, recursive : 1 });
  var deleted = _.select( got, '*/relative' );
  test.will = 'only terminals from root and empty dirs'
  var expected =
  [
    './file',
    './empty1'
  ];
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  var expected =
  [
    '.',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
  ];
  test.identical( files, expected );

  test.case = 'recursive : 2';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, recursive : 2 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.close( 'recursive' );

  test.open( 'includingTerminals' );

  test.case = 'includingTerminals off';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, includingTerminals : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  test.identical( files, expected );

  test.case = 'includingTerminals off';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, includingTerminals : 0, throwing : 1 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative'});
  test.will = 'only empty dirs should be deleted'
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  test.identical( files, expected );


  test.case = 'includingTerminals off';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, includingTerminals : 1 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.close( 'includingTerminals' );

  test.open( 'resolvingSoftLink' );

  test.case = 'soft link to terminal';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  provider.softLink( path.join( testPath, 'softLink' ), path.join( testPath, 'dir1/dir2/file' )  );
  var got = provider.filesDelete({ filePath : testPath, resolvingSoftLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './softLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to dir';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  provider.softLink( path.join( testPath, 'softLink' ), path.join( testPath, 'dir1/dir2' )  )
  var got = provider.filesDelete({ filePath : testPath, resolvingSoftLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './softLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to terminal';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  provider.softLink( path.join( testPath, 'softLink' ), path.join( testPath, 'dir1/dir2/file' )  )
  test.shouldThrowError( () => provider.filesDelete({ filePath : testPath, resolvingSoftLink : 1 }) );

  test.close( 'resolvingSoftLink' );

  test.open( 'resolvingTextLink' );

  test.case = 'soft link to terminal';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  provider.textLink( path.join( testPath, 'textLink' ), path.join( testPath, 'dir1/dir2/file' )  )
  var got = provider.filesDelete({ filePath : testPath, resolvingTextLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './textLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to dir';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  provider.textLink( path.join( testPath, 'textLink' ), path.join( testPath, 'dir1/dir2' )  )
  var got = provider.filesDelete({ filePath : testPath, resolvingTextLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './textLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to terminal';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  provider.textLink( path.join( testPath, 'textLink' ), path.join( testPath, 'dir1/dir2/file' )  )
  test.shouldThrowError( () => provider.filesDelete({ filePath : testPath, resolvingTextLink : 1 }) );

  test.close( 'resolvingTextLink' );

  test.open( 'writing' );

  test.case = 'writing off';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, writing : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.will = 'result must include files that should be deleted when writing is on'
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative'});
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( files, expected );

  test.case = 'writing on';
  provider.filesDelete( testPath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
  var got = provider.filesDelete({ filePath : testPath, writing : 1 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative'});
  var expected =
  [
  ]
  test.identical( files, expected );

  test.close( 'writing' );

  tree.finit();

}

//

function filesDeleteAsync( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;
  let hub = context.hub;

  var softLinkIsSupported = context.softLinkIsSupported();
  var testPath = path.join( context.testSuitePath, test.name );
  var terminalPath = path.join( testPath, 'terminal' );
  var dirPath = path.join( testPath, 'dir' );
  var con = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.case = 'delete terminal file';
    provider.fileWrite( terminalPath, 'a' );
    return provider.filesDelete({ filePath : terminalPath, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      test.identical( _.select( deleted, '*/relative' ), [ './terminal' ] );
      var stat = provider.statResolvedRead( terminalPath );
      test.identical( stat, null );
      return true;
    })
  })

  //

  .finally( () =>
  {
    test.case = 'delete empty dir';
    provider.dirMake( dirPath );
    return provider.filesDelete({ filePath : dirPath, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dirPath );
      test.identical( stat, null );
      return true;
    })
  })

  //

  .finally( () =>
  {
    test.case = 'delete hard link';
    provider.filesDelete( testPath );
    var dst = path.join( testPath, 'link' );
    provider.fileWrite( terminalPath, 'a');
    provider.hardLink( dst, terminalPath );
    return provider.filesDelete({ filePath : dst, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( terminalPath );
      test.is( !!stat );
      return true;
    })
  })

  //

  .finally( () =>
  {
    test.case = 'delete tree';
    var extract = _.FileProvider.Extract
    ({

      protocol : 'src',
      filesTree :
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

    });
    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( testPath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
    test.identical( provider.dirRead( testPath ), [ 'src' ] );
    return provider.filesDelete({ filePath : testPath, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var expectedDeleted =
      [
        '.',
        './src',
        './src/a.a',
        './src/b1.b',
        './src/b2.b',
        './src/c',
        './src/c/b3.b',
        './src/c/srcfile',
        './src/c/srcfile-dstdir',
        './src/c/e',
        './src/c/e/d2.d',
        './src/c/e/e1.e',
        './src/c/srcdir',
        './src/c/srcdir-dstfile',
        './src/c/srcdir-dstfile/srcdir-dstfile-file'
      ];
      test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
      test.identical( provider.dirRead( testPath ), null );
      var stat = provider.statResolvedRead( testPath );
      test.identical( stat, null );
      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })
  })

  //

  .finally( () =>
  {
    test.case = 'delete tree with filter';
    var extract = _.FileProvider.Extract
    ({

      protocol : 'src',
      filesTree :
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

    });

    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( testPath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
    test.identical( provider.dirRead( testPath ), [ 'src' ] );
    return provider.filesDelete({ filter : { filePath : testPath, maskAll : { excludeAny : '/c' } }, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var expectedDeleted =
      [
        './src/a.a',
        './src/b1.b',
        './src/b2.b',
      ];
      test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
      test.identical( provider.dirRead( testPath ), [ 'src' ] );
      var stat = provider.statResolvedRead( testPath );
      test.is( !!stat );
      var expectedFiles =
      [
        '.',
        './src',
        './src/c',
        './src/c/b3.b',
        './src/c/srcfile',
        './src/c/srcfile-dstdir',
        './src/c/e',
        './src/c/e/d2.d',
        './src/c/e/e1.e',
        './src/c/srcdir',
        './src/c/srcdir-dstfile',
        './src/c/srcdir-dstfile/srcdir-dstfile-file',
      ];
      var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
      test.identical( files, expectedFiles );
      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })

  })

  //

  .finally( () =>
  {

    test.case = 'delete tree with filter, exclude all';
    var extract = _.FileProvider.Extract
    ({

      protocol : 'src',
      filesTree :
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

    });

    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( testPath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });
    test.identical( provider.dirRead( testPath ), [ 'src' ] );
    return provider.filesDelete({ filter : { filePath : testPath, maskAll : { excludeAny : '/src' } }, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var expectedDeleted =
      [
      ];
      test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
      test.identical( provider.dirRead( testPath ), [ 'src' ] );
      var stat = provider.statResolvedRead( testPath );
      test.is( !!stat );
      var expectedFiles =
      [
        '.',
        './src',
        './src/a.a',
        './src/b1.b',
        './src/b2.b',
        './src/c',
        './src/c/b3.b',
        './src/c/srcfile',
        './src/c/srcfile-dstdir',
        './src/c/e',
        './src/c/e/d2.d',
        './src/c/e/e1.e',
        './src/c/srcdir',
        './src/c/srcdir-dstfile',
        './src/c/srcdir-dstfile/srcdir-dstfile-file'
      ];
      var files = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative' });
      test.identical( files, expectedFiles );
      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })

  })

  //


  .finally( () =>
  {
    test.case = 'deletingEmptyDirs : 1';
    var extract = _.FileProvider.Extract
    ({
      protocol : 'src',
      filesTree :
      {
        'd1' :
        {
          'd2a' :
          {
            'd3' :
            {
              'd4' : { 't' : 't' },
            },
          },
          'd2b' :
          {
            't' : 't'
          },
        },
      },
    });

    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( testPath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + testPath } });

    return provider.filesDelete
    ({
      filePath : path.join( testPath, 'd1/d2a/d3/d4' ),
      deletingEmptyDirs : 1,
      sync : 0
    })
    .thenKeep( ( deleted ) =>
    {
      var expected = [ '../..', '..', '.', './t' ];
      test.identical( _.select( deleted, '*/relative' ), expected );
      var stat = provider.statResolvedRead( path.join( testPath, 'd1/d2a' ) );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( path.join( testPath, 'd1/d2b' ) );
      test.is( !!stat );

      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })
  })

  //

  if( !softLinkIsSupported )
  return con;

  con.finally( () =>
  {
    test.case = 'delete soft link, resolvingSoftLink 1';
    provider.fieldPush( 'resolvingSoftLink', 1 );
    var dst = path.join( testPath, 'link' );
    provider.fileWrite( terminalPath, ' ');
    provider.softLink( dst, terminalPath );
    return provider.filesDelete({ filePath : dst, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( terminalPath );
      test.is( !!stat );
      provider.fieldPop( 'resolvingSoftLink', 1 );
      return true;
    })
  })

  .finally( () =>
  {
    test.case = 'delete soft link, resolvingSoftLink 0';
    provider.fieldPush( 'resolvingSoftLink', 0 );
    var dst = path.join( testPath, 'link' );
    provider.fileWrite( terminalPath, ' ');
    provider.softLink( dst, terminalPath );
    return provider.filesDelete({ filePath : dst, sync : 0 })
    .thenKeep( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( terminalPath );
      test.is( !!stat );
      provider.fieldPop( 'resolvingSoftLink', 0 );
      return true;
    })
  })

  /* */

  return con;
}

filesDeleteAsync.timeOut = 20000;

//

function filesDeleteDeletingEmptyDirs( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;
  let hub = context.hub;

  var testPath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    filesTree :
    {
      file : 'file',
      empty1 : {},
      dir1 :
      {
        file : 'file',
        empty2 : {},
        dir2 :
        {
          file : 'file',
          empty3 : {},
        }
      }
    }
  })

  //

  test.case = 'mask dir, deletingEmptyDirs off'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : /dir.$/g }
  var got = provider.filesDelete({ filePath : testPath, filter : filter, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
  ]
  test.will = 'filtered empty dirs should not be deleted';
  test.identical( deleted, expected );

  test.case = 'mask dir, deletingEmptyDirs on'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : /dir.$/g }
  var got = provider.filesDelete({ filePath : testPath, filter : filter, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file'
  ]
  test.will = 'filtered empty dirs should be deleted';
  test.identical( deleted, expected );

  test.case = 'everything is actual, deletingEmptyDirs off'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var got = provider.filesDelete({ filePath : testPath, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'all files should be deleted';
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, includingTerminals : 1, includingDirs : 1, outputFormat : 'relative' })
  var expected = [];
  test.identical( files, expected )

  test.case = 'everything is actual, deletingEmptyDirs on'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var got = provider.filesDelete({ filePath : testPath, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'all files should be deleted + empty parent dirs of root';
  test.is( _.arrayHasAll( deleted, expected ) );

  test.case = 'exclude empty dirs, deletingEmptyDirs off'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : { excludeAny : 'empty'} }
  var got = provider.filesDelete({ filePath : testPath, filter : filter, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
  ]
  test.will = 'empty dirs should be preserved';
  test.identical( deleted, expected );

  test.case = 'exclude empty dirs, deletingEmptyDirs on'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : { excludeAny : 'empty'} }
  var got = provider.filesDelete({ filePath : testPath, filter : filter, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file'
  ]
  test.will = 'only terminals should be deleted';
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, includingTerminals : 1, includingDirs : 1, outputFormat : 'relative' })
  var expected =
  [
    '.',
    './dir1',
    './dir1/dir2',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.will = 'empty dirs should be preserved';
  test.identical( files, expected )

  test.case = 'exclude dirs, deletingEmptyDirs off'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : { excludeAny : /dir.$/g } }
  var got = provider.filesDelete({ filePath : testPath, filter : filter, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'only empty dirs and terminals should be deleted';
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : testPath, includingTerminals : 1, includingDirs : 1, outputFormat : 'relative' })
  var expected =
  [
    '.',
    './dir1',
    './dir1/dir2',
  ];
  test.will = 'dirs should be preserved';
  test.identical( files, expected )

  test.case = 'exclude dirs, deletingEmptyDirs on'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : { excludeAny : /dir.$/g } }
  var got = provider.filesDelete({ filePath : testPath, filter : filter, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'only terminals and empty* dirs should be deleted';
  test.identical( deleted, expected );

}

filesDeleteDeletingEmptyDirs.timeOut = 20000;

//

function filesDeleteEmptyDirs( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;

  var testPath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    filesTree :
    {
      file : 'file',
      empty1 : {},
      dir1 :
      {
        file : 'file',
        empty2 : {},
        dir2 :
        {
          file : 'file',
          empty3 : {},
        }
      }
    }
  })

  //

  test.case = 'defaults'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteEmptyDirs( testPath );
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( expected, got );

  //

  test.case = 'not recursive'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteEmptyDirs({ filePath : testPath, recursive : 1 });
  /*
  {
    file : 'file',
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'filter'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : /empty2$/ };
  provider.filesDeleteEmptyDirs({ filePath : testPath, filter : filter  });
  /*
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'filter for not existing dir'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : 'emptyDir' };
  provider.filesDeleteEmptyDirs({ filePath : testPath, filter : filter });
  /*
  {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'filter for terminals'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskTerminal : 'file' };
  provider.filesDeleteEmptyDirs({ filePath : testPath, filter : filter });
  /*
  {
    file : 'file',
    dir1 :
    {
      file : 'file',
      dir2 :
      {
        file : 'file',
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'glob for dir'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteEmptyDirs( path.join( testPath, '**/empty3' ) );
  /*
  {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'glob for terminals'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteEmptyDirs( path.join( testPath, '**/file') );
  /* {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'glob not existing file'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteEmptyDirs( path.join( testPath, '**/emptyDir' ) );
  /* {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'resolvingSoftLink : 1'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.softLink( path.join( testPath, 'dstPath' ), path.join( testPath, 'dir1' ) )
  provider.filesDeleteEmptyDirs({ filePath : path.join( testPath, 'dstPath' ), resolvingSoftLink : 1  });
  // {
  //   file : 'file',
  //   empty1 : {},
  //   dir1 :
  //   {
  //     file : 'file',
  //     empty2 : {},
  //     dir2 :
  //     {
  //       file : 'file',
  //       empty3 : {},
  //     }
  //   },
  //   dstPath : [{ softLink : '/dir1'}]
  // }
  var expected =
  [
    './dstPath',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'resolvingSoftLink : 0'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.softLink( path.join( testPath, 'dstPath' ), path.join( testPath, 'dir1' ) )
  provider.filesDeleteEmptyDirs({ filePath : path.join( testPath, 'dstPath' ), resolvingSoftLink : 0  });
  /* {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    },
    dstPath : [{ softLink : '/dir'}]
  } */
  var expected =
  [
    './dstPath',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  if( !Config.debug )
  {
    test.case = 'including of terminals is not allow';
    test.shouldThrowError( () => provider.filesDeleteEmptyDirs({ filePath : testPath, includingTerminals : 1 }) )

    test.case = 'including of transients is not allow';
    test.shouldThrowError( () => provider.filesDeleteEmptyDirs({ filePath : testPath, includingTransient : 1 }) )
  }
}

//

function filesDeleteTerminals( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;

  let testPath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    filesTree :
    {
      terminal0 : 'terminal0',
      emptyDir0 : {},
      dir1 :
      {
        terminal1 : 'terminal1',
        emptyDir1 : {},
        dir2 :
        {
          terminal2 : 'terminal2',
          emptyDir2 : {},
        }
      }
    }
  })

  //

  test.case = 'defaults'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteTerminals( testPath );
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'recursion off'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteTerminals({ filePath : testPath, recursive : 0 });
  var expected =
  [
    './terminal0',
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'recursion only first level'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteTerminals({ filePath : testPath, recursive : 1 });
  var expected =
  [
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'mask terminals'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskTerminal : /terminal[01]$/ }
  provider.filesDeleteTerminals({ filePath : testPath, filter : filter });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'mask dirs'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskDirectory : /dir2/ }
  provider.filesDeleteTerminals({ filePath : testPath, filter : filter });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'mask not existing terminal'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var filter = { maskTerminal : /missing/ }
  provider.filesDeleteTerminals({ filePath : testPath, filter : filter });
  var expected =
  [
    './terminal0',
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'glob for terminals'
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteTerminals({ filePath : path.join( testPath, '**/terminal*' ) });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'soft link to directory';
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var linkPath = path.join( testPath, 'linkToDir' );
  var dirPath = path.join( testPath, 'dir1' );
  provider.softLink( linkPath, dirPath );
  test.is( provider.isSoftLink( linkPath ) )
  provider.filesDeleteTerminals({ filePath : testPath });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  // test.case = 'deleting empty dirs';
  // provider.filesDelete( testPath );
  // tree.readToProvider( provider, testPath );
  // provider.filesDeleteTerminals({ filePath : testPath, deletingEmptyDirs : 1 });
  // var expected =
  // [
  //   './dir1',
  //   './dir1/dir2',
  //   './dir1/dir2/emptyDir2',
  //   './dir1/emptyDir1',
  //   './emptyDir0'
  // ]
  // var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  // test.identical( got, expected );

  //

  test.case = 'writing controls delete';
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  provider.filesDeleteTerminals({ filePath : testPath, writing : 0 });
  var expected =
  [
    './terminal0',
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'broken soft link';
  provider.filesDelete( testPath );
  tree.readToProvider( provider, testPath );
  var linkPath = path.join( testPath, 'linkToDir' );
  provider.softLink({ dstPath : linkPath, srcPath :dirPath, allowingMissed : 1 });
  test.is( provider.isSoftLink( linkPath ) )
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  provider.filesDeleteTerminals({ filePath : testPath, allowingMissed : 1 });
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );
  provider.filesDeleteTerminals({ filePath : testPath, allowingMissed : 0 });
  var got = provider.filesFindRecursive({ filePath : testPath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  if( Config.debug )
  {
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : testPath, includingDirs : 1 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : testPath, includingTransient : 1 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : testPath, includingTerminals : 0 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : testPath, resolvingSoftLink : 1 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : testPath, resolvingTextLink : 1 }) )
  }

}

//

function filesDeleteAndAsyncWrite( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  test.case = 'try to delete dir before async write will be completed';

  var testPath = path.join( context.testSuitePath, test.name );


  var cons = [];

  for( var i = 0; i < 10; i++ )
  {
    var terminalPath = path.join( testPath, 'file' + i );
    var con = _.fileProvider.fileWrite({ filePath : terminalPath, data : terminalPath, sync : 0 });
    cons.push( con );
  }

  _.timeOut( 2, () =>
  {
    test.shouldThrowError( () =>
    {
      _.fileProvider.filesDelete( testPath );
    });
  });

  var mainCon = new _.Consequence().take( null );
  mainCon.andKeep( cons );
  mainCon.finally( () =>
  {
    test.mustNotThrowError( () =>
    {
      _.fileProvider.filesDelete( testPath );
    });

    var files = _.fileProvider.dirRead( testPath );
    test.identical( files, null );
  })
  return mainCon;
}

//

function filesFindDifference( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* zzz Needs repair. Files tree is written with "sameTime" option enabled, but files are not having same timestamps anyway,
     probably problem is in method used by HardDrive.fileTimeSetAct
  */

  var testRoutineDir = path.join( context.testSuitePath, test.name );

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
    var dir = path.join( testRoutineDir, './tmp/sample/' + sample.name );
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

    // var files = _.fileProvider.filesFind({ filePath : dir, includingStem : 1, recursive : 2, includingTransient : 1 } );

    // logger.log( context.select( files, '*.relative' ) )
    // logger.log( context.select( files, '*.stat.mtime' ).map( ( test ) => test.getTime() ) )

    var o =
    {
      src : path.join( dir, 'initial/src' ),
      dst : path.join( dir, 'initial/dst' ),
      includingTerminals : 1,
      includingDirs : 1,
      recursive : 2,
      onDown : function( record ){ test.identical( _.objectIs( record ), true ); },
      onUp : function( record ){ test.identical( _.objectIs( record ), true ); },
      /*srcFilter*/src : { ends : sample.ends }
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
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  var testRoutineDir = path.join( context.testSuitePath, test.name );

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
          reason : 'srcLooking',
          action : 'directory preserved',
          allow : true,
          relative : './c'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
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
          relative : './c/dstdir'
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
          action : 'directory preserved',
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

    var dir = path.join( testRoutineDir, './tmp/sample/' + sample.name );
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
      src : path.join( dir, 'initial/src' ),
      dst : path.join( dir, 'initial/dst' ),
      // filter : { ends : sample.ends },
      investigateDestination : 1,
      includingTerminals : 1,
      includingDirs : 1,
      recursive : 2,
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
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  var src = path.join( testPath, 'src' );
  var dst = path.join( testPath, 'dst' );
  _.fileProvider.fileWrite( src, 'data' );
  _.fileProvider.softLink( dst, src );
  _.fileProvider.resolvingSoftLink = 1;

  var files = _.fileProvider.filesFind( dst );
  console.log( _.toStr( files, { levels : 99 } ) );

  // var got2 = _.fileProvider.filesFind( { filePath : __dirname, recursive : 2 } );
  // console.log( got2[ 0 ] );

}

experiment.experimental = 1;

//

function filesFindExperiment2( test )
{
  let context = this;
  let provider = context.provider;
  let path = context.provider.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );

  var filesTree =
  {
    a :
    {
      b :
      {
        terminal : 'terminal'
      }
    }
  }

  provider.filesDelete( testPath );

  _.FileProvider.Extract.readToProvider
  ({
    dstProvider : provider,
    dstPath : testPath,
    filesTree : filesTree,
    allowWrite : 1,
    allowDelete : 1,
    sameTime : 1,
  });

  /*  */

  var got = provider.filesFind
  ({
    filePath : testPath,
    recursive : 2,
    includingTransient : 1,
    includingDirs : 1,
    includingTerminals : 1,
    outputFormat : 'relative'
  })

  var expected =
  [
    '.',
    './a',
    './a/b',
    './a/b/terminal'
  ]

  test.identical( got, expected );

}

filesFindExperiment2.experimental = 1;

//

function filesReflectExperiment( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;

  var testPath = path.join( context.testSuitePath, test.name );

  var srcPath = path.join( testPath, 'src' );
  var dstPath = path.join( testPath, 'dst' );

  var filesTree =
  {
    'src' : { a : 'a', b : { c : '' } },
    'dst' : {},
  }

  _.FileProvider.Extract.readToProvider
  ({
    dstProvider : provider,
    dstPath : testPath,
    filesTree : filesTree,
    allowWrite : 1,
    allowDelete : 1,
  });

  test.case = 'directory for terminal is not created, as the result fileCopy fails'

  var filesReflectOptions =
  {
    reflectMap : { [ srcPath ] : dstPath },
    dstDeleting: 0,
    dstRewriting: 1,
    dstRewritingByDistinct: true,
    includingDirs: 0,
    includingDst: 1,
    includingTerminals: 1,
    recursive: 2,
    srcDeleting: 1
  }

  provider.filesReflect( filesReflectOptions );

  var expected =
  {
    a : 'a', b : { c : '' }
  }
  var got = provider.filesExtract( dstPath );
  test.identical( got.filesTree, expected )

}

filesReflectExperiment.experimental = 1;


// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/FilesFind/Abstract',
  abstract : 1,
  silencing : 1,
  routineTimeOut : 60000,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    provider : null,
    hub : null,
    testSuitePath : null,

    makeStandardExtract,
    _generatePath,
    _filesReflect,
    _filesReflectWithFilter,
    softLinkIsSupported,
    select,
  },

  tests :
  {

    filesFindTrivial,
    filesFindTrivialAsync,
    filesFindMaskTerminal,
    filesFindCriticalCases,
    filesFindPreset,

    filesFind,
    filesFind2,
    filesFindRecursive,
    filesFindLinked,

    filesFindResolving,
    filesFindPerformance,

    filesFindGlob,
    filesGlob,

    filesFindGroups,

    filesReflectEvaluate,
    filesReflectTrivial,
    filesReflectMutuallyExcluding,
    filesReflectWithFilter,
    filesReflect,
    filesReflectRecursive,
    filesReflectToItself,
    filesReflectGrab,
    filesReflector,
    filesReflectWithHub,
    filesReflectLinkWithHub,
    filesReflectDeducing,
    filesReflectDstPreserving,
    filesReflectDstDeletingDirs,
    filesReflectLinked,
    filesReflectTo,

    filesDeleteTrivial,
    filesDelete,
    filesDeleteAsync,
    filesDeleteDeletingEmptyDirs,
    filesDeleteEmptyDirs,
    filesDeleteTerminals,
    // filesDeleteAndAsyncWrite,

    // filesFindDifference,
    // filesCopyWithAdapter,

    experiment,
    filesFindExperiment2,
    filesReflectExperiment

  },

};

wTestSuite( Self );

})();
