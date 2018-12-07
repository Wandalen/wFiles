( function _FileProvider_test_s_( ) {

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

  if( Config.platform === 'nodejs' && typeof process !== undefined )
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

// function shouldWriteOnlyOnce( test, filePath, expected )
// {
//   var self = this;
//
//   test.case = 'shouldWriteOnlyOnce test';
//   var files = self.provider.dirRead( self.makePath( filePath ) );
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

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
  self.provider.dirMake( filePath );

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
  var files = self.provider.dirRead( dir );
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
    encoding : isHd ? 'js.node' : 'js.structure',
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

  if( Config.platform === 'nodejs' )
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( _.path.dir( filePath ) );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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

  var files = self.provider.dirRead( dir );
  test.identical( files, null );

  /*file not exist*/

  self.provider.dirMake( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
    self.provider.softLink( linkPath, filePath );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data);
    self.provider.fieldReset( 'resolvingSoftLink', 1 );

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    self.provider.fileWrite( filePath, data );
    var linkPath = test.context.makePath( 'written/readWriteSync/link' );
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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
    self.provider.softLink( linkPath, filePath );
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

  if( Config.platform === 'nodejs' )
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
    var files = self.provider.dirRead( dir );
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
        self.provider.softLink( linkPath, filePath );
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
        self.provider.softLink( linkPath, filePath );
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
    // test.is( !self.provider.isHardLink( linkPath ) );

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
    test.is( !self.provider.isSoftLink( linkPath ) );

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
  // var files = self.provider.dirRead( test.context.makePath( 'written/readWriteSync/' ) );
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
  // var files = self.provider.dirRead( test.context.makePath( 'written/readWriteSync/' ) );
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
  // var files = self.provider.dirRead( test.context.makePath( 'written/readWriteSync/' ) );
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );
  consequence

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileRead, invalid path';
    var con = self.provider.fileRead
    ({
      filePath : '/invalid path',
      sync : 0,
      throwing : 1,
    });
    return test.shouldThrowError( con );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : '/invalid path',
      sync : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( ( got ) =>
    {
      test.identical( got, null );
      return got;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileRead, path ways to not a terminal file';
    filePath = test.context.makePath( 'written/readWriteAsync/dir' );
    self.provider.dirMake( filePath );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( ( got ) =>
    {
      test.identical( got, null );
      return got;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileRead,simple file read ';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    self.provider.fileWrite( filePath, testData );
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 0,
      encoding : 'utf8',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .doThen( function( err, got )
    {
      test.identical( got, testData );
      return got;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function()
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

  .doThen( function( err, arg/*aaa*/ )
  {
    test.case = 'fileRead,file read with common encodings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .doThen( function( err, got )
    {
      test.identical( got , testData );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      encoding : 'js.smart',
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

      return got;
    });
  })

  //

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
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

      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })

  /*onBegin returningRead 0*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.identical( _.objectIs( got ), true );
      return null;
    });
  })

  /*onBegin returningRead 1*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.identical( _.objectIs( got ), true );
      return null;
    });
  })

  /*onEnd returningRead 0*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.identical( got.result, testData );
      return null;
    });
  })

  /*onEnd returningRead 1*/
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.identical( got.result, testData );
      return null;
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 1,
      filePath : '/invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      test.identical( _.errIs( got ), true )
      return null;
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 1,
      throwing : 1,
      filePath : '/invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      test.identical( _.errIs( got ), true );
      return null;
    });
  })

  /*onError is no called*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 0,
      filePath : '/invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.identical( _.errIs( got ), true );
      return null;
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      returningRead : 0,
      throwing : 1,
      filePath : '/invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      test.identical( _.errIs( got ), true );
      return null;
    });
  })

  //fileWrite

  .doThen( function( err, arg/*aaa*/ )
  {
    test.case = 'fileWrite, path not exist,default settings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.fileWrite
    ({
       sync : 0,
       filePath : filePath,
       data : testData,
    })
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );

    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  /*path includes not existing directory*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    filePath = test.context.makePath( 'written/readWriteAsync/files/file.txt' );
    return self.provider.fileWrite
    ({
       sync : 0,
       filePath : filePath,
       data : testData
    })
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( test.context.makePath( 'written/readWriteAsync/files' ) );
    test.identical( files, [ 'file.txt' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileWrite, path already exist,default settings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    self.provider.fileWrite( filePath, testData );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.fileWrite
    ({
       sync : 0,
       filePath : filePath,
       data : testData
    })
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  /*try rewrite folder*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg )
  {
    test.case = 'fileWrite, path already exist';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    testData = 'Lorem ipsum dolor sit amet';
    self.provider.fileWrite( filePath, testData );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileWrite, path not exist';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    return null;
  })

  /*path includes not existing directory*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      makingDirectory : 0,
      purging : 0,
    });
    return test.shouldThrowError( con )
  })
  .ifNoErrorThen( function( arg )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, null );
    return null;
  })

  /*file not exist*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.dirMake( dir );
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  /*purging non existing filePath*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    test.identical( got, testData );
    return null;
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileWrite, different write modes';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    return null;
  })

  /*rewrite*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
    return null;
  })

  /*prepend*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData+testData );
    return null;
  })

  /*append*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData+testData );
    return null;
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'fileWrite, any writeMode should create file it not exist';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    filePath = test.context.makePath( 'written/readWriteAsync/file' );
    return null;
  })

  /*rewrite*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.fileWrite
    ({
      filePath : filePath,
      data : testData,
      sync : 0,
      writeMode : 'rewrite'
    });
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
    return null;
  })

  /*prepend*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
    return null;
  })

  /*append*/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1
    });
    var files = self.provider.dirRead( dir );
    test.identical( files, [ 'file' ] );
    test.identical( got, testData );
    return null;
  })

  /* resolvingSoftLink */

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {

    if( !symlinkIsAllowed )
    return null;

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
      self.provider.softLink( linkPath, filePath );
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data );
        self.provider.fieldReset( 'resolvingSoftLink', 1 );
        return null;

      })
    })
  })

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    if( !symlinkIsAllowed )
    return null;

    test.case = 'read from soft link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
      self.provider.softLink( linkPath, filePath );
      var con = self.provider.fileRead({ filePath : linkPath, sync : 0 });
      return test.shouldThrowError( con )
      .doThen( () =>
      {
        self.provider.fieldReset( 'resolvingSoftLink', 0 );
        return null;
      })
    })

  })

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    if( !symlinkIsAllowed )
    return null;

    test.case = 'write using link, resolvingSoftLink on';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
      self.provider.softLink( linkPath, filePath );
      return self.provider.fileWrite({ filePath : filePath, data : data + data, sync : 0 })
    })
    .doThen( () => self.provider.fileRead({ filePath : filePath, sync : 0 }) )
    .doThen( ( err, got ) =>
    {
      test.identical( got, data + data );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
      return null;
    })
  })

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    if( !symlinkIsAllowed )
    return null;

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      self.provider.softLink( linkPath, filePath );
      return self.provider.fileWrite({ filePath : linkPath, data : data + data, sync : 0 })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : filePath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data );
        return null;
      })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data + data );
        return null;
      })
    })
    .doThen( () => self.provider.fieldReset( 'resolvingSoftLink', 0 ) )
  })

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    if( !symlinkIsAllowed )
    return null;

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      self.provider.softLink( linkPath, filePath );
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
        return null;
      })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, data + data );
        return null;
      })
    })
    .doThen( () => self.provider.fieldReset( 'resolvingSoftLink', 0 ) )
  })

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    if( !symlinkIsAllowed )
    return null;

    test.case = 'write using link, resolvingSoftLink off';
    var data = 'data';
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var linkPath = test.context.makePath( 'written/readWriteAsync/link' );
    return self.provider.fileWrite({ filePath : filePath, data : data, sync : 0 })
    .doThen( () =>
    {
      self.provider.softLink( linkPath, filePath );
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
        return null;
      })
    })
    .doThen( () =>
    {
      return self.provider.fileRead({ filePath : linkPath, sync : 0 })
      .doThen( ( err, got ) =>
      {
        test.identical( got, 'prepend' + data );
        return null;
      })
    })
    .doThen( () =>
    {
      self.provider.fieldReset( 'resolvingSoftLink', 0 )
      return null;
    })

  })



  //

  if( Config.platform === 'nodejs' )
  {
    consequence.ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.case = 'fileWrite, data is raw buffer';
      self.provider.filesDelete( dir );
      testData = 'Lorem ipsum dolor sit amet';
      buffer = _.bufferRawFrom( Buffer.from( testData ) );
      filePath = test.context.makePath( 'written/readWriteAsync/file' );
      return null;
    })

    /**/

    consequence.ifNoErrorThen( function( arg/*aaa*/ )
    {
      return self.provider.fileWrite
      ({
        filePath : filePath,
        data : buffer,
        sync : 0,
      });
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      got = self.provider.fileRead
      ({
         filePath : filePath,
         sync : 1,
      });
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'file' ] );
      test.identical( got, testData );
      return null;
    });

    //

    consequence.ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      test.case = 'other encodings';
      self.provider.filesDelete( dir );
      filePath = test.context.makePath( 'written/readWriteSync/file' );
      testData = 'abc';
      return null;
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
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

  if( Config.platform === 'browser' || self.providerIsInstanceOf( _.FileProvider.Extract ))
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

    if( self.provider.statResolvedRead( path ) )
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

function fileReadWithEncoding( test )
{
  let self = this;
  let filePath = test.context.makePath( 'written/fileReadWithEncoding/dstFile' );
  let isHd = self.providerIsInstanceOf( _.FileProvider.HardDrive );

  test.open( 'buffer.*' );

  var data = 'abc'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, data );

  //

  var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.bytes' });
  test.identical( got, _.bufferBytesFrom( data ) );

  //

  if( isHd )
  {
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.node' });
    test.identical( got, _.bufferNodeFrom( data ) )
  }

  //

  var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.raw' });
  test.identical( got, _.bufferRawFrom( data ) )

  test.close( 'buffer.*' );

  /**/

  test.open( 'json' );

  var data = 'string'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data, encoding : 'json' });
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, data );

  //

  var data = [ 1,2,3 ];
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data, encoding : 'json' });
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, data );

  //

  var data = '{a : b}';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data });
  test.shouldThrowError( () =>
  {
    self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  })

  //

  var data =
  {
    string : 'string',
    number : 1,
    array : [ 1, 'string' ],
    map : { string : 'string', number : 1, array : [ 'string', 1 ] }
  };
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data, encoding : 'json' });
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, data );

  test.close( 'json' );

  /**/

  test.open( 'js' );

  var data  =
  `{
    string : 'string',
    number : 1,
    array : [ 1, 'string' ],
    date : new Date( Date.UTC( 2018,1,1 ) ),
    buffer : new Uint16Array([ 1,2,3 ]),
    map : { string : 'string', number : 1, array : [ 'string', 1 ] }
  }`;
  var expected =
  {
    string : 'string',
    number : 1,
    array : [ 1, 'string' ],
    date : new Date( Date.UTC( 2018,1,1 ) ),
    buffer : new Uint16Array([ 1,2,3 ]),
    map : { string : 'string', number : 1, array : [ 'string', 1 ] }
  }
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data });
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  test.identical( got, expected )

  //

  var data = '{a : b}';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data });
  test.shouldThrowError( () =>
  {
    self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  })

  test.close( 'js' );

  /* */

  test.open( 'js.smart' );

  var data = 'return 1';
  if( isHd )
  data = 'module.exports = { data : 1 }'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : data });
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.smart' });
  if( isHd )
  test.identical( got, { data : 1 } );
  else
  test.identical( got, 1 );

  //

  var data = '{a : b}';
  var filePath2 = test.context.makePath( 'written/fileReadWithEncoding/dstFile2' );
  self.provider.filesDelete( filePath2 );
  self.provider.fileWrite({ filePath : filePath2, data : data });
  test.shouldThrowError( () =>
  {
    self.provider.fileRead({ filePath : filePath2, encoding : 'js.smart' });
  })

  test.close( 'js.smart' );

  /* */

  if( isHd )
  {
    test.case = 'js.node'
    var data = 'module.exports = { data : 1 }'
    self.provider.filesDelete( filePath );
    self.provider.fileWrite({ filePath : filePath, data : data });
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.node' });
    test.identical( got, { data : 1 });

    //

    var data = 'module.exports = { data : 1 '
    var filePath3 = test.context.makePath( 'written/fileReadWithEncoding/dstFile3' );
    self.provider.filesDelete( filePath3 );
    self.provider.fileWrite({ filePath : filePath3, data : data });
    test.shouldThrowError( () =>
    {
      self.provider.fileRead({ filePath : filePath3, encoding : 'js.node' });
    })
  }
}

//

function fileWriteWithEncoding( test )
{
  let self = this;
  let filePath = test.context.makePath( 'written/fileWriteWithEncoding/dstFile' );
  let isHd = self.providerIsInstanceOf( _.FileProvider.HardDrive );

  /* js */

  var src = '';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'js.structure' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  test.identical( got, src );

  var src = 'return 1';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'js.structure' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  test.identical( got, src );

  var src = [ 1, '2', { a : 3 } ];
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'js.structure' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  test.identical( got, src );

  var src = new Date();
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'js.structure' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  test.identical( got, src );

  var src =
  {
    string : 'string',
    number : 1,
    array : [ 1, 'string' ],
    date : new Date(),
    buffer : new Uint16Array([ 1,2,3 ]),
    map : { string : 'string', number : 1, array : [ 'string', 1 ] }
  }
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'js.structure' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'js.structure' });
  test.identical( got, src );

  /* json */

  var src = '';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'json' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, src );

  var src = [ 1, 'a', { b : 34 } ];
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'json' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, src );

  var src = { a : 1, b : 's', c : [ 1, 3, 4 ] };
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'json' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, src );

  var src = '{ "a" : "3" }';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'json' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, src );

  var src = new Date( Date.UTC( 2018,1,1 ) );
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'json' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, '2018-02-01T00:00:00.000Z' );

  var src =
  {
    string : 'string',
    number : 1,
    array : [ 1, 'string' ],
    date : new Date( Date.UTC( 2018,1,1 ) ),
    buffer : new Uint16Array([ 1,2,3 ]),
    map : { string : 'string', number : 1, array : [ 'string', 1 ] }
  }
  var expected  =
  {
    string : 'string',
    number : 1,
    array : [ 1, 'string' ],
    date : '2018-02-01T00:00:00.000Z' ,
    buffer : { 0 : 1, 1 : 2, 2 : 3 },
    map : { string : 'string', number : 1, array : [ 'string', 1 ] }
  }
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'json' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'json' });
  test.identical( got, expected );

  /* origignal.type rewrite */

  var src = 'string';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'original.type' })
  var got = self.provider.fileRead( filePath );
  test.identical( got, src );

  var src = new Uint8Array([ 99,100,101 ]);
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'original.type' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.bytes' });
  test.identical( got, src );

  if( isHd )
  {
    var src = _.bufferNodeFrom( [ 99,100,101 ] )
    self.provider.filesDelete( filePath );
    self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'original.type' })
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.node' });
    test.identical( got, src );
  }

  var src = new ArrayBuffer( 3 );
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src, encoding : 'original.type' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.raw' });
  test.identical( got, src );

  /* original.type append to existing file */

  var src = 'string';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src });
  self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'append', encoding : 'original.type' })
  var got = self.provider.fileRead( filePath );
  test.identical( got, src + src );

  var src = new Uint8Array([ 99,100,101 ]);
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src });
  self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'append', encoding : 'original.type' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'original.type' });
  test.identical( got, _.bufferJoin( src,src ) );

  if( isHd )
  {
    var src = _.bufferNodeFrom( [ 99,100,101 ] )
    self.provider.filesDelete( filePath );
    self.provider.fileWrite({ filePath : filePath, data : src });
    self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'append', encoding : 'original.type' })
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.node' });
    test.identical( got, _.bufferJoin( src,src ) );
  }

  var src = new ArrayBuffer( 3 );
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src });
  self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'append', encoding : 'original.type' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.raw' });
  test.identical( got, _.bufferJoin( src,src ) );

  /* original.type prepend to existing file */

  var src = 'string';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src });
  self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'prepend', encoding : 'original.type' })
  var got = self.provider.fileRead( filePath );
  test.identical( got, src + src );

  var src = new Uint8Array([ 99,100,101 ]);
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src });
  self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'prepend', encoding : 'original.type' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'original.type' });
  test.identical( got, _.bufferJoin( src,src ) );

  if( isHd )
  {
    var src = _.bufferNodeFrom( [ 99,100,101 ] )
    self.provider.filesDelete( filePath );
    self.provider.fileWrite({ filePath : filePath, data : src });
    self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'prepend', encoding : 'original.type' })
    var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.node' });
    test.identical( got, _.bufferJoin( src,src ) );
  }

  var src = new ArrayBuffer( 3 );
  self.provider.filesDelete( filePath );
  self.provider.fileWrite({ filePath : filePath, data : src });
  self.provider.fileWrite({ filePath : filePath, data : src, writeMode : 'prepend', encoding : 'original.type' })
  var got = self.provider.fileRead({ filePath : filePath, encoding : 'buffer.raw' });
  test.identical( got, _.bufferJoin( src,src ) );

};

//

function fileWriteJson( test )
{
  let self = this;

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

    if( self.provider.statResolvedRead( path ) )
    self.provider.fileDelete( path );

    var con = self.provider.fileWriteJson( path, testCheck.data );

    // fileWtrite must returns wConsequence
    got.instance = _.consequenceIs( con );

    // recorded file should exists
    got.exist = !!self.provider.statResolvedRead( path );

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
}

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

  self.provider.filesDelete( dir );

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var srcPath = _.path.normalize( test.context.makePath( 'written/fileTouch/src.txt' ) );
  var testData = 'test';

  //

  test.case = 'filePath doesnt exist'
  // self.provider.filesDelete( srcPath );
  self.provider.fileTouch( srcPath );
  var stat = self.provider.statResolvedRead( srcPath );
  test.is( _.objectIs( stat ) );

  test.case = 'filePath doesnt exist, filePath as record';
  self.provider.filesDelete( srcPath );
  var record = self.provider.recordFactory().record( srcPath );
  test.identical( record.stat, null );
  self.provider.fileTouch( record );
  var stat = self.provider.statResolvedRead( srcPath );
  test.is( _.objectIs( stat ) );

  test.case = 'filePath is a directory';
  self.provider.filesDelete( srcPath );
  self.provider.dirMake( srcPath );
  test.shouldThrowError( () => self.provider.fileTouch( srcPath ) );

  test.case = 'directory, filePath as record';
  self.provider.filesDelete( srcPath );
  self.provider.dirMake( srcPath );
  var record = self.provider.recordFactory().record( srcPath );
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

  var con = new _.Consequence().give( null )

  /**/

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    test.case = 'filePath is a terminal';
    self.provider.filesDelete( srcPath );
    self.provider.fileWrite( srcPath, testData );
    var statsBefore = self.provider.statResolvedRead( srcPath );
    return _.timeOut( 1000, () =>
    {
      self.provider.fileTouch( srcPath );
      var statsAfter = self.provider.statResolvedRead( srcPath );
      test.identical( statsAfter.size, statsBefore.size );
      test.identical( statsAfter.ino , statsBefore.ino );
      test.is( statsAfter.mtime > statsBefore.mtime );
      test.is( statsAfter.ctime > statsBefore.mtime );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    test.case = 'terminal, filePath as record';
    self.provider.filesDelete( srcPath );
    self.provider.fileWrite( srcPath, testData );
    var record = self.provider.recordFactory().record( srcPath );
    var statsBefore = record.stat;
    return _.timeOut( 1000, () =>
    {
      self.provider.fileTouch( record );
      var statsAfter = self.provider.statResolvedRead( srcPath );
      test.identical( statsAfter.size, statsBefore.size );
      test.identical( statsAfter.ino , statsBefore.ino );
      test.is( statsAfter.mtime > statsBefore.mtime );
      test.is( statsAfter.ctime > statsBefore.mtime );
      return null;
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
  var stat  = self.provider.statResolvedRead( filePath );
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
  var stat  = self.provider.statResolvedRead( testDir );
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
  var stat  = self.provider.statResolvedRead( filePath );
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
  var stat  = self.provider.statResolvedRead( testDir );
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
  var stat  = self.provider.statResolvedRead( filePath );
  test.is( stat.isFile() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'two args, dir';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var filePath2 = test.context.makePath( 'written/fileTimeSet/dir' );
  self.provider.dirMake( filePath2 );
  var time = new Date();
  self.provider.fileTimeSet( filePath2, time, time );
  self.provider.fileTimeSet( testDir, filePath2 );
  var stat  = self.provider.statResolvedRead( testDir );
  test.is( stat.isDirectory() );
  var adiff = time.getTime() - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time.getTime() - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'negative values';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var statb  = self.provider.statResolvedRead( testDir );
  self.provider.fileTimeSet( filePath, -1, -1 );
  var stata  = self.provider.statResolvedRead( testDir );
  test.ge( statb.mtime, stata.mtime );
  test.ge( statb.atime, stata.atime );

  test.case = 'zero values';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var statb  = self.provider.statResolvedRead( testDir );
  self.provider.fileTimeSet( filePath, 0, 0 );
  var stata  = self.provider.statResolvedRead( testDir );
  test.ge( statb.mtime, stata.mtime );
  test.ge( statb.atime, stata.atime );

  if( process )
  if( process.platform === 'win32' )
  {
    test.case = 'number, milliseconds';
    self.provider.filesDelete( filePath );
    self.provider.fileWrite( filePath, filePath );
    var time = new Date().getTime();
    var statb  = self.provider.statResolvedRead( filePath );
    test.shouldThrowError( () => self.provider.fileTimeSet( filePath, time, time ) );
    var stata  = self.provider.statResolvedRead( filePath );
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
    var stat  = self.provider.statResolvedRead( filePath );
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
  var stat  = self.provider.statResolvedRead( filePath );
  test.is( stat.isFile() );
  var adiff = time - stat.atime.getTime();
  testDiff( adiff );
  var mdiff = time - stat.mtime.getTime();
  testDiff( mdiff );

  test.case = 'incorrect atime type';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  var statb  = self.provider.statResolvedRead( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet( filePath, {}, time ) );
  var stata  = self.provider.statResolvedRead( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  test.case = 'two args, second file does not exist';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( filePath, filePath );
  var filePath2 = test.context.makePath( 'written/fileTimeSet/dir' );
  var time = new Date();
  var statb  = self.provider.statResolvedRead( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet( filePath, filePath2 ) );
  var stata  = self.provider.statResolvedRead( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  test.case = 'only atime';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  var statb  = self.provider.statResolvedRead( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet({ filePath : filePath, atime : time }) );
  var stata  = self.provider.statResolvedRead( filePath );
  test.identical( statb.atime, stata.atime );
  test.identical( statb.mtime, stata.mtime );

  test.case = 'only mtime';
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var time = new Date();
  var statb  = self.provider.statResolvedRead( filePath );
  test.shouldThrowError( () => self.provider.fileTimeSet({ filePath : filePath, mtime : time }) );
  var stata  = self.provider.statResolvedRead( filePath );
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

  var consequence = new _.Consequence().give( null );

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
  {

    test.case = 'async, try to rewrite dir';

    var path = test.context.makePath( 'dir' );
    self.provider.dirMake( path );
    test.identical( self.provider.isDir( path ), true )
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

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
  test.identical( got, null );

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
  test.identical( got, null );

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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src.txt' ] );

  //

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  return;

  test.case = 'src is not a terminal, dst present, check if nothing changed';

  /* rewritin & throwing on */

  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( dstPath, ' ' );
  var srcStatExpected = self.provider.statResolvedRead( srcPath );
  var dstBefore = self.provider.fileRead( dstPath );
  var dirBefore = self.provider.dirRead( dir );
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
  var srcStat = self.provider.statResolvedRead( srcPath );
  var dstNow = self.provider.fileRead( dstPath );
  test.is( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.dirRead( dir );
  test.identical( dirAfter, dirBefore );

  /* rewritin on & throwing off */

  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( dstPath, ' ' );
  var srcStatExpected = self.provider.statResolvedRead( srcPath );
  var dstBefore = self.provider.fileRead( dstPath );
  var dirBefore = self.provider.dirRead( dir );
  var got = self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, false );
  var srcStat = self.provider.statResolvedRead( srcPath );
  var dstNow = self.provider.fileRead( dstPath );
  test.is( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.dirRead( dir );
  test.identical( dirAfter, dirBefore );

  /* rewritin & throwing off */

  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( dstPath, ' ' );
  var srcStatExpected = self.provider.statResolvedRead( srcPath );
  var dstBefore = self.provider.fileRead( dstPath );
  var dirBefore = self.provider.dirRead( dir );
  var got = self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, false );
  var srcStat = self.provider.statResolvedRead( srcPath );
  var dstNow = self.provider.fileRead( dstPath );
  test.is( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.dirRead( dir );
  test.identical( dirAfter, dirBefore );

  //

  test.case = 'makingDirectory creates dir for a file, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !self.provider.statResolvedRead( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    makingDirectory : 1,
    throwing : 1
  });
  test.is( !!self.provider.statResolvedRead( dstPath ) );

  //

  test.case = 'rewriting off, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !self.provider.statResolvedRead( dstPath ) );
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
  test.is( !self.provider.statResolvedRead( dstPath ) );

  //

  test.case = 'rewriting off, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !self.provider.statResolvedRead( dstPath ) );
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
  test.is( !self.provider.statResolvedRead( dstPath ) );

  //

  test.case = 'rewriting on, parentDir is a terminal file'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var terminalFilePath = _.path.join( dir, 'folder/structure' );
  self.provider.fileWrite( terminalFilePath, dstPath );
  var dstPath = _.path.join( dir, 'folder/structure/dst' );
  test.is( !!self.provider.statResolvedRead( terminalFilePath ) );
  test.is( !self.provider.statResolvedRead( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    makingDirectory : 1,
    throwing : 1
  });
  test.is( self.provider.isDir( terminalFilePath ) );
  test.is( !!self.provider.statResolvedRead( dstPath ) );

  //

  test.case = 'rewriting on, parentDir is a directory with files, dir must be preserved'
  self.provider.filesDelete( dir );
  var file1 = _.path.join( dir, 'dir', 'file1' );
  var file2 = _.path.join( dir, 'dir', 'file2' );
  self.provider.fileWrite( file1, file1 );
  self.provider.fileWrite( file2, file2 );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir, 'dst' );
  test.is( !self.provider.statResolvedRead( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  var files = self.provider.dirRead( dir );
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
  test.is( !self.provider.statResolvedRead( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  test.is( !!self.provider.statResolvedRead( srcPath ) );
  test.is( !!self.provider.statResolvedRead( dstPath ) );
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
  var files = self.provider.dirRead( dir );
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
  self.provider.dirMake( srcPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] )

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.dirRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.dirRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.dirRead( dstPath );
  test.identical( files, [] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.dirRead( dstPath );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  self.provider.hardLink( dstPath, srcPath );
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
  test.is( self.provider.isHardLink( dstPath ) );
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
  self.provider.hardLink( dstPath, srcPath );
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
  test.is( self.provider.isHardLink( dstPath ) );
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
  self.provider.hardLink( dstPath, srcPath );
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
  test.is( !self.provider.isHardLink( dstPath ) );
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
  self.provider.hardLink( dstPath, srcPath );
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
  test.is( !self.provider.isHardLink( dstPath ) );
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
  self.provider.softLink( dstPath, srcPath );
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
  test.is( self.provider.isSoftLink( dstPath ) );
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
  self.provider.softLink( dstPath, srcPath );
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
  test.is( self.provider.isSoftLink( dstPath ) );
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
  self.provider.softLink( dstPath, srcPath );
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
  test.is( self.provider.isSoftLink( dstPath ) );
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
    self.provider.fileCopyAct( o );
  })
  test.is( !self.provider.fileExists( dstPath ) );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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
    breakingDstHardLink : 0,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.fileCopyAct( o );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst', 'src' ] );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
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
    breakingDstHardLink : 0,
    sync : 1
  }

  var expected = _.mapExtend( null, o );
  expected.srcPath = self.provider.path.nativize( o.srcPath );
  expected.dstPath = self.provider.path.nativize( o.dstPath );

  self.provider.fileCopyAct( o );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst', 'src' ] );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.case = 'should assert that path is absolute';
  var srcPath = './dst';
  var dstPath = _.path.join( dir,'dst' );

  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
      breakingDstHardLink : 0
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
  var srcPath = _.path.join( dir,'src' );;
  var dstPath = _.path.join( dir,'dst' );

  /* sync option is missed */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingDstHardLink : 0
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct( o );
  });

  /* redundant option */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingDstHardLink : 0,
    sync : 1,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct( o );
  });

  //

  test.case = 'should expect normalized path, but not nativized';
  var srcPath = dir + '\\src';
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = dir + '\\dst';
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    breakingDstHardLink : 0,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct( o );
  })
  self.provider.filesDelete( dir );

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
    breakingDstHardLink : 0,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.fileCopyAct( o );
  })
  test.identical( o.srcPath, expected.srcPath );

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
  self.provider.dirMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile, dstPath ) );


  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile, dstPath ) );


  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/fileCopyRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( pathToFile2, dstPath ) );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/fileCopyRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/fileCopyRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
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
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.fileCopy( dstPath, srcPath );
  test.is( self.provider.filesAreSame( srcPath, dstPathResolved ) );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.dirMake( pathToDir );

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
  self.provider.dirMake( pathToDir );

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
  var statBefore = self.provider.statResolvedRead( pathToFile );
  var got = self.provider.fileCopy( dstPath, srcPath );
  var statNow = self.provider.statResolvedRead( pathToFile );
  test.identical( got, true );
  test.identical( statBefore.mtime.getTime(), statNow.mtime.getTime() );

  var srcPath = pathToFile;
  var dstPath = '../file';
  var statBefore = self.provider.statResolvedRead( pathToFile );
  var got = self.provider.fileCopy( dstPath, srcPath );
  var statNow = self.provider.statResolvedRead( pathToFile );
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  var otherPath = _.path.join( dir, 'other' );

  //

  /* hardlink */

  test.case = 'dst is a hard link, breaking disabled';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.hardLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 0
  });
  test.is( self.provider.isHardLink( dstPath ) );
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
  self.provider.hardLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 0
  });
  test.is( self.provider.isHardLink( dstPath ) );
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
  self.provider.hardLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.isHardLink( dstPath ) );
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
  self.provider.hardLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.isHardLink( dstPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.hardLink( dstPath, otherPath );
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
  test.is( !!self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.hardLink( dstPath, otherPath );
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
  test.is( !!self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.hardLink( dstPath, otherPath );
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
  test.is( !!self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.hardLink( dstPath, otherPath );
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
  test.is( !!self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.hardLink( dstPath, otherPath );
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
  test.is( !!self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.softLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 0
  });
  test.is( !self.provider.isSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );
  test.identical( otherFile, otherFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );

  //

  test.case = 'dst is a soft link, breakingDstSoftLink : 0 ,breakingDstHardLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 0,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.isSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );
  test.identical( otherFile, otherFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );

  //

  //breakingDstSoftLink is not present anymore

  /* test.case = 'dst is a soft link, breakingDstSoftLink : 1';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 0
  });
  test.is( !self.provider.isSoftLink( dstPath ) );
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
  self.provider.softLink( dstPath, srcPath );
  self.provider.fileCopy
  ({
    dstPath : dstPath,
    srcPath : otherPath,
    sync : 1,
    // breakingDstSoftLink : 1,
    breakingDstHardLink : 1
  });
  test.is( !self.provider.isSoftLink( dstPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, otherPath );
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
  test.is( !!self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, otherPath );
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
  test.is( !!self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, otherPath );
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
  test.is( !!self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, otherPath );
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
  test.is( !!self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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
  self.provider.dirMake( srcPath );
  self.provider.fileWrite( otherPath, otherPath );
  self.provider.softLink( dstPath, otherPath );
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
  test.is( !!self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isDir( srcPath ) );
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var srcPath = test.context.makePath( 'written/fileCopyAsync/src.txt' );
  var dstPath = test.context.makePath( 'written/fileCopyAsync/dst.txt' );

  var consequence = new _.Consequence().give( null );

  //

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'src not exist';
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      test.identical( got, null );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      test.identical( got, null );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'copy bigger file';
    var data = _.strDup( 'Lorem Ipsum is simply text', 10000 );
    self.provider.fileWrite( srcPath, data );
    self.provider.filesDelete( dstPath );
    var srcStat = self.provider.statResolvedRead( srcPath );
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
      var dstStat = self.provider.statResolvedRead( dstPath );
      test.identical( srcStat.size, dstStat.size );
      var dstFile = self.provider.fileRead( dstPath );
      test.is( dstFile === data );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dst path not exist';
    self.provider.fileWrite( srcPath, ' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dst path exist';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
    self.provider.fileWrite( dstPath, ' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst.txt', 'src.txt' ] );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, ' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src.txt' ] );
      return null;
    });
  });

  //

  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  return consequence;

  consequence.doThen( () =>
  {
    test.case = 'src is not a terminal, dst present, check if nothing changed';
    return true;
  })

  /* rewritin & throwing on */

  .doThen( () =>
  {
    self.provider.filesDelete( dir );
    self.provider.dirMake( srcPath );
    self.provider.fileWrite( dstPath, ' ' );
    var srcStatExpected = self.provider.statResolvedRead( srcPath );
    var dstBefore = self.provider.fileRead( dstPath );
    var dirBefore = self.provider.dirRead( dir );
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
      var srcStat = self.provider.statResolvedRead( srcPath );
      var dstNow = self.provider.fileRead( dstPath );
      test.is( srcStat.isDirectory() );
      test.identical( srcStat.size, srcStatExpected.size );
      test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
      test.identical( dstNow, dstBefore );
      var dirAfter = self.provider.dirRead( dir );
      test.identical( dirAfter, dirBefore );
      return true;
    })

  })

  /* rewritin on & throwing off */

  .doThen( () =>
  {
    self.provider.filesDelete( dir );
    self.provider.dirMake( srcPath );
    self.provider.fileWrite( dstPath, ' ' );
    var srcStatExpected = self.provider.statResolvedRead( srcPath );
    var dstBefore = self.provider.fileRead( dstPath );
    var dirBefore = self.provider.dirRead( dir );
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
      var srcStat = self.provider.statResolvedRead( srcPath );
      var dstNow = self.provider.fileRead( dstPath );
      test.is( srcStat.isDirectory() );
      test.identical( srcStat.size, srcStatExpected.size );
      test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
      test.identical( dstNow, dstBefore );
      var dirAfter = self.provider.dirRead( dir );
      test.identical( dirAfter, dirBefore );
      return got;
    })

  })

  /* rewritin & throwing off */

  .doThen( () =>
  {
    self.provider.filesDelete( dir );
    self.provider.dirMake( srcPath );
    self.provider.fileWrite( dstPath, ' ' );
    var srcStatExpected = self.provider.statResolvedRead( srcPath );
    var dstBefore = self.provider.fileRead( dstPath );
    var dirBefore = self.provider.dirRead( dir );
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
      var srcStat = self.provider.statResolvedRead( srcPath );
      var dstNow = self.provider.fileRead( dstPath );
      test.is( srcStat.isDirectory() );
      test.identical( srcStat.size, srcStatExpected.size );
      test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
      test.identical( dstNow, dstBefore );
      var dirAfter = self.provider.dirRead( dir );
      test.identical( dirAfter, dirBefore );
      return got;
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  var otherPath = _.path.join( dir, 'other' );

  var con = new _.Consequence().give( null )

  //

  /* hardlink */

  .ifNoErrorThen( () =>
  {
    test.case = 'dst is a hard link, breaking disabled';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.hardLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      test.is( self.provider.isHardLink( dstPath ) );
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
      return null;
    })
  })

  //

  .ifNoErrorThen( () =>
  {
    test.case = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.hardLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      // breakingDstSoftLink : 1,
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      test.is( self.provider.isHardLink( dstPath ) );
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
      return null;
    })
  })

  //

  .ifNoErrorThen( () =>
  {
    test.case = 'dst is a hard link, breakingDstHardLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.hardLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      // breakingDstSoftLink : 0,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      test.is( !self.provider.isHardLink( dstPath ) );
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
      return null;
    })
  })

  //

  .ifNoErrorThen( () =>
  {
    test.case = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.fileWrite( otherPath, otherPath );
    self.provider.hardLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      // breakingDstSoftLink : 1,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      test.is( !self.provider.isHardLink( dstPath ) );
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
      return null;
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
  //   self.provider.softLink( dstPath, srcPath );
  //   return self.provider.fileCopy
  //   ({
  //     dstPath : dstPath,
  //     srcPath : otherPath,
  //     sync : 0,
  //     // breakingDstSoftLink : 0,
  //     breakingDstHardLink : 0
  //   })
  //   .ifNoErrorThen( ( arg/*aaa*/ ) =>
  //   {
  //     test.is( self.provider.isSoftLink( dstPath ) );
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
    self.provider.softLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 0,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( ( arg ) =>
    {
      test.is( self.provider.isSoftLink( dstPath ) );
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
    self.provider.softLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 1,
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( ( arg ) =>
    {
      test.is( !self.provider.isSoftLink( dstPath ) );
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
    self.provider.softLink( dstPath, srcPath );
    return self.provider.fileCopy
    ({
      dstPath : dstPath,
      srcPath : otherPath,
      sync : 0,
      breakingDstSoftLink : 1,
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( ( arg ) =>
    {
      test.is( !self.provider.isSoftLink( dstPath ) );
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

function fileCopySoftLinkResolving( test )
{
  let self = this;

  if( !_.routineIs( self.provider.fileCopy ) )
  {
    test.identical( 1,1 );
    return;
  }

  /*

  resolvingSrcSoftLink : [ 0,1 ]
  resolvingDstSoftLink : [ 0,1 ]
  link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]

  */

  function fileCopy( o )
  {
    let o2 =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1
    }
    _.mapSupplement( o, o2 )
    return self.provider.fileCopy( o );
  }

  let workDir = test.context.makePath( 'written/fileCopySoftLinkResolving' );
  let srcPath = self.provider.path.join( workDir, 'src' );
  let srcPath2 = self.provider.path.join( workDir, 'src2' );
  let dstPath = self.provider.path.join( workDir, 'dst' );
  let dstPath2 = self.provider.path.join( workDir, 'dst2' );
  let srcPathTerminal = self.provider.path.join( workDir, 'srcTerminal' );
  let dstPathTerminal = self.provider.path.join( workDir, 'dstTerminal' );

  /**/

  test.open( 'normal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isTerminal( dstPath ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  fileCopy( o )
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'normal' );

  // /**/

  test.open( 'double' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath2 );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  fileCopy( o )
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.identical( self.provider.pathResolveLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  fileCopy( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.identical( self.provider.pathResolveLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'double' );

  /**/

  test.open( 'broken' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'broken' );

  /**/

  test.open( 'self cycled' );

  /* dst does not exist */

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0, allowingMissing : 0, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 0, throwing : 1 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( !self.provider.fileExists( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 1, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, false );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( !self.provider.fileExists( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 1, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, false );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( !self.provider.fileExists( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );

  /* both are self links */

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0, allowingMissing : 0, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0, allowingMissing : 1, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0, allowingMissing : 0, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0, allowingMissing : 1, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  //

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 0, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, null );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 1, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, false );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 0, throwing : 1 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0, allowingMissing : 1, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, false );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  //

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1, allowingMissing : 0, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1, allowingMissing : 1, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1, allowingMissing : 0, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1, allowingMissing : 1, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, true );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  //

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1, allowingMissing : 0, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, null );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1, allowingMissing : 1, throwing : 0 };
  var got = fileCopy( o );
  test.identical( got, false );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1, allowingMissing : 0, throwing : 1 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1, allowingMissing : 1, throwing : 1 };
  var got = fileCopy( o );
  test.identical( got, false );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => fileCopy( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  fileCopy( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isTerminal( dstPath ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileCopy( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPathTerminal ), srcPathTerminal );
  test.shouldThrowError( () => self.provider.fileRead( srcPath ) )
  test.shouldThrowError( () => self.provider.fileRead( dstPath ) )

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  var statSrcPathTerminal1 = self.provider.statRead( srcPathTerminal );
  fileCopy( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  var statSrcPathTerminal2 = self.provider.statRead( srcPathTerminal );
  test.will = 'terminal must not be changed';
  test.identical( statSrcPathTerminal1.mtime.getTime(),statSrcPathTerminal2.mtime.getTime()  )

  test.close( 'links to same file' );
}

//

// function fileCopyAsyncThrowingError( test )
// {
//   var self = this;

//   if( !_.routineIs( self.provider.fileCopy ) )
//   return;

//   var dir = test.context.makePath( 'written/fileCopyAsync' );

//   if( !self.provider.statResolvedRead( dir ) )
//   self.provider.dirMake( dir );

//   var consequence = new _.Consequence().give( null );

//   consequence
//   .ifNoErrorThen( function( arg/*aaa*/ )
//   {
//     test.case = 'async, throwing error';
//     var con = self.provider.fileCopy
//     ({
//       srcPath : test.context.makePath( 'invalid.txt' ),
//       dstPath : test.context.makePath( 'dstPath.txt' ),
//       sync : 0,
//     });

//     return test.shouldThrowError( con );
//   })
//   .ifNoErrorThen( function( arg/*aaa*/ )
//   {
//     test.case = 'async,try rewrite dir';
//     var con = self.provider.fileCopy
//     ({
//       srcPath : test.context.makePath( 'invalid.txt' ),
//       dstPath : test.context.makePath( 'tmp' ),
//       sync : 0,
//     });

//     return test.shouldThrowErrorAsync( con );
//   })
//   .ifNoErrorThen( function( arg/*aaa*/ )
//   {
//     test.case = 'async copy dir';
//     try
//     {
//       self.provider.dirMake
//       ({
//         filePath : test.context.makePath( 'written/fileCopyAsync/copydir' ),
//         sync : 1
//       });
//       self.provider.fileWrite
//       ({
//         filePath : test.context.makePath( 'written/fileCopyAsync/copydir/copyfile.txt' ),
//         data : 'Lorem',
//         sync : 1
//       });
//     } catch ( err ) { }

//     debugger;
//     var con = self.provider.fileCopy
//     ({
//         srcPath : test.context.makePath( 'written/fileCopyAsync/copydir' ),
//         dstPath : test.context.makePath( 'written/fileCopyAsync/copydir2' ),
//         sync : 0,
//     });

//     return test.shouldThrowErrorAsync( con );
//   });

//   return consequence;
// }

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
  test.identical( got, null );

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
  test.identical( got, null );

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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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

  self.provider.dirMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.dirMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.dirMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dstPath );
  self.provider.dirMake( srcPath );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  //

  test.case = 'rename moving to other existing dir';

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.dirMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.dirRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.dirMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.dirRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.dirMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.dirRead( _.path.dir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.dirMake( _.path.dir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.dirRead( _.path.dir( dstPath ) );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
    rewritingDirs : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
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
    rewritingDirs : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

}

//

function fileRenameSync2( test )
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

  test.open( 'rewriting terminal' );

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );

  test.shouldThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 0,
      throwing : 1
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( srcRead, srcPath );
  test.identical( dstRead, dstPath );

  //

  test.shouldThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 1,
      throwing : 1
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( srcRead, srcPath );
  test.identical( dstRead, dstPath );

  //

  test.mustNotThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 0,
      throwing : 0
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( srcRead, srcPath );
  test.identical( dstRead, dstPath );

  //

  test.mustNotThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 1,
      throwing : 0
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( srcRead, srcPath );
  test.identical( dstRead, dstPath );

  //

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    rewritingDirs : 0,
    throwing : 1
  })
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( dstRead, srcPath );

  //

  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    rewritingDirs : 1,
    throwing : 1
  })
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( dstRead, srcPath );

  test.close( 'rewriting terminal' );

  /**/

  test.open( 'rewriting directory' );

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );

  test.shouldThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 0,
      throwing : 1
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.isDir( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  test.shouldThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 1,
      throwing : 1
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.isDir( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  test.mustNotThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 0,
      throwing : 0
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.isDir( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  test.mustNotThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 0,
      rewritingDirs : 1,
      throwing : 0
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.isDir( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      rewritingDirs : 0,
      throwing : 1
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( self.provider.isDir( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
  self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    rewritingDirs : 1,
    throwing : 1
  })
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( dstRead, srcPath );

  test.close( 'rewriting directory' );

  /**/

  test.open( 'making directory' );

  dstPath = self.provider.path.join( dstPath, 'dstFile' );
  self.provider.filesDelete( dir );

  //

  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      rewritingDirs : 1,
      makingDirectory : 0,
      throwing : 1
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( !self.provider.fileExists( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  self.provider.fileWrite( srcPath, srcPath );
  test.mustNotThrowError( () =>
  {
    self.provider.fileRename
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      rewritingDirs : 1,
      makingDirectory : 0,
      throwing : 0
    })
  })
  test.is( self.provider.fileExists( srcPath ) );
  test.is( !self.provider.fileExists( dstPath ) );
  var srcRead = self.provider.fileRead( srcPath );
  test.identical( srcRead, srcPath );

  //

  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    rewritingDirs : 1,
    makingDirectory : 1,
    throwing : 1
  })
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.fileExists( dstPath ) );
  var dstRead = self.provider.fileRead( dstPath );
  test.identical( dstRead, srcPath );

  test.close( 'making directory' );
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
  self.provider.dirMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToFile ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.fileRead( dstPath );
  test.identical( got, pathToFile );

  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.dirMakeForFile( dstPath );
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
  self.provider.dirMakeForFile( dstPath )
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
  self.provider.dirMakeForFile( dstPath )
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
  self.provider.dirMakeForFile( dstPathResolved );
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
  self.provider.dirMakeForFile( dstPathResolved );
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
  self.provider.dirMakeForFile( dstPathResolved );
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
  self.provider.dirMakeForFile( dstPathResolved );
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
  self.provider.dirMakeForFile( dstPathResolved );
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
  self.provider.dirMakeForFile( dstPathResolved );
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
  var got = self.provider.dirRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = './../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.dirRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = '../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dst/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.dirMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.dirRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = './../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/dst/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.dirMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.dirRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = '../../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/a/b/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.dirMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.dirRead( dstPath );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = './../../../dir';
  var dstPath = test.context.makePath( 'written/fileRenameRelativePath/a/b/dstDir' );
  var fileInDirPath = self.provider.path.join( testDir, 'dir', 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.dirMakeForFile( dstPath );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( pathToDir ) )
  test.is( self.provider.fileExists( dstPath ) );
  var got = self.provider.dirRead( dstPath );
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
  var got = self.provider.dirRead( dstPathResolved );
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
  var got = self.provider.dirRead( dstPathResolved );
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
  var got = self.provider.dirRead( dstPathResolved );
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
  var got = self.provider.dirRead( dstPathResolved );
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
  var got = self.provider.dirRead( dstPathResolved );
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
  var got = self.provider.dirRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../a/b/dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.dirRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../a/b/dstDir';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  var fileInDirPath = self.provider.path.join( pathToDir, 'fileInDir' );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( fileInDirPath, fileInDirPath );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.fileRename( dstPath, srcPath );
  test.is( !self.provider.fileExists( srcPath ) )
  test.is( self.provider.fileExists( dstPathResolved ) );
  var got = self.provider.dirRead( dstPathResolved );
  test.identical( got, [ 'fileInDir' ] );

  test.close( 'dst - relative path to a dir' );

  test.open( 'same paths' );

  pathToFile =  test.context.makePath( 'written/fileRenameRelativePath/file' )

  var srcPath = pathToFile;
  var dstPath = '../file';
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  var statBefore = self.provider.statResolvedRead( pathToFile );
  var got = self.provider.fileRename( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.statResolvedRead( pathToFile );
  test.identical( statBefore.mtime.getTime(), statNow.mtime.getTime() );

  var srcPath = '../file';
  var dstPath = pathToFile;
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  var statBefore = self.provider.statResolvedRead( pathToFile );
  var got = self.provider.fileRename( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.statResolvedRead( pathToFile );
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


  var consequence = new _.Consequence().give( null );

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'src not exist';
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      test.identical( got, null );
      return got;
    });
  })

  /**/

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
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
      test.identical( got, null );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'rename in same directory,dst not exist';
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'rename with rewriting in same directory';
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });

  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });

  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'rename dir, dst not exist';
    self.provider.filesDelete( dir );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.dirMake( srcPath );
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dstPath );
    self.provider.dirMake( srcPath );
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dstPath );
    self.provider.dirMake( srcPath );
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dstPath );
    self.provider.dirMake( srcPath );
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'rename moving to other existing dir';
    dstPath = test.context.makePath( 'written/fileRenameAsync/dir/dst' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.dirMake( _.path.dir( dstPath ) );
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
      var files = self.provider.dirRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.dirMake( _.path.dir( dstPath ) );
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
      var files = self.provider.dirRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.dirMake( _.path.dir( dstPath ) );
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
      var files = self.provider.dirRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.dirMake( _.path.dir( dstPath ) );
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
      var files = self.provider.dirRead( _.path.dir( dstPath ) );
      test.identical( files, [ 'dst' ] );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'rename moving to not existing dir';
    dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .doThen( function( err, got )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .doThen( function( err, got )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dst is not empty dir';
    dstPath = test.context.makePath( 'written/fileRenameAsync/dir/dst' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      rewritingDirs : 1,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true )
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dir' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      rewritingDirs : 1,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true )
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dir' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dir','src' ] );
      return got;
    });
  })

  //src is equal to dst

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return got;
    });
  })

  return consequence;
}

//

function fileRenameActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRenameAct ) )
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
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })

  //

  test.case = 'no src';
  self.provider.filesDelete( dir );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })

  //

  test.case = 'no src, dst exists';
  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );

  //

  test.case = 'src : directory, no dst';
  self.provider.filesDelete( dir );
  self.provider.dirMake( srcPath );
  self.provider.fileRenameAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
  })
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] )

  //

  test.case = 'no structure before dst';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  //

  test.case = 'src - terminal, dst - directory';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dstDir', 'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.dirMake( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    })
  })
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dstDir', 'src' ] );
  var files = self.provider.dirRead( dstPath );
  test.identical( files, [] );
  //

  test.case = 'simple rename';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileRenameAct
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
  });
  var files = self.provider.dirRead( dir );
  var expected = [ 'dst' ];
  test.identical( files, expected );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );

  //

  test.case = 'dst exists';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    self.provider.fileRenameAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    });
    var files = self.provider.dirRead( dir );
    var expected = [ 'dst' ];
    test.identical( files, expected );
    var dstFile = self.provider.fileRead( dstPath );
    test.identical( srcPath, dstFile );
  }
  else
  {
    test.shouldThrowError( () =>
    {
      self.provider.fileRenameAct
      ({
        srcPath : srcPath,
        dstPath : dstPath,
        originalSrcPath : srcPath,
        originalDstPath : dstPath,
        sync : 1,
      });
    })
    var files = self.provider.dirRead( dir );
    var expected = [ 'dst','src' ];
    test.identical( files, expected );
    var srcFile = self.provider.fileRead( srcPath );
    test.identical( srcFile, srcPath );
    var dstFile = self.provider.fileRead( dstPath );
    test.identical( dstFile, dstPath );
  }

  //

  var dir = test.context.makePath( 'written/' + test.name );
  var srcPath = _.path.join( dir, 'src' );
  var dstPath = _.path.join( dir, 'dst' );
  var otherPath = _.path.join( dir, 'other' );

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
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct( o );
  })
  test.is( !self.provider.fileExists( dstPath ) );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.fileRenameAct( o );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
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
    sync : 1
  }

  var expected = _.mapExtend( null, o );
  expected.srcPath = self.provider.path.nativize( o.srcPath );
  expected.dstPath = self.provider.path.nativize( o.dstPath );

  self.provider.fileRenameAct( o );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( srcPath, dstFile );
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.case = 'should assert that path is absolute';
  var srcPath = './dst';
  var dstPath = _.path.join( dir,'dst' );

  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      sync : 1,
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
  var srcPath = _.path.join( dir,'src' );;
  var dstPath = _.path.join( dir,'dst' );

  /* sync option is missed */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct( o );
  });

  /* redundant option */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct( o );
  });

  //

  test.case = 'should expect normalized path, but not nativized';
  var srcPath = dir + '\\src';
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = dir + '\\dst';
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct( o );
  })
  self.provider.filesDelete( dir );

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
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.fileRenameAct( o );
  })
  test.identical( o.srcPath, expected.srcPath );
}

//

function fileRenameSoftLinkResolving( test )
{
  let self = this;

  if( !_.routineIs( self.provider.fileRename ) )
  {
    test.identical( 1,1 );
    return;
  }

  /*

  resolvingSrcSoftLink : [ 0,1 ]
  resolvingDstSoftLink : [ 0,1 ]
  link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]

  */

  function fileRename( o )
  {
    let o2 =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1
    }
    _.mapSupplement( o, o2 )
    return self.provider.fileRename( o );
  }

  let workDir = test.context.makePath( 'written/fileRenameSoftLinkResolving' );
  let srcPath = self.provider.path.join( workDir, 'src' );
  let srcPath2 = self.provider.path.join( workDir, 'src2' );
  let dstPath = self.provider.path.join( workDir, 'dst' );
  let dstPath2 = self.provider.path.join( workDir, 'dst2' );
  let srcPathTerminal = self.provider.path.join( workDir, 'srcTerminal' );
  let dstPathTerminal = self.provider.path.join( workDir, 'dstTerminal' );

  /**/

  test.open( 'normal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.fileExists( srcPathTerminal ) );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isTerminal( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.fileExists( srcPathTerminal ) );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( !self.provider.fileExists( srcPathTerminal ) );
  test.is( self.provider.fileExists( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.fileRead( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null )

  test.close( 'normal' );

  /**/

  test.open( 'double' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.fileExists( srcPathTerminal ) );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath2 );
  test.identical( self.provider.pathResolveLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath2 ), null );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.identical( self.provider.pathResolveLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveLink( dstPath2 ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), srcPathTerminal );

  test.close( 'double' );

  /**/

  test.open( 'broken' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => fileRename( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => fileRename( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'broken' );

  /**/

  test.open( 'self cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => fileRename( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../src' );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => fileRename( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPath );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => fileRename( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.pathResolveLink( dstPath2 ), srcPath );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => fileRename( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  fileRename( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( !self.provider.fileExists( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isTerminal( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( !self.provider.fileExists( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPathTerminal ), srcPathTerminal );
  test.shouldThrowError( () => self.provider.fileRead( srcPath ) )
  test.shouldThrowError( () => self.provider.fileRead( dstPath ) )

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  fileRename( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'links to same file' );
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

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
  var stat = self.provider.statResolvedRead( filePath );
  test.identical( stat, null );

  /**/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 1
  });
  var stat = self.provider.statResolvedRead( filePath );
  test.identical( stat, null );

  //

  test.case = 'removing empty folder';
  var filePath = test.context.makePath( 'written/fileDelete/folder');

  /**/

  self.provider.dirMake( filePath );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 0
  });
  var stat = self.provider.statResolvedRead( filePath );
  test.identical( stat, null );

  /**/

  self.provider.dirMake( filePath );
  self.provider.fileDelete
  ({
    filePath : filePath,
    sync : 1,
    throwing : 1
  });
  var stat = self.provider.statResolvedRead( filePath );
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
  var stat = self.provider.statResolvedRead( folder );
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

  var stat = self.provider.statResolvedRead( folder );
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
    // var stat = self.provider.statResolvedRead( '.' );
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
    var stat = self.provider.statResolvedRead( '/' );
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
  // self.provider.hardLink( dst, filePath );
  // self.provider.fileDelete( dst )
  // var stat = self.provider.statResolvedRead( dst );
  // test.identical( stat, null );
  // var stat = self.provider.statResolvedRead( filePath );
  // test.is( !!stat );
  // self.provider.fieldReset( 'resolvingHardLink', 1 );

  // test.case = 'delete soft link, resolvingHardLink 0';
  // self.provider.filesDelete( dir );
  // self.provider.fieldSet( 'resolvingHardLink', 0 );
  // var dst = _.path.join( dir, 'link' );
  // self.provider.fileWrite( filePath, ' ');
  // self.provider.hardLink( dst, filePath );
  // self.provider.fileDelete( dst )
  // var stat = self.provider.statResolvedRead( dst );
  // test.identical( stat, null );
  // var stat = self.provider.statResolvedRead( filePath );
  // test.is( !!stat );
  // self.provider.fieldReset( 'resolvingHardLink', 0 );

  //

  if( !test.context.symlinkIsAllowed() )
  return;

  test.case = 'delete soft link, resolvingSoftLink 1';
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var dst = _.path.join( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.softLink( dst, filePath );
  self.provider.fileDelete( dst )
  var stat = self.provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = self.provider.statResolvedRead( filePath );
  test.is( !!stat );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

  test.case = 'delete soft link, resolvingSoftLink 0';
  self.provider.filesDelete( dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var dst = _.path.join( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.softLink( dst, filePath );
  self.provider.fileDelete( dst )
  var stat = self.provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = self.provider.statResolvedRead( filePath );
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
  var stat = self.provider.statResolvedRead( srcPath );
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
  var stat = self.provider.statResolvedRead( srcPath );
  test.is( !stat );

  //

  test.case = 'src is empty dir';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.dirMake( srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  self.provider.fileDeleteAct( o );
  var stat = self.provider.statResolvedRead( srcPath );
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
  var stat = self.provider.statResolvedRead( dir );
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
  var stat = self.provider.statResolvedRead( srcPath );
  test.is( !stat );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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
  var stat = self.provider.statResolvedRead( srcPath );
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

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'removing not existing path';
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'removing file';
    filePath = test.context.makePath( 'written/fileDeleteAsync/file.txt');
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath,' ' );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var stat = self.provider.statResolvedRead( filePath );
      test.identical( stat, null );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath,' ' );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var stat = self.provider.statResolvedRead( filePath );
      test.identical( stat, null );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'removing existing empty folder';
    filePath = test.context.makePath( 'written/fileDeleteAsync/folder');
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.dirMake( filePath );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var stat = self.provider.statResolvedRead( filePath );
      test.identical( stat, null );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.dirMake( filePath );
    var con = self.provider.fileDelete
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var stat = self.provider.statResolvedRead( filePath );
      test.identical( stat, null );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'removing existing folder with file';
    filePath = test.context.makePath( 'written/fileDeleteAsync/folder/file.txt');
    return null;

  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    .doThen( function( err, arg )
    {
      var stat = self.provider.statResolvedRead( folder );
      test.is( !!stat );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      var stat = self.provider.statResolvedRead( folder );
      test.is( !!stat );
      test.identical( got, null )
      return got;
    });
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    if( self.provider.constructor.name !== 'wFileProviderExtract' )
    return null;

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
      let con = self.provider.fileDelete
      ({
        filePath : '/',
        sync : 0,
        throwing : 1
      });
      return test.shouldThrowError( con );
    })
  })
  .doThen( () =>
  {
    filePath = _.path.join( dir, 'file' );
    return null;
  })
  // .ifNoErrorThen( ( arg/*aaa*/ ) =>
  // {
  //   test.case = 'delete hard link, resolvingHardLink 1';
  //   self.provider.filesDelete( dir );
  //   self.provider.fieldSet( 'resolvingHardLink', 1 );
  //   var dst = _.path.join( dir, 'link' );
  //   self.provider.fileWrite( filePath, ' ');
  //   self.provider.hardLink( dst, filePath );
  //   return self.provider.fileDelete
  //   ({
  //     filePath : dst,
  //     sync : 0,
  //     throwing : 1
  //   })
  //   .ifNoErrorThen( ( arg/*aaa*/ ) =>
  //   {
  //     var stat = self.provider.statResolvedRead( dst );
  //     test.identical( stat, null );
  //     var stat = self.provider.statResolvedRead( filePath );
  //     test.is( !!stat );
  //     self.provider.fieldReset( 'resolvingHardLink', 1 );
  //   })
  // })
  // .ifNoErrorThen( ( arg/*aaa*/ ) =>
  // {
  //   test.case = 'delete hard link, resolvingHardLink 0';
  //   self.provider.filesDelete( dir );
  //   self.provider.fieldSet( 'resolvingHardLink', 0 );
  //   var dst = _.path.join( dir, 'link' );
  //   self.provider.fileWrite( filePath, ' ');
  //   self.provider.hardLink( dst, filePath );
  //   return self.provider.fileDelete
  //   ({
  //     filePath : dst,
  //     sync : 0,
  //     throwing : 1
  //   })
  //   .ifNoErrorThen( ( arg/*aaa*/ ) =>
  //   {
  //     var stat = self.provider.statResolvedRead( dst );
  //     test.identical( stat, null );
  //     var stat = self.provider.statResolvedRead( filePath );
  //     test.is( !!stat );
  //     self.provider.fieldReset( 'resolvingHardLink', 0 );
  //   })
  // });

  if( !test.context.symlinkIsAllowed() )
  return consequence;

  consequence.ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    var filePath = _.path.join( dir, 'file' );
    test.case = 'delete soft link, resolvingSoftLink 1';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    var dst = _.path.join( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.softLink( dst, filePath );
    return self.provider.fileDelete
    ({
      filePath : dst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      var stat = self.provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = self.provider.statResolvedRead( filePath );
      test.is( !!stat );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
      return null;
    })

  })
  .ifNoErrorThen( ( arg/*aaa*/ ) =>
  {
    test.case = 'delete soft link, resolvingSoftLink 0';
    self.provider.filesDelete( dir );
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var dst = _.path.join( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.softLink( dst, filePath );
    return self.provider.fileDelete
    ({
      filePath : dst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      var stat = self.provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = self.provider.statResolvedRead( filePath );
      test.is( !!stat );
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
      return null;
    })
  })

  return consequence;

}

//

function statResolvedReadSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.statReadAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/statResolvedRead' );
  var filePath,expected;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  //

  filePath = test.context.makePath( 'read/statResolvedRead/src.txt' );
  self.provider.fileWrite( filePath, 'Excepteur sint occaecat cupidatat non proident' );
  test.case = 'synchronous file stat default options';
  expected = 46;

  /**/

  var got = self.provider.statResolvedRead( filePath );
  if( _.bigIntIs( got.size ) )
  expected = BigInt( expected );
  test.identical( got.size, expected );

  /**/

  var got = self.provider.statResolvedRead
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

  var got = self.provider.statResolvedRead
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
    var got = self.provider.statResolvedRead
    ({
      sync : 1,
      filePath : filePath,
      throwing : 1
    });
  });
}

//

function statReadActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.statReadAct ) )
  {
    test.case = 'statReadAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'statReadActSync' );

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
  var stat = self.provider.statReadAct( o );
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
  var stat = self.provider.statReadAct( o );
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
  test.shouldThrowError( () => self.provider.statReadAct( o ) )
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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
  var stat = self.provider.statReadAct( o );
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
    self.provider.softLink( dstPath, srcPath );
    var o =
    {
      filePath : dstPath,
      sync : 1,
      throwing : 0,
      resolvingSoftLink : 1
    }
    var stat = self.provider.statReadAct( o );
    test.is( !!stat );
    test.is( !stat.isSoftLink() );
    self.provider.filesDelete( dir );

    //

    test.case = 'src is a soft link';
    var srcPath = _.path.join( dir,'src' );
    var dstPath = _.path.join( dir,'dst' );
    self.provider.fileWrite( srcPath, srcPath );
    self.provider.softLink( dstPath, srcPath );
    var o =
    {
      filePath : dstPath,
      sync : 1,
      throwing : 0,
      resolvingSoftLink : 0
    }
    var stat = self.provider.statReadAct( o );
    test.is( !!stat );
    test.is( stat.isSoftLink() );
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
      self.provider.statReadAct
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
    self.provider.statReadAct
    ({
      filePath : srcPath,
      sync : 1,
      throwing : 1,
      resolvingSoftLink : 1
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
  var srcPath = _.path.join( dir,'src' );

  /* sync option is missed */

  test.shouldThrowError( () =>
  {
    self.provider.statReadAct
    ({
      filePath : srcPath,
      throwing : 0,
      resolvingSoftLink : 1
    });
  });

  //

  test.shouldThrowError( () =>
  {
    self.provider.statReadAct
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
    self.provider.statReadAct( o );
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
    self.provider.statReadAct( o );
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
        self.provider.statReadAct( o );
      })
    }
    else
    {
      test.mustNotThrowError( () =>
      {
        self.provider.statReadAct( o );
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
      self.provider.statReadAct( o );
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
    self.provider.statReadAct( o );
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
    self.provider.statReadAct( o );
  })
  test.identical( o.filePath, expected.filePath );
}

//

function statResolvedReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.statReadAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/statResolvedReadAsync' );
  var filePath,expected;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );

  //

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    filePath = test.context.makePath( 'read/statResolvedReadAsync/src.txt' );
    self.provider.fileWrite( filePath, 'Excepteur sint occaecat cupidatat non proident' );
    test.case = 'synchronous file stat default options';
    expected = 46;
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.statResolvedRead
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
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.statResolvedRead
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
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'invalid path';
    filePath = test.context.makePath( '///bad path///test.txt' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.statResolvedRead
    ({
      sync : 0,
      filePath : filePath,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = null;
      test.identical( got, expected );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.statResolvedRead
    ({
      sync : 0,
      filePath : filePath,
      throwing : 1
    });

    return test.shouldThrowError( con )
  });

  return consequence;
}

//

function dirMakeSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.dirMakeAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  if( Config.platform === 'browser' )
  if( self.provider.filesTree )
  self.provider.filesTree = {};

  var dir = test.context.makePath( 'written/dirMake' );
  var filePath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  //

  test.case = 'synchronous mkdir';
  filePath = test.context.makePath( 'written/dirMake/make_dir' );

  /**/

  self.provider.dirMake( filePath );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'make_dir' ] );

  //

  test.case = 'synchronous mkdir force';
  self.provider.filesDelete( filePath );
  filePath = test.context.makePath( 'written/dirMake/make_dir/dir1/' );

  /**/

  self.provider.dirMake
  ({
    filePath : filePath,
    sync : 1,
    recursive : 1
  });
  var files = self.provider.dirRead( _.path.dir( filePath ) );
  test.identical( files, [ 'dir1' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.filesDelete( _.path.dir( filePath ) );
    self.provider.dirMake
    ({
      filePath : filePath,
      sync : 1,
      recursive : 0
    });
  })

  //

  test.case = 'try to rewrite terminal file';
  filePath = test.context.makePath( 'written/dirMake/terminal.txt' );
  self.provider.fileWrite( filePath, ' ' );

  /**/

  self.provider.dirMake
  ({
    filePath : filePath,
    sync : 1,
    recursive : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.dirRead( _.path.dir( filePath ) );
  test.identical( files, [ 'terminal.txt' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
      filePath : filePath,
      sync : 1,
      recursive : 1,
      rewritingTerminal : 0
    });
  })

  //

  test.case = 'try to rewrite empty dir';
  filePath = test.context.makePath( 'written/dirMake/empty' );

  /**/

  self.provider.filesDelete( dir )
  self.provider.dirMake( filePath );
  self.provider.dirMake
  ({
    filePath : filePath,
    sync : 1,
    recursive : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.dirRead( _.path.dir( filePath ) );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.filesDelete( dir )
  self.provider.dirMake( filePath );
  self.provider.dirMake
  ({
    filePath : filePath,
    sync : 1,
    recursive : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.filesDelete( dir )
  self.provider.dirMake( filePath );
  self.provider.dirMake
  ({
    filePath : filePath,
    sync : 1,
    recursive : 1,
    rewritingTerminal : 0
  });

  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'empty' ] );

  /**/

  self.provider.filesDelete( dir )
  self.provider.dirMake( filePath );
  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
      filePath : filePath,
      sync : 1,
      recursive : 0,
      rewritingTerminal : 1
    });
  });

  /**/

  self.provider.filesDelete( dir )
  self.provider.dirMake( filePath );
  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
      filePath : filePath,
      sync : 1,
      recursive : 0,
      rewritingTerminal : 0
    });
  });

  //

  test.case = 'dir exists, no rewritingTerminal, no force';
  filePath = test.context.makePath( 'written/dirMake/make_dir/' );

  /**/

  // self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
      filePath : filePath,
      sync : 1,
      recursive : 0,
      rewritingTerminal : 0
    });
  });

  //

  test.case = 'try to rewrite folder with files';
  filePath = test.context.makePath( 'written/dirMake/make_dir/file' );
  self.provider.filesDelete( dir );

  /**/

  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 1,
      recursive : 0,
      rewritingTerminal : 1
    });
  });

  /**/

  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 1,
      recursive : 0,
      rewritingTerminal : 0
    });
  });

  /**/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.dirMake
  ({
    filePath : _.path.dir( filePath ),
    sync : 1,
    recursive : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'make_dir' ] );


  //

  test.case = 'folders structure not exist';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/dirMake/dir' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
        filePath : filePath,
        sync : 1,
        recursive : 0,
        rewritingTerminal : 0
    });
  });

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.dirMake
    ({
        filePath : filePath,
        sync : 1,
        recursive : 0,
        rewritingTerminal : 1
    });
  });

  /**/

  self.provider.dirMake
  ({
      filePath : filePath,
      sync : 1,
      recursive : 1,
      rewritingTerminal : 0
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dir' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.dirMake
  ({
      filePath : filePath,
      sync : 1,
      recursive : 1,
      rewritingTerminal : 1
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'dir' ] );
}

//

function dirMakeAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.dirMakeAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  if( Config.platform === 'browser' )
  if( self.provider.filesTree )
  self.provider.filesTree = {};

  var dir = test.context.makePath( 'written/dirMakeAsync' );
  var filePath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );

  //

  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'synchronous mkdir';
    filePath = test.context.makePath( 'written/dirMakeAsync/make_dir' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'make_dir' ] );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'synchronous mkdir force';
    self.provider.filesDelete( filePath );
    filePath = tes
    t.context.makePath( 'written/dirMakeAsync/make_dir/dir1/' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( _.path.dir( filePath ) );
      test.identical( files, [ 'dir1' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( _.path.dir( filePath ) );
    var con = self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'try to rewrite terminal file';
    filePath = test.context.makePath( 'written/dirMakeAsync/terminal.txt' );
    self.provider.fileWrite( filePath, ' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( _.path.dir( filePath ) );
      test.identical( files, [ 'terminal.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 1,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'try to rewrite empty dir';
    filePath = test.context.makePath( 'written/dirMakeAsync/empty' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir )
    self.provider.dirMake( filePath );
    return self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( _.path.dir( filePath ) );
      test.identical( files, [ 'empty' ] );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir )
    self.provider.dirMake( filePath );
    return self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 1,
      rewritingTerminal : 0
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'empty' ] );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir )
    self.provider.dirMake( filePath );
    var con = self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    self.provider.filesDelete( dir )
    self.provider.dirMake( filePath );
    var con = self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'dir exists, no rewritingTerminal, no force';
    filePath = test.context.makePath( 'written/dirMakeAsync/make_dir/' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( filePath );
    self.provider.dirMake( filePath );
    var con = self.provider.dirMake
    ({
      filePath : filePath,
      sync : 0,
      recursive : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  //

  .doThen( function()
  {
    test.case = 'try to rewrite folder with files';
    filePath = test.context.makePath( 'written/dirMakeAsync/make_dir/file' );
    self.provider.filesDelete( dir );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.dirMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      recursive : 0,
      rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.dirMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      recursive : 0,
      rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    return self.provider.dirMake
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      recursive : 1,
      rewritingTerminal : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'make_dir' ] );
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'folders structure not exist';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/dirMakeAsync/dir' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.dirMake
    ({
        filePath : filePath,
        sync : 0,
        recursive : 0,
        rewritingTerminal : 0
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    var con = self.provider.dirMake
    ({
        filePath : filePath,
        sync : 0,
        recursive : 0,
        rewritingTerminal : 1
    });
    return test.shouldThrowError( con );
  })

  /**/

  .doThen( function()
  {
    return self.provider.dirMake
    ({
        filePath : filePath,
        sync : 0,
        recursive : 1,
        rewritingTerminal : 0
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dir' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    return self.provider.dirMake
    ({
        filePath : filePath,
        sync : 0,
        recursive : 1,
        rewritingTerminal : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dir' ] );
      return null;
    });
  })

  return consequence;
}



function fileHashSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileReadAct ) ||  !_.routineIs( self.provider.statReadAct ) || self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    test.identical( 1, 1 );
    return;
  }

  if( Config.platform === 'browser' )
  return;

  var dir = test.context.makePath( 'read/fileHash' );
  var got,filePath,data;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

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

  if( !_.routineIs( self.provider.fileReadAct ) || !_.routineIs( self.provider.statReadAct ) || self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    test.identical( 1, 1 );
    return;
  }

  var dir = test.context.makePath( 'read/fileHashAsync' );
  var got,filePath,data;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  if( Config.platform === 'browser' )
  return;

  var consequence = new _.Consequence().give( null );

  consequence

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'async filehash';
    data = 'Excepteur sint occaecat cupidatat non proident';
    filePath = test.context.makePath( 'read/fileHashAsync/src.txt' );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'invalid path';
    filePath = test.context.makePath( 'invalid.txt' );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg/*aaa*/ )
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

  .ifNoErrorThen( function( arg/*aaa*/ )
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
      return null;
    })

  })

  return consequence;
}

//

function dirReadSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.dirReadAct ) || !_.routineIs( self.provider.statReadAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/dirReadAct' );
  var got,filePath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  //

  test.case = 'synchronous read';
  filePath = test.context.makePath( 'read/dirRead/1.txt' ),

  /**/

  self.provider.fileWrite( filePath,' ' );
  var got = self.provider.dirRead( _.path.dir( filePath ) );
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  /**/

  self.provider.fileWrite( filePath,' ' );
  var got = self.provider.dirRead
  ({
    filePath : _.path.dir( filePath ),
    sync : 1,
    throwing : 1
  })
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  //

  test.case = 'synchronous, filePath points to file';
  filePath = test.context.makePath( 'read/dirRead/1.txt' );

  /**/

  self.provider.fileWrite( filePath,' ' )
  var got = self.provider.dirRead( filePath );
  var expected = [ '1.txt' ];
  test.identical( got, expected );

  /**/

  self.provider.fileWrite( filePath,' ' )
  var got = self.provider.dirRead
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

  var got = self.provider.dirRead( filePath );
  var expected = null;
  test.identical( got, expected );

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.dirRead
    ({
      filePath : filePath,
      sync : 1,
      throwing : 1
    });
  })
}

//

function dirReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.dirReadAct ) || !_.routineIs( self.provider.statReadAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'read/dirReadAsync' );
  var got,filePath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );

  consequence

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'synchronous read';
    filePath = test.context.makePath( 'read/dirReadAsync/1.txt' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.dirRead
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = [ "1.txt" ];
      test.identical( got.sort(), expected.sort() );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.dirRead
    ({
      filePath : _.path.dir( filePath ),
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var expected = [ "1.txt" ];
      test.identical( got.sort(), expected.sort() );
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'synchronous, filePath points to file';
    filePath = test.context.makePath( 'read/dirReadAsync/1.txt' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.dirRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var got = self.provider.dirRead( filePath );
      var expected = [ '1.txt' ];
      test.identical( got, expected );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.dirRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      var got = self.provider.dirRead( filePath );
      var expected = [ '1.txt' ];
      test.identical( got, expected );
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'path not exist';
    filePath = test.context.makePath( 'non_existing_folder' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.dirRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      var expected = null;
      test.identical( got, expected );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.dirRead
    ({
      filePath : filePath,
      sync : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
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
    self.provider.dirMake
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
  self.provider.hardLink( dstPath, srcPath )
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
  test.is( self.provider.isHardLink( dstPath ) );
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
  test.is( self.provider.isHardLink( dstPath ) );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );

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
  self.provider.hardLink( dstPath, srcPath );
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
  test.is( self.provider.isHardLink( dstPath ) );
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
  test.is( self.provider.isHardLink( dstPath ) );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );

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
  self.provider.hardLink( dstPath, srcPath )
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
  test.is( self.provider.isHardLink( dstPath ) );
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
  test.is( self.provider.isHardLink( dstPath ) );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );

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
  self.provider.softLink( dstPath, srcPath )
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
  test.is( self.provider.isSoftLink( dstPath ) );
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
  test.is( self.provider.isSoftLink( dstPath ) );

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
  self.provider.softLink( dstPath, srcPath )
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
  test.is( !self.provider.isSoftLink( dstPath ) );
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
  test.is( !self.provider.isSoftLink( dstPath ) );

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
  self.provider.softLink( dstPath, srcPath )
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
  test.is( !self.provider.isSoftLink( dstPath ) );
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
  test.is( !self.provider.isSoftLink( dstPath ) );

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
  self.provider.softLink( dstPath, srcPath )
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
  test.is( !self.provider.isSoftLink( dstPath ) );
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
  test.is( !self.provider.isSoftLink( dstPath ) );

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
  self.provider.softLink( dstPath, srcPath )
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
  test.is( self.provider.isSoftLink( dstPath ) );
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
  test.is( self.provider.isSoftLink( dstPath ) );

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
  self.provider.softLink( dstPath, srcPath )
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
  test.is( self.provider.isSoftLink( dstPath ) );
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
  test.is( self.provider.isSoftLink( dstPath ) );

}

//

function fileWriteAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileWrite ) )
  return;

  var consequence = new _.Consequence().give( null )
  /*writeMode rewrite*/

  .doThen( () =>
  {
    self.provider.filesDelete( test.context.makePath( 'write_test' ) )
    return self.provider.dirMake( test.context.makePath( 'write_test' ) )
  })

  /*writeMode rewrite*/
  var data = "LOREM"
  consequence
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
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

    return test.shouldThrowError( con );
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

  var con = new _.Consequence().give( null )

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return null;

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
      self.provider.softLink( dstPath, srcPath )
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
      test.is( self.provider.isSoftLink( dstPath ) );
      return null;
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
      test.is( self.provider.isSoftLink( dstPath ) );
      return null;
    })
  })

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return null;

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
      self.provider.softLink( dstPath, srcPath )
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
      test.is( !self.provider.isSoftLink( dstPath ) );
      return null;
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
      test.is( !self.provider.isSoftLink( dstPath ) );
      return null;
    })
  })

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return null;

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
      self.provider.softLink( dstPath, srcPath )
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
      test.is( !self.provider.isSoftLink( dstPath ) );
      return null;
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
      test.is( !self.provider.isSoftLink( dstPath ) );
      return null;
    })
  })

  //

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return null;

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
      self.provider.softLink( dstPath, srcPath )
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
      test.is( !self.provider.isSoftLink( dstPath ) );
      return null;
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
      test.is( !self.provider.isSoftLink( dstPath ) );
      return null;
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
      self.provider.hardLink( dstPath, srcPath )
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
      test.is( self.provider.isHardLink( dstPath ) );
      return null;
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
      test.is( self.provider.isHardLink( dstPath ) );
      test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
      return null;
    })
  })

  //append

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return null;

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
      self.provider.softLink( dstPath, srcPath )
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
      test.is( self.provider.isSoftLink( dstPath ) );
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
      test.is( self.provider.isSoftLink( dstPath ) );
      return null;
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
      self.provider.hardLink( dstPath, srcPath )
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
      test.is( self.provider.isHardLink( dstPath ) );
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
      test.is( self.provider.isHardLink( dstPath ) );
      test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
      return null;

    })

  })

  //prepend

  .doThen( function()
  {
    if( !symlinkIsAllowed )
    return null;

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
      self.provider.softLink( dstPath, srcPath )
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
      test.is( self.provider.isSoftLink( dstPath ) );
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
      test.is( self.provider.isSoftLink( dstPath ) );
      return null;
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
      self.provider.hardLink( dstPath, srcPath )
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
      test.is( self.provider.isHardLink( dstPath ) );
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
      test.is( self.provider.isHardLink( dstPath ) );
      test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
      return null;

    })

  })


  return con;
}

fileWriteLinksAsync.timeOut = 30000;

//

function softLinkSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.softLinkAct ) )
  {
    test.case = 'softLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  if( !test.context.symlinkIsAllowed() )
  {
    test.case = 'System does not allow to create soft links.';
    test.identical( 1, 1 )
    return;
  }

  var dir = test.context.makePath( 'written/softLink' );
  var srcPath,dstPath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  //

  test.case = 'make link sync';
  srcPath  = test.context.makePath( 'written/softLink/link_test.txt' );
  dstPath = test.context.makePath( 'written/softLink/link.txt' );
  self.provider.fileWrite( srcPath, '000' );

  /**/

  self.provider.softLink
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
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.fileRead( dstPath );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  var expected = '000new text';
  test.identical( got, expected );

  //

  test.case = 'make for file that not exist';
  self.provider.filesDelete( dir );
  srcPath  = test.context.makePath( 'written/softLink/no_file.txt' );
  dstPath = test.context.makePath( 'written/softLink/link2.txt' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.softLink
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
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.dirRead( dir );
  test.identical( files, null );

  //

  test.case = 'link already exists';
  srcPath = test.context.makePath( 'written/softLink/link_test.txt' );
  dstPath = test.context.makePath( 'written/softLink/link.txt' );
  self.provider.fileWrite( srcPath, 'abc' );
  self.provider.softLink
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
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.shouldThrowErrorSync( function( )
  {
    self.provider.softLink
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
    self.provider.softLink
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
  srcPath = test.context.makePath( 'written/softLink/link_test.txt' );
  self.provider.fileWrite( srcPath, ' ' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 1,
      allowingMissing : 1
    });
  });
  test.identical( got, true );
  test.is( self.provider.isSoftLink( srcPath ) );

  /**/

  self.provider.fileDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowingMissing : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  test.is( self.provider.isSoftLink( srcPath ) );

  /**/

  self.provider.fileDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      allowingMissing : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  test.is( self.provider.isSoftLink( srcPath ) );

  /**/

  self.provider.fileDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowingMissing : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  test.is( self.provider.isSoftLink( srcPath ) );

  /**/

  self.provider.filesDelete( srcPath );
  test.shouldThrowError( function()
  {
    got = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowingMissing : 0,
      throwing : 1
    });
  });
  test.is( !self.provider.isSoftLink( srcPath ) );

  /**/

  self.provider.filesDelete( srcPath );
  test.mustNotThrowError( function()
  {
    got = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      allowingMissing : 0,
      throwing : 0
    });
  });
  test.is( !self.provider.isSoftLink( srcPath ) );

  //

  test.case = 'try make softlink to folder';
  self.provider.filesDelete( dir );
  srcPath = test.context.makePath( 'written/softLink/link_test' );
  dstPath = test.context.makePath( 'written/softLink/link' );
  self.provider.dirMake( srcPath );

  /**/

  self.provider.softLink
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link', 'link_test' ]  );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.softLink
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
  self.provider.softLink
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 0,
    sync : 1,
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link', 'link_test' ]  );

  //

  test.open( 'allowingMissing' );

  self.provider.softLink
  ({
    srcPath : '../link_test',
    dstPath : srcPath,
    rewriting : 1,
    rewritingDirs : 1,
    throwing : 1,
    sync : 1,
    allowingMissing : 1
  });

  // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
  //   test.shouldThrowError(() =>
  //   {
  //     self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 });
  //   })
  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 });
  //   test.identical( got, srcPath )
  // }
  test.mustNotThrowError(() =>
  {
    self.provider.pathResolveLink
    ({
      filePath : srcPath,
      resolvingSoftLink : 1,
      allowingMissing : 1,
      throwing : 1
    });
  })

  test.mustNotThrowError(() =>
  {
    self.provider.pathResolveLink
    ({
      filePath : srcPath,
      resolvingSoftLink : 1,
      allowingMissing : 1,
      throwing : 0
    });
  })

  test.mustNotThrowError(() =>
  {
    self.provider.pathResolveLink
    ({
      filePath : srcPath,
      resolvingSoftLink : 1,
      allowingMissing : 0,
      throwing : 0
    });
  })

  test.shouldThrowError(() =>
  {
    self.provider.pathResolveLink
    ({
      filePath : srcPath,
      resolvingSoftLink : 1,
      allowingMissing : 0,
      throwing : 1
    });
  })

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.softLink
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 0,
    sync : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
  // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      });
    })

    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, notExistingPath );
  // }


  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.softLink
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 0,
    throwing : 1,
    sync : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
 // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      });
    })
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, notExistingPath );
  // }

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.softLink
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 0,
    throwing : 0,
    sync : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
 // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      });
    })
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, notExistingPath );
  // }

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  self.provider.softLink
  ({
    srcPath : notExistingPath,
    dstPath : dstPath,
    rewriting : 1,
    throwing : 1,
    sync : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
// if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      });
    })
    self.provider.fileWrite( notExistingPath, notExistingPath );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, notExistingPath );
  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, notExistingPath );
  // }

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.mustNotThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
      allowingMissing : 0
    });
  })

  test.is( !self.provider.isSoftLink( dstPath ) );

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
      allowingMissing : 0
    });
  })

  test.is( !self.provider.isSoftLink( dstPath ) );

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.mustNotThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
      allowingMissing : 0
    });
  })

  test.is( !self.provider.isSoftLink( dstPath ) );

  //

  var notExistingPath = test.context.makePath( 'written/softLink/notExisting' );
  self.provider.filesDelete( notExistingPath );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : notExistingPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
      allowingMissing : 0
    });
  })

  test.is( !self.provider.isSoftLink( dstPath ) );

  //

  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
      allowingMissing : 1
    });
  })

  //

  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
      allowingMissing : 0
    });
  })

  //

  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 1,
      allowingMissing : 0
    });
  })

  //

  test.mustNotThrowError( () =>
  {
    self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 0,
      sync : 1,
      allowingMissing : 0
    });
  })

  test.close( 'allowingMissing' );

  /**/

  test.mustNotThrowError( function()
  {
    self.provider.softLink
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

function softLinkAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.softLinkAct ) )
  {
    test.case = 'softLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  if( !test.context.symlinkIsAllowed() )
  {
    test.case = 'System does not allow to create soft links.';
    test.identical( 1, 1 )
    return;
  }

  var dir = test.context.makePath( 'written/softLinkAsync' );
  var srcPath,dstPath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );
  consequence

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'make link async';
    srcPath  = test.context.makePath( 'written/softLinkAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/softLinkAsync/link.txt' );
    self.provider.fileWrite( srcPath, '000' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      self.provider.fileWrite
      ({
        filePath : srcPath,
        writeMode : 'append',
        data : 'new text',
        sync : 1
      });
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      self.provider.fieldSet( 'resolvingSoftLink', 1 );
      var got = self.provider.fileRead( dstPath );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
      var expected = '000new text';
      test.identical( got, expected );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'make for file that not exist';
    self.provider.filesDelete( dir );
    srcPath  = test.context.makePath( 'written/softLinkAsync/no_file.txt' );
    dstPath = test.context.makePath( 'written/softLinkAsync/link2.txt' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.softLink
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
    var con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, null );
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'link already exists';
    srcPath = test.context.makePath( 'written/softLinkAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/softLinkAsync/link.txt' );
    self.provider.fileWrite( srcPath, 'abc' );
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.softLink
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
    var con = self.provider.softLink
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
  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/softLinkAsync/link_test.txt' );
    self.provider.fileWrite( srcPath, ' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.softLink
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
      test.is( self.provider.isSoftLink( srcPath ) );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( srcPath );
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 0,
      allowingMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.isSoftLink( srcPath ) );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( srcPath );
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      rewriting : 1,
      allowingMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.isSoftLink( srcPath ) );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( srcPath );
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      allowingMissing : 1,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      test.is( self.provider.isSoftLink( srcPath ) );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( srcPath );
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      allowingMissing : 0,
      rewriting : 0,
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, false );
      test.is( !self.provider.isSoftLink( srcPath ) );
      return null;
    })
  })

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( srcPath );
    var con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 0,
      allowingMissing : 0,
      rewriting : 0,
      throwing : 1
    })
    return test.shouldThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.is( !self.provider.isSoftLink( srcPath ) );
      return null;
    })
  })

  //

  .doThen( function()
  {
    test.case = 'try make hardlink for folder';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/softLinkAsync/link_test' );
    dstPath = test.context.makePath( 'written/softLinkAsync/link' );
    self.provider.dirMake( srcPath );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link', 'link_test' ]  );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.softLink
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
    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link', 'link_test' ]  );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.open( 'allowingMissing' );
    return null;
  })

  //

  .doThen( () =>
  {

    return self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
      allowingMissing : 1
    })
    .doThen( () =>
    {
      var got = self.provider.pathResolveLink({ filePath : srcPath, resolvingSoftLink : 1 });
      test.identical( got, srcPath )
      return null;
    })

  })

  .doThen( () =>
  {
    let con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
      allowingMissing : 1
    });
    return test.shouldThrowError( con );

  })

  .doThen( () =>
  {
    let con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
      allowingMissing : 0
    });
    return test.shouldThrowError( con );
  })

  .doThen( () =>
  {
    let con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 1,
      sync : 0,
      allowingMissing : 0
    });
    return test.shouldThrowError( con );
  })

  .doThen( () =>
  {
    let con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 0,
      throwing : 0,
      sync : 0,
      allowingMissing : 0
    });
    return test.mustNotThrowError( con );
  })

  .doThen( () =>
  {
    let con = self.provider.softLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
      allowingMissing : 0
    });
    return test.mustNotThrowError( con );
  })

  .doThen( () => test.close( 'allowingMissing' ) )

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.softLink
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

function softLinkRelativePath( test )
{
  var self = this;

  if( !_.routineIs( self.provider.softLinkAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/softLinkRelativePath' );
  let pathToDir = test.context.makePath( 'written/softLinkRelativePath/dir' );
  let pathToFile = test.context.makePath( 'written/softLinkRelativePath/file' );

  test.open( 'src - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './.././a/b/c';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.././a/b/c';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.\\..\\.\\a\\b\\c';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\.\\a\\b\\c';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../a/b/c/../..';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../a/b/c/../..';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.\\..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToFile2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  test.shouldThrowError( () => self.provider.softLink( dstPath, srcPath ) );
  test.is( !self.provider.isSoftLink( dstPath ) );

  test.close( 'src - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.dirMake( pathToDir );

  var srcPath = '../dir';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../dir';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../dir';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir/dstDirLink' );
  self.provider.filesDelete( _.path.dir( dstPath ) );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../dir';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir/dstDirLink' );
  self.provider.filesDelete( _.path.dir( dstPath ) );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../../../dir';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a/dir' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/a/b/c/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = './../../../dir';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a/dir' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/a/b/c/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  //

  var srcPath = './.././a/b/c';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.././a/b/c';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '.\\..\\.\\a\\b\\c';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\.\\a\\b\\c';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a/b/c' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );


  var srcPath = './../a/b/c/../..';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '../a/b/c/../..';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );


  var srcPath = '.\\..\\a\\b\\c\\..\\..';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );


  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToDir2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( _.path.dir( pathToDir2 ) );
  self.provider.dirMake( pathToDir2 );
  self.provider.fileWrite( _.path.join( pathToDir2, 'fileInDir' ) , 'fileInDir' );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got, pathToDir2 );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.dirRead({ filePath : dstPath });
  test.identical( got,[ 'fileInDir' ] );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, _.path.normalize( srcPath ) );

  var srcPath = '..\\a\\b\\c\\..\\..';
  var pathToFile2 = test.context.makePath( 'written/softLinkRelativePath/a' );
  self.provider.filesDelete( pathToFile2 );
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath );
  test.shouldThrowError( () => self.provider.softLink( dstPath, srcPath ) );
  test.is( !self.provider.isSoftLink( dstPath ) );

  test.close( 'src - relative path to a dir' );

  test.open( 'dst - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToFile );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'dst - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.dirMake( pathToDir );

  var srcPath = pathToDir;
  var dstPath = '../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.dirRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.dirRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.dirRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../../dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.dirRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = '../a/b/dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.dirRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  var srcPath = pathToDir;
  var dstPath = './../a/b/dstDir'
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.pathResolveLink({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got, pathToDir );
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  var got = self.provider.dirRead({ filePath : dstPathResolved });
  test.identical( got,[ 'fileInDir' ] );

  test.close( 'dst - relative path to a dir' );

  //

  test.open( 'allowingMissing on, relative path to src' );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.dirMakeForFile( dstPath );
  self.provider.softLink
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
  // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      })
    });
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );

  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, pathToFile );
  // }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.dirMakeForFile( dstPath );
  self.provider.softLink
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 0,
    throwing : 0,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
 // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      })
    });
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );

  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, pathToFile );
  // }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.dirMakeForFile( dstPath );
  self.provider.softLink
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 0,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
  // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      })
    });
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );

  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, pathToFile );
  // }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  self.provider.dirMakeForFile( dstPath );
  self.provider.softLink
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 0,
    throwing : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
  // if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  // {
    test.shouldThrowError( () =>
    {
      self.provider.pathResolveLink
      ({
        filePath : dstPath,
        resolvingSoftLink : 1,
        allowingMissing : 0,
        throwing : 1
      })
    });
    self.provider.fileWrite( pathToFile, pathToFile );
    var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
    test.identical( got, pathToFile );

  // }
  // else
  // {
  //   var got = self.provider.pathResolveLink({ filePath : dstPath, resolvingSoftLink : 1 });
  //   test.identical( got, pathToFile );
  // }
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );

  test.close( 'allowingMissing on, relative path to src' );

  //

  test.open( 'allowingMissing on, same path' );

  var srcPath = '../file';
  var dstPath = pathToFile;
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.softLink
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPath ) );
  test.shouldThrowError( () =>
  {
    self.provider.pathResolveLink
    ({
      filePath : dstPath,
      resolvingSoftLink : 1,
      allowingMissing : 0,
      throwing : 1
    })
  });
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );

  //

  var srcPath = pathToFile;
  var dstPath = '../file';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  self.provider.softLink
  ({
    dstPath : dstPath,
    srcPath : srcPath,
    rewriting : 1,
    throwing : 1,
    allowingMissing : 1
  });
  test.is( self.provider.isSoftLink( dstPathResolved ) );
  test.shouldThrowError( () =>
  {
    self.provider.pathResolveLink
    ({
      filePath : dstPath,
      resolvingSoftLink : 1,
      allowingMissing : 0,
      throwing : 1
    })
  });
  var got = self.provider.pathResolveSoftLink({ filePath : dstPathResolved/*, readLink : 1*/ });
  test.identical( got, srcPath );

  test.close( 'allowingMissing on, same path' );

  //

  test.open( 'allowingMissing off, relative path to src' );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 1,
      allowingMissing : 0
    });
  })
  test.is( !self.provider.isSoftLink( dstPath ) );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.mustNotThrowError( () =>
  {
    self.provider.softLink
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 0,
      throwing : 0,
      allowingMissing : 0
    });
  })
  test.is( !self.provider.isSoftLink( dstPath ) );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.mustNotThrowError( () =>
  {
    self.provider.softLink
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 0,
      allowingMissing : 0
    });
  })
  test.is( !self.provider.isSoftLink( dstPath ) );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/softLinkRelativePath/dstFile' );
  self.provider.filesDelete( testDir );
  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 0,
      throwing : 1,
      allowingMissing : 0
    });
  })
  test.is( !self.provider.isSoftLink( dstPath ) );

  test.close( 'allowingMissing off, relative path to src' );

  test.open( 'allowingMissing off, same path' );

  var srcPath = '../file';
  var dstPath = pathToFile;
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 1,
      allowingMissing : 0
    });
  })
  test.is( !self.provider.isSoftLink( dstPath ) );

  var srcPath = pathToFile;
  var dstPath = '../file';
  var dstPathResolved = self.provider.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );
  test.shouldThrowError( () =>
  {
    self.provider.softLink
    ({
      dstPath : dstPath,
      srcPath : srcPath,
      rewriting : 1,
      throwing : 1,
      allowingMissing : 0
    });
  })
  test.is( !self.provider.isSoftLink( dstPathResolved ) );

  test.close( 'allowingMissing off, same path' );
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

  var consequence = new _.Consequence().give( null );

  if( Config.platform === 'browser' )
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
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
  })
  .ifNoErrorThen( function( arg/*aaa*/ )
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
    return null;
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

function softLinkChain( test )
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
  var dir = test.context.makePath( 'written/softLinkChain' );
  // var dir = path.dirTempOpen( path.join( __dirname, 'softLinkChain' ) ); // xxx

  debugger;

  self.provider.dirMake( path.join( dir, 'a' ) );
  self.provider.fileWrite( path.join( dir, 'x' ), 'x' );
  self.provider.softLink( path.join( dir, 'a/b' ), '..' );
  self.provider.softLink( path.join( dir, 'a/c' ), '../../x' );

  test.description = 'resolve path';

  var expected = path.join( dir, 'a' );
  var got = provider.pathResolveLink( path.join( dir, 'a/b' ) );
  var stat = provider.statResolvedRead( got );
  test.is( !!stat );
  test.identical( got, expected );

  var expected = path.join( dir, 'x' );
  var got = provider.pathResolveLink( path.join( dir, 'a/c' ) );
  var stat = provider.statResolvedRead( got );
  test.is( !!stat );
  test.identical( got, expected );

  var expected = path.join( dir, 'x' );
  var got = provider.pathResolveLinkChain({ filePath : path.join( dir, 'a/b/c' ), resolvingIntermediateDirectories : 1 });
  got = got[ got.length - 1 ];
  var stat = provider.statResolvedRead( got );
  test.is( !!stat );
  test.identical( got, expected );

  // test.description = 'get stat';

  // var abStat = provider.statResolvedRead({ filePath : path.join( dir, 'a/b' ), resolvingSoftLink : 1 });
  // var acStat = provider.statResolvedRead({ filePath : path.join( dir, 'a/c' ), resolvingSoftLink : 1 });
  // var abcStat = provider.statResolvedRead({ filePath : path.join( dir, 'a/b/c' ), resolvingSoftLink : 1 });

  // test.is( !!abStat );
  // test.is( !!acStat );
  // test.is( !!abcStat );

  debugger;
}

//

function softLinkActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.softLinkAct ) )
  {
    test.case = 'softLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'hardLinkActSync' );

  var symlinkIsAllowed = test.context.symlinkIsAllowed();

  if( !symlinkIsAllowed )
  {
    test.case = 'symlinks are not allowed'
    test.identical( 1, 1 )
    return;
  }

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
    type : null,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.softLinkAct( o );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'no src';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.dirMakeForFile( dstPath );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.softLinkAct( o );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'src is a directory';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.dirMake( srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  self.provider.softLinkAct( o );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
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
    type : null,
    sync : 1
  }
  self.provider.softLinkAct( o );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  self.provider.filesDelete( dir );

  test.case = 'src is a hard link, check link';
  self.provider.filesDelete( dir );
  var filePath = _.path.join( dir,'file' );
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink({ srcPath : filePath, dstPath : srcPath, sync : 1 });
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null,
    sync : 1
  }
  self.provider.softLinkAct( o );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  var file = self.provider.fileRead( filePath );
  test.identical( srcFile, file );

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
    type : null,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct( o )
  });
  test.is( !self.provider.isSoftLink( dstPath ) );
  self.provider.filesDelete( dir );

  //

  test.case = 'dst is a hard link';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.hardLink( dstPath, srcPath );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct( o )
  });
  test.is( !self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, srcPath );
  self.provider.filesDelete( dir );

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
    type : null,
    sync : 1
  }
  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct( o )
  });
  var files = self.provider.dirRead( dstPath );
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
    self.provider.softLinkAct( o );
  })
  test.is( !self.provider.fileExists( dstPath ) );
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
    type : null,
    sync : 1
  }

  var expected = _.mapExtend( null, o );
  expected.srcPath = self.provider.path.nativize( o.srcPath );
  expected.dstPath = self.provider.path.nativize( o.dstPath );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  if( process.platform === 'win32' )
  expected.type = 'file'

  self.provider.softLinkAct( o );
  test.identical( o, expected );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
  var srcPath = _.path.join( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.path.join( dir,'dst' );
  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  expected.type = 'file'
  self.provider.softLinkAct( o );
  test.is( self.provider.isSoftLink( dstPath ) );
  var got = self.provider.pathResolveSoftLink({ filePath : dstPath/*, readLink : 1*/ });
  test.identical( got, srcPath );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.case = 'should assert that path is absolute';
  var srcPath = _.path.join( dir,'src' );
  var dstPath = _.path.join( dir,'dst' );
  self.provider.dirMakeForFile( dstPath );
  dstPath = _.path.relative( dir, dstPath );

  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      type : null,
      sync : 1
    });
  })

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
  var srcPath = _.path.join( dir,'src' );;
  var dstPath = _.path.join( dir,'dst' );

  /* sync option is missed */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null
  }
  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct( o );
  });

  /* redundant option */

  var o =
  {
    srcPath : srcPath,
    dstPath : dstPath,
    originalSrcPath : srcPath,
    originalDstPath : dstPath,
    type : null,
    sync : 1,
    redundant : 'redundant'
  }
  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct( o );
  });

  //

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
    type : null,
    sync : 1
  }
  var originalPath = o.srcPath;
  o.srcPath = self.provider.path.nativize( o.srcPath );
  o.dstPath = self.provider.path.nativize( o.dstPath );
  if( o.srcPath !== originalPath )
  {
    test.shouldThrowError( () =>
    {
      self.provider.softLinkAct( o );
    })
  }
  else
  {
    test.mustNotThrowError( () =>
    {
      self.provider.softLinkAct( o );
    })
  }

  self.provider.filesDelete( dir );

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
    type : null,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  test.shouldThrowError( () =>
  {
    self.provider.softLinkAct( o );
  })
  test.identical( o.srcPath, expected.srcPath );
}

//

function softLinkSoftLinkResolving( test )
{
  let self = this;

  if( !_.routineIs( self.provider.softLink ) )
  {
    test.identical( 1,1 );
    return;
  }

  /*

  resolvingSrcSoftLink : [ 0,1 ]
  resolvingDstSoftLink : [ 0,1 ]
  link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]

  */

  function softLink( o )
  {
    let o2 =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1
    }
    _.mapSupplement( o, o2 )
    return self.provider.softLink( o );
  }

  let workDir = test.context.makePath( 'written/fileRenameSoftLinkResolving' );
  let srcPath = self.provider.path.join( workDir, 'src' );
  let srcPath2 = self.provider.path.join( workDir, 'src2' );
  let dstPath = self.provider.path.join( workDir, 'dst' );
  let dstPath2 = self.provider.path.join( workDir, 'dst2' );
  let srcPathTerminal = self.provider.path.join( workDir, 'srcTerminal' );
  let dstPathTerminal = self.provider.path.join( workDir, 'dstTerminal' );

  /**/

  test.open( 'normal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPath );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'normal' );

  /**/

  test.open( 'double' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPath );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  //

  test.close( 'double' );

  /**/

  test.open( 'broken' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'broken' );

  /**/

  test.open( 'self cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPath )

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPathTerminal ), srcPath );
  test.shouldThrowError( () => self.provider.fileRead( srcPath ) )
  test.shouldThrowError( () => self.provider.fileRead( dstPath ) )

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1, allowingMissing : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal )
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal )
  test.shouldThrowError( () => self.provider.fileRead( srcPath ) )
  test.shouldThrowError( () => self.provider.fileRead( dstPath ) )

  test.close( 'links to same file' );
}

//

function softLinkRelativeLinkResolving( test )
{
  let self = this;

  if( !_.routineIs( self.provider.softLink ) )
  {
    test.identical( 1,1 );
    return;
  }

  /*

  resolvingSrcSoftLink : [ 0,1 ]
  resolvingDstSoftLink : [ 0,1 ]
  link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]

  */

  function softLink( o )
  {
    let o2 =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1
    }
    _.mapSupplement( o, o2 )
    return self.provider.softLink( o );
  }

  let workDir = test.context.makePath( 'written/softLinkRelativeLinkResolving' );
  let srcPath = self.provider.path.join( workDir, 'src' );
  let srcPath2 = self.provider.path.join( workDir, 'src2' );
  let srcPathRelative2 = self.provider.path.relative( srcPath, srcPath2 );
  let dstPath = self.provider.path.join( workDir, 'dst' );
  let dstPath2 = self.provider.path.join( workDir, 'dst2' );
  let dstPathRelative2 = self.provider.path.relative( dstPath, dstPath2 );
  let srcPathTerminal = self.provider.path.join( workDir, 'srcTerminal' );
  let srcPathRelativeTerminal = self.provider.path.relative( srcPath, srcPathTerminal );
  let dstPathTerminal = self.provider.path.join( workDir, 'dstTerminal' );
  let dstPathRelativeTerminal = self.provider.path.relative( dstPath, dstPathTerminal );

  /**/

  test.open( 'normal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPath );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'normal' );

  /**/

  test.open( 'double' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathRelativeTerminal );
  self.provider.softLink( srcPath, srcPathRelative2 );
  self.provider.softLink( dstPath2, dstPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelative2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathRelativeTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathRelativeTerminal );
  self.provider.softLink( srcPath, srcPathRelative2 );
  self.provider.softLink( dstPath2, dstPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelative2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathRelativeTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath2 ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathRelativeTerminal );
  self.provider.softLink( srcPath, srcPathRelative2 );
  self.provider.softLink( dstPath2, dstPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelative2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPath );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathRelativeTerminal );
  self.provider.softLink( srcPath, srcPathRelative2 );
  self.provider.softLink( dstPath2, dstPathRelativeTerminal );
  self.provider.softLink( dstPath, dstPathRelative2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  //

  test.close( 'double' );

  /**/

  test.open( 'broken' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelativeTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelativeTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelativeTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelativeTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelativeTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelativeTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelativeTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPathTerminal ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelativeTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelativeTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelativeTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'broken' );

  /**/

  test.open( 'self cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), '../dst' );
  test.identical( self.provider.pathResolveLink( dstPath ), srcPath );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : '../src', allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathRelative2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : '../dst', allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => softLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathRelative2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), '../src' );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), '../dst' );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, srcPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPath );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, srcPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathRelativeTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, srcPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPathTerminal ), srcPath );
  test.shouldThrowError( () => self.provider.fileRead( srcPath ) )
  test.shouldThrowError( () => self.provider.fileRead( dstPath ) )

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathRelativeTerminal );
  self.provider.softLink( dstPath, srcPathRelativeTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1, allowingMissing : 1 };
  softLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, srcPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.shouldThrowError( () => self.provider.fileRead( srcPath ) )
  test.shouldThrowError( () => self.provider.fileRead( dstPath ) )

  test.close( 'links to same file' );
}

//

function hardLinkSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.hardLinkAct ) )
  {
    test.case = 'hardLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  function linkGroups( paths, groups )
  {
    groups.forEach( ( g ) =>
    {
      var filePathes = g.map( ( i ) => paths[ i ] );
      self.provider.hardLink({ dstPath : filePathes });
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
    self.provider.hardLink( _.path.join( dir, 'file' + i ), filePath );
  }

  function filesHaveSameTime( paths )
  {
    _.assert( paths.length > 1 );
    var srcStat = self.provider.statResolvedRead( paths[ 0 ] );

    for( var i = 1; i < paths.length; i++ )
    {
      var stat = self.provider.statResolvedRead( paths[ i ] );
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

  var dir = test.context.makePath( 'written/hardLink' );
  self.provider.filesDelete( dir )
  var srcPath,dstPath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  //

  test.case = 'make link async';
  srcPath  = test.context.makePath( 'written/hardLink/link_test.txt' );
  dstPath = test.context.makePath( 'written/hardLink/link.txt' );
  self.provider.fileWrite( srcPath, '000' );

  /**/

  self.provider.hardLink
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

  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )
  var got = self.provider.fileRead( dstPath );
  var expected = '000new text';
  test.identical( got, expected );

  //

  test.case = 'make for file that not exist';
  self.provider.filesDelete( dir );
  srcPath  = test.context.makePath( 'written/hardLink/no_file.txt' );
  dstPath = test.context.makePath( 'written/hardLink/link2.txt' );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.hardLink
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
    self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  })
  var files = self.provider.dirRead( dir );
  test.identical( files, null );

  //

  test.case = 'link already exists';
  srcPath = test.context.makePath( 'written/hardLink/link_test.txt' );
  dstPath = test.context.makePath( 'written/hardLink/link.txt' );
  self.provider.fileWrite( srcPath, 'abc' );
  self.provider.hardLink
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
    self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 1,
    });
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 1,
    });
  });
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link.txt', 'link_test.txt' ] )

  /**/

  // test.shouldThrowErrorSync( function( )
  // {
  //   self.provider.hardLink
  //   ({
  //     srcPath : srcPath,
  //     dstPath : dstPath,
  //     rewriting : 0,
  //     throwing : 1,
  //     sync : 1,
  //   });
  // });

  var got = self.provider.hardLink
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    rewriting : 0,
    throwing : 1,
    sync : 1,
  });
  test.identical( got, true );
  test.identical( self.provider.filesAreHardLinked([ srcPath, dstPath ]), null )

  /**/

  test.mustNotThrowError( function( )
  {
    self.provider.hardLink
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
  srcPath = test.context.makePath( 'written/hardLink/link_test.txt' );
  self.provider.fileWrite( srcPath, ' ' );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 1,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : srcPath,
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, true );
  var files = self.provider.dirRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  //

  test.case = 'try make hardlink for folder';
  self.provider.filesDelete( dir );
  srcPath = test.context.makePath( 'written/hardLink/link_test' );
  dstPath = test.context.makePath( 'written/hardLink/link' );
  self.provider.dirMake( srcPath );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.hardLink
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
    self.provider.hardLink
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
    self.provider.hardLink
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
    self.provider.hardLink
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
    // next section needs time stats from Extract.statResolvedRead, not implemented yet
    return;
  }

  //

  var fileNames = [ 'a1', 'a2', 'a3' ];
  var currentTestDir = 'written/hardLink/';
  var data = ' ';

  /**/

  test.case = 'dstPath option, files are not linked';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths )
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  test.case = 'dstPath option, linking files from different dirs';
  paths = fileNames.map( ( n ) => _.path.join( 'dir_'+ n, n ) );
  paths = makeFiles( paths, currentTestDir );
  paths = self.provider.path.s.normalize( paths )

  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  test.case = 'dstPath option, try to link already linked files';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths );
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  // try to link again
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  test.case = 'dstPath, rewriting off, try to rewrite existing files';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths );
  test.shouldThrowError( () =>
  {
    self.provider.hardLink
    ({
      sync : 1,
      dstPath : paths,
      rewriting : 0,
      throwing : 1
    })
  });
  var got = self.provider.hardLink
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
  paths = self.provider.path.s.normalize( paths );
  linkGroups( paths,groups );
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  var groups = [ [ 0,1 ],[ 1,2,3 ],[ 3,4,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths );
  linkGroups( paths,groups );
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  var groups = [ [ 0,1,2,3 ],[ 4,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths );
  linkGroups( paths,groups );
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  var groups = [ [ 0,1,2,3,4 ],[ 0,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths );
  linkGroups( paths,groups );
  self.provider.hardLink
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );

  /**/

  test.case = 'dstPath option, only first path exists';
  var fileNames = [ 'a1', 'a2', 'a3' ];
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  makeFiles( fileNames.slice( 0, 1 ), currentTestDir );
  var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
  paths = self.provider.path.s.normalize( paths );
  test.mustNotThrowError( () =>
  {
    self.provider.hardLink
    ({
      sync : 1,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
  })
  test.identical( self.provider.filesAreHardLinked( paths ), null );
  self.provider.fileWrite( paths[ paths.length - 1 ], fileNames[ fileNames.length - 1 ] );
  test.identical( self.provider.fileRead( paths[ 0 ] ), self.provider.fileRead( paths[ paths.length - 1 ] ) );

  /**/

  test.case = 'dstPath option, all paths not exist';
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
  paths = self.provider.path.s.normalize( paths );
  test.shouldThrowError( () =>
  {
    self.provider.hardLink
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
  paths = self.provider.path.s.normalize( paths );
  self.provider.hardLink({ dstPath : paths });
  var stat = self.provider.statResolvedRead( paths[ 0 ] );
  waitSync( delay );
  self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
  self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
  var files = self.provider.recordFactory().records( paths );
  files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
  files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
  test.shouldThrowError( () =>
  {
    self.provider.hardLink({ dstPath : files, allowDiffContent : 0 });
  });
  test.is( !self.provider.filesAreHardLinked( paths ) ); */

  /* repair */

  /* test.case = 'dstPath option, same date but different content, allowDiffContent';
  var paths = makeFiles( fileNames, currentTestDir, true );
  paths = self.provider.path.s.normalize( paths );
  self.provider.hardLink({ dstPath : paths });
  var stat = self.provider.statResolvedRead( paths[ 0 ] );
  waitSync( delay );
  self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
  self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
  var files = self.provider.recordFactory().records( paths );
  files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
  files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
  self.provider.hardLink({ dstPath : files, allowDiffContent : 1 });
  test.identical( self.provider.filesAreHardLinked( paths ), null ); */

  /**/

  test.case = 'using srcPath as source for files from dstPath';
  var paths = makeFiles( fileNames, currentTestDir );
  paths = self.provider.path.s.normalize( paths );
  var srcPath = paths.pop();
  self.provider.hardLink({ srcPath : srcPath, dstPath : paths });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst )

  /* sourceMode */

  test.case = 'sourceMode: src - newest file with minimal amount of links';
  var paths = makeFiles( fileNames, currentTestDir);
  test.is( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); // #1 most linked file
  makeHardLinksToPath( paths[ 1 ], 2 ); // #2 most linked file
  paths = self.provider.path.s.normalize( paths );
  var records = self.provider.recordFactory().records( paths );
  // logger.log( _.select( records, '*.relative' ) )
  // logger.log( _.select( records, '*/stat/mtime' ).map( ( t ) => t.getTime() ) )
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified>hardlinks<' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks<'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
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
  paths = self.provider.path.s.normalize( paths );
  var records = self.provider.recordFactory().records( paths );
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified>hardlinks>' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks>'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
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
  paths = self.provider.path.s.normalize( paths );
  var records = self.provider.recordFactory().records( paths );
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified<hardlinks>' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks>'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst );

  //

  test.case = 'sourceMode: src - oldest file with maximal amount of links';
  var paths = makeFiles( fileNames, currentTestDir );
  test.is( paths.length >= 3 );
  paths = self.provider.path.s.normalize( paths );
  var records = self.provider.recordFactory().records( paths );
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified<hardlinks<' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks<'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
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
  paths = self.provider.path.s.normalize( paths );
  makeHardLinksToPath( paths[ 0 ], 2 );
  makeHardLinksToPath( paths[ 1 ], 3 );
  makeHardLinksToPath( paths[ 2 ], 5 );
  test.is( filesHaveSameTime( paths ) );
  var records = self.provider.recordFactory().records( paths );
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified>hardlinks>' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks>'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
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
  paths = self.provider.path.s.normalize( paths );
  makeHardLinksToPath( paths[ 0 ], 2 );
  makeHardLinksToPath( paths[ 1 ], 3 );
  makeHardLinksToPath( paths[ 2 ], 5 );
  test.is( filesHaveSameTime( paths ) );
  var records = self.provider.recordFactory().records( paths );
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified>hardlinks<' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks<'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ 2 ] );
  var ok = test.identical( src, dst );
}

hardLinkSync.timeOut = 60000;

//

function hardLinkRelativePath( test )
{
  var self = this;

  if( !_.routineIs( self.provider.hardLinkAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  let testDir = test.context.makePath( 'written/hardLinkRelativePath' );
  let pathToDir = test.context.makePath( 'written/hardLinkRelativePath/dir' );
  let pathToFile = test.context.makePath( 'written/hardLinkRelativePath/file' );

  test.open( 'src - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ), null );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = './../file';
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ), null );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = '../../file';
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ), null );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = './../../file';
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/dstDir/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPath ] ), null );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = './../../../file';
  var pathToFile2 = test.context.makePath( 'written/hardLinkRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile2, dstPath ] ), null );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );

  var srcPath = '../../../file';
  var pathToFile2 = test.context.makePath( 'written/hardLinkRelativePath/a/file' );
  self.provider.fileWrite( pathToFile2, pathToFile2 );
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/a/b/c/dstFile' );
  self.provider.filesDelete( dstPath );
  self.provider.dirMakeForFile( dstPath )
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile2, dstPath ] ), null );
  var got = self.provider.fileRead({ filePath : dstPath, resolvingSoftLink : 1 });
  test.identical( got,pathToFile2 );

  test.close( 'src - relative path to a file' );

  //

  test.open( 'src - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.dirMake( pathToDir );

  var srcPath = '../dir';
  var dstPath = test.context.makePath( 'written/hardLinkRelativePath/dstDir' );
  self.provider.filesDelete( dstPath );
  test.shouldThrowError( () => self.provider.hardLink( dstPath, srcPath ) )
  test.is( !self.provider.filesAreHardLinked( [ pathToDir, dstPath ] ) );

  test.close( 'src - relative path to a dir' );

  test.open( 'dst - relative path to a file' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ), null );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ), null );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );


  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ), null );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../../dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ), null );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = '../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ), null );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  var srcPath = pathToFile;
  var dstPath = './../a/b/dstFile';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.dirMakeForFile( dstPathResolved );
  self.provider.filesDelete( dstPathResolved );
  self.provider.hardLink( dstPath, srcPath );
  test.identical( self.provider.filesAreHardLinked( [ pathToFile, dstPathResolved ] ), null );
  var got = self.provider.fileRead({ filePath : dstPathResolved, resolvingSoftLink : 1 });
  test.identical( got,pathToFile );

  test.close( 'dst - relative path to a file' );

  //

  test.open( 'dst - relative path to a dir' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( _.path.join( pathToDir, 'fileInDir' ), 'fileInDir' );
  self.provider.dirMake( pathToDir );

  var srcPath = pathToDir;
  var dstPath = '../dstDir';
  var dstPathResolved = _.path.resolve( srcPath, dstPath );
  self.provider.filesDelete( dstPathResolved );
  test.shouldThrowError( () => self.provider.hardLink( dstPath, srcPath ) )
  test.is( !self.provider.filesAreHardLinked( [ pathToDir, dstPathResolved ] ) );

  test.close( 'dst - relative path to a dir' );

  test.open( 'same paths' );

  self.provider.filesDelete( testDir );
  self.provider.fileWrite( pathToFile, pathToFile );

  var srcPath = '../file';
  var dstPath = pathToFile;
  var statBefore = self.provider.statResolvedRead( pathToFile );
  var got = self.provider.hardLink( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.statResolvedRead( pathToFile );
  test.identical( statBefore.nlink, statNow.nlink );

  var srcPath = pathToFile;
  var dstPath = '../file';
  var statBefore = self.provider.statResolvedRead( pathToFile );
  var got = self.provider.hardLink( dstPath, srcPath );
  test.identical( got, true );
  var statNow = self.provider.statResolvedRead( pathToFile );
  test.identical( statBefore.nlink, statNow.nlink );

  test.close( 'same paths' );

}

//

function hardLinkExperiment( test )
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
    self.provider.hardLink( _.path.join( dir, 'file' + i ), filePath );
  }


  var dir = test.context.makePath( 'written/hardLink' );
  var srcPath,dstPath;

  var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
  test.case = 'sourceMode: src - oldest file with maximal amount of links';
  var paths = makeFiles( fileNames, dir );
  test.is( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); // #1 most linked+oldest file
  makeHardLinksToPath( paths[ paths.length - 1 ], 4 ); // #2 most linked+newest file
  paths = self.provider.path.s.normalize( paths );
  var records = self.provider.recordFactory().records( paths );
  logger.log( _.select( records, '*/name' ) )
  logger.log( 'nlink: ', _.select( records, '*/stat/nlink' ) )
  logger.log( 'atime: ', _.select( records, '*/stat/atime' ).map( ( r ) => r.getTime() ) )
  logger.log( 'mtime: ', _.select( records, '*/stat/mtime' ).map( ( r ) => r.getTime() ) )
  logger.log( 'ctime: ', _.select( records, '*/stat/ctime' ).map( ( r ) => r.getTime() ) )
  logger.log( 'birthtime: ', _.select( records, '*/stat/birthtime' ).map( ( r ) => r.getTime() ) )
  var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified<hardlinks>' });
  self.provider.hardLink
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks>'
  });
  test.identical( self.provider.filesAreHardLinked( paths ), null );
  var srcPath = paths[ 0 ];
  test.identical( selectedFile.absolute, srcPath );
  test.identical( selectedFile.stat.nlink, 4 );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst );
}

hardLinkExperiment.timeOut = 30000;

//

function hardLinkSoftlinked( test )
{
  var self = this;

  if( !_.routineIs( self.provider.hardLinkAct ) )
  {
    test.case = 'hardLinkAct is not implemented'
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
  var dir = mp( 'hardLinkActSync/dir' );
  var fileInDir = mp( 'hardLinkActSync/dir/src' );
  var linkToDir = mp( 'hardLinkActSync/linkToDir' );
  var fileInLinkedDir = mp( 'hardLinkActSync/linkToDir/src' );
  self.provider.fileWrite( fileInDir, fileInDir );
  var statResolvedReadBefore = self.provider.statResolvedRead( fileInDir );
  self.provider.softLink( linkToDir, dir );
  var got = self.provider.hardLink( fileInLinkedDir, fileInDir );
  test.identical( got, true );
  var statResolvedReadAfter = self.provider.statResolvedRead( fileInDir );
  test.is( !!statResolvedReadAfter );
  if( statResolvedReadAfter )
  {
    if( !self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
    return;

    test.identical( statResolvedReadBefore.atime.getTime(), statResolvedReadAfter.atime.getTime() );
    test.identical( statResolvedReadBefore.ctime.getTime(), statResolvedReadAfter.ctime.getTime() );
    test.identical( statResolvedReadBefore.mtime.getTime(), statResolvedReadAfter.mtime.getTime() );
    test.identical( statResolvedReadBefore.birthtime.getTime(), statResolvedReadAfter.birthtime.getTime() );
  }

}

//

function hardLinkActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.hardLinkAct ) )
  {
    test.case = 'hardLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'hardLinkActSync' );

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
  self.provider.hardLinkAct( o );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
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
    self.provider.hardLinkAct( o );
  })
  test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  test.case = 'src is not a terminal';
  self.provider.filesDelete( dir );
  var srcPath = _.path.join( dir,'src' );
  self.provider.dirMake( srcPath );
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
    self.provider.hardLinkAct( o );
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
  self.provider.hardLinkAct( o );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  self.provider.filesDelete( dir );

  test.case = 'src is hardlink';
  var filePath = _.path.join( dir,'file' );
  self.provider.fileWrite( filePath, filePath );
  var srcPath = _.path.join( dir,'src' );
  self.provider.hardLink( srcPath, filePath );
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
  self.provider.hardLinkAct( o );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.case = 'src is a hard link, check link';
    self.provider.filesDelete( dir );
    var filePath = _.path.join( dir,'file' );
    var srcPath = _.path.join( dir,'src' );
    self.provider.fileWrite( filePath, filePath );
    self.provider.hardLink({ srcPath : filePath, dstPath : srcPath, sync : 1 });
    test.identical( self.provider.filesAreHardLinked( [ srcPath, filePath ] ), null );
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
    self.provider.hardLinkAct( o );
    test.identical( self.provider.filesAreHardLinked( [ filePath, srcPath, dstPath ] ), null );
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
    self.provider.softLink({ srcPath : filePath, dstPath : srcPath, sync : 1 });
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
    test.shouldThrowError( () => self.provider.hardLinkAct( o ) )
    test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
    var srcFile = self.provider.fileRead( srcPath );
    test.identical( srcFile, filePath );
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
    self.provider.hardLinkAct( o )
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
  self.provider.hardLink( dstPath, srcPath );
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
    self.provider.hardLinkAct( o )
  });
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
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
    self.provider.softLink( dstPath, srcPath );
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
      self.provider.hardLinkAct( o )
    });
    test.is( self.provider.isSoftLink( dstPath ) );
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
    self.provider.hardLinkAct( o )
  });
  var files = self.provider.dirRead( dstPath );
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
    self.provider.hardLinkAct( o );
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

  self.provider.hardLinkAct( o );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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
  self.provider.hardLinkAct( o );
  test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
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
    self.provider.hardLinkAct
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

  test.case = 'should not extend or delete fields of options map, no _providerDefaults, routineOptions';
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
    self.provider.hardLinkAct( o );
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
    self.provider.hardLinkAct( o );
  });

  //

  test.case = 'should expect normalized path, but not nativized';
  var srcPath = dir + '\\src';
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = dir + '\\dst';
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
    self.provider.hardLinkAct( o );
  })
  self.provider.filesDelete( dir );

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
    self.provider.hardLinkAct( o );
  })
  test.identical( o.srcPath, expected.srcPath );
}

//

function hardLinkAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.hardLinkAct ) )
  {
    test.case = 'hardLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  function linkGroups( paths, groups )
  {
    groups.forEach( ( g ) =>
    {
      var filePathes = g.map( ( i ) => paths[ i ] );
      self.provider.hardLink({ dstPath : filePathes });
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
    self.provider.hardLink( _.path.join( dir, 'file' + i ), filePath );
  }

  var dir = test.context.makePath( 'written/hardLinkAsync' );
  self.provider.filesDelete( dir );
  var srcPath,dstPath;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var fileNames = [ 'a1', 'a2', 'a3' ];
  var currentTestDir = 'written/hardLink/';
  var data = ' ';
  var paths;

  var consequence = new _.Consequence().give( null );

  consequence

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'make link async';
    srcPath  = test.context.makePath( 'written/hardLinkAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/hardLinkAsync/link.txt' );
    self.provider.fileWrite( srcPath, '000' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      self.provider.fileWrite
      ({
        filePath : srcPath,
        sync : 1,
        data : 'new text',
        writeMode : 'append'
      });
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      var got = self.provider.fileRead( dstPath );
      var expected = '000new text';
      test.identical( got, expected );
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'make for file that not exist';
    self.provider.filesDelete( dir );
    srcPath  = test.context.makePath( 'written/hardLinkAsync/no_file.txt' );
    dstPath = test.context.makePath( 'written/hardLinkAsync/link2.txt' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.hardLink
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      rewriting : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, null );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'link already exists';
    srcPath = test.context.makePath( 'written/hardLinkAsync/link_test.txt' );
    dstPath = test.context.makePath( 'written/hardLinkAsync/link.txt' );
    self.provider.fileWrite( srcPath, 'abc' );
    return self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 1,
      sync : 0,
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      rewriting : 1,
      throwing : 0,
      sync : 0,
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link.txt', 'link_test.txt' ] )
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
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
      test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.hardLink
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'src is equal to dst';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/hardLinkAsync/link_test.txt' );
    self.provider.fileWrite( srcPath, ' ' );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
      return null;
    });
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    return self.provider.hardLink
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
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'try make hardlink for folder';
    self.provider.filesDelete( dir );
    srcPath = test.context.makePath( 'written/hardLinkAsync/link_test' );
    dstPath = test.context.makePath( 'written/hardLinkAsync/link' );
    self.provider.dirMake( srcPath );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.hardLink
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.hardLink
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.hardLink
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

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var con = self.provider.hardLink
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
    // next section needs time stats from Extract.statResolvedRead, not implemented yet
    return consequence;
  }

  /**/

  consequence.ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath option, files are not linked';
    var paths = makeFiles( fileNames, currentTestDir );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath option, linking files from different dirs';
    paths = fileNames.map( ( n ) => _.path.join( 'dir_'+ n, n ) );
    paths = makeFiles( paths, currentTestDir );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath option, try to link already linked files';
    var paths = makeFiles( fileNames, currentTestDir );
    self.provider.hardLink
    ({
      sync : 1,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    // try to link again
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath, rewriting off, try to rewrite existing files';
    var paths = makeFiles( fileNames, currentTestDir );
    var con = self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( () =>
    {
      var got = self.provider.hardLink
      ({
        sync : 1,
        dstPath : paths,
        rewriting : 0,
        throwing : 0
      });
      test.identical( got, false );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath option, groups of linked files ';
    fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    return null;
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var groups = [ [ 0,1 ],[ 2,3,4 ],[ 5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var groups = [ [ 0,1 ],[ 1,2,3 ],[ 3,4,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var groups = [ [ 0,1,2,3 ],[ 4,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    var groups = [ [ 0,1,2,3,4 ],[ 0,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir );
    linkGroups( paths,groups );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.identical( self.provider.filesAreHardLinked( paths ), null ) );
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath option, only first path exists';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    makeFiles( fileNames.slice( 0, 1 ), currentTestDir );
    var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () =>
    {
      test.identical( self.provider.filesAreHardLinked( paths ), null );
      self.provider.fileWrite( paths[ paths.length - 1 ], fileNames[ fileNames.length - 1 ] );
      test.identical( self.provider.fileRead( paths[ 0 ] ), self.provider.fileRead( paths[ paths.length - 1 ] ) );
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'dstPath option, all paths not exist';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    var paths = fileNames.map( ( n )  => self.makePath( _.path.join( currentTestDir, n ) ) );
    debugger
    var con = self.provider.hardLink
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    return test.shouldThrowError( con );
  })

  /* repair */

  /* .ifNoErrorThen( function( arg )
  {
    test.case = 'dstPath option, same date but different content';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = makeFiles( fileNames, currentTestDir, true );
    self.provider.hardLink({ dstPath : paths });
    var stat = self.provider.statResolvedRead( paths[ 0 ] );
    waitSync( delay );
    self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
    self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
    var files = self.provider.recordFactory().records( paths );
    files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
    files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
    var con = self.provider.hardLink
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

  /* .ifNoErrorThen( function( arg )
  {
    test.case = 'dstPath option, same date but different content, allow different files';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = self.provider.path.s.normalize( makeFiles( fileNames, currentTestDir ) );
    self.provider.hardLink({ dstPath : paths });
    var stat = self.provider.statResolvedRead( paths[ 0 ] );
    waitSync( delay );
    self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
    self.provider.fileWrite( paths[ paths.length - 1 ], 'different content' );
    var files = self.provider.recordFactory().records( paths );
    files[ files.length - 1 ].stat.mtime = files[ 0 ].stat.mtime;
    files[ files.length - 1 ].stat.birthtime = files[ 0 ].stat.birthtime;
    return self.provider.hardLink
    ({
      sync : 0,
      dstPath : files,
      rewriting : 1,
      throwing : 1,
      allowDiffContent : 1
    })
    .doThen( () =>
    {
      test.identical( self.provider.filesAreHardLinked( paths ), null );
    });
  }) */

  /* sourceMode */

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'sourceMode: source newest file with min hardlinks count ';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = makeFiles( fileNames, currentTestDir );
    test.is( paths.length >= 3 );
    makeHardLinksToPath( paths[ 1 ], 3 );
    paths = self.provider.path.s.normalize( paths );
    var records = self.provider.recordFactory().records( paths );
    var selectedFile = self.provider._recordsSort({ src : records, sorter : 'modified>hardlinks<' });
    return self.provider.hardLink
    ({
      dstPath : paths,
      sourceMode : 'modified>hardlinks<',
      sync : 0
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      test.identical( self.provider.filesAreHardLinked( paths ), null );
      var srcPath = paths[ paths.length - 1 ];
      test.identical( selectedFile.absolute, srcPath );
      var src = self.provider.fileRead( srcPath );
      var dst = self.provider.fileRead( paths[ 1 ] );
      test.identical( src, dst )
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
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
    paths = self.provider.path.s.normalize( paths );
    var records = self.provider.recordFactory().records( paths );
    var selectedFile = self.provider._recordsSort({ src : records, sorter : 'hardlinks>' });
    return self.provider.hardLink
    ({
      dstPath : paths,
      sync : 0,
      sourceMode : 'hardlinks>'
    })
    .ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      test.identical( self.provider.filesAreHardLinked( paths ), null );
      var srcPath = paths[ 0 ];
      test.identical( selectedFile.absolute, srcPath );
      var dstPath = paths[ 1 ];
      var src = self.provider.fileRead( srcPath );
      var dst = self.provider.fileRead( dstPath );
      test.identical( src, 'max links file' );
      test.identical( dst, 'max links file' );
      var srcStat = self.provider.statResolvedRead( srcPath );
      var dstStat = self.provider.statResolvedRead( dstPath );
      test.identical( Number( srcStat.nlink ), 9 );
      test.identical( Number( dstStat.nlink ), 9 );
      return null;
    })

  })

  return consequence;
}
hardLinkAsync.timeOut = 60000;

//

function hardLinkActAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.hardLinkAct ) )
  {
    test.case = 'hardLinkAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  let mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'hardLinkActSync' );

  let symlinkIsAllowed = test.context.symlinkIsAllowed();
  let con = new _.Consequence().give( null )

  //

  .doThen( () =>
  {
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
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.mustNotThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.identical( got, true );
      test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      self.provider.filesDelete( dir );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'src does not exist';
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
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.shouldThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.is( _.errIs( got ) );
      test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      self.provider.filesDelete( dir );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'src is not a terminal, but dir';
    var srcPath = _.path.join( dir,'src' );
    self.provider.dirMake( srcPath );
    var dstPath = _.path.join( dir,'dst' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.shouldThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.is( _.errIs( got ) );
      test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      self.provider.filesDelete( dir );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'src is not a terminal, but softlink';
    var filePath = _.path.join( dir,'file' );
    self.provider.fileWrite( filePath, filePath )
    var srcPath = _.path.join( dir,'src' );
    self.provider.softLink( srcPath, filePath );
    var dstPath = _.path.join( dir,'dst' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.shouldThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.is( _.errIs( got ) );
      test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      self.provider.filesDelete( dir );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'dst already exists';
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
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.shouldThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.is( _.errIs( got ) );
      test.is( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      self.provider.filesDelete( dir );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'same path';
    var srcPath = _.path.join( dir,'src' );
    var dstPath = _.path.join( dir,'src' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.mustNotThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.identical( got, true );
      test.is( !self.provider.isHardLink( dstPath ) );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      return null;
    })
  })

  //

  .doThen( () =>
  {
    test.case = 'src is hardlink';
    var filePath = _.path.join( dir,'file' );
    self.provider.fileWrite( filePath, filePath )
    var srcPath = _.path.join( dir,'src' );
    self.provider.hardLink( srcPath, filePath );
    var dstPath = _.path.join( dir,'dst' );
    var o =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      originalSrcPath : srcPath,
      originalDstPath : dstPath,
      breakingSrcHardLink : 0,
      breakingDstHardLink : 1,
      sync : 0
    }
    var expected = _.mapOwnKeys( o );
    return test.mustNotThrowError( self.provider.hardLinkAct( o ) )
    .doThen( ( err, got ) =>
    {
      test.identical( got, true );
      test.identical( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ), null );
      got = _.mapOwnKeys( o );
      test.identical( got, expected );
      self.provider.filesDelete( dir );
      return null;
    })
  })

  return con;
}

hardLinkActAsync.timeOut = 15000;

//

function fileExchangeSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileExchange ) || !_.routineIs( self.provider.statReadAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/fileExchange' );
  var srcPath,dstPath,src,dst,got;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  //

  test.case = 'swap two files content';
  srcPath = test.context.makePath( 'written/fileExchange/src' );
  dstPath = test.context.makePath( 'written/fileExchange/dst' );


  /*default setting*/

  self.provider.fileWrite( srcPath, 'src' );
  self.provider.fileWrite( dstPath, 'dst' );
  self.provider.fileExchange( dstPath, srcPath );
  var files = self.provider.dirRead( dir );
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
  var files = self.provider.dirRead( dir );
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
  src = self.provider.dirRead( _.path.dir( srcPath ) );
  dst = self.provider.dirRead( _.path.dir( dstPath ) );
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
  src = self.provider.dirRead( _.path.dir( srcPath ) );
  dst = self.provider.dirRead( _.path.dir( dstPath ) );
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
      allowingMissing : 0,
      throwing : 1
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  /*src not exist, throwing on, allowingMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, 'dst' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 1,
      throwing : 1
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  /*src not exist, throwing off,allowingMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( dstPath, 'dst' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 1,
      throwing : 0
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  /*dst not exist, throwing on,allowingMissing off*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 0,
      throwing : 1
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  /*dst not exist, throwing off,allowingMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 1,
      throwing : 0
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  /*dst not exist, throwing on,allowingMissing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 1,
      throwing : 1
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'dst' ] );

  /*dst not exist, throwing off,allowingMissing off*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  test.mustNotThrowError( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 0,
      throwing : 0
    });
  });
  var files  = self.provider.dirRead( dir );
  test.identical( files, [ 'src' ] );

  /*dst & src not exist, throwing on,allowingMissing on*/

  self.provider.filesDelete( dir );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 1,
      throwing : 1
    });
  });
  test.identical( got, null );

  /*dst & src not exist, throwing off,allowingMissing off*/

  // self.provider.filesDelete( dir );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 1,
      throwing : 0
    });
  });
  test.identical( got, null );

  /*dst & src not exist, throwing on,allowingMissing off*/

  // self.provider.filesDelete( dir );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 0,
      throwing : 1
    });
  });

  /*dst & src not exist, throwing off,allowingMissing off*/

  // self.provider.filesDelete( dir );
  test.mustNotThrowError( function()
  {
    got = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      allowingMissing : 0,
      throwing : 0
    });
  });
  test.identical( got, null );

}

//

function fileExchangeAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileExchange ) || !_.routineIs( self.provider.statReadAct ) )
  {
    test.identical( 1,1 );
    return;
  }

  var dir = test.context.makePath( 'written/fileExchangeAsync' );
  var srcPath,dstPath,src,dst,got;

  if( !self.provider.statResolvedRead( dir ) )
  self.provider.dirMake( dir );

  var consequence = new _.Consequence().give( null );

  consequence

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'swap two files content';
    srcPath = test.context.makePath( 'written/fileExchangeAsync/src' );
    dstPath = test.context.makePath( 'written/fileExchangeAsync/dst' );
    return null;
  })

  /*default setting*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst', 'src' ] );
      src = self.provider.fileRead( srcPath );
      dst = self.provider.fileRead( dstPath );
      test.identical( [ src, dst ], [ 'dst', 'src' ] )
      return null;
    })
  })

  /**/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files = self.provider.dirRead( dir );
      test.identical( files, [ 'dst', 'src' ] );
      src = self.provider.fileRead( srcPath );
      dst = self.provider.fileRead( dstPath );
      test.identical( [ src, dst ], [ 'dst', 'src' ] )
      return null;
    })
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'swap two dirs content';
    srcPath = test.context.makePath( 'written/fileExchangeAsync/src/src.txt' );
    dstPath = test.context.makePath( 'written/fileExchangeAsync/dst/dst.txt' );
    return null;
  })

  /*throwing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : _.path.dir( srcPath ),
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      allowingMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      src = self.provider.dirRead( _.path.dir( srcPath ) );
      dst = self.provider.dirRead( _.path.dir( dstPath ) );
      test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
      src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
      dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
      test.identical( [ src, dst ], [ 'dst', 'src' ] );
      return null;
    });
  })

  /*throwing off*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    self.provider.fileWrite( dstPath, 'dst' );
    return self.provider.fileExchange
    ({
      srcPath : _.path.dir( srcPath ),
      dstPath : _.path.dir( dstPath ),
      sync : 0,
      allowingMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      src = self.provider.dirRead( _.path.dir( srcPath ) );
      dst = self.provider.dirRead( _.path.dir( dstPath ) );
      test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
      src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
      dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
      test.identical( [ src, dst ], [ 'dst', 'src' ] );
      return null;
    });
  })

  //

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    test.case = 'path not exist';
    srcPath = test.context.makePath( 'written/fileExchangeAsync/src' );
    dstPath = test.context.makePath( 'written/fileExchangeAsync/dst' );
    return null;
  })

  /*src not exist, throwing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( dstPath, 'dst' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return null;
    });
  })

  /*src not exist, throwing on, allowingMissing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( dstPath, 'dst' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return null;
    });
  })

  /*src not exist, throwing off,allowingMissing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( dstPath, 'dst' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return null;
    });
  })

  /*dst not exist, throwing on,allowingMissing off*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 0,
      throwing : 1
    });
    return test.shouldThrowError( con )
    .doThen( function()
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return null;
    });
  })

  /*dst not exist, throwing off,allowingMissing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return null;
    });
  })

  /*dst not exist, throwing on,allowingMissing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'dst' ] );
      return null;
    });
  })

  /*dst not exist, throwing off,allowingMissing off*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath, 'src' );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( arg/*aaa*/ )
    {
      var files  = self.provider.dirRead( dir );
      test.identical( files, [ 'src' ] );
      return null;
    });
  })

  /*dst & src not exist, throwing on,allowingMissing on*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 1
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, null );
      return null;
    });
  })

  /*dst & src not exist, throwing off,allowingMissing off*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    // self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 1,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, null );
      return null;
    });
  })

  /*dst & src not exist, throwing on,allowingMissing off*/

  .ifNoErrorThen( function( arg/*aaa*/ )
  {
    // self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 0,
      throwing : 1
    });
    return test.shouldThrowError( con );
  })

  /*dst & src not exist, throwing off,allowingMissing off*/

  .doThen( function()
  {
    // self.provider.filesDelete( dir );
    var con = self.provider.fileExchange
    ({
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 0,
      allowingMissing : 0,
      throwing : 0
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      test.identical( got, null );
      return null;
    })
  })

  return consequence;
}

//

function hardLinkSoftLinkResolving( test )
{
  let self = this;

  if( !_.routineIs( self.provider.hardLink ) )
  {
    test.identical( 1,1 );
    return;
  }

  /*
  resolvingSrcSoftLink : [ 0,1 ]
  resolvingDstSoftLink : [ 0,1 ]
  link : [ normal, double, broken, self cycled, cycled, dst and src resolving to the same file ]
  */

  function hardLink( o )
  {
    let o2 =
    {
      srcPath : srcPath,
      dstPath : dstPath,
      sync : 1,
      rewriting : 1
    }
    _.mapSupplement( o, o2 )
    return self.provider.hardLink( o );
  }

  let workDir = test.context.makePath( 'written/fileRenameSoftLinkResolving' );
  let srcPath = self.provider.path.join( workDir, 'src' );
  let srcPath2 = self.provider.path.join( workDir, 'src2' );
  let dstPath = self.provider.path.join( workDir, 'dst' );
  let dstPath2 = self.provider.path.join( workDir, 'dst2' );
  let srcPathTerminal = self.provider.path.join( workDir, 'srcTerminal' );
  let dstPathTerminal = self.provider.path.join( workDir, 'dstTerminal' );

  /**/

  test.open( 'normal' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  hardLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.is( self.provider.filesAreHardLinked([ dstPath, srcPathTerminal ]) );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPathTerminal ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPathTerminal ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, dstPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  hardLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.filesAreHardLinked([ dstPathTerminal, srcPathTerminal ]) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'normal' );

  /**/

  test.open( 'double' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  hardLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isHardLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.is( self.provider.filesAreHardLinked([ dstPath , srcPathTerminal ]) );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isTerminal( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), dstPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.fileWrite( dstPathTerminal, dstPathTerminal );
  self.provider.softLink( srcPath2, srcPathTerminal );
  self.provider.softLink( srcPath, srcPath2 );
  self.provider.softLink( dstPath2, dstPathTerminal );
  self.provider.softLink( dstPath, dstPath2 );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  hardLink( o );
  test.identical( o.srcPath, srcPathTerminal );
  test.identical( o.dstPath, dstPathTerminal );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isTerminal( srcPathTerminal ) );
  test.is( self.provider.isHardLink( dstPathTerminal ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPathTerminal );
  test.is( self.provider.filesAreHardLinked([ dstPathTerminal , srcPathTerminal ]) );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPathTerminal );
  test.identical( self.provider.fileRead( srcPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'double' );

  /**/

  test.open( 'broken' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPathTerminal, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPathTerminal, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPathTerminal );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'broken' );

  /**/

  test.open( 'self cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'self cycled' );

  /* */

  test.open( 'cycled' );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.shouldThrowError( () => self.provider.pathResolveLink( dstPath ) );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  self.provider.filesDelete( workDir );
  self.provider.dirMake( workDir );
  self.provider.softLink({ dstPath : srcPath, srcPath : srcPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : srcPath2, srcPath : srcPath, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath, srcPath : dstPath2, allowingMissing : 1 });
  self.provider.softLink({ dstPath : dstPath2, srcPath : dstPath, allowingMissing : 1 });
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  test.shouldThrowError( () => hardLink( o ) );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( srcPath2 ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.is( self.provider.isSoftLink( dstPath2 ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPath2 );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), dstPath2 );
  test.identical( self.provider.pathResolveSoftLink( srcPath2 ), srcPath );
  test.identical( self.provider.pathResolveSoftLink( dstPath2 ), dstPath );
  test.identical( self.provider.statResolvedRead( srcPath ), null );
  test.identical( self.provider.statResolvedRead( dstPath ), null );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 0 };
  hardLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 0 };
  hardLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 0, resolvingDstSoftLink : 1 };
  hardLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  self.provider.filesDelete( workDir );
  self.provider.fileWrite( srcPathTerminal, srcPathTerminal );
  self.provider.softLink( srcPath, srcPathTerminal );
  self.provider.softLink( dstPath, srcPathTerminal );
  var o = { resolvingSrcSoftLink : 1, resolvingDstSoftLink : 1 };
  hardLink( o );
  test.identical( o.srcPath, srcPath );
  test.identical( o.dstPath, dstPath );
  test.is( self.provider.isSoftLink( srcPath ) );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( self.provider.pathResolveSoftLink( srcPath ), srcPathTerminal );
  test.identical( self.provider.pathResolveSoftLink( dstPath ), srcPathTerminal );
  test.identical( self.provider.fileRead( dstPath ), srcPathTerminal );

  test.close( 'links to same file' );
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

  if( Config.platform === 'nodejs' && process.platform === 'win32' )
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

function hardLinkSyncRunner( test )
{
  var self = this;

  var suite = test.suite;
  var tests = suite.tests;

  var runsLimit = 50;

  for( var i = 0; i < runsLimit; i++ )
  {
    tests.hardLinkSync.call( self, test );
    // if( test.report.testCheckFails > 0 )
    // break;
  }
}

//

function hardLinkAsyncRunner( test )
{
  var self = this;

  var suite = test.suite;
  var tests = suite.tests;

  var runsLimit = 50;

  var con = _.Consequence().give( null );

  for( var i = 0; i < runsLimit; i++ )(function()
  {
    con.ifNoErrorThen( ( arg/*aaa*/ ) =>
    {
      return tests.hardLinkAsync.call( self, test )
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

hardLinkAsyncRunner.timeOut = 60000 * 50;

//

function isDir( test )
{
  let self = this;
  let dirPath = test.context.makePath( 'written/isDir' );
  let filePath = test.context.makePath( 'written/isDir/file' );
  let linkPath = test.context.makePath( 'written/isDir/link' );
  let linkPath2 = test.context.makePath( 'written/isDir/link2' );
  let linkPath3 = test.context.makePath( 'written/isDir/link3' );

  /* resolving off */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'hardlink -> soft -> text -> dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'hardlink -> text -> soft -> dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false );
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + '../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isDir( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  self.provider.fieldPop( 'usingTextLink', 1 );

}

//

function dirIsEmpty( test )
{
  var self = this;

  var filePath = test.context.makePath( 'written/dirIsEmpty' );
  self.provider.filesDelete( filePath );

  //

  test.case = 'non existing path'
  test.identical( self.provider.dirIsEmpty( filePath ), false );

  //

  test.case = 'file'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, '' );
  test.identical( self.provider.dirIsEmpty( filePath ), false );

  //

  test.case = 'path with dot';
  self.provider.filesDelete( filePath );
  var path = test.context.makePath( 'written/.dirIsEmpty' );
  self.provider.dirMake( path )
  test.identical( self.provider.dirIsEmpty( path ), true );

  //

  test.case = 'directory with file'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( _.path.join( filePath, 'a' ), '' );
  test.identical( self.provider.dirIsEmpty( filePath ), false );

  //

  test.case = 'empty directory'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  test.identical( self.provider.dirIsEmpty( filePath ), true );

  //

  test.case = 'softLink to file';
  self.provider.filesDelete( filePath );
  var src = filePath + '_';
  self.provider.fileWrite( src, '' );
  self.provider.softLink( filePath, src );
  test.identical( self.provider.dirIsEmpty( filePath ), false );

  //

  test.case = 'softLink empty dir';
  self.provider.filesDelete( filePath );
  var src = filePath + '_';
  self.provider.dirMake( src );
  self.provider.softLink( filePath, src );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  test.identical( self.provider.dirIsEmpty( filePath ), false );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  debugger
  test.identical( self.provider.dirIsEmpty( filePath ), true );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
};

//

function isTerminal( test )
{
  let self = this;
  let dirPath = test.context.makePath( 'written/isTerminal' );
  let filePath = test.context.makePath( 'written/isTerminal/file' );
  let linkPath = test.context.makePath( 'written/isTerminal/link' );
  let linkPath2 = test.context.makePath( 'written/isTerminal/link2' );
  let linkPath3 = test.context.makePath( 'written/isTerminal/link3' );

  /* resolving off */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true );
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  self.provider.fieldPop( 'usingTextLink', 1 );

  /* resolving */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );


  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null);

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), true );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), true );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), true );
  test.identical( got.isTextLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isTerminal( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  self.provider.fieldPop( 'usingTextLink', 1 );

};

//

function isSoftLink( test )
{
  let self = this;
  let dirPath = test.context.makePath( 'written/isSoftLink' );
  let filePath = test.context.makePath( 'written/isSoftLink/file' );
  let linkPath = test.context.makePath( 'written/isSoftLink/link' );
  let linkPath2 = test.context.makePath( 'written/isSoftLink/link2' );
  let linkPath3 = test.context.makePath( 'written/isSoftLink/link3' );

  /* resolving off */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false );
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  self.provider.fieldPop( 'usingTextLink', 1 );


  /* resolving */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isSoftLink(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) )
  test.identical( got, null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1 };
  var got = self.provider.isSoftLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) )
  test.identical( got, null );

  self.provider.fieldPop( 'usingTextLink', 1 );

}

//

//

function isTextLink( test )
{
  let self = this;
  let dirPath = test.context.makePath( 'written/isTextLink' );
  let filePath = test.context.makePath( 'written/isTextLink/file' );
  let filePath2 = test.context.makePath( 'written/isTextLink/file2' );
  let linkPath = test.context.makePath( 'written/isTextLink/link' );

  /**/

  self.provider.fieldPush( 'usingTextLink', 0 )

  test.case = 'to missing'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'to terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'to directory'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'to text link'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, 'link ' + dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'self cycled'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath );
  test.mustNotThrowError( () => self.provider.isTextLink( linkPath ) );

  test.case = 'cycled'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.mustNotThrowError( () => self.provider.isTextLink( linkPath ) );

  test.case = 'to cycled soft link'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath, allowingMissing : 1 });
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  self.provider.fieldPush( 'resolvingSoftLink', 1 )
  test.is( !self.provider.isTextLink( linkPath ) );
  self.provider.fieldPop( 'resolvingSoftLink', 1 );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  test.is( !self.provider.isTextLink( filePath ) );

  test.case = 'softlink'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath, makingDirectory : 1, allowingMissing : 1 });
  test.is( !self.provider.isTextLink( filePath ) );

  test.case = 'softlink to softlink to missing'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath, makingDirectory : 1, allowingMissing : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'softlink to softlink to terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath2, filePath2 );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath2 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'softlink to softlink to dir'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : _.path.dir( filePath ), makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'hardlink'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );

  self.provider.fieldPop( 'usingTextLink', 0 )

  /**/

  self.provider.fieldPush( 'usingTextLink', 1 )
  self.provider.filesDelete( dirPath );

  test.case = 'to missing'
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink( linkPath ) );

  test.case = 'to terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink( linkPath ) );

  test.case = 'to directory'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink( linkPath ) );

  test.case = 'to text link'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, 'link ' + dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink( linkPath ) );

  test.case = 'self cycled'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath );
  test.is( self.provider.isTextLink( linkPath ) );

  test.case = 'cycled'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink( linkPath ) );

  test.case = 'to cycled soft link'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath, allowingMissing : 1 });
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  self.provider.fieldPush( 'resolvingSoftLink', 1 )
  test.is( self.provider.isTextLink( linkPath ) );
  self.provider.fieldPop( 'resolvingSoftLink', 1 );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  test.is( !self.provider.isTextLink( filePath ) );

  test.case = 'softlink'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath, makingDirectory : 1, allowingMissing : 1 });
  test.is( !self.provider.isTextLink( filePath ) );

  test.case = 'softlink to softlink to missing'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath, makingDirectory : 1, allowingMissing : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'softlink to softlink to terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath2, filePath2 );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath2 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'softlink to softlink to dir'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : _.path.dir( filePath ), makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );

  test.case = 'hardlink'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );

  self.provider.fieldPop( 'usingTextLink', 1 )

  /* resolving soft link */

  self.provider.fieldPush( 'usingTextLink', 1 )
  self.provider.filesDelete( dirPath );

  test.case = 'to missing'
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'to terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'to directory'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'to text link'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, 'link ' + dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'self cycled'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath );
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'cycled'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'to cycled soft link'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : '../file', allowingMissing : 1 });
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  self.provider.fieldPush( 'resolvingSoftLink', 1 )
  test.is( self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  self.provider.fieldPop( 'resolvingSoftLink', 1 );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), true );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  test.is( !self.provider.isTextLink( filePath ) );
  var got = self.provider.statRead({ filePath : filePath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), false );

  test.case = 'softlink to missing'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1, allowingMissing : 1 });
  test.is( !self.provider.isTextLink( linkPath ) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got, null );

  test.case = 'softlink to softlink to missing'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath2, srcPath : filePath, makingDirectory : 1, allowingMissing : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath2, allowingMissing : 1 });
  test.is( !self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got, null );

  test.case = 'softlink to softlink to terminal'
  self.provider.filesDelete( self.provider.path.dir( filePath ) );
  self.provider.fileWrite( filePath2, filePath2 );
  self.provider.softLink({ dstPath : filePath, srcPath : filePath2 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  test.is( !self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), false );

  test.case = 'softlink to softlink to dir'
  self.provider.filesDelete( filePath );
  self.provider.softLink({ dstPath : filePath, srcPath : _.path.dir( filePath ), makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1 });
  test.is( !self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );
  test.identical( got.isLink(), false );

  test.case = 'hardlink'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath, makingDirectory : 1 });
  test.is( !self.provider.isTextLink({ filePath : linkPath, resolvingSoftLink : 1 }) );
  var got = self.provider.statRead({ filePath : linkPath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isLink(), false );

  self.provider.fieldPop( 'usingTextLink', 1 )
};

//

function isHardLink( test )
{
  let self = this;
  let dirPath = test.context.makePath( 'written/isHardLink' );
  let filePath = test.context.makePath( 'written/isHardLink/file' );
  let linkPath = test.context.makePath( 'written/isHardLink/link' );
  let linkPath2 = test.context.makePath( 'written/isHardLink/link2' );
  let linkPath3 = test.context.makePath( 'written/isHardLink/link3' );

  /* resolving off */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isDirectory(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, true )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false );
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  self.provider.fieldPop( 'usingTextLink', 1 );

  /* resolving */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( o );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );


  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null);

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( o );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isHardLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), true );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), true );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), true );
  test.identical( got.isTextLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );


  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isTextLink(), true );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isHardLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  self.provider.fieldPop( 'usingTextLink', 1 );
}

//

function isLink( test )
{
  let self = this;
  let dirPath = test.context.makePath( 'written/isLink' );
  let filePath = test.context.makePath( 'written/isLink/file' );
  let linkPath = test.context.makePath( 'written/isLink/link' );
  let linkPath2 = test.context.makePath( 'written/isLink/link2' );
  let linkPath3 = test.context.makePath( 'written/isLink/link3' );

  /* resolving off */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );


  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  self.provider.fieldPop( 'usingTextLink', 1 );

  /* resolving */

  self.provider.fieldPush( 'usingTextLink', 1 );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'missing'
  self.provider.filesDelete( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'terminal'
  self.provider.filesDelete( filePath );
  self.provider.fileWrite( filePath, filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'dir'
  self.provider.filesDelete( filePath );
  self.provider.dirMake( filePath );
  var o = { filePath : filePath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null);

  test.case = 'soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null);

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to soft to missing'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink :1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );

  test.case = 'soft to text to directory'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

   test.case = 'soft self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'soft cycled'
  self.provider.filesDelete( dirPath );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'hardlink -> soft -> text -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink :1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'hardlink -> text -> soft -> terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.hardLink( linkPath, linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'soft to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath2, srcPath : filePath });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'soft to text to hardlink'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath,filePath);
  self.provider.hardLink({ dstPath : linkPath3, srcPath : filePath });
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 )
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), true );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to missing'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got, null );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );


  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );
  test.identical( got.isLink(), false );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );
  test.identical( got.isLink(), false );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to soft to terminal'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( filePath, filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), false );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), true );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text to soft to dir'
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( filePath )
  self.provider.softLink( linkPath2, filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), false );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), false );
  test.identical( got.isDirectory(), true );
  test.identical( got.isLink(), false );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got,null );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text self cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath, 'link ../link' );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got,null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got,null );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 0, resolvingSoftLink : 1 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, true )
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got.isTerminal(), true );
  test.identical( got.isHardLink(), false );
  test.identical( got.isSoftLink(), false );
  test.identical( got.isTextLink(), true );
  test.identical( got.isDirectory(), false );
  test.identical( got.isLink(), true );

  test.case = 'text cycled'
  self.provider.filesDelete( dirPath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = { filePath : linkPath, resolvingTextLink : 1, resolvingSoftLink : 0 };
  var got = self.provider.isLink( _.mapExtend( null, o ) );
  test.identical( got, false );
  var got = self.provider.statRead( _.mapExtend( null, o ) );
  test.identical( got,null );

  self.provider.fieldPop( 'usingTextLink', 1 );
}

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

  if( Config.platform === 'browser' || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
  var bufferData = new ArrayBuffer( 4 );
  else
  var bufferData = Buffer.from( [ 0x01, 0x02, 0x03, 0x04 ] );

  //

  test.case = 'same text file';
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  self.provider.fileWrite( filePath, textData );
  var got = self.provider.filesAreHardLinked([ filePath, filePath ]);
  test.identical( got, true );

  //

  test.case = 'softlink to a file';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, textData );
  self.provider.softLink( linkPath, filePath );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreHardLinked([ linkPath, filePath ]);
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreHardLinked([ linkPath, filePath ]);
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, true );

  //

  test.case = 'different files with identical binary content';
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var filePath2 = test.context.makePath( 'written/filesAreHardLinked/file2' );
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  self.provider.fileWrite( filePath, bufferData );
  self.provider.fileWrite( filePath2, bufferData );
  var got = self.provider.filesAreHardLinked([ filePath, filePath2 ]);
  test.identical( got, false );

  //

  test.case = 'symlink to file with  binary content';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, bufferData );
  self.provider.softLink( linkPath, filePath );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreHardLinked([ linkPath, filePath ]);
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreHardLinked([ linkPath, filePath ]);
  self.provider.fieldReset( 'resolvingSoftLink', 1 );
  test.identical( got, true );

  //

  test.case = 'hardLink to file with  binary content';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, bufferData );
  self.provider.hardLink( linkPath, filePath );
  var got = self.provider.filesAreHardLinked([ linkPath, filePath ]);
  test.identical( got, true );

  //

  test.case = 'hardlink to file with  text content : file record';
  self.provider.filesDelete( test.context.makePath( 'written/filesAreHardLinked' ) );
  var filePath = test.context.makePath( 'written/filesAreHardLinked/file' );
  var linkPath = test.context.makePath( 'written/filesAreHardLinked/link' );
  self.provider.fileWrite( filePath, textData );
  self.provider.hardLink( linkPath, filePath );
  var fileRecord = self.provider.recordFactory().record( filePath );
  var linkRecord = self.provider.recordFactory().record( linkPath );
  var got = self.provider.filesAreHardLinked([ fileRecord, linkRecord ]);
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

  if( Config.platform === 'browser' || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
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
  self.provider.softLink( filePath2, filePath );
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
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( filePath ), self.provider.recordFactory().record( filePath2 ) );
  test.identical( got, true );

  //

  test.case = 'two file records asociated with two regular files, same content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.fileWrite( filePath2, textData1 );
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( filePath ), self.provider.recordFactory().record( filePath2 ) );
  test.identical( got, true );

  //

  test.case = 'two file records asociated with two regular files, diff content';
  var filePath = test.context.makePath( 'written/filesAreSame/file' );
  var filePath2 = test.context.makePath( 'written/filesAreSame/file2' );
  self.provider.fileWrite( filePath, textData1 );
  self.provider.filesDelete( filePath2 );
  self.provider.fileWrite( filePath2, textData2 );
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( filePath ), self.provider.recordFactory().record( filePath2 ) );
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
  self.provider.softLink( linkPath, filePath );
  self.provider.softLink( linkPath2, filePath2 );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( linkPath ), self.provider.recordFactory().record( linkPath2 ) );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( linkPath ), self.provider.recordFactory().record( linkPath2 ) );
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
  self.provider.softLink( linkPath, filePath );
  self.provider.softLink( linkPath2, filePath2 );
  /* resolvingSoftLink off */
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( linkPath ), self.provider.recordFactory().record( linkPath2 ) );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );
  test.identical( got, false );
  /* resolvingSoftLink on */
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var got = self.provider.filesAreSame( self.provider.recordFactory().record( linkPath ), self.provider.recordFactory().record( linkPath2 ) );
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

  if( Config.platform === 'browser' || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
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
    catch( err )
    {
      _.errLog( err );
    }

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

  if( Config.platform === 'browser' || test.context.providerIsInstanceOf( _.FileProvider.Extract ) )
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

  test.case = 'terminal file as directory';
  self.provider.fileWrite( srcPath, srcPath );
  var filePath = self.provider.path.join( srcPath, 'notExistingFile' );
  var got = self.provider.fileExists( filePath );
  test.identical( got, false );

  test.case = 'regular file';
  self.provider.fileWrite( srcPath, srcPath );
  var got = self.provider.fileExists( srcPath );
  test.identical( got, true );

  test.case = 'directory';
  self.provider.dirMakeForFile( srcPath );
  var got = self.provider.fileExists( testDirPath );
  test.is( self.provider.isDir( testDirPath ) );
  test.identical( got, true );

  test.case = 'hard link to file';
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.hardLink( dstPath, srcPath );
  var got = self.provider.fileExists( dstPath );
  test.is( self.provider.filesAreHardLinked([ dstPath, srcPath ]) );
  test.identical( got, true );

  if( !test.context.symlinkIsAllowed() )
  return;

  test.case = 'soft link to file';
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.softLink( dstPath, srcPath );
  var got = self.provider.fileExists( dstPath );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( got, true );

  test.case = 'soft link to file that not exists';
  self.provider.filesDelete( srcPath );
  self.provider.softLink({ dstPath : dstPath, srcPath : srcPath, allowingMissing : 1 });
  var got = self.provider.fileExists( dstPath );
  test.is( self.provider.isSoftLink( dstPath ) );
  test.identical( got, true );
}

//

function pathResolve( test )
{
  let self = this;
  let resolve = _.routineJoin( self.provider.path, self.provider.path.resolve );
  let join = _.routineJoin( self.provider.path, self.provider.path.join );
  let current = _.routineJoin( self.provider.path, self.provider.path.current );

  test.case = 'join windows os paths';
  var got = resolve( 'c:\\', 'foo\\', 'bar\\' );
  var expected = '/c/foo/bar';
  test.identical( got, expected );

  test.case = 'join unix os paths';
  var got = resolve( '/bar/', '/baz', 'foo/', '.' )
  var expected = '/baz/foo';
  test.identical( got, expected );

  test.case = 'here cases'; /* */

  var expected = join( current(), 'aa/cc' );
  var got = resolve( 'aa','.','cc' );
  test.identical( got, expected );

  var expected = join( current(), 'aa/cc' );
  var got = resolve( 'aa','cc','.' )
  test.identical( got, expected );

  var expected = join( current(), 'aa/cc' );
  var got = resolve( '.','aa','cc' );
  test.identical( got, expected );

  test.case = 'down cases'; /* */

  var expected = join( current(), 'aa' );
  var got = resolve( '.','aa','cc','..' );
  test.identical( got, expected );

  var expected = current();
  var got = resolve( '.','aa','cc','..','..' );
  test.identical( got, expected );

  var expected = _.strIsolateEndOrNone( current(),'/' )[ 0 ];
  if( current() === '/' )
  expected = '/..';
  var got = resolve( 'aa','cc','..','..','..' );
  test.identical( got, expected );

  test.case = 'like-down or like-here cases'; /* */

  var expected = join( current(), '.x./aa/bb/.x.' );
  var got = resolve( '.x.','aa','bb','.x.' );
  test.identical( got, expected );

  var expected = join( current(), '..x../aa/bb/..x..' );
  var got = resolve( '..x..','aa','bb','..x..' )
  test.identical( got, expected );

  test.case = 'period and double period combined'; /* */

  var expected = '/a/b';
  var got = resolve( '/abc','./../a/b');
  test.identical( got, expected );

  var expected = '/abc/a/b';
  var got = resolve( '/abc','a/.././a/b');
  test.identical( got, expected );

  var expected = '/a/b';
  var got = resolve( '/abc','.././a/b' );
  test.identical( got, expected );

  var expected = '/a/b';
  var got = resolve( '/abc','./.././a/b'  );
  test.identical( got, expected );

  var expected = '/';
  var got = resolve( '/abc','./../.' );
  test.identical( got, expected );

  var expected = '/..';
  var got = resolve( '/abc','./../../.' );
  test.identical( got, expected );

  var expected = '/';
  var got = resolve( '/abc','./../.' );
  test.identical( got, expected );

  //

  var expected = null;
  var got = resolve( null );
  test.identical( got, expected );

  var expected = '/a/b';
  var got = resolve( null, '/a', 'b' );
  test.identical( got, expected );

  var expected = '/a/b';
  var got = resolve( null, '/a', 'b' );
  test.identical( got, expected );

  var expected = join( current(), 'b' );
  var got = resolve( '/a', null, 'b' );
  test.identical( got, expected );

  var expected = null;
  var got = resolve( '/a', 'b', null );
  test.identical( got, expected );

  var expected = '/b';
  var got = resolve( null, 'a', '/b' );
  test.identical( got, expected );

  var expected = '/b';
  var got = resolve( 'a', null, '/b' );
  test.identical( got, expected );

  var expected = null;
  var got = resolve( 'a', '/b', null );
  test.identical( got, expected );

  var expected = '/b';
  var got = resolve( null, '/a', '../b' );
  test.identical( got, expected );

  var expected = join( self.provider.path.dir( current() ), 'b' );
  var got = resolve( '/a', null, '../b' );
  test.identical( got, expected );

  if( !Config.debug ) //
  return;

  test.case = 'nothing passed';
  test.shouldThrowErrorSync( function()
  {
    resolve();
  });

  test.case = 'non string passed';
  test.shouldThrowErrorSync( function()
  {
    resolve( {} );
  });

}

//

function uriResolve( test )
{
  let self = this;
  let resolve = _.routineJoin( self.provider.path, self.provider.path.resolve );
  let join = _.routineJoin( self.provider.path, self.provider.path.join );
  let current = _.routineJoin( self.provider.path, self.provider.path.current );

  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( 1,1 );
    return;
  }

  test.open( 'with protocol' );

  var got = resolve( 'http://www.site.com:13','a' );
  test.identical( got, join( current(), 'http://www.site.com:13/a' ) );

  var got = resolve( 'http://www.site.com:13/','a' );
  test.identical( got, join( current(), 'http://www.site.com:13/a' ) );

  var got = resolve( 'http://www.site.com:13/','a','b' );
  test.identical( got, join( current(), 'http://www.site.com:13/a/b' ) );

  var got = resolve( 'http://www.site.com:13','a', '/b' );
  test.identical( got, join( current(), 'http:///b' ) );

  var got = resolve( 'http://www.site.com:13/','a','b','.' );
  test.identical( got, join( current(), 'http://www.site.com:13/a/b' ) );

  var got = resolve( 'http://www.site.com:13','a', '/b', 'c' );
  test.identical( got, join( current(), 'http:///b/c' ) );

  var got = resolve( 'http://www.site.com:13','/a/', '/b/', 'c/', '.' );
  test.identical( got, join( current(), 'http:///b/c' ) );

  var got = resolve( 'http://www.site.com:13','a', '.', 'b' );
  test.identical( got, join( current(), 'http://www.site.com:13/a/b' ) );

  var got = resolve( 'http://www.site.com:13/','a', '.', 'b' );
  test.identical( got, join( current(), 'http://www.site.com:13/a/b' ) );

  var got = resolve( 'http://www.site.com:13','a', '..', 'b' );
  test.identical( got, join( current(), 'http://www.site.com:13/b' ) );

  var got = resolve( 'http://www.site.com:13','a', '..', '..', 'b' );
  test.identical( got, join( current(), 'http://b' ) );

  var got = resolve( 'http://www.site.com:13','.a.', 'b', '.c.' );
  test.identical( got, join( current(), 'http://www.site.com:13/.a./b/.c.' ) );

  var got = resolve( 'http://www.site.com:13','a/../' );
  test.identical( got, join( current(), 'http://www.site.com:13' ) );

  test.close( 'with protocol' );

  /* - */

  test.open( 'with null protocol' );

  var got = resolve( '://www.site.com:13','a' );
  test.identical( got, join( current(), '://www.site.com:13/a' ) );

  var got = resolve( '://www.site.com:13','a', '/b' );
  test.identical( got, join( current(), ':///b' ) );

  var got = resolve( '://www.site.com:13','a', '/b', 'c' );
  test.identical( got, join( current(), ':///b/c' ) );

  var got = resolve( '://www.site.com:13','/a/', '/b/', 'c/', '.' );
  test.identical( got, join( current(), ':///b/c' ) );

  var got = resolve( '://www.site.com:13','a', '.', 'b' );
  test.identical( got, join( current(), '://www.site.com:13/a/b' ) );

  var got = resolve( '://www.site.com:13','a', '..', 'b' );
  test.identical( got, join( current(), '://www.site.com:13/b' ) );

  var got = resolve( '://www.site.com:13','a', '..', '..', 'b' );
  test.identical( got, join( current(), '://b' ) );

  var got = resolve( '://www.site.com:13','.a.', 'b','.c.' );
  test.identical( got, join( current(), '://www.site.com:13/.a./b/.c.' ) );

  var got = resolve( '://www.site.com:13','a/../' );
  test.identical( got, join( current(), '://www.site.com:13' ) );

  test.close( 'with null protocol' );

  /* */

  var got = resolve( ':///www.site.com:13','a' );
  test.identical( got, ':///www.site.com:13/a' );

  var got = resolve( ':///www.site.com:13/','a' );
  test.identical( got, ':///www.site.com:13/a' );

  var got = resolve( ':///www.site.com:13','a', '/b' );
  test.identical( got, ':///b' );

  var got = resolve( ':///www.site.com:13','a', '/b', 'c' );
  test.identical( got, ':///b/c' );

  var got = resolve( ':///www.site.com:13','/a/', '/b/', 'c/', '.' );
  test.identical( got, ':///b/c' );

  var got = resolve( ':///www.site.com:13','a', '.', 'b' );
  test.identical( got, ':///www.site.com:13/a/b' );

  var got = resolve( ':///www.site.com:13/','a', '.', 'b' );
  test.identical( got, ':///www.site.com:13/a/b' );

  var got = resolve( ':///www.site.com:13','a', '..', 'b' );
  test.identical( got, ':///www.site.com:13/b' );

  var got = resolve( ':///www.site.com:13','a', '..', '..', 'b' );
  test.identical( got, ':///b' );

  var got = resolve( ':///www.site.com:13','.a.', 'b','.c.' );
  test.identical( got, ':///www.site.com:13/.a./b/.c.' );

  var got = resolve( ':///www.site.com:13/','.a.', 'b','.c.' );
  test.identical( got, ':///www.site.com:13/.a./b/.c.' );

  var got = resolve( ':///www.site.com:13','a/../' );
  test.identical( got, ':///www.site.com:13' );

  var got = resolve( ':///www.site.com:13/','a/../' );
  test.identical( got, ':///www.site.com:13' );

  /* */

  var got = resolve( '/some/staging/index.html','a' );
  test.identical( got, '/some/staging/index.html/a' );

  var got = resolve( '/some/staging/index.html','.' );
  test.identical( got, '/some/staging/index.html' );

  var got = resolve( '/some/staging/index.html/','a' );
  test.identical( got, '/some/staging/index.html/a' );

  var got = resolve( '/some/staging/index.html','a', '/b' );
  test.identical( got, '/b' );

  var got = resolve( '/some/staging/index.html','a', '/b', 'c' );
  test.identical( got, '/b/c' );

  var got = resolve( '/some/staging/index.html','/a/', '/b/', 'c/', '.' );
  test.identical( got, '/b/c' );

  var got = resolve( '/some/staging/index.html','a', '.', 'b' );
  test.identical( got, '/some/staging/index.html/a/b' );

  var got = resolve( '/some/staging/index.html/','a', '.', 'b' );
  test.identical( got, '/some/staging/index.html/a/b' );

  var got = resolve( '/some/staging/index.html','a', '..', 'b' );
  test.identical( got, '/some/staging/index.html/b' );

  var got = resolve( '/some/staging/index.html','a', '..', '..', 'b' );
  test.identical( got, '/some/staging/b' );

  var got = resolve( '/some/staging/index.html','.a.', 'b','.c.' );
  test.identical( got, '/some/staging/index.html/.a./b/.c.' );

  var got = resolve( '/some/staging/index.html/','.a.', 'b','.c.' );
  test.identical( got, '/some/staging/index.html/.a./b/.c.' );

  var got = resolve( '/some/staging/index.html','a/../' );
  test.identical( got, '/some/staging/index.html' );

  var got = resolve( '/some/staging/index.html/','a/../' );
  test.identical( got, '/some/staging/index.html' );

  var got = resolve( '//some/staging/index.html', '.', 'a' );
  test.identical( got, '//some/staging/index.html/a' )

  var got = resolve( '///some/staging/index.html', 'a', '.', 'b', '..' );
  test.identical( got, '///some/staging/index.html/a' )

  var got = resolve( 'file:///some/staging/index.html', '../..' );
  test.identical( got, 'file:///some' )

  var got = resolve( 'svn+https://user@subversion.com/svn/trunk', '../a', 'b', '../c' );
  test.identical( got, join( current(), 'svn+https://user@subversion.com/svn/a/c' ) );

  var got = resolve( 'complex+protocol://www.site.com:13/path/name?query=here&and=here#anchor', '../../path/name' );
  test.identical( got, join( current(), 'complex+protocol://www.site.com:13/path/name?query=here&and=here#anchor' ) );

  var got = resolve( 'https://web.archive.org/web/*\/http://www.heritage.org/index/ranking', '../../../a.com' );
  test.identical( got, join( current(), 'https://web.archive.org/web/*\/http://a.com' ) );

  var got = resolve( '127.0.0.1:61726', '../path'  );
  test.identical( got, join( current(),'path' ) )

  var got = resolve( 'http://127.0.0.1:61726', '../path'  );
  test.identical( got, join( current(), 'http://path' ) );

  //

  var expected = 'file:///staging';
  var got = resolve( null, 'file:///some/index.html', '/staging' );
  test.identical( got, expected );

  var expected = join( current(), 'staging' );
  var got = resolve( 'file:///some/index.html', null, 'staging' );
  test.identical( got, expected );

  var expected = null;
  var got = resolve( 'file:///some', 'staging', null );
  test.identical( got, expected );

  var expected = 'file:///some';
  var got = resolve( null, 'a', 'file:///some' );
  test.identical( got, expected );

  var expected = 'file:///some';
  var got = resolve( 'a', null, 'file:///some' );
  test.identical( got, expected );

  var expected = null;
  var got = resolve( 'a', 'file:///some', null );
  test.identical( got, expected );

  var expected = 'file:///b';
  var got = resolve( null, 'file:///some', '../b' );
  test.identical( got, expected );

  var expected = join( self.provider.path.dir( current() ), 'b' );
  var got = resolve( 'file:///some', null, '../b' );
  test.identical( got, expected );

}

//

function pathResolveLinkChain( test )
{
  let self = this;

  if( !self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( 1,1 );
    return;
  }

  let o1 =
  {
    hub : null,
    filePath : null,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    preservingRelative : 0,
    allowingMissing : 1,
    throwing : 1
  }

  let dir = test.context.makePath( 'written/pathResolveLinkChain' );
  let filePath = test.context.makePath( 'written/pathResolveLinkChain/file' );
  let linkPath = test.context.makePath( 'written/pathResolveLinkChain/link' );
  let linkPath2 = test.context.makePath( 'written/pathResolveLinkChain/link2' );
  let linkPath3 = test.context.makePath( 'written/pathResolveLinkChain/link3' );
  let path = self.provider.path;

  self.provider.fieldPush( 'usingTextLink', true );

  /*
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    preservingRelative : [ 0,1 ],
    allowingMissing : [ 0,1 ],
    throwing : 1
  */

  /* basic */

  test.case = 'not existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ filePath, null ] )
  test.identical( o.found, [ filePath, null ] )

  test.case = 'existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ filePath ] )
  test.identical( o.found, [ filePath ] )

  test.case = 'hardlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath ] )
  test.identical( o.found, [ linkPath ] )

  test.case = 'softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,filePath ] )
  test.identical( o.found, [ linkPath,filePath ] )

  test.case = 'relative softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '../file' );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, filePath ] )
  test.identical( o.found, [ linkPath,filePath ] )

  test.case = 'relative softlink, preservingRelative : 1';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '../file' );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  var expectedFound = [ linkPath, '../file', filePath ]
  var expectedResult = [ linkPath, filePath ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  test.case = 'textlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, filePath ] )
  test.identical( o.found, [ linkPath, filePath ] )

  //

  test.case = 'absolute softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePath,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedResult =
  [
    linkPath,
    filePath,
    null
  ]
  var expectedFound =
  [
    linkPath,
    filePath,
    null
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'absolute softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePath,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, preservingRelative : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedResult =
  [
    linkPath,
    filePath,
    null
  ]
  var expectedFound =
  [
    linkPath,
    filePath,
    null
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'relative softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  var filePathRelative = self.provider.path.relative( linkPath,filePath );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePathRelative,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedResult =
  [
    linkPath,
    filePath,
    null
  ]
  var expectedFound =
  [
    linkPath,
    filePath,
    null
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'relative softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  var filePathRelative = self.provider.path.relative( linkPath,filePath );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePathRelative,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, preservingRelative : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedFound =
  [
    linkPath,
    '../file',
    filePath,
    null
  ]
  var expectedResult =
  [
    linkPath,
    filePath,
    null
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'absolute softlink to missing, allowingMissing : 0'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePath,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  //

  test.case = 'absolute softlink to missing, allowingMissing : 1'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePath,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedFound =
  [
    linkPath,
    filePath,
    null
  ]
  var expectedResult =
  [
    linkPath,
    filePath,
    null
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'relative softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  var filePathRelative = self.provider.path.relative( linkPath,filePath );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePathRelative,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0  } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  //

  test.case = 'relative softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  var filePathRelative = self.provider.path.relative( linkPath,filePath );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePathRelative,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1  } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedFound =
  [
    linkPath,
    filePath,
    null
  ]
  var expectedResult =
  [
    linkPath,
    filePath,
    null
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  /* chain */

  test.case = 'soft-soft-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath2, filePath );
  self.provider.softLink( linkPath, linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,filePath ] );
  test.identical( o.found, [ linkPath,linkPath2,filePath ] );

  test.case = 'soft-soft-file, preservingRelative';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath2, filePath );
  self.provider.softLink( linkPath, linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,filePath ] );
  test.identical( o.found, [ linkPath,linkPath2,filePath ] );

  test.case = 'text-text-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, linkPath2, filePath ] );
  test.identical( o.found, [ linkPath, linkPath2, filePath ] );

  test.case = 'text-text-file, preservingRelative';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + filePath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, linkPath2, filePath ] );
  test.identical( o.found, [ linkPath, linkPath2, filePath ] );

  test.case = 'soft-text-soft-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.softLink( linkPath, linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath3,filePath ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath3,filePath ] );

  test.case = 'soft-text-soft-file, preservingRelative';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath3 );
  self.provider.softLink( linkPath, linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath3,filePath ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath3,filePath ] );

  test.case = 'text-soft-text-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, linkPath2, linkPath3, filePath ] );
  test.identical( o.found, [ linkPath, linkPath2, linkPath3, filePath ] );

  test.case = 'text-soft-text-file, preservingRelative';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.softLink( linkPath2, linkPath3 );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, linkPath2, linkPath3, filePath ] );
  test.identical( o.found, [ linkPath, linkPath2, linkPath3, filePath ] );

  test.case = 'relative soft-relative soft-soft-file, preservingRelative : 1';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath3, filePath );
  self.provider.softLink( linkPath2, '../link3' );
  self.provider.softLink( linkPath, '../link2' );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  var expectedFound =
  [
    linkPath,
    '../link2',
    linkPath2,
    '../link3',
    linkPath3,
    filePath
  ]
  var expectedResult =
  [
    linkPath,
    linkPath2,
    linkPath3,
    filePath
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound);
  debugger;

  test.case = 'soft-hard-text-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.hardLink( linkPath2, linkPath3 );
  self.provider.softLink( linkPath, linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( o.result, [ linkPath, linkPath2, filePath ] )
    test.identical( o.found, [ linkPath, linkPath2, filePath ] )
  }
  else
  {
    test.identical( o.result, [ linkPath, linkPath2, linkPath3, filePath ] )
    test.identical( o.found, [ linkPath, linkPath2, linkPath3, filePath ] )
  }

  test.case = 'relative soft-hard-text-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.hardLink( linkPath2, linkPath3 );
  self.provider.softLink( linkPath, self.provider.path.relative( linkPath, linkPath2 ) );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 0 } );
  self.provider.pathResolveLinkChain( o );
  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( o.result, [ linkPath, linkPath2, filePath ] )
    test.identical( o.found, [ linkPath, linkPath2, filePath ] )
  }
  else
  {
    test.identical( o.result, [ linkPath, linkPath2, linkPath3, filePath ] )
    test.identical( o.found, [ linkPath, linkPath2, linkPath3, filePath ] )
  }

  test.case = 'relative soft-hard-text-file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath3, 'link ' + filePath );
  self.provider.hardLink( linkPath2, linkPath3 );
  self.provider.softLink( linkPath, self.provider.path.relative( linkPath, linkPath2 ) );
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  self.provider.pathResolveLinkChain( o );
  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( o.found, [ linkPath, '../link2', linkPath2, filePath ] )
    test.identical( o.result, [ linkPath, linkPath2, filePath ]  )
  }
  else
  {
    test.identical( o.found, [ linkPath, '../link2', linkPath2, linkPath3, filePath ] )
    test.identical( o.result, [ linkPath, linkPath2, linkPath3, filePath ] )
  }

  /* chain, resolvingIntermediateDirectories : [ 0, 1 ] */

  test.case = 'two soft links in path';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '..' );
  self.provider.softLink( linkPath2, '../file' );
  var o = _.mapExtend( null, o1, { filePath : path.join( dir, 'link/link2' ) , preservingRelative : 1, resolvingIntermediateDirectories : 0 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedFound =
  [
    path.join( dir, 'link/link2' ),
    '../file',
    path.join( dir, 'link/file' ),
  ]
  var expectedResult =
  [
    path.join( dir, 'link/link2' ),
    path.join( dir, 'link/file' ),
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'two soft links in path';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '..' );
  self.provider.softLink( linkPath2, '../file' );
  var o = _.mapExtend( null, o1, { filePath : path.join( dir, 'link/link2' ) , preservingRelative : 1, resolvingIntermediateDirectories : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  var expectedFound =
  [
    path.join( dir, 'link/link2' ),
    path.join( dir, 'link' ),
    '..',
    dir,
    linkPath2,
    '../file',
    filePath,
  ]
  var expectedResult =
  [
    path.join( dir, 'link/link2' ),
    path.join( dir, 'link' ),
    dir,
    linkPath2,
    filePath
  ]
  test.identical( o.result, expectedResult );
  test.identical( o.found, expectedFound );

  //

  test.case = 'several absolute soft links in path';
  var dirPath = _.path.dir( filePath );
  var dirPath1 = _.path.join( dirPath, 'dir1' );
  var dirPath2 = _.path.join( dirPath, 'dir2' );
  var pathToFile = _.path.join( dirPath, 'file' );
  var linkInDir = _.path.join( dirPath, 'linkToDir1' );
  var linkInDir1 = _.path.join( dirPath1, 'linkToDir2' );
  var linkInDir2 = _.path.join( dirPath2, 'linkToFile' );
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( dirPath );
  self.provider.dirMake( dirPath1 );
  self.provider.dirMake( dirPath2 );
  self.provider.fileWrite( pathToFile,pathToFile );
  self.provider.softLink( linkInDir, dirPath1 );
  self.provider.softLink( linkInDir1, dirPath2 );
  self.provider.softLink( linkInDir2, pathToFile );

  /*
    dir :
      dir1 :
        linkToDir2
      dir2 :
        linkToFile
      linkToDir1
      file

    path : 'dir/linkToDir1/linkToDir2/linkToFile' -> 'dir/file'
  */

  var testPath = _.path.join( dirPath, 'linkToDir1/linkToDir2/linkToFile' )
  var o = _.mapExtend( null, o1, { filePath : testPath , preservingRelative : 1, resolvingIntermediateDirectories : 0 } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ testPath, pathToFile ] )
  test.identical( o.found, [ testPath, pathToFile ] )

  //

  test.case = 'several absolute soft links in path';
  var dirPath = _.path.dir( filePath );
  var dirPath1 = _.path.join( dirPath, 'dir1' );
  var dirPath2 = _.path.join( dirPath, 'dir2' );
  var pathToFile = _.path.join( dirPath, 'file' );
  var linkInDir = _.path.join( dirPath, 'linkToDir1' );
  var linkInDir1 = _.path.join( dirPath1, 'linkToDir2' );
  var linkInDir2 = _.path.join( dirPath2, 'linkToFile' );
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( dirPath );
  self.provider.dirMake( dirPath1 );
  self.provider.dirMake( dirPath2 );
  self.provider.fileWrite( pathToFile,pathToFile );
  self.provider.softLink( linkInDir, dirPath1 );
  self.provider.softLink( linkInDir1, dirPath2 );
  self.provider.softLink( linkInDir2, pathToFile );

  /*
    dir :
      dir1 :
        linkToDir2
      dir2 :
        linkToFile
      linkToDir1
      file

    path : 'dir/linkToDir1/linkToDir2/linkToFile' -> 'dir/file'
  */

  var testPath = _.path.join( dirPath, 'linkToDir1/linkToDir2/linkToFile' )
  var o = _.mapExtend( null, o1, { filePath : testPath , preservingRelative : 1, resolvingIntermediateDirectories : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ testPath, linkInDir, dirPath1, linkInDir1, dirPath2, linkInDir2, pathToFile ] )
  test.identical( o.found, [ testPath, linkInDir, dirPath1, linkInDir1, dirPath2, linkInDir2, pathToFile ] )

  //

  test.case = 'several relative soft links in path';
  var dirPath = _.path.dir( filePath );
  var dirPath1 = _.path.join( dirPath, 'dir1' );
  var dirPath2 = _.path.join( dirPath, 'dir2' );
  var pathToFile = _.path.join( dirPath, 'file' );
  var linkInDir = _.path.join( dirPath, 'linkToDir1' );
  var linkInDir1 = _.path.join( dirPath1, 'linkToDir2' );
  var linkInDir2 = _.path.join( dirPath2, 'linkToFile' );
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( dirPath );
  self.provider.dirMake( dirPath1 );
  self.provider.dirMake( dirPath2 );
  self.provider.fileWrite( pathToFile,pathToFile );
  self.provider.softLink( linkInDir, self.provider.path.relative( linkInDir, dirPath1 ) );
  self.provider.softLink( linkInDir1, self.provider.path.relative( linkInDir1, dirPath2 ) );
  self.provider.softLink( linkInDir2, self.provider.path.relative( linkInDir2, pathToFile ) );

  /*
    dir :
      dir1 :
        linkToDir2
      dir2 :
        linkToFile
      linkToDir1
      file

    path : 'dir/linkToDir1/linkToDir2/linkToFile' -> 'dir/file'
  */

  var testPath = _.path.join( dirPath, 'linkToDir1/linkToDir2/linkToFile' )
  var o = _.mapExtend( null, o1, { filePath : testPath , preservingRelative : 1, resolvingIntermediateDirectories : 0 } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.found, [ testPath, '../../file', _.path.join( dirPath, 'linkToDir1/file'), null ] )
  test.identical( o.result, [ testPath, _.path.join( dirPath, 'linkToDir1/file'), null ] )

  //

  test.case = 'several relative soft links in path';
  var dirPath = _.path.dir( filePath );
  var dirPath1 = _.path.join( dirPath, 'dir1' );
  var dirPath2 = _.path.join( dirPath, 'dir2' );
  var pathToFile = _.path.join( dirPath, 'file' );
  var linkInDir = _.path.join( dirPath, 'linkToDir1' );
  var linkInDir1 = _.path.join( dirPath1, 'linkToDir2' );
  var linkInDir2 = _.path.join( dirPath2, 'linkToFile' );
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( dirPath );
  self.provider.dirMake( dirPath1 );
  self.provider.dirMake( dirPath2 );
  self.provider.fileWrite( pathToFile,pathToFile );
  self.provider.softLink( linkInDir, self.provider.path.relative( linkInDir, dirPath1 ) );
  self.provider.softLink( linkInDir1, self.provider.path.relative( linkInDir1, dirPath2 ) );
  self.provider.softLink( linkInDir2, self.provider.path.relative( linkInDir2, pathToFile ) );

  /*
    dir :
      dir1 :
        linkToDir2
      dir2 :
        linkToFile
      linkToDir1
      file

    path : 'dir/linkToDir1/linkToDir2/linkToFile' -> 'dir/file'
  */

  var testPath = _.path.join( dirPath, 'linkToDir1/linkToDir2/linkToFile' )
  var o = _.mapExtend( null, o1, { filePath : testPath , preservingRelative : 1, resolvingIntermediateDirectories : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.found, [ testPath, linkInDir, '../dir1', dirPath1, linkInDir1, '../../dir2', dirPath2, linkInDir2, '../../file', pathToFile ] )
  test.identical( o.result, [ testPath, linkInDir, dirPath1, linkInDir1, dirPath2, linkInDir2, pathToFile ] )

  //

  test.case = 'several absolute text links in path';
  var dirPath = _.path.dir( filePath );
  var dirPath1 = _.path.join( dirPath, 'dir1' );
  var dirPath2 = _.path.join( dirPath, 'dir2' );
  var pathToFile = _.path.join( dirPath, 'file' );
  var linkInDir = _.path.join( dirPath, 'linkToDir1' );
  var linkInDir1 = _.path.join( dirPath1, 'linkToDir2' );
  var linkInDir2 = _.path.join( dirPath2, 'linkToFile' );
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( dirPath );
  self.provider.dirMake( dirPath1 );
  self.provider.dirMake( dirPath2 );
  self.provider.fileWrite( pathToFile,pathToFile );
  self.provider.textLink( linkInDir, dirPath1 );
  self.provider.textLink( linkInDir1, dirPath2 );
  self.provider.textLink( linkInDir2, pathToFile );

  /*
    dir :
      dir1 :
        linkToDir2
      dir2 :
        linkToFile
      linkToDir1
      file

    path : 'dir/linkToDir1/linkToDir2/linkToFile' -> 'dir/file'
  */

  var testPath = _.path.join( dirPath, 'linkToDir1/linkToDir2/linkToFile' )
  var o = _.mapExtend( null, o1, { filePath : testPath , preservingRelative : 1, resolvingIntermediateDirectories : 1 } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ testPath, linkInDir, dirPath1, linkInDir1, dirPath2, linkInDir2, pathToFile ] )
  test.identical( o.found, [ testPath, linkInDir, dirPath1, linkInDir1, dirPath2, linkInDir2, pathToFile ] )

  //

  test.case = 'several absolute text links in path';
  var dirPath = _.path.dir( filePath );
  var dirPath1 = _.path.join( dirPath, 'dir1' );
  var dirPath2 = _.path.join( dirPath, 'dir2' );
  var pathToFile = _.path.join( dirPath, 'file' );
  var linkInDir = _.path.join( dirPath, 'linkToDir1' );
  var linkInDir1 = _.path.join( dirPath1, 'linkToDir2' );
  var linkInDir2 = _.path.join( dirPath2, 'linkToFile' );
  self.provider.filesDelete( dirPath );
  self.provider.dirMake( dirPath );
  self.provider.dirMake( dirPath1 );
  self.provider.dirMake( dirPath2 );
  self.provider.fileWrite( pathToFile,pathToFile );
  self.provider.textLink( linkInDir, dirPath1 );
  self.provider.textLink( linkInDir1, dirPath2 );
  self.provider.textLink( linkInDir2, pathToFile );

  /*
    dir :
      dir1 :
        linkToDir2
      dir2 :
        linkToFile
      linkToDir1
      file

    path : 'dir/linkToDir1/linkToDir2/linkToFile' -> 'dir/file'
  */

  var testPath = _.path.join( dirPath, 'linkToDir1/linkToDir2/linkToFile' )
  var o = _.mapExtend( null, o1, { filePath : testPath , preservingRelative : 1, resolvingIntermediateDirectories : 0 } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ testPath, null ] )
  test.identical( o.found, [ testPath, null ] )

  /* cycle, throwing : [ 0,1 ], allowingMissing : [ 0,1 ] */

  test.case = 'self cycle softlink, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath, null ] );

  test.case = 'self cycle softlink, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  test.case = 'self cycle softlink, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath, null ] );

  test.case = 'self cycle softlink, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 0 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath, null ] );

  test.case = 'self cycle text, throwing on '
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath, 'link ' + '../link' );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath, null ] );

  test.case = 'self cycle text, throwing on '
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath, 'link ' + '../link' );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  test.case = 'self cycle text, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath, 'link ' + '../link' );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath, null ] );

  test.case = 'self cycle text, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath, 'link ' + '../link' );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 0 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath, null ] );

  test.case = 'cycle softlink, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle softlink, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  test.case = 'cycle softlink, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle softlink, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 0 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle text link, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle text link, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  test.case = 'cycle text link, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle text link, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.fileWrite( linkPath, 'link ' + linkPath2 );
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle soft text, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle soft text, throwing on'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 1, allowingMissing : 0 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );

  test.case = 'cycle soft text, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 1 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );

  test.case = 'cycle soft text, throwing off'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( linkPath2, 'link ' + linkPath );
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, throwing : 0, allowingMissing : 0 } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,linkPath2,linkPath, null ] );
  test.identical( o.found, [ linkPath,linkPath2,linkPath, null ] );


  /* allowingMissing : 0 throwing : 1, preservingRelative : [ 0, 1 ] */

  o1.allowingMissing = 0;
  o1.throwing = 1;

  //

  test.case = 'not existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ filePath, null ] )
  test.identical( o.found, [ filePath, null ] )

  test.case = 'existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ filePath ] )
  test.identical( o.found, [ filePath ] )

  test.case = 'hardlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath ] )
  test.identical( o.found, [ linkPath ] )

  test.case = 'softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,filePath ] )
  test.identical( o.found, [ linkPath,filePath ] )

  test.case = 'relative softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '../file' );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, filePath ] )
  test.identical( o.found, [ linkPath,filePath ] )

  test.case = 'textlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, filePath ] )
  test.identical( o.found, [ linkPath, filePath ] )

  test.case = 'softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,filePath, null ] )

  test.case = 'relative softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,filePath, null ] )

  test.case = 'relative softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath, '../file', filePath, null ] )

  test.case = 'textlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,filePath, null ] )

  test.case = 'textlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,'../file',filePath, null ] )

  test.case = 'double textlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.textLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  test.case = 'double softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  test.case = 'soft to text to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  test.case = 'text to soft to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.textLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.shouldThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  /* allowingMissing : 0 throwing : 0, preservingRelative : [ 0, 1 ] */

  o1.allowingMissing = 0;
  o1.throwing = 0;

  //

  test.case = 'not existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ filePath, null ] )
  test.identical( o.found, [ filePath, null ] )

  test.case = 'existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ filePath ] )
  test.identical( o.found, [ filePath ] )

  test.case = 'hardlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath ] )
  test.identical( o.found, [ linkPath ] )

  test.case = 'softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath,filePath ] )
  test.identical( o.found, [ linkPath,filePath ] )

  test.case = 'relative softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '../file' );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, filePath ] )
  test.identical( o.found, [ linkPath,filePath ] )

  test.case = 'textlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveLinkChain( o );
  test.identical( o.result, [ linkPath, filePath ] )
  test.identical( o.found, [ linkPath, filePath ] )

  test.case = 'softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,filePath, null ] )

  test.case = 'relative softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,filePath, null ] )

  test.case = 'relative softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath, '../file', filePath, null ] )

  test.case = 'textlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,filePath, null ] )

  test.case = 'textlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath, preservingRelative : 1 } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,filePath, null ] )
  test.identical( o.found, [ linkPath,'../file',filePath, null ] )

  test.case = 'double textlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.textLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  test.case = 'double softlink to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  test.case = 'soft to text to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.textLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  test.case = 'text to soft to missing';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.textLink({ dstPath : linkPath, srcPath : linkPath2 });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  test.mustNotThrowError( () => self.provider.pathResolveLinkChain( o ) );
  test.identical( o.result, [ linkPath,linkPath2, filePath, null ] )
  test.identical( o.found, [ linkPath,linkPath2, filePath, null ] )

  self.provider.fieldPop( 'usingTextLink', true );
}

pathResolveLinkChain.timeOut = 30000;

//

function pathResolveLink( test )
{
  let self = this;

  if( !self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.identical( 1,1 );
    return;
  }

  let dir = test.context.makePath( 'written/pathResolveLinkChain' );
  let filePath = test.context.makePath( 'written/pathResolveLinkChain/file' );
  let linkPath = test.context.makePath( 'written/pathResolveLinkChain/link' );
  let linkPath2 = test.context.makePath( 'written/pathResolveLinkChain/link2' );
  let linkPath3 = test.context.makePath( 'written/pathResolveLinkChain/link3' );
  let path = self.provider.path;

  self.provider.fieldPush( 'usingTextLink', true );

  //

  test.case = 'not existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );

  var got = self.provider.pathResolveLink
  ({
     filePath : filePath,
     allowingMissing : 0,
     throwing : 0,
  });
  test.identical( got, null );

  var got = self.provider.pathResolveLink
  ({
     filePath : filePath,
     allowingMissing : 1,
     throwing : 0,
  });
  test.identical( got, filePath );

  test.shouldThrowError( () =>
  {
    self.provider.pathResolveLink
    ({
       filePath : filePath,
       allowingMissing : 0,
       throwing : 1,
    });
  })

  var got = self.provider.pathResolveLink
  ({
     filePath : filePath,
     allowingMissing : 1,
     throwing : 1,
  });
  test.identical( got, filePath );

  //

  test.case = 'absolute softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePath,
    makingDirectory : 1,
    allowingMissing : 1
  });

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 0,
     throwing : 0,
  });
  test.identical( got, null );

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 1,
     throwing : 0,
  });
  test.identical( got, filePath );

  test.shouldThrowError( () =>
  {
    self.provider.pathResolveLink
    ({
      filePath : linkPath,
      allowingMissing : 0,
      throwing : 1,
    });
  })

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 1,
     throwing : 1,
  });
  test.identical( got, filePath );

  //

  test.case = 'self cycle softlink'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../link', allowingMissing : 1, makingDirectory : 1 });

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 0,
     throwing : 0,
  });
  test.identical( got, null );

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 1,
     throwing : 0,
  });
  test.identical( got, linkPath );

  test.shouldThrowError( () =>
  {
    self.provider.pathResolveLink
    ({
      filePath : linkPath,
      allowingMissing : 0,
      throwing : 1,
    });
  })
  test.identical( got, linkPath );

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 1,
     throwing : 1,
  });
  test.identical( got, linkPath );

  //

  test.case = 'cycle softlink'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink({ dstPath : linkPath2, srcPath : linkPath, allowingMissing : 1, makingDirectory : 1 });
  self.provider.softLink({ dstPath : linkPath, srcPath : linkPath2, allowingMissing : 1, makingDirectory : 1 });

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 0,
     throwing : 0,
  });
  test.identical( got, null );

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 1,
     throwing : 0,
  });
  test.identical( got, linkPath );

  test.shouldThrowError( () =>
  {
    self.provider.pathResolveLink
    ({
      filePath : linkPath,
      allowingMissing : 0,
      throwing : 1,
    });
  })
  test.identical( got, linkPath );

  var got = self.provider.pathResolveLink
  ({
     filePath : linkPath,
     allowingMissing : 1,
     throwing : 1,
  });
  test.identical( got, linkPath );

  self.provider.fieldPop( 'usingTextLink', true );
}

pathResolveLink.timeOut = 30000;

//

function pathResolveSoftLink( test )
{
  let self = this;

  let filePath = test.context.makePath( 'written/pathResolveSoftLink/file' );
  let linkPath = test.context.makePath( 'written/pathResolveSoftLink/link' );

  var o1 =
  {
  }

  test.case = 'not existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, filePath )

  test.case = 'existing file';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  var o = _.mapExtend( null, o1, { filePath : filePath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, filePath )

  test.case = 'hardlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.hardLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, linkPath )

  test.case = 'softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, filePath )

  test.case = 'relative softlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.softLink( linkPath, '../file' );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, '../file' );

  test.case = 'textlink';
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.fileWrite( filePath, filePath );
  self.provider.fileWrite( linkPath, 'link ' + filePath );
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, linkPath );

  //

  test.case = 'absolute softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePath,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, filePath );

  test.case = 'relative softlink to missing'
  self.provider.filesDelete( _.path.dir( filePath ) );
  var filePathRelative = self.provider.path.relative( linkPath,filePath );
  self.provider.softLink
  ({
    dstPath : linkPath,
    srcPath : filePathRelative,
    makingDirectory : 1,
    allowingMissing : 1
  });
  var o = _.mapExtend( null, o1, { filePath : linkPath } );
  var got = self.provider.pathResolveSoftLink( o );
  test.identical( got, filePathRelative );
}

//

function pathResolveTextLink( test )
{
  let self = this;

  let workDir = test.context.makePath( 'written/pathResolveSoftLink' );
  let filePath = test.context.makePath( 'written/pathResolveSoftLink/file' );
  let linkPath = test.context.makePath( 'written/pathResolveSoftLink/link' );
  let testData = 'pathResolveSoftLink';

  self.provider.fieldPush( 'usingTextLink', 1 )

  test.case = 'regular file';
  self.provider.filesDelete( workDir );
  self.provider.fileWrite( filePath, testData );
  var o = { filePath : filePath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, filePath )

  test.case = 'hardlink to regular file';
  self.provider.filesDelete( workDir );
  self.provider.fileWrite( filePath, testData );
  self.provider.hardLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, linkPath );

  test.case = 'absolute softlink to regular file';
  self.provider.filesDelete( workDir );
  self.provider.fileWrite( filePath, testData );
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, linkPath );

  test.case = 'absolute textlink to regular file';
  self.provider.filesDelete( workDir );
  self.provider.fileWrite( filePath, testData );
  self.provider.textLink({ dstPath : linkPath, srcPath : filePath });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, filePath );

  /*

    Add test cases :

    absolute textlink to file that does not exist
    relative textlink to file that does not exist
    relative textlink to regular file

    use allowingMissing : 1 option to create link for missing file
  */

  test.case = 'absolute textlink to file that does not exist';
  self.provider.filesDelete( workDir );  // remove temp files created by previous test case
  self.provider.textLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1  });
  var o = { filePath : linkPath }; // create options map for current test case
  var got = self.provider.pathResolveTextLink( o ); // call routine and save result
  test.identical( got, filePath ); // check result

  test.case = 'relative textlink to file that does not exist';
  self.provider.filesDelete( workDir );
  self.provider.textLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, '../file' );

  test.case = 'relative textlink to regular file';
  self.provider.filesDelete( workDir );
  self.provider.fileWrite( filePath, testData );
  self.provider.textLink({ dstPath : linkPath, srcPath : '../file' });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, '../file' );  // Throws an error

  test.case = 'absolute softlink to file that does not exist';
  self.provider.filesDelete( workDir );  // remove temp files created by previous test case
  self.provider.softLink({ dstPath : linkPath, srcPath : filePath, allowingMissing : 1, makingDirectory : 1 }); // prepare link for test case
  var o = { filePath : linkPath }; // create options map for current test case
  var got = self.provider.pathResolveTextLink( o ); // call routine and save result
  test.identical( got, linkPath ); // check result

  test.case = 'relative softlink to file that does not exist';
  self.provider.filesDelete( workDir );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../file', allowingMissing : 1, makingDirectory : 1 });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, linkPath );

  test.case = 'relative softlink to regular file';
  self.provider.filesDelete( workDir );
  self.provider.fileWrite( filePath, testData );
  self.provider.softLink({ dstPath : linkPath, srcPath : '../file' });
  var o = { filePath : linkPath };
  var got = self.provider.pathResolveTextLink( o );
  test.identical( got, linkPath );

  self.provider.fieldPop( 'usingTextLink', 1 )

  /**/

  self.provider.fieldPush( 'usingTextLink', 0 );

  /*
    pathResolveTextLink only resolves text link and returns result without any additional checks

    usingTextLink - 1, enables resolving of text link, routine returns resolved path
    usingTextLink - 0, disables resolving of text link, routine always returns original path - o.filePath

    Please duplicate here tests above and adjust expected results.
  */

  self.provider.fieldPop( 'usingTextLink', 0 );
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

    fileReadWithEncoding : fileReadWithEncoding,
    fileWriteWithEncoding : fileWriteWithEncoding,

    fileTouch : fileTouch,
    fileTimeSet : fileTimeSet,

    writeAsyncThrowingError : writeAsyncThrowingError,

    fileCopySync : fileCopySync,
    fileCopyActSync : fileCopyActSync,
    fileCopyRelativePath : fileCopyRelativePath,
    fileCopyLinksSync : fileCopyLinksSync,
    fileCopyAsync : fileCopyAsync,
    fileCopyLinksAsync : fileCopyLinksAsync,
    fileCopySoftLinkResolving : fileCopySoftLinkResolving,
    // fileCopyAsyncThrowingError : fileCopyAsyncThrowingError,/* rewrite this routine */

    fileRenameSync : fileRenameSync,
    fileRenameRelativePath : fileRenameRelativePath,
    fileRenameAsync : fileRenameAsync,
    fileRenameActSync : fileRenameActSync,
    fileRenameSync2 : fileRenameSync2,
    fileRenameSoftLinkResolving : fileRenameSoftLinkResolving,

    fileDeleteSync : fileDeleteSync,
    fileDeleteActSync : fileDeleteActSync,
    fileDeleteAsync : fileDeleteAsync,

    statResolvedReadSync : statResolvedReadSync,
    statReadActSync : statReadActSync,
    statResolvedReadAsync : statResolvedReadAsync,

    dirMakeSync : dirMakeSync,
    dirMakeAsync : dirMakeAsync,

    fileHashSync : fileHashSync,
    fileHashAsync : fileHashAsync,

    dirReadSync : dirReadSync,
    dirReadAsync : dirReadAsync,

    fileWriteSync : fileWriteSync,
    fileWriteLinksSync : fileWriteLinksSync,
    fileWriteAsync : fileWriteAsync,
    fileWriteLinksAsync : fileWriteLinksAsync,

    fileReadAsync : fileReadAsync,

    softLinkSync : softLinkSync,
    softLinkAsync : softLinkAsync,
    softLinkRelativePath : softLinkRelativePath,
    softLinkChain : softLinkChain,
    softLinkActSync : softLinkActSync,
    softLinkSoftLinkResolving : softLinkSoftLinkResolving,
    softLinkRelativeLinkResolving : softLinkRelativeLinkResolving,

    hardLinkSync : hardLinkSync,
    hardLinkRelativePath : hardLinkRelativePath,
    // hardLinkExperiment : hardLinkExperiment,
    hardLinkSoftlinked : hardLinkSoftlinked,
    hardLinkActSync : hardLinkActSync,
    hardLinkAsync : hardLinkAsync,
    hardLinkActAsync : hardLinkActAsync,
    hardLinkSoftLinkResolving : hardLinkSoftLinkResolving,

    fileExchangeSync : fileExchangeSync,
    fileExchangeAsync : fileExchangeAsync,

    //etc

    nativize : nativize,

    // experiment : experiment,

    // hardLinkSyncRunner : hardLinkSyncRunner,
    // hardLinkAsyncRunner : hardLinkAsyncRunner,

    isDir : isDir,
    dirIsEmpty : dirIsEmpty,

    isTerminal : isTerminal,
    isSoftLink : isSoftLink,
    isTextLink : isTextLink,
    isHardLink : isHardLink,
    isLink : isLink,

    filesAreHardLinked : filesAreHardLinked,
    filesAreSame : filesAreSame,

    filesSize : filesSize,
    fileSize : fileSize,

    fileExists : fileExists,

    pathResolve : pathResolve,
    uriResolve : uriResolve,

    pathResolveLinkChain : pathResolveLinkChain,
    pathResolveLink : pathResolveLink,
    pathResolveSoftLink : pathResolveSoftLink,
    pathResolveTextLink : pathResolveTextLink,

  },

};

wTestSuite( Self );

})();
