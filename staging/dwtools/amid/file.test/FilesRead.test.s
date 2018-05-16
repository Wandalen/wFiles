( function _Files_read_test_s_( ) {

'use strict'; 

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath );
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
  require( '../file/FileTop.s' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;

//

function testDirMake()
{
  if( !isBrowser )
  this.testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..' ) );
  else
  this.testRootDirectory = _.pathCurrent();
}

//

function testDirClean()
{
  _.fileProvider.filesDelete( this.testRootDirectory );
}

// --
// read
// --

function filesRead( test )
{
  test.description = 'basic';

  var files = _.fileProvider.filesGlob({ globIn : _.pathNormalize( __dirname ) + '/**' });
  var read = _.fileProvider.filesRead({ paths : files, preset : 'js' });

  debugger;

  test.identical( read.errs, {} );
  test.shouldBe( read.err === undefined );
  test.shouldBe( _.arrayIs( read.read ) );
  test.shouldBe( _.strIs( read.data ) );
  test.shouldBe( read.data.indexOf( '======\n( function()' ) !== -1 );

  debugger;

  //

  var provider = _.fileProvider;
  var testDir = _.pathJoin( this.testRootDirectory, test.name );
  var fileNames = [ 'a', 'b', 'c' ];

  test.description = 'sync reading of files, all files are present';
  var paths = fileNames.map( ( path ) =>
  {
    var p = _.pathJoin( testDir, path );
    provider.fileWrite( p, path );
    return p;
  });
  var result = provider.filesRead
  ({
    paths : paths,
    sync : 1,
    throwing : 1,
  });
  test.identical( result.data, fileNames );
  test.identical( result.errs, {} );
  test.identical( result.err, undefined );

  //

  test.description = 'sync reading of files, not all files are present, throwing on';
  var paths = fileNames.map( ( path ) =>
  {
    var p = _.pathJoin( testDir, path );
    provider.fileWrite( p, path );
    return p;
  });
  paths.push( paths[ 0 ] + '_' );
  test.shouldThrowError( () =>
  {
    provider.filesRead
    ({
      paths : paths,
      sync : 1,
      throwing : 1,
    });
  })

  //

  test.description = 'sync reading of files, not all files are present, throwing off';
  var paths = fileNames.map( ( path ) =>
  {
    var p = _.pathJoin( testDir, path );
    provider.fileWrite( p, path );
    return p;
  });
  paths.push( paths[ 0 ] + '_' );
  var result = provider.filesRead
  ({
    paths : paths,
    sync : 1,
    throwing : 0,
  });

  var expectedData = fileNames.slice();
  expectedData.push( null );
  test.identical( result.data, expectedData );
  test.shouldBe( _.errIs( result.errs[ paths.length - 1 ] ) );
  test.shouldBe( _.errIs( result.err ) );

  // logger.log( _.toStr( result, { levels : 99 } ) )
}

//

function filesTreeRead( test )
{
  var currentTestDir = _.pathJoin( testRootDirectory, test.name );
  var provider = _.fileProvider;
  provider.safe = 1;
  var filesTreeReadFixedOptions =
  {
    recursive : 1,
    relative : null,
    filePath : null,
    strict : 1,
    ignoreNonexistent : 1,
    result : [],
    orderingExclusion : [],
    sortingWithArray : null,
    delimeter : '/',
    onFileTerminal : null,
    onFileDir : null,
  }

  var map =
  {
    includingTerminals : [ 0, 1 ],
    includingDirectories : [ 0, 1 ],
    asFlatMap : [ 0, 1 ],
    readingTerminals : [ 0, 1 ]
  }

  var combinations = [];
  var keys = _.mapOwnKeys( map );

  function combine( i, o )
  {
    if( i === undefined )
    i = 0;

    if( o === undefined )
    o = {};

    var currentKey = keys[ i ];
    var values = map[ currentKey ];

    values.forEach( ( val ) =>
    {
      o[ currentKey ] = val;

      if( i + 1 < keys.length )
      combine( i + 1, o )
      else
      combinations.push( _.mapSupplement( {}, o ) )
    });
  }

  function flatMapFromTree( tree, currentPath, paths, o )
  {
    if( paths === undefined )
    {
      paths = Object.create( null );
    }

    if( o.includingDirectories )
    if( !paths[ o.relative ] )
    paths[ o.relative ] = Object.create( null );

    for( var k in tree )
    {
      if( _.objectIs( tree[ k ] ) )
      {
        if( o.includingDirectories )
        paths[ _.pathResolve( currentPath, k ) ] = Object.create( null );

        flatMapFromTree( tree[ k ], _.pathJoin( currentPath, k ), paths, o );
      }
      else
      {
        if( o.includingTerminals )
        {
          var val = null;
          if( o.readingTerminals )
          val = tree[ k ];

          paths[ _.pathResolve( currentPath, k ) ] = val;
        }
      }
    }

    return paths;
  }

  function flatMapToTree( map, o )
  {
    var paths = _.mapOwnKeys( map );
    _.arrayRemoveOnce( paths, o.relative );
    var result = Object.create( null );
    // result[ '.' ] = Object.create( null );
    // var inner = result[ '.' ];

    paths.forEach( ( p ) =>
    {
      var isTerminal = _.strIs( map[ p ] );
      if( isTerminal && o.includingTerminals || o.includingDirectories && !isTerminal )
      {
        var val = map[ p ];
        if( isTerminal && !o.readingTerminals )
        val = null;
      }
      _.entitySelectSet( result , _.pathRelative( o.relative, p ), val );
    })

    return result;
  }

  //

  var filesTree =
  {
    a  :
    {
      b  :
      {
        c  :
        {
          d :
          {
            e :
            {
              e_a  : '1',
              e_b  : '2',
              e_c  : '3',
              e_d : {}
            }
          },
          d_a  : '4',
          d_b  : '5',
          d_c  : '6',
          d_d : {}
        },
        c_a  : '7',
        c_b  : '8',
        c_c  : '9',
        c_d : {}
      },
      b_a  : '0',
      b_b  : '1',
      b_c  : '2',
      b_d : {}
    },
    a_a  : '3',
    a_b  : '4',
    a_c  : '5',
    a_d : {}
  }

  provider.filesDelete( currentTestDir );

  provider.filesTreeWrite
  ({
    filesTree : filesTree,
    filePath : currentTestDir
  })

  var n = 0;

  var testsInfo = [];

  combine();
  combinations.forEach( ( c ) =>
  {
    var info = _.mapSupplement( {}, c );
    info.number = ++n;
    test.description = _.toStr( info, { levels : 3 } )
    var checks = [];
    var options = _.mapSupplement( {}, c );
    _.mapSupplement( options, filesTreeReadFixedOptions );
    options.relative = info.relative = currentTestDir;
    options.globIn = info.globIn = _.pathJoin( options.relative, '**' );

    debugger
    var files = _.fileProvider.filesTreeRead( options );

    var expected = {};
    debugger
    flatMapFromTree( filesTree, currentTestDir, expected, options );

    if( !options.asFlatMap )
    expected = flatMapToTree( expected, options );

    checks.push( test.identical( files, expected ) );

    info.passed = true;
    checks.forEach( ( check ) => { info.passed &= check; } )
    testsInfo.push( info );
  })

  console.log( _.toStr( testsInfo, { levels : 3 } ) )
}

//

function filesTreeWrite( test )
{
  test.description = 'filesTreeWrite';

  var currentTestDir = _.pathJoin( testRootDirectory, test.name );
  var provider = _.fileProvider;

  var fixedOptions =
  {
    filesTree : null,
    filePath : null,
    allowWrite : 1,
    allowDelete : 1,
    verbosity : 0,
  }

  var map =
  {
    sameTime : [ 0, 1 ],
    absolutePathForLink : [ 0, 1 ],
    terminatingSoftLinks : [ 0, 1 ],
    terminatingHardLinks : [ 0, 1 ],
  }

  var srcs =
  [
    {
      a  :
      {
        b  :
        {
          c  :
          {
            d :
            {
              e :
              {
                e_a  : '1',
                e_b  : '2',
                e_c  : '3',
                e_d : {}
              }
            },
            d_a  : '4',
            d_b  : '5',
            d_c  : '6',
            d_d : {}
          },
          c_a  : '7',
          c_b  : '8',
          c_c  : '9',
          c_d : {}
        },
        b_a  : '0',
        b_b  : '1',
        b_c  : '2',
        b_d : {}
      },
      a_a  : '3',
      a_b  : '4',
      a_c  : '5',
      a_d : {}
    }
  ]

  var combinations = [];
  var keys = _.mapOwnKeys( map );

  function combine( i, o )
  {
    if( i === undefined )
    i = 0;

    if( o === undefined )
    o = {};

    var currentKey = keys[ i ];
    var values = map[ currentKey ];

    values.forEach( ( val ) =>
    {
      o[ currentKey ] = val;

      if( i + 1 < keys.length )
      combine( i + 1, o )
      else
      combinations.push( _.mapSupplement( {}, o ) )
    });
  }


  var n = 0;

  var testsInfo = [];

  combine();
  srcs.forEach( ( tree ) =>
  {
    combinations.forEach( ( c ) =>
    {
      var info = _.mapSupplement( {}, c );
      info.number = ++n;
      test.description = _.toStr( info, { levels : 3 } )
      var checks = [];
      var options = _.mapSupplement( {}, c );
      _.mapSupplement( options, fixedOptions );

      provider.filesDelete( currentTestDir );
      options.filePath = currentTestDir;
      options.filesTree = tree;

      provider.filesTreeWrite( options );

      var got = provider.filesTreeRead( currentTestDir );
      test.identical( got, tree );
    })
  })
}

// --
// proto
// --

var Self =
{

  name : 'FilesRead',
  silencing : 1,
  // verbosity : 7,

  onSuitBegin : testDirMake,
  onSuitEnd : testDirClean,

  context :
  {
    testRootDirectory : null
  },

  tests :
  {

    filesRead : filesRead,
    filesTreeRead : filesTreeRead,
    filesTreeWrite : filesTreeWrite

  },

}

Self = wTestSuit( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
