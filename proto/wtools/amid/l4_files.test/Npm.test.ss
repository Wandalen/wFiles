( function _Npm_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Files.s' );
}

const _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Npm();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });

  context.suiteTempPath = _.fileProvider.path.tempOpen( _.fileProvider.path.join( __dirname, '../..' ), 'FileProviderNpm' );
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

function filesReflectTrivial( test )
{
  let context = this;
  let a = test.assetFor( false );
  let providerDst = context.providerDst;
  let system = context.system;
  let installPathGlobal = providerDst.path.globalFromPreferred( a.abs( 'wModuleForTesting1' ) );
  a.fileProvider.dirMake( a.routinePath );

  /* - */

  a.shell({ execPath : 'npm i pacote --no-package-lock' });

  a.ready.then( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1';
    return system.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  });
  a.ready.then( ( got ) =>
  {
    let files = providerDst.dirRead( a.abs( 'wModuleForTesting1' ) );
    let expected =
    [
      'License',
      'package.json',
      'Readme.md',
      'proto',
      'out',
    ];
    test.contains( files.sort(), expected.sort() );
    return got;
  });
  a.shell( './node_modules/.bin/pacote manifest wmodulefortesting1' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '"_from": "wmodulefortesting1@"' ), 1 );
    return null;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'no hash, with trailing /';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  });
  a.ready.then( ( got ) =>
  {
    let files = providerDst.dirRead( a.abs( 'wModuleForTesting1' ) );
    let expected =
    [
      'License',
      'package.json',
      'Readme.md',
      'proto',
      'out',
    ];
    test.identical( files.sort(), expected.sort() );
    return got;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'already exists';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1';
    let o = { reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 };
    system.filesReflect( _.cloneJust( o ) );
    return system.filesReflect( _.cloneJust( o ) );
  });
  a.ready.then( ( got ) =>
  {
    let files = providerDst.dirRead( a.abs( 'wModuleForTesting1' ) );
    let expected =
    [
      'License',
      'package.json',
      'Readme.md',
      'proto',
      'out',
    ];
    test.identical( files.sort(), expected.sort() );
    return got;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'specific version';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1#0.0.100';
    return system.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  });
  a.ready.then( ( got ) =>
  {
    let files = providerDst.dirRead( a.abs( 'wModuleForTesting1' ) );
    let expected =
    [
      'LICENSE',
      'README.md',
      'package.json',
      'proto',
      'out',
    ];
    test.identical( files.sort(), expected.sort() );
    var packagePath = providerDst.path.join( a.abs( 'wModuleForTesting1' ), 'package.json' );
    var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
    test.identical( packageRead.version, '0.0.100' )
    return got;
  });
  a.shell( './node_modules/.bin/pacote manifest wmodulefortesting1@0.0.100' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '"_from": "wmodulefortesting1@0.0.100"' ), 1 );
    return null;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'specific tag';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1!latest';
    return system.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  });
  a.ready.then( ( got ) =>
  {
    let files = providerDst.dirRead( a.abs( 'wModuleForTesting1' ) );
    let expected =
    [
      'License',
      'package.json',
      'Readme.md',
      'proto',
      'out',
    ];
    test.identical( files.sort(), expected.sort() );
    var packagePath = providerDst.path.join( a.abs( 'wModuleForTesting1' ), 'package.json' );
    var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
    if( packageRead._requested )
    test.identical( packageRead._requested.fetchSpec, 'latest' )
    return got;
  });
  a.shell( 'node_modules/.bin/pacote manifest wmodulefortesting1@latest' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '"_from": "wmodulefortesting1@latest"' ), 1 );
    return null;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'specific tag';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1!gamma';
    return system.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 });
  });
  a.ready.then( ( got ) =>
  {
    let files = providerDst.dirRead( a.abs( 'wModuleForTesting1' ) );
    let expected =
    [
      'License',
      'package.json',
      'Readme.md',
      'proto',
      'out',
    ];
    test.identical( files.sort(), expected.sort() );
    var packagePath = providerDst.path.join( a.abs( 'wModuleForTesting1' ), 'package.json' );
    var packageRead = providerDst.fileRead({ filePath : packagePath, encoding : 'json' });
    if( packageRead._requested )
    test.identical( packageRead._requested.fetchSpec, 'gamma' )
    return got;
  })
  a.shell( 'node_modules/.bin/pacote manifest wmodulefortesting1@gamma' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '"_from": "wmodulefortesting1@gamma"' ), 1 );
    return null;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'path is occupied';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    providerDst.fileWrite( a.abs( 'wModuleForTesting1' ), a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting1';
    return test.shouldThrowErrorSync
    (
      () => system.filesReflect( { reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 } )
    );
  });
  a.ready.then( () =>
  {
    test.true( providerDst.isTerminal( a.abs( 'wModuleForTesting1' ) ) );
    return null;
  });

  /*  */

  a.ready.then( () =>
  {
    test.case = 'wrong package name';
    providerDst.filesDelete( a.abs( 'wModuleForTesting1' ) );
    let remotePath = 'npm:///wmodulefortesting111';
    return test.shouldThrowErrorSync
    (
      () => system.filesReflect({ reflectMap : { [ remotePath ] : installPathGlobal }, verbosity : 3 })
    );
  })
  .then( () =>
  {
    test.true( !providerDst.fileExists( a.abs( 'wModuleForTesting1' ) ) );
    return null;
  })

  return a.ready;
}

filesReflectTrivial.timeOut = 240000;

//

//Vova: commented out test routine, because npm provider supports only global paths

// function filesReflectLocalPath( test )
// {
//   let context = this;
//   let providerSrc = context.providerSrc;
//   let providerDst = context.providerDst;
//   let path = context.providerDst.path;
//   let routinePath = path.join( context.suiteTempPath, 'routine-' + test.name );
//   let installPath = path.join( routinePath, 'wPathBasic' );

//   let con = new _.Consequence().take( null )

//   .then( () =>
//   {
//     test.case = 'localPath';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathbasic';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       dst : { effectiveProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .then( ( got ) =>
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

//   .then( () =>
//   {
//     test.case = 'localPath with hash';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathbasic#0.7.1';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       dst : { effectiveProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .then( ( got ) =>
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
//     test.identical( packageRead.version, '0.7.1' )
//     return got;
//   })

//   /*  */

//   .then( () =>
//   {
//     test.case = 'localPath with trailing slash and hash';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathbasic/#0.7.1';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       dst : { effectiveProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .then( ( got ) =>
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

//   .then( () =>
//   {
//     test.case = 'rewrite existing';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/wpathbasic';
//     let o =
//     {
//       reflectMap : { [ remotePath ] : installPath },
//       dst : { effectiveProvider : providerDst },
//       verbosity : 3
//     }
//     let con = providerSrc.filesReflect( _.props.extend( null, o ) );
//     con.then( () => providerSrc.filesReflect( _.props.extend( null, o ) ) );
//     return con;
//   })
//   .then( ( got ) =>
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

//   .then( () =>
//   {
//     test.case = 'githubname/reponame';
//     providerDst.filesDelete( installPath );
//     let remotePath = '/Wandalen/wPathBasic';
//     return providerSrc.filesReflect
//     ({
//       reflectMap : { [ remotePath ] : installPath },
//       dst : { effectiveProvider : providerDst },
//       verbosity : 3
//     });
//   })
//   .then( ( got ) =>
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
//     test.identical( packageRead.version, '0.7.1' )
//     return got;
//   })

//   /*  */

//   .then( () =>
//   {
//     test.case = 'path is occupied by terminal';
//     providerDst.filesDelete( installPath );
//     providerDst.fileWrite( installPath,installPath );
//     let remotePath = '/wpathbasic';
//     let o =
//     {
//       reflectMap : { [ remotePath ] : installPath },
//       dst : { effectiveProvider : providerDst },
//       verbosity : 3
//     }
//     let con = providerSrc.filesReflect( o );
//     return test.shouldThrowErrorAsync( con );
//   })
//   .then( ( got ) =>
//   {
//     test.true( providerDst.isTerminal( installPath ) );
//     return got;
//   })


//   return con;
// }

// filesReflectLocalPath.timeOut = 120000;


// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.Npm',
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
    filesReflectTrivial,
    // filesReflectLocalPath,
  },

}

//

const Self = wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
