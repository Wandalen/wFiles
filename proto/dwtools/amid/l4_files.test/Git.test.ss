( function _FileProvider_Git_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../dwtools/Tools.s' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Files.s' );
}

//

var _ = _global_.wTools;
var RunningInsideTestContainer = _.process.insideTestContainer();

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Git();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });
  context.system.defaultProvider = context.providerDst;

  context.suiteTempPath = context.providerDst.path.pathDirTempOpen( context.providerDst.path.join( __dirname, '../..'  ),'FileProviderGit' );

  if( RunningInsideTestContainer )
  {
    let gitConfig = context.gitConfigStart = _.process.starter
    ({
      execPath : 'git config --global',
      sync : 1,
      deasync : 0,
      mode : 'shell',
      outputCollecting : 1,
      throwingExitCode : 0,
    })
    context.gitOriginalCoreAutocrlf = _.strStrip( gitConfig( `core.autocrlf` ).output );
    gitConfig( `core.autocrlf true` )
  }

}

function onSuiteEnd( test )
{
  let context = this;

  if( RunningInsideTestContainer )
  {
    let gitConfig = context.gitConfigStart;
    gitConfig( `core.autocrlf ${context.gitOriginalCoreAutocrlf}` )
  }

  _.assert( _.strHas( context.suiteTempPath, 'FileProviderGit' ), context.suiteTempPath );
  context.providerDst.path.pathDirTempClose( context.suiteTempPath );
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
  let testPath = path.join( context.suiteTempPath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'wPathBasic' );
  debugger;
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );

  let con = new _.Consequence().take( null )

  .then( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
    ]

    test.is( _.arraySetContainAll( files,expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'no hash, trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'tag, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!master';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'not existing repository';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///DoesNotExist.git';
    let result = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
    return test.shouldThrowErrorAsync( result );
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    test.identical( files, [] );
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'reflect twice in a row';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!master';
    let o = { reflectMap : { [ remotePath ] : clonePathGlobal }};

    let ready = new _.Consequence().take( null );
    ready.then( () => system.filesReflect( _.mapExtend( null, o ) ) )
    ready.then( () => system.filesReflect( _.mapExtend( null, o ) ) )

    return ready;
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'reflect twice in a row, fetching off';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!master';
    let o =
    {
      reflectMap : { [ remotePath ] : clonePathGlobal },
      extra : { fetching : false }
    };

    let ready = new _.Consequence().take( null );
    ready.then( () => system.filesReflect( _.mapExtend( null, o ) ) )
    ready.then( () => system.filesReflect( _.mapExtend( null, o ) ) )

    return ready;
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'commit hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
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

  /*  */

  .then( () =>
  {
    test.case = 'local is behind remote';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });

    _.process.start
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready
    })

    ready.then( () => system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHasAny( got.output, [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ] ) )
      return null;
    })

    return ready;
  })

  /*  */

  .then( () =>
  {
    test.case = 'local has new commit, remote up to date, no merge required';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });

    _.process.start
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready
    })

    ready.then( () => system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 1 commit` ) )
      return null;
    })

    _.process.start
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( !_.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.is( _.strHas( got.output, `emptycommit` ) )
      return null;
    })

    return ready;
  })

  /*  */

  .then( () =>
  {
    test.case = 'local and remote have one new commit, should be merged';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });

    _.process.start
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready
    })

    _.process.start
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready
    })

    ready.then( () => system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 2 commits` ) )
      return null;
    })

    _.process.start
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.is( _.strHas( got.output, `emptycommit` ) )
      return null;
    })

    return ready;
  })

  /*  */

  .then( () =>
  {
    test.case = 'local version is fixate and has local commit, update to latest';
    providerDst.filesDelete( localPath );
    let remotePathFixate = 'git+https:///github.com/Wandalen/wPathBasic.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePathFixate ] : clonePathGlobal }, verbosity : 5 });

    _.process.start
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready
    })

    ready.then( () => system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHasAny( got.output, [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ] ) )
      return null;
    })

    return ready;
  })

  /*  */

  .then( () =>
  {
    test.case = 'local has fixed version, update to latest';
    providerDst.filesDelete( localPath );
    let remotePathFixate = 'git+https:///github.com/Wandalen/wPathBasic.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePathFixate ] : clonePathGlobal }, verbosity : 5 });

    ready.then( () => system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHasAny( got.output, [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ] ) )
      return null;
    })

    return ready;
  })

  /*  */

  .then( () =>
  {
    test.case = 'local has changes, checkout throws an error';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    let remotePathUnknownHash = 'git+https:///github.com/Wandalen/wPathBasic.git/!other';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });

    ready.then( ( got ) =>
    {
      providerDst.fileWrite( providerDst.path.join( localPath, 'README.md' ), 'test' );
      return null;
    })

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `modified:   README.md` ) )
      return null;
    })

    ready.then( () =>
    {
      let con = system.filesReflect({ reflectMap : { [ remotePathUnknownHash ] : clonePathGlobal }, verbosity : 5 });
      return test.shouldThrowErrorAsync( con );
    })

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `modified:   README.md` ) )
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
  {
    test.case = 'no local changes, checkout throws an error';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    let remotePathUnknownHash = 'git+https:///github.com/Wandalen/wPathBasic.git/!other';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHasAny( got.output, [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ] ) )
      return null;
    })

    ready.then( () =>
    {
      let con = system.filesReflect({ reflectMap : { [ remotePathUnknownHash ] : clonePathGlobal }, verbosity : 5 });
      return test.shouldThrowErrorAsync( con );
    })

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHasAny( got.output, [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ] ) )
      return null;
    })

    return ready;
  })

  /* */

  .then( () =>
  {
    test.case = 'download repo, then try to checkout';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( () =>
  {
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/#b5409b80e185d20b5936dd01451510cb2ecc02fe';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      withTerminals : 1,
      withDirs : 1,
      outputFormat : 'relative',
      filter : { recursive : 2 }
    });

    let expected =
    [
      '.',
      './.ex.will.yml',
      './.im.will.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
    ]

    test.is( _.arraySetContainAll( files,expected ) )
    return got;
  })

  //

  /* */

  .then( () =>
  {
    test.case = 'download repo, then try to checkout using branch name as hash';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( () =>
  {
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/#master';
    let con = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
    return test.shouldThrowErrorAsync( con );
  })

  /* */

  .then( () =>
  {
    test.case = 'download repo, then try to checkout using unknown branch name as tag';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .then( () =>
  {
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!master2';
    let con = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
    return test.shouldThrowErrorAsync( con );
  })

  return con;
}

filesReflectTrivial.timeOut = 120000;

//

function filesReflectNoStashing( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let testPath = path.join( context.suiteTempPath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'wPathBasic' );
  debugger;
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );

  let con = new _.Consequence().take( null )

  .then( () =>
  {
    test.case = 'local has changes, remote have one new commit, error expected';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });

    _.process.start
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready
    })

    ready.then( () =>
    {
      _.fileProvider.fileWrite( _.path.join( localPath, 'README.md' ), '' );
      return null;
    })

    ready.then( () =>
    {
      let con = system.filesReflect
      ({
        reflectMap : { [ remotePath ] : clonePathGlobal },
        verbosity : 5,
        extra : { stashing : 0 }
      });
      return test.shouldThrowErrorAsync( con );
    });

    _.process.start
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })

    ready.then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `modified:   README.md` ) )
      return null;
    })

    return ready;
  })

  return con;

}

filesReflectNoStashing.timeOut = 120000;

//

function filesReflectDownloadThrowing( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let testPath = path.join( context.suiteTempPath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'wPathBasic' );
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );

  let con = new _.Consequence().take( null )

  con
  .then( () =>
  {
    test.case = 'not existing hash';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/#63b39b105817e80e4a3810febd8b09ffe7cd6ad1';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( !providerDst.fileExists( localPath ) )
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'not existing branch';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!somebranch';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( !providerDst.fileExists( localPath ) )
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'not existing tag';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!v0.0.0';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( !providerDst.fileExists( localPath ) )
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'error on download, new directory should not be made';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasicc.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( !providerDst.fileExists( localPath ) )
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'error on download, existing empty directory should be preserved';
    providerDst.filesDelete( localPath );
    providerDst.dirMake( localPath )
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasicc.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( providerDst.fileExists( localPath ) );
      test.identical( providerDst.dirRead( localPath ), [] );
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'no error if dst path exists and its an empty dir';
    providerDst.filesDelete( localPath );
    providerDst.dirMake( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.mustNotThrowError( ready )
    .then( () =>
    {
      let got = _.git.hasRemote({ localPath, remotePath });
      test.identical( got.downloaded, true )
      test.identical( got.remoteIsValid, true )
      return got;
    })
  })

  .then( () =>
  {
    test.case = 'error if dst path exists and its not a empty dir';
    providerDst.filesDelete( localPath );
    providerDst.dirMake( localPath );
    let filePath = providerDst.path.join( localPath, 'file' );
    providerDst.fileWrite( filePath, filePath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( providerDst.fileExists( localPath ) );
      test.identical( providerDst.dirRead( localPath ), [ 'file' ] );
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'error if dst path exists and its terminal';
    providerDst.filesDelete( localPath );
    providerDst.fileWrite( localPath, localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    return test.shouldThrowErrorAsync( ready )
    .then( ( got ) =>
    {
      test.is( providerDst.isTerminal( localPath ) );
      return null;
    })
  })

  .then( () =>
  {
    test.case = 'error if dst path exists and it has other git repo';
    providerDst.filesDelete( localPath );
    providerDst.dirMake( localPath );
    return _.process.start({ execPath : 'git clone https://github.com/Wandalen/wTools.git .', currentPath : localPath, mode : 'spawn' })
    .then( () =>
    {
      let find = providerDst.filesFinder
      ({
        withTerminals : 1,
        withDirs : 1,
        outputFormat : 'relative',
        filter : { recursive : 2 }
      });

      let filesBefore = find( localPath );
      let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
      let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
      return test.shouldThrowErrorAsync( ready )
      .then( () =>
      {
        test.is( providerDst.fileExists( localPath ) );
        let filesAfter = find( localPath );
        test.identical( filesAfter, filesBefore );
        return null;
      })
    })
  })

  if( !Config.debug )
  return con;

  con.then( () =>
  {
    test.case = 'hash and tag in same time';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/#63b39b105817e80e4a3810febd8b09ffe7cd6ad1!master';
    test.shouldThrowErrorSync( () =>
    {
      system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
      test.is( !providerDst.fileExists( localPath ) )
    })
    return null;
  })

  return con;
}

filesReflectDownloadThrowing.timeOut = 120000;

//

function filesReflectEol( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let testPath = path.join( context.suiteTempPath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'clone' );
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );
  let repoPath = path.join( testPath, 'repo' );
  let expectedHash1;
  let expectedHash2;
  let con = new _.Consequence().take( null );

  prepare();

  /*
    +clone
    +checkout
    +change core.autocrl in local git config then checkout
    +merge
    +change core.autocrl in local git config then merge
    +merge stashing : 1
  */

  /* - */

  con
  .then( () =>
  {
    test.description =
    `clone git repo
     file endings should be preserved
     local config should have auto.crlf false
     global config should not be modified
    `
    providerDst.filesDelete( localPath );
    let remotePath = 'git+hd://' + repoPath;

    let autocrlfGlobalOriginal = gitConfigGlobalRead( 'core.autocrlf' );

    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    .then( () =>
    {
      test.case = 'global git config was not changed';
      let autocrlfGlobal = gitConfigGlobalRead( 'core.autocrlf' );
      test.identical( autocrlfGlobal, autocrlfGlobalOriginal );

      let autocrlfLocal = gitConfigLocalRead( localPath, 'core.autocrlf' )
      test.identical( autocrlfLocal, 'false' );

      let hash1 = providerDst.hashRead( path.join( localPath, 'file1' ) );
      test.identical( hash1, expectedHash1 );
      let hash2 = providerDst.hashRead( path.join( localPath, 'file2' ) );
      test.identical( hash2, expectedHash2 );
      return null;
    })
  })

  /* - */

  con
  .then( () =>
  {
    test.description =
    `clone and checkout to other branch
     repo should be on branch specified in path
     file endings should be preserved
     local config should have auto.crlf false
     global config should not be modified
    `
    providerDst.filesDelete( localPath );
    let remotePath = 'git+hd://' + repoPath + '/!secondbranch';

    let autocrlfGlobalOriginal = gitConfigGlobalRead( 'core.autocrlf' );

    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    .then( () =>
    {
      test.case = 'global git config was not changed';
      let autocrlfGlobal = gitConfigGlobalRead( 'core.autocrlf' );
      test.identical( autocrlfGlobal, autocrlfGlobalOriginal );

      let autocrlfLocal = gitConfigLocalRead( localPath, 'core.autocrlf' )
      test.identical( autocrlfLocal, 'false' );

      let branch = _.git.versionLocalRetrive({ localPath });
      test.identical( branch, 'secondbranch' )

      let hash1 = providerDst.hashRead( path.join( localPath, 'file1' ) );
      test.identical( hash1, expectedHash1 );
      let hash2 = providerDst.hashRead( path.join( localPath, 'file2' ) );
      test.identical( hash2, expectedHash2 );
      return null;
    })
  })

  /* - */

  con
  .then( () =>
  {
    test.description =
    `clone git repo, change local core.autocrlf to true, then checkout to other branch
     file endings should be preserved
     local config should have auto.crlf false
     global config should not be modified
    `
    providerDst.filesDelete( localPath );
    let remotePath = 'git+hd://' + repoPath;
    let remotePath2 = 'git+hd://' + repoPath + '/!secondbranch';

    let autocrlfGlobalOriginal = gitConfigGlobalRead( 'core.autocrlf' );

    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    .then( () =>
    {
      gitConfigLocalWrite( localPath, 'core.autocrlf true' );
      return system.filesReflect({ reflectMap : { [ remotePath2 ] : clonePathGlobal }, verbosity : 5 })
    })
    .then( () =>
    {
      test.case = 'global git config was not changed';
      let autocrlfGlobal = gitConfigGlobalRead( 'core.autocrlf' );
      test.identical( autocrlfGlobal, autocrlfGlobalOriginal );

      let autocrlfLocal = gitConfigLocalRead( localPath, 'core.autocrlf' )
      test.identical( autocrlfLocal, 'true' );

      let branch = _.git.versionLocalRetrive({ localPath });
      test.identical( branch, 'secondbranch' )

      let hash1 = providerDst.hashRead( path.join( localPath, 'file1' ) );
      test.identical( hash1, expectedHash1 );
      let hash2 = providerDst.hashRead( path.join( localPath, 'file2' ) );
      test.identical( hash2, expectedHash2 );
      return null;
    })
  })

  /* - */

  con
  .then( () =>
  {
    test.description =
    `merge
     file endings should be preserved
     local config should have auto.crlf false
     global config should not be modified
    `
    providerDst.filesDelete( localPath );
    let remotePath = 'git+hd://' + repoPath;

    let autocrlfGlobalOriginal = gitConfigGlobalRead( 'core.autocrlf' );

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    .then( () =>
    {
      let start = _.process.starter
      ({
        currentPath : localPath,
        sync : 1
      });

      start( 'git reset --hard HEAD~1' )
      start( 'git commit -m emptycommit --allow-empty' )

      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    })
    .then( () =>
    {
      test.case = 'global git config was not changed';
      let autocrlfGlobal = gitConfigGlobalRead( 'core.autocrlf' );
      test.identical( autocrlfGlobal, autocrlfGlobalOriginal );

      let autocrlfLocal = gitConfigLocalRead( localPath, 'core.autocrlf' )
      test.identical( autocrlfLocal, 'false' );

      let hash1 = providerDst.hashRead( path.join( localPath, 'file1' ) );
      test.identical( hash1, expectedHash1 );
      let hash2 = providerDst.hashRead( path.join( localPath, 'file2' ) );
      test.identical( hash2, expectedHash2 );
      return null;
    })

    _.process.start
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.is( _.strHas( got.output, `emptycommit` ) )
      return null;
    })

    return ready;
  })

  /* - */

  con
  .then( () =>
  {
    test.description =
    `change local config, then merge
     file endings should be preserved
     local config should have auto.crlf false
     global config should not be modified
    `
    providerDst.filesDelete( localPath );
    let remotePath = 'git+hd://' + repoPath;

    let autocrlfGlobalOriginal = gitConfigGlobalRead( 'core.autocrlf' );

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    .then( () =>
    {
      let start = _.process.starter
      ({
        currentPath : localPath,
        sync : 1
      });

      start( 'git reset --hard HEAD~1' )
      start( 'git commit -m emptycommit --allow-empty' )
      start( 'git config --local core.autocrlf true' )

      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    })
    .then( () =>
    {
      test.case = 'global git config was not changed';
      let autocrlfGlobal = gitConfigGlobalRead( 'core.autocrlf' );
      test.identical( autocrlfGlobal, autocrlfGlobalOriginal );

      let autocrlfLocal = gitConfigLocalRead( localPath, 'core.autocrlf' )
      test.identical( autocrlfLocal, 'true' );

      let hash1 = providerDst.hashRead( path.join( localPath, 'file1' ) );
      test.identical( hash1, expectedHash1 );
      let hash2 = providerDst.hashRead( path.join( localPath, 'file2' ) );
      test.identical( hash2, expectedHash2 );
      return null;
    })

    _.process.start
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.is( _.strHas( got.output, `emptycommit` ) )
      return null;
    })

    return ready;
  })

  /* - */

  con
  .then( () =>
  {
    test.description =
    `extra.stashing enabled
     change local config, then merge
     file endings should be preserved
     local config should have auto.crlf false
     global config should not be modified
    `
    providerDst.filesDelete( localPath );
    let remotePath = 'git+hd://' + repoPath;

    let autocrlfGlobalOriginal = gitConfigGlobalRead( 'core.autocrlf' );

    let ready = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    .then( () =>
    {
      let start = _.process.starter
      ({
        currentPath : localPath,
        sync : 1
      });

      start( 'git reset --hard HEAD~1' )
      start( 'git commit -m emptycommit --allow-empty' )
      start( 'git config --local core.autocrlf true' )

      providerDst.fileWrite( path.join( localPath, 'file1' ), 'abcc\n' );

      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra : { stashing : 1 } })
    })
    .then( () =>
    {
      test.case = 'global git config was not changed';
      let autocrlfGlobal = gitConfigGlobalRead( 'core.autocrlf' );
      test.identical( autocrlfGlobal, autocrlfGlobalOriginal );

      let autocrlfLocal = gitConfigLocalRead( localPath, 'core.autocrlf' )
      test.identical( autocrlfLocal, 'true' );

      let hash1 = providerDst.hashRead( path.join( localPath, 'file1' ) );
      test.notIdentical( hash1, expectedHash1 );
      let hash2 = providerDst.hashRead( path.join( localPath, 'file2' ) );
      test.identical( hash2, expectedHash2 );
      return null;
    })

    _.process.start
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready,
      outputCollecting : 1
    })
    .then( ( got ) =>
    {
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.is( _.strHas( got.output, `emptycommit` ) )
      return null;
    })

    return ready;
  })

  return con;

  /* - */

  function prepare()
  {
    let start = _.process.starter({ currentPath : repoPath, ready : con });
    con.then( () =>
    {
      providerDst.dirMake( repoPath );
      providerDst.fileWrite( path.join( repoPath, 'file1' ), 'abc\n' );
      providerDst.fileWrite( path.join( repoPath, 'file2' ), 'abc\r\n' );
      return null;
    });

    start( 'git init' )
    start( 'git config --local core.autocrlf false' )
    start( 'git add .' )
    start( 'git commit -m init' )
    start( 'git commit -m change --allow-empty' )
    start( 'git checkout -b secondbranch' )

    con.then( () =>
    {
      expectedHash1 = providerDst.hashRead( path.join( repoPath, 'file1' ) );
      expectedHash2 = providerDst.hashRead( path.join( repoPath, 'file2' ) );
      return null;
    });
  }

  function gitConfigGlobalRead( property )
  {
    let o =
    {
      execPath : 'git config --get --global ' + property,
      sync : 1,
      outputCollecting : 1
    };
    var got = _.process.start( o );
    return _.strStrip( got.output );
  }

  function gitConfigLocalRead( localPath, property )
  {
    let o =
    {
      execPath : 'git config --get --local ' + property,
      currentPath : localPath,
      sync : 1,
      outputCollecting : 1
    };
    var got = _.process.start( o );
    return _.strStrip( got.output );
  }

  function gitConfigLocalWrite( localPath, property )
  {
    let o =
    {
      execPath : 'git config --local ' + property,
      currentPath : localPath,
      sync : 1
    };
    _.process.start( o );
  }
}

filesReflectEol.timeOut = 120000;

//

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.Git',
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
    gitConfigStart : null,
    gitOriginalCoreAutocrlf : null,
    system : null
  },

  tests :
  {
    filesReflectTrivial,
    filesReflectNoStashing,
    filesReflectDownloadThrowing,
    filesReflectEol
  },

}

//

var Self = new wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
