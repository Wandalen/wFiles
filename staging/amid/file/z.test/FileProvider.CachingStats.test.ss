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

  var path = _.pathRefine( _.diagnosticLocation().path );
  logger.log( 'path',path );

  var timeSingle = _.timeNow();
  provider.fileStat( path );
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    provider.fileStat( path );
  }
  logger.log( _.timeSpent( 'Spent to make provider.fileStat 10k times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    filter.fileStat( path );
  }
  logger.log( _.timeSpent( 'Spent to make filter.fileStat 10k times',time2-timeSingle ) );
}

//

function fileStat( t )
{
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileProvider.CachingStats({ originalProvider : provider });
  var path = _.pathRefine( _.diagnosticLocation().path );
  logger.log( 'path',path );

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
    var expected = provider.fileStat( path );
    var got = filter.fileStat( path );
    t.identical( _.objectIs( got ), true );
    t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
  })

  /*compare results async*/

  .ifNoErrorThen( function()
  {
    var expected;
    provider.fileStat({ pathFile : path, sync : 0 })
    .ifNoErrorThen( function( got )
    {
      expected = got;
      filter.fileStat({ pathFile : path, sync : 0 })
      .ifNoErrorThen( function( got )
      {
        t.identical( _.objectIs( got ), true );
        t.identical( [ got.dev, got.size, got.ino ], [ expected.dev, expected.size, expected.ino ] );
      })
    });
  })

  /*path not exist in file system, default setting*/

  .ifNoErrorThen( function()
  {
    var expected = provider.fileStat( 'invalid path' );
    var got = filter.fileStat( 'invalid path' );
    t.identical( got, expected );
  })

  /*path not exist in file system, sync, throwing enabled*/

  .ifNoErrorThen( function()
  {
    t.shouldThrowErrorSync( function()
    {
      filter.fileStat({ pathFile : 'invalid path', sync : 1, throwing : 1 });
    });
  })

  /*path not exist in file system, async, throwing disabled*/

  .ifNoErrorThen( function()
  {
    var expected;
    provider.fileStat({ pathFile : 'invalid path', sync : 0, throwing : 0 })
    .ifNoErrorThen( function( got )
    {
      expected  = got;
      filter.fileStat({ pathFile : 'invalid path', sync : 0, throwing : 0 })
      .ifNoErrorThen( function( got )
      {
        t.identical( got, expected );
      })
    });
  })

  /*path not exist in file system, async, throwing enabled*/

  .ifNoErrorThen( function()
  {
    var con = filter.fileStat({ pathFile : 'invalid path', sync : 0, throwing : 1 });
    return t.shouldThrowErrorAsync( con );
  })


  return consequence;
}

//

function filesFind( t )
{
  var provider = _.FileProvider.HardDrive();
  var path = _.pathRefine( _.pathDir( _.diagnosticLocation().path ) );
  var filter = _.FileProvider.CachingStats({ originalProvider : provider });
  logger.log( 'path',path );

  t.description = 'filesFind test';

  var timeSingle = _.timeNow();
  provider.filesFind
  ({
    pathFile : path,
  });
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    provider.filesFind
    ({
      pathFile : path,
    });
  }
  logger.log( _.timeSpent( 'Spent to make provider.filesFind 100 times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    filter.filesFind
    ({
      pathFile : path,
    });
  }
  logger.log( _.timeSpent( 'Spent to make filter.filesFind 100 times',time2-timeSingle ) );

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
    fileStat : fileStat,
    filesFind : filesFind,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
