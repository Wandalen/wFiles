( function _File_path_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../Files.ss' );

  var _ = wTools;

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Testing;

//

function fileRecord( test )
{

  var path = '/file/deck/minimal/minimal.coord';

  debugger;
  var r = _.fileProvider.fileRecord( path );

  test.identical( r.absolute,path );
  test.identical( r.relative,'./minimal.coord' );

  test.identical( r.ext,'coord' );
  test.identical( r.extWithDot,'.coord' );

  test.identical( r.name,'minimal' );
  test.identical( r.nameWithExt,'minimal.coord' );

}

// --
// proto
// --

var Self =
{

  name : 'FileRecord',

  tests :
  {

    fileRecord : fileRecord,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Testing.test( Self.name );

} )( );
