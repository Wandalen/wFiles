( function _FilesFind_Extract_test_s_( ) {

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

function providerMake()
{
  let context = this;
  let provider = _.FileProvider.Extract({ protocols : [ 'current', 'second' ] });
  let system = _.FileProvider.System({ providers : [ provider ] });
  _.assert( system.defaultProvider === null );
  return provider;
}

//

function pathFor( filePath )
{
  return '/' + filePath;
}

//

function onSuiteBegin( test )
{
  let context = this;
  Parent.onSuiteBegin.apply( this, arguments );
  context.provider = _.FileProvider.Extract({ usingExtraStat : 1, protocol : 'current' });
  context.system = _.FileProvider.System({ providers : [ context.provider ] });
  context.suiteTempPath = context.provider.path.pathDirTempOpen( 'suite-' + 'FilesFind' );
}

//

function onSuiteEnd()
{
  let context = this;
  let path = this.provider.path;
  _.assert( _.mapKeys( context.provider.filesTree ).length === 1, context.provider.filesTree );
  return Parent.onSuiteEnd.apply( this, arguments );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.FilesFind.Extract',
  silencing : 1,
  abstract : 0,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    providerMake,
    pathFor,
    testFile : '/file1',
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
