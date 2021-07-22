( function _FileProvider_Git_test_ss_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Git.ss' );
}

/* qqq : use test modules instead of real modules */

//

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
var RunningInsideTestContainer = _.process.insideTestContainer();

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Git();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });
  context.system.defaultProvider = context.providerDst;

  context.suiteTempPath = context.providerDst.path.tempOpen( context.providerDst.path.join( __dirname, '../..' ), 'FileProviderGit' );

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
  context.providerDst.path.tempClose( context.suiteTempPath );
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
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );

  let con = new _.Consequence().take( null )

  .then( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
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
      './License',
      './package.json',
      './Readme.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
      './will.yml',
    ];

    test.true( _.arraySetContainAll_( files, expected ) );
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'no hash, trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
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
      './License',
      './package.json',
      './Readme.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
      './will.yml',
    ];

    test.true( _.arraySetContainAll_( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'tag, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!master';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
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
      './License',
      './package.json',
      './Readme.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
      './will.yml',
    ];

    test.true( _.arraySetContainAll_( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'not existing repository';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///DoesNotExist.git';
    let result = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
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
    let o = { reflectMap : { [ remotePath ] : clonePathGlobal } };

    let ready = new _.Consequence().take( null );
    ready.then( () => system.filesReflect( _.props.extend( null, o ) ) )
    ready.then( () => system.filesReflect( _.props.extend( null, o ) ) )

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
      './License',
      './package.json',
      './Readme.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
      './will.yml',
    ]

    test.true( _.arraySetContainAll_( files, expected ) )
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
    ready.then( () => system.filesReflect( _.props.extend( null, o ) ) )
    ready.then( () => system.filesReflect( _.props.extend( null, o ) ) )

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
      './License',
      './package.json',
      './Readme.md',
      './doc',
      './out',
      './out/wPathBasic.out.will.yml',
      './proto',
      './sample',
      './will.yml',
    ]

    test.true( _.arraySetContainAll_( files, expected ) )
    return got;
  })

  /*  */

  .then( () =>
  {
    test.case = 'commit hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
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

    test.true( _.arraySetContainAll_( files, expected ) )
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
      var exp = [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ];
      test.true( _.strHasAny( got.output, exp ) )
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
      test.true( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 1 commit` ) )
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
      test.true( !_.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.true( _.strHas( got.output, `emptycommit` ) )
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
      test.true( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 2 commits` ) )
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
      test.true( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.true( _.strHas( got.output, `emptycommit` ) )
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
      var exp = [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ];
      test.true( _.strHasAny( got.output, exp ) )
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
      var exp = [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ];
      test.true( _.strHasAny( got.output, exp ) )
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
      providerDst.fileWrite( providerDst.path.join( localPath, 'Readme.md' ), 'test' );
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
      test.true( _.strHas( got.output, `modified:   Readme.md` ) )
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
      test.true( _.strHas( got.output, `modified:   Readme.md` ) )
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
      var exp = [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ];
      test.true( _.strHasAny( got.output, exp ) )
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
      var exp = [ `Your branch is up to date with 'origin/master'.`, `Your branch is up-to-date with 'origin/master'.` ];
      test.true( _.strHasAny( got.output, exp ) )
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
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
  })
  .then( () =>
  {
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/#b5409b80e185d20b5936dd01451510cb2ecc02fe';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
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

    test.true( _.arraySetContainAll_( files, expected ) );
    return got;
  })

  /* */

  .then( () =>
  {
    test.case = 'download repo, then try to checkout using branch name as hash';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
  })
  .then( () =>
  {
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/#master';
    let con = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
    return test.shouldThrowErrorAsync( con );
  })

  /* */

  .then( () =>
  {
    test.case = 'download repo, then try to checkout using unknown branch name as tag';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
  })
  .then( () =>
  {
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git/!master2';
    let con = system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal } });
    return test.shouldThrowErrorAsync( con );
  });

  /* - */

  return con;
}

filesReflectTrivial.timeOut = 240000;

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
      _.fileProvider.fileWrite( _.path.join( localPath, 'Readme.md' ), '' );
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
      test.true( _.strHas( got.output, `modified:   Readme.md` ) )
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
      test.true( !providerDst.fileExists( localPath ) )
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
      test.true( !providerDst.fileExists( localPath ) )
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
      test.true( !providerDst.fileExists( localPath ) )
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
      test.true( !providerDst.fileExists( localPath ) )
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
      test.true( providerDst.fileExists( localPath ) );
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
      test.true( providerDst.fileExists( localPath ) );
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
      test.true( providerDst.isTerminal( localPath ) );
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
        test.true( providerDst.fileExists( localPath ) );
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
      test.true( !providerDst.fileExists( localPath ) )
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
  let expectedHash1, expectedHash2;
  let con = new _.Consequence().take( null );

  /* */

  let config = _.process.start
  ({
    execPath : 'git config --get --global core.autocrlf',
    sync : 1,
    outputCollecting : 1,
    throwingExitCode : 0,
  });

  if( config.exitCode !== 0 && !_.process.insideTestContainer() )
  {
    test.true( true );
    return;
  }

  /* */

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

      let branch = _.git.localVersion({ localPath });
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

      let branch = _.git.localVersion({ localPath });
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
      test.true( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.true( _.strHas( got.output, `emptycommit` ) )
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
      test.true( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.true( _.strHas( got.output, `emptycommit` ) )
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
      test.true( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) )
      test.true( _.strHas( got.output, `emptycommit` ) )
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

function filesReflectFetchingTags( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let a = test.assetFor( false );
  let repoPath = a.abs( 'repo' );
  let localPath = a.abs( 'clone' );
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );
  let remotePath = `git+hd://${repoPath}`;
  let escapeCaret = process.platform === 'win32' ? '^' : '';

  a.shellSync = _.process.starter
  ({
    currentPath : a.abs( '.' ),
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    sync : 1,
    deasync : 0,
    ready : null
  })

  a.init = ( o ) =>
  {
    o = o || {}

    a.ready.then( () =>
    {
      a.fileProvider.filesDelete( a.abs( '.' ) );
      a.reflect();
      a.fileProvider.dirMake( repoPath );
      a.shellSync( 'git -C repo init' );
      a.shellSync( 'git -C repo commit --allow-empty -m initial' );
      a.shellSync( 'git -C repo tag tag1' );
      return null;
    })

    if( o.download )
    a.ready.then( () =>
    {
      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    })

    return a.ready;
  }

  /* */

  a.init()
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 0 }
    test.case = `first download, remote has a tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init()
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 0 }
    test.case = `first download, remote has a tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init()
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 1 }
    test.case = `first download, remote has a tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init()
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 1 }
    test.case = `first download, remote has a tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo tag tag2' )
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 0 }
    test.case = `update, remote has a new tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      test.false( _.strHas( got.output, 'tag2' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      test.identical( tagVersionLocal, false )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo tag tag2' )
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 0 }
    test.case = `update, remote has a new tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag2' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo tag tag2' )
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 1 }
    test.case = `update, remote has a new tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag2' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo tag tag2' )
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 1 }
    test.case = `update, remote has a new tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag2' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( 'git -C repo tag -f tag1' )
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 0 }
    test.case = `update, remote has a updated tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.notIdentical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( 'git -C repo tag -f tag1' )
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 0 }
    test.case = `update, remote has a updated tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.notIdentical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( 'git -C repo tag -f tag1' )
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 1 }
    test.case = `update, remote has a updated tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( 'git -C repo tag -f tag1' )
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 1 }
    test.case = `update, remote has a updated tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone tag' );
      test.true( _.strHas( got.output, 'tag1' ) )
      let tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      let tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( `git -C repo tag tag2 tag1${ escapeCaret }^{}` )
  a.shell( 'git -C repo tag -d tag1' )
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 0 }
    test.case = `update, remote remamed existing tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone show-ref --tags' );
      test.true( _.strHas( got.output, 'tag1' ) )
      test.true( !_.strHas( got.output, 'tag2' ) )
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.identical( tagVersionRemote, false )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      test.identical( tagVersionLocal, false )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( `git -C repo tag tag2 tag1${ escapeCaret }^{}` )
  a.shell( 'git -C repo tag -d tag1' )
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 0 }
    test.case = `update, remote remamed existing tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone show-ref --tags' );
      test.true( _.strHas( got.output, 'tag1' ) )
      test.true( _.strHas( got.output, 'tag2' ) )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.true( _.strHas( got.output, tagVersionLocal ) )
      test.identical( tagVersionRemote, false )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( `git -C repo tag tag2 tag1${ escapeCaret }^{}` )
  a.shell( 'git -C repo tag -d tag1' )
  .then( () =>
  {
    let extra = { fetching : 0, fetchingTags : 1 }
    test.case = `update, remote remamed existing tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone show-ref --tags' );
      test.true( _.strHas( got.output, 'tag1' ) )
      test.true( _.strHas( got.output, 'tag2' ) )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.true( _.strHas( got.output, tagVersionLocal ) )
      test.identical( tagVersionRemote, false )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  /* */

  a.init({ download : 1 })
  a.shell( 'git -C repo commit --allow-empty -m test' )
  a.shell( `git -C repo tag tag2 tag1${ escapeCaret }^{}` )
  a.shell( 'git -C repo tag -d tag1' )
  .then( () =>
  {
    let extra = { fetching : 1, fetchingTags : 1 }
    test.case = `update, remote remamed existing tag ${_.entity.exportJs( extra ) }`
    return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let got = a.shellSync( 'git -C clone show-ref --tags' );
      test.true( _.strHas( got.output, 'tag1' ) )
      test.true( _.strHas( got.output, 'tag2' ) )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 1, remote : 0 });
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag1', local : 0, remote : 1 });
      test.true( _.strHas( got.output, tagVersionLocal ) )
      test.identical( tagVersionRemote, false )
      var tagVersionLocal = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 1, remote : 0 });
      var tagVersionRemote = _.git.repositoryTagToVersion({ localPath, tag : 'tag2', local : 0, remote : 1 });
      test.identical( tagVersionLocal, tagVersionRemote )
      return null;
    })
  })

  return a.ready;
}

filesReflectFetchingTags.timeOut = 60000;

//

function filesReflectUpdateSwitchToOutdatedBranch( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let a = test.assetFor( false );
  let repoPath = a.abs( 'repo' );
  let localPath = a.abs( 'clone' );
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );
  let remotePath = `git+hd://${repoPath}`;

  a.shellSync = _.process.starter
  ({
    currentPath : a.abs( '.' ),
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    sync : 1,
    deasync : 0,
    ready : null
  })

  a.init = ( o ) =>
  {
    o = o || {}

    a.ready.then( () =>
    {
      a.fileProvider.filesDelete( a.abs( '.' ) );
      a.reflect();
      a.fileProvider.dirMake( repoPath );
      a.shellSync( 'git -C repo init' );
      a.shellSync( 'git -C repo commit --allow-empty -m initial' );
      a.shellSync( 'git -C repo branch second' );
      a.shellSync( 'git -C repo checkout master' );

      return null;
    })

    a.ready.then( () =>
    {
      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 })
    })

    return a.ready;
  }

  /* */

  a.init()
  a.shell( 'git -C clone checkout second' )
  a.shell( 'git -C repo commit --allow-empty -m new' )
  .then( () =>
  {
    test.case = 'local master is stale, switching to master, fetchin is off';
    let extra = { fetching : 0, fetchingTags : 0 }
    test.case = `first download, remote has a tag ${_.entity.exportJs( extra ) }`
    let remotePathToMaster = `${remotePath}/!master`
    return system.filesReflect({ reflectMap : { [ remotePathToMaster ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let currentBranch = _.git.localVersion( repoPath );
      test.identical( currentBranch, 'master' );

      let remoteVersion = getHead( repoPath );
      let cloneVersion = getHead( localPath );

      console.log( 'remote:', remoteVersion )
      console.log( 'updated clone:', cloneVersion )

      test.notIdentical( remoteVersion, cloneVersion );

      return null;
    })
  })

  /* */

  a.init()
  a.shell( 'git -C clone checkout second' )
  a.shell( 'git -C repo commit --allow-empty -m new' )
  .then( () =>
  {
    test.case = 'local master is stale, switching to master, fetchin is on';
    let extra = { fetching : 1, fetchingTags : 0 }
    test.case = `first download, remote has a tag ${_.entity.exportJs( extra ) }`
    let remotePathToMaster = `${remotePath}/!master`
    return system.filesReflect({ reflectMap : { [ remotePathToMaster ] : clonePathGlobal }, verbosity : 5, extra })
    .then( () =>
    {
      let currentBranch = _.git.localVersion( repoPath );
      test.identical( currentBranch, 'master' );

      let remoteVersion = getHead( repoPath );
      let cloneVersion = getHead( localPath );

      console.log( 'remote:', remoteVersion )
      console.log( 'updated clone:', cloneVersion )

      test.identical( remoteVersion, cloneVersion );

      return null;
    })
  })

  /* - */

  return a.ready;

  function getHead( localPath, branch )
  {
    if( !branch )
    branch = 'master';

    let result = a.shellSync
    ({
      execPath : `git show-ref refs/heads/${branch} --hash`,
      currentPath : localPath,
      outputPiping : 0,
      inputMirroring : 0,
      outputCollecting : 1
    })
    return result.output.trim();
  }
}

filesReflectUpdateSwitchToOutdatedBranch.timeOut = 30000;

//

function filesReflectCheckOptionFetchingDefaults( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;

  let a = test.assetFor( false );
  let clonePathGlobal = providerDst.path.globalFromPreferred( a.abs( '.' ) );
  let remotePath = 'git+https:///github.com/Wandalen/wModuleForTesting1.git';

  // if( process.platform === 'win32' || process.platform === 'darwin' || !_.process.insideTestContainer() )
  // return test.true( true );

  /* - */

  let netInterfaces = __.test.netInterfacesGet({ activeInterfaces : 1, sync : 1 });
  a.ready.then( () => __.test.netInterfacesDown({ interfaces : netInterfaces }) );

  /* */

  a.ready.then( () =>
  {
    test.case = `default options`;
    var onErrorCallback = ( err, arg ) =>
    {
      test.true( _.error.is( err ) );
      test.identical( arg, undefined );
      var exp = `Attempts is exhausted, made 3 attempts`;
      test.identical( _.strCount( err.originalMessage, exp ), 1 );
      test.identical( _.strCount( err.originalMessage, `Could not resolve host` ), 1 );
      return null;
    };
    return test.shouldThrowErrorAsync( () =>
    {
      return system.filesReflect
      ({
        reflectMap : { [ remotePath ] : clonePathGlobal },
        verbosity : 5
      });
    }, onErrorCallback );
  });

  /* */

  a.ready.then( () =>
  {
    test.case = `not default options`;
    var start = _.time.now();
    var onErrorCallback = ( err, arg ) =>
    {
      var spent = _.time.now() - start;
      test.ge( spent, 3500 )
      test.true( _.error.is( err ) );
      test.identical( arg, undefined );
      var exp = `Attempts is exhausted, made 4 attempts`;
      test.identical( _.strCount( err.originalMessage, exp ), 1 );
      test.identical( _.strCount( err.originalMessage, `Could not resolve host` ), 1 );
      return null;
    };
    return test.shouldThrowErrorAsync( () =>
    {
      var fetchingDefaults  =
      {
        attemptLimit : 4,
        attemptDelay : 500,
        attemptDelayMultiplier : 2,
      };
      return system.filesReflect
      ({
        reflectMap : { [ remotePath ] : clonePathGlobal },
        verbosity : 5,
        extra : { fetchingDefaults }
      });
    }, onErrorCallback );
  });

  /* */

  a.ready.finally( () => __.test.netInterfacesUp({ interfaces : netInterfaces }) );

  /* - */

  return a.ready;
}

filesReflectCheckOptionFetchingDefaults.timeOut = 60000;

//

// function filesReflectPerformance( test )
// {
//   let context = this;
//   let providerSrc = context.providerSrc;
//   let providerDst = context.providerDst;
//   let system = context.system;
//   let path = context.providerDst.path;
//
//   let testPath = path.join( context.suiteTempPath, 'routine-' + test.name );
//   let localPath = path.join( testPath, '' );
//   let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );
//
//   let shellLocal = _.process.starter
//   ({
//     currentPath : localPath,
//     mode : 'shell'
//   })
//
//   let con = new _.Consequence().take( null )
//
//   .then( () =>
//   {
//     let t1;
//     providerDst.filesDelete( localPath );
//     let remotePathFixate =
//     'git+https:///github.com/Wandalen/wPathBasic.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
//     let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
//
//     let ready = system.filesReflect({ reflectMap : { [ remotePath ] :
//     clonePathGlobal }, verbosity : 5 });
//
//     ready.then( () =>
//     {
//       let structure = { dependencies : { 'willbe' : 'alpha' } };
//       providerDst.fileWrite({ filePath : path.join( localPath,
//       'package.json' ), data : structure, encoding : 'json' });
//       return null;
//     })
//
//     ready.then( () => shellLocal({ execPath : 'npm install', outputPiping : 0 }) );
//     ready.then( () => shellLocal( 'git reset --hard' ) );
//
//     ready.then( () =>
//     {
//       t1 = _.time.now();
//       return system.filesReflect({ reflectMap : { [ remotePathFixate ] :
//       clonePathGlobal }, verbosity : 5 })
//     });
//
//     ready.then( ( got ) =>
//     {
//       console.log( _.time.spent( t1 ) );
//       test.identical( got.exitCode, 0 );
//       return null;
//     })
//
//     return ready;
//   })
//
//   return con;
//
//   /* */
//
//   function init()
//   {
//     let data = { dependencies : { willbe : '', wTesting : '' } };
//     a.shell( 'git init' );
//     a.shell( 'git commit --allow-empty -m "init"' );
//     a.shell( 'git branch one' );
//     a.shell( 'git branch two' );
//     a.ready.then( () =>
//     {
//       a.fileProvider.configWrite({ filePath : a.abs( 'package.json' ), data, encoding : 'json' });
//       return null;
//     });
//     a.shell( 'git add .' );
//     a.shell( 'git commit -m "package"' );
//     return a.ready;
//   }
// }
//
// filesReflectPerformance.timeOut = 120000;

function filesReflectPerformance( test )
{
  let context = this;
  let system = context.system;
  let a = test.assetFor( false );
  let repoPath = a.abs( 'repo' );
  let remotePath = `git+hd://${repoPath}`;
  let localPath = a.abs( 'clone' );
  let clonePathGlobal = a.fileProvider.path.globalFromPreferred( localPath );
  let start;

  /* - */

  const times = 1;
  const runsWithout = [];
  const runsWith = [];
  for( let i = 0 ; i < times; i++ )
  run();

  a.ready.then( () =>
  {
    const averageWithout = runsWithout.reduce( ( s, e ) => s + e ) / times;
    const averageWith = runsWith.reduce( ( s, e ) => s + e ) / times;
    console.log( averageWithout );
    console.log( averageWith );
    return null;
  });

  /* */

  function run()
  {
    init().then( () =>
    {
      test.case = 'without installed dependencies';
      return null;
    });
    a.ready.then( () =>
    {
      start = _.time.now();
      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, outputFormat : 'nothing' });
    });
    a.ready.then( () =>
    {
      let spent = _.time.now() - start;
      runsWithout.push( spent );
      test.le( spent, 10000 );
      return null;
    });

    /* */

    init().then( () =>
    {
      test.case = 'with installed dependencies';
      return null;
    });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'npm install' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git reset --hard' });
    a.ready.then( () =>
    {
      console.log( '------reflect-------')
      start = _.time.now();
      return system.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5, outputFormat : 'nothing' });
    });
    a.ready.then( () =>
    {
      let spent = _.time.now() - start;
      runsWith.push( spent );
      test.le( spent, 10000 );
      return null;
    });
  }

  /* - */

  return a.ready;

  /* */

  function init()
  {
    a.ready.then( () => a.fileProvider.filesDelete( a.abs( '.' ) ) );
    a.ready.then( () => { a.fileProvider.dirMake( a.abs( 'repo' ) ); return null } );
    a.shell({ currentPath : repoPath, execPath : 'git init --bare' });
    a.shell( 'git clone repo clone' );
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git commit --allow-empty -m "init"' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git branch one' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git branch two' });
    a.ready.then( () =>
    {
      let data = { dependencies : { willbe : '', wTesting : '' } };
      a.fileProvider.fileWrite({ filePath : a.abs( 'clone/package.json' ), data, encoding : 'json' });
      return null;
    });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git add .' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git commit -m "package"' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git push' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git push -u origin one' });
    a.shell({ currentPath : a.abs( 'clone' ), execPath : 'git push -u origin two' });
    return a.ready;
  }

  /*
     Results of benchmark. The average time for 5 runs:
     without dependencies - 0.52s
     with dependencies - 34.58s
  */
}

filesReflectPerformance.timeOut = 500000;
filesReflectPerformance.experimental = 1;

//

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.fileProvider.Git',
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
    filesReflectEol,
    filesReflectFetchingTags,
    filesReflectUpdateSwitchToOutdatedBranch,
    filesReflectCheckOptionFetchingDefaults,
    filesReflectPerformance,
  },

}

//

const Self = wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
