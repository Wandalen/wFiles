( function _FileProvider_CachingStats_test_ss_( ) {

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

_.assert( Parent );

//


function simple( t )
{
  t.description = 'CachingStats test';
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileProvider.CachingStats({ originalProvider : provider });

  var path = '/path/to/file';

  var timeSingle = _.timeNow();
  provider.fileStat( path );
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    provider.fileStat( path );
  }
  console.log( _.timeSpent( 'Spent to make provider.fileStat 10k times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    filter.fileStat( path );
  }
  console.log( _.timeSpent( 'Spent to make filter.fileStat 10k times',time2-timeSingle ) );
}

//

function fileStat( t )
{
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileProvider.CachingStats({ originalProvider : provider });

  var consequence = new wConsequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    t.description = 'filter.fileStat work like original provider';
  })

  /* compare results sync*/

  .ifNoErrorThen( function()
  {
    var expected = provider.fileStat( __filename );
    var got = filter.fileStat( __filename );
    t.identical( _.objectIs( got ), true );
    t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
  })

  /*compare results async*/

  .ifNoErrorThen( function()
  {
    var expected;
    provider.fileStat({ pathFile : __filename, sync : 0 })
    .ifNoErrorThen( function( got )
    {
      expected = got;
      filter.fileStat({ pathFile : __filename, sync : 0 })
      .ifNoErrorThen( function( got )
      {
        t.identical( _.objectIs( got ), true );
        t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
      })
    });
  })


  return consequence;
}

// --
// proto
// --

var Self =
{

  name : 'FileProvider.CachingStats',

  tests :
  {
    simple : simple,
    fileStat : fileStat
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
