( function _FilesFind_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFilesFind.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools.mid.files.FilesFind.Abstract' ];

_.assert( !!Parent );

//

function onSuiteBegin( test ) /* qqq2 : review all onSuite* */
{
  let context = this;
  context.provider = _.FileProvider.HardDrive({ protocol : 'current' });
  context.system = _.FileProvider.System({ providers : [ context.provider ], defaultProvider : context.provider });
  context.suiteTempPath = context.provider.path.pathDirTempOpen( context.provider.path.join( __dirname, '../..'  ), 'suite-' + 'FilesFind' );
}

//
// //
//
// function onSuiteEnd()
// {
//   let path = this.provider.path;
//   _.assert( _.strHas( this.suiteTempPath, 'Provider/HardDrive' ) );
//   path.pathDirTempClose( this.suiteTempPath );
// }

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.FilesFind.HardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  // verbosity : 4,

  // routine : 'pathResolveTextLink',

  onSuiteBegin,
  // onSuiteEnd,

  context :
  {
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
