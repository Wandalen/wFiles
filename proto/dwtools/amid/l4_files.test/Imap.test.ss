( function _Imap_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../dwtools/Tools.s' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Files.s' );
  require( '../files/l7_provider/Imap.ss' );

}

var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;

  // context.providerSrc = _.FileProvider.Imap();
  // context.providerDst = _.FileProvider.HardDrive();
  // context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });

  context.suiteTempPath = _.fileProvider.path.pathDirTempOpen( _.fileProvider.path.join( __dirname, '../..'  ), 'FileProviderImap' );

}

//

function onSuiteEnd( test )
{
  let context = this;
  _.fileProvider.path.pathDirTempClose( context.suiteTempPath );
}

// --
// tests
// --

function basic( test )
{
  let context = this;

  var imap = _.FileProvider.Imap( context.cred );
  var hd = _.FileProvider.HardDrive();
  var extract = _.FileProvider.Extract({ protocols : [ 'extract' ] });
  var system = _.FileProvider.System({ providers : [ imap, hd, extract ] });

  var exp = [ 'x' ];
  var got = imap.dirRead( '/' );
  test.identical( got, exp );

  imap.ready.finally( () => imap.unform() );

  return imap.ready;
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.Imap',
  silencing : 1,
  routineTimeOut : 60000,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
    cred :
    {
      login : 'job@01.school',
      password : 'BrainsForSale8787',
      hostUri : 'imap.openxchange.eu:993',
    }
  },

  tests :
  {

    basic,

  },

}

//

var Self = new wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
