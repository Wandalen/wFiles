( function _FileProvider_Git_test_ss_( ) {

'use strict'; 

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  
  try
  {
    require( 'gitconfiglocal' )
  }
  catch( err )
  { 
    return;
  }

  require( '../files/UseTop.s' );
}

//

var _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Git();
  context.providerDst = _.FileProvider.HardDrive();
  context.hub = _.FileProvider.Hub({ providers : [ context.providerSrc, context.providerDst ] });

  let path = context.providerDst.path;

  context.testSuitePath = path.dirTempOpen( 'FileProviderGit' );
  context.testSuitePath = context.providerDst.pathResolveLinkFull({ filePath : context.testSuitePath, resolvingSoftLink : 1 });
}

function onSuiteEnd( test )
{
  let context = this;
  let path = context.providerDst.path;
  _.assert( _.strHas( context.testSuitePath, 'FileProviderGit' ) );
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
  let localPath = path.join( testPath, 'wPathFundamentals' );
  let clonePathGlobal = providerDst.globalFromLocal( localPath );

  let con = new _.Consequence().take( null )

  .thenKeep( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'no hash, trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git/';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#master';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'not existing repository';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///DoesNotExist.git';
    let result = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
    return test.shouldThrowErrorAsync( result );
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    test.identical( files, [ '.' ] );
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'reflect twice in a row';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#master';
    let o = { reflectMap : { [ remotePath ] : clonePathGlobal }};

    let ready = new _.Consequence().take( null );
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )

    return ready;
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'reflect twice in a row, fetching off';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#master';
    let o =
    {
      reflectMap : { [ remotePath ] : clonePathGlobal },
      extra : { fetching : false }
    };

    let ready = new _.Consequence().take( null );
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )

    return ready;
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'commit hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    let packagePath = providerDst.path.join( localPath, 'package.json' );
    let packageRead = providerDst.fileRead
    ({
      filePath : packagePath,
      encoding : 'json'
    });
    test.identical( packageRead.version, '0.6.157' );
    return got;
  })

  return con;
}

filesReflectTrivial.timeOut = 60000;


// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Git',
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
    filesReflectTrivial : filesReflectTrivial
  },

}

//

var Self = new wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
