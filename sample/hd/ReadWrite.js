require( 'wFiles' );
var _ = wTools;

// provider

var fileProvider = _.FileProvider.HardDrive();

// path

var pathFile = _.path.join( __dirname, './dir/File.txt' );

// read file

var read = fileProvider.fileRead( pathFile );
console.log( read );

// delete file

fileProvider.fileDelete( pathFile );
