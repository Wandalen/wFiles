( function _FileProvider_Url_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

  var _ = wTools;

  _.include( 'wFiles' );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

// --
// proto
// --

var Self =
{

  name : 'FileProvider.BackUrl',
  sourceFilePath : sourceFilePath,
  provider : _.FileProvider.BackUrl(),
  testFile : 'https://raw.githubusercontent.com/Wandalen/wFiles/master/xxx'

}

//

if( typeof module !== 'undefined' )
Self = new wTestSuite( Parent ).extendBy( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

if( 0 )
if( isBrowser )
{
  Self = new wTestSuite( Parent ).extendBy( Self );
  _.Testing.test( Self.name );
}

})( );
