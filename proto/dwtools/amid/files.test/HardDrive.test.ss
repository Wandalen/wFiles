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

// //
//
// function onSuiteBegin( test )
// {
//   let path = this.provider.path;
//   this.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'Provider/HardDrive' );
// }
//
// //
//
// function onSuiteEnd()
// {
//   let path = this.provider.path;
//   // qqq : error here
//   // aaa : format of temp path was changed and has unique id at the end
//   _.assert( _.strHas( this.suiteTempPath, 'Provider/HardDrive' ) );
//   path.pathDirTempClose( this.suiteTempPath );
// }

//

function onSuiteBegin( test )
{
  let context = this;

  context.provider = _.FileProvider.HardDrive({ /* protocol : 'current', */ protocols : [ 'current', 'second' ] });
  context.system = _.FileProvider.System({ providers : [ context.provider ] });
  context.system.defaultProvider = context.provider;

  let path = context.provider.path;
  context.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ),'HardDrive' );
  context.suiteTempPath = context.provider.pathResolveLinkFull({ filePath : context.suiteTempPath, resolvingSoftLink : 1 });
  context.suiteTempPath = context.suiteTempPath.absolutePath;
  context.globalFromPreferred = function globalFromPreferred( path ){ return path };
  // let path = this.provider.path;
  // this.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'Provider/HardDrive' );
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
    provider : _.FileProvider.HardDrive(),
    // onSuiteBegin,
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
