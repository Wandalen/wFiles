( function _FileProvider_HardDrive_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../file/Files.ss' );
  require( './FileProvider.test.s' );

}

//

var _ = wTools;
var Parent = wTests.FileProvider;
var Self = {};

//

var makePath  = function( pathFile )
{
  return _.pathJoin( this.testRootDirectory,  pathFile );
}

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.HardDrive',

  testRootDirectory : __dirname + '/../../../tmp.tmp/hard-drive',
  provider : _.FileProvider.HardDrive(),
  makePath : makePath,
  testFile : __dirname + '/../../../LICENSE'

}

_.mapExtend( Self,Proto );
Object.setPrototypeOf( Self, Parent );

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;
_global_.wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
