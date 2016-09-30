( function _Deployer_test_s_( ) {

'use strict';

/*

to run this test
from the project directory run

npm install
node ./amid/z.test/Deployer.test.s

*/

if( typeof module !== 'undefined' )
{

  require( 'wTools' );


  if( require( 'fs' ).existsSync( __dirname + '/../../amid/diagnostic/Testing.debug.s' ) )
  require( '../../amid/diagnostic/Testing.debug.s' );
  else
  require( 'wTesting' );

}

var _ = wTools;
var deployer = require( '../deployer/Deployer.ss' )(  );
var fs = require('fs');
var Self = {};


var path = __dirname + '/../../../file.test/';

//

var DeployerTest = function( test )
{

  test.description = 'single file path as string ';
  deployer.read( path + 'file.s' );
  deployer.writeToJson(  path + 'file.json' );
  var got = deployer._tree;
  deployer.readFromJson( path + 'file.json' );
  var expected = deployer._tree;
  test.identical( got,expected );

  test.description = 'single file, path like map property ';
  deployer.read( { pathFile : path + 'file.s' } );
  deployer.writeToJson(  { pathFile : path + 'file.json'} );
  var got = deployer._tree;
  deployer.readFromJson( { pathFile : path + 'file.json'} );
  var expected = deployer._tree;
  test.identical( got,expected );


  /**/

  if( Config.debug )
  {

    test.description = 'read : incorrect argument type';
    test.shouldThrowError( function()
    {
      deployer.read( 1 )
    });

    test.description = 'writeToJson : incorrect argument type';
    test.shouldThrowError( function()
    {
      deployer.writeToJson( 0 )
    });



  }
}

//

var Proto =
{

  name : 'Deployer test',

  tests :
  {

    DeployerTest : DeployerTest,


  }

}

_.mapExtend( Self,Proto );

if( typeof module !== 'undefined' && !module.parent )
_.testing.test( Self );

} )( );
