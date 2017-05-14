( function _Url_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Abstract.s' );

}

// if( wTools.FileProvider.BackUrl )
// return;

//

var _ = wTools;
var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderBack( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

function createReadStreamAct( o )
{
  var self = this;

  if( _.strIs( o ) )
  {
    o = { filePath : o };
  }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ),'createReadStreamAct :','expects ( o.filePath )' );

  var con = new wConsequence( );
  var Request = null;

  function get( url )
  {
    var info = _.urlParse( url );
    Request = info.protocol ? require( info.protocol ) : require( 'http' );

    Request.get( url, function( response )
    {
      if( response.statusCode > 300 && response.statusCode < 400 )
      {
        get( response.headers.location );
      }
      else if( response.statusCode !== 200 )
      {
        con.error( _.err( "Network error. StatusCode: ", response.statusCode ) );
      }
      else
      {
        con.give( response );
      }
    });
  }

  get( o.filePath );

  return con;
}

createReadStreamAct.defaults =
{
  filePath : null,
}

//

function fileReadAct( o )
{
  var self = this;
  var con = new wConsequence( );

  if( _.strIs( o ) )
  {
    o = { filePath : o };
  }

  var o = _.routineOptions( fileReadAct, o );

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ),'fileReadAct :','expects ( o.filePath )' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects ( o.encoding )' );
  _.assert( !o.sync,'sync version is not implemented' );

  o.encoding = o.encoding.toLowerCase();
  var encoder = fileReadAct.encoders[ o.encoding ];

  logger.log( 'fileReadAct',o );

  /* on encoding : arraybuffer or encoding : buffer should return buffer( in consequence ) */

  function handleError( err )
  {
    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    err = _.err( err );
    if( o.sync )
    {
      throw err;
    }
    else
    {
      con.error( err );
    }
  }

  /* */

  function onData( data )
  {

    if( o.encoding === null )
    {
      _.bufferMove
      ({
        dst : result,
        src : data,
        dstOffset : dstOffset
      });

      dstOffset += data.length;
    }
    else
    {
      result += data;
    }

  }

  /* */

  function onEnd()
  {
    if( o.encoding === null )
    _.assert( _.bufferRawIs( result ) );
    else
    _.assert( _.strIs( result ) );

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,{ data : data, transaction : o, encoder : encoder });

    con.give( result );
  }

  /* */

  var result = null;;
  var totalSize = null;
  var dstOffset = 0;

  if( encoder && encoder.onBegin )
  encoder.onBegin.call( self,{ transaction : o, encoder : encoder });

  self.createReadStreamAct( o.filePath )
  .got( function( err, response )
  {
    debugger;

    _.assert( _.strIs( o.encoding ) || o.encoding === null );

    if( o.encoding === null )
    {
      totalSize = response.headers[ 'content-length' ];
      result = new ArrayBuffer( totalSize );
    }
    else
    {
      response.setEncoding( o.encoding );
      result = '';
    }

    response.on( 'data', onData );
    response.on( 'end', onEnd );
    response.on( 'error', handleError );
    debugger;

  });

 return con;
}

fileReadAct.defaults =
{
}

fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

fileReadAct.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,
}

fileReadAct.isOriginalReader = 1;

//

// --
// encoders
// --

var encoders = {};

encoders[ 'utf8' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = 'utf8';
  },

}

encoders[ 'arraybuffer' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = null;
  },

}

encoders[ 'buffer' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = null;
  },

}

encoders[ 'blob' ] =
{

  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.transaction.encoding = 'blob';
  },

}

encoders[ 'document' ] =
{

  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.transaction.encoding = 'document';
  },

}

fileReadAct.encoders = encoders;

//

function fileCopyToHardDriveAct( o )
{
  var self = this;
  var con = new wConsequence( );

  if( _.strIs( o ) )
  {
    var filePath = _.pathJoin( _.pathRealMainDir( ), _.pathName({ path : o, withExtension : 1 }) );
    o = { url : o, filePath : filePath };
  }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.url ),'fileCopyToHardDriveAct :','expects ( o.filePath )' );
  _.assert( _.strIs( o.filePath ),'fileCopyToHardDriveAct :','expects ( o.filePath )' );

  /* begin */

  function onError( err )
  {
    try
    {
      HardDrive.fileDelete( o.filePath );
    }
    catch( err )
    {
    }
    con.error( _.err( err ) );
  }

 //

  var fileProvider = _.FileProvider.HardDrive( );
  var writeStream = null;

  var filePath = fileProvider.pathNativize( o.filePath );

  console.log( 'filePath',filePath );

  writeStream = fileProvider.createWriteStreamAct({ filePath : filePath });

  writeStream.on( 'error', onError );

  writeStream.on( 'finish', function( )
  {
    writeStream.close( function( )
    {
      con.give( o.filePath );
    })
  });

  self.createReadStreamAct( o.url )
  .got( function( err, response )
  {
    response.pipe( writeStream );

   response.on( 'error', onError );

  });

  return con;
}

fileCopyToHardDriveAct.defaults =
{
  url : null
}

fileCopyToHardDriveAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

fileCopyToHardDriveAct.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,

}

fileCopyToHardDriveAct.isOriginalReader = 1;

//

function fileCopyToHardDrive( o )
{
  var self = this;

  if( _.strIs( o ) )
  {
    var filePath = _.pathJoin( _.pathRealMainDir( ), _.pathName({ path : o, withExtension : 1 }) );
    o = { url : o, filePath : filePath };
  }
  else
  {
    _.assert( arguments.length === 1 );
    _.assert( _.strIs( o.url ),'fileCopyToHardDrive :','expects ( o.filePath )' );
    _.assert( _.strIs( o.filePath ),'fileCopyToHardDrive :','expects ( o.filePath )' );

    var HardDrive = _.FileProvider.HardDrive();
    var dirPath = _.pathDir( o.filePath );
    var stat = HardDrive.fileStat({ filePath : dirPath, throwing : 0 });
    if( !stat )
    {
      try
      {
        HardDrive.directoryMake({ filePath : dirPath, force : 1})
      }
      catch ( err )
      {
      }
    }
  }

  return self.fileCopyToHardDriveAct( o );
}

fileCopyToHardDrive.defaults =
{
  url : null
}

fileCopyToHardDrive.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

fileCopyToHardDrive.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,

}

fileCopyToHardDrive.isOriginalReader = 1;


// --
// relationship
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,

  createReadStreamAct : createReadStreamAct,

  fileReadAct : fileReadAct,
  fileCopyToHardDriveAct : fileCopyToHardDriveAct,
  fileCopyToHardDrive : fileCopyToHardDrive,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.protoMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.BackUrl = Self;

if( typeof module === 'undefined' )
if( !_.FileProvider.Default )
_.FileProvider.Default = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})( );
