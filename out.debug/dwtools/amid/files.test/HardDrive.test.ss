( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools/mid/files/fileProvider/Abstract' ];

_.assert( !!Parent );

//

function onSuiteBegin( test )
{
  let path = this.provider.path;
  this.testRootDirectory = path.dirTempOpen( path.join( __dirname, '../..'  ), 'Provider/HardDrive' );
}

//

function onSuiteEnd()
{
  let path = this.provider.path;
  // qqq : error here
  // aaa : format of temp path was changed and has unique id at the end
  _.assert( _.strHas( this.testRootDirectory, 'Provider/HardDrive' ) );
  path.dirTempClose( this.testRootDirectory );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/HardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  verbosity : 4,

  // routine : 'pathResolveSoftLink',

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    provider : _.FileProvider.HardDrive(),
    onSuiteBegin : onSuiteBegin,
    testRootDirectory : null,
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
