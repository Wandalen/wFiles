if( typeof module !== 'undefined' )
{
  require( 'wTools' )
  require( '../staging/amid/file/Files.ss' )
}

var _ = wTools;

var provider = _.FileProvider.HardDrive();
var filter = _.FileProvider.CachingStats({ originalProvider : provider });

var timeSingle = _.timeNow();
provider.fileStat({ pathFile : __filename });
timeSingle = _.timeNow() - timeSingle;

var time = _.timeNow();
for( var i = 0; i < 10000; ++i )
{
  filter.fileStat( { pathFile : __filename, useNativePath : 1 } )
}
console.log( _.timeSpent( 'Spent to make filter.fileStat 10k times, using native path',time-timeSingle ) );

var time = _.timeNow();
for( var i = 0; i < 10000; ++i )
{
  filter.fileStat( { pathFile : __filename, useNativePath : 0 } )
}
console.log( _.timeSpent( 'Spent to make filter.fileStat 10k time, using refined path',time-timeSingle ) );

/*
Results on windows 7 x64 node -v v7.7.3:

Spent to make filter.fileStat 10k times, native path : 0.009s
Spent to make filter.fileStat 10k time, refined path : 0.166s
*/
