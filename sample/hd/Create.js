require( 'wFiles' );
var _ = wTools;

// provider

var fileProvider = _.FileProvider.HardDrive();

// path

var pathFile = _.path.join( _.path.current(), './dir/File.txt' );

// create file

var record = fileProvider.fileWrite(  pathFile, 'Hello, world' );

