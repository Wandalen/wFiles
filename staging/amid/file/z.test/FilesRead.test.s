( function _Files_read_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( '../../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  require( '../FileMid.s' );

  _.include( 'wTesting' );

}

//

var _ = wTools;
var Parent = wTools.Tester;

// --
// read
// --

function filesRead( test )
{

  test.description = 'basic';

  var files = _.fileProvider.filesGlob({ glob : _.pathRegularize( __dirname ) + '/**' });
  var read = _.fileProvider.filesRead({ paths : files, preset : 'js' });

  debugger;

  test.shouldBe( read.errs.length === 0 );
  test.shouldBe( read.err === undefined );
  test.shouldBe( _.arrayIs( read.read ) );
  test.shouldBe( _.strIs( read.data ) );
  test.shouldBe( read.data.indexOf( '======\n( function()' ) !== -1 );

  debugger;
}

// --
// proto
// --

var Self =
{

  name : 'FilesRead',
  silencing : 1,
  // verbosity : 7,

  tests :
  {

    filesRead : filesRead,

  },

}

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
