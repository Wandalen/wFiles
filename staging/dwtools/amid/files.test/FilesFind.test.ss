( function _Files_find_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;

//

function onSuiteBegin()
{
  this.isBrowser = typeof module === 'undefined';

  if( !this.isBrowser )
  this.testRootDirectory = _.path.dirTempMake( _.path.join( __dirname, '../..' ) );
  else
  this.testRootDirectory = _.path.current();
}

//

function onSuiteEnd()
{
  if( !this.isBrowser )
  _.fileProvider.filesDelete( this.testRootDirectory );
}

//

function makeStandardExtract()
{
  let extract = _.FileProvider.Extract
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

  if( !self.isBrowser && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allowed = false;
    var dir = _.path.join( self.testRootDirectory, 'symlinkIsAllowed' );
    var srcPath = _.path.join( dir, 'src' );
    var dstPath = _.path.join( dir, 'dst' );

    _.fileProvider.filesDelete( dir );
    _.fileProvider.fileWrite( srcPath, srcPath );

    try
    {
      _.fileProvider.linkSoft({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allowed = _.fileProvider.fileIsSoftLink( dstPath );
    }
    catch( err )
    {
      logger.error( err );
    }

    return allowed;
  }

  return true;
}


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

function _filesFindTrivial( t,provider )
{
  var context = this;

  /* */

  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });

  t.description = 'setup trivial';

  wasTree1.readToProvider( provider,context.testRootDirectory );
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider, context.testRootDirectory );
  t.identical( gotTree.filesTree, wasTree1.filesTree );

  wasTree1.readToProvider( provider,context.testRootDirectory );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 1, includingTerminals : 1 }
  t.description = 'find single terminal file . includingDirectories : 1';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [ '.' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 0, includingTerminals : 1 }
  t.description = 'find single terminal file . includingDirectories : 0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 0, includingDirectories : 1, includingTerminals : 1 }
  t.description = 'find single terminal file . includingBase : 0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [];
  t.identical( got, expected );

  //

  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  t.description = 'setup trivial';

  wasTree1.readToProvider( provider,context.testRootDirectory );
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider,context.testRootDirectory );
  t.identical( gotTree.filesTree, wasTree1.filesTree );

  wasTree1.readToProvider( provider,context.testRootDirectory );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory,'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 1, includingTerminals : 1 }
  t.description = 'find single terminal file . includingTerminals : 1';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [ '.' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory,'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 1, includingTerminals : 0 }
  t.description = 'find single terminal file . includingTerminals : 0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory,'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 0, includingDirectories : 1, includingTerminals : 1 }
  t.description = 'find single terminal file . includingBase : 0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [];
  t.identical( got, expected );

  //

  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : '1', b : '1', dir11 : {} },
      dir2 : { c : '1' },
      d : '1',
    },
  });

  t.description = 'setup trivial';

  wasTree1.readToProvider({ dstProvider : provider, dstPath : context.testRootDirectory, allowDelete : 1 });
  //!!!terminals from directories are not included because of problem with ** glob
  var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider,context.testRootDirectory );
  t.identical( gotTree.filesTree, wasTree1.filesTree );

  wasTree1.readToProvider( provider,context.testRootDirectory );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 1, includingTerminals : 1 }
  t.description = 'find includingBase : 1';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [ '.', './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 0, includingDirectories : 1, includingTerminals : 1 }
  t.description = 'find includingBase:0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [ './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 0, includingTerminals : 1 }
  t.description = 'find includingDirectories:0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  var expected = [ './d', './dir1/a', './dir1/b', './dir2/c' ];
  t.identical( got, expected );

  /* */

  var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  var o2 = { recursive : 1, includingBase : 1, includingDirectories : 1, includingTerminals : 0 }
  t.description = 'find includingTerminals:0';

  var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
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
  // t.description = 'setup trivial';
  //
  // wasTree1.readToProvider({ dstProvider : provider, dstPath : context.testRootDirectory, allowDelete : 1 });
  // var gotTree = _.FileProvider.Extract().rewriteFromProvider( provider,context.testRootDirectory );
  // t.identical( gotTree.filesTree, wasTree1.filesTree );
  //
  // logger.log( 'context.testRootDirectory',_.fileProvider.nativize( context.testRootDirectory ) );

  // /* */
  //
  // // var o1 = { filePath : _.path.join( context.testRootDirectory ), outputFormat : 'relative' }
  // // var o2 = { recursive : 1, includingBase : 1, includingDirectories : 1, includingTerminals : 1 }
  // // t.description = 'find includingTerminals:0';
  // //
  // // var got = provider.filesFind( _.mapExtend( null,o1,o2 ) );
  // // var expected = [ '.', './dir1', './dir1/dir11', './dir2' ];
  // // t.identical( got, expected );
  //
}

//

function filesFindTrivial( t )
{
  var context = this;

  var provider = _.FileProvider.Extract();
  context._filesFindTrivial( t,provider );

  var provider = _.FileProvider.HardDrive();
  context._filesFindTrivial( t,provider );

}

//

function filesFind( test )
{
  var testDir = _.path.join( test.context.testRootDirectory, test.name );

  var fixedOptions =
  {
    basePath : null,
    // filePath : testDir,
    // strict : 1,
    ignoringNonexistent : 1,
    result : [],
    orderingExclusion : [],
    sortingWithArray : null,

  }

  //

  test.case = 'native path';
  var got = _.fileProvider.filesFind
  ({
    filePath : __filename,
    includingTerminals : 1,
    includingDirectories : 0,
    outputFormat : 'absolute'
  });
  var expected = [ _.path.normalize( __filename ) ];
  test.identical( got, expected );

  //

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
    includingDirectories : 1,
    outputFormat : 'absolute',
    onUp : onUp,
    onDown : onDown,
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
  var recursive = [ 0, 1 ];
  var includingTerminals = [ 0, 1 ];
  var includingDirectories = [ 0, 1 ];

  if( require.main === module )
  var filePaths = [ _.path.realMainFile(), testDir ];
  else
  var filePaths = [ _.path.normalize( __filename ), testDir ];

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
    '{x.*,a.*}'
  ];

  outputFormat.forEach( ( _outputFormat ) =>
  {
    filePaths.forEach( ( filePath ) =>
    {
      recursive.forEach( ( _recursive ) =>
      {
        includingTerminals.forEach( ( _includingTerminals ) =>
        {
          includingDirectories.forEach( ( _includingDirectories ) =>
          {
            globs.forEach( ( glob ) =>
            {
              var o =
              {
                outputFormat : _outputFormat,
                recursive : _recursive,
                includingTerminals : _includingTerminals,
                includingDirectories : _includingDirectories,
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

  //

  function prepareFiles( level )
  {
    if( _.fileProvider.fileStat( testDir ) )
    _.fileProvider.filesDelete( testDir );

    var path = testDir;
    for( var i = 0; i <= level; i++ )
    {
      if( i >= 1 )
      path = _.path.join( path, '' + i );

      for( var j = 0; j < filesNames.length; j++ )
      {
        var filePath = _.path.join( path, filesNames[ j ] );
        // var filePath = _.path.join( path, i + '-' + filesNames[ j ] );
        _.fileProvider.fileWrite( filePath, '' );
      }
    }
  }

  //

  var clone = function( src )
  {
    var res = Object.create( null );
    _.mapOwnKeys( src )
    .forEach( ( key ) =>
    {
      var val = src[ key ];
      if( _.objectIs( val ) )
      res[ key ] = clone( val );
      if( _.longIs( val ) )
      res[ key ] = val.slice();
      else
      res[ key ] = val;
    })

    return res;
  }

  //

  function makeExpected( level, o )
  {
    var expected = [];
    var path = testDir;

    var directoryIs = _.fileProvider.directoryIs( o.filePath );

    if( directoryIs && o.includingDirectories )
    {
      if( o.outputFormat === 'absolute' ||  o.outputFormat === 'record' )
      _.arrayPrependOnce( expected, o.filePath );

      if( o.outputFormat === 'relative' )
      _.arrayPrependOnce( expected, _.path.relative( o.filePath, o.filePath ) );
    }

    if( !directoryIs )
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

          var passed = _.path.globRegexpsForTerminal( o.glob ).test( toTest );
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
      if( l > 0 )
      {
        path = _.path.join( path, '' + l );
        if( o.includingDirectories )
        {
          if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
          expected.push( path );
          if( o.outputFormat === 'relative' )
          expected.push( _.path.dot( _.path.relative( o.basePath || testDir, path ) ) );
        }
      }

      if( !o.recursive && l > 0 )
      break;

      if( o.includingTerminals )
      {

        filesNames.forEach( ( name ) =>
        {
          // var filePath = _.path.join( path,l + '-' + name );
          var filePath = _.path.join( path,name );
          var passed = true;
          var relative = _.path.dot( _.path.relative( o.basePath || testDir, filePath ) );

          if( o.glob )
          passed = _.path.globRegexpsForTerminal( o.glob ).test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( filePath );
            if( o.outputFormat === 'relative' )
            expected.push( relative );
          }
        })
      }
    }

    return expected;
  }

  /* filesFind test */

  var n = 0;
  for( var l = 0; l < levels; l++ )
  {
    prepareFiles( l );
    combinations.forEach( ( c ) =>
    {
      var info = clone( c );
      info.level = l;
      info.number = ++n;
      test.case = _.toStr( info, { levels : 3 } )
      var checks = [];
      var options = clone( c );

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
        checks.push( test.identical( files.sort(), expected.sort() ) );
      }

      info.passed = true;
      checks.forEach( ( check ) => { info.passed &= check; } )
      testsInfo.push( info );
    })
  }


  /**/

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
        'a' : clone( part ),
        'b' : clone( part ),
        'c' : clone( part ),
      }
    }

    _.fileProvider.filesDelete( testDir );

    for( var i = 0; i < numberOfDuplicates; i++ )
    {
      var keys = _.mapOwnKeys( tree );
      var key = keys.pop();
      tree[ String.fromCharCode( key.charCodeAt(0) + 1 ) ] = clone( tree[ key ] );
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
    makePaths( tree ,testDir );
    paths.sort();
    paths.forEach( ( p ) => _.fileProvider.fileWrite( p, '' ) )
    return paths;
  }

  var allFiles =  prepareTree( 1 );

  /**/

  var complexGlobs =
  [
    '**/a/a.?',
    '**/b/a.??',
    '**/c/{x.*,c.*}',
    'a/**/c/{x.*,c.*}',
    '**/b/{x,c}/*',
    '**/[!ab]/*.?s',
    'b/[a-c]/**/a/*',
    '[ab]/**/[!ac]/*',
  ]

  complexGlobs.forEach( ( glob ) =>
  {
    var o =
    {
      outputFormat : 'absolute',
      recursive : 1,
      includingTerminals : 1,
      includingDirectories : 0,
      basePath : testDir,
      glob : glob,
      filePath : testDir
    };

    _.mapSupplement( o, fixedOptions );

    var info = clone( o );
    info.level = levels;
    info.number = ++n;
    test.case = _.toStr( info, { levels : 3 } )
    var files = _.fileProvider.filesFind( clone( o ) );
    var tester = _.path.globRegexpsForTerminal( info.glob );
    var expected = allFiles.slice();
    expected = expected.filter( ( p ) =>
    {
      return tester.test( './' + _.path.relative( testDir, p ) )
    });
    var checks = [];
    checks.push( test.identical( files.sort(), expected.sort() ) );

    info.passed = true;
    checks.forEach( ( check ) => { info.passed &= check; } )
    testsInfo.push( info );
  })

  /* drawInfo */

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
        !!i.includingDirectories,
        i.glob || '-',
        !!i.passed
      ])
    })

    var o =
    {
      data : t,
      head : [ '#', 'level', 'outputFormat', 'recursive','i.terminals','i.directories', 'glob', 'passed' ],
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

  drawInfo( testsInfo );

}

//

function filesFind2( t )
{
  var dir = _.path.join( t.context.testRootDirectory, t.name );
  var provider = _.FileProvider.HardDrive();
  var filePath,got,expected;

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

  //

  function _orderingExclusion( src, orderingExclusion  )
  {
    var result = [];
    orderingExclusion = _.RegexpObject.order( orderingExclusion );
    for( var i = 0; i < orderingExclusion.length; i++ )
    {
      for( var j = 0; j < src.length; j++ )
      {
        if( _.RegexpObject.test( orderingExclusion[ i ], src[ j ]  ) )
        if( _.arrayRightIndex( result,src[ j ] ) >= 0 )
        continue;
        else
        result.push( src[ j ] );
      }
    }
    return result;
  }

  //

  t.description = 'default options';

  /*filePath - directory*/

  got = provider.filesFind( dir );
  expected = provider.directoryRead( dir );
  t.identical( check( got,expected ), true );

  /*filePath - terminal file*/

  filePath = _.path.join( dir, __filename );
  got = provider.filesFind( filePath );
  expected = provider.directoryRead( filePath );
  t.identical( check( got,expected ), true );

  /*filePath - empty dir*/

  filePath = _.path.join( t.context.testRootDirectory, 'tmp/empty' );
  provider.directoryMake( filePath )
  got = provider.filesFind( filePath );
  t.identical( got, [] );

  //

  t.description = 'ignoringNonexistent option';
  filePath = _.path.join( dir, __filename );

  /*filePath - relative path*/
  t.shouldThrowErrorSync( function()
  {
    provider.filesFind
    ({
      filePath : 'invalid path',
      ignoringNonexistent : 0
    });
  })

  /*filePath - not exist*/

  got = provider.filesFind
  ({
    filePath : '/invalid path',
    ignoringNonexistent : 0
  });
  t.identical( got, [] );

  /*filePath - some pathes not exist,ignoringNonexistent off*/

  got = provider.filesFind
  ({
    filePath : [ '/0', filePath, '/1' ],
    ignoringNonexistent : 0
  });
  expected = provider.directoryRead( filePath );
  t.identical( check( got, expected ), true )

  /*filePath - some pathes not exist,ignoringNonexistent on*/

  got = provider.filesFind
  ({
    filePath : [ '/0', filePath, '/1' ],
    ignoringNonexistent : 1
  });
  expected = provider.directoryRead( filePath );
  t.identical( check( got, expected ), true )


  //

  t.description = 'includingTerminals,includingDirectories options';

  /*filePath - empty dir, includingTerminals,includingDirectories on*/

  provider.directoryMake( _.path.join( t.context.testRootDirectory, 'empty' ) )
  got = provider.filesFind({ filePath : _.path.join( dir, 'empty' ), includingTerminals : 1, includingDirectories : 1 });
  t.identical( got, [] );

  /*filePath - empty dir, includingTerminals,includingDirectories off*/

  provider.directoryMake( _.path.join( t.context.testRootDirectory, 'empty' ) )
  got = provider.filesFind({ filePath : _.path.join( dir, 'empty' ), includingTerminals : 0, includingDirectories : 0 });
  t.identical( got, [] );

  /*filePath - directory, includingTerminals,includingDirectories on*/

  got = provider.filesFind({ filePath : dir, includingTerminals : 1, includingDirectories : 1, includingBase : 0 });
  expected = provider.directoryRead( dir );
  t.identical( check( got,expected ), true );

  /*filePath - directory, includingTerminals,includingDirectories off*/

  got = provider.filesFind({ filePath : dir, includingTerminals : 0, includingDirectories : 0 });
  expected = provider.directoryRead( dir );
  t.identical( got, [] );

  /*filePath - directory, includingTerminals off,includingDirectories on*/

  got = provider.filesFind({ filePath : dir, includingTerminals : 0, includingDirectories : 1, includingBase : 0 });
  expected = provider.directoryRead( dir );
  t.identical( check( got,expected ), true  );

  /*filePath - terminal file, includingTerminals,includingDirectories off*/

  filePath = _.path.join( dir, __filename );
  got = provider.filesFind({ filePath : filePath, includingTerminals : 0, includingDirectories : 0 });
  expected = provider.directoryRead( dir );
  t.identical( got, [] );

  /*filePath - terminal file, includingTerminals off,includingDirectories on*/

  filePath = _.path.join( dir, __filename );
  got = provider.filesFind({ filePath : filePath, includingTerminals : 0, includingDirectories : 1 });
  t.identical( got, [] );

  //

  t.description = 'outputFormat option';

  /*filePath - directory,outputFormat absolute */

  got = provider.filesFind({ filePath : dir, outputFormat : 'record' });
  function recordIs( element ){ return element.constructor.name === 'wFileRecord' };
  expected = provider.directoryRead( dir );
  t.identical( check( got, recordIs ), true );

  /*filePath - directory,outputFormat absolute */

  got = provider.filesFind({ filePath : dir, outputFormat : 'absolute' });
  expected = provider.directoryRead( dir );
  t.identical( check( got, _.path.isAbsolute ), true );

  /*filePath - directory,outputFormat relative */

  got = provider.filesFind({ filePath : dir, outputFormat : 'relative' });
  expected = provider.directoryRead( dir );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = _.path.join( './', expected[ i ] );
  t.identical( check( got, expected ), true );

  /*filePath - directory,outputFormat nothing */

  got = provider.filesFind({ filePath : dir, outputFormat : 'nothing' });
  t.identical( got, [] );

  /*filePath - directory,outputFormat unexpected */

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
  expected = provider.directoryRead( dir );
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
    maskTerminal : 'Files',
    outputFormat : 'relative'
  });
  expected = provider.directoryRead( dir );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.test( 'Files', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  t.identical( got, expected );

  /*filePath - directory, maskDir, includingDirectories */

  filePath = _.path.join( t.context.testRootDirectory, 'tmp/dir' );
  provider.directoryMake( filePath );

  got = provider.filesFind
  ({
    filePath : filePath,
    basePath : _.path.dir( filePath ),
    includingDirectories : 1,
    maskDir : 'dir',
    outputFormat : 'relative',
    includingBase : 1,
    includingTerminals : 1,
    recursive : 1
  });
  expected = provider.directoryRead( _.path.dir( filePath ) );
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
    maskAll : 'a12b',
  });
  t.identical( got, [] );

  /*filePath - directory, orderingExclusion mask,maskTerminal null,expected order Caching->Files*/

  var orderingExclusion = [ 'src','dir3' ];
  got = provider.filesFind
  ({
    filePath : dir,
    orderingExclusion : orderingExclusion,
    includingDirectories : 1,
    maskTerminal : null,
    outputFormat : 'record'
  });
  got = got.map( ( r ) => r.relative );
  expected = _orderingExclusion( provider.directoryRead( dir ), orderingExclusion );
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
    basePath : relative,
  });
  got = got[ 0 ].relative;
  var begins = './' + _.path.relative( relative, _.path.join( dir, 'src/dir' ) );
  t.identical( _.strBegins( got, begins ), true );

  /* changing relative path affects only record.relative*/

  got = provider.filesFind
  ({
    filePath : dir,
    basePath : '/x/a/b',
    recursive : 1,
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

function filesFindResolving( test )
{
  var testDir = _.path.join( test.context.testRootDirectory, test.name );

  var symlinkIsAllowed = test.context.symlinkIsAllowed();

  var fixedOptions =
  {
    basePath : null,
    ignoringNonexistent : 1,
    orderingExclusion : [],
    sortingWithArray : null,
    outputFormat : 'record',
    includingBase : 1,
    includingTerminals : 1,
    includingDirectories : 1,
    recursive : 1
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
      isDir : record._isDir()
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

    resolvingSoftLink : 0,1
    resolvingTextLink : 0,1
    provider : usingTextLink : 0,1

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
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
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
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
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
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
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
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

  //

  makeCleanTree( testDir );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
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
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 0';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );


  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 0';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

   //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

  //

  test.case = 'text->text->file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  var textLink2Path = _.path.join( testDir, 'textLink2' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var textLink2Stat = findRecord( files, 'absolute', textLink2Path ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, textLink2Stat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.is( srcFileStat.ino !== softLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
  var softLink = _.path.join( testDir, 'link' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 0';
  var srcDirPath = _.path.join( testDir, 'dir' );
  var softLink = _.path.join( testDir, 'linkToDir' );
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
  _.fileProvider.filesDelete( testDir );
  makeCleanTree( srcDirPath );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
    includingBase : 0
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.linkSoft( softLink, srcDirPath );

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
  var srcDirStat = _.fileProvider.fileStat( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 1';
  var srcDirPath = _.path.join( testDir, 'dir' );
  var softLink = _.path.join( testDir, 'linkToDir' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
  _.fileProvider.filesDelete( testDir );
  makeCleanTree( srcDirPath );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.linkSoft( softLink, srcDirPath );

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
  var srcDirStat = _.fileProvider.fileStat( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
  _.fileProvider.linkSoft( softLink2, softLink );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
  _.fileProvider.linkSoft( softLink2, softLink );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 0 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
  _.fileProvider.linkSoft( softLink2, srcPath );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 0 );

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
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
  var softLink = _.path.join( testDir, 'link' );
  var softLink2 = _.path.join( testDir, 'link2' );
  var srcPath = filePaths[ 0 ];
  _.fileProvider.linkSoft( softLink, srcPath );
  _.fileProvider.linkSoft( softLink2, srcPath );
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
  var srcFileStat = _.fileProvider.fileStat( filePaths[ 0 ] );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  makeCleanTree( testDir );
  var srcFilePath = filePaths[ 0 ];
  var textLinkPath = _.path.join( testDir, 'textLink' );
  var softLinkPath = _.path.join( testDir, 'softLinkPath' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  _.fileProvider.linkSoft( softLinkPath, textLinkPath );

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
  var srcFileStat = _.fileProvider.fileStat( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, softLinkStat.ino );
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  _.fileProvider.filesDelete( testDir );
  var srcDirPath = _.path.join( testDir, 'dir' );
  makeCleanTree( srcDirPath );
  var textLinkPath = _.path.join( testDir, 'textLink' );
  var softLinkPath = _.path.join( testDir, 'softLinkPath' );
  _.fileProvider.fieldSet( 'usingTextLink', 1 );
  var o =
  {
    filePath : testDir,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  _.fileProvider.fileWrite( textLinkPath, 'link ' + srcDirPath );
  _.fileProvider.linkSoft( softLinkPath, textLinkPath );

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
  var srcDirStat = _.fileProvider.fileStat( srcDirPath );
  var srcFileStat = findRecord( files, 'absolute', filePaths[ 0 ] ).stat;
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcDirStat.ino, textLinkStat.ino );
  test.identical( srcDirStat.ino, softLinkStat.ino );
  test.is( srcFileStat.ino !== textLinkStat.ino )
  test.is( srcFileStat.ino !== softLinkStat.ino )
  _.fileProvider.fieldReset( 'usingTextLink', 1 );

}

//

function filesFindPerformance( t )
{
  var context = this;
  t.description = 'filesFind time test';

  /*prepare files */

  var dir = _.path.join( t.context.testRootDirectory, t.name );
  var provider = _.FileProvider.HardDrive();

  var filesNumber = 2000;
  var levels = 5;

  if( !_.fileProvider.fileStat( dir ) )
  {
    logger.log( 'Creating ', filesNumber, ' random files tree. ' );
    var t1 = _.timeNow();
    for( var i = 0; i < filesNumber; i++ )
    {
      var path = context._generatePath( dir, Math.random() * levels );
      provider.fileWrite({ filePath : path, data : 'abc', writeMode : 'rewrite' } );
    }

    logger.log( _.timeSpent( 'Spent to make ' + filesNumber +' files tree',t1 ) );
  }

  var times = 10;

  /*default filesFind*/

  var t2 = _.timeNow();
  for( var i = 0; i < times; i++)
  {
    var files = provider.filesFind
    ({
      filePath : dir,
      recursive : 1
    });
  }

  logger.log( _.timeSpent( 'Spent to make  provider.filesFind x' + times + ' times in dir with ' + filesNumber +' files tree',t2 ) );

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
  //     recursive : 1
  //   });
  // }
  // logger.log( _.timeSpent( 'Spent to make CachingStats.filesFind x' + times + ' times in dir with ' + filesNumber +' files tree',t2 ) );

  /*stats, directoryRead filters filesFind*/

  // var filter = _.FileFilter.Caching();
  // var t2 = _.timeNow();
  // for( var i = 0; i < times; i++)
  // {
  //   var files = filter.filesFind
  //   ({
  //     filePath : dir,
  //     recursive : 1
  //   });
  // }

  // logger.log( _.timeSpent( 'Spent to make filesFind with three filters x' + times + ' times in dir with ' + filesNumber +' files tree',t2 ) );

  // t.identical( files.length, filesNumber );
}

filesFindPerformance.timeout = 150000;

//

// test.is( _.path.isGlob( '?' ) );
// test.is( _.path.isGlob( '*' ) );
// test.is( _.path.isGlob( '**' ) );
//
// test.is( _.path.isGlob( '?c.js' ) );
// test.is( _.path.isGlob( '*.js' ) );
// test.is( _.path.isGlob( '**/a.js' ) );
//
// test.is( _.path.isGlob( 'dir?c/a.js' ) );
// test.is( _.path.isGlob( 'dir/*.js' ) );
// test.is( _.path.isGlob( 'dir/**.js' ) );
// test.is( _.path.isGlob( 'dir/**/a.js' ) );
//
// test.is( _.path.isGlob( '[a-c]' ) );
// test.is( _.path.isGlob( '{a,c}' ) );
// test.is( _.path.isGlob( '(a|b)' ) );
//
// test.is( _.path.isGlob( '(ab)' ) );
// test.is( _.path.isGlob( '@(ab)' ) );
// test.is( _.path.isGlob( '!(ab)' ) );
// test.is( _.path.isGlob( '?(ab)' ) );
// test.is( _.path.isGlob( '*(ab)' ) );
// test.is( _.path.isGlob( '+(ab)' ) );
//
// test.is( _.path.isGlob( 'dir/[a-c].js' ) );
// test.is( _.path.isGlob( 'dir/{a,c}.js' ) );
// test.is( _.path.isGlob( 'dir/(a|b).js' ) );
//
// test.is( _.path.isGlob( 'dir/(ab).js' ) );
// test.is( _.path.isGlob( 'dir/@(ab).js' ) );
// test.is( _.path.isGlob( 'dir/!(ab).js' ) );
// test.is( _.path.isGlob( 'dir/?(ab).js' ) );
// test.is( _.path.isGlob( 'dir/*(ab).js' ) );
// test.is( _.path.isGlob( 'dir/+(ab).js' ) );

/*
(\*\*)| -- **
([?*])| -- ?*
(\[[!^]?.*\])| -- [!^]
([+!?*@]\(.*\))| -- @+!?*()
(\{.*\}) -- {}
*/

function filesFindGlob( test )
{
  var context = this;
  var provider = context.makeStandardExtract();

  var onUp = function onUp( record )
  {
    onUpAbsolutes.push( record.absolute );
    return record;
  }

  var onDown = function onDown( record )
  {
    onDownAbsolutes.push( record.absolute );
    return record;
  }

  var onDownAbsolutes = [];
  var onUpAbsolutes = [];
  function clean()
  {
    onDownAbsolutes = [];
    onUpAbsolutes = [];
  }

  var globTerminals = provider.filesGlober
  ({
    filePath : '/',
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirectories : 0,
    recursive : 1,
  });

  var globAll = provider.filesGlober
  ({
    filePath : '/',
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirectories : 1,
    recursive : 1,
  });

  /* */

  test.case = 'globTerminals /src1/** - extended'; /* */

  clean();

  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnUpAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnDownAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsolutes, expectedOnUpAbsolutes );
  test.identical( onDownAbsolutes, expectedOnDownAbsolutes );

  test.case = 'globAll /src1/** - extended';

  clean();

  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnUpAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var expectedOnDownAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1/d', '/src1', '/' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsolutes, expectedOnUpAbsolutes );
  test.identical( onDownAbsolutes, expectedOnDownAbsolutes );

  test.case = 'globTerminals src1/** - extended relative';

  clean();

  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c' ];
  var expectedOnUpAbsolutes = [ '/src1/a', '/src1/b', '/src1/c' ];
  var expectedOnDownAbsolutes = [ '/src1/a', '/src1/b', '/src1/c' ];
  var records = globTerminals({ glob : '*', filePath : '/src1' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsolutes, expectedOnUpAbsolutes );
  test.identical( onDownAbsolutes, expectedOnDownAbsolutes );

  test.case = 'globAll src1/** - extended relative';

  clean();

  var expectedAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var expectedOnUpAbsolutes = [ '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var expectedOnDownAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1' ];
  var records = globAll({ glob : '*', filePath : '/src1' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );

  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( onUpAbsolutes, expectedOnUpAbsolutes );
  test.identical( onDownAbsolutes, expectedOnDownAbsolutes );

  test.case = 'globTerminals /src1/**'; /* */

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1/**'; /* */

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1**'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b/a' ];
  var records = globTerminals( '/src1**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1**';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b', '/src1b/a' ];
  var records = globAll( '/src1**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1/*'; /* */

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c' ];
  var records = globTerminals( '/src1/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/*';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d' ];
  var records = globAll( '/src1/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1*'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals( '/src1*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1*';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/src1', '/src1b' ];
  var records = globAll( '/src1*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src3/** - nothing'; /* */

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals( '/src3/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src3/** - nothing';

  clean();
  var expectedAbsolutes = [ '/' ];
  var records = globAll( '/src3/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src?'; /* */

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/src?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src?';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src1', '/src2' ];
  var records = globAll( '/src?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src?*'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT' ];
  var records = globTerminals( '/src?*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src?*';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '/src?*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src*?'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT' ];
  var records = globTerminals( '/src*?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src*?';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '/src*?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src**?'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT', '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b/a', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d/a', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d/a' ];
  var records = globTerminals( '/src**?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src**?';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b', '/src1b/a', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d', '/src3.js/d/a', '/src3.s', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d', '/src3.s/d/a' ];
  var records = globAll( '/src**?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src?**'; /* */

  clean();
  var expectedAbsolutes = [ '/src1Terminal', '/srcT', '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b/a', '/src2/a', '/src2/b', '/src2/c', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d/a', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d/a' ];
  var records = globTerminals( '/src?**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src?**';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal', '/srcT', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src1b', '/src1b/a', '/src2', '/src2/a', '/src2/b', '/src2/c', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c', '/src3.js', '/src3.js/a', '/src3.js/b.s', '/src3.js/c.js', '/src3.js/d', '/src3.js/d/a', '/src3.s', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d', '/src3.s/d/a' ];
  var records = globAll( '/src?**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+(src)2'; /* */

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals( '/+(src)2' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+(src)2';

  clean();
  var expectedAbsolutes = [ '/', '/src2' ];
  var records = globAll( '/+(src)2' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+(alt)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/altalt/a' ];
  var records = globTerminals( '/+(alt)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+(alt)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/altalt', '/altalt/a', '/altalt/d' ];
  var records = globAll( '/+(alt)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+(alt|ctrl)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/altalt/a', '/altctrl/a', '/altctrlalt/a', '/ctrl/a', '/ctrlctrl/a' ]
  var records = globTerminals( '/+(alt|ctrl)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+(alt|ctrl)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/altalt', '/altalt/a', '/altalt/d', '/altctrl', '/altctrl/a', '/altctrl/d', '/altctrlalt', '/altctrlalt/a', '/altctrlalt/d', '/ctrl', '/ctrl/a', '/ctrl/d', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d' ];
  var records = globAll( '/+(alt|ctrl)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /*(alt|ctrl)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/altalt/a', '/altctrl/a', '/altctrlalt/a', '/ctrl/a', '/ctrlctrl/a' ];
  var records = globTerminals( '/*(alt|ctrl)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*(alt|ctrl)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/altalt', '/altalt/a', '/altalt/d', '/altctrl', '/altctrl/a', '/altctrl/d', '/altctrlalt', '/altctrlalt/a', '/altctrlalt/d', '/ctrl', '/ctrl/a', '/ctrl/d', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d' ];
  var records = globAll( '/*(alt|ctrl)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt*(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/altalt2/a', '/altctrl2/a', '/altctrlalt2/a' ];
  var records = globTerminals( '/alt*(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt*(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/altalt2', '/altalt2/a', '/altalt2/d', '/altctrl2', '/altctrl2/a', '/altctrl2/d', '/altctrlalt2', '/altctrlalt2/a', '/altctrlalt2/d' ];
  var records = globAll( '/alt*(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /*(alt|ctrl|2)/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt/a', '/alt2/a', '/altalt/a', '/altalt2/a', '/altctrl/a', '/altctrl2/a', '/altctrlalt/a', '/altctrlalt2/a', '/ctrl/a', '/ctrl2/a', '/ctrlctrl/a', '/ctrlctrl2/a' ];
  var records = globTerminals( '/*(alt|ctrl|2)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*(alt|ctrl|2)/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/a', '/alt/d', '/alt2', '/alt2/a', '/alt2/d', '/altalt', '/altalt/a', '/altalt/d',
    '/altalt2', '/altalt2/a', '/altalt2/d', '/altctrl', '/altctrl/a', '/altctrl/d', '/altctrl2', '/altctrl2/a', '/altctrl2/d',
    '/altctrlalt', '/altctrlalt/a', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/a', '/altctrlalt2/d', '/ctrl', '/ctrl/a',
    '/ctrl/d', '/ctrl2', '/ctrl2/a', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/a', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/a', '/ctrlctrl2/d' ];
  var records = globAll( '/*(alt|ctrl|2)/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt?(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/altalt2/a', '/altctrl2/a' ];
  var records = globTerminals( '/alt?(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt?(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/altalt2', '/altalt2/a', '/altalt2/d', '/altctrl2', '/altctrl2/a', '/altctrl2/d' ];
  var records = globAll( '/alt?(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt!(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a' ];
  var records = globTerminals( '/alt!(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt!(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d' ];
  var records = globAll( '/alt!(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /alt!(ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/altalt/a', '/altalt2/a' ];
  var records = globTerminals( '/alt!(ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /alt!(ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/altalt', '/altalt/a', '/altalt/d', '/altalt2', '/altalt2/a', '/altalt2/d' ];
  var records = globAll( '/alt!(ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /@(alt|ctrl)?/*'; /* */

  clean();
  var expectedAbsolutes = [ '/alt2/a', '/ctrl2/a' ];
  var records = globTerminals( '/@(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /@(alt|ctrl)?/*';

  clean();
  var expectedAbsolutes = [ '/', '/alt2', '/alt2/a', '/alt2/d', '/ctrl2', '/ctrl2/a', '/ctrl2/d' ];
  var records = globAll( '/@(alt|ctrl)?/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /*([c-s])?';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/*([c-s])?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /*([c-s])?';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src1', '/src2' ];
  var records = globAll( '/*([c-s])?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /+([c-s])?';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '/+([c-s])?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /+([c-s])?';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src1', '/src2' ];
  var records = globAll( '/+([c-s])?' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals +([lrtc])';

  clean();
  var expectedAbsolutes = [];
  var records = globTerminals( '+([lrtc])' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([lrtc])';

  clean();
  var expectedAbsolutes = [ '/', '/ctrl', '/ctrlctrl' ];
  var records = globAll( '+([lrtc])' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals +([^lt])';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '+([^lt])' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([^lt])';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '+([^lt])' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.case = 'globTerminals +([!lt])';

  clean();
  var expectedAbsolutes = [ '/srcT' ];
  var records = globTerminals( '+([!lt])' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll +([!lt])';

  clean();
  var expectedAbsolutes = [ '/', '/srcT', '/src1', '/src1b', '/src2', '/src3.js', '/src3.s' ];
  var records = globAll( '+([!lt])' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* - */

  test.case = 'globTerminals src1/**/*';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( 'src1/**/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll src1/**/*';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( 'src1/**/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* - */

  test.case = 'globTerminals **/*.s';

  clean();
  var expectedAbsolutes = [ '/src3.js/b.s', '/src3.s/b.s' ];
  var records = globTerminals( '**/*.s' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **/*.s';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/d', '/alt2', '/alt2/d', '/altalt', '/altalt/d', '/altalt2', '/altalt2/d', '/altctrl', '/altctrl/d', '/altctrl2', '/altctrl2/d', '/altctrlalt', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/d', '/ctrl', '/ctrl/d', '/ctrl2', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/d', '/doubledir', '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d2', '/doubledir/d2/d22', '/src1', '/src1/d', '/src1b', '/src2', '/src2/d', '/src3.js', '/src3.js/b.s', '/src3.js/d', '/src3.s', '/src3.s/b.s', '/src3.s/d' ];
  var records = globAll( '**/*.s' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals **/*.js';

  clean();
  var expectedAbsolutes = [ '/src3.js/c.js', '/src3.s/c.js' ];
  var records = globTerminals( '**/*.js' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **/*.js';

  clean();
  var expectedAbsolutes = [ '/', '/alt', '/alt/d', '/alt2', '/alt2/d', '/altalt', '/altalt/d', '/altalt2', '/altalt2/d', '/altctrl', '/altctrl/d', '/altctrl2', '/altctrl2/d', '/altctrlalt', '/altctrlalt/d', '/altctrlalt2', '/altctrlalt2/d', '/ctrl', '/ctrl/d', '/ctrl2', '/ctrl2/d', '/ctrlctrl', '/ctrlctrl/d', '/ctrlctrl2', '/ctrlctrl2/d', '/doubledir', '/doubledir/d1', '/doubledir/d1/d11', '/doubledir/d2', '/doubledir/d2/d22', '/src1', '/src1/d', '/src1b', '/src2', '/src2/d', '/src3.js', '/src3.js/c.js', '/src3.js/d', '/src3.s', '/src3.s/c.js', '/src3.s/d' ];
  var records = globAll( '**/*.js' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals **.s/*';

  clean();
  var expectedAbsolutes = [ '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js' ];
  var records = globTerminals( '**.s/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll **.s/*';

  clean();
  var expectedAbsolutes = [ '/', '/src3.s', '/src3.s/a', '/src3.s/b.s', '/src3.s/c.js', '/src3.s/d' ];
  var records = globAll( '**.s/*' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1/**';

  clean();
  var expectedAbsolutes = [ '/src1/a', '/src1/b', '/src1/c', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globTerminals( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/a', '/src1/b', '/src1/c', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c' ];
  var records = globAll( '/src1/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* */

  test.case = 'globTerminals /src1Terminal/**';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals( '/src1Terminal/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal' ];
  var records = globAll( '/src1Terminal/**' );
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** with options map';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ glob : '/src1Terminal/**' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** with options map';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal' ];
  var records = globAll({ glob : '/src1Terminal/**' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** with basePath and filePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ glob : '/src1Terminal/**', basePath : '/src1Terminal', filePath : '/src1Terminal' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/** with basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globAll({ glob : '/src1Terminal/**', basePath : '/src1Terminal', filePath : '/src1Terminal' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals /src1Terminal/** with basePath';

  clean();
  var expectedAbsolutes = [ '/src1Terminal' ];
  var records = globTerminals({ glob : '/src1Terminal/**', basePath : '/src1Terminal' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll /src1Terminal/**';

  clean();
  var expectedAbsolutes = [ '/', '/src1Terminal' ];
  var records = globAll({ glob : '/src1Terminal/**', basePath : '/src1Terminal' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  /* - */

  test.open( 'several paths' );

  test.case = 'globTerminals [ /src1/d/**, /src2/d/** ]';

  clean();
  var expectedAbsolutes = [ '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globTerminals({ glob : [ '/src1/d/**', '/src2/d/**' ] });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globAll [ /src1/d/**, /src2/d/** ]';

  clean();
  var expectedAbsolutes = [ '/', '/src1', '/src1/d', '/src1/d/a', '/src1/d/b', '/src1/d/c', '/src2', '/src2/d', '/src2/d/a', '/src2/d/b', '/src2/d/c' ];
  var records = globAll({ glob : [ '/src1/d/**', '/src2/d/**' ] });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  test.identical( gotAbsolutes, expectedAbsolutes );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ], no options map';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals([ '/doubledir/d1/**', '/doubledir/d2/**' ]);
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ], no options map';

  clean();
  var expectedAbsolutes = [ '/', '/doubledir', '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '.', './doubledir', './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll([ '/doubledir/d1/**', '/doubledir/d2/**' ]);
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ]';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ] });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ]';

  clean();
  var expectedAbsolutes = [ '/', '/doubledir', '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '.', './doubledir', './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ] });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], basePath : '/' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';

  clean();
  var expectedAbsolutes = [ '/', '/doubledir', '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '.', './doubledir', './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], basePath : '/' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './d1/a', './d1/d11/b', './d1/d11/c', './d2/b', './d2/d22/c', './d2/d22/d' ];
  var records = globTerminals({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], basePath : '/doubledir' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';

  clean();
  var expectedAbsolutes = [ '/', '/doubledir', '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '..', '.', './d1', './d1/a', './d1/d11', './d1/d11/b', './d1/d11/c', './d2', './d2/b', './d2/d22', './d2/d22/c', './d2/d22/d' ];
  var records = globAll({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], basePath : '/doubledir' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with filePath:null';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './d1/a', './d1/d11/b', './d1/d11/c', './d2/b', './d2/d22/c', './d2/d22/d' ];
  var records = globTerminals({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filePath : null });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with filePath:null';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ './d1', './d1/a', './d1/d11', './d1/d11/b', './d1/d11/c', './d2', './d2/b', './d2/d22', './d2/d22/c', './d2/d22/d' ];
  var records = globAll({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filePath : null });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with filePath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1/a', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2/b', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '../a', './b', './c', '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filePath : null, basePath : '/doubledir/d1/d11' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with filePath:null, basePath:/doubledir/d1';

  clean();
  var expectedAbsolutes = [ '/doubledir/d1', '/doubledir/d1/a', '/doubledir/d1/d11', '/doubledir/d1/d11/b', '/doubledir/d1/d11/c', '/doubledir/d2', '/doubledir/d2/b', '/doubledir/d2/d22', '/doubledir/d2/d22/c', '/doubledir/d2/d22/d' ];
  var expectedRelatives = [ '..', '../a', '.', './b', './c', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ glob : [ '/doubledir/d1/**', '/doubledir/d2/**' ], filePath : null, basePath : '/doubledir/d1/d11' });
  var gotAbsolutes = _.entitySelect( records, '*.absolute' );
  var gotRelatives = _.entitySelect( records, '*.relative' );
  test.identical( gotAbsolutes, expectedAbsolutes );
  test.identical( gotRelatives, expectedRelatives );

  test.close( 'several paths' );

  /* - */

}

//

function filesGlob( test )
{

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

  var testDir = _.path.join( test.context.testRootDirectory, test.name );

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
    options.glob = _.path.join( testDir, glob );
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

  var  glob = '[ab]/**/[!xc]/*';
  var options = completeOptions( glob );
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a/a.js',
    './a/a.s',
    './a/a.ss',
    './a/a.txt',
  ]
  test.identical( got, expected );

  /**/

  var glob = '**/*.s';
  var options =
  {
    glob : _.path.join( testDir, 'a/c', glob ),
    outputFormat : 'relative',
    basePath : testDir
  }
  var got = _.fileProvider.filesGlob( options );
  var expected =
  [
    './a/c/c.s',
  ]
  test.identical( got, expected );

  /**/

  /* {} are not supported !!! */

  // var  glob = 'a/{x.*,a.*}';
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
  // var  glob = '**/c/{x.*,c.*}';
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
  // var  glob = 'b/*/{x,c}/a/*';
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

function filesMigrate( t )
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

  t.description = 'trivial move';
  var wasTree1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1' },
      dst : { b : '2', },
    },
  });

  var records = wasTree1.filesMigrate( '/dst','/src' );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1' },
      dst : { a1 : '1', b : '1' },
    },
  });

  t.identical( wasTree1.filesTree, expected.filesTree );

  var expected =
  [
    {
      dst : { relative : '.', absolute : '/dst', real : '/dst' },
      src : { relative : '.', absolute : '/src', real : '/src' },
      effective : { relative : '.', absolute : '/src', real : '/src' },
    },
    {
      dst : { relative : './a1', absolute : '/dst/a1', real : '/dst/a1' },
      src : { relative : './a1', absolute : '/src/a1', real : '/src/a1' },
      effective : { relative : './a1', absolute : '/src/a1', real : '/src/a1' },
    },
    {
      dst : { relative : './b', absolute : '/dst/b', real : '/dst/b' },
      src : { relative : './b', absolute : '/src/b', real : '/src/b' },
      effective : { relative : './b', absolute : '/src/b', real : '/src/b' },
    },
  ];

  t.contains( records, expected );
  t.identical( records.length, expected.length );

  /* */

  var o =
  {
    prepare : prepareSingle,
  }

  context._filesMigrate( t,o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  context._filesMigrate( t,o );

}

filesMigrate.timeOut = 30000;

//

function _filesMigrate( t,o )
{
  var context = this;

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/a1' ),p.dst.urlFromLocal( '/dst/a1' ) ), false );
  t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/a2' ),p.dst.urlFromLocal( '/dst/a2' ) ), false );
  t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/b' ),p.dst.urlFromLocal( '/dst/b' ) ), false );
  t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/dir/a1' ),p.dst.urlFromLocal( '/dst/dir/a1' ) ), false );
  t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/dir/a2' ),p.dst.urlFromLocal( '/dst/dir/a2' ) ), false );
  t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/dir/b' ),p.dst.urlFromLocal( '/dst/dir/b' ) ), false );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
  var o2 =
  {
    linking : 'hardlink',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.description = 'complex move with linking : hardlink\n' + _.toStr( o2 );

  if( p.src === p.dst )
  {

    var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

    var expected = _.FileProvider.Extract
    ({
      filesTree :
      {
        src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
        dst : { a2 : '2', a1 : [{ hardLink : '/src/a1' }], b : [{ hardLink : '/src/b' }], c : [{ hardLink : '/src/c' }], dir : { a2 : '2', a1 : [{ hardLink : '/src/dir/a1' }], b : [{ hardLink : '/src/dir/b' }], c : [{ hardLink : '/src/dir/c' }] }, dirSame : { d : [{ hardLink : '/src/dirSame/d' }] }, dir1 : { a1 : [{ hardLink : '/src/dir1/a1' }], b : [{ hardLink : '/src/dir1/b' }], c : [{ hardLink : '/src/dir1/c' }] }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : [{ hardLink : '/src/srcFile' }], dstFile : { f : [{ hardLink : '/src/dstFile/f' }] } },
      },
    });

    t.identical( p.src.filesTree.src, expected.filesTree.src );
    t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

    var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
    var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
    var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

    var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
    var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
    var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

    t.identical( gotDstAbsolute, expectedDstAbsolute );
    t.identical( gotSrcAbsolute, expectedSrcAbsolute );
    t.identical( gotEffAbsolute, expectedEffAbsolute );

    t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/a1' ),p.dst.urlFromLocal( '/dst/a1' ) ), p.src === p.dst );
    t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/a2' ),p.dst.urlFromLocal( '/dst/a2' ) ), false );
    t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/b' ),p.dst.urlFromLocal( '/dst/b' ) ), p.src === p.dst );
    t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/dir/a1' ),p.dst.urlFromLocal( '/dst/dir/a1' ) ), p.src === p.dst );
    t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/dir/a2' ),p.dst.urlFromLocal( '/dst/dir/a2' ) ), false );
    t.identical( p.hub.filesAreHardLinked( p.src.urlFromLocal( '/src/dir/b' ),p.dst.urlFromLocal( '/dst/dir/b' ) ), p.src === p.dst );

  }
  else
  {

    t.shouldThrowErrorSync( function()
    {
      var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );
    });

  }

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.description = 'complex move with dstRewriting : 0\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move with writing : 0\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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
  var expectedActions = [ 'directoryPreserve', 'notAllowed', 'notAllowed', 'notAllowed', 'notAllowed', 'directoryPreserve', 'notAllowed', 'notAllowed', 'notAllowed', 'notAllowed', 'notAllowed', 'notAllowed', 'notAllowed', 'directoryPreserve', 'notAllowed', 'directoryPreserve', 'notAllowed', 'notAllowed', 'notAllowed' ]

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );
  var actions = _.entitySelect( records,'*.action' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );
  t.identical( actions, expectedActions );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move with writing : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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
  var expectedActions = [ 'directoryPreserve', 'nop', 'nop', 'nop', 'nop', 'directoryPreserve', 'nop', 'nop', 'nop', 'directoryMake', 'nop', 'nop', 'nop', 'directoryPreserve', 'directoryMake', 'directoryPreserve', 'nop', 'directoryMake', 'nop' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );
  var actions = _.entitySelect( records,'*.action' );

  logger.log( 'expectedEffAbsolute',expectedEffAbsolute );
  logger.log( 'actions',actions );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );
  t.identical( actions, expectedActions );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.description = 'complex move with writing : 1, dstRewriting : 0, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

// src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
// dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];
  var expectedActions = [ 'directoryPreserve', 'nop', 'directoryPreserve', 'nop', 'directoryMake', 'nop', 'nop', 'nop', 'directoryPreserve', 'directoryMake', 'directoryPreserve' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );
  var actions = _.entitySelect( records,'*.action' );

  logger.log( 'expectedEffAbsolute',expectedEffAbsolute );
  logger.log( 'actions',actions );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );
  t.identical( actions, expectedActions );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move with preservingSame : 1, linking : fileCopy\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

// src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
// dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedActions = [ 'directoryPreserve', 'fileCopy', 'terminalPreserved', 'fileCopy', 'fileCopy', 'directoryPreserve', 'fileCopy', 'terminalPreserved', 'fileCopy', 'directoryMake', 'fileCopy', 'fileCopy', 'fileCopy', 'directoryPreserve', 'directoryMake', 'directoryPreserve', 'terminalPreserved', 'directoryMake', 'fileCopy' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );
  var actions = _.entitySelect( records,'*.action' );

  logger.log( 'expectedEffAbsolute',expectedEffAbsolute );
  logger.log( 'actions',actions );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );
  t.identical( actions, expectedActions );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move with srcDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move with srcDeleting : 1, dstRewriting : 0\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ]
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ]
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ]

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
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

  t.description = 'complex move with dstDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

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

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/dst/srcFile', '/dst/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/dst/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

  var p = o.prepare();

  var o1 = { dstPath : '/dst', srcPath : '/src', srcProvider : p.src, dstProvider : p.dst };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  t.description = 'complex move with dstDeleting : 1, dstRewriting : 0, srcDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { b : '1', c : '2', dir : { b : '1', c : '2' }, dirSame : { d : '1' }, dstFile : '1', srcFile : { f : '2' } },
    },
  });

// src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
// dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir/a1', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/a1', '/dst/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir4', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir/a1', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/a1', '/src/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir3', '/src/dir4', '/src/dir5' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/dst/dir/a1', '/dst/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/dst/a1', '/dst/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir4', '/dst/dir5' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

  var p = o.prepare();

  var o1 =
  {
    dstPath : [ '/dst','/dst2','/dst3' ],
    srcPath : [ '/src','/src2','/src3' ],
    srcProvider : p.src,
    dstProvider : p.dst,
  };
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

  t.description = 'move several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesMigrate( _.mapExtend( null,o1,o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src :
      {
        a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' },
      },

      dst :
      {
        a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' },
        bx : '10',
        cx : '10',
        dirx : { a : '20' },
        ax2 : '20',
        by : '20',
        cy : '20',
      },

    },
  });

  t.identical( p.src.filesTree.src, expected.filesTree.src );
  t.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f', '/dst2', '/dst2/a1', '/dst2/b', '/dst2/c', '/dst2/srcFile', '/dst2/dir', '/dst2/dir/a1', '/dst2/dir/b', '/dst2/dir/c', '/dst2/dir1', '/dst2/dir1/a1', '/dst2/dir1/b', '/dst2/dir1/c', '/dst2/dir3', '/dst2/dir4', '/dst2/dirSame', '/dst2/dirSame/d', '/dst2/dstFile', '/dst2/dstFile/f', '/dst3', '/dst3/a1', '/dst3/b', '/dst3/c', '/dst3/srcFile', '/dst3/dir', '/dst3/dir/a1', '/dst3/dir/b', '/dst3/dir/c', '/dst3/dir1', '/dst3/dir1/a1', '/dst3/dir1/b', '/dst3/dir1/c', '/dst3/dir3', '/dst3/dir4', '/dst3/dirSame', '/dst3/dirSame/d', '/dst3/dstFile', '/dst3/dstFile/f', '/dst', '/dst/ax2', '/dst/bx', '/dst/cx', '/dst/dirx', '/dst/dirx/a', '/dst2', '/dst2/ax2', '/dst2/bx', '/dst2/cx', '/dst2/dirx', '/dst2/dirx/a', '/dst3', '/dst3/ax2', '/dst3/bx', '/dst3/cx', '/dst3/dirx', '/dst3/dirx/a', '/dst', '/dst/ax2', '/dst/by', '/dst/cy', '/dst/dirx', '/dst/dirx/a', '/dst2', '/dst2/ax2', '/dst2/by', '/dst2/cy', '/dst2/dirx', '/dst2/dirx/a', '/dst3', '/dst3/ax2', '/dst3/by', '/dst3/cy', '/dst3/dirx', '/dst3/dirx/a' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src2', '/src2/ax2', '/src2/bx', '/src2/cx', '/src2/dirx', '/src2/dirx/a', '/src2', '/src2/ax2', '/src2/bx', '/src2/cx', '/src2/dirx', '/src2/dirx/a', '/src2', '/src2/ax2', '/src2/bx', '/src2/cx', '/src2/dirx', '/src2/dirx/a', '/src3', '/src3/ax2', '/src3/by', '/src3/cy', '/src3/dirx', '/src3/dirx/a', '/src3', '/src3/ax2', '/src3/by', '/src3/cy', '/src3/dirx', '/src3/dirx/a', '/src3', '/src3/ax2', '/src3/by', '/src3/cy', '/src3/dirx', '/src3/dirx/a' ];
  var expectedEffAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src2', '/src2/ax2', '/src2/bx', '/src2/cx', '/src2/dirx', '/src2/dirx/a', '/src2', '/src2/ax2', '/src2/bx', '/src2/cx', '/src2/dirx', '/src2/dirx/a', '/src2', '/src2/ax2', '/src2/bx', '/src2/cx', '/src2/dirx', '/src2/dirx/a', '/src3', '/src3/ax2', '/src3/by', '/src3/cy', '/src3/dirx', '/src3/dirx/a', '/src3', '/src3/ax2', '/src3/by', '/src3/cy', '/src3/dirx', '/src3/dirx/a', '/src3', '/src3/ax2', '/src3/by', '/src3/cy', '/src3/dirx', '/src3/dirx/a' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

}

//

function filesGrab( t )
{
  var context = this;

  t.description = 'nothing to grab';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  // var src = _.FileProvider.Extract
  // ({
  //   filesTree :
  //   {
  //     src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
  //     src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
  //     src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
  //   },
  // });
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

  var records = hub.filesGrab
  ({
    recipe : recipe,
    srcProvider : src,
    dstProvider : dst,
    srcPath : '/',
    dstPath : '/',
  });

  var expectedDstAbsolute = [ '/' ];
  var expectedSrcAbsolute = [ '/' ];
  var expectedEffAbsolute = [ '/' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

  /* */

  t.description = 'trivial';

  var dst = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });
  var src = context.makeStandardExtract();
  // var src = _.FileProvider.Extract
  // ({
  //   filesTree :
  //   {
  //     src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
  //     src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
  //     src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
  //   },
  // });

  var hub = new _.FileProvider.Hub({ empty : 1 });
  src.originPath = 'extract+src://';
  dst.originPath = 'extract+dst://';
  hub.providerRegister( src );
  hub.providerRegister( dst );

  var recipe =
  {
    '/src/dir**' : true,
    '/src/dir1/**' : false,
    '/dstFile/**' : true,
  }

  // var recipe =
  // {
  //   '/src/dir**' : true,
  //   '/src/dir1/**' : false,
  //   '/dstFile/**' : true,
  // }

  debugger;
  var records = hub.filesGrab
  ({
    recipe : recipe,
    srcProvider : src,
    dstProvider : dst,
    srcPath : '/',
    dstPath : '/',
  });
  debugger;

  var expectedDstAbsolute = [ '/' ];
  var expectedSrcAbsolute = [ '/' ];
  var expectedEffAbsolute = [ '/' ];

  // var expectedDstAbsolute = [ '/', '/src', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  // var expectedSrcAbsolute =  [ '/', '/src', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];
  // var expectedEffAbsolute = [ '/', '/src', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var gotDstAbsolute = _.entitySelect( records,'*.dst.absolute' );
  var gotSrcAbsolute = _.entitySelect( records,'*.src.absolute' );
  var gotEffAbsolute = _.entitySelect( records,'*.effective.absolute' );

  t.identical( gotDstAbsolute, expectedDstAbsolute );
  t.identical( gotSrcAbsolute, expectedSrcAbsolute );
  t.identical( gotEffAbsolute, expectedEffAbsolute );

}

//

function filesLookExperiment( test )
{
  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  var srcProvider = _.FileProvider.Extract({ filesTree : filesTree, protocols : [ 'extract' ] });
  var dstProvider = new _.FileProvider.HardDrive();
  var srcPath = '/src';
  var dstPath = _.path.join( test.context.testRootDirectory, test.name, 'dst' );
  var hub = new _.FileProvider.Hub({ empty : 1 });
  hub.providerRegister( srcProvider );
  hub.providerRegister( dstProvider );

  //

  test.case = 'filesMigrate: copy files from Extract to HardDrive, using absolute paths'
  dstProvider.filesDelete( dstPath );
  var o1 = { dstPath : dstPath, srcPath : srcPath, srcProvider : srcProvider, dstProvider : dstProvider };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  var records = hub.filesMigrate( _.mapExtend( null,o1,o2 ) );
  test.is( records.length >= 0 );

  var got = _.FileProvider.Extract.filesTreeRead({ srcPath : dstPath, srcProvider : dstProvider });
  test.identical( got, _.entitySelect( filesTree, srcPath ) )

  //

  test.case = 'filesMigrate: copy files from Extract to HardDrive, using absolute urls'
  dstProvider.filesDelete( dstPath );
  var srcUrl = srcProvider.urlFromLocal( srcPath );
  var dstUrl = dstProvider.urlFromLocal( dstPath );
  var o1 = { dstPath : dstUrl, srcPath : srcUrl /*, srcProvider : srcProvider, dstProvider : dstProvider*/ };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  var records = hub.filesMigrate( _.mapExtend( null,o1,o2 ) );
  test.is( records.length >= 0 );

  var got = _.FileProvider.Extract.filesTreeRead({ srcPath : dstPath, srcProvider : dstProvider });
  test.identical( got, _.entitySelect( filesTree, srcPath ) )

}

//

function filesDelete( test )
{
  var symlinkIsAllowed = test.context.symlinkIsAllowed();
  var testDir = _.path.join( test.context.testRootDirectory, test.name );
  var filePath = _.path.join( testDir, 'file' );
  var dirPath = _.path.join( testDir, 'dir' );

  test.case = 'delete terminal file';
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.filesDelete( filePath );
  var stat = _.fileProvider.fileStat( filePath );
  test.identical( stat, null );

  test.case = 'delete empty dir';
  _.fileProvider.directoryMake( dirPath );
  _.fileProvider.filesDelete( dirPath );
  var stat = _.fileProvider.fileStat( dirPath );
  test.identical( stat, null );

  test.case = 'delete hard link';
  _.fileProvider.filesDelete( testDir );
  var dst = _.path.join( testDir, 'link' );
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.linkHard( dst, filePath );
  _.fileProvider.filesDelete( dst );
  var stat = _.fileProvider.fileStat( dst );
  test.identical( stat, null );
  var stat = _.fileProvider.fileStat( filePath );
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
  var stat = _.fileProvider.fileStat( testDir );
  test.identical( stat, null );

  //

  if( !symlinkIsAllowed )
  return;

  test.case = 'delete soft link, resolvingSoftLink 1';
  _.fileProvider.fieldSet( 'resolvingSoftLink', 1 );
  var dst = _.path.join( testDir, 'link' );
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.linkSoft( dst, filePath );
  _.fileProvider.filesDelete( dst )
  var stat = _.fileProvider.fileStat( dst );
  test.identical( stat, null );
  var stat = _.fileProvider.fileStat( filePath );
  test.is( !!stat );
  _.fileProvider.fieldReset( 'resolvingSoftLink', 1 );

  test.case = 'delete soft link, resolvingSoftLink 0';
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.fieldSet( 'resolvingSoftLink', 0 );
  var dst = _.path.join( testDir, 'link' );
  _.fileProvider.fileWrite( filePath, ' ');
  _.fileProvider.linkSoft( dst, filePath );
  _.fileProvider.filesDelete( dst )
  var stat = _.fileProvider.fileStat( dst );
  test.identical( stat, null );
  var stat = _.fileProvider.fileStat( filePath );
  test.is( !!stat );
  _.fileProvider.fieldReset( 'resolvingSoftLink', 0 );
}

//

function filesDeleteAndAsyncWrite( test )
{

  test.case = 'try to delete dir before async write will be completed';

  var testDir = _.path.join( test.context.testRootDirectory, test.name );


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

  var mainCon = new _.Consequence().give();
  mainCon.andThen( cons );
  mainCon.doThen( () =>
  {
    test.mustNotThrowError( () =>
    {
      _.fileProvider.filesDelete( testDir );
    });

    var files = _.fileProvider.directoryRead( testDir );
    test.identical( files, null );
  })
  return mainCon;
}

//

function filesFindDifference( test )
{
  var self = this;

  /* !!! Needs repair. Files tree is written with "sameTime" option enabled, but files are not having same timestamps anyway,
     probably problem is in method used by HardDrive.fileTimeSetAct
  */

  var testRoutineDir = _.path.join( test.context.testRootDirectory, test.name );

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
        { src : { relative : '.' }, /*same : undefined, del : undefined,*/ newer :null, older : null },
        { src : { relative : './a.a' }, /*same : undefined, del : undefined,*/ newer :  { side : 'src' }, older : null },
        { src : { relative : './b1.b' }, same : true, /* del : undefined, */ newer : null, older : null   },
        { src : { relative : './b2.b' }, same : false,/*  del : undefined, */ newer : null, older : null   },
        { src : { relative : './c' }, /*same : undefined, del : undefined,*/ newer : null, older : null   },
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

        { relative : '.', /*same : undefined, del : undefined*/ },

        { src : { relative : './a.a' }, del : true, /* same : undefined */ },
        { src : { relative : './b1.b' }, /* del : undefined, */ same : true },
        { src : { relative : './b2.b' }, /* del : undefined, */ same : true },

        { src : { relative : './c' }/* , del : undefined, same : undefined */ },
        { src : { relative : './c/d1.d' }, del : true, /* same : undefined */ },
        { src : { relative : './c/b3.b' }, /* del : undefined, */ same : true },

        { src : { relative : './c/e' }/* , del : undefined, same : undefined */ },
        { src : { relative : './c/e/d2.d' }, del : true, /* same : undefined */ },
        { src : { relative : './c/e/e1.e' }, del : true, /* same : undefined */ },

      ],
    },

    //

    {
      name : 'complex-1',

      expected :
      [

        { relative : '.', /*same : undefined, del : undefined,*/ older : null, newer : null  },

        { relative : './a.a', same : true,/*  del : undefined, */ older : null, newer : null  },
        { relative : './b1.b', same : true, /* del : undefined, */ older : null, newer : null  },
        { relative : './b2.b', same : false, /* del : undefined, */ older : null, newer : null  },

        { relative : './c', /*same : undefined, del : undefined,*/ older : null, newer : null  },

        { relative : './c/dstfile.d', /* same : undefined,  */del : true, older : null, newer : { side : 'dst' } },
        { relative : './c/dstdir', /* same : undefined, */ del : true, older : null, newer : { side : 'dst' }  },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', /* same : undefined, */ del : true, older : null, newer : { side : 'dst' } },

        { relative : './c/b3.b', same : false,/*  del : undefined, */ older : null, newer : null  },

        { relative : './c/srcfile', /*same : undefined, del : undefined,*/ older : null, newer : { side : 'src' } },
        { relative : './c/srcfile-dstdir', same : false, /* del : undefined, */ older : null , newer : null },

        { relative : './c/e', /*same : undefined, del : undefined,*/ older : null , newer : null },
        { relative : './c/e/d2.d', same : false, /* del : undefined, */ older : null, newer : null  },
        { relative : './c/e/e1.e', same : true, /* del : undefined, */ older : null, newer : null  },

        { relative : './c/srcdir', /*same : undefined, del : undefined,*/ older : null, newer : { side : 'src' } },
        { relative : './c/srcdir-dstfile', same : false, /* del : undefined, */ older : null , newer : null },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', /*same : undefined, del : undefined,*/ older : null, newer : { side : 'src' } },

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
        { relative : './c/c1',/*  same : undefined, */ del : true },
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

    //!!!repair
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

    // var files = _.fileProvider.filesFind({ filePath : dir, includingBase : 1, recursive : 1, includingDirectories : 1 } );

    // logger.log( _.entitySelect( files, '*.relative' ) )
    // logger.log( _.entitySelect( files, '*.stat.mtime' ).map( ( t ) => t.getTime() ) )

    var o =
    {
      src : _.path.join( dir, 'initial/src' ),
      dst : _.path.join( dir, 'initial/dst' ),
      includingTerminals : 1,
      includingDirectories : 1,
      recursive : 1,
      onDown : function( record ){ test.identical( _.objectIs( record ),true ); },
      onUp : function( record ){ test.identical( _.objectIs( record ),true ); },
      filter : _.FileRecordFilter({ fileProvider : _.fileProvider, ends : sample.ends }).form()
    }

    _.mapExtend( o,sample.options || {} );

    var files = _.FileProvider.HardDrive();

    var got = files.filesFindDifference( o );

    var passed = true;
    passed = passed && test.contains( got,sample.expected );
    passed = passed && test.identical( got.length,sample.expected.length );

    if( !passed )
    {

      // logger.log( 'got :\n' + _.toStr( got,{ levels : 3 } ) );
      // logger.log( 'expected :\n' + _.toStr( sample.expected,{ levels : 3 } ) );

      // logger.log( 'got :\n' + _.toStr( got,{ levels : 2 } ) );

      logger.log( 'relative :\n' + _.toStr( _.entitySelect( got,'*.src.relative' ),{ levels : 2 } ) );
      logger.log( 'same :\n' + _.toStr( _.entitySelect( got,'*.same' ),{ levels : 2 } ) );
      logger.log( 'del :\n' + _.toStr( _.entitySelect( got,'*.del' ),{ levels : 2 } ) );

      logger.log( 'newer :\n' + _.toStr( _.entitySelect( got,'*.newer.side' ),{ levels : 1 } ) );
      logger.log( 'older :\n' + _.toStr( _.entitySelect( got,'*.older' ),{ levels : 1 } ) );

    }

    test.case = '';

  }

}

//

function filesCopy( test )
{
  var self = this;

  var testRoutineDir = _.path.join( test.context.testRootDirectory, test.name );

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
      options : { removingSource : 1, allowWrite : 1 },
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
      name : 'remove-source-files-1',
      options : { includingDirectories : 0, removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowDelete : 0, ends : '.b' },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '', 'b3.b' : 'b3' }, 'e' : { 'b4.b' : 'b4' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'e' : 'e', 'f1.f' : 'f1', 'g' : {}, 'h' : { 'h1.h' : 'h1' } },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'c' : { 'c1.c' : '' }, 'e' : {} },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' , 'c' : { 'b3.b' : 'b3' }, 'e' : { 'b4.b' : 'b4' }, 'f1.f' : 'f1', 'g' : {}, 'h' : { 'h1.h' : 'h1' } },
        },
      },
      expected :
      [
        { relative : './a.a', action : 'deleted', allowed : false },
        { relative : './f1.f', action : 'deleted', allowed : false },
        { relative : './h/h1.h', action : 'deleted', allowed : false },

        { relative : './b1.b', action : 'same', allowed : true },
        { relative : './b2.b', action : 'copied', allowed : true },
        { relative : './c/b3.b', action : 'copied', allowed : true },
        { relative : './e/b4.b', action : 'copied', allowed : true },
      ],
    },

    //

    {

      name : 'remove-sorce-files-2',
      options : { includingDirectories : 0, removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowDelete : 0, ends : '.b' },

      expected :
      [

        { relative : './a.a', action : 'deleted', allowed : false },
        { relative : './b1.b', action : 'same', allowed : true },
        { relative : './b2.b', action : 'copied', allowed : true },

        { relative : './c/dstfile.d', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

        { relative : './c/b3.b', action : 'copied', allowed : true },
        { relative : './c/e/d2.d', action : 'deleted', allowed : false },
        { relative : './c/e/e1.e', action : 'deleted', allowed : false },

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
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'dstfile.d' : 'd1',
              'dstdir' : {},
              'srcdir-dstfile' : {},
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
              'srcdir' : {},
            },
          },
        },

      },

    },

    //

    {

      name : 'allow-rewrite-file-by-dir',
      options : { removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowRewriteFileByDir : 0, allowDelete : 0, ends : '.b' },

      expected :
      [

        { relative : '.', action : 'directory preserved', allowed : true },

        { relative : './a.a', action : 'deleted', allowed : false },
        { relative : './b1.b', action : 'same', allowed : true },
        { relative : './b2.b', action : 'copied', allowed : true },

        { relative : './c', action : 'directory preserved', allowed : true },
        { relative : './c/dstfile.d', action : 'deleted', allowed : false },
        { relative : './c/dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

        { relative : './c/b3.b', action : 'copied', allowed : true },
        { relative : './c/e', action : 'directory preserved', allowed : true },
        { relative : './c/e/d2.d', action : 'deleted', allowed : false },
        { relative : './c/e/e1.e', action : 'deleted', allowed : false },

        { relative : './c/srcdir', action : 'directory new', allowed : true },
        { relative : './c/srcdir-dstfile', action : 'cant rewrite', allowed : false },

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
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'dstfile.d' : 'd1',
              'dstdir' : {},
              'srcdir-dstfile' : 'x',
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
              'srcdir' : {},
            },
          },
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

        { relative : '.', action : 'directory preserved' },

        { relative : './a.a', action : 'same' },
        { relative : './b1.b', action : 'same' },
        { relative : './b2.b', action : 'copied' },

        { relative : './c', action : 'directory preserved' },

        { relative : './c/d1.d', action : 'deleted' },
        { relative : './c/f', action : 'deleted' },

        { relative : './c/b3.b', action : 'copied' },
        { relative : './c/e', action : 'directory preserved' },
        { relative : './c/e/d2.d', action : 'same' },
        { relative : './c/e/e1.e', action : 'same' },
        { relative : './c/g', action : 'directory new' },

      ],
    },

    //

    {
      name : 'remove-source-files-1',
      options : { removingSourceTerminals : 1 },
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
            'c' :
            {
              'e' : {},
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

        { relative : '.', action : 'directory preserved' },

        { relative : './a.a', action : 'same' },
        { relative : './b1.b', action : 'same' },
        { relative : './b2.b', action : 'copied' },

        { relative : './c', action : 'directory preserved' },

        { relative : './c/d1.d', action : 'deleted' },
        { relative : './c/f', action : 'deleted' },

        { relative : './c/b3.b', action : 'copied' },
        { relative : './c/e', action : 'directory preserved' },
        { relative : './c/e/d2.d', action : 'same' },
        { relative : './c/e/e1.e', action : 'same' },
        { relative : './c/g', action : 'directory new' },

      ],
    },

    //

    {
      name : 'remove-source-1',
      options : { removingSource : 1 },
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

        { relative : '.', action : 'directory preserved' },

        { relative : './a.a', action : 'same' },
        { relative : './b1.b', action : 'same' },
        { relative : './b2.b', action : 'copied' },

        { relative : './c', action : 'directory preserved' },

        { relative : './c/d1.d', action : 'deleted' },
        { relative : './c/f', action : 'deleted' },

        { relative : './c/b3.b', action : 'copied' },
        { relative : './c/e', action : 'directory preserved' },
        { relative : './c/e/d2.d', action : 'same' },
        { relative : './c/e/e1.e', action : 'same' },
        { relative : './c/g', action : 'directory new' },

      ],
    },

    //

    {

      name : 'complex-allow-delete-0',
      options : { allowRewrite : 1, allowDelete : 0 },

      expected :
      [

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', },
        { relative : './b2.b', action : 'copied', },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : false },
        { relative : './c/dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

        { relative : './c/b3.b', action : 'copied', },

        { relative : './c/srcfile', action : 'copied' },
        { relative : './c/srcfile-dstdir', action : 'copied', },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'copied', },
        { relative : './c/e/e1.e', action : 'same', },

        { relative : './c/srcdir', action : 'directory new' },
        { relative : './c/srcdir-dstfile', action : 'directory new', },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'copied' },

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

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', },
        { relative : './b2.b', action : 'copied', },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : true },
        { relative : './c/dstdir', action : 'deleted', allowed : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : true },

        { relative : './c/b3.b', action : 'copied', },
        { relative : './c/srcfile', action : 'copied' },
        { relative : './c/srcfile-dstdir', action : 'copied', },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'copied', },
        { relative : './c/e/e1.e', action : 'same', },

        { relative : './c/srcdir', action : 'directory new' },
        { relative : './c/srcdir-dstfile', action : 'directory new', },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'copied' },

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
    //     { relative : './b1.b', action : 'same', allowed : true },
    //     { relative : './b2.b', action : 'cant rewrite', allowed : false },

    //     { relative : './c', action : 'directory preserved', },

    //     { relative : './c/dstfile.d', action : 'deleted', allowed : false },
    //     { relative : './c/dstdir', action : 'deleted', allowed : false },
    //     { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

    //     { relative : './c/b3.b', action : 'cant rewrite', allowed : false },

    //     { relative : './c/srcfile', action : 'copied', allowed : false },
    //     { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

    //     { relative : './c/e', action : 'directory preserved', },
    //     { relative : './c/e/d2.d', action : 'cant rewrite', allowed : false },
    //     { relative : './c/e/e1.e', action : 'same', },

    //     { relative : './c/srcdir', action : 'directory new', allowed : false },
    //     { relative : './c/srcdir-dstfile', action : 'cant rewrite', allowed : false },
    //     { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allowed : false },

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
  //       { relative : './b1.b', action : 'same', allowed : true },
  //       { relative : './b2.b', action : 'cant rewrite', allowed : false },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allowed : true },
  //       { relative : './c/dstdir', action : 'deleted', allowed : true },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : true },

  //       { relative : './c/b3.b', action : 'cant rewrite', allowed : false },

  //       { relative : './c/srcfile', action : 'copied', allowed : false },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', allowed : false },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new', allowed : false },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', allowed : false },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allowed : false },

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

  //       { relative : './c/dstfile.d', action : 'deleted', allowed : true },
  //       { relative : './c/dstdir', action : 'deleted', allowed : true },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : true },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied' },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

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

  //       { relative : './c/dstfile.d', action : 'deleted', allowed : false },
  //       { relative : './c/dstdir', action : 'deleted', allowed : false },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied' },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

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

  //     name : 'complex-not-allowed',
  //     options : { allowRewrite : 0, allowDelete : 0, allowWrite : 0 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allowed : false },
  //       { relative : './c/dstdir', action : 'deleted', allowed : false },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied', allowed : false },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', allowed : false },
  //       { relative : './c/e/e1.e', action : 'same', allowed : true },

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
  //       { relative : '.', action : 'directory new', allowed : true },
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
  //       { relative : '.', action : 'directory preserved', allowed : true },
  //       { relative : './a.a', action : 'deleted', allowed : true },
  //       { relative : './b1.b', action : 'deleted', allowed : true },
  //       { relative : './b2.b', action : 'deleted', allowed : true },
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
  //       { relative : '.', action : 'directory preserved', allowed : true },
  //       { relative : './a', action : 'deleted', allowed : true },
  //       { relative : './b', action : 'deleted', allowed : true },
  //       { relative : './b/b1', action : 'deleted', allowed : true },
  //       { relative : './b/b2', action : 'deleted', allowed : true },
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

  //       { relative : './b', action : 'deleted', allowed : true },
  //       { relative : './b/b1', action : 'deleted', allowed : true },
  //       { relative : './b/b2', action : 'deleted', allowed : true },
  //       { relative : './b/b2/b22', action : 'deleted', allowed : true },
  //       { relative : './b/b2/x', action : 'deleted', allowed : true },

  //       { relative : './c', action : 'deleted', allowed : true },
  //       { relative : './c/c1', action : 'deleted', allowed : true },
  //       { relative : './c/c2', action : 'deleted', allowed : true },
  //       { relative : './c/c2/c22', action : 'deleted', allowed : true },

  //       { relative : './a', action : 'copied', allowed : true },

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

  //       { relative : './b', action : 'deleted', allowed : true },
  //       { relative : './b/b1', action : 'deleted', allowed : true },
  //       { relative : './b/b2', action : 'deleted', allowed : true },
  //       { relative : './b/b2/b22', action : 'deleted', allowed : true },
  //       { relative : './b/b2/x', action : 'deleted', allowed : true },

  //       { relative : './c', action : 'deleted', allowed : true },
  //       { relative : './c/c1', action : 'deleted', allowed : true },
  //       { relative : './c/c2', action : 'deleted', allowed : true },
  //       { relative : './c/c2/c22', action : 'deleted', allowed : true },

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

  //       { relative : './a', action : 'copied', allowed : true },

  //       { relative : './b', action : 'directory new', allowed : true },
  //       //{ relative : './b/.b1', action : 'copied', allowed : true },
  //       { relative : './b/b2', action : 'directory new', allowed : true },
  //       { relative : './b/b2/b22', action : 'copied', allowed : true },

  //       { relative : './c', action : 'directory new', allowed : true },
  //       { relative : './c/b2', action : 'directory new', allowed : true },
  //       { relative : './c/b2/b22', action : 'copied', allowed : true },

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
    logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );
*/

    var copyOptions =
    {
      src : _.path.join( dir, 'initial/src' ),
      dst : _.path.join( dir, 'initial/dst' ),
      ends : sample.ends,
      investigateDestination : 1,
      includingTerminals : 1,
      includingDirectories : 1,
      recursive : 1,
      allowWrite : 1,
      allowRewrite : 1,
      allowDelete : 0,
    }

    _.mapExtend( copyOptions,sample.options || {} );

    var got = _.fileProvider.filesCopy( copyOptions );

    var treeGot = _.FileProvider.Extract.filesTreeRead({ srcPath : dir, srcProvider : _.fileProvider });
    // var treeGot = _.fileProvider.filesTreeRead( dir );

    var passed = true;
    passed = passed && test.contains( got,sample.expected );
    passed = passed && test.identical( got.length,sample.expected.length );
    passed = passed && test.identical( treeGot.initial,sample.filesTree.got );

    if( !passed )
    {

      //logger.log( 'return :\n' + _.toStr( got,{ levels : 2 } ) );
      //logger.log( 'got :\n' + _.toStr( treeGot.initial,{ levels : 3 } ) );
      //logger.log( 'expected :\n' + _.toStr( sample.filesTree.got,{ levels : 3 } ) );

      logger.log( 'relative :\n' + _.toStr( _.entitySelect( got,'*.relative' ),{ levels : 2 } ) );
      logger.log( 'action :\n' + _.toStr( _.entitySelect( got,'*.action' ),{ levels : 2 } ) );
      logger.log( 'length :\n' + got.length + ' / ' + sample.expected.length );

      //logger.log( 'same :\n' + _.toStr( _.entitySelect( got,'*.same' ),{ levels : 2 } ) );
      //logger.log( 'del :\n' + _.toStr( _.entitySelect( got,'*.del' ),{ levels : 2 } ) );

    }

    test.case = '';

  }

}

//

function experiment( test )
{

  // var got1 = _.fileProvider.filesFind({ filePath : __dirname, basePath : 'C:\\x', recursive : 1 });
  // var got1 = _.fileProvider.filesFind({ filePath : __dirname, recursive : 1 });

  // var got1 = _.fileProvider.filesFind
  // ({
  //   filePath : __dirname + '/../../../../tmp.tmp',
  //   basePath : '/pro/web/Port/package',
  //   basePath : '/abc',
  //   recursive : 1,
  //   usingTiming : 1,
  // });

  var testDir = _.path.join( test.context.testRootDirectory, test.name );
  var src = _.path.join( testDir, 'src' );
  var dst = _.path.join( testDir, 'dst' );
  _.fileProvider.fileWrite( src, 'data' );
  _.fileProvider.linkSoft( dst, src );
  _.fileProvider.resolvingSoftLink = 1;

  var files = _.fileProvider.filesFind( dst );
  console.log( _.toStr( files, { levels : 99 } ) );

  // var got2 = _.fileProvider.filesFind( { filePath : __dirname, recursive : 1 } );
  // console.log( got2[ 0 ] );

}

experiment.experimental = 1;

//

function experiment2( test )
{
  var expected =
  [
    './Provider.Extract.html',
    './Provider.Extract.test.s',
    './Provider.HardDrive.test.ss',
    './Provider.Hub.Extract.test.s',
    './Provider.Hub.HardDrive.test.ss',
    './Provider.Url.test.ss'
  ]

  //!!!this case is not working

  test.case = 'glob without absolute path';

  debugger;
  var result = _.fileProvider.filesFind
  ({
    filePath : __dirname,
    glob : 'Provider*',
    outputFormat : 'relative'
  })
  test.identical( result, expected );
  debugger;

  //!!!this works

  test.case = 'glob with absolute path';

  var result = _.fileProvider.filesFind
  ({
    filePath : __dirname,
    glob : _.path.join( __dirname, 'Provider*' ),
    outputFormat : 'relative'
  })
  test.identical( result, expected );
}

experiment2.experimental = 1;

// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/FilesFind',
  silencing : 1,
  enabled : 1,
  // verbosity : 0,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {

    isBrowser : null,
    testRootDirectory : null,

    makeStandardExtract : makeStandardExtract,
    _generatePath : _generatePath,
    _filesFindTrivial : _filesFindTrivial,
    _filesMigrate : _filesMigrate,
    symlinkIsAllowed : symlinkIsAllowed

  },

  tests :
  {

    filesFindTrivial : filesFindTrivial,

    // filesFind : filesFind,
    filesFind2 : filesFind2,
    // filesFindResolving : filesFindResolving,
    // filesFindPerformance : filesFindPerformance,

    filesFindGlob : filesFindGlob,
    filesGlob : filesGlob,

    filesMigrate : filesMigrate,
    filesGrab : filesGrab,
    filesLookExperiment : filesLookExperiment,

    filesDelete : filesDelete,
    // filesDeleteAndAsyncWrite : filesDeleteAndAsyncWrite,

    filesFindDifference : filesFindDifference, /* qqq : fix it please */
    // filesCopy : filesCopy, /* qqq : fix it please */

    // experiment : experiment,
    experiment2 : experiment2,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
