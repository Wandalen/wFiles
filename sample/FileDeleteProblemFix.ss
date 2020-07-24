
var _ = require( '..')
var fs = require( 'fs' );
var path = require( 'path' );

var terminalPath = path.join( __dirname, 'terminal' );
var tempPath = path.join( __dirname, 'tempFile' );

/* Problem : file will be removed only when all fd's are closed, unlink marks file for deletion */

/* solution rename + unlink */

var fd = fs.openSync( terminalPath, 'w+' );
fs.renameSync( terminalPath,tempPath );
fs.unlinkSync( tempPath );
console.log( 'Original exists after combination:', _.fileProvider.fileExists( terminalPath ) );
fs.closeSync( fd );
console.log( 'Temp exists after fd is closed:', _.fileProvider.fileExists( terminalPath ) );


