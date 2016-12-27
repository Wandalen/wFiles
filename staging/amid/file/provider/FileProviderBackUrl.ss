( function _FileProviderBackUrl_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Abstract.s' );

}

if( wTools.FileProvider.BackUrl )
return;

//

var _ = wTools;
var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderBackUrl( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

var init = function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

var createReadStreamAct = function createReadStreamAct( o )
{
  var self = this;

  if( _.strIs( o ) )
  {
    o = { pathFile : o };
  }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ),'createReadStreamAct :','expects ( o.pathFile )' );

  var con = new wConsequence( );
  var Request = null;

  var get = function get( url )
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

  get( o.pathFile );

  return con;
}

createReadStreamAct.defaults =
{
  pathFile : null,
}

//

var fileReadAct = function fileReadAct( o )
{
  var self = this;
  var con = new wConsequence( );

  if( _.strIs( o ) )
  {
    o = { pathFile : o };
  }

  var o = _.routineOptions( fileReadAct, o );

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ),'fileReadAct :','expects ( o.pathFile )' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects ( o.encoding )' );
  _.assert( !o.sync,'sync version is not implemented' );

  o.encoding = o.encoding.toLowerCase();
  var encoder = fileReadAct.encoders[ o.encoding ];

  logger.log( 'fileReadAct',o );

  /* on encoding : arraybuffer or encoding : buffer should return buffer( in consequence ) */

  var handleError = function( err )
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

  var onData = function( data )
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

  var onEnd = function()
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

  self.createReadStreamAct( o.pathFile )
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

var fileCopyToHardDrive = function fileCopyToHardDrive( o )
{
  var self = this;
  var con = new wConsequence( );

  if( _.strIs( o ) )
  {
    var pathFile = _.pathJoin( _.pathMainDir( ), _.pathName({ path : o, withExtension : 1 }) );
    o = { url : o, pathFile : pathFile };
  }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ),'fileCopyToHardDrive :','expects ( o.pathFile )' );

  /* begin */

 var HardDrive = _.FileProvider.HardDrive( );
 var writeStream = HardDrive.createWriteStreamAct( { pathFile : o.pathFile });

 self.createReadStreamAct( o.url )
 .got( function( err, response )
 {
   response.pipe( writeStream );

   writeStream.on( 'finish', function( )
   {
     writeStream.close( function( )
     {
       con.give( o.pathFile );
     })
   });

   response.on( 'error', function( err )
   {
     HardDrive.unlinkSync( o.pathFile );
     con.error( _.err( err ) );
   });

   writeStream.on( 'error', function( err )
   {
     HardDrive.unlinkSync( o.pathFile );
     con.error( _.err( err ) );
   });

 });

 return con;
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
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.BackUrl = Self;

if( typeof module === 'undefined' )
if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})( );
