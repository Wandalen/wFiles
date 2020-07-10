if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

//directoryRead sync

var content = files.dirRead({ filePath : `${__dirname}/../data` });
console.log( 'read dir sync: ', content );

// directoryRead async

var con = files.dirRead({ filePath : `${__dirname}/../data`, sync : 0 });
con.got( ( content ) => console.log( 'read dir async: ', content ) );
