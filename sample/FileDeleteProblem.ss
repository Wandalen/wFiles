
var _ = require( '..' );
var fs = require( 'fs' );
var path = require( 'path' );

var terminalPath = path.join( __dirname, 'terminal' );

/* Problem : file will be removed only when all fd's are closed, unlink marks file for deletion */

// _.fileProvider.fileExists because stat fails with EPERM

var fd = fs.openSync( terminalPath, 'w+' );
console.log( 'unlink:' )
fs.unlinkSync( terminalPath );
console.log( 'File exists after unlink:', _.fileProvider.fileExists( terminalPath ) );
fs.closeSync( fd );
console.log( 'File exists after fd is closed:', _.fileProvider.fileExists( terminalPath ) );




