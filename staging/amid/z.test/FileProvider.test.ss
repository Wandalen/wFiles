( function _FileProvider_test_ss_( ) {

'use strict';

if( typeof module !== undefined )
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

  require( '../file/Files.ss' );

  var File = require( 'fs-extra' );
  var Path = require( 'path' );

}

//

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;

var _ = wTools;
var tree =
{
 "folder.abc" :
 {
   'test1.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
   'test2' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   'folder2.x' :
   {
     'test1.txt' : "var concatMap = require('concat-map');\nvar balanced = require('balanced-match');",
   }
 }
}
var HardDrive = _.FileProvider.HardDrive();
var SimpleStructure = _.FileProvider.SimpleStructure( { tree : tree } );
var provider = HardDrive;
var Self = {};

var testRootDirectory = './tmp/FileProvider';

//

function createTestsDirectory( path, rmIfExists )
{
  rmIfExists && File.existsSync( path ) && File.removeSync( path );
  return File.mkdirsSync( path );
}

//

function createInTD( path )
{
  return createTestsDirectory( Path.join( testRootDirectory, path ) );
}

//

function createTestFile( path, data, decoding )
{
  var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
  File.createFileSync( Path.join( testRootDirectory, path ) );
  dataToWrite && File.writeFileSync( Path.join( testRootDirectory, path ), dataToWrite );
}


function getLstat( path )
{
  var stats;
  try
  {
    stats = File.lstatSync( path );
  }
  catch ( error )
  {
  }
  return stats;
}

//

var testDelaySample = function testDelaySample( test )
{

  debugger;

  test.description = 'delay test';

  var con = _.timeOut( 1000 );

  test.identical( 1,1 );

  con.then_( function( ){ logger.log( '1000ms delay' ) } );

  con.then_( _.routineSeal( _,_.timeOut,[ 1000 ] ) );

  con.then_( function( ){ logger.log( '2000ms delay' ) } );

  con.then_( function( ){ test.identical( 1,1 ); } );

  return con;
}


//

var makePath  = function ( pathFile )
{
  if( provider === HardDrive )
  {
    return _.pathJoin( testRootDirectory,  pathFile );
  }
  if( provider === SimpleStructure )
  {
    return  pathFile;
  }
}


//

var readWrite = function ( test )
{
  test.description = 'syncronous';
  var data = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  provider.fileWriteAct(
    {
      pathFile : makePath( 'test.txt' ),
      data : data,
      sync : 1
    } );
  var got = provider.fileReadAct(
    {
      pathFile : makePath( 'test.txt' ),
      sync : 1
    } );
  var expected = data;
  test.identical( got, expected );
}


// --
// proto
// --

var Proto =
{

  name : 'FileProvider',

  tests :
  {
    readWrite : readWrite
    // testDelaySample : testDelaySample,

  },

  verbose : 0,

};

debugger;

Self.__proto__ = Proto;
wTests[ Self.name ] = Self;

createTestsDirectory( testRootDirectory, 1 );
_.testing.test( Self );

} )( );
