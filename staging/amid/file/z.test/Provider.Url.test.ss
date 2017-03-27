( function _FileProvider_Url_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

  var _ = wTools;

}

//

var _ = wTools;
var Parent = wTests[ 'FileProvider' ];
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

_.assert( Parent );

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.BackUrl',
  sourceFilePath : sourceFilePath,
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

debugger;
if( typeof module !== 'undefined' )
var Self = new wTestSuite( Parent ).extendBy( Proto );

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

if( 0 )
if( isBrowser )
{
  Self = new wTestSuite( Parent ).extendBy( Self );
  _.Testing.test( Self.name );
}

})( );
