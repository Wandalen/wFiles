( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../Files.ss' );

  var _ = wTools;

  _.include( 'wTesting' );

  // console.log( '_.fileProvider :',_.fileProvider );

}

//

var _ = wTools;
var Parent = wTools.Testing;
var sourceFilePath = _.diagnosticLocation().full; // typeof module !== 'undefined' ? __filename : document.scripts[ document.scripts.length-1 ].src;

_.assert( Parent );

//


function simple( t )
{
  t.description = 'CachingStats test';
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileProvider.CachingStats({ originalProvider : provider });

  var time1 = _.timeNow();
  for( var i = 0; i < 1000; ++i )
  {
    provider.fileStat( __filename );
  }
  console.log( _.timeSpent( 'Spent to make provider.fileStat 1k times',time1 ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 1000; ++i )
  {
    filter.fileStat( __filename );
  }
  console.log( _.timeSpent( 'Spent to make filter.fileStat 1k times',time2 ) );

  t.identical( time2 < time1, true );
}

// --
// proto
// --

var Self =
{

  name : 'FileProvider.CachingStats',
  sourceFilePath : sourceFilePath,
  verbosity : 1,

  tests :
  {
    simple : simple,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
