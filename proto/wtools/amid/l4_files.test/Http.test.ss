( function _FileProvider_Http_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Files.s' );
}

//

const _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Http();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });
  context.system.defaultProvider = context.providerDst;

  context.suiteTempPath = context.providerDst.path.tempOpen( context.providerDst.path.join( __dirname, '../..'  ), 'FileProviderHttp' );

}

//

function onSuiteEnd( test )
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, 'FileProviderHttp' ), context.suiteTempPath );
  context.providerDst.path.tempClose( context.suiteTempPath );
}

// --
// tests
// --

function streamReadProviderWithoutSystem( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );
  a.fileProvider.dirMake( a.abs( '.' ) );

  /* */

  a.ready.then( () =>
  {
    test.case = 'regular http path';
    var con = new _.Consequence();

    var providerSrc = _.FileProvider.Http();
    var providerDst = _.FileProvider.HardDrive();

    var dstPath = a.abs( 'ModuleForTesting1.s' );
    var writeStream = providerDst.streamWrite({ filePath : dstPath });
    writeStream.on( 'finish', () => writeStream.close( () => con.take( null ) ) );

    var filePath = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/proto/wtools/testing/l1/ModuleForTesting1.s';
    var readStream = providerSrc.streamRead({ filePath });
    readStream.on( 'header', ( statusCode ) =>
    {
      if( statusCode === 200 )
      readStream.pipe( writeStream );
    });

    con.then( () =>
    {
      return providerDst.filesReflectEvaluate
      ({
        src : { filePath : dstPath },
        dst : { filePath : dstPath },
      });
    });

    return con;
  });

  a.ready.then( ( op ) =>
  {
    var got = a.fileProvider.fileExists( a.abs( 'ModuleForTesting1.s' ) );
    test.true( got );
    var got = a.fileProvider.fileRead( a.abs( 'ModuleForTesting1.s' ) );
    test.ge( got.length, 200 );

    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'global http path';
    var con = new _.Consequence();

    var providerSrc = _.FileProvider.Http();
    var providerDst = _.FileProvider.HardDrive();

    var dstPath = a.abs( 'ModuleForTesting1.s' );
    var writeStream = providerDst.streamWrite({ filePath : dstPath });
    writeStream.on( 'finish', () => writeStream.close( () => con.take( null ) ) );

    var filePath = 'https:///raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/proto/wtools/testing/l1/ModuleForTesting1.s';
    var readStream = providerSrc.streamRead({ filePath });
    readStream.on( 'header', ( statusCode ) =>
    {
      if( statusCode === 200 )
      readStream.pipe( writeStream );
    });

    con.then( () =>
    {
      return providerDst.filesReflectEvaluate
      ({
        src : { filePath : dstPath },
        dst : { filePath : dstPath },
      });
    });

    return con;
  });

  a.ready.then( ( op ) =>
  {
    var got = a.fileProvider.fileExists( a.abs( 'ModuleForTesting1.s' ) );
    test.true( got );
    var got = a.fileProvider.fileRead( a.abs( 'ModuleForTesting1.s' ) );
    test.ge( got.length, 200 );

    return null;
  });

  return a.ready;
}

//

function streamReadProviderWithSystem( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );
  a.fileProvider.dirMake( a.abs( '.' ) );

  /* */

  a.ready.then( () =>
  {
    test.case = 'regular http path';
    var con = new _.Consequence();

    var dstPath = a.abs( 'ModuleForTesting1.s' );
    var writeStream = context.providerDst.streamWrite({ filePath : dstPath });
    writeStream.on( 'finish', () => writeStream.close( () => con.take( null ) ) );

    var filePath = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/proto/wtools/testing/l1/ModuleForTesting1.s';
    var readStream = context.providerSrc.streamRead({ filePath });
    readStream.on( 'header', ( statusCode ) =>
    {
      if( statusCode === 200 )
      readStream.pipe( writeStream );
    });

    con.then( () =>
    {
      return context.providerDst.filesReflectEvaluate
      ({
        src : { filePath : dstPath },
        dst : { filePath : dstPath },
      });
    });

    return con;
  });

  a.ready.then( ( op ) =>
  {
    var got = a.fileProvider.fileExists( a.abs( 'ModuleForTesting1.s' ) );
    test.true( got );
    var got = a.fileProvider.fileRead( a.abs( 'ModuleForTesting1.s' ) );
    test.ge( got.length, 200 );

    return null;
  });

  /* */

  a.ready.then( () =>
  {
    test.case = 'global http path';
    var con = new _.Consequence();

    var dstPath = a.abs( 'ModuleForTesting1.s' );
    var writeStream = context.providerDst.streamWrite({ filePath : dstPath });
    writeStream.on( 'finish', () => writeStream.close( () => con.take( null ) ) );

    var filePath = 'https:///raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/proto/wtools/testing/l1/ModuleForTesting1.s';
    var readStream = context.providerSrc.streamRead({ filePath });
    readStream.on( 'header', ( statusCode ) =>
    {
      if( statusCode === 200 )
      readStream.pipe( writeStream );
    });

    con.then( () =>
    {
      return context.providerDst.filesReflectEvaluate
      ({
        src : { filePath : dstPath },
        dst : { filePath : dstPath },
      });
    });

    return con;
  });

  a.ready.then( ( op ) =>
  {
    var got = a.fileProvider.fileExists( a.abs( 'ModuleForTesting1.s' ) );
    test.true( got );
    var got = a.fileProvider.fileRead( a.abs( 'ModuleForTesting1.s' ) );
    test.ge( got.length, 200 );

    return null;
  });

  return a.ready;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.Http',
  silencing : 1,
  enabled : 1,

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
    streamReadProviderWithoutSystem,
    streamReadProviderWithSystem,
  },

}

//

const Self = wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
