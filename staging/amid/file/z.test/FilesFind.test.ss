( function _Files_find_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

  var _ = wTools;

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;
var rootDir = _.pathResolve( __dirname + '/../../../../tmp.tmp'  );

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

  softlink :
  {
    'src' :
    {
      'a' : 'a',
      'b' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
      'c' : [{ softlink : './b' }]
    },
    'dst' :
    {
    },
  },

}

// --
// test
// --

function filesFindDifference( test )
{
  var self = this;

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
        { src : { relative : '.' }, same : undefined, del : undefined },
        { src : { relative : './a.a' }, same : undefined, del : undefined },
        { src : { relative : './b1.b' }, same : undefined, del : undefined },
        { src : { relative : './b2.b' }, same : undefined, del : undefined },
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
        { src : { relative : '.' }, same : true, del : undefined },
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
        { src : { relative : '.' }, same : false, del : undefined },
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
        { src : { relative : './d2.d' }, same : undefined, del : true },
        { src : { relative : './e1.e' }, same : undefined, del : true },
        { src : { relative : '.' }, same : false, del : undefined },
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
        { src : { relative : '.' }, same : false, del : undefined },
        { src : { relative : './d2.d' }, same : undefined, del : undefined },
        { src : { relative : './e1.e' }, same : undefined, del : undefined },
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
        { src : { relative : '.' }, same : undefined, del : undefined, newer : null, older : null },
        { src : { relative : './a.a' }, same : undefined, del : undefined, newer :  { side : 'src' }, older : null },
        { src : { relative : './b1.b' }, same : true, del : undefined, newer : null, older : null },
        { src : { relative : './b2.b' }, same : false, del : undefined, newer : null, older : null },
        { src : { relative : './c' }, same : undefined, del : undefined, newer : null, older : null },
        { src : { relative : './c/d1.d' }, same : undefined, del : true, newer : { side : 'dst' }, older : null },
        { src : { relative : './c/b3.b' }, same : false, del : undefined, newer : null, older : null },
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
        { relative : '.', same : undefined, del : undefined },
        { relative : './a.a', same : undefined, del : undefined },
        { relative : './b1.b', same : undefined, del : undefined },
        { relative : './b2.b', same : undefined, del : undefined },
        { relative : './c', same : undefined, del : undefined },
        { relative : './c/b3.b', same : undefined, del : undefined },
        { relative : './c/d1.d', same : undefined, del : undefined },
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
        { relative : '.', same : undefined, del : undefined },
        { src : { relative : './a.a' }, del : undefined },
        { src : { relative : './b1.b' }, del : undefined },
        { src : { relative : './b2.b' }, del : undefined },
        { src : { relative : './c' }, del : undefined },
        { src : { relative : './c/b3.b' }, del : undefined },
        { src : { relative : './c/d1.d' }, del : undefined },
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
        { relative : '.', same : undefined, del : undefined },
        { src : { relative : './a.a' }, del : true },
        { src : { relative : './b1.b' }, del : undefined },
        { src : { relative : './b2.b' }, del : undefined },
        { src : { relative : './c' }, del : undefined },
        { src : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, del : undefined },
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
        { relative : '.', same : undefined, del : undefined },
        { src : { relative : './c' }, del : true },
        { src : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, del : true },
        { src : { relative : './c/e' }, del : true },
        { src : { relative : './c/e/d2.d' }, del : true },
        { src : { relative : './c/e/e1.e' }, del : true },

        { src : { relative : './a.a' }, del : undefined },
        { src : { relative : './b1.b' }, del : undefined },
        { src : { relative : './b2.b' }, del : undefined },

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

        { relative : '.', same : undefined, del : undefined },

        { src : { relative : './a.a' }, same : true },
        { src : { relative : './b1.b' }, same : true },
        { src : { relative : './b2.b' }, same : true },

        { src : { relative : './c' }, del : undefined, same : false },
        { src : { relative : './c/b3.b' }, del : undefined },
        { src : { relative : './c/d1.d' }, del : undefined },
        { src : { relative : './c/e' }, del : undefined },
        { src : { relative : './c/e/d2.d' }, del : undefined },
        { src : { relative : './c/e/e1.e' }, del : undefined },

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

        { relative : '.', src : { relative : '.' }, dst : { relative : '.' }, same : undefined, del : undefined },

        { src : { relative : './c/b3.b' }, dst : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, dst : { relative : './c/d1.d' }, del : true },
        { src : { relative : './c/e' }, dst : { relative : './c/e' }, del : true },
        { src : { relative : './c/e/d2.d' }, dst : { relative : './c/e/d2.d' }, del : true },
        { src : { relative : './c/e/e1.e' }, dst : { relative : './c/e/e1.e' }, del : true },

        { src : { relative : './a.a' }, src : { relative : './a.a' }, same : true },
        { src : { relative : './b1.b' }, src : { relative : './b1.b' }, same : true },
        { src : { relative : './b2.b' }, src : { relative : './b2.b' }, same : true },

        { src : { relative : './c' }, dst : { relative : './c' }, del : undefined, same : false },

        { src : { relative : './f' }, dst : { relative : './f' }, same : undefined },
        { src : { relative : './f/f1/f11' }, dst : { relative : './f/f1/f11' }, same : undefined, del : true },
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

        { relative : '.', same : undefined, del : undefined },

        { src : { relative : './a.a' }, del : true, same : undefined },
        { src : { relative : './b1.b' }, del : undefined, same : true },
        { src : { relative : './b2.b' }, del : undefined, same : true },

        { src : { relative : './c' }, del : undefined, same : undefined },
        { src : { relative : './c/d1.d' }, del : true, same : undefined },
        { src : { relative : './c/b3.b' }, del : undefined, same : true },

        { src : { relative : './c/e' }, del : undefined, same : undefined },
        { src : { relative : './c/e/d2.d' }, del : true, same : undefined },
        { src : { relative : './c/e/e1.e' }, del : true, same : undefined },

      ],
    },

    //

    {
      name : 'complex-1',

      expected :
      [

        { relative : '.', same : undefined, del : undefined, older : null, newer : null },

        { relative : './a.a', same : true, del : undefined, older : null, newer : null },
        { relative : './b1.b', same : true, del : undefined, older : null, newer : null },
        { relative : './b2.b', same : false, del : undefined, older : null, newer : null },

        { relative : './c', same : undefined, del : undefined, older : null, newer : null },

        { relative : './c/dstfile.d', same : undefined, del : true, older : null, newer : { side : 'dst' } },
        { relative : './c/dstdir', same : undefined, del : true, older : null, newer : { side : 'dst' }  },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', same : undefined, del : true, older : null, newer : { side : 'dst' } },

        { relative : './c/b3.b', same : false, del : undefined, older : null, newer : null },

        { relative : './c/srcfile', same : undefined, del : undefined, older : null, newer : { side : 'src' } },
        { relative : './c/srcfile-dstdir', same : false, del : undefined, older : null, newer : null },

        { relative : './c/e', same : undefined, del : undefined, older : null, newer : null },
        { relative : './c/e/d2.d', same : false, del : undefined, older : null, newer : null },
        { relative : './c/e/e1.e', same : true, del : undefined, older : null, newer : null },

        { relative : './c/srcdir', same : undefined, del : undefined, older : null, newer : { side : 'src' } },
        { relative : './c/srcdir-dstfile', same : false, del : undefined, older : null, newer : null },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', same : undefined, del : undefined, older : null, newer : { side : 'src' } },

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

        { relative : '.', same : undefined, del : undefined },

        { relative : './c', same : undefined, del : true },
        { relative : './c/c1', same : undefined, del : true },
        { relative : './c/c2', same : undefined, del : true },
        { relative : './c/c2/c22', same : undefined, del : true },

        { relative : './a', same : undefined, del : undefined },

        { relative : './b', same : undefined, del : undefined },
        { relative : './b/b1', same : true, del : undefined },
        { relative : './b/b2', same : undefined, del : undefined },
        { relative : './b/b2/b22', same : true, del : undefined },
        { relative : './b/b2/x', same : true, del : undefined },

      ],

      filesTree :
      {

        initial : filesTree.exclude,

      },

    },

    //

    {
      name : 'exclude-2',
      options :
      {
        maskAll : { excludeAny : /b/ }
      },

      expected :
      [

        { relative : '.', same : undefined, del : undefined },

        { relative : './b', same : undefined, del : true },
        { relative : './b/b1', same : undefined, del : true },
        { relative : './b/b2', same : undefined, del : true },
        { relative : './b/b2/b22', same : undefined, del : true },
        { relative : './b/b2/x', same : undefined, del : true },

        { relative : './c', same : undefined, del : true },
        { relative : './c/c1', same : undefined, del : true },
        { relative : './c/c2', same : undefined, del : true },
        { relative : './c/c2/c22', same : undefined, del : true },

        { relative : './a', same : undefined, del : undefined },

      ],

      filesTree :
      {

        initial : filesTree.exclude,

      },

    },

  ];

  //

  debugger;
  for( var s = 0 ; s < samples.length ; s++ )
  {

    var sample = samples[ s ];
    var dir = _.pathJoin( rootDir, './tmp/sample/' + sample.name );
    test.description = sample.name;

    _.fileProvider.filesTreeWrite
    ({
      filePath : dir,
      filesTree : sample.filesTree,
      allowWrite : 1,
      allowDelete : 1,
      sameTime : 1,
    });

    var o =
    {
      src : _.pathJoin( dir, 'initial/src' ),
      dst : _.pathJoin( dir, 'initial/dst' ),
      ends : sample.ends,
      includeFiles : 1,
      includeDirectories : 1,
      recursive : 1,
      onDown : function( record ){ test.identical( _.objectIs( record ),true ); },
      onUp : function( record ){ test.identical( _.objectIs( record ),true ); },
    }

    _.mapExtend( o,sample.options || {} );

    var files = _.FileProvider.HardDrive();
    var got = files.filesFindDifference( o );

    var passed = true;
    passed = passed && test.contain( got,sample.expected );
    passed = passed && test.identical( got.length,sample.expected.length );

    if( !passed )
    {

      //logger.log( 'got :\n' + _.toStr( got,{ levels : 3 } ) );
      //logger.log( 'expected :\n' + _.toStr( sample.expected,{ levels : 3 } ) );

      logger.log( 'got :\n' + _.toStr( got,{ levels : 2 } ) );

      logger.log( 'relative :\n' + _.toStr( _.entitySelect( got,'*.src.relative' ),{ levels : 2 } ) );
      logger.log( 'same :\n' + _.toStr( _.entitySelect( got,'*.same' ),{ levels : 2 } ) );
      logger.log( 'del :\n' + _.toStr( _.entitySelect( got,'*.del' ),{ levels : 2 } ) );

      logger.log( 'newer :\n' + _.toStr( _.entitySelect( got,'*.newer.side' ),{ levels : 1 } ) );
      logger.log( 'older :\n' + _.toStr( _.entitySelect( got,'*.older' ),{ levels : 1 } ) );

    }

    test.description = '';

  }

  debugger;
}

//

function filesCopy( test )
{
  var self = this;

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
      options : { removeSource : 1, allowWrite : 1 },
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
      options : { includeDirectories : 0, removeSourceFiles : 1, allowWrite : 1, allowRewrite : 1, allowDelete : 0, ends : '.b' },
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
      options : { includeDirectories : 0, removeSourceFiles : 1, allowWrite : 1, allowRewrite : 1, allowDelete : 0, ends : '.b' },

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
      options : { removeSourceFiles : 1, allowWrite : 1, allowRewrite : 1, allowRewriteFileByDir : 0, allowDelete : 0, ends : '.b' },

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
      options : { removeSourceFiles : 1 },
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
      options : { removeSource : 1 },
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

    {

      name : 'complex-allow-only-rewrite',
      options : { allowRewrite : 1, allowDelete : 0, allowWrite : 0 },

      expected :
      [

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', allowed : true },
        { relative : './b2.b', action : 'cant rewrite', allowed : false },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : false },
        { relative : './c/dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

        { relative : './c/b3.b', action : 'cant rewrite', allowed : false },

        { relative : './c/srcfile', action : 'copied', allowed : false },
        { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'cant rewrite', allowed : false },
        { relative : './c/e/e1.e', action : 'same', },

        { relative : './c/srcdir', action : 'directory new', allowed : false },
        { relative : './c/srcdir-dstfile', action : 'cant rewrite', allowed : false },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allowed : false },

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

      },

    },

    //

    {

      name : 'complex-allow-only-delete',
      options : { allowRewrite : 0, allowDelete : 1, allowWrite : 0 },

      expected :
      [

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', allowed : true },
        { relative : './b2.b', action : 'cant rewrite', allowed : false },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : true },
        { relative : './c/dstdir', action : 'deleted', allowed : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : true },

        { relative : './c/b3.b', action : 'cant rewrite', allowed : false },

        { relative : './c/srcfile', action : 'copied', allowed : false },
        { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'cant rewrite', allowed : false },
        { relative : './c/e/e1.e', action : 'same', },

        { relative : './c/srcdir', action : 'directory new', allowed : false },
        { relative : './c/srcdir-dstfile', action : 'cant rewrite', allowed : false },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allowed : false },

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
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'srcdir-dstfile' : 'x',
              'srcfile-dstdir' : {},
            },
          },
        },

      },

    },

    //

    {

      name : 'complex-not-allow-only-rewrite',
      options : { allowRewrite : 0, allowDelete : 1, allowWrite : 1 },

      expected :
      [

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', },
        { relative : './b2.b', action : 'cant rewrite', },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : true },
        { relative : './c/dstdir', action : 'deleted', allowed : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : true },

        { relative : './c/b3.b', action : 'cant rewrite', },

        { relative : './c/srcfile', action : 'copied' },
        { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'cant rewrite', },
        { relative : './c/e/e1.e', action : 'same', },

        { relative : './c/srcdir', action : 'directory new' },
        { relative : './c/srcdir-dstfile', action : 'cant rewrite', },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

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
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : {},
              'srcdir' : {},
              'srcdir-dstfile' : 'x',
            },
          },
        },

      },

    },

    //

    {

      name : 'complex-not-allow-rewrite-and-delete',
      options : { allowRewrite : 0, allowDelete : 0, allowWrite : 1 },

      expected :
      [

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', },
        { relative : './b2.b', action : 'cant rewrite', },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : false },
        { relative : './c/dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

        { relative : './c/b3.b', action : 'cant rewrite', },

        { relative : './c/srcfile', action : 'copied' },
        { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'cant rewrite', },
        { relative : './c/e/e1.e', action : 'same', },

        { relative : './c/srcdir', action : 'directory new' },
        { relative : './c/srcdir-dstfile', action : 'cant rewrite', },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

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
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'dstfile.d' : 'd1',
              'dstdir' : {},
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
              'srcdir' : {},
              'srcdir-dstfile' : 'x',
            },
          },
        },

      },

    },

    //

    {

      name : 'complex-not-allowed',
      options : { allowRewrite : 0, allowDelete : 0, allowWrite : 0 },

      expected :
      [

        { relative : '.', action : 'directory preserved', },

        { relative : './a.a', action : 'same', },
        { relative : './b1.b', action : 'same', },
        { relative : './b2.b', action : 'cant rewrite', },

        { relative : './c', action : 'directory preserved', },

        { relative : './c/dstfile.d', action : 'deleted', allowed : false },
        { relative : './c/dstdir', action : 'deleted', allowed : false },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allowed : false },

        { relative : './c/b3.b', action : 'cant rewrite', },

        { relative : './c/srcfile', action : 'copied', allowed : false },
        { relative : './c/srcfile-dstdir', action : 'cant rewrite', allowed : false },

        { relative : './c/e', action : 'directory preserved', },
        { relative : './c/e/d2.d', action : 'cant rewrite', allowed : false },
        { relative : './c/e/e1.e', action : 'same', allowed : true },

        { relative : './c/srcdir', action : 'directory new' },
        { relative : './c/srcdir-dstfile', action : 'cant rewrite' },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

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

      },

    },

    //

    {
      name : 'filtered-out-dst-empty-1',
      options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1, maskAll : 'xxx' },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : {},
        },
      },
      expected :
      [
        { relative : '.', action : 'directory new', allowed : true },
      ],
    },

    //

    {
      name : 'filtered-out-dst-filled-1',
      options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1, maskAll : 'xxx' },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : {},
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved', allowed : true },
        { relative : './a.a', action : 'deleted', allowed : true },
        { relative : './b1.b', action : 'deleted', allowed : true },
        { relative : './b2.b', action : 'deleted', allowed : true },
      ],
    },

    //

    {
      name : 'filtered-out-dst-filled-1',
      options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1 },
      filesTree :
      {
        initial :
        {
          'src' : {},
          'dst' : { 'a' : {}, 'b' : { 'b1' : 'b1', 'b2' : 'b2' } },
        },
        got :
        {
          'src' : {},
          'dst' : {},
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved', allowed : true },
        { relative : './a', action : 'deleted', allowed : true },
        { relative : './b', action : 'deleted', allowed : true },
        { relative : './b/b1', action : 'deleted', allowed : true },
        { relative : './b/b2', action : 'deleted', allowed : true },
      ],
    },

    //

    {
      name : 'exclude-1',
      options :
      {
        allowDelete : 1,
        maskAll : { excludeAny : /b/ }
      },

      expected :
      [

        { relative : '.', action : 'directory preserved' },

        { relative : './b', action : 'deleted', allowed : true },
        { relative : './b/b1', action : 'deleted', allowed : true },
        { relative : './b/b2', action : 'deleted', allowed : true },
        { relative : './b/b2/b22', action : 'deleted', allowed : true },
        { relative : './b/b2/x', action : 'deleted', allowed : true },

        { relative : './c', action : 'deleted', allowed : true },
        { relative : './c/c1', action : 'deleted', allowed : true },
        { relative : './c/c2', action : 'deleted', allowed : true },
        { relative : './c/c2/c22', action : 'deleted', allowed : true },

        { relative : './a', action : 'copied', allowed : true },

      ],

      filesTree :
      {

        initial : filesTree.exclude,
        got :
        {
          'src' :
          {
            'a' : 'a',
            'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
          },
          'dst' :
          {
            'a' : 'a',
          },
        },

      },

    },

    //

    {
      name : 'exclude-2',
      options :
      {
        allowDelete : 1,
        maskAll : { includeAny : /x/ }
      },

      expected :
      [

        { relative : '.', action : 'directory preserved' },

        { relative : './b', action : 'deleted', allowed : true },
        { relative : './b/b1', action : 'deleted', allowed : true },
        { relative : './b/b2', action : 'deleted', allowed : true },
        { relative : './b/b2/b22', action : 'deleted', allowed : true },
        { relative : './b/b2/x', action : 'deleted', allowed : true },

        { relative : './c', action : 'deleted', allowed : true },
        { relative : './c/c1', action : 'deleted', allowed : true },
        { relative : './c/c2', action : 'deleted', allowed : true },
        { relative : './c/c2/c22', action : 'deleted', allowed : true },

      ],

      filesTree :
      {

        initial : filesTree.exclude,
        got :
        {
          'src' :
          {
            'a' : 'a',
            'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
          },
          'dst' :
          {
          },
        },

      },

    },

    //

    {
      name : 'softlink-1',
      options :
      {
        allowDelete : 1,
        maskAll : { excludeAny : /(^|\/)\.(?!$|\/|\.)/ },
      },

      expected :
      [

        { relative : '.', action : 'directory preserved' },

        { relative : './a', action : 'copied', allowed : true },

        { relative : './b', action : 'directory new', allowed : true },
        //{ relative : './b/.b1', action : 'copied', allowed : true },
        { relative : './b/b2', action : 'directory new', allowed : true },
        { relative : './b/b2/b22', action : 'copied', allowed : true },

        { relative : './c', action : 'directory new', allowed : true },
        { relative : './c/b2', action : 'directory new', allowed : true },
        { relative : './c/b2/b22', action : 'copied', allowed : true },

      ],

      filesTree :
      {
        initial : filesTree.softlink,
        got :
        {
          'src' :
          {
            'a' : 'a',
            'b' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
            'c' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
          },
          'dst' :
          {
            'a' : 'a',
            'b' : { 'b2' : { 'b22' : 'b22' } },
            'c' : { 'b2' : { 'b22' : 'b22' } },
          },
        },
      },

    },

  //

  ];

  //

  debugger;
  for( var s = 0 ; s < samples.length ; s++ )
  {

    var sample = samples[ s ];
    if( !sample ) break;

    var dir = _.pathJoin( rootDir, './tmp/sample/' + sample.name );
    test.description = sample.name;

    _.fileProvider.filesTreeWrite
    ({
      filePath : dir,
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
      src : _.pathJoin( dir, 'initial/src' ),
      dst : _.pathJoin( dir, 'initial/dst' ),
      ends : sample.ends,
      investigateDestination : 1,
      includeFiles : 1,
      includeDirectories : 1,
      recursive : 1,
      allowWrite : 1,
      allowRewrite : 1,
      allowDelete : 0,
    }

    _.mapExtend( copyOptions,sample.options || {} );
    var got = _.fileProvider.filesCopy( copyOptions );

    var treeGot = _.fileProvider.filesTreeRead( dir );

    var passed = true;
    passed = passed && test.contain( got,sample.expected );
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

    test.description = '';

  }

  debugger;
}

//

function _generatePath( dir, levels )
{
  var foldersPath = dir;
  var fileName = _.idGenerateGuid();

  for( var j = 0; j < levels; j++ )
  {
    var temp = _.idGenerateGuid().substring( 0, Math.random() * levels );
    foldersPath = _.pathJoin( foldersPath , temp );
  }

  return _.pathJoin( foldersPath, fileName );
}

//

function filesFind( t )
{
  var dir = _.pathRealMainDir();
  var provider = _.FileProvider.HardDrive();
  var filePath,got,expected;

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
        if( expected.indexOf( got[ i ].nameWithExt || got[ i ] ) === -1 )
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
        if( _.arrayLeftIndexOf( result,src[ j ] ) >= 0 )
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

  filePath = _.pathJoin( dir, __filename );
  got = provider.filesFind( filePath );
  expected = provider.directoryRead( filePath );
  t.identical( check( got,expected ), true );

  /*filePath - empty dir*/

  filePath = _.pathJoin( rootDir, 'tmp/empty' );
  provider.directoryMake( filePath )
  got = provider.filesFind( filePath );
  t.identical( got, [] );

  //

  t.description = 'ignoreNonexistent option';
  filePath = _.pathJoin( dir, __filename );

  /*filePath - relative path*/
  t.shouldThrowErrorSync( function()
  {
    provider.filesFind
    ({
      filePath : 'invalid path',
      ignoreNonexistent : 0
    });
  })

  /*filePath - not exist*/

  got = provider.filesFind
  ({
    filePath : '/invalid path',
    ignoreNonexistent : 0
  });
  t.identical( got, [] );

  /*filePath - some pathes not exist,ignoreNonexistent off*/

  got = provider.filesFind
  ({
    filePath : [ '/0', filePath, '/1' ],
    ignoreNonexistent : 0
  });
  expected = provider.directoryRead( filePath );
  t.identical( check( got, expected ), true )

  /*filePath - some pathes not exist,ignoreNonexistent on*/

  got = provider.filesFind
  ({
    filePath : [ '0', filePath, '1' ],
    ignoreNonexistent : 1
  });
  expected = provider.directoryRead( filePath );
  t.identical( check( got, expected ), true )

  //

  t.description = 'includeFiles,includeDirectories options';

  /*filePath - empty dir, includeFiles,includeDirectories on*/

  provider.directoryMake( _.pathJoin( rootDir, 'empty' ) )
  got = provider.filesFind({ filePath : _.pathJoin( dir, 'empty' ), includeFiles : 1, includeDirectories : 1 });
  t.identical( got, [] );

  /*filePath - empty dir, includeFiles,includeDirectories off*/

  provider.directoryMake( _.pathJoin( rootDir, 'empty' ) )
  got = provider.filesFind({ filePath : _.pathJoin( dir, 'empty' ), includeFiles : 0, includeDirectories : 0 });
  t.identical( got, [] );

  /*filePath - directory, includeFiles,includeDirectories on*/

  got = provider.filesFind({ filePath : dir, includeFiles : 1, includeDirectories : 1 });
  expected = provider.directoryRead( dir );
  t.identical( check( got,expected ), true );

  /*filePath - directory, includeFiles,includeDirectories off*/

  got = provider.filesFind({ filePath : dir, includeFiles : 0, includeDirectories : 0 });
  expected = provider.directoryRead( dir );
  t.identical( got, [] );

  /*filePath - directory, includeFiles off,includeDirectories on*/

  got = provider.filesFind({ filePath : dir, includeFiles : 0, includeDirectories : 1 });
  expected = provider.directoryRead( dir );
  t.identical( check( got,expected ), true  );

  /*filePath - terminal file, includeFiles,includeDirectories off*/

  filePath = _.pathJoin( dir, __filename );
  got = provider.filesFind({ filePath : filePath, includeFiles : 0, includeDirectories : 0 });
  expected = provider.directoryRead( dir );
  t.identical( got, [] );

  /*filePath - terminal file, includeFiles off,includeDirectories on*/

  filePath = _.pathJoin( dir, __filename );
  got = provider.filesFind({ filePath : filePath, includeFiles : 0, includeDirectories : 1 });
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
  t.identical( check( got, _.pathIsAbsolute ), true );

  /*filePath - directory,outputFormat relative */

  got = provider.filesFind({ filePath : dir, outputFormat : 'relative' });
  expected = provider.directoryRead( dir );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = _.pathJoin( './', expected[ i ] );
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
  })

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

  /*filePath - directory, maskDir, includeDirectories */

  filePath = _.pathJoin( rootDir, 'tmp/dir' );
  provider.directoryMake( filePath );
  got = provider.filesFind
  ({
    filePath : _.pathDir( filePath ),
    includeDirectories : 1,
    maskDir : 'dir',
    outputFormat : 'relative'
  });
  expected = provider.directoryRead( _.pathDir( filePath ) );
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

  var orderingExclusion = [ 'Caching','Files' ];
  got = provider.filesFind
  ({
    filePath : dir,
    orderingExclusion : orderingExclusion,
    maskTerminal : null,
    outputFormat : 'relative'
  });
  expected = _orderingExclusion( provider.directoryRead( dir ), orderingExclusion );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  t.identical( got, expected )

  //

  t.description = 'change relative path in record';

  /*change relative to wFiles, relative should be like ./staging/amid/file/z.test/'file_name'*/

  var relative = _.pathResolve( dir + '../../../../../' );
  got = provider.filesFind
  ({
    filePath : dir,
    relative : relative
  });
  got = got[ 0 ].relative;
  var begins = './' + _.pathRelative( relative, dir );
  t.identical( _.strBegins( got, begins ), true );

  /* changing relative path affects only record.relative*/

  got = provider.filesFind
  ({
    filePath : dir,
    relative : '/x'
  });
  console.log( got[ 0 ] )
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

  t.mustNotThrowError( function()
  {
    var records = provider.filesFind({ filePath : dir, strict : 0 });
    records[ 0 ].newProperty = 1;
  })


}

filesFind.timeout = 5000;
// filesFind.timeout = 600000;

//

function filesFindPerformance( t )
{
  t.description = 'filesFind time test';

  /*prepare files */

  var dir = _.pathJoin( rootDir, 'tmp.special' );
  var provider = _.FileProvider.HardDrive();

  var filesNumber = 2000;
  var levels = 5;

  if( !_.fileProvider.fileStat( dir ) )
  {
    logger.log( "Creating ", filesNumber, " random files tree. " );
    var t1 = _.timeNow();
    for( var i = 0; i < filesNumber; i++ )
    {
      var path = _generatePath( dir, Math.random() * levels );
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

  var filter = _.FileFilter.Caching();
  var t2 = _.timeNow();
  for( var i = 0; i < times; i++)
  {
    var files = filter.filesFind
    ({
      filePath : dir,
      recursive : 1
    });
  }

  logger.log( _.timeSpent( 'Spent to make filesFind with three filters x' + times + ' times in dir with ' + filesNumber +' files tree',t2 ) );

  t.identical( files.length, filesNumber );
}

filesFindPerformance.timeout = 150000;

//

function experiment( test )
{

  // debugger;
  // var got1 = _.fileProvider.filesFind({ filePath : __dirname, relative : 'C:\\x', recursive : 1 });
  // var got1 = _.fileProvider.filesFind({ filePath : __dirname, recursive : 1 });

  debugger;
  var got1 = _.fileProvider.filesFind
  ({
    filePath : __dirname + '/../../../../tmp.tmp',
    relative : '/pro/web/Port/package',
    relative : '/abc',
    recursive : 1,
    usingTiming : 1,
  });

  debugger;
  // var got2 = _.fileProvider.filesFind( { filePath : __dirname, recursive : 1 } );
  // console.log( got2[ 0 ] );

}

experiment.experimental = 1;

// --
// proto
// --

var Self =
{

  name : 'FilesFindTest',
  sourceFilePath : sourceFilePath,
  // verbosity : 0,

  tests :
  {

    filesFindDifference : filesFindDifference,
    filesCopy : filesCopy,
    filesFind : filesFind,
    filesFindPerformance : filesFindPerformance,

    experiment : experiment,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
