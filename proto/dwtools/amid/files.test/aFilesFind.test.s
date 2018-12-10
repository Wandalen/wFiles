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
  let path = self.provider.path;

  /*
    link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]
  */

  //

  function select( container, path )
  {
    let result = _.select( container, path );
    if( _.strIs( result[ 0 ] ) )
    result = result.map( ( e ) => _.strPrependOnce( _.strRemoveBegin( e, workDir ), '/' ) );
    return result;
  }

  //

  let terminalPath = path.join( workDir, 'terminal' );
  let normalPath = path.join( workDir, 'normal' );
  let doublePath = path.join( workDir, 'double' );
  let brokenPath = path.join( workDir, 'broken' );
  let missingPath = path.join( workDir, 'missing' );
  let selfPath = path.join( workDir, 'self' );
  let onePath = path.join( workDir, 'one' );
  let twoPath = path.join( workDir, 'two' );
  let normalaPath = path.join( workDir, 'normala' );
  let normalbPath = path.join( workDir, 'normalb' );
  let dirPath = path.join( workDir, 'directory' );
  let toDirPath = path.join( workDir, 'toDir' );

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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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
  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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

  var got = self.provider.filesFind
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
  let self = this;
  let workDir = test.context.pathFor( test.name );
  let provider = self.provider;
  let path = self.provider.path;

  var srcDir = path.join( workDir, 'src' );
  var dstDir = path.join( workDir, 'dst' );

  logger.log( 'workDir', workDir );

  provider.filesDelete( workDir );

  provider.dirMake( srcDir );

  provider.fileWrite( path.join( srcDir, 'file' ), 'file' );

  provider.softLink
  ({
    srcPath : path.join( srcDir, 'fileNotExists' ),
    dstPath : path.join( srcDir, 'link' ),
    allowingMissing : 1,
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  });

  test.is( provider.fileExists( path.join( dstDir, 'file' ) ) )
  test.is( !provider.fileExists( path.join( dstDir, 'link' ) ) )

  /**/

  provider.filesDelete( workDir );

  provider.dirMake( srcDir );
  provider.dirMake( dstDir );

  provider.fileWrite( path.join( srcDir, 'link' ), 'file' );

  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissing : 1
  });

  provider.filesReflect
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

  test.is( !provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  test.identical( provider.fileRead( path.join( dstDir, 'link' ) ), 'file' );

  /* */

  test.case = 'src - link to missing, dst - link to missing'
  provider.filesDelete( workDir );
  provider.softLink
  ({
    srcPath : path.join( srcDir, 'fileNotExists' ),
    dstPath : path.join( srcDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  var dstLink1 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink1, path.join( dstDir, 'fileNotExists' ) );

  /* */

  test.case = 'src - link to missing, dst - link to terminal'
  provider.filesDelete( workDir );
  provider.softLink
  ({
    srcPath : path.join( srcDir, 'fileNotExists' ),
    dstPath : path.join( srcDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })
  provider.fileWrite( path.join( dstDir, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'file' ),
    dstPath : path.join( dstDir, 'link' ),
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  var dstLink1 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink1, path.join( dstDir, 'file' ) );

  /* */

  test.case = 'src - link to terminal, dst - link to missing'
  provider.filesDelete( workDir );
  provider.fileWrite( path.join( srcDir, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( srcDir, 'file' ),
    dstPath : path.join( srcDir, 'link' ),
    makingDirectory : 1
  })
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should be rewritten by srcDir/link'
  test.is( !provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  test.is( provider.isTerminal( path.join( dstDir, 'link' ) ) );
  var read = provider.fileRead({ filePath : path.join( dstDir, 'link' ) });
  test.identical( read, 'file' );

  /* */

  test.case = 'src - no files, dst - link to missing'
  provider.filesDelete( workDir );
  provider.softLink
  ({
    srcPath : path.join( dstDir, 'fileNotExists' ),
    dstPath : path.join( dstDir, 'link' ),
    allowingMissing : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcDir ] : dstDir },
    allowingMissing : 1,
  })

  test.will = 'dstDir/link should not be rewritten by srcDir/link'
  test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  var dstLink4 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  test.identical( dstLink4, path.join( dstDir, 'fileNotExists' ) );

  //

  // /* old test case */

  // provider.filesDelete( workDir );

  // provider.dirMake( srcDir );
  // provider.dirMake( dstDir );

  // provider.fileWrite( path.join( srcDir, 'file' ), 'file' );
  // provider.fileWrite( path.join( dstDir, 'file' ), 'file' );

  // provider.softLink
  // ({
  //   srcPath : path.join( srcDir, 'fileNotExists' ),
  //   dstPath : path.join( srcDir, 'link' ),
  //   allowingMissing : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( srcDir, 'fileNotExists' ),
  //   dstPath : path.join( srcDir, 'link2' ),
  //   allowingMissing : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( srcDir, 'file' ),
  //   dstPath : path.join( srcDir, 'link3' ),
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'fileNotExists' ),
  //   dstPath : path.join( dstDir, 'link' ),
  //   allowingMissing : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'file' ),
  //   dstPath : path.join( dstDir, 'link2' ),
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'fileNotExists' ),
  //   dstPath : path.join( dstDir, 'link3' ),
  //   allowingMissing : 1
  // })

  // provider.softLink
  // ({
  //   srcPath : path.join( dstDir, 'fileNotExists' ),
  //   dstPath : path.join( dstDir, 'link4' ),
  //   allowingMissing : 1
  // })

  // provider.filesReflect
  // ({
  //   reflectMap : { [ srcDir ] : dstDir },
  //   allowingMissing : 1,
  // })

  // test.is( provider.isSoftLink( path.join( dstDir, 'link' ) ) );
  // var dstLink1 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link' )/*, readLink : 1*/ });
  // test.identical( dstLink1, path.join( dstDir, 'fileNotExists' ) );

  // test.is( provider.isSoftLink( path.join( dstDir, 'link2' ) ) );
  // var dstLink2 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link2' )/*, readLink : 1*/ });
  // test.identical( dstLink2, path.join( dstDir, 'file' ) );

  // test.is( !provider.isSoftLink( path.join( dstDir, 'link3' ) ) );
  // var read = provider.fileRead({ filePath : path.join( dstDir, 'link3' ) });
  // test.identical( read, 'file' );

  // test.is( provider.isSoftLink( path.join( dstDir, 'link4' ) ) );
  // var dstLink4 = provider.pathResolveSoftLink({ filePath : path.join( dstDir, 'link4' )/*, readLink : 1*/ });
  // test.identical( dstLink4, path.join( dstDir, 'fileNotExists' ) );

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
