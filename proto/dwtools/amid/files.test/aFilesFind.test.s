( function _FilesFind_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );

  // if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  var crypto = require( 'crypto' );
  var waitSync = require( 'wait-sync' );

}

//

var _ = _global_.wTools;
var Parent = wTester;

//

function onSuiteBegin( test )
{
  this.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'FileProvider/Abstract' );
}

//

function pathFor( filePath )
{
  filePath =  _.path.join( this.testRootDirectory, filePath );
  return _.path.normalize( filePath );
}

//

function providerIsInstanceOf( src )
{
  var self = this;

  if(  self.provider instanceof src )
  return true;

  if( _.FileProvider.Hub && self.provider instanceof _.FileProvider.Hub )
  {
    var testPath = self.pathFor( 'testPath' );
    var provider = self.provider.providerForPath( testPath );
    if( provider instanceof src )
    return true;
  }

  return false;
}

//

function symlinkIsAllowed()
{
  var self = this;

  if( Config.platform === 'nodejs' && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allowed = false;
    var dir = self.pathFor( 'symlinkIsAllowed' );
    var srcPath = self.pathFor( 'symlinkIsAllowed/src' );
    var dstPath = self.pathFor( 'symlinkIsAllowed/dst' );

    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );

    try
    {
      self.provider.softLink({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allowed = self.provider.isSoftLink( dstPath );
    }
    catch( err )
    {
      logger.error( err );
    }

    return allowed;
  }

  return true;
}

//

function filesFindLinked( test )
{
  let self = this;
  let workDir = test.context.pathFor( test.name );
  let provider = self.provider;

  /*
    link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]
  */

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    double : [{ softLink : '/normal' }],
    broken : [{ softLink : '/missing' }],
    brokenChain : [{ softLink : '/broken' }],
    selfCycled : [{ softLink : '/selfCycled' }],
    cycled :
    {
      one : [{ softLink : '/cycled/two' }],
      two : [{ softLink : '/cycled/one' }],
    },
    toSameFile :
    {
      one : [{ softLink : '/terminal' }],
      two : [{ softLink : '/terminal' }],
    }
  }

  //

  function select( container, path )
  {
    let result = _.select( container, path );
    if( _.strIs( result[ 0 ] ) )
    result = result.map( ( e ) => _.strPrependOnce( _.strRemoveBegin( e, workDir ), '/' ) );
    return result;
  }

  //

  let terminalPath = self.provider.path.join( workDir, 'terminal' );
  let normalPath = self.provider.path.join( workDir, 'normal' );
  let doublePath = self.provider.path.join( workDir, 'double' );
  let brokenPath = self.provider.path.join( workDir, 'broken' );
  let missingPath = self.provider.path.join( workDir, 'missing' );
  let selfPath = self.provider.path.join( workDir, 'self' );
  let onePath = self.provider.path.join( workDir, 'one' );
  let twoPath = self.provider.path.join( workDir, 'two' );
  let normalaPath = self.provider.path.join( workDir, 'normala' );
  let normalbPath = self.provider.path.join( workDir, 'normalb' );
  let dirPath = self.provider.path.join( workDir, 'directory' );
  let toDirPath = self.provider.path.join( workDir, 'toDir' );

  //

  test.open( 'normal' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/terminal' ] );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal' ] );

  test.close( 'normal' );

  /* */

  test.open( 'double' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    double : [{ softLink : '/normal' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );
  self.provider.softLink( doublePath, normalPath );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/double', '/normal', '/terminal' ] );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal', '/terminal' ] );

  test.close( 'double' );

  /* */

  test.open( 'broken' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    broken : [{ softLink : '/missing' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );
  self.provider.softLink({ dstPath : brokenPath, srcPath : missingPath, allowingMissing : 1 });

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 0,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/broken', '/normal', '/terminal' ] );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/broken', '/normal', '/terminal' ] );

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : workDir,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissing : 0,
      includingDirs : 1,
      recursive : '2',
      includingStem : 1,
    })
  })

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/missing', '/terminal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, false, true, true ] );

  test.close( 'broken' );

  /* */

  test.open( 'self cycled' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    self : [{ softLink : '/self' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalPath, terminalPath );
  self.provider.softLink({ dstPath : selfPath, srcPath : '../self', allowingMissing : 1 });

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 0,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/',  '/normal', '/self', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/self', '/terminal' ] );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/self', '/terminal'] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/self', '/terminal' ] );

  test.shouldThrowErrorSync( () =>
  {
    let found = provider.filesFind
    ({
      filePath : workDir,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissing : 0,
      includingDirs : 1,
      recursive : '2',
      includingStem : 1,
    });
  });

  provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  var tree =
  {
    terminal : 'terminal',
    one : [{ softLink : '/two' }],
    two : [{ softLink : '/one' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink({ dstPath : twoPath, srcPath : onePath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : onePath, srcPath : twoPath, allowingMissing : 1 });

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 0,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : workDir,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissing : 0,
      includingDirs : 1,
      recursive : '2',
      includingStem : 1,
    })
  })

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissing : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  var tree =
  {
    terminal : 'terminal',
    normala : [{ softLink : '/terminal' }],
    normalb : [{ softLink : '/terminal' }],
  }

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalPath, terminalPath );
  self.provider.softLink( normalaPath,terminalPath );
  self.provider.softLink( normalbPath,terminalPath );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normala', '/normalb', '/terminal' ] );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal', '/terminal' ] );

  test.close( 'links to same file' );

  /**/

  test.open( 'link to directory' );

  var tree =
  {
    directory :
    {
      terminal : 'terminal',
    },
    toDir : [{ softLink : '/directory' }],
  }

  var terminalInDirPath = self.provider.path.join( dirPath, 'terminal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  self.provider.softLink( toDirPath,dirPath );

  var got = provider.filesFind
  ({
    filePath : toDirPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir'  ] );
  test.identical( select( got, '*/real' ), [ '/toDir' ] );

  // debugger;
  var got = provider.filesFind
  ({
    filePath : toDirPath,
    outputFormat : 'record',
    resolvingSoftLink : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : '2',
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/directory', '/directory/terminal'  ] );

  test.close( 'link to directory' );

  /**/

  test.open( 'link to processed directory' );

  var tree =
  {
    directory :
    {
      terminal : 'terminal'
    },
    toDir : [{ softLink : '/directory'}]
  }

  var terminalInDirPath = self.provider.path.join( dirPath, 'terminal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  self.provider.softLink( toDirPath,dirPath );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })

  test.identical( select( got, '*/absolute' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );

  var got = provider.filesFind
  ({
    filePath : workDir,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : '2',
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/directory', '/directory/terminal', '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/directory', '/directory/terminal', '/directory', '/directory/terminal'  ] );

  test.close( 'link to processed directory' );
}

//

function filesReflectLinked( test )
{
  var self = this;

  var testDir = _.path.join( self.testRootDirectory, test.name );
  var srcDir = _.path.join( testDir, 'src' );
  var dstDir = _.path.join( testDir, 'dst' );

  logger.log( 'testDir', testDir );

  _.fileProvider.filesDelete( testDir );

  _.fileProvider.dirMake( srcDir );

  _.fileProvider.fileWrite( _.path.join( srcDir, 'file' ), 'file' );

  _.fileProvider.softLink
  ({
    srcPath : _.path.join( srcDir, 'fileNotExists' ),
    dstPath : _.path.join( srcDir, 'link' ),
    allowingMissing : 1,
  })

  _.fileProvider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  });

  test.is( _.fileProvider.fileExists( _.path.join( dstDir, 'file' ) ) )
  test.is( !_.fileProvider.fileExists( _.path.join( dstDir, 'link' ) ) )

  /**/

  _.fileProvider.filesDelete( testDir );

  _.fileProvider.dirMake( srcDir );
  _.fileProvider.dirMake( dstDir );

  _.fileProvider.fileWrite( _.path.join( srcDir, 'link' ), 'file' );

  _.fileProvider.softLink
  ({
    srcPath : _.path.join( dstDir, 'fileNotExists' ),
    dstPath : _.path.join( dstDir, 'link' ),
    allowingMissing : 1
  });

  _.fileProvider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  });

  /*
    !!! qqq : dstDir/link should be link and dstDir/fileNotExists should exists if resolvingDstSoftLink : 1
    but resolvingDstSoftLink is 0 by default
    so resolvingDstSoftLink option is NOT COVERED by tests at all!

    seems File.copyFileSync works if resolvingDstSoftLink is always 1
  */

  test.is( !_.fileProvider.isSoftLink( _.path.join( dstDir, 'link' ) ) );
  test.identical( _.fileProvider.fileRead( _.path.join( dstDir, 'link' ) ), 'file' );

  /* */

  test.case = 'src - link to missing, dst - link to missing'
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( srcDir, 'fileNotExists' ),
    dstPath : _.path.join( srcDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( dstDir, 'fileNotExists' ),
    dstPath : _.path.join( dstDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })

  _.fileProvider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( _.fileProvider.isSoftLink( _.path.join( dstDir, 'link' ) ) );
  var dstLink1 = _.fileProvider.pathResolveSoftLink({ filePath : _.path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink1, _.path.join( dstDir, 'fileNotExists' ) );

  /* */

  test.case = 'src - link to missing, dst - link to terminal'
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( srcDir, 'fileNotExists' ),
    dstPath : _.path.join( srcDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })
  _.fileProvider.fileWrite( _.path.join( dstDir, 'file' ), 'file' );
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( dstDir, 'file' ),
    dstPath : _.path.join( dstDir, 'link' ),
    makingDirectory : 1
  })

  _.fileProvider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( _.fileProvider.isSoftLink( _.path.join( dstDir, 'link' ) ) );
  var dstLink1 = _.fileProvider.pathResolveSoftLink({ filePath : _.path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink1, _.path.join( dstDir, 'file' ) );

  /* */

  test.case = 'src - link to terminal, dst - link to missing'
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.fileWrite( _.path.join( srcDir, 'file' ), 'file' );
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( srcDir, 'file' ),
    dstPath : _.path.join( srcDir, 'link' ),
    makingDirectory : 1
  })
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( dstDir, 'fileNotExists' ),
    dstPath : _.path.join( dstDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })

  _.fileProvider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should be rewritten by srcDir/link'
  test.is( !_.fileProvider.isSoftLink( _.path.join( dstDir, 'link' ) ) );
  test.is( _.fileProvider.isTerminal( _.path.join( dstDir, 'link' ) ) );
  var read = _.fileProvider.fileRead({ filePath : _.path.join( dstDir, 'link' ) });
  test.identical( read, 'file' );

  /* */

  test.case = 'src - no files, dst - link to missing'
  _.fileProvider.filesDelete( testDir );
  _.fileProvider.softLink
  ({
    srcPath : _.path.join( dstDir, 'fileNotExists' ),
    dstPath : _.path.join( dstDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })

  _.fileProvider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( _.fileProvider.isSoftLink( _.path.join( dstDir, 'link' ) ) );
  var dstLink4 = _.fileProvider.pathResolveSoftLink({ filePath : _.path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink4, _.path.join( dstDir, 'fileNotExists' ) );

  //

  // /* old test case */

  // _.fileProvider.filesDelete( testDir );

  // _.fileProvider.dirMake( srcDir );
  // _.fileProvider.dirMake( dstDir );

  // _.fileProvider.fileWrite( _.path.join( srcDir, 'file' ), 'file' );
  // _.fileProvider.fileWrite( _.path.join( dstDir, 'file' ), 'file' );

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( srcDir, 'fileNotExists' ),
  //   dstPath : _.path.join( srcDir, 'link' ),
  //   allowingMissing : 1
  // })

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( srcDir, 'fileNotExists' ),
  //   dstPath : _.path.join( srcDir, 'link2' ),
  //   allowingMissing : 1
  // })

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( srcDir, 'file' ),
  //   dstPath : _.path.join( srcDir, 'link3' ),
  // })

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( dstDir, 'fileNotExists' ),
  //   dstPath : _.path.join( dstDir, 'link' ),
  //   allowingMissing : 1
  // })

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( dstDir, 'file' ),
  //   dstPath : _.path.join( dstDir, 'link2' ),
  // })

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( dstDir, 'fileNotExists' ),
  //   dstPath : _.path.join( dstDir, 'link3' ),
  //   allowingMissing : 1
  // })

  // _.fileProvider.softLink
  // ({
  //   srcPath : _.path.join( dstDir, 'fileNotExists' ),
  //   dstPath : _.path.join( dstDir, 'link4' ),
  //   allowingMissing : 1
  // })

  // _.fileProvider.filesReflect
  // ({
  //   reflectMap : { [ srcDir ] : dstDir },
  //   allowingMissing : 1,
  // })

  // test.is( _.fileProvider.isSoftLink( _.path.join( dstDir, 'link' ) ) );
  // var dstLink1 = _.fileProvider.pathResolveSoftLink({ filePath : _.path.join( dstDir, 'link' )/*, readLink : 1*/ });
  // test.identical( dstLink1, _.path.join( dstDir, 'fileNotExists' ) );

  // test.is( _.fileProvider.isSoftLink( _.path.join( dstDir, 'link2' ) ) );
  // var dstLink2 = _.fileProvider.pathResolveSoftLink({ filePath : _.path.join( dstDir, 'link2' )/*, readLink : 1*/ });
  // test.identical( dstLink2, _.path.join( dstDir, 'file' ) );

  // test.is( !_.fileProvider.isSoftLink( _.path.join( dstDir, 'link3' ) ) );
  // var read = _.fileProvider.fileRead({ filePath : _.path.join( dstDir, 'link3' ) });
  // test.identical( read, 'file' );

  // test.is( _.fileProvider.isSoftLink( _.path.join( dstDir, 'link4' ) ) );
  // var dstLink4 = _.fileProvider.pathResolveSoftLink({ filePath : _.path.join( dstDir, 'link4' )/*, readLink : 1*/ });
  // test.identical( dstLink4, _.path.join( dstDir, 'fileNotExists' ) );

  xxx

}

// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/FilesFind/Abstract',
  abstract : 1,
  silencing : 1,
  // verbosity : 7,

  onSuiteBegin : onSuiteBegin,

  context :
  {
    pathFor : pathFor,
    providerIsInstanceOf : providerIsInstanceOf,
    symlinkIsAllowed : symlinkIsAllowed,
    testRootDirectory : null,
  },

  tests :
  {
    filesFindLinked : filesFindLinked,
    filesReflectLinked : filesReflectLinked
  },

};

wTestSuite( Self );

})();
