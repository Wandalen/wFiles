( function _Files_find_test_ss_( ) {

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
    require( '../wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  try
  {
    require( 'include/abase/object/Testing.debug.s' );
  }
  catch( err )
  {
    require( 'wTesting' );
  }

  require( '../file/Files.ss' );

}

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

var _ = wTools;
var Self = {};
debugger;
var files = new _.FileProvider.HardDrive();

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

var filesFindDifference = function( test )
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
        { src : { relative : './a.a' }, same : undefined, del : undefined, newer:  { side : 'src' }, older : null },
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
    var dir = './tmp/sample/' + sample.name;
    test.description = sample.name;

    _.filesTreeWrite
    ({
      pathFile : dir,
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

      //logger.log( 'got:\n' + _.toStr( got,{ levels : 3 } ) );
      //logger.log( 'expected:\n' + _.toStr( sample.expected,{ levels : 3 } ) );

      logger.log( 'got:\n' + _.toStr( got,{ levels : 2 } ) );

      logger.log( 'relative:\n' + _.toStr( _.entitySelect( got,'*.src.relative' ),{ levels : 2 } ) );
      logger.log( 'same:\n' + _.toStr( _.entitySelect( got,'*.same' ),{ levels : 2 } ) );
      logger.log( 'del:\n' + _.toStr( _.entitySelect( got,'*.del' ),{ levels : 2 } ) );

      logger.log( 'newer:\n' + _.toStr( _.entitySelect( got,'*.newer.side' ),{ levels : 1 } ) );
      logger.log( 'older:\n' + _.toStr( _.entitySelect( got,'*.older' ),{ levels : 1 } ) );

    }

    test.description = '';

  }

  debugger;
}

//

var filesCopy = function( test )
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
        maskAll : { excludeAny : /(^|\/)\.(?!$|\/)/ },
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

    var dir = './tmp/sample/' + sample.name;
    test.description = sample.name;

    _.filesTreeWrite
    ({
      pathFile : dir,
      filesTree : sample.filesTree,
      allowWrite : 1,
      allowDelete : 1,
      sameTime : 1,
    });

/*
    var treeWriten = _.filesTreeRead
    ({
      pathFile : dir,
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
    var got = files.filesCopy( copyOptions );

    var treeGot = _.filesTreeRead( dir );

    var passed = true;
    passed = passed && test.contain( got,sample.expected );
    passed = passed && test.identical( got.length,sample.expected.length );
    passed = passed && test.identical( treeGot.initial,sample.filesTree.got );

    if( !passed )
    {

      //logger.log( 'return:\n' + _.toStr( got,{ levels : 2 } ) );
      //logger.log( 'got:\n' + _.toStr( treeGot.initial,{ levels : 3 } ) );
      //logger.log( 'expected:\n' + _.toStr( sample.filesTree.got,{ levels : 3 } ) );

      logger.log( 'relative:\n' + _.toStr( _.entitySelect( got,'*.relative' ),{ levels : 2 } ) );
      logger.log( 'action:\n' + _.toStr( _.entitySelect( got,'*.action' ),{ levels : 2 } ) );
      logger.log( 'length:\n' + got.length + ' / ' + sample.expected.length );

      //logger.log( 'same:\n' + _.toStr( _.entitySelect( got,'*.same' ),{ levels : 2 } ) );
      //logger.log( 'del:\n' + _.toStr( _.entitySelect( got,'*.del' ),{ levels : 2 } ) );

    }

    test.description = '';

  }

  debugger;
}

// --
// proto
// --

var Proto =
{

  tests:
  {

    filesFindDifference: filesFindDifference,
    filesCopy: filesCopy,

  },

  verbose : 0,
  name : 'FilesTest',

};

_.mapExtend( Self,Proto );
wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
