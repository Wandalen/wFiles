( function _FileProvider_Http_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../dwtools/Tools.s' );

  _.include( 'wTesting' );

  require( '../files/UseTop.s' );
}

//

var _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Http();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });
  context.system.defaultProvider = context.providerDst;

  let path = context.providerDst.path;

  context.suitePath = path.pathDirTempOpen( path.join( __dirname, '../..'  ),'FileProviderHttp' );
  context.suitePath = context.providerDst.pathResolveLinkFull({ filePath : context.suitePath, resolvingSoftLink : 1 });
  context.suitePath = context.suitePath.absolutePath;
}

function onSuiteEnd( test )
{
  let context = this;
  let path = context.providerDst.path;
  _.assert( _.strHas( context.suitePath, 'FileProviderHttp' ), context.suitePath );
  path.pathDirTempClose( context.suitePath );
}

// --
// tests
// --

function filesReflectTrivial( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let testPath = path.join( context.suitePath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'README.md' );
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );
  let localPath2 = path.join( testPath, 'README2.md' );
  let clonePathGlobal2 = providerDst.path.globalFromPreferred( localPath2 );

  let con = new _.Consequence().take( null )

  /* - */

  .then( () =>
  {
    test.case = 'reflect single file, url doesn\'t exist';
    providerDst.filesDelete( localPath );
    let remotePath = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README';
    let con = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
    return test.shouldThrowErrorAsync( con );
  })
  .then( ( got ) =>
  {
    test.is( !providerDst.fileExists( localPath ) );
    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect single file, url exists';
    providerDst.filesDelete( localPath );
    let remotePath = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    test.identical( got.length, 1 );
    let dst = got[ 0 ].dst;
    test.identical( dst.absolute, localPath );
    test.identical( Number( dst.stat.size ), 1763 );

    let file = providerDst.fileRead( localPath );
    test.is( _.strHas( file, '# wTools' ) );
    test.is( _.strHas( file, '### Try out' ) );
    test.is( _.strHas( file, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect single file, url exists, trailing slash';
    providerDst.filesDelete( localPath );
    let remotePath = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    test.identical( got.length, 1 );
    let dst = got[ 0 ].dst;
    test.identical( dst.absolute, localPath );
    test.identical( Number( dst.stat.size ), 1763 );

    let file = providerDst.fileRead( localPath );
    test.is( _.strHas( file, '# wTools' ) );
    test.is( _.strHas( file, '### Try out' ) );
    test.is( _.strHas( file, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect single file, url exists';
    providerDst.filesDelete( localPath );
    let remotePath = 'https:///raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    test.identical( got.length, 1 );
    let dst = got[ 0 ].dst;
    test.identical( dst.absolute, localPath );
    test.identical( Number( dst.stat.size ), 1763 );

    let file = providerDst.fileRead( localPath );
    test.is( _.strHas( file, '# wTools' ) );
    test.is( _.strHas( file, '### Try out' ) );
    test.is( _.strHas( file, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect single file, url exists, trailing slash';
    providerDst.filesDelete( localPath );
    let remotePath = 'https:///raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    test.identical( got.length, 1 );
    let dst = got[ 0 ].dst;
    test.identical( dst.absolute, localPath );
    test.identical( Number( dst.stat.size ), 1763 );

    let file = providerDst.fileRead( localPath );
    test.is( _.strHas( file, '# wTools' ) );
    test.is( _.strHas( file, '### Try out' ) );
    test.is( _.strHas( file, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect single file, dst file exists';
    providerDst.fileWrite( localPath, localPath );
    let remotePath = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    test.identical( got.length, 1 );
    let dst = got[ 0 ].dst;
    test.identical( dst.absolute, localPath );
    test.identical( Number( dst.stat.size ), 1763 );

    let file = providerDst.fileRead( localPath );
    test.is( _.strHas( file, '# wTools' ) );
    test.is( _.strHas( file, '### Try out' ) );
    test.is( _.strHas( file, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect several files';
    providerDst.filesDelete( localPath );
    providerDst.filesDelete( localPath2 );
    let remotePath1 = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md';
    let remotePath2 = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.641/README.md';
    return system.filesReflect
    ({
      reflectMap :
      {
        [ remotePath1 ] : clonePathGlobal,
        [ remotePath2 ] : clonePathGlobal2,
      }
    });
  })
  .then( ( got ) =>
  {
    test.identical( got.length, 2 );
    test.identical( got[ 0 ].dst.absolute, localPath );
    test.identical( Number( got[ 0 ].dst.stat.size ), 1763 );
    test.identical( got[ 1 ].dst.absolute, localPath2 );
    test.identical( Number( got[ 1 ].dst.stat.size ), 1763 );

    let file = providerDst.fileRead( localPath );
    test.is( _.strHas( file, '# wTools' ) );
    test.is( _.strHas( file, '### Try out' ) );
    test.is( _.strHas( file, '### Contributors' ) );

    let file2 = providerDst.fileRead( localPath2 );
    test.is( _.strHas( file2, '# wTools' ) );
    test.is( _.strHas( file2, '### Try out' ) );
    test.is( _.strHas( file2, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect several files, first src file doesn\'t exist';
    providerDst.filesDelete( localPath );
    providerDst.filesDelete( localPath2 );
    let remotePath1 = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README';
    let remotePath2 = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.641/README.md';
    let con = system.filesReflect
    ({
      reflectMap :
      {
        [ remotePath1 ] : clonePathGlobal,
        [ remotePath2 ] : clonePathGlobal2,
      }
    });
    return test.shouldThrowErrorAsync( con );
  })
  .then( ( got ) =>
  {
    test.is( !providerDst.fileExists( localPath ) );
    test.is( providerDst.fileExists( localPath2 ) );

    let file2 = providerDst.fileRead( localPath2 );
    test.is( _.strHas( file2, '# wTools' ) );
    test.is( _.strHas( file2, '### Try out' ) );
    test.is( _.strHas( file2, '### Contributors' ) );

    return got;
  })

  /* - */

  .then( () =>
  {
    test.case = 'reflect several files, second src file doesn\'t exist';
    providerDst.filesDelete( localPath );
    providerDst.filesDelete( localPath2 );
    let remotePath1 = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.642/README.md';
    let remotePath2 = 'https://raw.githubusercontent.com/Wandalen/wTools/v0.8.641/README';
    let con = system.filesReflect
    ({
      reflectMap :
      {
        [ remotePath1 ] : clonePathGlobal,
        [ remotePath2 ] : clonePathGlobal2,
      }
    });
    return test.shouldThrowErrorAsync( con );
  })
  .then( ( got ) =>
  {
    test.is( providerDst.fileExists( localPath ) );
    test.is( !providerDst.fileExists( localPath2 ) );
    return got;
  })

  /* - */

  return con;
}

filesReflectTrivial.timeOut = 120000;

//

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
    suitePath : null,
    providerSrc : null,
    providerDst : null,
    system : null
  },

  tests :
  {
    filesReflectTrivial
  },

}

//

var Self = new wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
