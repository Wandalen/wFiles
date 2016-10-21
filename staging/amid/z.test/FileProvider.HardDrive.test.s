( function _FileProvider_HardDrive_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../ServerTools.ss' );
  }
  catch( err )
  {
  }

  try
  {
    require( '../../wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  require( 'wTesting' );
  //require( '../../../../wTesting/staging/abase/object/Testing.debug.s' );

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
  makePath : makePath

}

_.mapExtend( Self,Proto );
Object.setPrototypeOf( Self, Parent );

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;
_global_.wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
