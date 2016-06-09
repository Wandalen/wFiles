( function( ) {

  'use strict';

  if( typeof module !== undefined )
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
      require( '../wTools.ss' );
    }
    catch( err )
    {
      require( 'wTools' );
    }

    try
    {
      require( 'wTesting' );
    }
    catch( err )
    {
      require( 'include/abase/object/Testing.debug.s' );
    }

    require( '../file/Files.ss' );

  }

  _global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

  var _ = wTools;
  var Self = {};

  //

  var _pathJoin = function( test )
  {
    var options1 =
      {
        reroot: 1,
        url: 0
      },
      options2 =
      {
        reroot: 0,
        url: 1
      },
      options3 =
      {
        reroot: 0
      },

      paths1 = [ 'http://www.site.com:13/', 'bar', 'foo', ],
      paths2 = [ 'c:\\', 'foo\\', 'bar\\' ],
      paths3 = [ '/bar/', '/', 'foo/' ],
      paths4 = [ '/bar/', '/baz', 'foo/' ],

      expected1 = 'http://www.site.com:13/bar/foo',
      expected2 = 'c:/foo/bar/',
      expected3 = '/foo/',
      expected4 = '/bar/baz/foo/';


    test.description = 'join url';
    var got = _._pathJoin( paths1, options2 );
    test.contain( got, expected1 );

    test.description = 'join windows os paths';
    var got = _._pathJoin( paths2, options3 );
    test.contain( got, expected2 );

    test.description = 'join unix os paths';
    var got = _._pathJoin( paths3, options3 );
    test.contain( got, expected3 );

    test.description = 'join unix os paths with reroot';
    var got = _._pathJoin( paths4, options1 );
    test.contain( got, expected4 );

    if( Config.debug )
    {

      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _._pathJoin();
      });

      test.description = 'path element is not string';
      test.shouldThrowError( function()
      {
        _._pathJoin( [ 34 , 'foo/' ], options3 );
      });

      test.description = 'missed options';
      test.shouldThrowError( function()
      {
        _._pathJoin( paths1 );
      });

      test.description = 'options has unexpected parameters';
      test.shouldThrowError( function()
      {
        _._pathJoin( paths1, { wrongParameter: 1 } );
      });

    }


  };

  //

  var pathJoin = function( test )
  {
    var paths1 = [ 'c:\\', 'foo\\', 'bar\\' ],
      paths2 = [ '/bar/', '/baz', 'foo/', '.' ],
      expected1 = 'c:/foo/bar/',
      expected2 = '/baz/foo/';

    test.description = 'missed arguments';
    var got = _.pathJoin();
    test.contain( got, '.' );

    test.description = 'join windows os paths';
    var got = _.pathJoin.apply( _, paths1 );
    test.contain( got, expected1 );

    test.description = 'join unix os paths';
    var got = _.pathJoin.apply( _, paths2 );
    test.contain( got, expected2 );

    if( Config.debug )
    {
      test.description = 'non string passed';
      test.shouldThrowError( function()
      {
        _.pathJoin( {} );
      });
    }

  };

  //

  var pathReroot = function( test )
  {
    var paths1 = [ 'c:\\', 'foo\\', 'bar\\' ],
      paths2 = [ '/bar/', '/baz', 'foo/', '.' ],
      expected1 = 'c:/foo/bar/',
      expected2 = '/bar/baz/foo/.';

    test.description = 'missed arguments';
    var got = _.pathReroot();
    test.contain( got, '' );

    test.description = 'join windows os paths';
    var got = _.pathReroot.apply( _, paths1 );
    test.contain( got, expected1 );

    test.description = 'join unix os paths';
    var got = _.pathReroot.apply( _, paths2 );
    test.contain( got, expected2 );

    if( Config.debug )
    {
      test.description = 'non string passed';
      test.shouldThrowError( function()
      {
        _.pathReroot( {} );
      });
    }

  };

  // --
  // proto
  // --

  var Proto =
  {

    name : 'PathTest',

    tests:
    {

      _pathJoin: _pathJoin,
      pathJoin: pathJoin,
      pathReroot: pathReroot,

    },

    verbose : 1

  };

  Self.__proto__ = Proto;
  wTests[ Self.name ] = Self;
  _.testing.test( Self );

} )( );
