( function _FileProvider_test_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{

  isBrowser = false;

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );

  var crypto = require( 'crypto' );

  _.include( 'wTesting' );

  var waitSync = require( 'wait-sync' );

  // _.assert( HardDrive === _.FileProvider.HardDrive,'overwritten' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;

//

function onSuiteBegin( test )
{
  this.testRootDirectory = _.path.dirTempOpen( _.path.join( __dirname, '../..'  ), 'FileProvider/Abstract' );
}

//

function makePath( filePath )
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
    var testPath = self.makePath( 'testPath' );
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

  if( !isBrowser && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allowed = false;
    var dir = self.makePath( 'symlinkIsAllowed' );
    var srcPath = self.makePath( 'symlinkIsAllowed/src' );
    var dstPath = self.makePath( 'symlinkIsAllowed/dst' );

    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );

    try
    {
      self.provider.linkSoft({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allowed = self.provider.fileIsSoftLink( dstPath );
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

// function shouldWriteOnlyOnce( test, filePath, expected )
// {
//   var self = this;
//
//   test.case = 'shouldWriteOnlyOnce test';
//   var files = self.provider.directoryRead( self.makePath( filePath ) );
//   test.identical( files, expected );
// }

// --
// tests
// --

function testDelaySample( test )
{
  var self = this;

  test.case = 'delay test';

  var con = _.timeOut( 1000 );

  test.identical( 1,1 );

  con.doThen( function( ){ logger.log( '1000ms delay' ) } );

  con.doThen( _.routineSeal( _,_.timeOut,[ 1000 ] ) );

  con.doThen( function( ){ logger.log( '2000ms delay' ) } );

  con.doThen( function( ){ test.identical( 1,1 ); } );

  return con;
}

//

function mustNotThrowError( test )
{

  // test.identical( 0,0 );
  //
  // test.case = 'if passes dont appears in output/passed test cases/total counter';
  // test.mustNotThrowError( function()
  // {
  // });
  //
  // test.identical( 0,0 );
  //
  // test.case = 'if not passes then appears in output/total counter';
  // test.mustNotThrowError( function()
  // {
  //   return _.timeOut( 1000,function()
  //   {
  //     throw _.err( 'test' );
  //   });
  //   // throw _.err( 'test' );
  // });
  //
  // test.identical( 0,0 );
  //

  /**/

  test.case = 'mustNotThrowError must return con with message';

  var con = new _.Consequence().give( '123' );
  test.mustNotThrowError( con )
  .ifNoErrorThen( function( got )
  {
    test.identical( got, '123' );
  })

}

//

function readWriteSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  debugger

  var dir = _.path.normalize( test.context.makePath( 'written/readWriteSync' ) );

  var got, filePath, readOptions, writeOptions;
  var testData = 'Lorem ipsum dolor sit amet';

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'fileRead, invalid path';

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      filePath : 'invalid path',
      sync : 1,
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'invalid path' ),
      sync : 1,
      throwing : 0,
    });
    test.identical( got, null );
  })

  //

  test.case = 'fileRead, path ways to not a terminal file';
  filePath = test.context.makePath( 'written/readWriteSync/dir' );
  self.provider.directoryMake( filePath );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    var got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      throwing : 0,
    });
    test.identical( got, null );
  });

  //

  test.case = 'fileRead,simple file read ';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  self.provider.fileWrite( filePath, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );

  /**/

  // test.shouldThrowErrorSync( function()
  // {
  //   self.provider.fileRead
  //   ({
  //     filePath : filePath,
  //     sync : 1,
  //     encoding : 'utf8',
  //     throwing : 1,
  //   })
  // });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'utf8',
      throwing : 1,
    })
  });
  test.identical( got, testData );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'unknown',
      throwing : 1,
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    var got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'unknown',
      throwing : 0,
    });
    test.identical( got, null );
  });

  //

  test.case = 'fileRead,file read with common encodings';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/file' );

  /**/

  testData = { a : 'abc' };
  self.provider.fileWrite( filePath, JSON.stringify( testData ) );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1,
    encoding : 'json',
    throwing : 1,
  });
  test.identical( got , testData );

  /**/

  var isHd = self.providerIsInstanceOf( _.FileProvider.HardDrive );

  if( isHd )
  testData = 'module.exports = { a : 1 }';
  else
  testData = '1 + 2';

  self.provider.fileWrite( filePath, testData );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1,
    encoding : isHd ? 'node.js' : 'structure.js',
    throwing : 1,
  });

  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( got, { a : 1 } );
  }
  else
  {
    var expected = _.exec
    ({
      code : testData,
      filePath :filePath,
      prependingReturn : 1,
    });
    test.identical( got , expected );
  }

  /**/

  testData = filePath;
  self.provider.fileWrite( filePath, testData );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1,
    encoding : 'original.type',
    throwing : 1,
  });
  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.is( _.bufferBytesIs( got ) )
    test.identical( got, _.bufferBytesFrom( Buffer.from( testData ) ) );
  }
  else
  {
    test.identical( got , testData );
  }

  /**/

  test.shouldThrowError( () =>
  {
    self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'abcde',
      throwing : 1,
    });
  })

  /**/

  test.mustNotThrowError( () =>
  {
    var got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'abcde',
      throwing : 0,
    });
    test.identical( got, null );
  })

  /**/

  test.case = 'encoder not finded';
  var encoding = 'unknown';
  test.identical( self.provider.fileRead.encoders[ encoding ], undefined );
  // test.identical( self.provider.fileReadAct.encoders[ encoding ], undefined );
  test.shouldThrowError( () =>
  {
    self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      throwing : 1,
      encoding : encoding
    });
  });

  //

  if( !isBrowser )
  {
    test.case = 'other encodings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteSync/file' );
    testData = 'abc';

    self.provider.fileWrite( filePath, testData );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'buffer.node',
      throwing : 1,
    });
    test.is( _.bufferNodeIs( got ) );

    self.provider.fileWrite( filePath, testData );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'buffer.raw',
      throwing : 1,
    });
    test.is( _.bufferRawIs( got ) );
  }

  //

  test.case = 'fileRead,onBegin,onEnd,onError';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  function onBegin( err, o )
  {
    self.provider.fileWrite( filePath, testData );
    if( o )
    got = o;
  }
  function onEnd( err, data )
  {
    got = data;
  }
  function onError( err )
  {
    got = err;
  }

  /*onBegin returningRead 0*/

  got = self.provider.fileRead
  ({
    sync : 1,
    returningRead : 0,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : onBegin,
    onEnd : null,
    onError : null,
  });
  test.identical( got.result, testData );

  /*onBegin returningRead 1*/

  var got = self.provider.fileRead
  ({
    sync : 1,
    returningRead : 1,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : onBegin,
    onEnd : null,
    onError : null,
  });
  test.identical( _.objectIs( got ), false );

  /*onEnd returningRead 0*/

  var got = self.provider.fileRead
  ({
    sync : 1,
    returningRead : 0,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : null,
    onEnd : onEnd,
    onError : null,
  });
  test.identical( got.result, testData );

  /*onEnd returningRead 1*/

  debugger;
  var got = self.provider.fileRead
  ({
    sync : 1,
    returningRead : 1,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : null,
    onEnd : onEnd,
    onError : null,
  });
  debugger;
  test.identical( got, testData );
  debugger;

  /*onError is no called*/

  debugger;
  test.shouldThrowErrorSync( function()
  {
    var got = self.provider.fileRead
    ({
      sync : 1,
      returningRead : 0,
      throwing : 1,
      filePath : test.context.makePath( 'invalid path' ),
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  debugger;
  test.identical( _.errIs( got ), true )
  debugger;

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      returningRead : 1,
      throwing : 1,
      filePath : test.context.makePath( 'invalid path' ),
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errIs( got ), true );

  /*onError is no called*/

  test.mustNotThrowError( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      returningRead : 0,
      throwing : 0,
      filePath : test.context.makePath( 'invalid path' ),
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errIs( got ), true );

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      returningRead : 0,
      throwing : 1,
      filePath : test.context.makePath( 'invalid path' ),
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errIs( got ), true );

  //fileWrite

  //

  test.case = 'fileWrite, path not exist,default settings';
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( filePath, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  /* path includes not existing directory */

  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/files/file' );
  self.provider.fileWrite( filePath, testData );
  var files = self.provider.directoryRead( _.path.dir( filePath ) );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.case = 'fileWrite, path already exist,default settings';
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  self.provider.fileWrite( filePath, testData );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( filePath, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  /*try rewrite folder*/
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileWrite( dir, testData );
  });

  //

  test.case = 'fileWrite, path already exist';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  self.provider.fileWrite( filePath, testData );

  /**/

  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    makingDirectory : 1,
    purging : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  /**/

  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    makingDirectory : 0,
    purging : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  /**/

  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    makingDirectory : 0,
    purging : 0,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.case = 'fileWrite, path not exist';
  self.provider.filesDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  filePath = test.context.makePath( 'written/readWriteSync/file' );


  /*path includes not existing directory*/

  debugger
  // self.provider.filesDelete( _.path.dir( filePath ) );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 1,
      makingDirectory : 0,
      purging : 0,
    });
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, null );

  /*file not exist*/

  self.provider.directoryMake( dir );
  test.mustNotThrowError( function()
  {
    self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 1,
      makingDirectory : 0,
      purging : 0,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  /*purging non existing filePath*/

  self.provider.filesDelete( filePath );
  test.mustNotThrowError( function()
  {
    self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 1,
      makingDirectory : 0,
      purging : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.case = 'fileWrite, different write modes';
  self.provider.filesDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  filePath = test.context.makePath( 'written/readWriteSync/file' );

  /*rewrite*/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    writeMode : 'rewrite'
  });
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  /*prepend*/

  self.provider.fileWrite( filePath, testData );
  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    writeMode : 'prepend'
  });
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData+testData );

  /*append*/

  self.provider.fileWrite( filePath, testData );
  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    writeMode : 'append'
  });
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData+testData );

  //

  test.case = 'fileWrite, any writeMode should create file it not exist';
  self.provider.filesDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  filePath = test.context.makePath( 'written/readWriteSync/file' );

  /*rewrite*/

  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    writeMode : 'rewrite'
  });
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  /*prepend*/

  self.provider.filesDelete( filePath );
  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    writeMode : 'prepend'
  });
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  /*append*/

  self.provider.filesDelete( filePath );
  self.provider.fileWrite
  ({
    filePath : filePath,
    data : testData,
    sync : 1,
    writeMode : 'append'
  });
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  test.identical( got, testData );

  //

  var symlinkIsAllowed = test.context.symlinkIsAllowed();

  //

  if( symlinkIsAllowed )
  {
    /* resolvingSoftLink */

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data);
    self.provider.fieldReset( 'resolvingSoftLink', 1 );

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    test.shouldThrowError( () =>
    {
      self.provider.fileRead( linkPath );
    });
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    self.provider.fileWrite( linkPath, data + data );
    var got = self.provider.fileRead( filePath );
    test.identical( got, data + data );
    self.provider.fieldReset( 'resolvingSoftLink', 1 );

    //

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    self.provider.fileWrite( linkPath, data + data );
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data + data );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    self.provider.fileWrite
    ({
      filePath : linkPath,
      writeMode : 'append',
      data : data
    });
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data + data );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    self.provider.fileWrite
    ({
      filePath : linkPath,
      writeMode : 'append',
      encoding : 'original.type',
      data : data
    });
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data + data );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink off';
    var data = _.bufferBytesFrom( 'abc' );
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite
    ({
      filePath : filePath,
      encoding : 'original.type',
      data : data
    });
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    var appendData = 'abc';
    self.provider.fileWrite
    ({
      filePath : linkPath,
      writeMode : 'append',
      encoding : 'original.type',
      data : appendData
    });
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'original.type' });
    test.identical( got, data );
    var got = self.provider.fileRead({ filePath : linkPath, encoding : 'original.type' });
    test.is( _.bufferBytesIs( got ) );
    test.identical( got, _.bufferBytesFrom( appendData + appendData ) );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    self.provider.fileWrite
    ({
      filePath : linkPath,
      writeMode : 'prepend',
      data : '1'
    });
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, '1' + data );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    self.provider.fileWrite
    ({
      filePath : linkPath,
      writeMode : 'prepend',
      encoding : 'original.type',
      data : '1'
    });
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, '1' + data );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

    test.case = 'write using link, resolvingSoftLink off';
    var data = _.bufferBytesFrom( 'abc' );
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite
    ({
      filePath : filePath,
      encoding : 'original.type',
      data : data
    });
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.linkSoft( linkPath, filePath );
    var appendData = 'abc';
    self.provider.fileWrite
    ({
      filePath : linkPath,
      writeMode : 'prepend',
      encoding : 'original.type',
      data : appendData
    });
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'original.type' });
    test.identical( got, data );
    var got = self.provider.fileRead({ filePath : linkPath, encoding : 'original.type' });
    test.is( _.bufferBytesIs( got ) );
    test.identical( got, _.bufferBytesFrom( appendData + appendData ) );
    self.provider.fieldReset( 'resolvingSoftLink', 0 );

  }

  //

  if( !isBrowser )
  {
    test.case = 'fileWrite, data is raw buffer';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    var buffer = _.bufferRawFrom( Buffer.from( testData ) );
    filePath = test.context.makePath( 'written/readWriteSync/file' );

    /**/

    self.provider.fileWrite( filePath,buffer );
    got = self.provider.fileRead
    ({
     filePath : filePath,
     sync : 1,
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );

    if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
    {
      test.case = 'typed buffer'
      buffer = new Uint16Array( buffer );
      self.provider.fileWrite( filePath,buffer );
      got = self.provider.fileRead
      ({
       filePath : filePath,
       sync : 1,
      });
      test.identical( got, testData );

      test.case = 'node buffer'
      buffer = Buffer.from( testData );
      self.provider.fileWrite( filePath,buffer );
      got = self.provider.fileRead
      ({
       filePath : filePath,
       sync : 1,
      });
      test.identical( got, testData );

      if( symlinkIsAllowed )
      {
        test.case = 'write using link, resolvingSoftLink off';
        var data = 'data';
        self.provider.fieldSet( 'resolvingSoftLink', 0 );
        self.provider.fileWrite( filePath, data );
        var linkPath = test.context.makePath( 'written/readWriteSync/link' );
        self.provider.linkSoft( linkPath, filePath );
        self.provider.fileWrite
        ({
           filePath : linkPath,
           writeMode : 'prepend',
           data : Buffer.from( data )
        });
        var got = self.provider.fileRead( filePath );
        test.identical( got, data );
        var got = self.provider.fileRead( linkPath );
        test.identical( got, data + data );
        self.provider.fieldReset( 'resolvingSoftLink', 0 );

        test.case = 'write using link, resolvingSoftLink off';
        var data = 'data';
        self.provider.fieldSet( 'resolvingSoftLink', 0 );
        self.provider.fileWrite( filePath, data );
        var linkPath = test.context.makePath( 'written/readWriteSync/link' );
        self.provider.linkSoft( linkPath, filePath );
        self.provider.fileWrite
        ({
           filePath : linkPath,
           writeMode : 'prepend',
           data : Buffer.from( data ),
           encoding : 'original.type'
        });
        var got = self.provider.fileRead( filePath );
        test.identical( got, data );
        var got = self.provider.fileRead( linkPath );
        test.identical( got, data + data );
        self.provider.fieldReset( 'resolvingSoftLink', 0 );
      }
    }
  }

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    var data = 'data';

    self.provider.fieldSet( 'safe', 0 );


    /* hardLink */

    // var resolvingHardLink = self.provider.resolvingHardLink;

    /* resolving on */

    // self.provider.fieldSet( 'resolvingHardLink', 1 );

    // test.case = 'read, hardLink to file that not exist';
    // var linkPath = '/linkToUnknown';
    // test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    // test.case = 'write+read, hardLink to file that not exist';
    // var linkPath = '/linkToUnknown';
    // test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );
    // test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    // test.case = 'update file using hardLink, then read';
    // var linkPath = '/linkToFile';
    // var filePath = '/file';
    // self.provider.fileWrite( linkPath, data );
    // var got = self.provider.fileRead( filePath );
    // test.identical( got, data );

    // test.case = 'update file, then read it using hardLink';
    // var linkPath = '/linkToFile';
    // var filePath = '/file';
    // self.provider.fileWrite( filePath, data + data );
    // var got = self.provider.fileRead( linkPath );
    // test.identical( got, data + data );

    // test.case = 'hardLink to directory, read+write';
    // var linkPath = '/linkToDir';
    // test.shouldThrowError( () => self.provider.fileRead( linkPath ) );
    // test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );

    /* resolving off */

    // self.provider.fieldSet( 'resolvingHardLink', 0 );

    // test.case = 'resolving disabled, read using hardLink';
    // var linkPath = '/linkToFile';
    // test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    // test.case = 'resolving disabled, write using hardLink, link becomes usual file';
    // var linkPath = '/linkToFile';
    // self.provider.fileWrite( linkPath, data );
    // var got = self.provider.fileRead( linkPath );
    // test.identical( got, data );
    // test.is( !self.provider.fileIsHardLink( linkPath ) );

    //

    // self.provider.fieldReset( 'resolvingHardLink', 0 );

    /* softLink */

    var resolvingSoftLink = self.provider.resolvingSoftLink;

    /* resolving on */

    self.provider.fieldSet( 'resolvingSoftLink', 1 );

    test.case = 'read, softLink to file that not exist';
    var linkPath = '/softLinkToUnknown';
    var filePath = '/unknown';
    // self.provider.filesDelete( filePath );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.case = 'write+read, softLink to file that not exist';
    var linkPath = '/softLinkToUnknown';
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.case = 'update file using softLink, then read';
    var linkPath = '/softLinkToFile';
    var filePath = '/file';
    self.provider.fileWrite( linkPath, data );
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );

    test.case = 'update file, then read it using softLink';
    var linkPath = '/softLinkToFile';
    var filePath = '/file';
    self.provider.fileWrite( filePath, data + data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data + data );

    test.case = 'softLink to directory, read+write';
    var linkPath = '/softLinkToDir';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );

    test.case = 'softLink to file, file renamed';
    var linkPath = '/softLinkToFile';
    var filePath = '/file';
    var filePathNew = '/file_new';
    self.provider.fileRename( filePathNew, filePath );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );
    self.provider.fileRename( filePath, filePathNew );


    /* resolving off */

    self.provider.fieldSet( 'resolvingSoftLink', 0 );

    test.case = 'resolving disabled, read using softLink';
    var linkPath = '/softLinkToFile';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.case = 'resolving disabled, write using softLink, link becomes usual file';
    var linkPath = '/softLinkToFile';
    self.provider.fileWrite( linkPath, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data );
    test.is( !self.provider.fileIsSoftLink( linkPath ) );

    //

    self.provider.fieldReset( 'resolvingSoftLink', 0 );
    self.provider.fieldReset( 'safe', 0 );
  }

  //

  // var data1 = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
  // self.provider.fileWrite
  // ({
  //   filePath : test.context.makePath( 'written/readWriteSync/test.txt' ),
  //   data : data1,
  //   sync : 1,
  // });
  //
  // test.case = 'single file is written';
  // var files = self.provider.directoryRead( test.context.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.case = 'synchronous, writeMode : rewrite';
  // var got = self.provider.fileRead
  // ({
  //   filePath : test.context.makePath( 'written/readWriteSync/test.txt' ),
  //   sync : 1
  // });
  // var expected = data1;
  // test.identical( got, expected );
  //
  // var data2 = 'LOREM';
  // self.provider.fileWrite
  // ({
  //   filePath : test.context.makePath( 'written/readWriteSync/test.txt' ),
  //   data : data2,
  //   sync : 1,
  //   writeMode : 'append'
  // });
  //
  // test.case = 'single file is written';
  // var files = self.provider.directoryRead( test.context.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.case = 'synchronous, writeMode : append';
  // var got = self.provider.fileRead
  // ({
  //   filePath : test.context.makePath( 'written/readWriteSync/test.txt' ),
  //   sync : 1
  // });
  // var expected = data1 + data2;
  // test.identical( got, expected );
  //
  // var data2 = 'LOREM';
  // self.provider.fileWrite
  // ({
  //   filePath : test.context.makePath( 'written/readWriteSync/test.txt' ),
  //   data : data2,
  //   sync : 1,
  //   writeMode : 'prepend'
  // });
  //
  // test.case = 'single file is written';
  // var files = self.provider.directoryRead( test.context.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.case = 'synchronous, writeMode : prepend';
  // var got = self.provider.fileRead
  // ({
  //   filePath : test.context.makePath( 'written/readWriteSync/test.txt' ),
  //   sync : 1
  // });
  // var expected = data2 + data1 + data2;
  // test.identical( got, expected );
  //
  // if( Config.debug )
  // {
  //   test.case = 'file doesn`t exist';
  //   test.shouldThrowErrorSync( function( )
  //   {
  //     self.provider.fileRead
  //     ({
  //       filePath : test.context.makePath( 'unknown' ),
  //       sync : 1
  //     });
  //   });
  //
  //   test.case = 'try to read dir';
  //   test.shouldThrowErrorSync( function( )
  //   {
  //     self.provider.fileRead
  //     ({
  //       filePath : test.context.makePath( '/' ),
  //       sync : 1
  //     });
  //   });
  // }
}

//

function readWriteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var symlinkIsAllowed = test.context.symlinkIsAllowed();
  var dir = test.context.makePath( 'written/readWriteAsync' );
  var got, filePath, readOptions, writeOptions,onBegin,onEnd,onError,buffer;
  var testData = 'Lorem ipsum dolor sit amet';

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();
  consequence

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileRead, invalid path';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : 'invalid path',
      sync : 0,
      throwing : 1,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : 'invalid path',
      sync : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .doThen( ( err, got ) =>
    {
      test.identical( got, null );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileRead, path ways to not a terminal file';
    filePath = test.context.makePath( 'written/readWriteAsync/dir' );
    self.provider.directoryMake( filePath );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .doThen( ( err, got ) =>
    {
      test.identical( got, null );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileRead,simple file read ';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    self.provider.fileWrite( filePath, testData );
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'utf8',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, testData );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'unknown',
      throwing : 1,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'unknown',
      throwing : 0,
    });
    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileRead,file read with common encodings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    testData = { a : 'abc' };
    self.provider.fileWrite( filePath, JSON.stringify( testData ) );
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'json',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got , testData );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
    testData = 'module.exports = { a : 1 }';
    else
    testData = '1 + 2';

    self.provider.fileWrite( filePath, testData );
    var con  = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'structure.js',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
      {
        test.identical( got, { a : 1 } );
      }
      else
      {
        var expected = _.exec
        ({
          code : testData,
          filePath :filePath,
          prependingReturn : 1,
        });
        test.identical( got , expected );
      }
    });
  })

  //

  .ifNoErrorThen( () =>
  {
    testData = filePath;
    self.provider.fileWrite( filePath, testData );
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'original.type',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( ( got ) =>
    {
      if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
      {
        test.is( _.bufferBytesIs( got ) )
        test.identical( got, _.bufferBytesFrom( Buffer.from( testData ) ) );
      }
      else
      {
        test.identical( got , testData );
      }
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileRead,onBegin,onEnd,onError';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    onBegin = function onBegin( err, o )
    {
      self.provider.fileWrite( filePath, testData );
      if( o )
      got = o;
    }
    onEnd = function onEnd( err, data )
    {
      got = data;
    }
    onError = function onError( err )
    {
      got = err;
    }
  })

  /*onBegin returningRead 0*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 1,
      filePath : filePath,
      encoding : 'utf8',
      onBegin : onBegin,
      onEnd : null,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.objectIs( got ), true );
    });
  })

  /*onBegin returningRead 1*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 1,
      throwing : 1,
      filePath : filePath,
      encoding : 'utf8',
      onBegin : onBegin,
      onEnd : null,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.objectIs( got ), true );
    });
  })

  /*onEnd returningRead 0*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 1,
      filePath : filePath,
      encoding : 'utf8',
      onBegin : null,
      onEnd : onEnd,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( got.result, testData );
    });
  })

  /*onEnd returningRead 1*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 1,
      throwing : 1,
      filePath : filePath,
      encoding : 'utf8',
      onBegin : null,
      onEnd : onEnd,
      onError : null,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( got.result, testData );
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 1,
      filePath : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      test.identical( _.errIs( got ), true )
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 1,
      throwing : 1,
      filePath : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      test.identical( _.errIs( got ), true );
    });
  })

  /*onError is no called*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 0,
      filePath : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      test.identical( _.errIs( got ), true );
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 1,
      filePath : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      test.identical( _.errIs( got ), true );
    });
  })

  //fileWrite

  .ifNoErrorThen( function()
  {
    test.case = 'fileWrite, path not exist,default settings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
       sync : 0,
       filePath : filePath,
       data : testData,
    })
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );

    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  /*path includes not existing directory*/

  .ifNoErrorThen( function()
  {
    filePath = test.context.makePath( 'written/readWriteAsync/files/file.txt' );
    return self.provider.fileWrite
    ({
       sync : 0,
       filePath : filePath,
       data : testData
    })
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  .ifNoErrorThen( function()
  {
    test.case = 'fileWrite, path already exist,default settings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    self.provider.fileWrite( filePath, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
       sync : 0,
       filePath : filePath,
       data : testData
    })
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  /*try rewrite folder*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileWrite
    ({
       sync : 0,
       filePath : dir,
       data : testData
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'fileWrite, path already exist';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    self.provider.fileWrite( filePath, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 1,
      purging : 1,
    });
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 1,
    });

  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileWrite, path not exist';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
  })

  /*path includes not existing directory*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
    return test.shouldThrowError( con );
  })
  .doThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, null );
  })

  /*file not exist*/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( dir );
    var con = self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
    return test.mustNotThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  /*purging non existing filePath*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( filePath );
    var con = self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 1,
    });
    return test.mustNotThrowError( con );
  })
  .ifNoErrorThen( function()
  {
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileWrite, different write modes';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
  })

  /*rewrite*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'rewrite'
    });

  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /*prepend*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath, testData );
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'prepend'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData+testData );
  })

  /*append*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath, testData );
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'append'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData+testData );
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'fileWrite, any writeMode should create file it not exist';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
  })

  /*rewrite*/

  .ifNoErrorThen( function()
  {
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'rewrite'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /*prepend*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( filePath );
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'prepend'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /*append*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( filePath );
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'append'
    });
  })
  .ifNoErrorThen( function()
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.directoryRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
  })

  /* resolvingSoftLink */

  .ifNoErrorThen( () =>
  {

    if( !symlinkIsAllowed )
    return;

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
      self.provider.linkSoft( linkPath, filePath );
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data );
        self.provider.fieldReset( 'resolvingSoftLink', 1 );
      })
    })
  })

  .ifNoErrorThen( () =>
  {
    if( !symlinkIsAllowed )
    return;

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
      self.provider.linkSoft( linkPath, filePath );
      var con = self.provider.fileRead({ filePath : linkPath, sync : 0 });
      return test.shouldThrowError( con )
      .doThen( () =>
      {
        self.provider.fieldReset( 'resolvingSoftLink', 0 );
      })
    })

  })

  .ifNoErrorThen( () =>
  {
    if( !symlinkIsAllowed )
    return;

    test.case = 'write using link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
      self.provider.linkSoft( linkPath, filePath );
      return self.provider.fileWrite({ filePath : filePath, data : data + data, sync : 0 })
    })
    .doThen( () => self.provider.fileRead({ filePath : filePath, sync : 0 }) )
    .doThen( ( err, got ) =>
    {
      test.identical( got, data + data );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
    })
  })

  .ifNoErrorThen( () =>
  {
    if( !symlinkIsAllowed )
    return;

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      self.provider.linkSoft( linkPath, filePath );
      return self.provider.fileWrite({ filePath : linkPath, data : data + data, sync : 0 })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : filePath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data );
      })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data + data );
      })
    })
    .doThen( () => self.provider.fieldReset( 'resolvingSoftLink', 0 ) )
  })

  .ifNoErrorThen( () =>
  {
    if( !symlinkIsAllowed )
    return;

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      self.provider.linkSoft( linkPath, filePath );
      return self.provider.fileWrite
      ({
         filePath : linkPath,
         writeMode : 'append',
         sync : 0,
         data : data
      });
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : filePath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data );
      })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data + data );
      })
    })
    .doThen( () => self.provider.fieldReset( 'resolvingSoftLink', 0 ) )
  })

  .ifNoErrorThen( () =>
  {
    if( !symlinkIsAllowed )
    return;

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      self.provider.linkSoft( linkPath, filePath );
      return self.provider.fileWrite
      ({
         filePath : linkPath,
         writeMode : 'prepend',
         sync : 0,
         data : 'prepend'
      });
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : filePath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data );
      })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, 'prepend' + data );
      })
    })
    .doThen( () => self.provider.fieldReset( 'resolvingSoftLink', 0 ) )

  })



  //

  if( !isBrowser )
  {
    consequence.ifNoErrorThen( function()
    {
      test.case = 'fileWrite, data is raw buffer';
      self.provider.filesDelete( dir );
      testData = 'Lorem ipsum dolor sit amet';
      buffer = _.bufferRawFrom( Buffer.from( testData ) );
      filePath = test.context.makePath( 'written/readWriteAsync/file' );
    })

    /**/

    consequence.ifNoErrorThen( function()
    {
      return self.provider.fileWrite
      ({
        filePath : filePath,
        data : buffer,
        sync : 0,
      });
    })
    .ifNoErrorThen( function()
    {
      got = self.provider.fileRead
      ({
         filePath : filePath,
         sync : 1,
      });
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'file' ] );
      test.identical( got, testData );
    });

    //

    consequence.ifNoErrorThen( function()
    {
      test.case = 'encoder not finded';
      var encoding = 'unknown';
      test.identical( self.provider.fileRead.encoders[ encoding ], undefined );
      // test.identical( self.provider.fileReadAct.encoders[ encoding ], undefined );
      var con = self.provider.fileRead
      ({
        filePath : filePath,
        sync : 0,
        throwing : 1,
        encoding : encoding
      });
      return test.shouldThrowError( con );
    })
    .ifNoErrorThen( function()
    {
      test.case = 'other encodings';
      self.provider.filesDelete( dir );
      filePath = test.context.makePath( 'written/readWriteSync/file' );
      testData = 'abc';
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite( filePath, testData );
      return self.provider.fileRead
      ({
        filePath : filePath,
        sync : 0,
        encoding : 'buffer.node',
        throwing : 1,
      })
      .doThen( ( err, got ) => test.is( _.bufferNodeIs( got ) ) )
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite( filePath, testData );
      return self.provider.fileRead
      ({
        filePath : filePath,
        sync : 0,
        encoding : 'buffer.raw',
        throwing : 1,
      })
      .doThen( ( err, got ) => test.is( _.bufferRawIs( got ) ) )
    })
  }

 return consequence;
}

//

function fileReadJson( test )
{
  var self = this;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
  var bufferData1;

  if( isBrowser || self.providerIsInstanceOf( _.FileProvider.Extract ))
  bufferData1 = new ArrayBuffer( 4 );
  else
  bufferData1 = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );


  var dataToJSON1 = [ 1, 'a', { b : 34 } ];
  var dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };

  var testChecks =
  [
    {
      name : 'try to load empty text file as json',
      data : '',
      path : 'fileReadJson/rtext1.txt',
      expected :
      {
        error : true,
        content : void 0
      },
    },
    {
      name : 'try to read non json string as json',
      data : textData1,
      path : 'fileReadJson/text2.txt',
      expected :
      {
        error : true,
        content : void 0
      }
    },
    {
      name : 'try to parse buffer as json',
      data : bufferData1,
      path : 'fileReadJson/data0',
      expected :
      {
        error : true,
        content : void 0
      }
    },
    {
      name : 'read json from file',
      data : dataToJSON1,
      path : 'fileReadJson/jason1.json',
      encoding : 'json',
      expected :
      {
        error : null,
        content : dataToJSON1
      }
    },
    {
      name : 'read json from file 2',
      data : dataToJSON2,
      path : 'fileReadJson/json2.json',
      encoding : 'json',
      expected :
      {
        error : null,
        content : dataToJSON2
      }
    }
  ];

  for( var testCheck of testChecks )
  {
    // join several test aspects together
    var got =
    {
      error : null,
      content : void 0
    };

    var path = test.context.makePath( testCheck.path );

    if( self.provider.fileStat( path ) )
    self.provider.fileDelete( path );

    if( testCheck.encoding === 'json' )
    {
      self.provider.fileWriteJson( path, testCheck.data );
    }
    else
    {
      self.provider.fileWrite({ filePath : path, data : testCheck.data })
    }

    try
    {
      got.content = self.provider.fileReadJson( path );
    }
    catch ( err )
    {
      got.error = true;
    }

    test.identical( got, testCheck.expected );
  }

  //

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      self.provider.fileReadJson( );
    });

    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      self.provider.fileReadJson( 'tmp.tmp/tmp.tmp.json', {} );
    });
  }

};

//

function fileWriteJson( test )
{
  var self = this;

  var defReadOptions =
  {
    encoding : 'utf8'
  };
  var dataToJSON1 = [ 1, 'a', { b : 34 } ];
  var dataToJSON2 = { a : 1, b : 's', c : [ 1, 3, 4 ] };
  var dataToJSON3 = '{ "a" : "3" }';

  var testChecks =
  [
    {
      name : 'write empty JSON string file',
      data : '',
      path : 'fileWriteJson/data1.json',
      expected :
      {
        instance : false,
        content : '',
        exist : true
      },
      readOptions : defReadOptions
    },
    {
      name : 'write array to file',
      data : dataToJSON1,
      path : 'fileWriteJson/data1.json',
      expected :
      {
        instance : false,
        content : dataToJSON1,
        exist : true
      },
      readOptions : defReadOptions
    },
    {
      name : 'write object using options',
      data : dataToJSON2,
      path : 'fileWriteJson/data2.json',
      expected :
      {
        instance : false,
        content : dataToJSON2,
        exist : true
      },
      readOptions : defReadOptions
    },
    {
      name : 'write jason string',
      data : dataToJSON3,
      path : 'fileWriteJson/data3.json',
      expected :
      {
        instance : false,
        content : dataToJSON3,
        exist : true
      },
      readOptions : defReadOptions
    }
  ];


  // regular tests
  for( var testCheck of testChecks )
  {
    // join several test aspects together
    var got =
    {
      instance : null,
      content : null,
      exist : null
    }

    var path = test.context.makePath( testCheck.path );

    // clear

    if( self.provider.fileStat( path ) )
    self.provider.fileDelete( path );

    var con = self.provider.fileWriteJson( path, testCheck.data );

    // fileWtrite must returns wConsequence
    got.instance = _.consequenceIs( con );

    // recorded file should exists
    got.exist = !!self.provider.fileStat( path );

    // check content of created file.
    var o = _.mapExtend( null, testCheck.readOptions, { filePath : path } );
    // got.content = JSON.parse( _.fileProvider.fileRead( path, testCheck.readOptions ) );
    got.content = JSON.parse( self.provider.fileRead( o ) );

    test.case = testCheck.name;
    test.identical( got, testCheck.expected );
  }

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      self.provider.fileWriteJson( );
    } );

    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      self.provider.fileWriteJson( 'temp/sample.txt', { a : 'hello' }, { b : 'world' } );
    } );

    test.case = 'path is not string';
    test.shouldThrowErrorSync( function( )
    {
      self.provider.fileWriteJson( 3, 'hello' );
    } );

    test.case = 'passed unexpected property in options';
    test.shouldThrowErrorSync( function( )
    {
      self.provider.fileWriteJson( { filePath : 'temp/some.txt', data : 'hello', parentDir : './work/project' } );
    } );
  }
};

//

function fileTouch( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWriteAct ) || self.providerIsInstanceOf( _.FileProvider.Extract )  )
  {
    test.identical( 1,1 );
    return;
  }

  var got;

  var dir = test.context.makePath( 'written/fileTouch' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var srcPath = _.path.normalize( test.context.makePath( 'written/fileTouch/src.txt' ) );
  var testData = 'test';

  //

  test.case = 'filePath doesnt exist'
  // self.provider.filesDelete( srcPath );
  self.provider.fileTouch( srcPath );
  var stat = self.provider.fileStat( srcPath );
  test.is( _.objectIs( stat ) );

  test.case = 'filePath doesnt exist, filePath as record';
  self.provider.filesDelete( srcPath );
  var record = self.provider.fileRecord( srcPath );
  test.identical( record.stat, null );
  self.provider.fileTouch( record );
  var stat = self.provider.fileStat( srcPath );
  test.is( _.objectIs( stat ) );

  test.case = 'filePath is a directory';
  self.provider.filesDelete( srcPath );
  self.provider.directoryMake( srcPath );
  test.shouldThrowError( () => self.provider.fileTouch( srcPath ) );

  test.case = 'directory, filePath as record';
  self.provider.filesDelete( srcPath );
  self.provider.directoryMake( srcPath );
  var record = self.provider.fileRecord( srcPath );
  test.shouldThrowError( () => self.provider.fileTouch( record ) );

  if( Config.debug )
  {
    test.case = 'invalid filePath type'
    test.shouldThrowError( () => self.provider.fileTouch( 1 ) );

    test.case = 'data option must be undefined'
    test.shouldThrowError( () => self.provider.fileTouch({ filePath : srcPath, data : testData }) );

    test.case = 'more then one arg'
    test.shouldThrowError( () => self.provider.fileTouch( srcPath, testData ) );
  }

  var con = new _.Consequence().give()

  /**/

  .ifNoErrorThen( () =>
  {
    test.case = 'filePath is a terminal';
    self.provider.filesDelete( srcPath );
    self.provider.fileWrite( srcPath, testData );
    var statsBefore = self.provider.fileStat( srcPath );
    return _.timeOut( 1000, () =>
    {
      self.provider.fileTouch( srcPath );
      var statsAfter = self.provider.fileStat( srcPath );
      test.identical( statsAfter.size, statsBefore.size );
      test.identical( statsAfter.ino , statsBefore.ino );
      test.is( statsAfter.mtime > statsBefore.mtime );
      test.is( statsAfter.ctime > statsBefore.mtime );
    })
  })

  /**/

  .ifNoErrorThen( () =>
  {
    test.case = 'terminal, filePath as record';
    self.provider.filesDelete( srcPath );
    self.provider.fileWrite( srcPath, testData );
    var record = self.provider.fileRecord( srcPath );
    var statsBefore = record.stat;
    return _.timeOut( 1000, () =>
    {
      self.provider.fileTouch( record );
      var statsAfter = self.provider.fileStat( srcPath );
      test.identical( statsAfter.size, statsBefore.size );
      test.identical( statsAfter.ino , statsBefore.ino );
      test.is( statsAfter.mtime > statsBefore.mtime );
      test.is( statsAfter.ctime > statsBefore.mtime );
    })
  })

  return con;
}

//

function fileTimeSet( test )
{
  let self = this;

  if( !test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/fileTimeSet' );
  let filePath = test.context.makePath( 'written/fileTimeSet/file' );

  let maxDiff = self.provider.systemBitrateTimeGet();

  test.case = 'path does not exist';
  self.provider.filesDelete( filePath );
  var time = _.timeNow();
  test.shouldThrowError( () => self.provider.fileTimeSet( filePath, time, time ) );

  function testDiff( diff )
  {
    if( !diff )
    test.identical( diff, 0 );
    else
    test.le( diff, maxDiff );
  }

  test.case = 'terminal file';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  self.provider.fileTimeSet( filePath, time, time );
  var stat  = self.provider.fileStat( filePath );
  test.is( stat.isFile() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'dir';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  self.provider.fileTimeSet( testDir, time, time );
  var stat  = self.provider.fileStat( testDir );
  test.is( stat.isDirectory() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'object, file';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  self.provider.fileTimeSet({ filePath : filePath, atime : time, mtime : time });
  var stat  = self.provider.fileStat( filePath );
  test.is( stat.isFile() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'object, dir';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  self.provider.fileTimeSet({ filePath : testDir, atime : time, mtime : time });
  var stat  = self.provider.fileStat( testDir );
  test.is( stat.isDirectory() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'two args, file';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var filePath2 = test.context.makePath( 'written/fileTimeSet/file2' );
  self.provider.fileWrite( filePath2, filePath2 );
  var time = new Date();
  self.provider.fileTimeSet( filePath2, time, time );
  self.provider.fileTimeSet( filePath, filePath2 );
  var stat  = self.provider.fileStat( filePath );
  test.is( stat.isFile() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'two args, dir';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var filePath2 = test.context.makePath( 'written/fileTimeSet/dir' );
  self.provider.directoryMake( filePath2 );
  var time = new Date();
  self.provider.fileTimeSet( filePath2, time, time );
  self.provider.fileTimeSet( testDir, filePath2 );
  var stat  = self.provider.fileStat( testDir );
  test.is( stat.isDirectory() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'negative values';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var statb  = self.provider.fileStat( testDir );
  self.provider.fileTimeSet( filePath, -1, -1 );
  var stata  = self.provider.fileStat( testDir );
  test.ge( statb.mtime, stata.mtime );
  test.ge( statb.atime, stata.atime );

  test.case = 'zero values';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var statb  = self.provider.fileStat( testDir );
  self.provider.fileTimeSet( filePath, 0, 0 );
  var stata  = self.provider.fileStat( testDir );
  test.ge( statb.mtime, stata.mtime );
  test.ge( statb.atime, stata.atime );

  if( process )
  if( process.platform === 'win32' )
  {
    test.case = 'number, milliseconds';
    self.provider.filesDelete( filePath );
    self.provider.fileWrite( filePath, filePath );
    var time = new Date().getTime();
    var statb  = self.provider.fileStat( filePath );
    test.shouldThrowError( () => self.provider.fileTimeSet( filePath, time, time ) );
    var stata  = self.provider.fileStat( filePath );
    test.identical( statb.atime, stata.atime );
    test.identical( statb.mtime, stata.mtime );
  }
  else
  {
    test.case = 'number, sec';
    self.provider.filesDelete( filePath );
    self.provider.fileWrite( filePath, filePath );
    var time = new Date().getTime();
    self.provider.fileTimeSet( filePath, time, time );
    var stat  = self.provider.fileStat( filePath );
    test.is( stat.isFile() );
    var adiff = time - stat.atime.getTime();
    testDiff( adiff );
    var mdiff = time - stat.mtime.getTime();
    testDiff( mdiff );
  }

  test.case = 'number, sec';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date().getTime();
  self.provider.fileTimeSet( filePath, time / 1000, time / 1000 );
  var stat  = self.provider.fileStat( filePath );
  test.is( stat.isFile() );
  var adiff = time - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'incorrect atime type';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  var statb  = self.provider.fileStat( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet( filePath, {}, time ) );
  var stata  = self.provider.fileStat( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  test.case = 'two args, second file does not exist';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var filePath2 = test.context.makePath( 'written/fileTimeSet/dir' );
  var time = new Date();
  var statb  = self.provider.fileStat( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet( filePath, filePath2 ) );
  var stata  = self.provider.fileStat( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  test.case = 'only atime';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  var statb  = self.provider.fileStat( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet({ filePath : filePath, atime : time }) );
  var stata  = self.provider.fileStat( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  test.case = 'only mtime';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  var statb  = self.provider.fileStat( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet({ filePath : filePath, mtime : time }) );
  var stata  = self.provider.fileStat( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  if( !Config.debug )
  return;

  var time = new Date();
  test.case = 'invalid arguments'
  test.shouldThrowError( () => self.provider.fileTimeSet( 1 ) );
  test.shouldThrowError( () => self.provider.fileTimeSet({ filePath : 1, atime : time, mtime : time } ) );
}

//

function writeAsyncThrowingError( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var consequence = new _.Consequence().give();

  consequence
  .ifNoErrorThen( function()
  {

    test.case = 'async, try to rewrite dir';

    var path = test.context.makePath( 'dir' );
    self.provider.directoryMake( path );
    test.identical( self.provider.directoryIs( path ), true )
    var data1 = 'data1';
    var con = self.provider.fileWrite
    ({
      filePath : path,
      data : data1,
      sync : 0,
    });

    return test.shouldThrowErrorAsync( con );
  })

  return consequence;
}

//

function fileCopySync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var got;

  var dir = test.context.makePath( 'written/fileCopy' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'src not exist';

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 0,
    });
  });
  test.identical( got, false );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 0,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 0,
      throwing : 0,
    });
  });
  test.identical( got, false );

  //

  test.case = 'dst path not exist';
  var srcPath = test.context.makePath( 'written/fileCopy/src.txt' );
  var dstPath = test.context.makePath( 'written/fileCopy/dst.txt' );
  self.provider.fileWrite( srcPath, ' ' );

  /**/

  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  //

  test.case = 'dst path exist';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, ' ' );
  self.provider.fileWrite( dstPath, ' ' );

  /**/

  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst.txt', 'src.txt' ] );

  //

  test.case = 'src is equal to dst';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, ' ' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src.txt' ] );

  //

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  return;

  test.case = 'src is not a terminal, dst present, check if nothing changed';

  /* rewritin & throwing on */

  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( dstPath, ' ' );
  var srcStatExpected = self.provider.fileStat( srcPath );
  var dstBefore = self.provider.fileRead( dstPath );
  var dirBefore = self.provider.directoryRead( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  var srcStat = self.provider.fileStat( srcPath );
  var dstNow = self.provider.fileRead( dstPath );
  test.is( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.directoryRead( dir );
  test.identical( dirAfter, dirBefore );

  /* rewritin on & throwing off */

  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( dstPath, ' ' );
  var srcStatExpected = self.provider.fileStat( srcPath );
  var dstBefore = self.provider.fileRead( dstPath );
  var dirBefore = self.provider.directoryRead( dir );
  var got = self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, false );
  var srcStat = self.provider.fileStat( srcPath );
  var dstNow = self.provider.fileRead( dstPath );
  test.is( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.directoryRead( dir );
  test.identical( dirAfter, dirBefore );

  /* rewritin & throwing off */

  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( dstPath, ' ' );
  var srcStatExpected = self.provider.fileStat( srcPath );
  var dstBefore = self.provider.fileRead( dstPath );
  var dirBefore = self.provider.directoryRead( dir );
  var got = self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, false );
  var srcStat = self.provider.fileStat( srcPath );
  var dstNow = self.provider.fileRead( dstPath );
  test.is( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.directoryRead( dir );
  test.identical( dirAfter, dirBefore );

  //

  test.case = 'rewriting creates dir for a file, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.is( !!self.provider.fileStat( dstPath ) );

  //

  test.case = 'rewriting off, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !self.provider.fileStat( dstPath ) );
  test.shouldThrowError( () =>
  {
     self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  })
  test.is( !self.provider.fileStat( dstPath ) );

  //

  test.case = 'rewriting off, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !self.provider.fileStat( dstPath ) );
  test.mustNotThrowError( () =>
  {
     self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  })
  test.is( !self.provider.fileStat( dstPath ) );

  //

  test.case = 'rewriting on, parentDir is a terminal file'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var terminalFilePath = _.path.join( dir, 'folder/structure' );
  self.provider.fileWrite( terminalFilePath, dstPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !!self.provider.fileStat( terminalFilePath ) );
  test.is( !self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.is( self.provider.directoryIs( terminalFilePath ) );
  test.is( !!self.provider.fileStat( dstPath ) );

  //

  test.case = 'rewriting on, parentDir is a directory with files, dir must be preserved'
  self.provider.filesDelete( dir );
  var file1 = _.path.join( dir, 'dir', 'file1' );
  var file2 = _.path.join( dir, 'dir', 'file2' );
  self.provider.fileWrite( file1, file1 );
  self.provider.fileWrite( file2, file2 );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'dst' );
  test.is( !self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dir', 'dst', 'src.txt' ];
  test.identical( files, expected );

  //

  test.case = 'rewriting off, parentDir is a directory with files, dir must be preserved'
  self.provider.filesDelete( dir );
  var file1 = _.path.join( dir, 'dir', 'file1' );
  var file2 = _.path.join( dir, 'dir', 'file2' );
  self.provider.fileWrite( file1, file1 );
  self.provider.fileWrite( file2, file2 );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'dst' );
  test.is( !self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dir', 'dst', 'src.txt' ];
  test.identical( files, expected );

  /* relative paths */

  test.case = 'relative path, dst path not exist';
  var dir = test.context.makePath( 'written/fileCopy' );
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );

  //

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : '../dst',
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst', 'src' ] );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopy
  ({
    srcPath : '../src',
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst', 'src' ] );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  if( !Config.debug )
  return;

  /* both relative, throwing : 1 */

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopy
    ({
      srcPath : '../src',
      dstPath : '../dst',
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcPath, srcFile );

  /* both relative, throwing : 0 */

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopy
    ({
      srcPath : _.path.relative( dir, srcPath ),
      dstPath : _.path.relative( dir, dstPath ),
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcPath, srcFile );

  //

  test.case = 'dst - terminal, rewrite by src - terminal'
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  test.is( !!self.provider.fileStat( srcPath ) );
  test.is( !!self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var srcFile = self.provider.fileRead( srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst', 'src' ] )
  test.identical( srcFile, srcPath );
  test.identical( dstFile, srcPath );
}

//

function fileCopyActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var got;

  var dir = test.context.makePath( 'written/fileCopy' );
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 0
    })
  })

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 0
    })
  })

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 1
    })
  })

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 1
    })
  })

  //

  test.case = 'no src, dst exists';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 0
    })
  })
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );

  //

  test.case = 'no src, dst exists';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 0
    })
  })
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );

  //

  test.case = 'no src, dst exists';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 1
    })
  })
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );

  //

  test.case = 'no src, dst exists';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 1
    })
  })
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 0
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] )

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 0
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 1
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 1
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] )

  //

  test.case = 'no structure before dst';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 0
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'no structure before dst';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 0
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'no structure before dst';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 1
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'no structure before dst';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 1
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.directoryMake( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 0
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.directoryRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.directoryMake( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 0
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.directoryRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.directoryMake( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0,
      // breakingDstSoftLink : 1
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.directoryRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.directoryMake( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 1,
      // breakingDstSoftLink : 1
    })
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.directoryRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'simple copy';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 0,
    // breakingDstSoftLink : 0
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple copy';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 1,
    // breakingDstSoftLink : 0
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple copy';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 0,
    // breakingDstSoftLink : 1
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple copy';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 1,
    // breakingDstSoftLink : 1
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple, rewrite';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 0,
    // breakingDstSoftLink : 0
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple, rewrite';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 1,
    // breakingDstSoftLink : 0
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple, rewrite';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 0,
    // breakingDstSoftLink : 1
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'simple, rewrite';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  self.provider.fileCopyAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    breakingDstHardLink : 1,
    // breakingDstSoftLink : 1
  });
  var files = self.provider.directoryRead( dir );
  var expected = [ 'dst', 'src' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  var dir = test.context.makePath( 'written/' + test.name );
  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  var otherPath = _.path.join( dir, 'other' );

  /* hardlink */

  test.case = 'dst is a hard link, breaking disabled';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a hard link, breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  debugger
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.is( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.is( srcFile !== dstFile );

  //

  test.case = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.is( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.is( srcFile !== dstFile );

  /* links */

  if( !test.context.symlinkIsAllowed() )
  return;

  test.case = 'dst is a soft link';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a soft link';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a soft link';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopyAct
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    originalSrcPath : otherPath,
    originalDstPath : dstPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

}

//

function fileCopyRelativePath( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/fileCopyRelativePath' );
  let pathToDir = test.context.makePath( 'written/fileCopyRelativePath/dir' );
  let pathToFile = test.context.makePath( 'written/fileCopyRelativePath/file' );

  test.open( 'src - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile, dstPath ) );

  var srcPath = './../file';
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile, dstPath ) );

  var srcPath = '../../file';
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile, dstPath ) );


  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile, dstPath ) );


  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/fileCopyRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile2, dstPath ) );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/fileCopyRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile2, dstPath ) );

  test.close( 'src - relative path to a file' );

  //

  test.open( 'dst - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath,dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( srcPath, dstPathResolved ) );

  var srcPath = pathToFile;
  var dstPath = './../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath,dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( srcPath, dstPathResolved ) );

  var srcPath = pathToFile;
  var dstPath = '../../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath,dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( srcPath, dstPathResolved ) );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath,dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( srcPath, dstPathResolved ) );

  var srcPath = pathToFile;
  var dstPath = './../a/b/dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath,dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( srcPath, dstPathResolved ) );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.directoryMake( pathToDir );

  var srcPath = '../dir';
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () => self.provider.fileCopy( dstPath, srcPath ) );
  test.is( !self.provider.fileExists( dstPath ) );

  test.close( 'src - relative path to a dir' );

  //

  test.open( 'dst - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.directoryMake( pathToDir );

  var srcPath = pathToDir;
  var dstPath = '../copyOfDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  test.shouldThrowError( () => self.provider.fileCopy( dstPath, srcPath ) );
  test.is( !self.provider.fileExists( dstPathResolved ) );

  test.close( 'dst - relative path to a dir' );

  test.open( 'same paths' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile,pathToFile );

  var srcPath = '../file';
  var dstPath = pathToFile;
  var statBefore = self.provider.fileStat( pathToFile );
  var got = self.provider.fileCopy( dstPath, srcPath );
  var statNow = self.provider.fileStat( pathToFile );
  test.identical( got, true );
  test.identical( statBefore.mtime.getTime(), statNow.mtime.getTime() );

  var srcPath = pathToFile;
  var dstPath = '../file';
  var statBefore = self.provider.fileStat( pathToFile );
  var got = self.provider.fileCopy( dstPath, srcPath );
  var statNow = self.provider.fileStat( pathToFile );
  test.identical( got, true );
  test.identical( statBefore.mtime.getTime(), statNow.mtime.getTime() );

  test.close( 'same paths' );
}

//

function fileCopyLinksSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/' + test.name );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  var otherPath = _.path.join( dir, 'other' );

  //

  /* hardlink */

  test.case = 'dst is a hard link, breaking disabled';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a hard link, breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.is( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.is( srcFile !== dstFile );

  //

  test.case = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.is( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.is( srcFile !== dstFile );

  //

  test.case = 'src - not terminal, dst - hard link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, otherPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 1,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 0
    });
  })
  test.is( !!self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - hard link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 0
    });
  })
  test.is( !!self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - hard link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 1,
      breakingDstHardLink : 0
    });
  })
  test.is( !!self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - hard link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 1
    });
  })
  test.is( !!self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

   //

  test.case = 'src - not terminal, dst - hard link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkHard( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
    //  breakingDstSoftLink : 1,
      breakingDstHardLink : 1
    });
  })
  test.is( !!self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  if( !test.context.symlinkIsAllowed() )
  return;

  test.case = 'dst is a soft link, breaking disabled';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 0
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  test.case = 'dst is a soft link, breakingDstSoftLink : 0 ,breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.is( srcFile !== otherFile );

  //

  //breakingDstSoftLink is not present anymore

  /* test.case = 'dst is a soft link, breakingDstSoftLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 0
  });
  test.is( !self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.is( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.is( srcFile !== dstFile ); */

  //breakingDstSoftLink is not present anymore

  /* test.case = 'dst is a soft link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.is( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.is( srcFile !== dstFile ); */

  //

  test.case = 'src - not terminal, dst - soft link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, otherPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 1,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 0
    });
  })
  test.is( !!self.provider.fileIsSoftLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - soft link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 0
    });
  })
  test.is( !!self.provider.fileIsSoftLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - soft link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 1,
      breakingDstHardLink : 0
    });
  })
  test.is( !!self.provider.fileIsSoftLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - soft link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 1
    });
  })
  test.is( !!self.provider.fileIsSoftLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'src - not terminal, dst - soft link';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.linkSoft( dstPath, otherPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      sync : 1,
      throwing  : 0,
      // breakingDstSoftLink : 1,
      breakingDstHardLink : 1
    });
  })
  test.is( !!self.provider.fileIsSoftLink( dstPath ) );
  test.is( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );
}

//

function fileCopyAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopyAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/fileCopyAsync' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var srcPath = test.context.makePath( 'written/fileCopyAsync/src.txt' );
  var dstPath = test.context.makePath( 'written/fileCopyAsync/dst.txt' );

  var consequence = new _.Consequence().give();

  //

  consequence
  .ifNoErrorThen( function()
  {
    test.case = 'src not exist';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 1,
      throwing : 1,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 1,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 0,
      throwing : 1,
    });
    return test.shouldThrowError( con )
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'copy bigger file';
    var data = _.strDup( 'Lorem Ipsum is simply text', 10000 );
    self.provider.fileWrite( srcPath, data );
    self.provider.filesDelete( dstPath );
    var srcStat = self.provider.fileStat( srcPath );
    return self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var dstStat = self.provider.fileStat( dstPath );
      test.identical( srcStat.size, dstStat.size );
      var dstFile = self.provider.fileRead( dstPath );
      test.is( dstFile === data );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'dst path not exist';
    self.provider.fileWrite( srcPath, ' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dstPath );
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dstPath );
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dstPath );
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'dst path exist';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
    self.provider.fileWrite( dstPath, ' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    })
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src.txt' ] );
    });
  });

  //

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  return consequence;

  consequence.doThen( () =>
  {
    test.case = 'src is not a terminal, dst present, check if nothing changed';
  })

  /* rewritin & throwing on */

  .doThen( () =>
  {
    self.provider.filesDelete( dir );
    self.provider.directoryMake( srcPath );
    self.provider.fileWrite( dstPath, ' ' );
    var srcStatExpected = self.provider.fileStat( srcPath );
    var dstBefore = self.provider.fileRead( dstPath );
    var dirBefore = self.provider.directoryRead( dir );
    return test.shouldThrowError( () =>
    {
      return self.provider.fileCopy
      ({
        srcPath : srcPath,
        dstPath : dstPath,
        sync : 0,
        rewriting : 1,
        throwing : 1
      });
    })
    .doThen( () =>
    {
      var srcStat = self.provider.fileStat( srcPath );
      var dstNow = self.provider.fileRead( dstPath );
      test.is( srcStat.isDirectory() );
      test.identical( srcStat.size, srcStatExpected.size );
      test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
      test.identical( dstNow, dstBefore );
      var dirAfter = self.provider.directoryRead( dir );
      test.identical( dirAfter, dirBefore );
    })

  })

  /* rewritin on & throwing off */

  .doThen( () =>
  {
    self.provider.filesDelete( dir );
    self.provider.directoryMake( srcPath );
    self.provider.fileWrite( dstPath, ' ' );
    var srcStatExpected = self.provider.fileStat( srcPath );
    var dstBefore = self.provider.fileRead( dstPath );
    var dirBefore = self.provider.directoryRead( dir );
    return self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .doThen( ( err, got ) =>
    {
      test.identical( got, false );
      var srcStat = self.provider.fileStat( srcPath );
      var dstNow = self.provider.fileRead( dstPath );
      test.is( srcStat.isDirectory() );
      test.identical( srcStat.size, srcStatExpected.size );
      test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
      test.identical( dstNow, dstBefore );
      var dirAfter = self.provider.directoryRead( dir );
      test.identical( dirAfter, dirBefore );
    })

  })

  /* rewritin & throwing off */

  .doThen( () =>
  {
    self.provider.filesDelete( dir );
    self.provider.directoryMake( srcPath );
    self.provider.fileWrite( dstPath, ' ' );
    var srcStatExpected = self.provider.fileStat( srcPath );
    var dstBefore = self.provider.fileRead( dstPath );
    var dirBefore = self.provider.directoryRead( dir );
    return self.provider.fileCopy
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    })
    .doThen( ( err, got ) =>
    {
      test.identical( got, false );
      var srcStat = self.provider.fileStat( srcPath );
      var dstNow = self.provider.fileRead( dstPath );
      test.is( srcStat.isDirectory() );
      test.identical( srcStat.size, srcStatExpected.size );
      test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
      test.identical( dstNow, dstBefore );
      var dirAfter = self.provider.directoryRead( dir );
      test.identical( dirAfter, dirBefore );
    })

  })

  return consequence;
}

//

function fileCopyLinksAsync( test )
{
  var self = this;

  // !!!needs adjusting

  if( !_.routineIs( self.provider.fileCopyAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/' + test.name );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  var otherPath = _.path.join( dir, 'other' );

  var con = new _.Consequence().give()

  //

  /* hardlink */

  .doThen( () =>
  {
    test.case = 'dst is a hard link, breaking disabled';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkHard( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 0,
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( () =>
    {
      test.is( self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.is( srcFile !== otherFile );
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkHard( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 1,
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( () =>
    {
      test.is( self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.is( srcFile !== otherFile );
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'dst is a hard link, breakingDstHardLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkHard( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 0,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( () =>
    {
      test.is( !self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.is( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.is( srcFile !== dstFile );
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkHard( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      // breakingDstSoftLink : 1,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( () =>
    {
      test.is( !self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.is( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.is( srcFile !== dstFile );
    })
  });

  //

  if( !test.context.symlinkIsAllowed() )
  return con;

  /* soft links */

  // con.doThen( () =>
  // {
  //   test.case = 'dst is a soft link, breaking disabled';
  //   self.provider.filesDelete( dir );
  //   self.provider.fileWrite( srcPath, srcPath );
  //   self.provider.fileWrite( otherPath, otherPath );
  //   self.provider.linkSoft( dstPath, srcPath );
  //   return self.provider.fileCopy
  //   ({
  //     dstPath : dstPath,
  //     srcPath : otherPath,
  //     sync : 0,
  //     // breakingDstSoftLink : 0,
  //     breakingDstHardLink : 0
  //   })
  //   .ifNoErrorThen( () =>
  //   {
  //     test.is( self.provider.fileIsSoftLink( dstPath ) );
  //     var dstFile = self.provider.fileRead( dstPath );
  //     var srcFile = self.provider.fileRead( srcPath );
  //     var otherFile = self.provider.fileRead( otherPath );
  //     test.identical( dstFile, srcFile );
  //     test.identical( otherFile, srcFile );
  //     self.provider.fileWrite( srcPath, srcPath );
  //     var dstFile = self.provider.fileRead( dstPath );
  //     var srcFile = self.provider.fileRead( srcPath );
  //     test.identical( dstFile, srcFile );
  //     test.is( srcFile !== otherFile );
  //   })
  // })

  //

  /* .doThen( () =>
  {
    test.case = 'dst is a soft link, breakingDstSoftLink : 0 ,breakingDstHardLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkSoft( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 0,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( () =>
    {
      test.is( self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.is( srcFile !== otherFile );
    })
  }) */

  //

  /* .doThen( () =>
  {
    test.case = 'dst is a soft link, breakingDstSoftLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkSoft( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 1,
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( () =>
    {
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.is( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.is( srcFile !== dstFile );
    })
  }) */

  /* .doThen( () =>
  {
    test.case = 'dst is a soft link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.linkSoft( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 1,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( () =>
    {
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.is( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.is( srcFile !== dstFile );
    })
  }) */

  return con;
}

//

function fileCopyAsyncThrowingError( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileCopy ) )
  return;

  var dir = test.context.makePath( 'written/fileCopyAsync' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.case = 'async, throwing error';
    var con = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'invalid.txt' ),
      dstPath : test.context.makePath( 'dstPath.txt' ),
      sync : 0,
    });

    return test.shouldThrowErrorAsync( con );
  })
  .ifNoErrorThen( function()
  {
    test.case = 'async,try rewrite dir';
    var con = self.provider.fileCopy
    ({
      srcPath : test.context.makePath( 'invalid.txt' ),
      dstPath : test.context.makePath( 'tmp' ),
      sync : 0,
    });

    return test.shouldThrowErrorAsync( con );
  })
  .ifNoErrorThen( function()
  {
    test.case = 'async copy dir';
    try
    {
      self.provider.directoryMake
      ({
        filePath : test.context.makePath( 'written/fileCopyAsync/copydir' ),
        sync : 1
      });
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'written/fileCopyAsync/copydir/copyfile.txt' ),
        data : 'Lorem',
        sync : 1
      });
    } catch ( err ) { }

    debugger;
    var con = self.provider.fileCopy
    ({
        srcPath : test.context.makePath( 'written/fileCopyAsync/copydir' ),
        dstPath : test.context.makePath( 'written/fileCopyAsync/copydir2' ),
        sync : 0,
    });

    return test.shouldThrowErrorAsync( con );
  });

  return consequence;
}

//

function fileRenameSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRenameAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var got;
  var srcPath = test.context.makePath( 'written/fileRename/src' );
  var dstPath = test.context.makePath( 'written/fileRename/dst' );
  var dir  = _.path.dir( srcPath );

  //

  test.case = 'src not exist';

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 1,
      throwing : 0,
    });
  });
  test.identical( got, false );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 0,
      throwing : 1,
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 1,
      rewriting : 0,
      throwing : 0,
    });
  });
  test.identical( got, false );

  //

  test.case = 'rename in same directory,dst not exist';

  /**/

  self.provider.fileWrite( srcPath, ' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, ' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, ' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, ' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  //

  test.case = 'rename with rewriting in same directory';

  /**/

  self.provider.fileWrite( srcPath, ' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileWrite( srcPath, ' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.fileWrite( srcPath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );

  //

  test.case = 'rename dir, dst not exist';
  self.provider.filesDelete( dir );

  /**/

  self.provider.directoryMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.directoryMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.directoryMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.directoryMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  //

  test.case = 'rename moving to other existing dir';

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  //

  test.case = 'rename moving to not existing dir';

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, false )
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false )
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'dst is not empty dir';

  /**/

  debugger
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( dstPath,' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : _.path.dir( dstPath ),
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( dstPath,' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : _.path.dir( dstPath ),
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( dstPath,' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : _.path.dir( dstPath ),
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( dstPath,' ' );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : _.path.dir( dstPath ),
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir','src' ] );

  //src is equal to dst

  test.case = 'src is equal to dst';

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

}

//

function fileRenameRelativePath( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRenameAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/fileRenameRelativePath' );
  let pathToDir = test.context.makePath( 'written/fileRenameRelativePath/dir' );
  let pathToFile = test.context.makePath( 'written/fileRenameRelativePath/file' );

  test.open( 'src - relative path to a file' );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile );

  var srcPath = './../file';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile );


  var srcPath = '../../file';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile );

  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile );

  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/fileRenameRelativePath/a/file' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/a/b/c/dstFile' );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile2 ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile2 );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/fileRenameRelativePath/a/file' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/a/b/c/dstFile' );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile2 ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile2 );

  test.close( 'src - relative path to a file' );

  //

  test.open( 'dst - relative path to a file' );

  pathToFile = test.context.makePath( 'written/fileRenameRelativePath/a/b/c/file' );

  var srcPath = pathToFile;
  var dstPath = '../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.fileRead( dstPathResolved );
  test.identical( got, pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.fileRead( dstPathResolved );
  test.identical( got, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.fileRead( dstPathResolved );
  test.identical( got, pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.fileRead( dstPathResolved );
  test.identical( got, pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.fileRead( dstPathResolved );
  test.identical( got, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../../../dstFile';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.fileRead( dstPathResolved );
  test.identical( got, pathToFile );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  var srcPath = '../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.directoryRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = './../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.directoryRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = '../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dst/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.directoryRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = './../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dst/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.directoryRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = '../../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/a/b/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.directoryRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = './../../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/a/b/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.directoryRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  test.close( 'src - relative path to a dir' );

  //

  test.open( 'dst - relative path to a dir' );

  pathToDir = test.context.makePath( 'written/fileRenameRelativePath/1/2/3/dir' )

  var srcPath = pathToDir;
  var dstPath = '../dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../../dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../../dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../../../dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../../../dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../a/b/dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../a/b/dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.directoryRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  test.close( 'dst - relative path to a dir' );

  test.open( 'same paths' );

  pathToFile =  test.context.makePath( 'written/fileRenameRelativePath/file' )

  var srcPath = pathToFile;
  var dstPath = '../file';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  var statBefore = self.provider.fileStat( pathToFile );
  var got = self.provider.fileRename( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.fileStat( pathToFile );
  test.identical( statBefore.mtime.getTime(), statNow.mtime.getTime() );

  var srcPath = '../file';
  var dstPath = pathToFile;
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  var statBefore = self.provider.fileStat( pathToFile );
  var got = self.provider.fileRename( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.fileStat( pathToFile );
  test.identical( statBefore.mtime.getTime(), statNow.mtime.getTime() );

  test.close( 'same paths' );

}

//

function fileRenameAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRenameAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var got;
  var srcPath = test.context.makePath( 'written/fileRenameAsync/src' );
  var dstPath = test.context.makePath( 'written/fileRenameAsync/dst' );
  var dir  = _.path.dir( srcPath );


  var consequence = new _.Consequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.case = 'src not exist';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 1,
      throwing : 1,
    });

    return test.shouldThrowError( con );
  })

  /**/

  consequence
  .doThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 1,
      throwing : 0,
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  /**/

  consequence
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 0,
      throwing : 1,
    });

    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : test.context.makePath( 'not_existing_path' ),
      dstPath : ' ',
      sync : 0,
      rewriting : 0,
      throwing : 0,
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'rename in same directory,dst not exist';
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'rename with rewriting in same directory';
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });

  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });

  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, ' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'rename dir, dst not exist';
    self.provider.filesDelete( dir );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( srcPath );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dstPath );
    self.provider.directoryMake( srcPath );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dstPath );
    self.provider.directoryMake( srcPath );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dstPath );
    self.provider.directoryMake( srcPath );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'rename moving to other existing dir';
    dstPath = test.context.makePath( 'written/fileRenameAsync/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.path.dir( dstPath ) );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.path.dir( dstPath ) );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.path.dir( dstPath ) );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.path.dir( dstPath ) );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'rename moving to not existing dir';
    dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'dst is not empty dir';
    dstPath = test.context.makePath( 'written/fileRenameAsync/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.fileWrite( dstPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.fileWrite( dstPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true )
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.fileWrite( dstPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      rewriting : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.fileWrite( dstPath,' ' );
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .doThen( function( err,got )
    {
      test.identical( got, false );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir','src' ] );
    });
  })

  //src is equal to dst

  .ifNoErrorThen( function()
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  return consequence;
}

//

function fileDeleteSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDeleteAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var isExtract = false;

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  isExtract = true;

  var dir = test.context.makePath( 'written/fileDelete' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'removing not existing path';

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileDelete
    ({
      filePath : test.context.makePath( 'not_existing_path' ),
      sync : 1,
      throwing : 1
    })
  });

  /**/

  test.mustNotThrowError( function()
  {
    var got = self.provider.fileDelete
    ({
      filePath : test.context.makePath( 'not_existing_path' ),
      sync : 1,
      throwing : 0
    });
    test.identical( got, null );
  });

  //

  test.case = 'removing existing file';
  var filePath = test.context.makePath( 'written/fileDelete/file.txt');

  /**/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 0
  });
  var stat = self.provider.fileStat( filePath );
  test.identical( stat, null );

  /**/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 1
  });
  var stat = self.provider.fileStat( filePath );
  test.identical( stat, null );

  //

  test.case = 'removing empty folder';
  var filePath = test.context.makePath( 'written/fileDelete/folder');

  /**/

  self.provider.directoryMake( filePath );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 0
  });
  var stat = self.provider.fileStat( filePath );
  test.identical( stat, null );

  /**/

  self.provider.directoryMake( filePath );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 1
  });
  var stat = self.provider.fileStat( filePath );
  test.identical( stat, null );

  //

  test.case = 'try removing folder with file';
  var filePath = test.context.makePath( 'written/fileDelete/folder/file.txt');
  var folder = _.path.dir( filePath );

  /**/

  self.provider.fileWrite( filePath,' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileDelete
    ({
      filePath : folder,
      sync : 1,
      throwing : 1
    })
  });
  var stat = self.provider.fileStat( folder );
  test.is( !!stat );

  /**/

  test.mustNotThrowError( () =>
  {
    self.provider.fileDelete
    ({
      filePath : folder,
      sync : 1,
      throwing : 0
    });
  })

  var stat = self.provider.fileStat( folder );
  test.is( !!stat );

  if( self.provider.constructor.name === 'wFileProviderExtract' )
  {
    test.case = 'try to remove filesTree';

    //

    // test.shouldThrowErrorSync( function()
    // {
    //   self.provider.fileDelete
    //   ({
    //     filePath : '.',
    //     sync : 1,
    //     throwing : 1
    //   });
    // })

    /**/

    test.shouldThrowErrorSync( function()
    {
      self.provider.filesTree = {};
      self.provider.fileDelete
      ({
        filePath : '/',
        sync : 1,
        throwing : 1
      });
    })

    /**/

    // test.mustNotThrowError( function()
    // {
    //   var got = self.provider.fileDelete
    //   ({
    //     filePath : '.',
    //     sync : 1,
    //     throwing : 0
    //   });
    //   test.identical( got, null );
    // })
    // var stat = self.provider.fileStat( '.' );
    // test.is( !!stat );

    /**/

    test.shouldThrowErrorSync( function()
    {
      self.provider.filesTree = {};
      self.provider.fileDelete
      ({
        filePath : '/',
        sync : 1,
        throwing : 1
      });
    })
    var stat = self.provider.fileStat( '/' );
    test.is( !!stat );
  }

  //

  var filePath = _.path.join( dir, 'file' );

  //

  // test.case = 'delete soft link, resolvingHardLink 1';
  // self.provider.filesDelete( dir );
  // self.provider.fieldSet( 'resolvingHardLink', 1 );
  // var dst = _.path.join( dir, 'link' );
  // self.provider.fileWrite( filePath, ' ');
  // self.provider.linkHard( dst, filePath );
  // self.provider.fileDelete( dst )
  // var stat = self.provider.fileStat( dst );
  // test.identical( stat, null );
  // var stat = self.provider.fileStat( filePath );
  // test.is( !!stat );
  // self.provider.fieldReset( 'resolvingHardLink', 1 );

  // test.case = 'delete soft link, resolvingHardLink 0';
  // self.provider.filesDelete( dir );
  // self.provider.fieldSet( 'resolvingHardLink', 0 );
  // var dst = _.path.join( dir, 'link' );
  // self.provider.fileWrite( filePath, ' ');
  // self.provider.linkHard( dst, filePath );
  // self.provider.fileDelete( dst )
  // var stat = self.provider.fileStat( dst );
  // test.identical( stat, null );
  // var stat = self.provider.fileStat( filePath );
  // test.is( !!stat );
  // self.provider.fieldReset( 'resolvingHardLink', 0 );

  //

  if( !test.context.symlinkIsAllowed() )
  return;

  test.case = 'delete soft link, resolvingSoftLink 1';
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var dst = _.path.join( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.linkSoft( dst, filePath );
  self.provider.fileDelete( dst )
  var stat = self.provider.fileStat( dst );
  test.identical( stat, null );
  var stat = self.provider.fileStat( filePath );
  test.is( !!stat );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

  test.case = 'delete soft link, resolvingSoftLink 0';
  self.provider.filesDelete( dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var dst = _.path.join( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.linkSoft( dst, filePath );
  self.provider.fileDelete( dst )
  var stat = self.provider.fileStat( dst );
  test.identical( stat, null );
  var stat = self.provider.fileStat( filePath );
  test.is( !!stat );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
}

//

function fileDeleteActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDeleteAct ) )
  {
    test.case = 'fileDeleteAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'fileDeleteActSync' );

  //

  test.case = 'basic usage';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.path.nativize( o.filePath );
  self.provider.fileDeleteAct( o );
  test.identical( o, expected );
  var stat = self.provider.fileStat( srcPath );
  test.is( !stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'no src';
  var srcPath = _.path.join( dir,'src' );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileDeleteAct( o );
  })
  var stat = self.provider.fileStat( srcPath );
  test.is( !stat );

  //

  test.case = 'src is empty dir';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.directoryMake( srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  self.provider.fileDeleteAct( o );
  var stat = self.provider.fileStat( srcPath );
  test.is( !stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'src is empty dir';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : dir,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileDeleteAct( o );
  })
  var stat = self.provider.fileStat( dir );
  test.is( !!stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'should path nativize all paths in options map if needed by its own means';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.path.nativize( o.filePath );
  self.provider.fileDeleteAct( o );
  test.identical( o, expected );
  var stat = self.provider.fileStat( srcPath );
  test.is( !stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  expected.filePath = self.provider.path.nativize( o.filePath );
  self.provider.fileDeleteAct( o );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  var stat = self.provider.fileStat( srcPath );
  test.is( !stat );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.case = 'should assert that path is absolute';
  var srcPath = './src';

  test.shouldThrowError( () =>
  {
    self.provider.fileDeleteAct
    ({
      filePath : srcPath,
      sync : 1
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.path.join( dir,'src' );

  /* sync option is missed */

  var o =
  {
    filePath : srcPath,
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileDeleteAct( o );
  });

  /* redundant option */

  var o =
  {
    filePath : srcPath,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileDeleteAct( o );
  });

  //

  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.case = 'should expect normalized path, but not nativized';
    var srcPath = _.path.join( dir,'src' );
    self.provider.fileWrite( srcPath, srcPath );
    var o =
    {
      filePath : srcPath,
      sync : 1
    }
    var originalPath = o.filePath;
    o.filePath = self.provider.path.nativize( o.filePath );
    if( o.filePath !== originalPath )
    {
      test.shouldThrowError( () =>
      {
        self.provider.fileDeleteAct( o );
      })
    }
    else
    {
      test.mustNotThrowError( () =>
      {
        self.provider.fileDeleteAct( o );
      })
    }
    self.provider.filesDelete( dir );
  }

  //

  test.case = 'should expect ready options map, no complex arguments preprocessing';
  var srcPath = _.path.join( dir,'src' );
  var o =
  {
    filePath : [ srcPath ],
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.fileDeleteAct( o );
  })
  test.identical( o.filePath, expected.filePath );
}

//

function fileDeleteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDeleteAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var isExtract = false;

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  isExtract = true;

  var filePath,folder;

  var dir = test.context.makePath( 'written/fileDeleteAsync' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.case = 'removing not existing path';
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileDelete
    ({
      filePath : test.context.makePath( 'not_existing_path' ),
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.fileDelete
    ({
      filePath : test.context.makePath( 'not_existing_path' ),
      sync : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( ( got ) => test.identical( got, null ) );

  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'removing file';
    filePath = test.context.makePath( 'written/fileDeleteAsync/file.txt');
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( filePath );
      test.identical( stat, null );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( filePath );
      test.identical( stat, null );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'removing existing empty folder';
    filePath = test.context.makePath( 'written/fileDeleteAsync/folder');
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( filePath );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( filePath );
      test.identical( stat, null );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.directoryMake( filePath );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var stat = self.provider.fileStat( filePath );
      test.identical( stat, null );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'removing existing folder with file';
    filePath = test.context.makePath( 'written/fileDeleteAsync/folder/file.txt');

  })

  /**/

  .ifNoErrorThen( function()
  {
    folder = _.path.dir( filePath );
    self.provider.fileWrite( filePath,' ' );
    var con = self.provider.fileDelete
    ({
      filePath : folder,
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con )
    .doThen( function()
    {
      var stat = self.provider.fileStat( folder );
      test.is( !!stat );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileDelete
    ({
      filePath : folder,
      sync : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      var stat = self.provider.fileStat( folder );
      test.is( !!stat );
      test.identical( got, null )
    });
  })
  .ifNoErrorThen( function()
  {
    if( self.provider.constructor.name !== 'wFileProviderExtract' )
    return;

    test.case = 'try to remove filesTree';

    //

    return test.shouldThrowError( function()
    {
      return self.provider.fileDelete
      ({
        filePath : '.',
        sync : 0,
        throwing : 1
      });
    })
    .doThen( function()
    {
      return test.shouldThrowError( function()
      {
        self.provider.filesTree = {};
        return self.provider.fileDelete
        ({
          filePath : '/',
          sync : 0,
          throwing : 1
        });
      })
    })
    .doThen( function()
    {
      return test.shouldThrowError( function()
      {
        return self.provider.fileDelete
        ({
          filePath : '.',
          sync : 0,
          throwing : 1
        });
      })
    })
    .doThen( function()
    {
      self.provider.filesTree = {};
      test.shouldThrowError( function()
      {
        return self.provider.fileDelete
        ({
          filePath : '/',
          sync : 0,
          throwing : 1
        });
      })
    })
    .doThen( function()
    {
    })
  })
  .doThen( () =>
  {
    filePath = _.path.join( dir, 'file' );
  })
  .ifNoErrorThen( () =>
  {
    // test.case = 'delete hard link, resolvingHardLink 1';
    // self.provider.filesDelete( dir );
    // self.provider.fieldSet( 'resolvingHardLink', 1 );
    // var dst = _.path.join( dir, 'link' );
    // self.provider.fileWrite( filePath, ' ');
    // self.provider.linkHard( dst, filePath );
    // return self.provider.fileDelete
    // ({
    //   filePath : dst,
    //   sync : 0,
    //   throwing : 1
    // })
    // .ifNoErrorThen( () =>
    // {
    //   var stat = self.provider.fileStat( dst );
    //   test.identical( stat, null );
    //   var stat = self.provider.fileStat( filePath );
    //   test.is( !!stat );
    //   self.provider.fieldReset( 'resolvingHardLink', 1 );
    // })
  })
  .ifNoErrorThen( () =>
  {
    // test.case = 'delete hard link, resolvingHardLink 0';
    // self.provider.filesDelete( dir );
    // self.provider.fieldSet( 'resolvingHardLink', 0 );
    // var dst = _.path.join( dir, 'link' );
    // self.provider.fileWrite( filePath, ' ');
    // self.provider.linkHard( dst, filePath );
    // return self.provider.fileDelete
    // ({
    //   filePath : dst,
    //   sync : 0,
    //   throwing : 1
    // })
    // .ifNoErrorThen( () =>
    // {
    //   var stat = self.provider.fileStat( dst );
    //   test.identical( stat, null );
    //   var stat = self.provider.fileStat( filePath );
    //   test.is( !!stat );
    //   self.provider.fieldReset( 'resolvingHardLink', 0 );
    // })
  });

  if( !test.context.symlinkIsAllowed() )
  return consequence;

  consequence.ifNoErrorThen( () =>
  {
    var filePath = _.path.join( dir, 'file' );
    test.case = 'delete soft link, resolvingSoftLink 1';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    var dst = _.path.join( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.linkSoft( dst, filePath );
    return self.provider.fileDelete
    ({
      filePath : dst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( () =>
    {
      var stat = self.provider.fileStat( dst );
      test.identical( stat, null );
      var stat = self.provider.fileStat( filePath );
      test.is( !!stat );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
    })

  })
  .ifNoErrorThen( () =>
  {
    test.case = 'delete soft link, resolvingSoftLink 0';
    self.provider.filesDelete( dir );
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var dst = _.path.join( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.linkSoft( dst, filePath );
    return self.provider.fileDelete
    ({
      filePath : dst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( () =>
    {
      var stat = self.provider.fileStat( dst );
      test.identical( stat, null );
      var stat = self.provider.fileStat( filePath );
      test.is( !!stat );
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
    })
  })

  return consequence;

}

//

function fileStatSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStatAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/fileStat' );
  var filePath,expected;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  filePath = test.context.makePath( 'read/fileStat/src.txt' );
  self.provider.fileWrite( filePath, 'Excepteur sint occaecat cupidatat non proident' );
  test.case = 'synchronous file stat default options';
  expected = 46;

  /**/

  var got = self.provider.fileStat( filePath );
  if( _.bigIntIs( got.size ) )
  expected = BigInt( expected );
  test.identical( got.size, expected );

  /**/

  var got = self.provider.fileStat
  ({
    sync : 1,
    filePath : filePath,
    throwing : 1
  });
  if( _.bigIntIs( got.size ) )
  expected = BigInt( expected );
  test.identical( got.size, expected );

  //

  test.case = 'invalid path';
  filePath = test.context.makePath( '///bad path///test.txt' );

  /**/

  var got = self.provider.fileStat
  ({
    sync : 1,
    filePath : filePath,
    throwing : 0
  });
  var expected = null;
  test.identical( got, expected );

  /**/

  test.shouldThrowErrorSync( function()
  {
    var got = self.provider.fileStat
    ({
      sync : 1,
      filePath : filePath,
      throwing : 1
    });
  });
}

//

function fileStatActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStatAct ) )
  {
    test.case = 'fileStatAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'fileStatActSync' );

  //

  test.case = 'basic usage, should path nativize all paths in options map if needed by its own means';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1
  }
  var expected = _.mapExtend( null, o );
  // expected.filePath = self.provider.path.nativize( o.filePath );
  var stat = self.provider.fileStatAct( o );
  test.identical( o, expected );
  test.is( !!stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'no src';
  var srcPath = _.path.join( dir,'src' );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1
  }
  var expected = _.mapExtend( null, o );
  // expected.filePath = self.provider.path.nativize( o.filePath );
  var stat = self.provider.fileStatAct( o );
  test.identical( o, expected );
  test.is( !stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'no src';
  var srcPath = _.path.join( dir,'src' );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 1,
    resolvingSoftLink : 1
  }
  var expected = _.mapExtend( null, o );
  // expected.filePath = self.provider.path.nativize( o.filePath );
  test.shouldThrowError( () => self.provider.fileStatAct( o ) )
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1
  }
  var expected = _.mapOwnKeys( o );
  // expected.filePath = self.provider.path.nativize( o.filePath );
  var stat = self.provider.fileStatAct( o );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  test.is( !!stat );
  self.provider.filesDelete( dir );

  //

  if( test.context.symlinkIsAllowed() )
  {
    test.case = 'src is a soft link';
    var srcPath = _.path.join( dir,'src' );
    var dstPath = _.path.join( dir,'dst' );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.linkSoft( dstPath, srcPath );
    var o =
    {
      filePath : dstPath,
      sync : 1,
      throwing : 0,
      resolvingSoftLink : 1
    }
    var stat = self.provider.fileStatAct( o );
    test.is( !!stat );
    test.is( !stat.isSymbolicLink() );
    self.provider.filesDelete( dir );

    //

    test.case = 'src is a soft link';
    var srcPath = _.path.join( dir,'src' );
    var dstPath = _.path.join( dir,'dst' );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.linkSoft( dstPath, srcPath );
    var o =
    {
      filePath : dstPath,
      sync : 1,
      throwing : 0,
      resolvingSoftLink : 0
    }
    var stat = self.provider.fileStatAct( o );
    test.is( !!stat );
    test.is( stat.isSymbolicLink() );
    self.provider.filesDelete( dir );
  }

  //

  if( !Config.debug )
  return;

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.case = 'should assert that path is absolute';
    var srcPath = './src';

    test.shouldThrowError( () =>
    {
      self.provider.fileStatAct
      ({
        filePath : srcPath,
        sync : 1,
        throwing : 0,
        resolvingSoftLink : 1
      });
    })
  }



  //

  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct
    ({
      filePath : srcPath,
      sync : 1,
      throwing : 1,
      resolvingSoftLink : 1
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.path.join( dir,'src' );

  /* sync option is missed */

  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct
    ({
      filePath : srcPath,
      throwing : 0,
      resolvingSoftLink : 1
    });
  });

  //

  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct
    ({
      filePath : srcPath,
      throwing : 1,
      resolvingSoftLink : 1
    });
  });

  /* redundant option */

  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct( o );
  });

  //

  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 1,
    resolvingSoftLink : 1,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct( o );
  });

  //

  test.case = 'should expect normalized path, but not nativized';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );

  //

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    var o =
    {
      filePath : srcPath,
      sync : 1,
      throwing : 0,
      resolvingSoftLink : 1,
    }
    var originalPath = o.filePath;
    o.filePath = self.provider.path.nativize( o.filePath );
    if( o.filePath !== originalPath )
    {
      test.shouldThrowError( () =>
      {
        self.provider.fileStatAct( o );
      })
    }
    else
    {
      test.mustNotThrowError( () =>
      {
        self.provider.fileStatAct( o );
      })
    }
    self.provider.filesDelete( dir );

    //

    var o =
    {
      filePath : srcPath,
      sync : 1,
      throwing : 1,
      resolvingSoftLink : 1,
    }
    o.filePath = self.provider.path.nativize( o.filePath );
    test.shouldThrowError( () =>
    {
      self.provider.fileStatAct( o );
    })
    self.provider.filesDelete( dir );
  }

  //

  test.case = 'should expect ready options map, no complex arguments preprocessing';
  var srcPath = _.path.join( dir,'src' );

  //

  var o =
  {
    filePath : [ srcPath ],
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1,
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct( o );
  })
  test.identical( o.filePath, expected.filePath );

  //

  var o =
  {
    filePath : [ srcPath ],
    sync : 1,
    throwing : 1,
    resolvingSoftLink : 1,
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.fileStatAct( o );
  })
  test.identical( o.filePath, expected.filePath );
}

//

function fileStatAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileStatAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/fileStatAsync' );
  var filePath,expected;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  //

  consequence
  .ifNoErrorThen( function()
  {
    filePath = test.context.makePath( 'read/fileStatAsync/src.txt' );
    self.provider.fileWrite( filePath, 'Excepteur sint occaecat cupidatat non proident' );
    test.case = 'synchronous file stat default options';
    expected = 46;
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileStat
    ({
      sync : 0,
      filePath : filePath,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      if( _.bigIntIs( got.size ) )
      expected = BigInt( expected );
      test.identical( got.size, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileStat
    ({
      sync : 0,
      filePath : filePath,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      if( _.bigIntIs( got.size ) )
      expected = BigInt( expected );
      test.identical( got.size, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'invalid path';
    filePath = test.context.makePath( '///bad path///test.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileStat
    ({
      sync : 0,
      filePath : filePath,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = null;
      test.identical( got, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileStat
    ({
      sync : 0,
      filePath : filePath,
      throwing : 1
    });

    return test.shouldThrowError( con )
    .doThen( function()
    {
    })
  });

  return consequence;
}

//

function directoryMakeSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryMakeAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  if( isBrowser )
  if( self.provider.filesTree )
  self.provider.filesTree = {};

  var dir = test.context.makePath( 'written/directoryMake' );
  var filePath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'synchronous mkdir';
  filePath = test.context.makePath( 'written/directoryMake/make_dir' );

  /**/

  self.provider.directoryMake( filePath );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'make_dir' ] );

  //

  test.case = 'synchronous mkdir force';
  self.provider.filesDelete( filePath );
  filePath = test.context.makePath( 'written/directoryMake/make_dir/dir1/' );

  /**/

  self.provider.directoryMake
  ({
    filePath : filePath,
    sync : 1,
    force : 1
  });
  var files = self.provider.directoryRead( _.path.dir( filePath ) );
  test.identical( files, [ 'dir1' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.filesDelete( _.path.dir( filePath ) );
    self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 1,
      force : 0
    });
  })

  //

  test.case = 'try to rewrite terminal file';
  filePath = test.context.makePath( 'written/directoryMake/terminal.txt' );
  self.provider.fileWrite( filePath, ' ' );

  /**/

  self.provider.directoryMake
  ({
    filePath : filePath,
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( _.path.dir( filePath ) );
  test.identical( files, [ 'terminal.txt' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 1,
      force : 1,
      rewritingTerminal : 0
    });
  })

  //

  test.case = 'try to rewrite empty dir';
  filePath = test.context.makePath( 'written/directoryMake/empty' );

  /**/

  self.provider.filesDelete( dir )
  self.provider.directoryMake( filePath );
  self.provider.directoryMake
  ({
    filePath : filePath,
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( _.path.dir( filePath ) );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.filesDelete( dir )
  self.provider.directoryMake( filePath );
  self.provider.directoryMake
  ({
    filePath : filePath,
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.filesDelete( dir )
  self.provider.directoryMake( filePath );
  self.provider.directoryMake
  ({
    filePath : filePath,
    sync : 1,
    force : 1,
    rewritingTerminal : 0
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.filesDelete( dir )
  self.provider.directoryMake( filePath );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 1,
      force : 0,
      rewritingTerminal : 1
    });
  });

  /**/

  self.provider.filesDelete( dir )
  self.provider.directoryMake( filePath );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  //

  test.case = 'dir exists, no rewritingTerminal, no force';
  filePath = test.context.makePath( 'written/directoryMake/make_dir/' );

  /**/

  // self.provider.filesDelete( filePath );
  self.provider.directoryMake( filePath );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  //

  test.case = 'try to rewrite folder with files';
  filePath = test.context.makePath( 'written/directoryMake/make_dir/file' );
  self.provider.filesDelete( dir );

  /**/

  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 1,
      force : 0,
      rewritingTerminal : 1
    });
  });

  /**/

  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  /**/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.directoryMake
  ({
    filePath : _.path.dir( filePath ),
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'make_dir' ] );


  //

  test.case = 'folders structure not exist';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/directoryMake/dir' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
        filePath : filePath,
        sync : 1,
        force : 0,
        rewritingTerminal : 0
    });
  });

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
        filePath : filePath,
        sync : 1,
        force : 0,
        rewritingTerminal : 1
    });
  });

  /**/

  self.provider.directoryMake
  ({
      filePath : filePath,
      sync : 1,
      force : 1,
      rewritingTerminal : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.directoryMake
  ({
      filePath : filePath,
      sync : 1,
      force : 1,
      rewritingTerminal : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir' ] );
}

//

function directoryMakeAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryMakeAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  if( isBrowser )
  if( self.provider.filesTree )
  self.provider.filesTree = {};

  var dir = test.context.makePath( 'written/directoryMakeAsync' );
  var filePath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  //

  consequence
  .ifNoErrorThen( function()
  {
    test.case = 'synchronous mkdir';
    filePath = test.context.makePath( 'written/directoryMakeAsync/make_dir' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'make_dir' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'synchronous mkdir force';
    self.provider.filesDelete( filePath );
    filePath = test.context.makePath( 'written/directoryMakeAsync/make_dir/dir1/' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( _.path.dir( filePath ) );
      test.identical( files, [ 'dir1' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( _.path.dir( filePath ) );
    var con = self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 0,
      rewritingTerminal : 1
    });
   return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'try to rewrite terminal file';
    filePath = test.context.makePath( 'written/directoryMakeAsync/terminal.txt' );
    self.provider.fileWrite( filePath, ' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( _.path.dir( filePath ) );
      test.identical( files, [ 'terminal.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 1,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'try to rewrite empty dir';
    filePath = test.context.makePath( 'written/directoryMakeAsync/empty' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir )
    self.provider.directoryMake( filePath );
    return self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( _.path.dir( filePath ) );
      test.identical( files, [ 'empty' ] );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir )
    self.provider.directoryMake( filePath );
    return self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 1,
      rewritingTerminal : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'empty' ] );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir )
    self.provider.directoryMake( filePath );
    var con = self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    self.provider.filesDelete( dir )
    self.provider.directoryMake( filePath );
    var con = self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'dir exists, no rewritingTerminal, no force';
    filePath = test.context.makePath( 'written/directoryMakeAsync/make_dir/' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( filePath );
    self.provider.directoryMake( filePath );
    var con = self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'try to rewrite folder with files';
    filePath = test.context.makePath( 'written/directoryMakeAsync/make_dir/file' );
    self.provider.filesDelete( dir );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.directoryMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      force : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.directoryMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      force : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    return self.provider.directoryMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      force : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'make_dir' ] );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'folders structure not exist';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/directoryMakeAsync/dir' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.directoryMake
    ({
        filePath : filePath,
        sync : 0,
        force : 0,
        rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.directoryMake
    ({
        filePath : filePath,
        sync : 0,
        force : 0,
        rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    return self.provider.directoryMake
    ({
        filePath : filePath,
        sync : 0,
        force : 1,
        rewritingTerminal : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    return self.provider.directoryMake
    ({
        filePath : filePath,
        sync : 0,
        force : 1,
        rewritingTerminal : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dir' ] );
    });
  })

  return consequence;
}



function fileHashSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileReadAct ) ||  !_.routineIs( self.provider.fileStatAct ) || self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    test.identical( 1, 1 );
    return;
  }

  if( isBrowser )
  return;

  var dir = test.context.makePath( 'read/fileHash' );
  var got,filePath,data;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'synchronous filehash';
  data = 'Excepteur sint occaecat cupidatat non proident';
  filePath = test.context.makePath( 'read/fileHash/src.txt' );

  /**/

  self.provider.fileWrite( filePath, data );
  got = self.provider.fileHash( filePath );
  var md5sum = crypto.createHash( 'md5' );
  md5sum.update( data );
  var expected = md5sum.digest( 'hex' );
  test.identical( got, expected );

  //

  test.case = 'invalid path';
  filePath = test.context.makePath( 'invalid.txt' );

  /**/

  got = self.provider.fileHash
  ({
     filePath : filePath,
     throwing : 0
  });
  var expected = NaN;
  test.identical( got, expected );

  /*invalid path throwing enabled*/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileHash
    ({
      filePath : filePath,
      sync : 1,
      throwing : 1
    });
  });

  /*invalid path throwing disabled*/

  test.mustNotThrowError( function( )
  {
    got = self.provider.fileHash
    ({
      filePath : filePath,
      sync : 1,
      throwing : 0
    });
    var expected = NaN;
    test.identical( got, expected );
  });

  /*is not terminal file*/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileHash
    ({
      filePath : test.context.makePath( '/' ),
      sync : 1,
      throwing : 1
    });
  });

  /*is not terminal file, throwing disabled*/

  test.mustNotThrowError( function( )
  {
    got = self.provider.fileHash
    ({
      filePath : test.context.makePath( '/' ),
      sync : 1,
      throwing : 0
    });
    var expected = NaN;
    test.identical( got, expected );
  });

}

//

function fileHashAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileReadAct ) || !_.routineIs( self.provider.fileStatAct ) || self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    test.identical( 1, 1 );
    return;
  }

  var dir = test.context.makePath( 'read/fileHashAsync' );
  var got,filePath,data;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  if( isBrowser )
  return;

  var consequence = new _.Consequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.case = 'async filehash';
    data = 'Excepteur sint occaecat cupidatat non proident';
    filePath = test.context.makePath( 'read/fileHashAsync/src.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath, data );
    return self.provider.fileHash
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var md5sum = crypto.createHash( 'md5' );
      md5sum.update( data );
      var expected = md5sum.digest( 'hex' );
      test.identical( got, expected );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'invalid path';
    filePath = test.context.makePath( 'invalid.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.fileHash
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = NaN;
      test.identical( got, expected );
    });
  })

  /*invalid path throwing enabled*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileHash
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );
  })

  /*invalid path throwing disabled*/

  .doThen( function()
  {
    var con = self.provider.fileHash
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      var expected = NaN;
      test.identical( got, expected );
    });
  })

  /*is not terminal file*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileHash
    ({
      filePath : test.context.makePath( '/' ),
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );
  })

  /*is not terminal file, throwing disabled*/
  .doThen( function()
  {
    var con = self.provider.fileHash
    ({
      filePath : test.context.makePath( '/' ),
      sync : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      var expected = NaN;
      test.identical( got, expected );
    })

  })

  return consequence;
}

//

function directoryReadSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryReadAct ) || !_.routineIs( self.provider.fileStatAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/directoryReadAct' );
  var got,filePath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'synchronous read';
  filePath = test.context.makePath( 'read/directoryRead/1.txt' ),

  /**/

  self.provider.fileWrite( filePath,' ' );
  var got = self.provider.directoryRead( _.path.dir( filePath ) );
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  /**/

  self.provider.fileWrite( filePath,' ' );
  var got = self.provider.directoryRead
  ({
    filePath : _.path.dir( filePath ),
    sync : 1,
    throwing : 1
  })
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  //

  test.case = 'synchronous, filePath points to file';
  filePath = test.context.makePath( 'read/directoryRead/1.txt' );

  /**/

  self.provider.fileWrite( filePath,' ' )
  var got = self.provider.directoryRead( filePath );
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  /**/

  self.provider.fileWrite( filePath,' ' )
  var got = self.provider.directoryRead
  ({
    filePath : filePath,
    sync : 1,
    throwing : 1
  })
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  //

  test.case = 'path not exist';
  filePath = test.context.makePath( 'non_existing_folder' );

  /**/

  var got = self.provider.directoryRead( filePath );
  var expected = null;
  test.identical( got, expected );

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.directoryRead
    ({
      filePath : filePath,
      sync : 1,
      throwing : 1
    });
  })
}

//

function directoryReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.directoryReadAct ) || !_.routineIs( self.provider.fileStatAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/directoryReadAsync' );
  var got,filePath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.case = 'synchronous read';
    filePath = test.context.makePath( 'read/directoryReadAsync/1.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.directoryRead
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = [ "1.txt" ];
      test.identical( got.sort(), expected.sort() );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.directoryRead
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var expected = [ "1.txt" ];
      test.identical( got.sort(), expected.sort() );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'synchronous, filePath points to file';
    filePath = test.context.makePath( 'read/directoryReadAsync/1.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.directoryRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var got = self.provider.directoryRead( filePath );
      var expected = [ '1.txt' ];
      test.identical( got, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.directoryRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var got = self.provider.directoryRead( filePath );
      var expected = [ '1.txt' ];
      test.identical( got, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'path not exist';
    filePath = test.context.makePath( 'non_existing_folder' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.directoryRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = null;
      test.identical( got, expected );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.directoryRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
    })
  })

  return consequence;
}

//

function fileWriteSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var isHd = test.context.providerIsInstanceOf( _.FileProvider.HardDrive );

  /*writeMode rewrite*/
  try
  {
    self.provider.directoryMake
    ({
      filePath : test.context.makePath( 'write_test' ),
      sync : 1
    })
  }
  catch ( err ) { }

  /*writeMode rewrite*/
  var data = "LOREM"
  test.case ='rewrite, file not exist ';
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected )

  test.case ='rewrite existing file ';
  data = "LOREM LOREM";
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  test.case = 'encoding : original.type, data: string';
  data = "LOREM LOREM";
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1,
    encoding : 'original.type'
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    encoding : 'original.type',
    sync : 1
  });
  var expected = data;
  if( isHd )
  expected = _.bufferBytesFrom( data );
  test.identical( got, expected );

  test.case = 'encoding : original.type, data: bytes buffer';
  data = new Uint8Array( [ 97,98,99 ] );
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1,
    encoding : 'original.type'
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    encoding : 'original.type',
    sync : 1
  });
  var expected = data;
  if( isHd )
  expected = _.bufferBytesFrom( data );
  test.identical( got, expected );

  test.case = 'encoding : original.type, data: array buffer';
  data = new Uint8Array( [ 97,98,99 ] ).buffer;
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    data : data,
    sync : 1,
    encoding : 'original.type'
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/dst.txt' ),
    encoding : 'original.type',
    sync : 1
  });
  var expected = data;
  if( isHd )
  expected = _.bufferBytesFrom( data );
  test.identical( got, expected );

  if( isHd )
  {
    test.case = 'encoding : original.type, data: node buffer';
    data = Buffer.from( [ 97,98,99 ] );
    self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 1,
      encoding : 'original.type'
    });
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/dst.txt' ),
      encoding : 'original.type',
      sync : 1
    });
    expected = _.bufferBytesFrom( data );
    test.identical( got, expected );
  }

  //

  if( Config.debug )
  {
    test.case ='try write to non existing folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'unknown/dst.txt' ),
        data : data,
        sync : 1,
        makingDirectory : 0,
      });
    });

    test.case ='try to rewrite folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'write_test' ),
        data : data,
        sync : 1
      });
    });
  }

  /*writeMode append*/

  self.provider.filesDelete( test.context.makePath( 'write_test/append.txt' ) );
  var data = 'APPEND';
  test.case ='append, file not exist ';
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  test.case ='append, to file ';
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/append.txt' ),
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/append.txt' ),
    sync : 1
  });
  var expected = 'APPENDAPPEND';
  test.identical( got, expected );

  //

  if( Config.debug )
  {
    test.case ='try append to non existing folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'append',
        sync : 1,
        makingDirectory : 0
      });
    });

    test.case ='try to append to folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'write_test' ),
        data : data,
        writeMode : 'append',
        sync : 1
      });
    });
  }
  /*writeMode prepend*/

  self.provider.filesDelete( test.context.makePath( 'write_test/prepend.txt' ) )
  var data = 'Lorem';
  test.case ='prepend, file not exist ';
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );

  data = 'new text';
  test.case ='prepend to file ';
  self.provider.fileWrite
  ({
    filePath : test.context.makePath( 'write_test/prepend.txt' ),
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : test.context.makePath( 'write_test/prepend.txt' ),
    sync : 1
  });
  var expected = 'new textLorem';
  test.identical( got, expected );

  //

  if( Config.debug )
  {
    test.case ='try prepend to non existing folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'unknown/dst.txt' ),
        data : data,
        writeMode : 'prepend',
        sync : 1,
        makingDirectory : 0
      });
    });

    test.case ='try to prepend to folder';
    test.shouldThrowErrorSync( function()
    {
      self.provider.fileWrite
      ({
        filePath : test.context.makePath( 'write_test' ),
        data : data,
        writeMode : 'prepend',
        sync : 1
      });
    });
  }
}

//

function fileWriteLinksSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var mp = _.routineJoin( test.context, test.context.makePath );

  var dirPath = mp( 'write_test' );
  var srcPath = mp( 'write_test/src.txt' );
  var dstPath = mp( 'write_test/dst.txt' );
  var data;

  /*writeMode rewrite*/

  //

  self.provider.filesDelete( dirPath )

  test.case ='rewrite link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkHard( dstPath, srcPath )
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data + data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( self.provider.fileIsHardLink( dstPath ) );
  data = 'rewrite';
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, data );
  test.is( self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='append link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkHard( dstPath, srcPath );
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( self.provider.fileIsHardLink( dstPath ) );
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, data + data + data );
  test.is( self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='prepend link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkHard( dstPath, srcPath )
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( self.provider.fileIsHardLink( dstPath ) );
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, data + data + data );
  test.is( self.provider.fileIsHardLink( dstPath ) );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  if( !test.context.symlinkIsAllowed() )
  return;

  /* soft link */

  self.provider.filesDelete( dirPath )

  test.case ='rewrite link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkSoft( dstPath, srcPath )
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data + data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  data = 'rewrite';
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, data );
  test.is( self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='rewrite link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkSoft( dstPath, srcPath )
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data + data,
    sync : 1
  });
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );
  data = 'rewrite';
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, expected );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='append link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkSoft( dstPath, srcPath )
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data,
    writeMode : 'append',
    sync : 1
  });
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );
  data = 'append';
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, expected );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='append link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkSoft( dstPath, srcPath )
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );
  data = 'prepend';
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, expected );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='append link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkSoft( dstPath, srcPath )
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    writeMode : 'append',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, data + data + data );
  test.is( self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.case ='prepend link file ';
  data = "LOREM";
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    sync : 1
  });
  self.provider.linkSoft( dstPath, srcPath )
  self.provider.fileWrite
  ({
    filePath : dstPath,
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : srcPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  var expected = data + data;
  test.identical( got, expected );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  self.provider.fileWrite
  ({
    filePath : srcPath,
    data : data,
    writeMode : 'prepend',
    sync : 1
  });
  var got = self.provider.fileRead
  ({
    filePath : dstPath,
    sync : 1
  });
  test.identical( got, data + data + data );
  test.is( self.provider.fileIsSoftLink( dstPath ) );

}

//

function fileWriteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var consequence = new _.Consequence().give()
  /*writeMode rewrite*/

  .doThen( () =>
  {
    return self.provider.directoryMake( test.context.makePath( 'write_test' ) )
  })

  /*writeMode rewrite*/
  var data = "LOREM"
  consequence
  .ifNoErrorThen( function()
  {
    test.case ='rewrite, file not exist ';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .doThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/dst.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected )
  })
  .ifNoErrorThen( function()
  {
    test.case ='rewrite existing file ';
    data = "LOREM LOREM";
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/dst.txt' ),
      data : data,
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .doThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/dst.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .doThen( function()
  {
    test.case ='try to rewrite folder';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test' ),
      data : data,
      sync : 0,
      makingDirectory : 0
    });

    return test.shouldThrowError( con );
  })
  /*writeMode append*/
  .doThen( function()
  {
    return self.provider.filesDelete( test.context.makePath( 'write_test/append.txt' ) );
  })
  .doThen( function()
  {
    data = 'APPEND';
    test.case ='append, file not exist ';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/append.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .doThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/append.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='append, to file ';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/append.txt' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .doThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/append.txt' ),
      sync : 1
    });
    var expected = 'APPENDAPPEND';
    test.identical( got, expected );
  })
  .doThen( function()
  {
    test.case ='try to append to folder';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test' ),
      data : data,
      writeMode : 'append',
      sync : 0
    });

    return test.shouldThrowError( con );
  })

  /*writeMode prepend*/
  .doThen( function()
  {
    return self.provider.filesDelete( test.context.makePath( 'write_test/prepend.txt' ) );
  })
  .doThen( function()
  {
    data = 'Lorem';
    test.case ='prepend, file not exist ';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/prepend.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .doThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/prepend.txt' ),
      sync : 1
    });
    var expected = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    data = 'new text';
    test.case ='prepend to file ';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test/prepend.txt' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .doThen( function( err )
  {
    var got = self.provider.fileRead
    ({
      filePath : test.context.makePath( 'write_test/prepend.txt' ),
      sync : 1
    });
    var expected = 'new textLorem';
    test.identical( got, expected );
  })
  .doThen( function()
  {
    test.case ='try prepend to folder';
    var con = self.provider.fileWrite
    ({
      filePath : test.context.makePath( 'write_test' ),
      data : data,
      writeMode : 'prepend',
      sync : 0
    });

    test.shouldThrowError( con );
  })

  return consequence;
}

fileWriteAsync.timeOut = 30000;

//

function fileWriteLinksAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var mp = _.routineJoin( test.context, test.context.makePath );

  var dirPath = mp( 'write_test' );
  var srcPath = mp( 'write_test/src.txt' );
  var dstPath = mp( 'write_test/dst.txt' );
  var data;

  var symlinkIsAllowed = test.context.symlinkIsAllowed();

  var con = new _.Consequence().give()

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return;

    self.provider.filesDelete( dirPath )

    test.case ='rewrite link file ';
    data = "LOREM";
    return self.provider.fileWrite
    ({
      filePath : srcPath,
      data : data,
      sync : 0
    })
    .doThen( () =>
    {
      self.provider.linkSoft( dstPath, srcPath )
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data + data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      test.is( self.provider.fileIsSoftLink( dstPath ) );
    })
    .doThen( () =>
    {
      data = 'rewrite';
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, data );
      test.is( self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return;

    self.provider.filesDelete( dirPath )
    var expected;

    test.case ='rewrite link file ';
    data = "LOREM";
    return self.provider.fileWrite
    ({
      filePath : srcPath,
      data : data,
      sync : 0
    })
    .doThen( () =>
    {
      self.provider.linkSoft( dstPath, srcPath )
      self.provider.fieldSet( 'resolvingSoftLink', 0 );
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data + data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      expected = data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      expected = data + data;
      test.identical( got, expected );
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
    })
    .doThen( () =>
    {
      data = 'rewrite';
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, expected );
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return;

    self.provider.filesDelete( dirPath )
    var expected;

    test.case ='rewrite link file ';
    data = "LOREM";
    return self.provider.fileWrite
    ({
      filePath : srcPath,
      data : data,
      sync : 0
    })
    .doThen( () =>
    {
      self.provider.linkSoft( dstPath, srcPath )
      self.provider.fieldSet( 'resolvingSoftLink', 0 );
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data,
        writeMode : 'append',
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      expected = data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      expected = data + data;
      test.identical( got, expected );
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
    })
    .doThen( () =>
    {
      data = 'append';
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, expected );
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return;

    self.provider.filesDelete( dirPath )
    var expected;

    test.case ='rewrite link file ';
    data = "LOREM";
    return self.provider.fileWrite
    ({
      filePath : srcPath,
      data : data,
      sync : 0
    })
    .doThen( () =>
    {
      self.provider.linkSoft( dstPath, srcPath )
      self.provider.fieldSet( 'resolvingSoftLink', 0 );
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data,
        writeMode : 'prepend',
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      expected = data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      expected = data + data;
      test.identical( got, expected );
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
    })
    .doThen( () =>
    {
      data = 'prepend';
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, expected );
      test.is( !self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    self.provider.filesDelete( dirPath )

    test.case ='rewrite link file ';
    data = "LOREM";
    return self.provider.fileWrite
    ({
      filePath : srcPath,
      data : data,
      sync : 0
    })
    .doThen( () =>
    {
      self.provider.linkHard( dstPath, srcPath )
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data + data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      test.is( self.provider.fileIsHardLink( dstPath ) );
    })
    .doThen( () =>
    {
      data = 'rewrite';
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, data );
      test.is( self.provider.fileIsHardLink( dstPath ) );
      test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
    })
  })

  //append

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return;

    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.case ='append link file ';
      data = "LOREM";
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.linkSoft( dstPath, srcPath )
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data,
        writeMode : 'append',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      test.is( self.provider.fileIsSoftLink( dstPath ) );
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        writeMode : 'append',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, data + data + data );
      test.is( self.provider.fileIsSoftLink( dstPath ) );
    })

  })
  .doThen( function()
  {
    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.case ='append link file ';
      data = "LOREM";
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.linkHard( dstPath, srcPath )
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data,
        writeMode : 'append',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      test.is( self.provider.fileIsHardLink( dstPath ) );
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        writeMode : 'append',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, data + data + data );
      test.is( self.provider.fileIsHardLink( dstPath ) );
      test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

    })

  })

  //prepend

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return;

    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.case ='append link file ';
      data = "LOREM";
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.linkSoft( dstPath, srcPath )
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data,
        writeMode : 'prepend',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      test.is( self.provider.fileIsSoftLink( dstPath ) );
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        writeMode : 'prepend',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, data + data + data );
      test.is( self.provider.fileIsSoftLink( dstPath ) );
    })

  })
  .doThen( function()
  {
    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.case ='prepend link file ';
      data = "LOREM";
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        sync : 0
      })
    })
    .doThen( () =>
    {
      self.provider.linkHard( dstPath, srcPath )
      return self.provider.fileWrite
      ({
        filePath : dstPath,
        data : data,
        writeMode : 'prepend',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : srcPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      var expected = data + data;
      test.identical( got, expected );
      test.is( self.provider.fileIsHardLink( dstPath ) );
      return self.provider.fileWrite
      ({
        filePath : srcPath,
        data : data,
        writeMode : 'prepend',
        sync : 0
      });
    })
    .doThen( () =>
    {
      var got = self.provider.fileRead
      ({
        filePath : dstPath,
        sync : 1
      });
      test.identical( got, data + data + data );
      test.is( self.provider.fileIsHardLink( dstPath ) );
      test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

    })

  })


  return con;
}

fileWriteLinksAsync.timeOut = 30000;

//

function linkSoftSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoftAct ) )
  {
    test.case = 'linkSoftAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  if( !test.context.symlinkIsAllowed() )
  {
    test.case = 'System does not allow to create soft links.';
    test.identical( 1, 1 )
    return;
  }

  var dir = test.context.makePath( 'written/linkSoft' );
  var srcPath,dstPath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'make link sync';
  srcPath  = test.context.makePath( 'written/linkSoft/link_test.txt' );
  dstPath = test.context.makePath( 'written/linkSoft/link.txt' );
  self.provider.fileWrite( srcPath, '000' );

  /**/

  self.provider.linkSoft
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
  });
  self.provider.fileWrite
  ({
    filePath : srcPath,
    writeMode : 'append',
    data : 'new text',
    sync : 1
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.fileRead( dstPath );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  var expected = '000new text';
  test.identical( got, expected );

  //

  test.case = 'make for file that not exist';
  self.provider.filesDelete( dir );
  srcPath  = test.context.makePath( 'written/linkSoft/no_file.txt' );
  dstPath = test.context.makePath( 'written/linkSoft/link2.txt' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  })

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, null );

  //

  test.case = 'link already exists';
  srcPath = test.context.makePath( 'written/linkSoft/link_test.txt' );
  dstPath = test.context.makePath( 'written/linkSoft/link.txt' );
  self.provider.fileWrite( srcPath, 'abc' );
  self.provider.linkSoft
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  });

  //

  test.case = 'src is equal to dst';
  self.provider.filesDelete( dir );
  srcPath = test.context.makePath( 'written/linkSoft/link_test.txt' );
  self.provider.fileWrite( srcPath, ' ' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 1,
      allowMissing : 1
    });
  });
  test.identical( got, true );
  test.is( self.provider.fileIsSoftLink( srcPath ) );

  /**/

  self.provider.fileDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowMissing : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  test.is( self.provider.fileIsSoftLink( srcPath ) );

  /**/

  self.provider.fileDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      allowMissing : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  test.is( self.provider.fileIsSoftLink( srcPath ) );

  /**/

  self.provider.fileDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowMissing : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  test.is( self.provider.fileIsSoftLink( srcPath ) );

  /**/

  self.provider.filesDelete( srcPath );
  test.shouldThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowMissing : 0,
      throwing : 1
    });
  });
  test.is( !self.provider.fileIsSoftLink( srcPath ) );

  /**/

  self.provider.filesDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowMissing : 0,
      throwing : 0
    });
  });
  test.is( !self.provider.fileIsSoftLink( srcPath ) );

  //

  test.case = 'try make softlink to folder';
  self.provider.filesDelete( dir );
  srcPath = test.context.makePath( 'written/linkSoft/link_test' );
  dstPath = test.context.makePath( 'written/linkSoft/link' );
  self.provider.directoryMake( srcPath );

  /**/

  self.provider.linkSoft
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link', 'link_test' ]  );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  debugger
  self.provider.linkSoft
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 0,
    sync : 1,
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link', 'link_test' ]  );

  //

  test.open( 'allowMissing' );

  self.provider.linkSoft
  ({
    srcPath : srcPath,
    dstPath : srcPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
    allowMissing : 1
  });

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError(() =>
    {
      self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 });
    })
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 });
    test.identical( got, srcPath )
  }

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 0,
    sync : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }


  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 0,
    throwing : 1,
    sync : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 0,
    throwing : 0,
    sync : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  }

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.mustNotThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
      allowMissing : 0
    });
  })

  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
      allowMissing : 0
    });
  })

  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.mustNotThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
      allowMissing : 0
    });
  })

  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  var notExistingPath = test.context.makePath( 'written/linkSoft/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
      allowMissing : 0
    });
  })

  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  //

  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
      allowMissing : 1
    });
  })

  //

  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
      allowMissing : 0
    });
  })

  //

  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
      allowMissing : 0
    });
  })

  //

  test.mustNotThrowError( () =>
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
      allowMissing : 0
    });
  })

  test.close( 'allowMissing' );

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  })
}

//

function linkSoftAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoftAct ) )
  {
    test.case = 'linkSoftAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  if( !test.context.symlinkIsAllowed() )
  {
    test.case = 'System does not allow to create soft links.';
    test.identical( 1, 1 )
    return;
  }

  var dir = test.context.makePath( 'written/linkSoftAsync' );
  var srcPath,dstPath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();
  consequence

  //

  .ifNoErrorThen( function()
  {
    test.case = 'make link async';
    srcPath  = test.context.makePath( 'written/linkSoftAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/linkSoftAsync/link.txt' );
    self.provider.fileWrite( srcPath, '000' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite
      ({
        filePath : srcPath,
        writeMode : 'append',
        data : 'new text',
        sync : 1
      });
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      self.provider.fieldSet( 'resolvingSoftLink', 1 );
      var got = self.provider.fileRead( dstPath );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
      var expected = '000new text';
      test.identical( got, expected );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'make for file that not exist';
    self.provider.filesDelete( dir );
    srcPath  = test.context.makePath( 'written/linkSoftAsync/no_file.txt' );
    dstPath = test.context.makePath( 'written/linkSoftAsync/link2.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function( )
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, null );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'link already exists';
    srcPath = test.context.makePath( 'written/linkSoftAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/linkSoftAsync/link.txt' );
    self.provider.fileWrite( srcPath, 'abc' );
    self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  //
  .ifNoErrorThen( function()
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/linkSoftAsync/link_test.txt' );
    self.provider.fileWrite( srcPath, ' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.fileIsSoftLink( srcPath ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( srcPath );
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      allowMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.fileIsSoftLink( srcPath ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( srcPath );
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      allowMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.fileIsSoftLink( srcPath ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( srcPath );
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      allowMissing : 1,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.fileIsSoftLink( srcPath ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( srcPath );
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      allowMissing : 0,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
      test.is( !self.provider.fileIsSoftLink( srcPath ) );
    })
  })

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( srcPath );
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      allowMissing : 0,
      rewriting : 0,
      throwing : 1
    })
    return test.shouldThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.is( !self.provider.fileIsSoftLink( srcPath ) );
    })
  })

  //

  .doThen( function()
  {
    test.case = 'try make hardlink for folder';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/linkSoftAsync/link_test' );
    dstPath = test.context.makePath( 'written/linkSoftAsync/link' );
    self.provider.directoryMake( srcPath );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link', 'link_test' ]  );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link', 'link_test' ]  );
    })
  })

  //

  .doThen( () => test.open( 'allowMissing' ) )

  //

  .doThen( () =>
  {

    return self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
      allowMissing : 1
    })
    .doThen( () =>
    {
      if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
      {
        test.shouldThrowError( () => self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 }) )
      }
      else
      {
        var got = self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 });
        test.identical( got, srcPath )
      }
    })

  })

  .doThen( () =>
  {
    let con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
      allowMissing : 1
    });
    return test.shouldThrowError( con );

  })

  .doThen( () =>
  {
    let con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
      allowMissing : 0
    });
    return test.shouldThrowError( con );
  })

  .doThen( () =>
  {
    let con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
      allowMissing : 0
    });
    return test.shouldThrowError( con );
  })

  .doThen( () =>
  {
    let con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 0,
      sync : 0,
      allowMissing : 0
    });
    return test.mustNotThrowError( con );
  })

  .doThen( () =>
  {
    let con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
      allowMissing : 0
    });
    return test.mustNotThrowError( con );
  })

  .doThen( () => test.close( 'allowMissing' ) )

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkSoft
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  return consequence;
}

//

function linkSoftRelativePath( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkSoftAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/linkSoftRelativePath' );
  let pathToDir = test.context.makePath( 'written/linkSoftRelativePath/dir' );
  let pathToFile = test.context.makePath( 'written/linkSoftRelativePath/file' );

  test.open( 'src - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './.././a/b/c';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.././a/b/c';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.\\..\\.\\a\\b\\c';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\.\\a\\b\\c';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../a/b/c/../..';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../a/b/c/../..';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.\\..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  test.shouldThrowError( () => self.provider.linkSoft( dstPath, srcPath ) );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  test.close( 'src - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.directoryMake( pathToDir );

  var srcPath = '../dir';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../dir';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../dir';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir/dstDirLink' );
  self.provider.filesDelete( _.path.dir( dstPath ) );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../dir';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir/dstDirLink' );
  self.provider.filesDelete( _.path.dir( dstPath ) );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../../dir';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a/dir' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/a/b/c/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../../dir';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a/dir' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/a/b/c/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  //

  var srcPath = './.././a/b/c';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.././a/b/c';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.\\..\\.\\a\\b\\c';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\.\\a\\b\\c';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );


  var srcPath = './../a/b/c/../..';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../a/b/c/../..';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );


  var srcPath = '.\\..\\a\\b\\c\\..\\..';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );


  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToDir2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.directoryMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  var got = self.provider.directoryRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/linkSoftRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath );
  test.shouldThrowError( () => self.provider.linkSoft( dstPath, srcPath ) );
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  test.close( 'src - relative path to a dir' );

  test.open( 'dst - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'dst - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.directoryMake( pathToDir );

  var srcPath = pathToDir;
  var dstPath = '../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.directoryRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.directoryRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.directoryRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.directoryRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../a/b/dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.directoryRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../a/b/dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  var got = self.provider.directoryRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  test.close( 'dst - relative path to a dir' );

  //

  test.open( 'allowMissing on, relative path to src' );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.linkSoft
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );

  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, srcPath );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.linkSoft
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 0,
    throwing : 0,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, srcPath );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.linkSoft
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 0,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, srcPath );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.directoryMakeForFile( dstPath );
  self.provider.linkSoft
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 0,
    throwing : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  else
  {
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );
  }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, srcPath );

  test.close( 'allowMissing on, relative path to src' );

  //

  test.open( 'allowMissing on, same path' );

  var srcPath = '../file';
  var dstPath = pathToFile;
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.linkSoft
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath, readLink : 1 });
  test.identical( got, srcPath );

  //

  var srcPath = pathToFile;
  var dstPath = '../file';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.linkSoft
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 1,
    allowMissing : 1
  });
  test.is( self.provider.fileIsSoftLink( dstPathResolved ) );
  test.shouldThrowError( () =>  self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 }) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPathResolved, readLink : 1 });
  test.identical( got, srcPath );

  test.close( 'allowMissing on, same path' );

  //

  test.open( 'allowMissing off, relative path to src' );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 1,
      allowMissing : 0
    });
  })
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.mustNotThrowError( () =>
  {
    self.provider.linkSoft
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 0,
      throwing : 0,
      allowMissing : 0
    });
  })
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.mustNotThrowError( () =>
  {
    self.provider.linkSoft
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 0,
      allowMissing : 0
    });
  })
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkSoftRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 0,
      throwing : 1,
      allowMissing : 0
    });
  })
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  test.close( 'allowMissing off, relative path to src' );

  test.open( 'allowMissing off, same path' );

  var srcPath = '../file';
  var dstPath = pathToFile;
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 1,
      allowMissing : 0
    });
  })
  test.is( !self.provider.fileIsSoftLink( dstPath ) );

  var srcPath = pathToFile;
  var dstPath = '../file';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  test.shouldThrowError( () =>
  {
    self.provider.linkSoft
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 1,
      allowMissing : 0
    });
  })
  test.is( !self.provider.fileIsSoftLink( dstPathResolved ) );

  test.close( 'allowMissing off, same path' );
}

//

function fileReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRead ) )
  {
    test.identical( 1,1 );
    return;
  }

  if( !test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( 1,1 );
    return;
  }

  var consequence = new _.Consequence().give();

  if( isBrowser )
  {
    test.identical( 1,1 );
    return;
  }

  function encode( src, encoding )
  {
    return Buffer.from( src ).toString( encoding );
  }

  function decode( src, encoding )
  {
    return Buffer.from( src, encoding ).toString( 'utf8' );
  }

  var src = 'Excepteur sint occaecat cupidatat non proident';

  self.testFile = test.context.makePath( 'written/fileReadAsync/file' );
  self.provider.fileWrite( self.testFile, src );

  consequence
  .ifNoErrorThen( function()
  {
    test.case ='read from file';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
    });
    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = src;
    // why slice ???
    // var got = data.slice( 0, expected.length );
    var got = data;
    test.identical( got, expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='read from file, encoding : ascii';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'ascii'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'ascii' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='read from file, encoding : utf16le';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'utf16le'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'utf16le' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='read from file, encoding : ucs2';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'ucs2'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = encode( src, 'ucs2' )
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='read from file, encoding : base64';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'base64'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = src;
    data = decode( data, 'base64' );
    var got = data.slice( 0, expected.length );
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='read from file, encoding : arraybuffer';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'buffer.raw'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = [ true, src ];
    var result  = Buffer.from( data ).toString().slice( 0, src.length );
    var got = [ _.bufferRawIs( data ), result ];
    test.identical( got , expected );
  })
  .ifNoErrorThen( function()
  {
    test.case ='read from file, encoding : buffer';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'buffer.node'
    });

    return test.shouldMessageOnlyOnce( con );
  })
  .ifNoErrorThen( function( data )
  {
    var expected = [ true, src ];
    var result  = Buffer.from( data ).toString().slice( 0, src.length );
    var got = [ _.bufferNodeIs( data ), result ];
    test.identical( got , expected );
  })

  return consequence;
}

//

/*

/port/package/wMathSpace/node_modules/wmathspace -> /port/package/wMathSpace/
/port/package/wMathSpace/builder -> /repo/git/trunk/builder
/port/package/wMathSpace/node_modules/wmathspace/builder -> /repo/git/trunk/builder

/a/b -> ..
/a/c -> /x
/a/b/c -> /x
*/

function linkSoftChain( test )
{
  var self = this;

  if( !test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( 1,1 );
    return
  }

  var provider = self.provider;
  var path = provider.path;
  // var dir = path.dirTempOpen();
  var dir = test.context.makePath( 'written/linkSoftChain' );
  // var dir = path.dirTempOpen( path.join( __dirname, 'linkSoftChain' ) ); // xxx

  debugger;

  self.provider.directoryMake( path.join( dir, 'a' ) );
  self.provider.fileWrite( path.join( dir, 'x' ), 'x' );
  self.provider.linkSoft( path.join( dir, 'a/b' ), '..' );
  self.provider.linkSoft( path.join( dir, 'a/c' ), '../../x' );

  test.description = 'resolve path';

  var expected = path.join( dir, 'a' );
  var got = provider.pathResolveLink( path.join( dir, 'a/b' ) );
  test.identical( got, expected );

  var expected = path.join( dir, 'x' );
  var got = provider.pathResolveLink( path.join( dir, 'a/c' ) );
  test.identical( got, expected );

  var expected = path.join( dir, 'x' );
  var got = provider.pathResolveLink( path.join( dir, 'a/b/c' ) );
  test.identical( got, expected );

  test.description = 'get stat';

  var abStat = provider.fileStat({ filePath : path.join( dir, 'a/b' ), resolvingSoftLink : 1 });
  var acStat = provider.fileStat({ filePath : path.join( dir, 'a/c' ), resolvingSoftLink : 1 });
  var abcStat = provider.fileStat({ filePath : path.join( dir, 'a/b/c' ), resolvingSoftLink : 1 });

  test.is( !!abStat );
  test.is( !!acStat );
  test.is( !!abcStat );

  debugger;
}

//

function linkHardSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.case = 'linkHardAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  function linkGroups( paths, groups )
  {
    groups.forEach( ( g ) =>
    {
      var filePathes = g.map( ( i ) => paths[ i ] );
      self.provider.linkHard({ dstPath : filePathes });
    })
  }

  var delay = 0.01;

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  delay = self.provider.systemBitrateTimeGet() / 1000;

  function makeFiles( names, dirPath, sameTime )
  {
    var paths = names.map( ( name, i ) =>
    {
      var filePath = self.makePath( _.path.join( dirPath, name ) );
      self.provider.fileWrite({ filePath : filePath, data : filePath, purging : 1 });

      if( sameTime )
      {
        var time = delay * 1000;
        self.provider.fileTimeSet( filePath, time, time );
      }
      else if( i > 0 )
      {
        waitSync( delay );
        self.provider.fileWrite({ filePath : filePath, data : _.path.name( filePath ) });
      }

      return filePath;
    });

    return paths;
  }

  function makeHardLinksToPath( filePath, amount )
  {
    _.assert( _.strHas( filePath, 'tmp.tmp' ) );
    var dir = _.path.dirTempOpen( _.path.dir( filePath ), _.path.name( filePath ) );
    for( var i = 0; i < amount; i++ )
    self.provider.linkHard( _.path.join( dir, 'file' + i ), filePath );
  }

  function filesHaveSameTime( paths )
  {
    _.assert( paths.length > 1 );
    var srcStat = self.provider.fileStat( paths[ 0 ] );

    for( var i = 1; i < paths.length; i++ )
    {
      var stat = self.provider.fileStat( paths[ i ] );
      if( srcStat.atime.getTime() !== stat.atime.getTime() )
      {
        logger.log( srcStat.atime.getTime(), stat.atime.getTime() );
        return false;
      }

      if( srcStat.mtime.getTime() !== stat.mtime.getTime() )
      {
        logger.log( srcStat.mtime.getTime(), stat.mtime.getTime() )
        return false;
      }
    }

    return true;
  }

  var dir = test.context.makePath( 'written/linkHard' );
  self.provider.filesDelete( dir )
  var srcPath,dstPath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'make link async';
  srcPath  = test.context.makePath( 'written/linkHard/link_test.txt' );
  dstPath = test.context.makePath( 'written/linkHard/link.txt' );
  self.provider.fileWrite( srcPath, '000' );

  /**/

  self.provider.linkHard
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
  });
  self.provider.fileWrite
  ({
    filePath : srcPath,
    sync : 1,
    data : 'new text',
    writeMode : 'append'
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )
  var got = self.provider.fileRead( dstPath );
  var expected = '000new text';
  test.identical( got, expected );

  //

  test.case = 'make for file that not exist';
  self.provider.filesDelete( dir );
  srcPath  = test.context.makePath( 'written/linkHard/no_file.txt' );
  dstPath = test.context.makePath( 'written/linkHard/link2.txt' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  })

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.directoryRead( dir );
  test.identical( files, null );

  //

  test.case = 'link already exists';
  srcPath = test.context.makePath( 'written/linkHard/link_test.txt' );
  dstPath = test.context.makePath( 'written/linkHard/link.txt' );
  self.provider.fileWrite( srcPath, 'abc' );
  self.provider.linkHard
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  // test.shouldThrowErrorSync( function( )
  // {
  //   self.provider.linkHard
  //   ({
  //     srcPath : srcPath,
  //     dstPath : dstPath,
  //     rewriting : 0,
  //     throwing : 1,
  //     sync : 1,
  //   });
  // });

  var got = self.provider.linkHard
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 0,
    throwing : 1,
    sync : 1,
  });
  test.identical( got, true );
  test.is( self.provider.filesAreHardLinked( srcPath, dstPath ) )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  });

  //

  test.case = 'src is equal to dst';
  self.provider.filesDelete( dir );
  srcPath = test.context.makePath( 'written/linkHard/link_test.txt' );
  self.provider.fileWrite( srcPath, ' ' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  //

  test.case = 'try make hardlink for folder';
  self.provider.filesDelete( dir );
  srcPath = test.context.makePath( 'written/linkHard/link_test' );
  dstPath = test.context.makePath( 'written/linkHard/link' );
  self.provider.directoryMake( srcPath );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  })

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
    });
  })

  //

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    // next section needs time stats from Extract.fileStat, not implemented yet
    return;
  }

  //

  var fileNames = [ 'a1', 'a2', 'a3' ];
  var currentTestDir = 'written/linkHard/';
  var data = ' ';

  /**/

  test.case = 'dstPath option, files are not linked';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths )
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.case = 'dstPath option, linking files from different directories';
  paths = fileNames.map( ( n ) => _.path.join( 'dir_'+ n, n ) );
  paths = makeFiles( paths, currentTestDir );
  paths = _.path.pathsNormalize( paths )

  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.case = 'dstPath option, try to link already linked files';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  // try to link again
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.case = 'dstPath, rewriting off, try to rewrite existing files';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  test.shouldThrowError( () =>
  {
    self.provider.linkHard
    ({
      sync : 1,
      dstPath : paths,
      rewriting : 0,
      throwing : 1
    })
  });
  var got = self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, false );

  //

  test.case = 'dstPath option, groups of linked files ';
  var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );

  /**/

  var groups = [ [ 0,1 ],[ 2,3,4 ],[ 5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  var groups = [ [ 0,1 ],[ 1,2,3 ],[ 3,4,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  var groups = [ [ 0,1,2,3 ],[ 4,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  var groups = [ [ 0,1,2,3,4 ],[ 0,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.case = 'dstPath option, only first path exists';
  var fileNames = [ 'a1', 'a2', 'a3' ];
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  makeFiles( fileNames.slice( 0, 1 ), currentTestDir );
  var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
  paths = _.path.pathsNormalize( paths );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.is( self.provider.filesAreHardLinked( paths ) );
  self.provider.fileWrite( paths[ paths.length - 1 ], fileNames[ fileNames.length - 1 ] );
  test.identical( self.provider.fileRead( paths[ 0 ] ), self.provider.fileRead( paths[ paths.length - 1 ] ) );

  /**/

  test.case = 'dstPath option, all paths not exist';
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
  paths = _.path.pathsNormalize( paths );
  test.shouldThrowError( () =>
  {
    self.provider.linkHard
    ({
      sync : 1,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
  });

  /* repair */

  /* test.case = 'dstPath option, same date but different content';
  var paths = makeFiles( fileNames, currentTestDir, true );
  paths = _.path.pathsNormalize( paths );
  self.provider.linkHard({ dstPath : paths });
  var stat = self.provider.fileStat( paths[ 0 ] );
  waitSync( delay );
  self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
  self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
  var files = self.provider.fileRecords( paths );
  files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
  files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
  test.shouldThrowError( () =>
  {
    self.provider.linkHard({ dstPath : files, allowDiffContent : 0 });
  });
  test.is( !self.provider.filesAreHardLinked( paths ) ); */

  /* repair */

  /* test.case = 'dstPath option, same date but different content, allowDiffContent';
  var paths = makeFiles( fileNames, currentTestDir, true );
  paths = _.path.pathsNormalize( paths );
  self.provider.linkHard({ dstPath : paths });
  var stat = self.provider.fileStat( paths[ 0 ] );
  waitSync( delay );
  self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
  self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
  var files = self.provider.fileRecords( paths );
  files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
  files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
  self.provider.linkHard({ dstPath : files, allowDiffContent : 1 });
  test.is( self.provider.filesAreHardLinked( paths ) ); */

  /**/

  test.case = 'using srcPath as source for files from dstPath';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = _.path.pathsNormalize( paths );
  var srcPath = paths.pop();
  self.provider.linkHard({ srcPath : srcPath, dstPath : paths });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst )

  /* sourceMode */

  test.case = 'sourceMode: src - newest file with minimal amount of links';
  var paths = makeFiles( fileNames, currentTestDir);
  test.is( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); // #1 most linked file
  makeHardLinksToPath( paths[ 1 ], 2 ); // #2 most linked file
  paths = _.path.pathsNormalize( paths );
  var records = self.provider.fileRecords( paths );
  // logger.log( _.entitySelect( records, '*.relative' ) )
  // logger.log( _.entitySelect( records, '*.stat.mtime' ).map( ( t ) => t.getTime() ) )
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified>hardlinks<' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks<'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 2 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ 1 ] );
  test.identical( src, dst );

  //

  test.case = 'sourceMode: src - newest file with maximal amount of links';
  var paths = makeFiles( fileNames, currentTestDir );
  test.is( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); // #1 most linked file
  makeHardLinksToPath( paths[ paths.length - 1 ], 4 ); // #2 most linked+newest file
  paths = _.path.pathsNormalize( paths );
  var records = self.provider.fileRecords( paths );
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified>hardlinks>' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks>'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ paths.length - 1 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ 0 ] );
  test.identical( src, dst );

  //

  test.case = 'sourceMode: src - oldest file with maximal amount of links';
  var paths = makeFiles( fileNames, currentTestDir );
  test.is( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); // #1 most linked+oldest file
  makeHardLinksToPath( paths[ paths.length - 1 ], 4 ); // #2 most linked+newest file
  paths = _.path.pathsNormalize( paths );
  var records = self.provider.fileRecords( paths );
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified<hardlinks>' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks>'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst );

  //

  test.case = 'sourceMode: src - oldest file with maximal amount of links';
  var paths = makeFiles( fileNames, currentTestDir );
  test.is( paths.length >= 3 );
  paths = _.path.pathsNormalize( paths );
  var records = self.provider.fileRecords( paths );
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified<hardlinks<' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks<'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst );

  //

  test.case = 'sourceMode: src - same time, max amount of links';
  var paths = makeFiles( fileNames, currentTestDir, true );
  test.is( filesHaveSameTime( paths ) );
  test.is( paths.length >= 3 );
  paths = _.path.pathsNormalize( paths );
  makeHardLinksToPath( paths[ 0 ], 2 );
  makeHardLinksToPath( paths[ 1 ], 3 );
  makeHardLinksToPath( paths[ 2 ], 5 );
  test.is( filesHaveSameTime( paths ) );
  var records = self.provider.fileRecords( paths );
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified>hardlinks>' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks>'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 2 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ 0 ] );
  test.identical( src, dst );

  //

  test.case = 'sourceMode: src - same time, min amount of links';
  var paths = makeFiles( fileNames, currentTestDir, true );
  test.is( filesHaveSameTime( paths ) );
  test.is( paths.length >= 3 );
  paths = _.path.pathsNormalize( paths );
  makeHardLinksToPath( paths[ 0 ], 2 );
  makeHardLinksToPath( paths[ 1 ], 3 );
  makeHardLinksToPath( paths[ 2 ], 5 );
  test.is( filesHaveSameTime( paths ) );
  var records = self.provider.fileRecords( paths );
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified>hardlinks<' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks<'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ 2 ] );
  var ok = test.identical( src, dst );
}

linkHardSync.timeOut = 60000;

//

function linkHardRelativePath( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/linkHardRelativePath' );
  let pathToDir = test.context.makePath( 'written/linkHardRelativePath/dir' );
  let pathToFile = test.context.makePath( 'written/linkHardRelativePath/file' );

  test.open( 'src - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = './../file';
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = '../../file';
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/linkHardRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile2, dstPath ] ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/linkHardRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.directoryMakeForFile( dstPath )
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile2, dstPath ] ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );

  test.close( 'src - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.directoryMake( pathToDir );

  var srcPath = '../dir';
  var dstPath = test.context.makePath( 'written/linkHardRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () => self.provider.linkHard( dstPath, srcPath ) )
  test.is( !self.provider.filesAreHardLinked( [ pathToDir, dstPath ] ) );

  test.close( 'src - relative path to a dir' );

  test.open( 'dst - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );


  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.directoryMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.linkHard( dstPath, srcPath );
  test.is( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'dst - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.directoryMake( pathToDir );

  var srcPath = pathToDir;
  var dstPath = '../dstDir';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  test.shouldThrowError( () => self.provider.linkHard( dstPath, srcPath ) )
  test.is( !self.provider.filesAreHardLinked( [ pathToDir, dstPathResolved ] ) );

  test.close( 'dst - relative path to a dir' );

  test.open( 'same paths' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = pathToFile;
  var statBefore = self.provider.fileStat( pathToFile );
  var got = self.provider.linkHard( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.fileStat( pathToFile );
  test.identical( statBefore.nlink, statNow.nlink );

  var srcPath = pathToFile;
  var dstPath = '../file';
  var statBefore = self.provider.fileStat( pathToFile );
  var got = self.provider.linkHard( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.fileStat( pathToFile );
  test.identical( statBefore.nlink, statNow.nlink );

  test.close( 'same paths' );

}

//

function linkHardExperiment( test )
{
  var self = this;

  var delay = 0.01;

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  delay = self.provider.systemBitrateTimeGet() / 1000;

  function makeFiles( names, dirPath, sameTime )
  {
    var paths = names.map( ( name, i ) =>
    {
      var filePath = self.makePath( _.path.join( dirPath, name ) );
      self.provider.fileWrite({ filePath : filePath, data : filePath, purging : 1 });

      if( sameTime )
      {
        var time = delay * 1000;
        self.provider.fileTimeSet( filePath, time, time );
      }
      else if( i > 0 )
      {
        waitSync( delay );
        self.provider.fileWrite({ filePath : filePath, data : _.path.name( filePath ) });
      }

      return filePath;
    });

    return paths;
  }

  function makeHardLinksToPath( filePath, amount )
  {
    _.assert( _.strHas( filePath, 'tmp.tmp' ) );
    var dir = _.path.dirTempOpen( _.path.dir( filePath ), _.path.name( filePath ) );
    for( var i = 0; i < amount; i++ )
    self.provider.linkHard( _.path.join( dir, 'file' + i ), filePath );
  }


  var dir = test.context.makePath( 'written/linkHard' );
  var srcPath,dstPath;

  var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
  test.case = 'sourceMode: src - oldest file with maximal amount of links';
  var paths = makeFiles( fileNames, dir );
  test.is( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); // #1 most linked+oldest file
  makeHardLinksToPath( paths[ paths.length - 1 ], 4 ); // #2 most linked+newest file
  paths = _.path.pathsNormalize( paths );
  var records = self.provider.fileRecords( paths );
  logger.log( _.entitySelect( records, '*.name' ) )
  logger.log( 'nlink: ', _.entitySelect( records, '*.stat.nlink' ) )
  logger.log( 'atime: ', _.entitySelect( records, '*.stat.atime' ).map( ( r ) => r.getTime() ) )
  logger.log( 'mtime: ', _.entitySelect( records, '*.stat.mtime' ).map( ( r ) => r.getTime() ) )
  logger.log( 'ctime: ', _.entitySelect( records, '*.stat.ctime' ).map( ( r ) => r.getTime() ) )
  logger.log( 'birthtime: ', _.entitySelect( records, '*.stat.birthtime' ).map( ( r ) => r.getTime() ) )
  var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified<hardlinks>' });
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks>'
  });
  test.is( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  test.identical( selectedFile.stat.nlink, 4 );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst );
}

linkHardExperiment.timeOut = 30000;

//

function linkHardSoftlinked( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.case = 'linkHardAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  if( !test.context.symlinkIsAllowed() )
  {
    test.case = 'System does not allow to create soft links.';
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );

  test.case = 'files are already linked, must not throw an error'
  var dir = mp( 'linkHardActSync/dir' );
  var fileInDir = mp( 'linkHardActSync/dir/src' );
  var linkToDir = mp( 'linkHardActSync/linkToDir' );
  var fileInLinkedDir = mp( 'linkHardActSync/linkToDir/src' );
  self.provider.fileWrite( fileInDir, fileInDir );
  var fileStatBefore = self.provider.fileStat( fileInDir );
  self.provider.linkSoft( linkToDir, dir );
  var got = self.provider.linkHard( fileInLinkedDir, fileInDir );
  test.identical( got, true );
  var fileStatAfter = self.provider.fileStat( fileInDir );
  test.is( !!fileStatAfter );
  if( fileStatAfter )
  {
    if( !self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
    return;

    test.identical( fileStatBefore.atime.getTime(), fileStatAfter.atime.getTime() );
    test.identical( fileStatBefore.ctime.getTime(), fileStatAfter.ctime.getTime() );
    test.identical( fileStatBefore.mtime.getTime(), fileStatAfter.mtime.getTime() );
    test.identical( fileStatBefore.birthtime.getTime(), fileStatAfter.birthtime.getTime() );
  }

}

//

function linkHardActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.case = 'linkHardAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'linkHardActSync' );

  var symlinkIsAllowed = test.context.symlinkIsAllowed();

  //

  test.case = 'basic usage';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.linkHardAct( o );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'no src';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o );
  })
  test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  test.case = 'src is not a terminal';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.directoryMake( srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o );
  })
  test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.filesDelete( dir );

  //

  test.case = 'src is a terminal, check link';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  self.provider.linkHardAct( o );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  self.provider.filesDelete( dir );

  //

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.case = 'src is a hard link, check link';
    self.provider.filesDelete( dir );
    var filePath = _.path.join( dir,'file' );
    var srcPath = _.path.join( dir,'src' );
    self.provider.fileWrite( filePath, filePath );
    self.provider.linkHard({ srcPath : filePath, dstPath : srcPath, sync : 1 });
    test.is( self.provider.filesAreHardLinked( [ srcPath, filePath ] ) );
    var dstPath = _.path.join( dir,'dst' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 1
    }
    self.provider.linkHardAct( o );
    test.is( self.provider.filesAreHardLinked( [ filePath, srcPath, dstPath ] ) );
    self.provider.fileWrite( dstPath, dstPath );
    var srcFile = self.provider.fileRead( srcPath );
    test.identical( srcFile, dstPath );
    var file = self.provider.fileRead( filePath );
    test.identical( srcFile, file );
    self.provider.filesDelete( dir );
  }

  //

  if( symlinkIsAllowed )
  {
    test.case = 'src is a soft link, check link';
    self.provider.filesDelete( dir );
    var filePath = _.path.join( dir,'file' );
    var srcPath = _.path.join( dir,'src' );
    self.provider.fileWrite( filePath, filePath );
    self.provider.linkSoft({ srcPath : filePath, dstPath : srcPath, sync : 1 });
    var dstPath = _.path.join( dir,'dst' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 1
    }
    self.provider.linkHardAct( o );
    test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
    self.provider.fileWrite( dstPath, dstPath );
    var srcFile = self.provider.fileRead( srcPath );
    test.identical( srcFile, dstPath );
    var file = self.provider.fileRead( filePath );
    test.identical( srcFile, file );
  }


  //

  test.case = 'dst is a terminal';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o )
  });
  test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );
  self.provider.filesDelete( dir );

  //

  test.case = 'dst is a hard link';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.linkHard( dstPath, srcPath );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o )
  });
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, srcPath );
  self.provider.filesDelete( dir );

  //

  if( symlinkIsAllowed )
  {
    test.case = 'dst is a soft link';
    self.provider.filesDelete( dir );
    var srcPath = _.path.join( dir,'src' );
    var dstPath = _.path.join( dir,'dst' );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.linkSoft( dstPath, srcPath );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 1
    }
    test.shouldThrowError( () =>
    {
      self.provider.linkHardAct( o )
    });
    test.is( self.provider.fileIsSoftLink( dstPath ) );
    var dstFile = self.provider.fileRead( dstPath );
    test.identical( dstFile, srcPath );
    self.provider.filesDelete( dir );
  }

  //

  test.case = 'dst is dir';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  var filePath = _.path.join( dstPath, 'file' )
  var filePath2 = _.path.join( dstPath, 'file2' )
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( filePath2, filePath2 );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o )
  });
  var files = self.provider.directoryRead( dstPath );
  var expected = [ 'file', 'file2' ];
  test.identical( files, expected );
  var file1 = self.provider.fileRead( filePath );
  var file2 = self.provider.fileRead( filePath2 );
  test.identical( file1, filePath );
  test.identical( file2, filePath2 );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not create folders structure for path';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir,'parent/dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o );
  })
  test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.filesDelete( dir );

  //

  test.case = 'should path nativize all paths in options map if needed by its own means';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }

  var expected = _.mapExtend( null, o );
  expected.srcPath = self.provider.path.nativize( o.srcPath );
  expected.dstPath = self.provider.path.nativize( o.dstPath );

  self.provider.linkHardAct( o );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.linkHardAct( o );
  test.is( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.case = 'should assert that path is absolute';
  var srcPath = './src';
  var dstPath = _.path.join( dir,'dst' );

  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 1
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.path.join( dir,'src' );;
  var dstPath = _.path.join( dir,'dst' );

  /* sync option is missed */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o );
  });

  /* redundant option */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o );
  });

  //

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.case = 'should expect normalized path, but not nativized';
    var srcPath = _.path.join( dir,'src' );
    self.provider.fileWrite( srcPath, srcPath );
    var dstPath = _.path.join( dir,'dst' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 1
    }
    var originalPath = o.srcPath;
    o.srcPath = self.provider.path.nativize( o.srcPath );
    o.dstPath = self.provider.path.nativize( o.dstPath );
    if( o.srcPath !== originalPath )
    {
      test.shouldThrowError( () =>
      {
        self.provider.linkHardAct( o );
      })
    }
    else
    {
      test.mustNotThrowError( () =>
      {
        self.provider.linkHardAct( o );
      })
    }

    self.provider.filesDelete( dir );
  }

  //

  test.case = 'should expect ready options map, no complex arguments preprocessing';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : [ srcPath ],
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingSrcHardLink : 0,
    breakingDstHardLink : 1,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.linkHardAct( o );
  })
  test.identical( o.srcPath, expected.srcPath );
}

//

function linkHardAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.case = 'linkHardAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  function linkGroups( paths, groups )
  {
    groups.forEach( ( g ) =>
    {
      var filePathes = g.map( ( i ) => paths[ i ] );
      self.provider.linkHard({ dstPath : filePathes });
    })
  }

  var delay = 0.01;

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  delay = self.provider.systemBitrateTimeGet() / 1000;

  function makeFiles( names, dirPath, sameTime )
  {
    var paths = names.map( ( name, i ) =>
    {
      var filePath = self.makePath( _.path.join( dirPath, name ) );
      self.provider.fileWrite({ filePath : filePath, data : filePath, purging : 1 });

      if( sameTime )
      {
        var time = delay * 1000;
        self.provider.fileTimeSet( filePath, time, time );
      }
      else if( i > 0 )
      {
        waitSync( delay );
        self.provider.fileWrite({ filePath : filePath, data : _.path.name( filePath ) });
      }

      return filePath;
    });

    return paths;
  }

  function makeHardLinksToPath( filePath, amount )
  {
    _.assert( _.strHas( filePath, 'tmp.tmp' ) );
    var dir = _.path.dirTempOpen( _.path.dir( filePath ), _.path.name( filePath ) );
    for( var i = 0; i < amount; i++ )
    self.provider.linkHard( _.path.join( dir, 'file' + i ), filePath );
  }

  var dir = test.context.makePath( 'written/linkHardAsync' );
  self.provider.filesDelete( dir );
  var srcPath,dstPath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var fileNames = [ 'a1', 'a2', 'a3' ];
  var currentTestDir = 'written/linkHard/';
  var data = ' ';
  var paths;

  var consequence = new _.Consequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.case = 'make link async';
    srcPath  = test.context.makePath( 'written/linkHardAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/linkHardAsync/link.txt' );
    self.provider.fileWrite( srcPath, '000' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite
      ({
        filePath : srcPath,
        sync : 1,
        data : 'new text',
        writeMode : 'append'
      });
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      var got = self.provider.fileRead( dstPath );
      var expected = '000new text';
      test.identical( got, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'make for file that not exist';
    self.provider.filesDelete( dir );
    srcPath  = test.context.makePath( 'written/linkHardAsync/no_file.txt' );
    dstPath = test.context.makePath( 'written/linkHardAsync/link2.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, null );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'link already exists';
    srcPath = test.context.makePath( 'written/linkHardAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/linkHardAsync/link.txt' );
    self.provider.fileWrite( srcPath, 'abc' );
    self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    })
    .doThen( ( err, got ) =>
    {
      test.identical( got, true );
      test.is( self.provider.filesAreHardLinked( srcPath, dstPath ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/linkHardAsync/link_test.txt' );
    self.provider.fileWrite( srcPath, ' ' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'try make hardlink for folder';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/linkHardAsync/link_test' );
    dstPath = test.context.makePath( 'written/linkHardAsync/link' );
    self.provider.directoryMake( srcPath );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.linkHard
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con );
  });

  //

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    // next section needs time stats from Extract.fileStat, not implemented yet
    return consequence;
  }

  /**/

  consequence.ifNoErrorThen( function()
  {
    test.case = 'dstPath option, files are not linked';
    var paths = makeFiles( fileNames, currentTestDir );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, linking files from different directories';
    paths = fileNames.map( ( n ) => _.path.join( 'dir_'+ n, n ) );
    paths = makeFiles( paths, currentTestDir );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, try to link already linked files';
    var paths = makeFiles( fileNames, currentTestDir );
    self.provider.linkHard
    ({
      sync : 1,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    // try to link again
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.case = 'dstPath, rewriting off, try to rewrite existing files';
    var paths = makeFiles( fileNames, currentTestDir );
    var con = self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( () =>
    {
      var got = self.provider.linkHard
      ({
        sync : 1,
        dstPath : paths,
        rewriting : 0,
        throwing : 0
      });
      test.identical( got, false );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, groups of linked files ';
    fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1 ],[ 2,3,4 ],[ 5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1 ],[ 1,2,3 ],[ 3,4,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1,2,3 ],[ 4,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1,2,3,4 ],[ 0,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.is( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, only first path exists';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    makeFiles( fileNames.slice( 0, 1 ), currentTestDir );
    var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () =>
    {
      test.is( self.provider.filesAreHardLinked( paths ) );
      self.provider.fileWrite( paths[ paths.length - 1 ], fileNames[ fileNames.length - 1 ] );
      test.identical( self.provider.fileRead( paths[ 0 ] ), self.provider.fileRead( paths[ paths.length - 1 ] ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, all paths not exist';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
    debugger
    var con = self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    return test.shouldThrowError( con );
  })

  /* repair */

  /* .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, same date but different content';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = makeFiles( fileNames, currentTestDir, true );
    self.provider.linkHard({ dstPath : paths });
    var stat = self.provider.fileStat( paths[ 0 ] );
    waitSync( delay );
    self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
    self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
    var files = self.provider.fileRecords( paths );
    files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
    files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
    var con = self.provider.linkHard
    ({
      sync : 0,
      dstPath : files,
      rewriting : 1,
      throwing : 1,
      allowDiffContent : 0
    })
    return test.shouldThrowError( con )
    .doThen( () =>
    {
      test.is( !self.provider.filesAreHardLinked( paths ) );
    });
  })
 */
  /* repair */

  /* .ifNoErrorThen( function()
  {
    test.case = 'dstPath option, same date but different content, allow different files';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = _.path.pathsNormalize( makeFiles( fileNames, currentTestDir ) );
    self.provider.linkHard({ dstPath : paths });
    var stat = self.provider.fileStat( paths[ 0 ] );
    waitSync( delay );
    self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
    self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
    var files = self.provider.fileRecords( paths );
    files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
    files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : files,
      rewriting : 1,
      throwing : 1,
      allowDiffContent : 1
    })
    .doThen( () =>
    {
      test.is( self.provider.filesAreHardLinked( paths ) );
    });
  }) */

  /* sourceMode */

  .ifNoErrorThen( function()
  {
    test.case = 'sourceMode: source newest file with min hardlinks count ';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = makeFiles( fileNames, currentTestDir );
    test.is( paths.length >= 3 );
    makeHardLinksToPath( paths[ 1 ], 3 );
    paths = _.path.pathsNormalize( paths );
    var records = self.provider.fileRecords( paths );
    var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'modified>hardlinks<' });
    return self.provider.linkHard
    ({
      dstPath : paths,
      sourceMode : 'modified>hardlinks<',
      sync : 0
    })
    .ifNoErrorThen( () =>
    {
      test.is( self.provider.filesAreHardLinked( paths ) );
      var srcPath = paths[ paths.length - 1 ];
      test.identical( selectedFile.absolute, srcPath );
      var src = self.provider.fileRead( srcPath );
      var dst = self.provider.fileRead( paths[ 1 ] );
      test.identical( src, dst )
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'sourceMode: source must be a file with max amount of links';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    var paths = makeFiles( fileNames, currentTestDir );
    waitSync( delay );
    self.provider.fileWrite( paths[ 0 ], 'max links file' );
    test.is( paths.length >= 3 );
    makeHardLinksToPath( paths[ 0 ], 3 ); //3 links to a file
    makeHardLinksToPath( paths[ 1 ], 2 ); //2 links to a file
    paths = _.path.pathsNormalize( paths );
    var records = self.provider.fileRecords( paths );
    var selectedFile = self.provider._fileRecordsSort({ src : records, sorter : 'hardlinks>' });
    return self.provider.linkHard
    ({
      dstPath : paths,
      sync : 0,
      sourceMode : 'hardlinks>'
    })
    .ifNoErrorThen( () =>
    {
      test.is( self.provider.filesAreHardLinked( paths ) );
      var srcPath = paths[ 0 ];
      test.identical( selectedFile.absolute, srcPath );
      var dstPath = paths[ 1 ];
      var src = self.provider.fileRead( srcPath );
      var dst = self.provider.fileRead( dstPath );
      test.identical( src, 'max links file' );
      test.identical( dst, 'max links file' );
      var srcStat = self.provider.fileStat( srcPath );
      var dstStat = self.provider.fileStat( dstPath );
      test.identical( Number( srcStat.nlink ), 9 );
      test.identical( Number( dstStat.nlink ), 9 );
    })

  })

  return consequence;
}
linkHardAsync.timeOut = 60000;

//

function fileExchangeSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileExchange ) || !_.routineIs( self.provider.fileStatAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/fileExchange' );
  var srcPath,dstPath,src,dst,got;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.case = 'swap two files content';
  srcPath = test.context.makePath( 'written/fileExchange/src' );
  dstPath = test.context.makePath( 'written/fileExchange/dst' );


  /*default setting*/

  self.provider.fileWrite( srcPath, 'src' );
  self.provider.fileWrite( dstPath, 'dst' );
  self.provider.fileExchange( dstPath, srcPath );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst', 'src' ] );
  src = self.provider.fileRead( srcPath );
  dst = self.provider.fileRead( dstPath );
  test.identical( [ src, dst ], [ 'dst', 'src' ] )

  /**/

  self.provider.fileWrite( srcPath, 'src' );
  self.provider.fileWrite( dstPath, 'dst' );
  self.provider.fileExchange
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    throwing : 0
  });
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst', 'src' ] );
  src = self.provider.fileRead( srcPath );
  dst = self.provider.fileRead( dstPath );
  test.identical( [ src, dst ], [ 'dst', 'src' ] )

  //

  test.case = 'swap two dirs content';
  srcPath = test.context.makePath( 'written/fileExchange/src/src.txt' );
  dstPath = test.context.makePath( 'written/fileExchange/dst/dst.txt' );

  /*throwing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  self.provider.fileWrite( dstPath, 'dst' );
  self.provider.fileExchange
  ({
    srcPath : _.path.dir( srcPath ),
    dstPath : _.path.dir( dstPath ),
    sync : 1,
    throwing : 1
  });
  src = self.provider.directoryRead( _.path.dir( srcPath ) );
  dst = self.provider.directoryRead( _.path.dir( dstPath ) );
  test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
  src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
  dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
  test.identical( [ src, dst ], [ 'dst', 'src' ] );

  /*throwing off*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  self.provider.fileWrite( dstPath, 'dst' );
  self.provider.fileExchange
  ({
    srcPath : _.path.dir( srcPath ),
    dstPath : _.path.dir( dstPath ),
    sync : 1,
    throwing : 1
  });
  src = self.provider.directoryRead( _.path.dir( srcPath ) );
  dst = self.provider.directoryRead( _.path.dir( dstPath ) );
  test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
  src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
  dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
  test.identical( [ src, dst ], [ 'dst', 'src' ] );

  //

  test.case = 'path not exist';
  srcPath = test.context.makePath( 'written/fileExchange/src' );
  dstPath = test.context.makePath( 'written/fileExchange/dst' );

  /*src not exist, throwing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, 'dst' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 0,
      throwing : 1
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /*src not exist, throwing on, allowMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, 'dst' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 1,
      throwing : 1
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /*src not exist, throwing off,allowMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, 'dst' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 1,
      throwing : 0
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /*dst not exist, throwing on,allowMissing off*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 0,
      throwing : 1
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /*dst not exist, throwing off,allowMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 1,
      throwing : 0
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /*dst not exist, throwing on,allowMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 1,
      throwing : 1
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'dst' ] );

  /*dst not exist, throwing off,allowMissing off*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 0,
      throwing : 0
    });
  });
  var files  = self.provider.directoryRead( dir );
  test.identical( files, [ 'src' ] );

  /*dst & src not exist, throwing on,allowMissing on*/

  self.provider.filesDelete( dir );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 1,
      throwing : 1
    });
  });
  test.identical( got, null );

  /*dst & src not exist, throwing off,allowMissing off*/

  // self.provider.filesDelete( dir );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 1,
      throwing : 0
    });
  });
  test.identical( got, null );

  /*dst & src not exist, throwing on,allowMissing off*/

  // self.provider.filesDelete( dir );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 0,
      throwing : 1
    });
  });

  /*dst & src not exist, throwing off,allowMissing off*/

  // self.provider.filesDelete( dir );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowMissing : 0,
      throwing : 0
    });
  });
  test.identical( got, null );

}

//

function fileExchangeAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileExchange ) || !_.routineIs( self.provider.fileStatAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/fileExchangeAsync' );
  var srcPath,dstPath,src,dst,got;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  consequence

  //

  .ifNoErrorThen( function()
  {
    test.case = 'swap two files content';
    srcPath = test.context.makePath( 'written/fileExchangeAsync/src' );
    dstPath = test.context.makePath( 'written/fileExchangeAsync/dst' );
  })

  /*default setting*/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst', 'src' ] );
      src = self.provider.fileRead( srcPath );
      dst = self.provider.fileRead( dstPath );
      test.identical( [ src, dst ], [ 'dst', 'src' ] )
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function()
    {
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst', 'src' ] );
      src = self.provider.fileRead( srcPath );
      dst = self.provider.fileRead( dstPath );
      test.identical( [ src, dst ], [ 'dst', 'src' ] )
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'swap two dirs content';
    srcPath = test.context.makePath( 'written/fileExchangeAsync/src/src.txt' );
    dstPath = test.context.makePath( 'written/fileExchangeAsync/dst/dst.txt' );
  })

  /*throwing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : _.path.dir( srcPath ),
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      allowMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function()
    {
      src = self.provider.directoryRead( _.path.dir( srcPath ) );
      dst = self.provider.directoryRead( _.path.dir( dstPath ) );
      test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
      src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
      dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
      test.identical( [ src, dst ], [ 'dst', 'src' ] );
    });
  })

  /*throwing off*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : _.path.dir( srcPath ),
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      allowMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function()
    {
      src = self.provider.directoryRead( _.path.dir( srcPath ) );
      dst = self.provider.directoryRead( _.path.dir( dstPath ) );
      test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
      src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
      dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
      test.identical( [ src, dst ], [ 'dst', 'src' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.case = 'path not exist';
    srcPath = test.context.makePath( 'written/fileExchangeAsync/src' );
    dstPath = test.context.makePath( 'written/fileExchangeAsync/dst' );
  })

  /*src not exist, throwing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( dstPath, 'dst' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /*src not exist, throwing on, allowMissing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( dstPath, 'dst' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /*src not exist, throwing off,allowMissing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( dstPath, 'dst' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /*dst not exist, throwing on,allowMissing off*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /*dst not exist, throwing off,allowMissing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /*dst not exist, throwing on,allowMissing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'dst' ] );
    });
  })

  /*dst not exist, throwing off,allowMissing off*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function()
    {
      var files  = self.provider.directoryRead( dir );
      test.identical( files, [ 'src' ] );
    });
  })

  /*dst & src not exist, throwing on,allowMissing on*/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, null );
    });
  })

  /*dst & src not exist, throwing off,allowMissing off*/

  .ifNoErrorThen( function()
  {
    // self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, null );
    });
  })

  /*dst & src not exist, throwing on,allowMissing off*/

  .ifNoErrorThen( function()
  {
    // self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );
  })

  /*dst & src not exist, throwing off,allowMissing off*/

  .doThen( function()
  {
    // self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowMissing : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, null );
    })
  })

  return consequence;
}

//

function nativize( t )
{
  var self = this;

  if( !_.routineIs( self.provider.path.nativize ) )
  return;

  if( !( self.provider instanceof _.FileProvider.HardDrive ) )
  {
    t.description = 'nativize returns src'
    t.identical( 1, 1 )
    return;
  }

  if( !isBrowser && process.platform === 'win32' )
  {
    t.description = 'path in win32 style ';

    /**/

    debugger
    var path = '/A/abc/';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\abc\\';
    t.identical( got, expected );

    /**/

    var path = '/A/';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\';
    t.identical( got, expected );

    /**/

    var path = '/A';
    var got = self.provider.path.nativize( path );
    // var expected = 'A:\\';
    var expected = 'A:';
    t.identical( got, expected );

    /**/

    var path = '/A/a';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\a';
    t.identical( got, expected );

    /**/

    var path = 'A:/a';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\a';
    t.identical( got, expected );

    /**/

    var path = '\\A\\a';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\a';
    t.identical( got, expected );

    /**/

    var path = 'A';
    var got = self.provider.path.nativize( path );
    var expected = 'A';
    t.identical( got, expected );

    /**/

    var path = '/c/a';
    var got = self.provider.path.nativize( path );
    var expected = 'c:\\a';
    t.identical( got, expected );

    /**/

    var path = '/A/1.txt';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\1.txt';
    t.identical( got, expected );

    /**/

    var path = 'A:/a\\b/c\\d';
    var got = self.provider.path.nativize( path );
    var expected = 'A:\\a\\b\\c\\d';
    t.identical( got, expected );
  }

  //

  if( Config.debug )
  {
    t.description = 'path is not a string ';
    t.shouldThrowErrorSync( function()
    {
      self.provider.path.nativize( 1 );
    })
  }
}

//

function experiment( test )
{
  var self = this;

  test.identical( 1,1 );
}

//

function linkHardSyncRunner( test )
{
  var self = this;

  var suite = test.suite;
  var tests = suite.tests;

  var runsLimit = 50;

  for( var i = 0; i < runsLimit; i++ )
  {
    tests.linkHardSync.call( self, test );
    // if( test.report.testCheckFails > 0 )
    // break;
  }
}

//

function linkHardAsyncRunner( test )
{
  var self = this;

  var suite = test.suite;
  var tests = suite.tests;

  var runsLimit = 50;

  var con = _.Consequence().give();

  for( var i = 0; i < runsLimit; i++ )(function()
  {
    con.ifNoErrorThen( () =>
    {
      return tests.linkHardAsync.call( self, test )
      .doThen( ( err, got ) =>
      {
        // if( test.report.testCheckFails > 0 )
        // return _.Consequence().error( 'Execution stopped after first failed test run.' );
      })
    })
  })();

  con.ifNoErrorThen( ( err ) => _.errLog( err ) );

  return con;
}

linkHardAsyncRunner.timeOut = 60000 * 50;

//

function directoryIs( test )
{
  var self = this;

  var filePath = test.context.makePath( 'written/directoryIs' );
  self.provider.filesDelete( filePath );

  //

  test.case = 'non existing path'
  test.identical( self.provider.directoryIs( filePath ), false );

  //

  test.case = 'file'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, '' );
  test.identical( self.provider.directoryIs( filePath ), false );

  //

  test.case = 'directory with file'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( _.path.join( filePath, 'a' ), '' );
  test.identical( self.provider.directoryIs( filePath ), true );

  //

  test.case = 'path with dot';
  self.provider.filesDelete( filePath );
  var path = test.context.makePath( 'written/.directoryIs' );
  self.provider.directoryMake( path )
  test.identical( self.provider.directoryIs( path ), true );

  //

  test.case = 'empty directory'
  self.provider.filesDelete( filePath );
  self.provider.directoryMake( filePath );
  test.identical( self.provider.directoryIs( filePath ), true );

  //

  test.case = 'softLink to file';
  self.provider.filesDelete( filePath );
  var src = filePath + '_';
  self.provider.fileWrite( src, '' );
  self.provider.linkSoft( filePath, src );
  test.identical( self.provider.directoryIs( filePath ), false );

  //

  test.case = 'softLink empty dir';
  self.provider.filesDelete( filePath );
  var src = filePath + '_';
  self.provider.directoryMake( src );
  self.provider.linkSoft( filePath, src );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  test.identical( self.provider.directoryIs( filePath ), false );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  test.identical( self.provider.directoryIs( filePath ), true );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

};

//

function directoryIsEmpty( test )
{
  var self = this;

  var filePath = test.context.makePath( 'written/directoryIsEmpty' );
  self.provider.filesDelete( filePath );

  //

  test.case = 'non existing path'
  test.identical( self.provider.directoryIsEmpty( filePath ), false );

  //

  test.case = 'file'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, '' );
  test.identical( self.provider.directoryIsEmpty( filePath ), false );

  //

  test.case = 'path with dot';
  self.provider.filesDelete( filePath );
  var path = test.context.makePath( 'written/.directoryIsEmpty' );
  self.provider.directoryMake( path )
  test.identical( self.provider.directoryIsEmpty( path ), true );

  //

  test.case = 'directory with file'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( _.path.join( filePath, 'a' ), '' );
  test.identical( self.provider.directoryIsEmpty( filePath ), false );

  //

  test.case = 'empty directory'
  self.provider.filesDelete( filePath );
  self.provider.directoryMake( filePath );
  test.identical( self.provider.directoryIsEmpty( filePath ), true );

  //

  test.case = 'softLink to file';
  self.provider.filesDelete( filePath );
  var src = filePath + '_';
  self.provider.fileWrite( src, '' );
  self.provider.linkSoft( filePath, src );
  test.identical( self.provider.directoryIsEmpty( filePath ), false );

  //

  test.case = 'softLink empty dir';
  self.provider.filesDelete( filePath );
  var src = filePath + '_';
  self.provider.directoryMake( src );
  self.provider.linkSoft( filePath, src );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  test.identical( self.provider.directoryIsEmpty( filePath ), false );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  debugger
  test.identical( self.provider.directoryIsEmpty( filePath ), true );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
};

//

function fileIsTerminal( test )
{
  var self = this;

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = 'directory';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( dir );
  var got = self.provider.fileIsTerminal( dir );
  test.identical( got, false );

  //

  var dir = test.context.makePath( 'written/.fileIsTerminal' );
  test.case = 'path with dot, dir';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( dir );
  var got = self.provider.fileIsTerminal( dir );
  test.identical( got, false );

  //

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = ' file';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dir, '' );
  var got = self.provider.fileIsTerminal( dir );
  test.identical( got, true );

  //

  var dir = test.context.makePath( 'written/.fileIsTerminal' );
  test.case = 'path with dot, file';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dir, '' );
  var got = self.provider.fileIsTerminal( dir );
  test.identical( got, true );

  //

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = 'symlink to dir';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( dir );
  var symlink = test.context.makePath( 'written/symlinkToDir' );
  self.provider.linkSoft( symlink, dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.fileIsTerminal( symlink );
  test.identical( got, false );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.fileIsTerminal( symlink );
  test.identical( got, false );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

  //

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = 'symlink to file';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dir, '' );
  var symlink = test.context.makePath( 'written/symlinkToFile' );
  self.provider.linkSoft( symlink, dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.fileIsTerminal( symlink );
  test.identical( got, false );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.fileIsTerminal( symlink );
  test.identical( got, false );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

};

//

function fileSymbolicLinkIs( test )
{
  var self = this;

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = 'directory';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( dir );
  var got = self.provider.fileIsSoftLink( dir );
  test.identical( got, false );

  //

  var dir = test.context.makePath( 'written/.fileIsTerminal' );
  test.case = 'path with dot, dir';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( dir );
  var got = self.provider.fileIsSoftLink( dir );
  test.identical( got, false );

  //

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = ' file';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dir, '' );
  var got = self.provider.fileIsSoftLink( dir );
  test.identical( got, false );

  //

  var dir = test.context.makePath( 'written/.fileIsTerminal' );
  test.case = 'path with dot, file';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dir, '' );
  var got = self.provider.fileIsSoftLink( dir );
  test.identical( got, false );

  //

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = 'symlink to dir';
  self.provider.filesDelete( dir );
  self.provider.directoryMake( dir );
  var symlink = test.context.makePath( 'written/symlinkToDir' );
  self.provider.linkSoft( symlink, dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.fileIsSoftLink( symlink );
  test.identical( got, true );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.fileIsSoftLink( symlink );
  test.identical( got, true );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

  //

  var dir = test.context.makePath( 'written/fileIsTerminal' );
  test.case = 'symlink to file';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dir, '' );
  var symlink = test.context.makePath( 'written/symlinkToFile' );
  self.provider.linkSoft( symlink, dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.fileIsSoftLink( symlink );
  test.identical( got, true );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.fileIsSoftLink( symlink );
  test.identical( got, true );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
};

//

function filesAreHardLinked( test )
{
  var self = this;

  var textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  if( test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    //!!!Look into cases with soft links, resolvingSoftLink is not implemented in Extract.filesAreHardLinkedAct
    test.identical( 1,1 );
    return;
  }

  if( isBrowser || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
  var bufferData = new ArrayBuffer( 4 );
  else
  var bufferData = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

  //

  test.case = 'same text file';
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  self.provider.fileWrite( filePath, textData );
  var got = self.provider.filesAreHardLinked( filePath, filePath );
  test.identical( got, true );

  //

  test.case = 'softlink to a file';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, textData );
  self.provider.linkSoft( linkPath, filePath );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreHardLinked( linkPath, filePath );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreHardLinked( linkPath, filePath );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, true );

  //

  test.case = 'different files with identical binary content';
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var filePath2 = test.context.makePath( 'written/filesAreHardLinked/file2' );
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  self.provider.fileWrite( filePath, bufferData );
  self.provider.fileWrite( filePath2, bufferData );
  var got = self.provider.filesAreHardLinked( filePath, filePath2 );
  test.identical( got, false );

  //

  test.case = 'symlink to file with  binary content';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, bufferData );
  self.provider.linkSoft( linkPath, filePath );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreHardLinked( linkPath, filePath );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreHardLinked( linkPath, filePath );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, true );

  //

  test.case = 'hardLink to file with  binary content';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, bufferData );
  self.provider.linkHard( linkPath, filePath );
  var got = self.provider.filesAreHardLinked( linkPath, filePath );
  test.identical( got, true );

  //

  test.case = 'hardlink to file with  text content : file record';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, textData );
  self.provider.linkHard( linkPath, filePath );
  var fileRecord = self.provider.fileRecord( filePath );
  var linkRecord = self.provider.fileRecord( linkPath );
  var got = self.provider.filesAreHardLinked( fileRecord, linkRecord );
  test.identical( got, true );

};

//

function filesAreSame( test )
{
  var self = this;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
  var textData2 = ' Aenean non feugiat mauris'
  var bufferData1;
  var bufferData2;

  if( isBrowser || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    bufferData1 = new ArrayBuffer( 4 );
    bufferData2 = new ArrayBuffer( 5 );
  }
  else
  {
    bufferData1 = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );
    bufferData2 =  Buffer.from( [ 0x07, 0x06, 0x05 ] );
  }


  //

  test.case = 'same file with empty content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  self.provider.fileWrite( filePath, '' );
  var got = self.provider.filesAreSame( filePath, filePath );
  if( self.provider.UsingBigIntForStat )
  test.identical( got, true );
  else
  test.identical( got, false );

  //

  test.case = 'two different files with empty content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, '' );
  self.provider.fileWrite( filePath2, '' );
  var got = self.provider.filesAreSame( filePath, filePath2 );
  test.identical( got, false );

  //

  test.case = 'files with identical binary content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, bufferData1 );
  self.provider.fileWrite( filePath2, bufferData1 );
  var got = self.provider.filesAreSame( filePath, filePath2 );
  test.identical( got, true );

  //

  test.case = 'files with non identical text content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.fileWrite( filePath2, textData2 );
  var got = self.provider.filesAreSame( filePath, filePath2 );
  test.identical( got, false );

  //

  test.case = 'files with non identical binart content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, bufferData1 );
  self.provider.fileWrite( filePath2, bufferData2 );
  var got = self.provider.filesAreSame( filePath, filePath2 );
  test.identical( got, false );

  //

  test.case = 'file and symlink to file';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.linkSoft( filePath2, filePath );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreSame( filePath, filePath2 );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreSame( filePath, filePath2 );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, true );

  //

  test.case = 'not existing path';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, bufferData1 );
  self.provider.filesDelete( filePath );
  test.shouldThrowError( () =>
  {
    self.provider.filesAreSame( filePath, filePath2 );
  })

  //

  test.case = 'two file records asociated with two regular files';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.fileWrite( filePath, textData1 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( filePath ), self.provider.fileRecord( filePath2 ) );
  test.identical( got, true );

  //

  test.case = 'two file records asociated with two regular files, same content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.fileWrite( filePath2, textData1 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( filePath ), self.provider.fileRecord( filePath2 ) );
  test.identical( got, true );

  //

  test.case = 'two file records asociated with two regular files, diff content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.filesDelete( filePath2 );
  self.provider.fileWrite( filePath2, textData2 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( filePath ), self.provider.fileRecord( filePath2 ) );
  test.identical( got, false );

  //

  test.case = 'two file records asociated with two symlinks, same content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.filesDelete( filePath2 );
  self.provider.fileWrite( filePath2, textData1 );
  var linkPath = test.context.makePath( 'written/filesAreSame/link1' );
  var linkPath2 = test.context.makePath( 'written/filesAreSame/link2' );
  self.provider.linkSoft( linkPath, filePath );
  self.provider.linkSoft( linkPath2, filePath2 );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( linkPath ), self.provider.fileRecord( linkPath2 ) );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( linkPath ), self.provider.fileRecord( linkPath2 ) );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, true );

  //

  test.case = 'two file records asociated with two symlinks, diff content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.filesDelete( filePath2 );
  self.provider.fileWrite( filePath2, textData2 );
  var linkPath = test.context.makePath( 'written/filesAreSame/link1' );
  var linkPath2 = test.context.makePath( 'written/filesAreSame/link2' );
  self.provider.linkSoft( linkPath, filePath );
  self.provider.linkSoft( linkPath2, filePath2 );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( linkPath ), self.provider.fileRecord( linkPath2 ) );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreSame( self.provider.fileRecord( linkPath ), self.provider.fileRecord( linkPath2 ) );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, false );

  //

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      self.prvoider.filesSame( );
    } );
  }

};

//

function filesSize( test )
{
  var self = this;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
  var textData2 = ' Aenean non feugiat mauris'
  var bufferData1;
  var bufferData2;

  if( isBrowser || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    bufferData1 = new ArrayBuffer( 4 );
    bufferData2 = new ArrayBuffer( 5 );
  }
  else
  {
    bufferData1 = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );
    bufferData2 =  Buffer.from( [ 0x07, 0x06, 0x05 ] );
  }

  var  testChecks =
  [
    {
      name : 'empty file',
      path : 'filesSize/filesSize/rtext1.txt',
      expected : 0,
      data : ''
    },
    {
      name : 'text file1',
      data : textData1,
      path : 'filesSize/filesSize/text2.txt',
      expected : textData1.length
    },
    {
      name : 'text file 2',
      data : textData2,
      path : 'filesSize/filesSize/text3.txt',
      expected : textData2.length
    },
    {
      name : 'file binary',
      data : bufferData1,
      path : 'filesSize/filesSize/data1',
      expected : bufferData1.byteLength
    },
    {
      name : 'binary file 2',
      data : bufferData2,
      path : 'filesSize/filesSize/data2',
      expected : bufferData2.byteLength
    },
  ];

  for( var testCheck of testChecks )
  {
    // join several test aspects together

    var path = test.context.makePath( testCheck.path );
    var got;

    test.case = testCheck.name;

    self.provider.fileWrite( path, testCheck.data );

    try
    {
      got = self.provider.filesSize( path );
    }
    catch( err ) {}

    let expected = testCheck.expected;
    if( _.bigIntIs( got ) )
    expected = BigInt( expected );
    test.identical( got, expected );
  }

  var paths = testChecks.map( c => test.context.makePath( c.path ) );
  var expected = testChecks.reduce( ( pc, cc ) => { return pc + cc.expected; }, 0 );

  test.case = 'all paths together';
  var got = self.provider.filesSize( paths );
  if( _.bigIntIs( got ) )
  expected = BigInt( expected );
  test.identical( got, expected );

  test.case = 'single path that exists';
  var path = testChecks[ testChecks.length - 1 ].path
  var got = self.provider.filesSize( test.context.makePath( path ) );
  var expected = testChecks[ testChecks.length - 1 ].expected;
  if( _.bigIntIs( got ) )
  expected = BigInt( expected );
  test.identical( got,expected )

  if( !Config.debug )
  return;

  test.case = 'single path that not exists';
  var path = test.context.makePath( 'filesSize/filesSize/notExistingPath' );
  test.shouldThrowError( () => self.provider.filesSize( path ) );

  test.case = 'not existing path in array';
  var path = test.context.makePath( 'filesSize/filesSize/notExistingPath' );
  var path2 = testChecks[ testChecks.length - 1 ].path;
  var paths = [ path2, path ];
  test.shouldThrowError( () => self.provider.filesSize( paths ) );

};

//

function fileSize( test )
{
  var self = this;

  var textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
  var  textData2 = ' Aenean non feugiat mauris'
  var bufferData1;
  var bufferData2;

  if( isBrowser || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    bufferData1 = new ArrayBuffer( 4 );
    bufferData2 = new ArrayBuffer( 5 );
  }
  else
  {
    bufferData1 = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );
    bufferData2 =  Buffer.from( [ 0x07, 0x06, 0x05 ] );
  }
  var  testChecks =
  [
    {
      name : 'empty file',
      path : 'tmp.tmp/fileSize/rtext1.txt',
      expected : 0,
      data : ''
    },
    {
      name : 'text file1',
      data : textData1,
      path : 'tmp.tmp/fileSize/text2.txt',
      expected : textData1.length
    },
    {
      name : 'text file 2',
      data : textData2,
      path : 'tmp.tmp/fileSize/text3.txt',
      expected : textData2.length
    },
    {
      name : 'file binary',
      data : bufferData1,
      path : 'tmp.tmp/fileSize/data1',
      expected : bufferData1.byteLength
    },
    {
      name : 'binary file 2',
      data : bufferData2,
      path : 'tmp.tmp/fileSize/data2',
      expected : bufferData2.byteLength
    },
  ];

  for( var testCheck of testChecks )
  {
    // join several test aspects together

    var path = test.context.makePath( testCheck.path )
    var got;

    test.case = testCheck.name;

    self.provider.fileWrite( path, testCheck.data );

    try
    {
      got = self.provider.fileSize( path );
    }
    catch( err ) {}

    let expected = testCheck.expected;
    if( _.bigIntIs( got ) )
    expected = BigInt( expected );
    test.identical( got, expected );
  }

  //

  if( Config.debug )
  return;

  test.case = 'missed arguments';
  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileSize( );
  });

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileSize( test.context.makePath( 'tmp.tmp/fileSize/data2' ), test.context.makePath( 'tmp.tmp/fileSize/data3' ) );
  });

  test.case = 'path is not string';
  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileSize( { filePath : null } );
  });

  test.case = 'passed unexpected property';
  test.shouldThrowErrorSync( function( )
  {
    self.provider.fileSize( { filePath : test.context.makePath( 'tmp.tmp/fileSize/data2' ), dir : test.context.makePath( 'tmp.tmp/fileSize/data3' ) } );
  });

};

//

function fileExists( test )
{
  let self = this;

  let testDirPath = test.context.makePath( 'written/fileExists' );
  let srcPath = test.context.makePath( 'written/fileExists/src' );
  let dstPath = test.context.makePath( 'written/fileExists/dst' );

  self.provider.filesDelete( testDirPath );

  test.case = 'not existing file';
  var got = self.provider.fileExists( srcPath );
  test.identical( got, false );

  test.case = 'regular file';
  self.provider.fileWrite( srcPath, srcPath );
  var got = self.provider.fileExists( srcPath );
  test.identical( got, true );

  test.case = 'directory';
  self.provider.directoryMakeForFile( srcPath );
  var got = self.provider.fileExists( testDirPath );
  test.is( self.provider.directoryIs( testDirPath ) );
  test.identical( got, true );

  test.case = 'hard link to file';
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.linkHard( dstPath, srcPath );
  var got = self.provider.fileExists( dstPath );
  test.is( self.provider.filesAreHardLinked( dstPath, srcPath ) );
  test.identical( got, true );

  if( !test.context.symlinkIsAllowed() )
  return;

  test.case = 'soft link to file';
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.linkSoft( dstPath, srcPath );
  var got = self.provider.fileExists( dstPath );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  test.identical( got, true );

  test.case = 'soft link to file that not exists';
  self.provider.filesDelete( srcPath );
  self.provider.linkSoft({ dstPath : dstPath, srcPath : srcPath, allowMissing : 1 });
  var got = self.provider.fileExists( dstPath );
  test.is( self.provider.fileIsSoftLink( dstPath ) );
  test.identical( got, true );
}


// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/fileProvider/Abstract',
  abstract : 1,
  silencing : 1,
  // verbosity : 7,

  onSuiteBegin : onSuiteBegin,

  context :
  {
    makePath : makePath,
    providerIsInstanceOf : providerIsInstanceOf,
    symlinkIsAllowed : symlinkIsAllowed,
    testRootDirectory : null,
    // shouldWriteOnlyOnce : shouldWriteOnlyOnce
  },

  tests :
  {

    //testDelaySample : testDelaySample,
    mustNotThrowError : mustNotThrowError,

    readWriteSync : readWriteSync,
    readWriteAsync : readWriteAsync,

    fileReadJson : fileReadJson,

    fileWriteJson : fileWriteJson,

    fileTouch : fileTouch,
    fileTimeSet : fileTimeSet,

    writeAsyncThrowingError : writeAsyncThrowingError,

    fileCopySync : fileCopySync,
    fileCopyActSync : fileCopyActSync,
    fileCopyRelativePath : fileCopyRelativePath,
    fileCopyLinksSync : fileCopyLinksSync,
    fileCopyAsync : fileCopyAsync,
    fileCopyLinksAsync : fileCopyLinksAsync,
    fileCopyAsyncThrowingError : fileCopyAsyncThrowingError,/* last case dont throw error */

    fileRenameSync : fileRenameSync,
    fileRenameRelativePath : fileRenameRelativePath,
    fileRenameAsync : fileRenameAsync,

    fileDeleteSync : fileDeleteSync,
    fileDeleteActSync : fileDeleteActSync,
    fileDeleteAsync : fileDeleteAsync,

    fileStatSync : fileStatSync,
    fileStatActSync : fileStatActSync,
    fileStatAsync : fileStatAsync,

    directoryMakeSync : directoryMakeSync,
    directoryMakeAsync : directoryMakeAsync,

    fileHashSync : fileHashSync,
    fileHashAsync : fileHashAsync,

    directoryReadSync : directoryReadSync,
    directoryReadAsync : directoryReadAsync,

    fileWriteSync : fileWriteSync,
    fileWriteLinksSync : fileWriteLinksSync,
    fileWriteAsync : fileWriteAsync,
    fileWriteLinksAsync : fileWriteLinksAsync,

    fileReadAsync : fileReadAsync,

    linkSoftSync : linkSoftSync,
    linkSoftAsync : linkSoftAsync,
    linkSoftRelativePath : linkSoftRelativePath,
    linkSoftChain : linkSoftChain,

    linkHardSync : linkHardSync,
    linkHardRelativePath : linkHardRelativePath,
    // linkHardExperiment : linkHardExperiment,
    linkHardSoftlinked : linkHardSoftlinked,
    linkHardActSync : linkHardActSync,
    linkHardAsync : linkHardAsync,

    fileExchangeSync : fileExchangeSync,
    fileExchangeAsync : fileExchangeAsync,

    //etc

    nativize : nativize,

    // experiment : experiment,

    // linkHardSyncRunner : linkHardSyncRunner,
    // linkHardAsyncRunner : linkHardAsyncRunner,

    directoryIs : directoryIs,
    directoryIsEmpty : directoryIsEmpty,

    fileIsTerminal : fileIsTerminal,
    fileSymbolicLinkIs : fileSymbolicLinkIs,

    filesAreHardLinked : filesAreHardLinked,
    filesAreSame : filesAreSame,

    filesSize : filesSize,
    fileSize : fileSize,

    fileExists : fileExists,

  },

};

wTestSuite( Self );

})();
