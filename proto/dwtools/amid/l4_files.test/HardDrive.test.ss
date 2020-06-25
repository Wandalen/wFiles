( function _FileProvider_HardDrive_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './aFileProvider.test.s' );

}

//

var _ = _global_.wTools;
var Parent = wTests[ 'Tools.mid.files.fileProvider.Abstract' ];

_.assert( !!Parent );

//

function onSuiteBegin( test )
{
  let context = this;

  context.provider = _.FileProvider.HardDrive({ /* protocol : 'current', */ protocols : [ 'current', 'second' ] });
  context.system = _.FileProvider.System({ providers : [ context.provider ] });
  context.system.defaultProvider = context.provider;

  context.suiteTempPath = context.provider.path.pathDirTempOpen( context.provider.path.join( __dirname, '../..'  ),'HardDrive' ); /* xxx */
  context.suiteTempPath = context.provider.pathResolveLinkFull({ filePath : context.suiteTempPath, resolvingSoftLink : 1 }); /* zzz */
  context.suiteTempPath = context.suiteTempPath.absolutePath;
  context.globalFromPreferred = function globalFromPreferred( path ){ return path };

}

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

var Proto =
{

  name : 'Tools.mid.files.fileProvider.HardDrive',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  verbosity : 3,

  // routine : 'pathResolveSoftLink',

  onSuiteBegin,

  context :
  {
    providerMake,
    provider : _.FileProvider.HardDrive(),
    suiteTempPath : null,
    globalFromPreferred : null
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
