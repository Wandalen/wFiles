( function _FileProviderBackUrl_s_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../file/Files.ss' );
  require( './FileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests.FileProvider;
var Self = {};

//

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.BackUrl',

  provider : _.FileProvider.BackUrl(),
  testFile : 'https://raw.githubusercontent.com/Wandalen/wFiles/master/LICENSE'

}

_.mapExtend( Self,Proto );
Object.setPrototypeOf( Self, Parent );

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;
_global_.wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
