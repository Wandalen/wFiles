( function _FileProvider_Git_test_ss_( ) {

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

  context.providerSrc = _.FileProvider.Git();
  context.providerDst = _.FileProvider.HardDrive();
  context.system = _.FileProvider.System({ providers : [ context.providerSrc, context.providerDst ] });
  context.system.defaultProvider = context.providerDst;

  let path = context.providerDst.path;

  context.suitePath = path.pathDirTempOpen( path.join( __dirname, '../..'  ),'FileProviderGit' );
  context.suitePath = context.providerDst.pathResolveLinkFull({ filePath : context.suitePath, resolvingSoftLink : 1 });
  context.suitePath = context.suitePath.absolutePath;

}

function onSuiteEnd( test )
{
  let context = this;
  let path = context.providerDst.path;
  _.assert( _.strHas( context.suitePath, 'FileProviderGit' ), context.suitePath );
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
  let localPath = path.join( testPath, 'wPathBasic' );
  debugger;
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );

  let con = new _.Consequence().take( null )

  .then( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git';
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
    test.case = 'hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git#master';
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
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git#master';
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
    let remotePath = 'git+https:///github.com/Wandalen/wPathBasic.git#master';
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
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) )
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
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) )
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
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) )
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
    let remotePathUnknownHash = 'git+https:///github.com/Wandalen/wPathBasic.git#other';

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
    let remotePathUnknownHash = 'git+https:///github.com/Wandalen/wPathBasic.git#other';

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
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) )
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
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) )
      return null;
    })

    return ready;
  })

  return con;
}

filesReflectTrivial.timeOut = 60000;

//

function filesReflectNoStashing( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let testPath = path.join( context.suitePath, 'routine-' + test.name );
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

filesReflectNoStashing.timeOut = 60000;

//

function filesReflectDownloadErrors( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let system = context.system;
  let path = context.providerDst.path;
  let testPath = path.join( context.suitePath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'wPathBasic' );
  let clonePathGlobal = providerDst.path.globalFromPreferred( localPath );

  let con = new _.Consequence().take( null )

  .then( () =>
  {
    test.case = 'error on download, new directory should not be made';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///githu.com/Wandalen/wPathBasic.git';

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
    let remotePath = 'git+https:///githu.com/Wandalen/wPathBasic.git';

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
      let got = _.git.isDownloadedFromRemote({ localPath, remotePath });
      test.identical( got.downloaded, true )
      test.identical( got.downloadedFromRemote, true )
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

  return con;
}

filesReflectDownloadErrors.timeOut = 60000;

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
    suitePath : null,
    providerSrc : null,
    providerDst : null,
    system : null
  },

  tests :
  {
    filesReflectTrivial,
    filesReflectNoStashing,
    filesReflectDownloadErrors,
  },

}

//

var Self = new wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
