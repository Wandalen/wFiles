( function _Files_read_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../../../Base.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  require( '../file/FileTop.s' );

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Tester;
var testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..'  ) );

//

function cleanTestDir()
{
  _.fileProvider.fileDelete( testRootDirectory );
}

// --
// read
// --

function filesRead( test )
{

  test.description = 'basic';

  var files = _.fileProvider.filesGlob({ glob : _.pathRegularize( __dirname ) + '/**' });
  var read = _.fileProvider.filesRead({ paths : files, preset : 'js' });

  debugger;

  test.shouldBe( read.errs.length === 0 );
  test.shouldBe( read.err === undefined );
  test.shouldBe( _.arrayIs( read.read ) );
  test.shouldBe( _.strIs( read.data ) );
  test.shouldBe( read.data.indexOf( '======\n( function()' ) !== -1 );

  debugger;
}

//

function filesTreeRead( test )
{
  var currentTestDir = _.pathJoin( testRootDirectory, test.name );
  var provider = _.fileProvider;
  var filesTreeReadFixedOptions =
  {
    recursive : 1,
    relative : null,
    filePath : null,
    safe : 1,
    strict : 1,
    ignoreNonexistent : 1,
    result : [],
    orderingExclusion : [],
    sortWithArray : null,
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

  provider.fileDelete( currentTestDir );

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
    options.glob = info.glob = _.pathJoin( options.relative, '**' );

    debugger
    var files = _.fileProvider.filesTreeRead( options );

    var expected = {};
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

// --
// proto
// --

var Self =
{

  name : 'FilesRead',
  silencing : 1,
  // verbosity : 7,

  onSuiteEnd : cleanTestDir,

  tests :
  {

    filesRead : filesRead,
    filesTreeRead : filesTreeRead

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
