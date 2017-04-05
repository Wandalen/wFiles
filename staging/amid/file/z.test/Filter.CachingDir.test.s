( function _FileProvider_CachingDir_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileMid.s' );

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
  t.description = 'CachingDir test';
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileFilter.Caching({ original : provider, cachingStats : 0 });

  var path = _.pathRefine( _.pathDir( _.diagnosticLocation().path ) );
  logger.log( 'path',path );

  var timeSingle = _.timeNow();
  provider.directoryRead( path );
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    provider.directoryRead( path );
  }
  logger.log( _.timeSpent( 'Spent to make provider.directoryRead 10k times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 10000; ++i )
  {
    filter.directoryRead( path );
  }
  logger.log( _.timeSpent( 'Spent to make filter.directoryRead 10k times',time2-timeSingle ) );

  t.identical( 1, 1 )
}

//

function filesFind( t )
{
  t.description = 'CachingDir filesFind';
  var provider = _.FileProvider.HardDrive();
  var filter = _.FileFilter.Caching({ original : provider, cachingStats : 0 });

  var path = _.pathRefine( _.pathDir( _.diagnosticLocation().path ) );
  logger.log( 'path',path );

  var timeSingle = _.timeNow();
  provider.filesFind({ filePath : path });
  timeSingle = _.timeNow() - timeSingle;

  var time1 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    provider.filesFind({ filePath : path });
  }
  logger.log( _.timeSpent( 'Spent to make provider.filesFind 100 times',time1-timeSingle ) );

  var time2 = _.timeNow();
  for( var i = 0; i < 100; ++i )
  {
    filter.filesFind({ filePath : path });
  }
  logger.log( _.timeSpent( 'Spent to make filter.filesFind 100 times',time2-timeSingle ) );

  t.identical( 1, 1 )
}

//

// --
// proto
// --

var Self =
{

  name : 'FileProvider.CachingDir',

  tests :
  {
    simple : simple,
    filesFind : filesFind,
  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
