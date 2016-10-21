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
 },
 "test_dir" :
 {
   'test3.js' : "test\n.gitignore\n.travis.yml\nMakefile\nexample.js\n",
 }
}

//

var makePath  = function( pathFile )
{
  return pathFile;
}

//

// --
// proto
// --

var Proto =
{

  name : 'FileProvider.SimpleStructure',
  tree : tree,
  provider : _.FileProvider.SimpleStructure( { tree : tree } ),
  makePath : makePath

}

_.mapExtend( Self,Proto );
Object.setPrototypeOf( Self, Parent );

// _.assert( _.routineIs( Parent.makePath ) );
_.assert( _.routineIs( Self.makePath ) );

_global_.wTests = typeof wTests === 'undefined' ? {} : wTests;
_global_.wTests[ Self.name ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self );

} )( );
