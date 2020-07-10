require( 'wFiles' );
var _ = wTools;

// provider

var fileProvider = _.FileProvider.HardDrive();

// path

var pathFile = _.path.join( _.path.current(), './dir/File.txt' );

// create file

fileProvider.fileWrite( pathFile, 'Hello, world' );

console.log( record );
