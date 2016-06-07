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

  var urlParse = function( test )
  {
    var options = 
      {
        atomicOnly: true
      },

      url1 = 'http://www.site.com:13/path/name?query=here&and=here#anchor',

      expected1 =
      {
        protocol: 'http',
        host: 'www.site.com',
        port: '13',
        pathname: '/path/name',
        query: 'query=here&and=here',
        hash: 'anchor',

        hostname: 'www.site.com:13',
        origin: 'http://www.site.com:13'
      },
      expected2 =
      {
        protocol: 'http',
        host: 'www.site.com',
        port: '13',
        pathname: '/path/name',
        query: 'query=here&and=here',
        hash: 'anchor'
      };

    // TODO: tests failed, please check actuality

    test.description = 'full url with all components';
    var got = _.urlParse( url1 );
    test.contain( got, expected1 );

    test.description = 'full url with all components, atomicOnly';
    var got = _.urlParse( url1, options );
    test.contain( got, expected2 );

    if( Config.debug )
    {

      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.urlParse();
      });

      test.description = 'argument is not string';
      test.shouldThrowError( function()
      {
        _.urlParse( 34 );
      });

    }


  };

  //

  var urlMake = function( test )
  {
    var url = 'http://www.site.com:13/path/name?query=here&and=here#anchor',
      components0 =
      {
        url: url
      },
      components1 =
      {
        protocol: 'http',
        host: 'www.site.com',
        port: '13',
        pathname: '/path/name',
        query: 'query=here&and=here',
        hash: 'anchor',
      },
      components2 =
      {
        pathname: '/path/name',
        query: 'query=here&and=here',
        hash: 'anchor',

        origin: 'http://www.site.com:13'
      },
      components3 =
      {
        protocol: 'http',
        pathname: '/path/name',
        query: 'query=here&and=here',
        hash: 'anchor',

        hostname: 'www.site.com:13'
      },
      expected1 = url;

    test.description = 'make url from components url';
    var got = _.urlMake( components0 );
    test.contain( got, expected1 );

    test.description = 'make url from atomic components';
    var got = _.urlMake( components1 );
    test.contain( got, expected1 );

    test.description = 'make url from composites components: origin';
    var got = _.urlMake( components2 );
    test.contain( got, expected1 );

    test.description = 'make url from composites components: hostname';
    var got = _.urlMake( components3 );
    test.contain( got, expected1 );

    //

    if( Config.debug )
    {

      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.urlMake();
      });

      test.description = 'argument is not url component object';
      test.shouldThrowError( function()
      {
        _.urlMake( url );
      });

    }
  };

  // --
  // proto
  // --

  var Proto =
  {

    name : 'PathUrlTest',

    tests:
    {

      urlParse: urlParse,
      urlMake : urlMake

    },

    verbose : 0

  };

  Self.__proto__ = Proto;
  wTests[ Self.name ] = Self;
  _.testing.test( Self );

} )( );
