( function _Npm_test_ss_( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Files.s' );
}

var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Http();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });

  context.suiteTempPath = _.fileProvider.path.tempOpen( _.fileProvider.path.join( __dirname, '../..' ), 'FileProviderHttp' );
}

//

function onSuiteEnd( test )
{
  let context = this;
  _.fileProvider.path.tempClose( context.suiteTempPath );
}

// --
// tests
// --

function fileReadActSync( test )
{
  const context = this;
  const provider = _.FileProvider.Http();

  /* */

  let ready = new _.Consequence().take( null )

  ready

  .then( () =>
  {
    test.case = 'encoding : utf8';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json'
    var got = provider.fileRead({ filePath : url, encoding : 'utf8', sync : 1 });
    test.identical( _.strIs( got ), true );
    return null;
  });

  return ready;
}


// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.Http',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  verbosity : 4,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
    providerSrc : null,
    providerDst : null,
    system : null
  },

  tests :
  {
    fileReadActSync,
  },

}

//

var Self = new wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
