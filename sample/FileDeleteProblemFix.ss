
var _ = require( '..')
var fs = require( 'fs' );
var path = require( 'path' );

var testPath = path.join( __dirname, 'testPath' );
var terminalPath = path.join( testPath, 'terminal' );
var tempPath = path.join( testPath, 'tempFile' );

if( !fs.statSync( testPath ) )
fs.mkdirSync( testPath );
fs.writeFileSync( terminalPath, terminalPath );

/* Problem : file will be removed only when all fd's are closed, unlink marks file for deletion */

var fd = fs.openSync( terminalPath, 'r+' );

/* solution rename + unlink */

console.log( 'rename + unlink:' );
fs.renameSync( terminalPath,tempPath );
fs.unlinkSync( tempPath );
console.log( 'Original file exists:', fileExists( terminalPath ) );
console.log( 'Temp file exists:', fileExists( tempPath ) );
console.log( '\nclose fd:' );
fs.closeSync( fd );
console.log( 'Original file exists:', fileExists( terminalPath ) );
console.log( 'Temp file exists:', fileExists( tempPath ) );

/* */

function fileExists( filePath )
{
  try
  {
    fs.accessSync( filePath, fs.constants.F_OK );
  }
  catch( err )
  {
    if( err.code === 'ENOENT' )
    return false;
    if( err.code === 'ENOTDIR' )
    return false;
  }
  return true;
}



