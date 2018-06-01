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
      require.resolve( toolsPath );
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
  require( '../file/FileTop.s' );

  var crypto = require( 'crypto' );

  _.include( 'wTesting' );

  // _.assert( HardDrive === _.FileProvider.HardDrive,'overwritten' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;

//

function makePath( filePath )
{
  filePath =  _.pathJoin( this.testRootDirectory,  filePath );
  return _.pathNormalize( filePath );
}


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

// function shouldWriteOnlyOnce( test, filePath, expected )
// {
//   var self = this;
//
//   test.description = 'shouldWriteOnlyOnce test';
//   var files = self.provider.directoryRead( self.makePath( filePath ) );
//   test.identical( files, expected );
// }

// --
// tests
// --

function testDelaySample( test )
{
  var self = this;

  debugger;

  test.description = 'delay test';

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
  // test.description = 'if passes dont appears in output/passed test cases/total counter';
  // test.mustNotThrowError( function()
  // {
  // });
  //
  // test.identical( 0,0 );
  //
  // test.description = 'if not passes then appears in output/total counter';
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

  test.description = 'mustNotThrowError must return con with message';

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

  var dir = _.pathNormalize( test.context.makePath( 'written/readWriteSync' ) );

  var got, filePath, readOptions, writeOptions;
  var testData = 'Lorem ipsum dolor sit amet';

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'fileRead, invalid path';

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

  test.description = 'fileRead, path ways to not a terminal file';
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

  test.description = 'fileRead,simple file read ';
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

  test.description = 'fileRead,file read with common encodings';
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

  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  testData = 'module.exports = { a : 1 }';
  else
  testData = '1 + 2';

  self.provider.fileWrite( filePath, testData );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1,
    encoding : 'js',
    throwing : 1,
  });

  if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  test.identical( got, { a : 1 } );
  else
  test.identical( got , _.exec( testData ) );

  /**/

  test.shouldThrowError( () =>
  {
    self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'xxx',
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
      encoding : 'xxx',
      throwing : 0,
    });
    test.identical( got, null );
  })

  /**/

  test.description = 'encoder not finded';
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
    test.description = 'other encodings';
    self.provider.filesDelete( dir );
    filePath = test.context.makePath( 'written/readWriteSync/file' );
    testData = 'abc';

    self.provider.fileWrite( filePath, testData );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'buffer-node',
      throwing : 1,
    });
    test.shouldBe( _.bufferNodeIs( got ) );

    self.provider.fileWrite( filePath, testData );
    got = self.provider.fileRead
    ({
      filePath : filePath,
      sync : 1,
      encoding : 'buffer-raw',
      throwing : 1,
    });
    test.shouldBe( _.bufferRawIs( got ) );
  }

  //

  test.description = 'fileRead,onBegin,onEnd,onError';
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

  /*onBegin wrap 0*/

  got = self.provider.fileRead
  ({
    sync : 1,
    wrap : 0,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : onBegin,
    onEnd : null,
    onError : null,
  });
  test.identical( got, testData );

  /*onBegin wrap 1*/

  self.provider.fileRead
  ({
    sync : 1,
    wrap : 1,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : onBegin,
    onEnd : null,
    onError : null,
  });
  test.identical( _.objectIs( got.options ), true );

  /*onEnd wrap 0*/

  self.provider.fileRead
  ({
    sync : 1,
    wrap : 0,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : null,
    onEnd : onEnd,
    onError : null,
  });
  test.identical( got, testData );

  /*onEnd wrap 1*/

  self.provider.fileRead
  ({
    sync : 1,
    wrap : 1,
    throwing : 1,
    filePath : filePath,
    encoding : 'utf8',
    onBegin : null,
    onEnd : onEnd,
    onError : null,
  });
  test.identical( got.data, testData );

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      wrap : 0,
      throwing : 1,
      filePath : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errIs( got ), true )

  /*onError is no called*/

  test.shouldThrowErrorSync( function()
  {
    self.provider.fileRead
    ({
      sync : 1,
      wrap : 1,
      throwing : 1,
      filePath : 'invalid path',
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
      wrap : 0,
      throwing : 0,
      filePath : 'invalid path',
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
      wrap : 0,
      throwing : 1,
      filePath : 'invalid path',
      encoding : 'utf8',
      onBegin : null,
      onEnd : null,
      onError : onError,
    });
  });
  test.identical( _.errIs( got ), true );

  //fileWrite

  //

  test.description = 'fileWrite, path not exist,default settings';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';

  /**/

  self.provider.fileWrite( filePath, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  /*path includes not existing directory*/
  filePath = test.context.makePath( 'written/readWriteSync/file/file.txt' );
  self.provider.fileWrite( filePath, testData );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'file' ] );
  got = self.provider.fileRead
  ({
    filePath : filePath,
    sync : 1
  });
  test.identical( got, testData );

  //

  test.description = 'fileWrite, path already exist,default settings';
  self.provider.filesDelete( dir );
  filePath = test.context.makePath( 'written/readWriteSync/file' );
  testData = 'Lorem ipsum dolor sit amet';
  self.provider.fileWrite( filePath, testData );

  /**/

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

  test.description = 'fileWrite, path already exist';
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

  test.description = 'fileWrite, path not exist';
  self.provider.filesDelete( dir );
  testData = 'Lorem ipsum dolor sit amet';
  filePath = test.context.makePath( 'written/readWriteSync/file' );


  /*path includes not existing directory*/

  debugger
  // self.provider.filesDelete( _.pathDir( filePath ) );
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

  test.description = 'fileWrite, different write modes';
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

  test.description = 'fileWrite, any writeMode should create file it not exist';
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


  /* resolvingSoftLink */

  test.description = 'read from soft link, resolvingSoftLink on';
  var data = 'data';
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  self.provider.fileWrite( filePath, data );
  var linkPath = test.context.makePath( 'written/readWriteSync/link' );
  self.provider.linkSoft( linkPath, filePath );
  var got = self.provider.fileRead( linkPath );
  test.identical( got, data);
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

  test.description = 'read from soft link, resolvingSoftLink on';
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

  test.description = 'write using link, resolvingSoftLink on';
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

  test.description = 'write using link, resolvingSoftLink off';
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

  test.description = 'write using link, resolvingSoftLink off';
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

  test.description = 'write using link, resolvingSoftLink off';
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

  //

  if( !isBrowser )
  {
    test.description = 'fileWrite, data is raw buffer';
    self.provider.filesDelete( dir );
    testData = 'Lorem ipsum dolor sit amet';
    var buffer = _.bufferRawFrom( new Buffer( testData ) );
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
      test.description = 'typed buffer'
      buffer = new Uint16Array( buffer );
      self.provider.fileWrite( filePath,buffer );
      got = self.provider.fileRead
      ({
       filePath : filePath,
       sync : 1,
      });
      test.identical( got, testData );

      test.description = 'node buffer'
      buffer = new Buffer( testData );
      self.provider.fileWrite( filePath,buffer );
      got = self.provider.fileRead
      ({
       filePath : filePath,
       sync : 1,
      });
      test.identical( got, testData );

      test.description = 'write using link, resolvingSoftLink off';
      var data = 'data';
      self.provider.fieldSet( 'resolvingSoftLink', 0 );
      self.provider.fileWrite( filePath, data );
      var linkPath = test.context.makePath( 'written/readWriteSync/link' );
      self.provider.linkSoft( linkPath, filePath );
      self.provider.fileWrite
      ({
         filePath : linkPath,
         writeMode : 'prepend',
         data : new Buffer.from( data )
      });
      var got = self.provider.fileRead( filePath );
      test.identical( got, data );
      var got = self.provider.fileRead( linkPath );
      test.identical( got, data + data );
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
    }

  }


  if( self.providerIsInstanceOf( _.FileProvider.Extract ) )
  {
    var data = 'data';

    self.provider.fieldSet( 'safe', 0 );


    /* hardLink */

    var resolvingHardLink = self.provider.resolvingHardLink;

    /* resolving on */

    self.provider.fieldSet( 'resolvingHardLink', 1 );

    test.description = 'read, hardLink to file that not exist';
    var linkPath = '/linkToUnknown';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.description = 'write+read, hardLink to file that not exist';
    var linkPath = '/linkToUnknown';
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.description = 'update file using hardLink, then read';
    var linkPath = '/linkToFile';
    var filePath = '/file';
    self.provider.fileWrite( linkPath, data );
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );

    test.description = 'update file, then read it using hardLink';
    var linkPath = '/linkToFile';
    var filePath = '/file';
    self.provider.fileWrite( filePath, data + data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data + data );

    test.description = 'hardLink to directory, read+write';
    var linkPath = '/linkToDir';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );

    /* resolving off */

    self.provider.fieldSet( 'resolvingHardLink', 0 );

    test.description = 'resolving disabled, read using hardLink';
    var linkPath = '/linkToFile';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.description = 'resolving disabled, write using hardLink, link becomes usual file';
    var linkPath = '/linkToFile';
    self.provider.fileWrite( linkPath, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data );
    test.shouldBe( !self.provider.fileIsHardLink( linkPath ) );

    //

    self.provider.fieldReset( 'resolvingHardLink', 0 );

    /* softLink */

    var resolvingSoftLink = self.provider.resolvingSoftLink;

    /* resolving on */

    self.provider.fieldSet( 'resolvingSoftLink', 1 );

    test.description = 'read, softLink to file that not exist';
    var linkPath = '/softLinkToUnknown';
    var filePath = '/unknown';
    // self.provider.filesDelete( filePath );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.description = 'write+read, softLink to file that not exist';
    var linkPath = '/softLinkToUnknown';
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.description = 'update file using softLink, then read';
    var linkPath = '/softLinkToFile';
    var filePath = '/file';
    self.provider.fileWrite( linkPath, data );
    var got = self.provider.fileRead( filePath );
    test.identical( got, data );

    test.description = 'update file, then read it using softLink';
    var linkPath = '/softLinkToFile';
    var filePath = '/file';
    self.provider.fileWrite( filePath, data + data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data + data );

    test.description = 'softLink to directory, read+write';
    var linkPath = '/softLinkToDir';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );

    test.description = 'softLink to file, file renamed';
    var linkPath = '/softLinkToFile';
    var filePath = '/file';
    var filePathNew = '/file_new';
    self.provider.fileRename( filePathNew, filePath );
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );
    test.shouldThrowError( () => self.provider.fileWrite( linkPath, data ) );
    self.provider.fileRename( filePath, filePathNew );


    /* resolving off */

    self.provider.fieldSet( 'resolvingSoftLink', 0 );

    test.description = 'resolving disabled, read using softLink';
    var linkPath = '/softLinkToFile';
    test.shouldThrowError( () => self.provider.fileRead( linkPath ) );

    test.description = 'resolving disabled, write using softLink, link becomes usual file';
    var linkPath = '/softLinkToFile';
    self.provider.fileWrite( linkPath, data );
    var got = self.provider.fileRead( linkPath );
    test.identical( got, data );
    test.shouldBe( !self.provider.fileIsSoftLink( linkPath ) );

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
  // test.description = 'single file is written';
  // var files = self.provider.directoryRead( test.context.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.description = 'synchronous, writeMode : rewrite';
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
  // test.description = 'single file is written';
  // var files = self.provider.directoryRead( test.context.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.description = 'synchronous, writeMode : append';
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
  // test.description = 'single file is written';
  // var files = self.provider.directoryRead( test.context.makePath( 'written/readWriteSync/' ) );
  // test.identical( files, [ 'test.txt' ] );
  //
  // test.description = 'synchronous, writeMode : prepend';
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
  //   test.description = 'file doesn`t exist';
  //   test.shouldThrowErrorSync( function( )
  //   {
  //     self.provider.fileRead
  //     ({
  //       filePath : test.context.makePath( 'unknown' ),
  //       sync : 1
  //     });
  //   });
  //
  //   test.description = 'try to read dir';
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
    test.description = 'fileRead, invalid path';
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
    test.description = 'fileRead, path ways to not a terminal file';
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
    test.description = 'fileRead,simple file read ';
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
    test.description = 'fileRead,file read with common encodings';
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
      encoding : 'js',
      throwing : 1,
    });
    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
       if( self.providerIsInstanceOf( _.FileProvider.HardDrive ) )
       test.identical( got, { a : 1 } );
       else
       test.identical( got , _.exec( testData ) );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'fileRead,onBegin,onEnd,onError';
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

  /*onBegin wrap 0*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
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
      test.identical( _.objectIs( got), true );
    });
  })

  /*onBegin wrap 1*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 1,
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
      test.identical( _.objectIs( got.options ), true );
    });
  })

  /*onEnd wrap 0*/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
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
      test.identical( got, testData );
    });
  })

  /*onEnd wrap 1*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 1,
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
      test.identical( got.data, testData );
    });
  })

  /*onError is no called*/
  .ifNoErrorThen( function()
  {
    var con = self.provider.fileRead
    ({
      sync : 0,
      wrap : 0,
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
      wrap : 1,
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
      wrap : 0,
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
      wrap : 0,
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
    test.description = 'fileWrite, path not exist,default settings';
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
    filePath = test.context.makePath( 'written/readWriteAsync/file/file.txt' );
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
    test.description = 'fileWrite, path already exist,default settings';
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
    test.description = 'fileWrite, path already exist';
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
    test.description = 'fileWrite, path not exist';
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
    test.description = 'fileWrite, different write modes';
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
    test.description = 'fileWrite, any writeMode should create file it not exist';
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

    test.description = 'read from soft link, resolvingSoftLink on';
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
    test.description = 'read from soft link, resolvingSoftLink on';
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
    test.description = 'write using link, resolvingSoftLink on';
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
    test.description = 'write using link, resolvingSoftLink off';
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
    test.description = 'write using link, resolvingSoftLink off';
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
    test.description = 'write using link, resolvingSoftLink off';
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
      test.description = 'fileWrite, data is raw buffer';
      self.provider.filesDelete( dir );
      testData = 'Lorem ipsum dolor sit amet';
      buffer = _.bufferRawFrom( new Buffer( testData ) );
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
      test.description = 'encoder not finded';
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
      test.description = 'other encodings';
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
        encoding : 'buffer-node',
        throwing : 1,
      })
      .doThen( ( err, got ) => test.shouldBe( _.bufferNodeIs( got ) ) )
    })
    .ifNoErrorThen( function()
    {
      self.provider.fileWrite( filePath, testData );
      return self.provider.fileRead
      ({
        filePath : filePath,
        sync : 0,
        encoding : 'buffer-raw',
        throwing : 1,
      })
      .doThen( ( err, got ) => test.shouldBe( _.bufferRawIs( got ) ) )
    })
  }

 return consequence;
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

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var srcPath = _.pathNormalize( test.context.makePath( 'written/fileTouch/src.txt' ) );
  var testData = 'test';

  //

  test.description = 'filePath doesnt exist'
  // self.provider.filesDelete( srcPath );
  self.provider.fileTouch( srcPath );
  var stat = self.provider.fileStat( srcPath );
  test.shouldBe( _.objectIs( stat ) );

  test.description = 'filePath doesnt exist, filePath as record';
  self.provider.filesDelete( srcPath );
  var record = self.provider.fileRecord( srcPath );
  test.identical( record.stat, null );
  self.provider.fileTouch( record );
  var stat = self.provider.fileStat( srcPath );
  test.shouldBe( _.objectIs( stat ) );

  test.description = 'filePath is a directory';
  self.provider.filesDelete( srcPath );
  self.provider.directoryMake( srcPath );
  test.shouldThrowError( () => self.provider.fileTouch( srcPath ) );

  test.description = 'directory, filePath as record';
  self.provider.filesDelete( srcPath );
  self.provider.directoryMake( srcPath );
  var record = self.provider.fileRecord( srcPath );
  test.shouldThrowError( () => self.provider.fileTouch( record ) );

  if( Config.debug )
  {
    test.description = 'invalid filePath type'
    test.shouldThrowError( () => self.provider.fileTouch( 1 ) );

    test.description = 'data option must be undefined'
    test.shouldThrowError( () => self.provider.fileTouch({ filePath : srcPath, data : testData }) );

    test.description = 'more then one arg'
    test.shouldThrowError( () => self.provider.fileTouch( srcPath, testData ) );
  }

  var con = new _.Consequence().give()

  /**/

  .ifNoErrorThen( () =>
  {
    test.description = 'filePath is a terminal';
    self.provider.filesDelete( srcPath );
    self.provider.fileWrite( srcPath, testData );
    var statsBefore = self.provider.fileStat( srcPath );
    return _.timeOut( 1000, () =>
    {
      self.provider.fileTouch( srcPath );
      var statsAfter = self.provider.fileStat( srcPath );
      test.identical( statsAfter.size, statsBefore.size );
      test.identical( statsAfter.ino , statsBefore.ino );
      test.shouldBe( statsAfter.mtime > statsBefore.mtime );
      test.shouldBe( statsAfter.ctime > statsBefore.mtime );
    })
  })

  /**/

  .ifNoErrorThen( () =>
  {
    test.description = 'terminal, filePath as record';
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
      test.shouldBe( statsAfter.mtime > statsBefore.mtime );
      test.shouldBe( statsAfter.ctime > statsBefore.mtime );
    })
  })

  return con;
}

//

// function writeAsyncThrowingError( test )
// {
//   var self = this;
//
//   if( !_.routineIs( self.provider.fileWrite ) )
//   return;
//
//   var consequence = new _.Consequence().give();
//
//   try
//   {
//     self.provider.directoryMake
//     ({
//       filePath : test.context.makePath( 'dir' ),
//       sync : 1
//     });
//   }
//   catch( err )
//   {
//   }
//
//
//   consequence
//   .ifNoErrorThen( function()
//   {
//
//     test.description = 'async, try to rewrite dir';
//
//     var data1 = 'data1';
//     var con = self.provider.fileWrite
//     ({
//       filePath : test.context.makePath( 'dir' ),
//       data : data1,
//       sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   })
//
//   return consequence;
// }

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

  test.description = 'src not exist';

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

  test.description = 'dst path not exist';
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

  test.description = 'dst path exist';
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

  test.description = 'src is equal to dst';
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

  test.description = 'src is not a terminal, dst present, check if nothing changed';

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
  test.shouldBe( srcStat.isDirectory() );
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
  test.shouldBe( srcStat.isDirectory() );
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
  test.shouldBe( srcStat.isDirectory() );
  test.identical( srcStat.size, srcStatExpected.size );
  test.identical( srcStat.mtime.getTime(), srcStatExpected.mtime.getTime() );
  test.identical( dstNow, dstBefore );
  var dirAfter = self.provider.directoryRead( dir );
  test.identical( dirAfter, dirBefore );

  //

  test.description = 'rewriting creates dir for a file, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir, 'folder/structure/dst' );
  test.shouldBe( !self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.shouldBe( !!self.provider.fileStat( dstPath ) );

  //

  test.description = 'rewriting off, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir, 'folder/structure/dst' );
  test.shouldBe( !self.provider.fileStat( dstPath ) );
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
  test.shouldBe( !self.provider.fileStat( dstPath ) );

  //

  test.description = 'rewriting off, dstPath structure not exists'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir, 'folder/structure/dst' );
  test.shouldBe( !self.provider.fileStat( dstPath ) );
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
  test.shouldBe( !self.provider.fileStat( dstPath ) );

  //

  test.description = 'rewriting on, parentDir is a terminal file'
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  var terminalFilePath = _.pathJoin( dir, 'folder/structure' );
  self.provider.fileWrite( terminalFilePath, dstPath );
  var dstPath = _.pathJoin( dir, 'folder/structure/dst' );
  test.shouldBe( !!self.provider.fileStat( terminalFilePath ) );
  test.shouldBe( !self.provider.fileStat( dstPath ) );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.shouldBe( self.provider.directoryIs( terminalFilePath ) );
  test.shouldBe( !!self.provider.fileStat( dstPath ) );

  //

  test.description = 'rewriting on, parentDir is a directory with files, dir must be preserved'
  self.provider.filesDelete( dir );
  var file1 = _.pathJoin( dir, 'dir', 'file1' );
  var file2 = _.pathJoin( dir, 'dir', 'file2' );
  self.provider.fileWrite( file1, file1 );
  self.provider.fileWrite( file2, file2 );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir, 'dst' );
  test.shouldBe( !self.provider.fileStat( dstPath ) );
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

  test.description = 'rewriting off, parentDir is a directory with files, dir must be preserved'
  self.provider.filesDelete( dir );
  var file1 = _.pathJoin( dir, 'dir', 'file1' );
  var file2 = _.pathJoin( dir, 'dir', 'file2' );
  self.provider.fileWrite( file1, file1 );
  self.provider.fileWrite( file2, file2 );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir, 'dst' );
  test.shouldBe( !self.provider.fileStat( dstPath ) );
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

  test.description = 'relative path, dst path not exist';
  var dir = test.context.makePath( 'written/fileCopy' );
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );

  //

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileCopy
  ({
    srcPath : srcPath,
    dstPath : _.pathRelative( dir, dstPath ),
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
    srcPath : _.pathRelative( dir, srcPath ),
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
      srcPath : _.pathRelative( dir, srcPath ),
      dstPath : _.pathRelative( dir, dstPath ),
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
      srcPath : _.pathRelative( dir, srcPath ),
      dstPath : _.pathRelative( dir, dstPath ),
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

  test.description = 'dst - terminal, rewrite by src - terminal'
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir, 'src' );
  var dstPath = _.pathJoin( dir, 'dst' );
  self.provider.fileWrite( srcPath, srcPath );
  self.provider.fileWrite( dstPath, dstPath );
  test.shouldBe( !!self.provider.fileStat( srcPath ) );
  test.shouldBe( !!self.provider.fileStat( dstPath ) );
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
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );

  //

  test.description = 'no src';
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

  test.description = 'no src';
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

  test.description = 'no src';
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

  test.description = 'no src';
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

  test.description = 'no src, dst exists';
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

  test.description = 'no src, dst exists';
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

  test.description = 'no src, dst exists';
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

  test.description = 'no src, dst exists';
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

  test.description = 'src : directory, no dst';
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

  test.description = 'src : directory, no dst';
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

  test.description = 'src : directory, no dst';
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

  test.description = 'src : directory, no dst';
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

  test.description = 'no structure before dst';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'no structure before dst';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'no structure before dst';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'no structure before dst';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'src - terminal, dst - directory';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'src - terminal, dst - directory';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'src - terminal, dst - directory';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'src - terminal, dst - directory';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dstDir', 'dst' );
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

  test.description = 'simple copy';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple copy';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple copy';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple copy';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple, rewrite';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple, rewrite';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple, rewrite';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  test.description = 'simple, rewrite';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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

  /* links */

  var dir = test.context.makePath( 'written/' + test.name );
  var srcPath = _.pathJoin( dir, 'src' );
  var dstPath = _.pathJoin( dir, 'dst' );
  var otherPath = _.pathJoin( dir, 'other' );

  test.description = 'dst is a soft link';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a soft link';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a soft link';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  /* hardlink */

  test.description = 'dst is a hard link, breaking disabled';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a hard link, breakingDstHardLink : 1';
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
  test.shouldBe( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.shouldBe( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.shouldBe( srcFile !== dstFile );

  //

  test.description = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
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
  test.shouldBe( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.shouldBe( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.shouldBe( srcFile !== dstFile );

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

  var srcPath = _.pathJoin( dir, 'src' );
  var dstPath = _.pathJoin( dir, 'dst' );
  var otherPath = _.pathJoin( dir, 'other' );

  //

  test.description = 'dst is a soft link, breaking disabled';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a soft link, breakingDstSoftLink : 0 ,breakingDstHardLink : 1';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  //!!! breakingDstSoftLink is not present anymore

  /* test.description = 'dst is a soft link, breakingDstSoftLink : 1';
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.shouldBe( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.shouldBe( srcFile !== dstFile ); */

  //

  /* test.description = 'dst is a soft link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.shouldBe( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.shouldBe( srcFile !== dstFile ); */

  //

  test.description = 'src - not terminal, dst - soft link';
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
  test.shouldBe( !!self.provider.fileIsSoftLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - soft link';
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
  test.shouldBe( !!self.provider.fileIsSoftLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - soft link';
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
  test.shouldBe( !!self.provider.fileIsSoftLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - soft link';
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
  test.shouldBe( !!self.provider.fileIsSoftLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - soft link';
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
  test.shouldBe( !!self.provider.fileIsSoftLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  /* hardlink */

  test.description = 'dst is a hard link, breaking disabled';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, srcFile );
  test.identical( otherFile, srcFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, srcFile );
  test.shouldBe( srcFile !== otherFile );

  //

  test.description = 'dst is a hard link, breakingDstHardLink : 1';
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
  test.shouldBe( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.shouldBe( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.shouldBe( srcFile !== dstFile );

  //

  test.description = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
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
  test.shouldBe( !self.provider.fileIsHardLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  test.shouldBe( srcFile !== dstFile );
  self.provider.fileWrite( srcPath, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( dstFile, otherFile );
  test.shouldBe( srcFile !== dstFile );

  //

  test.description = 'src - not terminal, dst - hard link';
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
  test.shouldBe( !!self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - hard link';
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
  test.shouldBe( !!self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - hard link';
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
  test.shouldBe( !!self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

  //

  test.description = 'src - not terminal, dst - hard link';
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
  test.shouldBe( !!self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.directoryIs( srcPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( otherFile, dstFile );
  self.provider.fileWrite( otherFile, srcPath );
  var dstFile = self.provider.fileRead( dstPath );
  var otherFile = self.provider.fileRead( otherPath );
  test.identical( dstFile, otherFile );

   //

   test.description = 'src - not terminal, dst - hard link';
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
   test.shouldBe( !!self.provider.fileIsHardLink( dstPath ) );
   test.shouldBe( self.provider.directoryIs( srcPath ) );
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
    test.description = 'src not exist';
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
    test.description = 'copy bigger file';
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
      test.shouldBe( dstFile === data );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'dst path not exist';
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
    test.description = 'dst path exist';
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
    test.description = 'src is equal to dst';
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
    test.description = 'src is not a terminal, dst present, check if nothing changed';
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
      test.shouldBe( srcStat.isDirectory() );
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
      test.shouldBe( srcStat.isDirectory() );
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
      test.shouldBe( srcStat.isDirectory() );
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

  var srcPath = _.pathJoin( dir, 'src' );
  var dstPath = _.pathJoin( dir, 'dst' );
  var otherPath = _.pathJoin( dir, 'other' );

  var con = new _.Consequence().give()

  //

  .doThen( () =>
  {
    test.description = 'dst is a soft link, breaking disabled';
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
      breakingDstHardLink : 0
    })
    .ifNoErrorThen( () =>
    {
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.shouldBe( srcFile !== otherFile );
    })
  })

  //

  .doThen( () =>
  {
    test.description = 'dst is a soft link, breakingDstSoftLink : 0 ,breakingDstHardLink : 1';
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.shouldBe( srcFile !== otherFile );
    })
  })

  //

  .doThen( () =>
  {
    test.description = 'dst is a soft link, breakingDstSoftLink : 1';
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.shouldBe( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.shouldBe( srcFile !== dstFile );
    })
  })

  .doThen( () =>
  {
    test.description = 'dst is a soft link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.shouldBe( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.shouldBe( srcFile !== dstFile );
    })
  })

  /* hardlink */

  .doThen( () =>
  {
    test.description = 'dst is a hard link, breaking disabled';
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.shouldBe( srcFile !== otherFile );
    })
  })

  //

  .doThen( () =>
  {
    test.description = 'dst is a hard link, breakingDstSoftLink : 1 ,breakingDstHardLink : 0';
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( dstFile, srcFile );
      test.identical( otherFile, srcFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, srcFile );
      test.shouldBe( srcFile !== otherFile );
    })
  })

  //

  .doThen( () =>
  {
    test.description = 'dst is a hard link, breakingDstHardLink : 1';
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
      test.shouldBe( !self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.shouldBe( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.shouldBe( srcFile !== dstFile );
    })
  })

  //

  .doThen( () =>
  {
    test.description = 'dst is a hard link, breakingDstSoftLink : 1, breakingDstHardLink : 1';
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
      breakingDstHardLink : 1
    })
    .ifNoErrorThen( () =>
    {
      test.shouldBe( !self.provider.fileIsHardLink( dstPath ) );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      var otherFile = self.provider.fileRead( otherPath );
      test.identical( otherFile, dstFile );
      test.shouldBe( srcFile !== dstFile );
      self.provider.fileWrite( srcPath, srcPath );
      var dstFile = self.provider.fileRead( dstPath );
      var srcFile = self.provider.fileRead( srcPath );
      test.identical( dstFile, otherFile );
      test.shouldBe( srcFile !== dstFile );
    })
  })

  return con;
}

//

// function fileCopyAsyncThrowingError( test )
// {
//   var self = this;
//
//   if( !_.routineIs( self.provider.fileCopy ) )
//   return;
//
//   var dir = test.context.makePath( 'written/fileCopyAsync' );
//
//   if( !self.provider.fileStat( dir ) )
//   self.provider.directoryMake( dir );
//
//   var consequence = new _.Consequence().give();
//
//   consequence
//   .ifNoErrorThen( function()
//   {
//     test.description = 'async, throwing error';
//     var con = self.provider.fileCopy
//     ({
//       srcPath : test.context.makePath( 'invalid.txt' ),
//       dstPath : test.context.makePath( 'dstPath.txt' ),
//       sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   })
//   .ifNoErrorThen( function()
//   {
//     test.description = 'async,try rewrite dir';
//     var con = self.provider.fileCopy
//     ({
//       srcPath : test.context.makePath( 'invalid.txt' ),
//       dstPath : test.context.makePath( 'tmp' ),
//       sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   })
//   .ifNoErrorThen( function()
//   {
//     test.description = 'async copy dir';
//     try
//     {
//       self.provider.directoryMake
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
//
//     debugger;
//     var con = self.provider.fileCopy
//     ({
//         srcPath : test.context.makePath( 'written/fileCopyAsync/copydir' ),
//         dstPath : test.context.makePath( 'written/fileCopyAsync/copydir2' ),
//         sync : 0,
//     });
//
//     return test.shouldThrowErrorSync( con );
//   });
//
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
  var dir  = _.pathDir( srcPath );

  //

  test.description = 'src not exist';

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

  test.description = 'rename in same directory,dst not exist';

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

  test.description = 'rename with rewriting in same directory';

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

  test.description = 'rename dir, dst not exist';
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

  test.description = 'rename moving to other existing dir';

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 1
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 1,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  /**/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.directoryMake( _.pathDir( dstPath ) );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : dstPath,
    sync : 1,
    rewriting : 0,
    throwing : 0
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( _.pathDir( dstPath ) );
  test.identical( files, [ 'dst' ] );

  //

  test.description = 'rename moving to not existing dir';

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

  test.description = 'dst is not empty dir';

  /**/

  debugger
  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath,' ' );
  dstPath = test.context.makePath( 'written/fileRename/dir/dst' );
  self.provider.fileWrite( dstPath,' ' );
  got = self.provider.fileRename
  ({
    srcPath : srcPath,
    dstPath : _.pathDir( dstPath ),
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
    dstPath : _.pathDir( dstPath ),
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
      dstPath : _.pathDir( dstPath ),
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
      dstPath : _.pathDir( dstPath ),
      sync : 1,
      rewriting : 0,
      throwing : 0
    });
  });
  test.identical( got, false );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'dir','src' ] );

  //src is equal to dst

  test.description = 'src is equal to dst';

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
  var dir  = _.pathDir( srcPath );


  var consequence = new _.Consequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'src not exist';
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
    test.description = 'rename in same directory,dst not exist';
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
    test.description = 'rename with rewriting in same directory';
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
    test.description = 'rename dir, dst not exist';
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
    test.description = 'rename moving to other existing dir';
    dstPath = test.context.makePath( 'written/fileRenameAsync/dir/dst' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.pathDir( dstPath ) );
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
      var files = self.provider.directoryRead( _.pathDir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.pathDir( dstPath ) );
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
      var files = self.provider.directoryRead( _.pathDir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.pathDir( dstPath ) );
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
      var files = self.provider.directoryRead( _.pathDir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( dir );
    self.provider.fileWrite( srcPath,' ' );
    self.provider.directoryMake( _.pathDir( dstPath ) );
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
      var files = self.provider.directoryRead( _.pathDir( dstPath ) );
      test.identical( files, [ 'dst' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'rename moving to not existing dir';
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
    test.description = 'dst is not empty dir';
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
      dstPath : _.pathDir( dstPath ),
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
      dstPath : _.pathDir( dstPath ),
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
      dstPath : _.pathDir( dstPath ),
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
      dstPath : _.pathDir( dstPath ),
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
    test.description = 'src is equal to dst';
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

  test.description = 'removing not existing path';

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

  test.description = 'removing existing file';
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

  test.description = 'removing empty folder';
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

  test.description = 'try removing folder with file';
  var filePath = test.context.makePath( 'written/fileDelete/folder/file.txt');
  var pathFolder = _.pathDir( filePath );

  /**/

  self.provider.fileWrite( filePath,' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.fileDelete
    ({
      filePath : pathFolder,
      sync : 1,
      throwing : 1
    })
  });
  var stat = self.provider.fileStat( pathFolder );
  test.shouldBe( !!stat );

  /**/

  test.mustNotThrowError( () =>
  {
    self.provider.fileDelete
    ({
      filePath : pathFolder,
      sync : 1,
      throwing : 0
    });
  })

  var stat = self.provider.fileStat( pathFolder );
  test.shouldBe( !!stat );

  if( self.provider.constructor.name === 'wFileProviderExtract' )
  {
    test.description = 'try to remove filesTree';

    //

    test.shouldThrowErrorSync( function()
    {
      self.provider.fileDelete
      ({
        filePath : '.',
        sync : 1,
        throwing : 1
      });
    })

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

    test.mustNotThrowError( function()
    {
      var got = self.provider.fileDelete
      ({
        filePath : '.',
        sync : 1,
        throwing : 0
      });
      test.identical( got, null );
    })
    var stat = self.provider.fileStat( '.' );
    test.shouldBe( !!stat );

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
    test.shouldBe( !!stat );
  }

  //

  var filePath = _.pathJoin( dir, 'file' );
  test.description = 'delete soft link, resolvingSoftLink 1';
  self.provider.fieldSet( 'resolvingSoftLink', 1 );
  var pathDst = _.pathJoin( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.linkSoft( pathDst, filePath );
  self.provider.fileDelete( pathDst )
  var stat = self.provider.fileStat( pathDst );
  test.identical( stat, null );
  var stat = self.provider.fileStat( filePath );
  test.shouldBe( !!stat );
  self.provider.fieldReset( 'resolvingSoftLink', 1 );

  test.description = 'delete soft link, resolvingSoftLink 0';
  self.provider.filesDelete( dir );
  self.provider.fieldSet( 'resolvingSoftLink', 0 );
  var pathDst = _.pathJoin( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.linkSoft( pathDst, filePath );
  self.provider.fileDelete( pathDst )
  var stat = self.provider.fileStat( pathDst );
  test.identical( stat, null );
  var stat = self.provider.fileStat( filePath );
  test.shouldBe( !!stat );
  self.provider.fieldReset( 'resolvingSoftLink', 0 );

  test.description = 'delete soft link, resolvingHardLink 1';
  self.provider.filesDelete( dir );
  self.provider.fieldSet( 'resolvingHardLink', 1 );
  var pathDst = _.pathJoin( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.linkHard( pathDst, filePath );
  self.provider.fileDelete( pathDst )
  var stat = self.provider.fileStat( pathDst );
  test.identical( stat, null );
  var stat = self.provider.fileStat( filePath );
  test.shouldBe( !!stat );
  self.provider.fieldReset( 'resolvingHardLink', 1 );

  test.description = 'delete soft link, resolvingHardLink 0';
  self.provider.filesDelete( dir );
  self.provider.fieldSet( 'resolvingHardLink', 0 );
  var pathDst = _.pathJoin( dir, 'link' );
  self.provider.fileWrite( filePath, ' ');
  self.provider.linkHard( pathDst, filePath );
  self.provider.fileDelete( pathDst )
  var stat = self.provider.fileStat( pathDst );
  test.identical( stat, null );
  var stat = self.provider.fileStat( filePath );
  test.shouldBe( !!stat );
  self.provider.fieldReset( 'resolvingHardLink', 0 );

  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     filePath : test.context.makePath( 'written/fileDelete/dir' ),
  //     sync : 1
  //   });
  //
  //   self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDelete' ),[ 'dir' ] );
  //
  // } catch ( err ){ }
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     filePath : test.context.makePath( 'written/fileDelete/dir/dir2' ),
  //     sync : 1
  //   });
  //
  //   self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDelete/dir' ),[ 'dir2' ] );
  //
  // } catch ( err ){ }
  //
  // var data1 = 'Excepteur sint occaecat cupidatat non proident';
  // self.provider.fileWrite
  // ({
  //     filePath : test.context.makePath( 'written/fileDelete/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDelete/' ),[ 'dir','src.txt' ] );
  //
  // self.provider.fileWrite
  // ({
  //     filePath : test.context.makePath( 'written/fileDelete/dir/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDelete/dir' ),[ 'dir2','src.txt' ] );
  //
  // self.provider.fileWrite
  // ({
  //     filePath : test.context.makePath( 'written/fileDelete/dir/dir2/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDelete/dir/dir2' ),[ 'src.txt' ] );
  //
  // test.description = 'synchronous delete';
  // self.provider.fileDelete
  // ({
  //   filePath : test.context.makePath( 'written/fileDelete/src.txt' ),
  //   sync : 1
  // });
  // var got = self.provider.fileStat
  // ({
  //   filePath : test.context.makePath( 'written/fileDelete/src.txt' ),
  //   sync : 1
  // });
  // var expected = null;
  // test.identical( got, expected );
  //
  // test.description = 'synchronous delete empty dir';
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     filePath : test.context.makePath( 'written/fileDelete/empty_dir' ),
  //     sync : 1
  //   });
  // } catch ( err ){ }
  // self.provider.fileDelete
  // ({
  //   filePath : test.context.makePath( 'written/fileDelete/empty_dir' ),
  //   force : 0,
  //   sync : 1
  // });
  // var got = self.provider.fileStat
  // ({
  //   filePath : test.context.makePath( 'written/fileDelete/empty_dir' ),
  //   sync : 1
  // });
  // var expected = null;
  // test.identical( got, expected );
  //
  // if( Config.debug )
  // {
  //   test.description = 'invalid path';
  //   test.shouldThrowErrorSync( function()
  //   {
  //     self.provider.fileDelete
  //     ({
  //         filePath : test.context.makePath( '///bad path///test.txt' ),
  //         sync : 1,
  //     });
  //   });
  //
  //   test.description = 'not empty dir';
  //   test.shouldThrowErrorSync( function()
  //   {
  //     self.provider.fileDelete
  //     ({
  //         filePath : test.context.makePath( 'written/fileDelete/dir' ),
  //         force : 0,
  //         sync : 1,
  //     });
  //   });
  //
  //   test.description = 'not empty dir inner level';
  //   test.shouldThrowErrorSync( function()
  //   {
  //     self.provider.fileDelete
  //     ({
  //         filePath : test.context.makePath( 'written/fileDelete/dir/dir2' ),
  //         force : 0,
  //         sync : 1,
  //     });
  //   });
  // }
  //
  // test.description = 'dir with files';
  // self.provider.fileDelete
  // ({
  //   filePath : test.context.makePath( 'written/fileDelete/dir' ),
  //   force : 1,
  //   sync : 1
  // });
  // var got = self.provider.fileStat
  // ({
  //   filePath : test.context.makePath( 'written/fileDelete/dir' ),
  //   sync : 1
  // });
  // var expected = null;
  // test.identical( got, expected );

}

//

function fileDeleteActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileDeleteAct ) )
  {
    test.description = 'fileDeleteAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'fileDeleteActSync' );

  //

  test.description = 'basic usage';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  self.provider.fileDeleteAct( o );
  test.identical( o, expected );
  var stat = self.provider.fileStat( srcPath );
  test.shouldBe( !stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'no src';
  var srcPath = _.pathJoin( dir,'src' );
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
  test.shouldBe( !stat );

  //

  test.description = 'src is empty dir';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.directoryMake( srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  self.provider.fileDeleteAct( o );
  var stat = self.provider.fileStat( srcPath );
  test.shouldBe( !stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'src is empty dir';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
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
  test.shouldBe( !!stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'should nativize all paths in options map if needed by its own means';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  self.provider.fileDeleteAct( o );
  test.identical( o, expected );
  var stat = self.provider.fileStat( srcPath );
  test.shouldBe( !stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1
  }
  var expected = _.mapOwnKeys( o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  self.provider.fileDeleteAct( o );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  var stat = self.provider.fileStat( srcPath );
  test.shouldBe( !stat );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.description = 'should assert that path is absolute';
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

  test.description = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.pathJoin( dir,'src' );

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
    test.description = 'should expect normalized path, but not nativized';
    var srcPath = _.pathJoin( dir,'src' );
    self.provider.fileWrite( srcPath, srcPath );
    var o =
    {
      filePath : srcPath,
      sync : 1
    }
    o.filePath = self.provider.pathNativize( o.filePath );
    test.shouldThrowError( () =>
    {
      self.provider.fileDeleteAct( o );
    })
    self.provider.filesDelete( dir );
  }

  //

  test.description = 'should expect ready options map, no complex arguments preprocessing';
  var srcPath = _.pathJoin( dir,'src' );
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

  var filePath,pathFolder;

  var dir = test.context.makePath( 'written/fileDeleteAsync' );

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  var consequence = new _.Consequence().give();

  consequence
  .ifNoErrorThen( function()
  {
    test.description = 'removing not existing path';
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
    test.description = 'removing file';
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
    test.description = 'removing existing empty folder';
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
    test.description = 'removing existing folder with file';
    filePath = test.context.makePath( 'written/fileDeleteAsync/folder/file.txt');

  })

  /**/

  .ifNoErrorThen( function()
  {
    pathFolder = _.pathDir( filePath );
    self.provider.fileWrite( filePath,' ' );
    var con = self.provider.fileDelete
    ({
      filePath : pathFolder,
      sync : 0,
      throwing : 1
    });

    return test.shouldThrowError( con )
    .doThen( function()
    {
      var stat = self.provider.fileStat( pathFolder );
      test.shouldBe( !!stat );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    var con = self.provider.fileDelete
    ({
      filePath : pathFolder,
      sync : 0,
      throwing : 0
    });

    return test.mustNotThrowError( con )
    .ifNoErrorThen( function( got )
    {
      var stat = self.provider.fileStat( pathFolder );
      test.shouldBe( !!stat );
      test.identical( got, null )
    });
  })
  .ifNoErrorThen( function()
  {
    if( self.provider.constructor.name !== 'wFileProviderExtract' )
    return;

    test.description = 'try to remove filesTree';

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
  .ifNoErrorThen( () =>
  {
    var filePath = _.pathJoin( dir, 'file' );
    test.description = 'delete soft link, resolvingSoftLink 1';
    self.provider.fieldSet( 'resolvingSoftLink', 1 );
    var pathDst = _.pathJoin( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.linkSoft( pathDst, filePath );
    return self.provider.fileDelete
    ({
      filePath : pathDst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( () =>
    {
      var stat = self.provider.fileStat( pathDst );
      test.identical( stat, null );
      var stat = self.provider.fileStat( filePath );
      test.shouldBe( !!stat );
      self.provider.fieldReset( 'resolvingSoftLink', 1 );
    })

  })
  .ifNoErrorThen( () =>
  {
    test.description = 'delete soft link, resolvingSoftLink 0';
    self.provider.filesDelete( dir );
    self.provider.fieldSet( 'resolvingSoftLink', 0 );
    var pathDst = _.pathJoin( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.linkSoft( pathDst, filePath );
    return self.provider.fileDelete
    ({
      filePath : pathDst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( () =>
    {
      var stat = self.provider.fileStat( pathDst );
      test.identical( stat, null );
      var stat = self.provider.fileStat( filePath );
      test.shouldBe( !!stat );
      self.provider.fieldReset( 'resolvingSoftLink', 0 );
    })
  })
  .ifNoErrorThen( () =>
  {
    test.description = 'delete hard link, resolvingHardLink 1';
    self.provider.filesDelete( dir );
    self.provider.fieldSet( 'resolvingHardLink', 1 );
    var pathDst = _.pathJoin( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.linkHard( pathDst, filePath );
    return self.provider.fileDelete
    ({
      filePath : pathDst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( () =>
    {
      var stat = self.provider.fileStat( pathDst );
      test.identical( stat, null );
      var stat = self.provider.fileStat( filePath );
      test.shouldBe( !!stat );
      self.provider.fieldReset( 'resolvingHardLink', 1 );
    })
  })
  .ifNoErrorThen( () =>
  {
    test.description = 'delete hard link, resolvingHardLink 0';
    self.provider.filesDelete( dir );
    self.provider.fieldSet( 'resolvingHardLink', 0 );
    var pathDst = _.pathJoin( dir, 'link' );
    self.provider.fileWrite( filePath, ' ');
    self.provider.linkHard( pathDst, filePath );
    return self.provider.fileDelete
    ({
      filePath : pathDst,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( () =>
    {
      var stat = self.provider.fileStat( pathDst );
      test.identical( stat, null );
      var stat = self.provider.fileStat( filePath );
      test.shouldBe( !!stat );
      self.provider.fieldReset( 'resolvingHardLink', 0 );
    })
  })

  return consequence;

  // var consequence = new _.Consequence().give();
  // var data1 = 'Excepteur sint occaecat cupidatat non proident';
  //
  // var dir = test.context.makePath( 'written/fileDeleteAsync' );
  //
  // if( !self.provider.fileStat( dir ) )
  // self.provider.directoryMake( dir );
  //
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/dir' ),
  //     sync : 1
  //   });
  //
  // } catch ( err ){ }
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDeleteAsync' ),[ 'dir' ] );
  //
  // try
  // {
  //   self.provider.directoryMake
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/dir/dir2' ),
  //     sync : 1
  //   });
  //
  // } catch ( err ){ }
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDeleteAsync/dir' ),[ 'dir2' ] );
  //
  //
  // self.provider.fileWrite
  // ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/dir/dir2/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDeleteAsync/dir/dir2' ),[ 'src.txt' ] );
  //
  // var data1 = 'Excepteur sint occaecat cupidatat non proident';
  // self.provider.fileWrite
  // ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/src.txt' ),
  //     data : data1,
  //     sync : 1,
  // });
  //
  // self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDeleteAsync' ),[ 'dir','src.txt' ] );
  //
  // consequence
  // .ifNoErrorThen( function()
  // {
  //   self.provider.fileWrite
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/dir/src.txt' ),
  //     data : data1,
  //     sync : 1,
  //   });
  //
  //   self.shouldWriteOnlyOnce( test,test.context.makePath( 'written/fileDeleteAsync/dir' ),[ 'dir2','src.txt' ] );
  //
  //   test.description = 'asynchronous delete';
  //   var con = self.provider.fileDelete
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/src.txt' ),
  //     sync : 0
  //   });
  //
  //   return test.shouldMessageOnlyOnce( con );
  // })
  // .ifNoErrorThen( function( err )
  // {
  //   var got = self.provider.fileStat
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/src.txt' ),
  //     sync : 1
  //   });
  //   var expected = null;
  //   test.identical( got, expected );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'synchronous delete empty dir';
  //   try
  //   {
  //     self.provider.directoryMake
  //     ({
  //       filePath : test.context.makePath( 'written/fileDeleteAsync/empty_dir' ),
  //       sync : 1
  //     });
  //   } catch ( err ){ }
  //
  //   var con = self.provider.fileDelete
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/empty_dir' ),
  //     sync : 0
  //   });
  //
  //   return test.shouldMessageOnlyOnce( con );
  // })
  // .ifNoErrorThen( function( err )
  // {
  //   var got = self.provider.fileStat
  //   ({
  //     filePath : test.context.makePath( 'written/fileDeleteAsync/empty_dir' ),
  //     sync : 1
  //   });
  //   var expected = null;
  //   test.identical( got, expected );
  // })
  // .ifNoErrorThen( function()
  // {
  //
  //   //!!!something wrong here
  //
  //   test.description = 'invalid path';
  //   var con = self.provider.fileDelete
  //   ({
  //     filePath : test.context.makePath( 'somefile.txt' ),
  //     sync : 0,
  //     force : 0,
  //   });
  //
  //   return test.shouldThrowErrorSync( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'not empty dir';
  //   var con = self.provider.fileDelete
  //   ({
  //       filePath : test.context.makePath( 'written/fileDeleteAsync/dir' ),
  //       force : 0,
  //       sync : 0,
  //   });
  //
  //   return test.shouldThrowErrorSync( con );
  // })
  // .ifNoErrorThen( function()
  // {
  //   test.description = 'not empty dir inner level';
  //   var con = self.provider.fileDelete
  //   ({
  //       filePath : test.context.makePath( 'written/fileDeleteAsync/dir/dir2' ),
  //       force : 0,
  //       sync : 0,
  //   });
  //
  //   return test.shouldThrowErrorSync( con );
  // });
  //
  // return consequence;
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
  test.description = 'synchronous file stat default options';

  /**/

  var got = self.provider.fileStat( filePath );
  // if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
  // {
    expected = 46;
  // }
  // else if( self.provider instanceof _.FileProvider.Extract )
  // {
  //   expected = null;
  // }
  test.identical( got.size, expected );

  /**/

  var got = self.provider.fileStat
  ({
    sync : 1,
    filePath : filePath,
    throwing : 1
  });
  // if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
  // {
    expected = 46;
  // }
  // else if( self.provider instanceof _.FileProvider.Extract )
  // {
  //   expected = null;
  // }
  test.identical( got.size, expected );

  //

  test.description = 'invalid path';
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
    test.description = 'fileStatAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'fileStatActSync' );

  //

  test.description = 'basic usage,should nativize all paths in options map if needed by its own means';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  var stat = self.provider.fileStatAct( o );
  test.identical( o, expected );
  test.shouldBe( !!stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'no src';
  var srcPath = _.pathJoin( dir,'src' );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  var stat = self.provider.fileStatAct( o );
  test.identical( o, expected );
  test.shouldBe( !stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'no src';
  var srcPath = _.pathJoin( dir,'src' );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 1,
    resolvingSoftLink : 1
  }
  var expected = _.mapExtend( null, o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  test.shouldThrowError( () => self.provider.fileStatAct( o ) )
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  test.description = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var o =
  {
    filePath : srcPath,
    sync : 1,
    throwing : 0,
    resolvingSoftLink : 1
  }
  var expected = _.mapOwnKeys( o );
  expected.filePath = self.provider.pathNativize( o.filePath );
  var stat = self.provider.fileStatAct( o );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  test.shouldBe( !!stat );
  self.provider.filesDelete( dir );

  //

  test.description = 'src is a soft link';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( !!stat );
  test.shouldBe( !stat.isSymbolicLink() );
  self.provider.filesDelete( dir );

  //

  test.description = 'src is a soft link';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( !!stat );
  test.shouldBe( stat.isSymbolicLink() );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  if( test.context.providerIsInstanceOf( _.FileProvider.HardDrive ) )
  {
    test.description = 'should assert that path is absolute';
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

  test.description = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.pathJoin( dir,'src' );

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

  test.description = 'should expect normalized path, but not nativized';
  var srcPath = _.pathJoin( dir,'src' );
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
    o.filePath = self.provider.pathNativize( o.filePath );
    test.shouldThrowError( () =>
    {
      self.provider.fileStatAct( o );
    })
    self.provider.filesDelete( dir );

    //

    var o =
    {
      filePath : srcPath,
      sync : 1,
      throwing : 1,
      resolvingSoftLink : 1,
    }
    o.filePath = self.provider.pathNativize( o.filePath );
    test.shouldThrowError( () =>
    {
      self.provider.fileStatAct( o );
    })
    self.provider.filesDelete( dir );
  }

  //

  test.description = 'should expect ready options map, no complex arguments preprocessing';
  var srcPath = _.pathJoin( dir,'src' );

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
    test.description = 'synchronous file stat default options';
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
      // if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
      // {
        expected = 46;
      // }
      // else if( self.provider instanceof _.FileProvider.Extract )
      // {
      //   expected = null;
      // }
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
      // if( !isBrowser && self.provider instanceof _.FileProvider.HardDrive )
      // {
        expected = 46;
      // }
      // else if( self.provider instanceof _.FileProvider.Extract )
      // {
      //   expected = null;
      // }
      test.identical( got.size, expected );
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'invalid path';
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

  test.description = 'synchronous mkdir';
  filePath = test.context.makePath( 'written/directoryMake/make_dir' );

  /**/

  self.provider.directoryMake( filePath );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'make_dir' ] );

  //

  test.description = 'synchronous mkdir force';
  self.provider.filesDelete( filePath );
  filePath = test.context.makePath( 'written/directoryMake/make_dir/dir1/' );

  /**/

  self.provider.directoryMake
  ({
    filePath : filePath,
    sync : 1,
    force : 1
  });
  var files = self.provider.directoryRead( _.pathDir( filePath ) );
  test.identical( files, [ 'dir1' ] );

  /**/

  test.shouldThrowErrorSync( function()
  {
    self.provider.filesDelete( _.pathDir( filePath ) );
    self.provider.directoryMake
    ({
      filePath : filePath,
      sync : 1,
      force : 0
    });
  })

  //

  test.description = 'try to rewrite terminal file';
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

  var files = self.provider.directoryRead( _.pathDir( filePath ) );
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

  test.description = 'try to rewrite empty dir';
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

  var files = self.provider.directoryRead( _.pathDir( filePath ) );
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

  test.description = 'dir exists, no rewritingTerminal, no force';
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

  test.description = 'try to rewrite folder with files';
  filePath = test.context.makePath( 'written/directoryMake/make_dir/file' );
  self.provider.filesDelete( dir );

  /**/

  self.provider.fileWrite( filePath, ' ' );
  test.shouldThrowErrorSync( function()
  {
    self.provider.directoryMake
    ({
      filePath : _.pathDir( filePath ),
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
      filePath : _.pathDir( filePath ),
      sync : 1,
      force : 0,
      rewritingTerminal : 0
    });
  });

  /**/

  self.provider.fileWrite( filePath, ' ' );
  self.provider.directoryMake
  ({
    filePath : _.pathDir( filePath ),
    sync : 1,
    force : 1,
    rewritingTerminal : 1
  });

  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'make_dir' ] );


  //

  test.description = 'folders structure not exist';
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
    test.description = 'synchronous mkdir';
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
    test.description = 'synchronous mkdir force';
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
      var files = self.provider.directoryRead( _.pathDir( filePath ) );
      test.identical( files, [ 'dir1' ] );
    });
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.filesDelete( _.pathDir( filePath ) );
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
    test.description = 'try to rewrite terminal file';
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
      var files = self.provider.directoryRead( _.pathDir( filePath ) );
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
    test.description = 'try to rewrite empty dir';
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
      var files = self.provider.directoryRead( _.pathDir( filePath ) );
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
    test.description = 'dir exists, no rewritingTerminal, no force';
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
    test.description = 'try to rewrite folder with files';
    filePath = test.context.makePath( 'written/directoryMakeAsync/make_dir/file' );
    self.provider.filesDelete( dir );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath, ' ' );
    var con = self.provider.directoryMake
    ({
      filePath : _.pathDir( filePath ),
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
      filePath : _.pathDir( filePath ),
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
      filePath : _.pathDir( filePath ),
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
    test.description = 'folders structure not exist';
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

  test.description = 'synchronous filehash';
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

  test.description = 'invalid path';
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
    test.description = 'async filehash';
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
    test.description = 'invalid path';
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

  test.description = 'synchronous read';
  filePath = test.context.makePath( 'read/directoryRead/1.txt' ),

  /**/

  self.provider.fileWrite( filePath,' ' );
  var got = self.provider.directoryRead( _.pathDir( filePath ) );
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  /**/

  self.provider.fileWrite( filePath,' ' );
  var got = self.provider.directoryRead
  ({
    filePath : _.pathDir( filePath ),
    sync : 1,
    throwing : 1
  })
  var expected = [ "1.txt" ];
  test.identical( got.sort(), expected.sort() );

  //

  test.description = 'synchronous, filePath points to file';
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

  test.description = 'path not exist';
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
    test.description = 'synchronous read';
    filePath = test.context.makePath( 'read/directoryReadAsync/1.txt' );
  })

  /**/

  .ifNoErrorThen( function()
  {
    self.provider.fileWrite( filePath,' ' );
    return self.provider.directoryRead
    ({
      filePath : _.pathDir( filePath ),
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
      filePath : _.pathDir( filePath ),
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
    test.description = 'synchronous, filePath points to file';
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
    test.description = 'path not exist';
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
  test.description ='rewrite, file not exist ';
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

  test.description ='rewrite existing file ';
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

  //

  if( Config.debug )
  {
    test.description ='try write to non existing folder';
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

    test.description ='try to rewrite folder';
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
  test.description ='append, file not exist ';
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

  test.description ='append, to file ';
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
    test.description ='try append to non existing folder';
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

    test.description ='try to append to folder';
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
  test.description ='prepend, file not exist ';
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
  test.description ='prepend to file ';
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
    test.description ='try prepend to non existing folder';
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

    test.description ='try to prepend to folder';
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

  test.description ='rewrite link file ';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='rewrite link file ';
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='append link file ';
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='append link file ';
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
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
  test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='rewrite link file ';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='append link file ';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='append link file ';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='prepend link file ';
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );

  //

  self.provider.filesDelete( dirPath )

  test.description ='prepend link file ';
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
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
  test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

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
    test.description ='rewrite, file not exist ';
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
    test.description ='rewrite existing file ';
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
    test.description ='try to rewrite folder';
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
    test.description ='append, file not exist ';
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
    test.description ='append, to file ';
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
    test.description ='try to append to folder';
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
    test.description ='prepend, file not exist ';
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
    test.description ='prepend to file ';
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
    test.description ='try prepend to folder';
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

  var con = new _.Consequence().give()

  //

  .doThen( function()
  {
    self.provider.filesDelete( dirPath )

    test.description ='rewrite link file ';
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    self.provider.filesDelete( dirPath )
    var expected;

    test.description ='rewrite link file ';
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    self.provider.filesDelete( dirPath )
    var expected;

    test.description ='rewrite link file ';
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    self.provider.filesDelete( dirPath )
    var expected;

    test.description ='rewrite link file ';
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
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
      test.shouldBe( !self.provider.fileIsSoftLink( dstPath ) );
    })
  })

  //

  .doThen( function()
  {
    self.provider.filesDelete( dirPath )

    test.description ='rewrite link file ';
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
      test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
    })
  })

  //append

  .doThen( function()
  {
    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.description ='append link file ';
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
    })

  })
  .doThen( function()
  {
    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.description ='append link file ';
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
      test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

    })

  })

  //prepend

  .doThen( function()
  {
    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.description ='append link file ';
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
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
      test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
    })

  })
  .doThen( function()
  {
    self.provider.filesDelete( dirPath );

    var data;

    return _.timeOut( 2000 )
    .doThen( () =>
    {
      test.description ='prepend link file ';
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
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
      test.shouldBe( self.provider.fileIsHardLink( dstPath ) );
      test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

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
    test.description = 'linkSoftAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var dir = test.context.makePath( 'written/linkSoft' );
  var srcPath,dstPath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'make link sync';
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

  test.description = 'make for file that not exist';
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

  test.description = 'link already exists';
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

  test.description = 'src is equal to dst';
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
      throwing : 1
    });
  });
  test.identical( got, true );
  var files = self.provider.directoryRead( dir );
  test.identical( files, [ 'link_test.txt' ] );

  /**/

  test.mustNotThrowError( function()
  {
    got = self.provider.linkSoft
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
    got = self.provider.linkSoft
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
    got = self.provider.linkSoft
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

  test.description = 'try make softlink to folder';
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
    test.description = 'linkSoftAct is not implemented'
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
    test.description = 'make link async';
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
    test.description = 'make for file that not exist';
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
    test.description = 'link already exists';
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
    test.description = 'src is equal to dst';
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
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
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
    })
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
      throwing : 0
    })
    .ifNoErrorThen( function( got )
    {
      test.identical( got, true );
      var files = self.provider.directoryRead( dir );
      test.identical( files, [ 'link_test.txt' ] );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    return self.provider.linkSoft
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
    })
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'try make hardlink for folder';
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

function fileReadAsync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.fileRead ) )
  return;

  var consequence = new _.Consequence().give();

  if( isBrowser )
  return;

  function encode( src, encoding )
  {
    return new Buffer( src ).toString( encoding );
  }

  function decode( src, encoding )
  {
    return Buffer.from( src, encoding ).toString( 'utf8' );
  }

  var src = 'Excepteur sint occaecat cupidatat non proident';

  consequence
  .ifNoErrorThen( function()
  {
    test.description ='read from file';
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
    test.description ='read from file, encoding : ascii';
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
    test.description ='read from file, encoding : utf16le';
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
    test.description ='read from file, encoding : ucs2';
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
    test.description ='read from file, encoding : base64';
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
    test.description ='read from file, encoding : arraybuffer';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'arraybuffer'
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
    test.description ='read from file, encoding : buffer';
    var con = self.provider.fileRead
    ({
      filePath : self.testFile,
      sync : 0,
      encoding : 'buffer'
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

function linkHardSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.description = 'linkHardAct is not implemented'
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

  function makeFiles( names, dirPath, data )
  {
    var paths = names.map( ( name, i ) =>
    {
      var filePath = self.makePath( _.pathJoin( dirPath, name ) )
      self.provider.fileWrite({ filePath : filePath, data : data[ i ] || data, purging : 1 });
      return filePath;
    });

    return paths;
  }

  function makeHardLinksToPath( filePath, amount )
  {
    _.assert( _.strHas( filePath, 'tmp.tmp' ) );
    var dir = _.dirTempMake( _.pathDir( filePath ) );
    for( var i = 0; i < amount; i++ )
    self.provider.linkHard( _.pathJoin( dir, 'file' + i ), filePath );
  }

  var dir = test.context.makePath( 'written/linkHard' );
  var srcPath,dstPath;

  if( !self.provider.fileStat( dir ) )
  self.provider.directoryMake( dir );

  //

  test.description = 'make link async';
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

  test.description = 'make for file that not exist';
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

  test.description = 'link already exists';
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

  test.shouldThrowErrorSync( function( )
  {
    self.provider.linkHard
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

  test.description = 'src is equal to dst';
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

  test.description = 'try make hardlink for folder';
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

  test.description = 'dstPath option, files are not linked';
  var paths = makeFiles( fileNames, currentTestDir, data );
  paths = _.pathsNormalize( paths )
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.description = 'dstPath option, linking files from different directories';
  paths = fileNames.map( ( n ) => _.pathJoin( 'dir_'+ n, n ) );
  paths = makeFiles( paths, currentTestDir, data );
  paths = _.pathsNormalize( paths )

  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.description = 'dstPath option, try to link already linked files';
  var paths = makeFiles( fileNames, currentTestDir, data );
  paths = _.pathsNormalize( paths );
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
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.description = 'dstPath, rewriting off, try to rewrite existing files';
  var paths = makeFiles( fileNames, currentTestDir, fileNames );
  paths = _.pathsNormalize( paths );
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

  test.description = 'dstPath option, groups of linked files ';
  var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );

  /**/

  var groups = [ [ 0,1 ],[ 2,3,4 ],[ 5 ] ];
  var paths = makeFiles( fileNames, currentTestDir, fileNames );
  paths = _.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  var groups = [ [ 0,1 ],[ 1,2,3 ],[ 3,4,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir, fileNames );
  paths = _.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  var groups = [ [ 0,1,2,3 ],[ 4,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir, fileNames );
  paths = _.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  var groups = [ [ 0,1,2,3,4 ],[ 0,5 ] ];
  var paths = makeFiles( fileNames, currentTestDir, fileNames );
  paths = _.pathsNormalize( paths );
  linkGroups( paths,groups );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.description = 'dstPath option, only first path exists';
  var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  makeFiles( fileNames.slice( 0, 1 ), currentTestDir, fileNames[ 0 ] );
  var paths = fileNames.map( ( n )  => self.makePath( _.pathJoin( currentTestDir, n ) ) );
  paths = _.pathsNormalize( paths );
  self.provider.linkHard
  ({
    sync : 1,
    dstPath : paths,
    rewriting : 1,
    throwing : 1
  })
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );
  self.provider.fileWrite( paths[ paths.length - 1 ], fileNames[ fileNames.length - 1 ] );
  test.identical( self.provider.fileRead( paths[ 0 ] ), self.provider.fileRead( paths[ paths.length - 1 ] ) );

  /**/

  test.description = 'dstPath option, all paths not exist';
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  var paths = fileNames.map( ( n )  => self.makePath( _.pathJoin( currentTestDir, n ) ) );
  paths = _.pathsNormalize( paths );
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

  /**/

  //!!! repair
 /*  test.description = 'dstPath option, same date but different content';
  var paths = makeFiles( fileNames, currentTestDir, data );
  paths = _.pathsNormalize( paths );
  self.provider.linkHard({ dstPath : paths });
  self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
  self.provider.fileWrite({ filePath : paths[ paths.length - 1 ], data : '  ', writeMode : 'prepend' });
  test.shouldThrowError( () =>
  {
    self.provider.linkHard({ dstPath : paths });
  });
  test.shouldBe( !self.provider.filesAreHardLinked( paths ) ); */

  /**/

  test.description = 'dstPath option, same date but different content, allowDiffContent';
  var paths = makeFiles( fileNames, currentTestDir, data );
  paths = _.pathsNormalize( paths );
  self.provider.linkHard({ dstPath : paths });
  self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
  self.provider.fileWrite({ filePath : paths[ paths.length - 1 ], data : '  ', writeMode : 'prepend' });
  self.provider.linkHard({ dstPath : paths, allowDiffContent : 1 });
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );

  /**/

  test.description = 'using srcPath as source for files from dstPath';
  var paths = makeFiles( fileNames, currentTestDir, data );
  paths = _.pathsNormalize( paths );
  var srcPath = paths.pop();
  self.provider.linkHard({ srcPath : srcPath, dstPath : paths });
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ paths.length - 1 ] );
  test.identical( src, dst )

  /* sourceMode */

  test.description = 'sourceMode: source must be a newest file, hardlinks are not counted';
  var paths = makeFiles( fileNames, currentTestDir, data );
  test.shouldBe( paths.length >= 3 );
  self.provider.fileWrite( paths[ 1 ], test.description )
  makeHardLinksToPath( paths[ 1 ], 3 );
  paths = _.pathsNormalize( paths );
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified>hardlinks<'
  });
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ paths.length - 1 ];
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( paths[ 1 ] );
  test.identical( src, dst )

  //

  //!!!repair

  /* test.description = 'sourceMode: source must be a file with max amount of links';
  self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  var paths = makeFiles( fileNames, currentTestDir, data );
  self.provider.fileWrite( paths[ 0 ], 'max links file' );
  test.shouldBe( paths.length >= 3 );
  makeHardLinksToPath( paths[ 0 ], 3 ); //3 links to a file
  makeHardLinksToPath( paths[ 1 ], 2 ); //2 links to a file
  self.provider.fileWrite( paths[ 2 ], '1' );
  paths = _.pathsNormalize( paths );
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks>'
  });
  test.shouldBe( self.provider.filesAreHardLinked( paths ) );
  var srcPath = paths[ 0 ];
  var dstPath = paths[ 1 ];
  var src = self.provider.fileRead( srcPath );
  var dst = self.provider.fileRead( dstPath );
  test.identical( src, 'max links file' );
  test.identical( dst, 'max links file' );
  var srcStat = self.provider.fileStat( srcPath );
  var dstStat = self.provider.fileStat( dstPath );
  test.identical( srcStat.nlink, 9 );
  test.identical( dstStat.nlink, 9 ); */

  //

  test.description = 'sourceMode: all sort methods are disabled, single source file can not be finded';
  var paths = makeFiles( fileNames, currentTestDir, data );
  paths = _.pathsNormalize( paths );
  test.shouldThrowError( () =>
  {
  self.provider.linkHard
  ({
    dstPath : paths,
    sourceMode : 'modified<hardlinks<'
  });
  })
  test.shouldBe( !self.provider.filesAreHardLinked( paths ) );
}

//

function linkHardActSync( test )
{
  var self = this;

  if( !_.routineIs( self.provider.linkHardAct ) )
  {
    test.description = 'linkHardAct is not implemented'
    test.identical( 1, 1 )
    return;
  }

  var mp = _.routineJoin( test.context, test.context.makePath );
  var dir = mp( 'linkHardActSync' );

  //

  test.description = 'basic usage';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  test.description = 'no src';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );

  //

  test.description = 'src is not a terminal';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.directoryMake( srcPath );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.filesDelete( dir );

  //

  test.description = 'src is a terminal, check link';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  self.provider.filesDelete( dir );

  //

  test.description = 'src is a hard link, check link';
  self.provider.filesDelete( dir );
  var filePath = _.pathJoin( dir,'file' );
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( filePath, filePath );
  self.provider.linkHard({ srcPath : filePath, dstPath : srcPath, sync : 1 });
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, filePath ] ) );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.filesAreHardLinked( [ filePath, srcPath, dstPath ] ) );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  var file = self.provider.fileRead( filePath );
  test.identical( srcFile, file );
  self.provider.filesDelete( dir );

  //

  test.description = 'src is a soft link, check link';
  self.provider.filesDelete( dir );
  var filePath = _.pathJoin( dir,'file' );
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( filePath, filePath );
  self.provider.linkSoft({ srcPath : filePath, dstPath : srcPath, sync : 1 });
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.fileWrite( dstPath, dstPath );
  var srcFile = self.provider.fileRead( srcPath );
  test.identical( srcFile, dstPath );
  var file = self.provider.fileRead( filePath );
  test.identical( srcFile, file );

  //

  test.description = 'dst is a terminal';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, dstPath );
  self.provider.filesDelete( dir );

  //

  test.description = 'dst is a hard link';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, srcPath );
  self.provider.filesDelete( dir );

  //

  test.description = 'dst is a soft link';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.fileIsSoftLink( dstPath ) );
  var dstFile = self.provider.fileRead( dstPath );
  test.identical( dstFile, srcPath );
  self.provider.filesDelete( dir );

  //

  test.description = 'dst is dir';
  self.provider.filesDelete( dir );
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
  var filePath = _.pathJoin( dstPath, 'file' )
  var filePath2 = _.pathJoin( dstPath, 'file2' )
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

  test.description = 'should not create folders structure for path';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir,'parent/dst' );
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
  test.shouldBe( !self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  self.provider.filesDelete( dir );

  //

  test.description = 'should nativize all paths in options map if needed by its own means';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir,'dst' );
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
  expected.srcPath = self.provider.pathNativize( o.srcPath );
  expected.dstPath = self.provider.pathNativize( o.dstPath );

  self.provider.linkHardAct( o );
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  test.identical( o, expected );
  self.provider.filesDelete( dir );

  //

  test.description = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.pathJoin( dir,'src' );
  self.provider.fileWrite( srcPath, srcPath );
  var dstPath = _.pathJoin( dir,'dst' );
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
  test.shouldBe( self.provider.filesAreHardLinked( [ srcPath, dstPath ] ) );
  var got = _.mapOwnKeys( o );
  test.identical( got, expected );
  self.provider.filesDelete( dir );

  //

  if( !Config.debug )
  return;

  test.description = 'should assert that path is absolute';
  var srcPath = './src';
  var dstPath = _.pathJoin( dir,'dst' );

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

  test.description = 'should not extend or delete fields of options map, no _providerOptions, routineOptions';
  var srcPath = _.pathJoin( dir,'src' );;
  var dstPath = _.pathJoin( dir,'dst' );

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
    test.description = 'should expect normalized path, but not nativized';
    var srcPath = _.pathJoin( dir,'src' );
    self.provider.fileWrite( srcPath, srcPath );
    var dstPath = _.pathJoin( dir,'dst' );
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
    o.srcPath = self.provider.pathNativize( o.srcPath );
    o.dstPath = self.provider.pathNativize( o.dstPath );
    test.shouldThrowError( () =>
    {
      self.provider.linkHardAct( o );
    })
    self.provider.filesDelete( dir );
  }

  //

  test.description = 'should expect ready options map, no complex arguments preprocessing';
  var srcPath = _.pathJoin( dir,'src' );
  var dstPath = _.pathJoin( dir,'dst' );
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
    test.description = 'linkHardAct is not implemented'
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

  function makeFiles( names, dirPath, data )
  {
    var paths = names.map( ( name, i ) =>
    {
      var filePath = self.makePath( _.pathJoin( dirPath, name ) )
      self.provider.fileWrite({ filePath : filePath, data : data[ i ] || data, purging : 1 });
      return filePath;
    });

    return paths;
  }

  function makeHardLinksToPath( filePath, amount )
  {
    _.assert( _.strHas( filePath, 'tmp.tmp' ) );
    var dir = _.dirTempMake( _.pathDir( filePath ) );
    for( var i = 0; i < amount; i++ )
    self.provider.linkHard( _.pathJoin( dir, 'file' + i ), filePath );
  }

  var dir = test.context.makePath( 'written/linkHardAsync' );
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
    test.description = 'make link async';
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
    test.description = 'make for file that not exist';
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

  .doThen( function()
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
    test.description = 'link already exists';
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

  .doThen( function()
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
    test.description = 'src is equal to dst';
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
    test.description = 'try make hardlink for folder';
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

  .doThen( function()
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

  .doThen( function()
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
    test.description = 'dstPath option, files are not linked';
    var paths = makeFiles( fileNames, currentTestDir, data );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.description = 'dstPath option, linking files from different directories';
    paths = fileNames.map( ( n ) => _.pathJoin( 'dir_'+ n, n ) );
    paths = makeFiles( paths, currentTestDir, data );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.description = 'dstPath option, try to link already linked files';
    var paths = makeFiles( fileNames, currentTestDir, data );
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
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.description = 'dstPath, rewriting off, try to rewrite existing files';
    var paths = makeFiles( fileNames, currentTestDir, fileNames );
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
    test.description = 'dstPath option, groups of linked files ';
    fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1 ],[ 2,3,4 ],[ 5 ] ];
    var paths = makeFiles( fileNames, currentTestDir, fileNames );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1 ],[ 1,2,3 ],[ 3,4,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir, fileNames );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1,2,3 ],[ 4,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir, fileNames );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    var groups = [ [ 0,1,2,3,4 ],[ 0,5 ] ];
    var paths = makeFiles( fileNames, currentTestDir, fileNames );
    linkGroups( paths,groups );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () => test.shouldBe( self.provider.filesAreHardLinked( paths ) ) );
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.description = 'dstPath option, only first path exists';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    makeFiles( fileNames.slice( 0, 1 ), currentTestDir, fileNames[ 0 ] );
    var paths = fileNames.map( ( n )  => self.makePath( _.pathJoin( currentTestDir, n ) ) );
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    .doThen( () =>
    {
      test.shouldBe( self.provider.filesAreHardLinked( paths ) );
      self.provider.fileWrite( paths[ paths.length - 1 ], fileNames[ fileNames.length - 1 ] );
      test.identical( self.provider.fileRead( paths[ 0 ] ), self.provider.fileRead( paths[ paths.length - 1 ] ) );
    })
  })

  /**/

  .ifNoErrorThen( function()
  {
    test.description = 'dstPath option, all paths not exist';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    var paths = fileNames.map( ( n )  => self.makePath( _.pathJoin( currentTestDir, n ) ) );
    var con = self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    return test.shouldThrowError( con );
  })

  /**/

  //!!!repair
  /* .doThen( function()
  {
    test.description = 'dstPath option, same date but different content';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = makeFiles( fileNames, currentTestDir, data );
    self.provider.linkHard({ dstPath : paths });
    self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
    self.provider.fileWrite({ filePath : paths[ paths.length - 1 ], data : '  ', writeMode : 'prepend' });
    var con = self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1
    })
    return test.shouldThrowError( con )
    .doThen( () =>
    {
      test.shouldBe( !self.provider.filesAreHardLinked( paths ) );
    });
  }) */

  /**/

  .doThen( function()
  {
    test.description = 'dstPath option, same date but different content, allow different files';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = _.pathsNormalize( makeFiles( fileNames, currentTestDir, data ) );
    self.provider.linkHard({ dstPath : paths });
    self.provider.fileTouch({ filePath : paths[ paths.length - 1 ], purging : 1 });
    self.provider.fileWrite({ filePath : paths[ paths.length - 1 ], data : '  ', writeMode : 'prepend' });
    return self.provider.linkHard
    ({
      sync : 0,
      dstPath : paths,
      rewriting : 1,
      throwing : 1,
      allowDiffContent : 1
    })
    .doThen( () =>
    {
      test.shouldBe( self.provider.filesAreHardLinked( paths ) );
    });
  })

  /* sourceMode */

  .doThen( function()
  {
    test.description = 'sourceMode: source must be a newest file, hardlinks are not counted';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    var paths = makeFiles( fileNames, currentTestDir, data );
    test.shouldBe( paths.length >= 3 );
    self.provider.fileWrite( paths[ 1 ], test.description )
    makeHardLinksToPath( paths[ 1 ], 3 );
    paths = _.pathsNormalize( paths );
    return self.provider.linkHard
    ({
      dstPath : paths,
      sourceMode : 'modified>hardlinks<',
      sync : 0
    })
    .ifNoErrorThen( () =>
    {
      test.shouldBe( self.provider.filesAreHardLinked( paths ) );
      var srcPath = paths[ paths.length - 1 ];
      var src = self.provider.fileRead( srcPath );
      var dst = self.provider.fileRead( paths[ 1 ] );
      test.identical( src, dst )
    })
  })

  //

  // !!!repair

  /* .doThen( function()
  {
    test.description = 'sourceMode: source must be a file with max amount of links';
    var fileNames = [ 'a1', 'a2', 'a3', 'a4', 'a5', 'a6' ];
    self.provider.filesDelete( test.context.makePath( currentTestDir ) );
    var paths = makeFiles( fileNames, currentTestDir, data );
    self.provider.fileWrite( paths[ 0 ], 'max links file' );
    test.shouldBe( paths.length >= 3 );
    makeHardLinksToPath( paths[ 0 ], 3 ); //3 links to a file
    makeHardLinksToPath( paths[ 1 ], 2 ); //2 links to a file
    self.provider.fileWrite( paths[ 2 ], '1' );
    paths = _.pathsNormalize( paths );
    return self.provider.linkHard
    ({
      dstPath : paths,
      sync : 0,
      sourceMode : 'modified<hardlinks>'
    })
    .ifNoErrorThen( () =>
    {
      test.shouldBe( self.provider.filesAreHardLinked( paths ) );
      var srcPath = paths[ 0 ];
      var dstPath = paths[ 1 ];
      var src = self.provider.fileRead( srcPath );
      var dst = self.provider.fileRead( dstPath );
      test.identical( src, 'max links file' );
      test.identical( dst, 'max links file' );
      var srcStat = self.provider.fileStat( srcPath );
      var dstStat = self.provider.fileStat( dstPath );
      test.identical( srcStat.nlink, 9 );
      test.identical( dstStat.nlink, 9 );
    })

  }) */

  return consequence;
}

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

  test.description = 'swap two files content';
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

  test.description = 'swap two dirs content';
  srcPath = test.context.makePath( 'written/fileExchange/src/src.txt' );
  dstPath = test.context.makePath( 'written/fileExchange/dst/dst.txt' );

  /*throwing on*/

  self.provider.filesDelete( dir );
  self.provider.fileWrite( srcPath, 'src' );
  self.provider.fileWrite( dstPath, 'dst' );
  self.provider.fileExchange
  ({
    srcPath : _.pathDir( srcPath ),
    dstPath : _.pathDir( dstPath ),
    sync : 1,
    throwing : 1
  });
  src = self.provider.directoryRead( _.pathDir( srcPath ) );
  dst = self.provider.directoryRead( _.pathDir( dstPath ) );
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
    srcPath : _.pathDir( srcPath ),
    dstPath : _.pathDir( dstPath ),
    sync : 1,
    throwing : 1
  });
  src = self.provider.directoryRead( _.pathDir( srcPath ) );
  dst = self.provider.directoryRead( _.pathDir( dstPath ) );
  test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
  src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
  dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
  test.identical( [ src, dst ], [ 'dst', 'src' ] );

  //

  test.description = 'path not exist';
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
    test.description = 'swap two files content';
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
    test.description = 'swap two dirs content';
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
      srcPath : _.pathDir( srcPath ),
      dstPath : _.pathDir( dstPath ),
      sync : 0,
      allowMissing : 1,
      throwing : 1
    })
    .ifNoErrorThen( function()
    {
      src = self.provider.directoryRead( _.pathDir( srcPath ) );
      dst = self.provider.directoryRead( _.pathDir( dstPath ) );
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
      srcPath : _.pathDir( srcPath ),
      dstPath : _.pathDir( dstPath ),
      sync : 0,
      allowMissing : 1,
      throwing : 0
    })
    .ifNoErrorThen( function()
    {
      src = self.provider.directoryRead( _.pathDir( srcPath ) );
      dst = self.provider.directoryRead( _.pathDir( dstPath ) );
      test.identical( [ src, dst ], [ [ 'dst.txt' ], [ 'src.txt' ] ] );
      src = self.provider.fileRead( _.strReplaceAll( srcPath, 'src.txt', 'dst.txt' ) );
      dst = self.provider.fileRead( _.strReplaceAll( dstPath, 'dst.txt', 'src.txt' ) );
      test.identical( [ src, dst ], [ 'dst', 'src' ] );
    });
  })

  //

  .ifNoErrorThen( function()
  {
    test.description = 'path not exist';
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

function pathNativize( t )
{
  var self = this;

  if( !_.routineIs( self.provider.pathNativize ) )
  return;

  if( !( self.provider instanceof _.FileProvider.HardDrive ) )
  {
    t.description = 'pathNativize returns src'
    t.identical( 1, 1 )
    return;
  }

  if( !isBrowser && process.platform === 'win32' )
  {
    t.description = 'path in win32 style ';

    /**/

    debugger
    var path = '/A/abc/';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\abc\\';
    t.identical( got, expected );

    /**/

    var path = '/A/';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\';
    t.identical( got, expected );

    /**/

    var path = '/A';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\';
    t.identical( got, expected );

    /**/

    var path = '/A/a';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\a';
    t.identical( got, expected );

    /**/

    var path = 'A:/a';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\a';
    t.identical( got, expected );

    /**/

    var path = '\\A\\a';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\a';
    t.identical( got, expected );

    /**/

    var path = 'A';
    var got = self.provider.pathNativize( path );
    var expected = 'A';
    t.identical( got, expected );

    /**/

    var path = '/c/a';
    var got = self.provider.pathNativize( path );
    var expected = 'c:\\a';
    t.identical( got, expected );

    /**/

    var path = '/A/1.txt';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\1.txt';
    t.identical( got, expected );

    /**/

    var path = 'A:/a\\b/c\\d';
    var got = self.provider.pathNativize( path );
    var expected = 'A:\\a\\b\\c\\d';
    t.identical( got, expected );
  }

  //

  if( Config.debug )
  {
    t.description = 'path is not a string ';
    t.shouldThrowErrorSync( function()
    {
      self.provider.pathNativize( 1 );
    })
  }
}

//

function experiment( test )
{
  var self = this;

  test.identical( 1,1 );
}

// --
// proto
// --

var Self =
{

  name : 'FileProvider',
  abstract : 1,
  silencing : 1,
  // verbosity : 7,

  context :
  {
    makePath : makePath,
    providerIsInstanceOf : providerIsInstanceOf
    // shouldWriteOnlyOnce : shouldWriteOnlyOnce
  },

  tests :
  {

    //testDelaySample : testDelaySample,
    mustNotThrowError : mustNotThrowError,

    readWriteSync : readWriteSync,
    readWriteAsync : readWriteAsync,

    fileTouch : fileTouch,

    // writeAsyncThrowingError : writeAsyncThrowingError,

    fileCopySync : fileCopySync,
    fileCopyActSync : fileCopyActSync,
    fileCopyLinksSync : fileCopyLinksSync,
    fileCopyAsync : fileCopyAsync,
    // fileCopyLinksAsync : fileCopyLinksAsync,
    // fileCopyAsyncThrowingError : fileCopyAsyncThrowingError,/* last case dont throw error */

    fileRenameSync : fileRenameSync,
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

    // fileReadAsync : fileReadAsync,

    linkSoftSync : linkSoftSync,
    linkSoftAsync : linkSoftAsync,

    linkHardSync : linkHardSync,
    linkHardActSync : linkHardActSync,
    linkHardAsync : linkHardAsync,

    fileExchangeSync : fileExchangeSync,
    fileExchangeAsync : fileExchangeAsync,

    //etc

    pathNativize : pathNativize,

    // experiment : experiment,

  },

};

wTestSuit( Self );

})();
