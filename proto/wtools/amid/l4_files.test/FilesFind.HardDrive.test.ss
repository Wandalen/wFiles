( function _FilesFind_HardDrive_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFilesFind.test.s' );

}

//

const _ = _global_.wTools;
const Parent = wTests[ 'Tools.files.FilesFind.Abstract' ];

_.assert( !!Parent );

//

function onSuiteBegin( test ) /* qqq2 : review all onSuite* */
{
  let context = this;
  context.provider = _.FileProvider.HardDrive({ protocol : 'current' });
  context.system = _.FileProvider.System({ providers : [ context.provider ], defaultProvider : context.provider });
  context.suiteTempPath = context.provider.path.tempOpen( context.provider.path.join( __dirname, '../..'  ), 'suite-' + 'FilesFind' );
}

//
// //
//
// function onSuiteEnd()
// {
//   let path = this.provider.path;
//   _.assert( _.strHas( this.suiteTempPath, 'Provider/HardDrive' ) );
//   path.tempClose( this.suiteTempPath );
// }

//

function providerMake()
{
  let context = this;
  let provider = _.FileProvider.HardDrive({ protocols : [ 'current', 'second' ] });
  let system = _.FileProvider.System({ providers : [ provider ] });
  _.assert( system.defaultProvider === null );
  return provider;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.FilesFind.HardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  // verbosity : 4,

  // routine : 'pathResolveTextLink',

  onSuiteBegin,
  // onSuiteEnd,

  context :
  {
    providerMake,
  },

  tests :
  {
  },

}

//

const Self = wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
