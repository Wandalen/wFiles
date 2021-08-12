( function _Namespace_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );
  _.include( 'wTesting' );
  require( '../l4_files/entry/Files.s' );
}

const _ = _global_.wTools;

// --
// tests
// --

function currentAtBeginGet( test )
{
  const a = test.assetFor( false );
  const program = a.program( testApp );

  /* - */

  a.shell( `node ${ a.path.nativize( program.filePath ) }` );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Before : undefined' ), 1 );
    test.identical( _.strCount( op.output, `After : ${ a.abs( '.' ) }` ), 1 );
    return null;
  });

  /* - */

  return a.ready;

  /* */

  function testApp()
  {
    const _ = require( toolsPath );

    console.log( `Before : ${ _.path.currentAtBeginGet }` );
    _.include( 'wFiles' );
    console.log( `After : ${ _.path.currentAtBeginGet() }` );
  }
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.Namespace',
  silencing : 1,

  tests :
  {
    currentAtBeginGet,
  },
};

//

const Self = wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
