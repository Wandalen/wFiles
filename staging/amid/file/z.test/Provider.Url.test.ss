( function _FileProvider_Url_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests[ 'FileProvider' ];

_.assert( Parent );

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.BackUrl',
  silencing : 1,
  abstract : 0,

  context :
  {
    provider : _.FileProvider.BackUrl(),
    testFile : 'https://raw.githubusercontent.com/Wandalen/wFiles/master/xxx'
  },

  tests :
  {
  },

}

//

// debugger;
// if( typeof module !== 'undefined' )
// var Self = new wTestSuite( Parent ).extendBy( Proto );

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

if( 0 )
if( isBrowser )
{
  Self = new wTestSuite( Parent ).extendBy( Self );
  _.Tester.test( Self.name );
}

})( );
