( function _FileProvider_Npm_test_ss_( ) {

'use strict'; 

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );

  require( '../files/UseTop.s' );
}

//

var _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Npm();
  context.providerDst = _.FileProvider.HardDrive();
  context.hub = _.FileProvider.Hub({ providers : [ context.providerSrc, context.providerDst ] });

  let path = context.providerDst.path;

  context.testSuitePath = path.dirTempOpen( 'FileProviderNpm' );
  context.testSuitePath = context.providerDst.pathResolveLinkFull({ filePath : context.testSuitePath, resolvingSoftLink : 1 });
}

function onSuiteEnd( test )
{
  let context = this;
  let path = context.providerDst.path;
  _.assert( _.strHas( context.testSuitePath, 'FileProviderNpm' ) );
  path.dirTempClose( context.testSuitePath );
}

// --
// tests
// --

function filesReflectTrivial( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let hub = context.hub;
  let path = context.providerDst.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let installPath = path.join( testPath, 'wPathFundamentals' );
  let installPathGlobal = providerDst.path.globalFromLocal( installPath );

  let con = new _.Consequence().take( null )

  .thenKeep( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( installPath );
    let remotePath = 'npm:///wpathfundamentals';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.dirRead( installPath );
    let expected =
    [
      'LICENSE',
      'package.json',
      'README.md',
      'out',
      'proto',
      'node_modules',
    ]
    test.contains( files.sort(), expected.sort() );
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'no hash, with trailing /';
    providerDst.filesDelete( installPath );
    let remotePath = 'npm:///wpathfundamentals/'
    return hub.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.dirRead( installPath );
    let expected =
    [
      'LICENSE',
      'package.json',
      'README.md',
      'out',
      'proto',
      'node_modules',
    ]
    test.identical( files.sort(), expected.sort() );
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'already exists';
    providerDst.filesDelete( installPath );
    let remotePath = 'npm:///wpathfundamentals';
    let o = { reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 };
    hub.filesReflect( _.cloneJust( o ) )
    return hub.filesReflect( _.cloneJust( o ) );
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.dirRead( installPath );
    let expected =
    [
      'LICENSE',
      'package.json',
      'README.md',
      'out',
      'proto',
      'node_modules',
    ]
    test.identical( files.sort(), expected.sort() );
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'specific version';
    providerDst.filesDelete( installPath );
    let remotePath = 'npm:///wpathfundamentals#0.6.154'
    return hub.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.dirRead( installPath );
    let expected =
    [
      'LICENSE',
      'package.json',
      'README.md',
      'out',
      'proto',
      'node_modules',
    ]
    test.identical( files.sort(), expected.sort() );
    var packagePath = providerDst.path.join( installPath, 'package.json' );
    var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
    test.identical( packageRead.version, '0.6.154' )
    return got;
  })
  
  /*  */
  
  .thenKeep( () =>
  {
    test.case = 'specific tag';
    providerDst.filesDelete( installPath );
    let remotePath = 'npm:///wpathfundamentals#latest'
    return hub.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.dirRead( installPath );
    let expected =
    [
      'LICENSE',
      'package.json',
      'README.md',
      'out',
      'proto',
      'node_modules',
    ]
    test.identical( files.sort(), expected.sort() );
    var packagePath = providerDst.path.join( installPath, 'package.json' );
    var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
    test.identical( packageRead._requested.fetchSpec, 'latest' )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'path is occupied';
    providerDst.filesDelete( installPath );
    providerDst.fileWrite( installPath, installPath );
    let remotePath = 'npm:///wpathfundamentals';
    return test.shouldThrowErrorSync( () => hub.filesReflect( { reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 } ));
  })
  .thenKeep( () =>
  {
    test.is( providerDst.isTerminal( installPath ) );
    return null;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'wrong package name';
    providerDst.filesDelete( installPath );
    let remotePath = 'npm:///wpathFundamentals';
    return test.shouldThrowErrorSync( () => hub.filesReflect( { reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 } ) );
  })
  .thenKeep( () =>
  {
    test.is( !providerDst.fileExists( installPath ) );
    return null;
  })

  return con;
}

filesReflectTrivial.timeOut = 120000;

//

//Vova: commented out test routine, because npm provider supports only global paths 

// function filesReflectLocalPath( test )
// {
//   let context = this;
//   let providerSrc = context.providerSrc;
//   let providerDst = context.providerDst;
//   let path = context.providerDst.path;
//   let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
//   let installPath = path.join( testPath, 'wPathFundamentals' );

//   let con = new _.Consequence().take( null )

//   .thenKeep( () =>
//   {
//     test.case = 'localPath';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathfundamentals';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       /*dstFilter*/dst : { effectiveFileProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .thenKeep( ( got ) =>
//   {
//     let files = providerDst.dirRead( installPath );
//     let expected =
//     [
//       'LICENSE',
//       'package.json',
//       'README.md',
//       'out',
//       'proto',
//       'node_modules',
//     ]
//     test.contains( files.sort(), expected.sort() );
//     return got;
//   })

//   /*  */

//   .thenKeep( () =>
//   {
//     test.case = 'localPath with hash';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathfundamentals#0.6.154';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       /*dstFilter*/dst : { effectiveFileProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .thenKeep( ( got ) =>
//   {
//     let files = providerDst.dirRead( installPath );
//     let expected =
//     [
//       'LICENSE',
//       'package.json',
//       'README.md',
//       'out',
//       'proto',
//       'node_modules',
//     ]
//     test.contains( files.sort(), expected.sort() );
//     var packagePath = providerDst.path.join( installPath, 'package.json' );
//     var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
//     test.identical( packageRead.version, '0.6.154' )
//     return got;
//   })

//   /*  */

//   .thenKeep( () =>
//   {
//     test.case = 'localPath with trailing slash and hash';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathfundamentals/#0.6.154';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       /*dstFilter*/dst : { effectiveFileProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .thenKeep( ( got ) =>
//   {
//     let files = providerDst.dirRead( installPath );
//     let expected =
//     [
//       'LICENSE',
//       'package.json',
//       'README.md',
//       'out',
//       'proto',
//       'node_modules',
//     ]
//     test.contains( files.sort(), expected.sort() );
//     return got;
//   })

//   /*  */

//   .thenKeep( () =>
//   {
//     test.case = 'rewrite existing';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathfundamentals';
//     let o =
//     {
//       reflectMap : { [ remotePath ] : installPath },
//       /*dstFilter*/dst : { effectiveFileProvider : providerDst },
//       verbosity : 3
//     }
//     let con = providerSrc.filesReflect( _.mapExtend( null, o ) );
//     con.thenKeep( () => providerSrc.filesReflect( _.mapExtend( null, o ) ) );
//     return con;
//   })
//   .thenKeep( ( got ) =>
//   {
//     let files = providerDst.dirRead( installPath );
//     let expected =
//     [
//       'LICENSE',
//       'package.json',
//       'README.md',
//       'out',
//       'proto',
//       'node_modules',
//     ]
//     test.contains( files.sort(), expected.sort() );
//     return got;
//   })

//   /*  */

//   .thenKeep( () =>
//   {
//     test.case = 'githubname/reponame';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/Wandalen/wPathFundamentals';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       /*dstFilter*/dst : { effectiveFileProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .thenKeep( ( got ) =>
//   {
//     let files = providerDst.dirRead( installPath );
//     let expected =
//     [
//       'LICENSE',
//       'package.json',
//       'README.md',
//       'out',
//       'proto',
//       'node_modules',
//     ]
//     test.contains( files.sort(), expected.sort() );
//     var packagePath = providerDst.path.join( installPath, 'package.json' );
//     var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
//     test.identical( packageRead.version, '0.6.154' )
//     return got;
//   })

//   /*  */

//   .thenKeep( () =>
//   {
//     test.case = 'path is occupied by terminal';
//     providerDst.filesDelete( installPath );
//     providerDst.fileWrite( installPath,installPath );
//     let remotePath = '/wpathfundamentals';
//     let o =
//     {
//       reflectMap : { [ remotePath ] : installPath },
//       /*dstFilter*/dst : { effectiveFileProvider : providerDst },
//       verbosity : 3
//     }
//     let con = providerSrc.filesReflect( o );
//     return test.shouldThrowErrorAsync( con );
//   })
//   .thenKeep( ( got ) =>
//   {
//     test.is( providerDst.isTerminal( installPath ) );
//     return got;
//   })


//   return con;
// }

// filesReflectLocalPath.timeOut = 120000;


// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Npm',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  verbosity : 4,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    testSuitePath : null,
    providerSrc : null,
    providerDst : null,
    hub : null
  },

  tests :
  {
    filesReflectTrivial : filesReflectTrivial,
    // filesReflectLocalPath : filesReflectLocalPath,
  },

}

//

var Self = new wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
