( function _FilesFind_HardDrive_test_ss_( ) {

'use strict'; 

if( typeof module !== 'undefined' )
{

  require( './aFilesFind.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools/mid/files/FilesFind/Abstract' ];

_.assert( !!Parent );

//

function onSuiteBegin( test )
{
  let context = this;
  context.provider = _.FileProvider.HardDrive({ protocol : 'current' });
  context.hub = _.FileProvider.Hub({ providers : [ context.provider ], defaultProvider : context.provider });
  let path = context.provider.path;
  context.testSuitePath = path.dirTempOpen( 'suite-' + 'FilesFind' );
  context.testSuitePath = context.provider.pathResolveLinkFull({ filePath : context.testSuitePath, resolvingSoftLink : 1 });
}

//
// //
//
// function onSuiteEnd()
// {
//   let path = this.provider.path;
//   _.assert( _.strHas( this.testSuitePath, 'Provider/HardDrive' ) );
//   path.dirTempClose( this.testSuitePath );
// }

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/FilesFind/HardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  // verbosity : 4,

  // routine : 'pathResolveTextLink',

  onSuiteBegin,
  // onSuiteEnd,

  context :
  {
    // provider : null,
    // onSuiteBegin : onSuiteBegin,
    testSuitePath : null,
  },

  tests :
  {
  },

}

//

var Self = new wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
