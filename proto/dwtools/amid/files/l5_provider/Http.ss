( function _Http_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _global = _global_;
  let _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = _.FileProvider.Partial;
let Self = function wFileProviderHttp( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Http';

_.assert( !_.FileProvider.Http );

// --
// inter
// --

function init( o )
{
  let self = this;
  Parent.prototype.init.call( self,o );
}

//

function streamReadAct( o )
{
  let self = this;

  // if( _.strIs( o ) )
  // {
  //   o = { filePath : o };
  // }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.filePath ),'streamReadAct :','Expects {-o.filePath-}' );

  let con = new _.Consequence( );
  let Request = null;

  function get( url )
  {
    let info = _.uri.parse( url );
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

streamReadAct.defaults = Object.create( Parent.prototype.streamReadAct.defaults );
streamReadAct.having = Object.create( Parent.prototype.streamReadAct.having );


//

function fileReadAct( o )
{
  let self = this;
  let con = new _.Consequence( );

  // if( _.strIs( o ) )
  // {
  //   o = { filePath : o };
  // }

  _.assertRoutineOptions( fileReadAct,arguments );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.filePath ),'fileReadAct :','Expects {-o.filePath-}' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','Expects {-o.encoding-}' );
  _.assert( !o.sync,'sync version is not implemented' );

  o.encoding = o.encoding.toLowerCase();
  let encoder = fileReadAct.encoders[ o.encoding ];

  logger.log( 'fileReadAct',o );

  /* on encoding : arraybuffer or encoding : buffer should return buffer( in consequence ) */

  function handleError( err )
  {

    if( encoder && encoder.onError )
    try
    {
      err = _._err
      ({
        args : [ stack,'\nfileReadAct( ',o.filePath,' )\n',err ],
        usingSourceCode : 0,
        level : 0,
      });
      err = encoder.onError.call( self,{ error : err, operation : o, encoder : encoder })
    }
    catch( err2 )
    {
      console.error( err2 );
      console.error( err.toString() + '\n' + err.stack );
    }

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

  let result = null;;
  let totalSize = null;
  let dstOffset = 0;

  if( encoder && encoder.onBegin )
  _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder }) === undefined );

  self.streamReadAct({ filePath :  o.filePath })
  .got( function( err, response )
  {
    debugger;

    if( err )
    return handleError( err );

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

  /* */

  function onEnd()
  {
    if( o.encoding === null )
    _.assert( _.bufferRawIs( result ) );
    else
    _.assert( _.strIs( result ) );

    let context = { data : result, operation : o, encoder : encoder };
    if( encoder && encoder.onEnd )
    _.sure( encoder.onEnd.call( self,context ) === undefined );
    result = context.data

    con.give( result );
  }

}

fileReadAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );
fileReadAct.having = Object.create( Parent.prototype.fileReadAct.having );

fileReadAct.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,
}

//

function fileCopyToHardDriveAct( o )
{
  let self = this;
  let con = new _.Consequence( );

  // if( _.strIs( o ) )
  // {
  //   let filePath = self.path.join( self.path.realMainDir( ), self.path.name({ path : o, withExtension : 1 }) );
  //   o = { url : o, filePath : filePath };
  // }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( o.url ),'fileCopyToHardDriveAct :','Expects {-o.filePath-}' );
  _.assert( _.strIs( o.filePath ),'fileCopyToHardDriveAct :','Expects {-o.filePath-}' );

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

  let fileProvider = _.FileProvider.HardDrive( );
  let writeStream = null;

  let filePath = fileProvider.path.nativize( o.filePath );

  console.log( 'filePath',filePath );

  writeStream = fileProvider.streamWrite({ filePath : filePath });

  writeStream.on( 'error', onError );

  writeStream.on( 'finish', function( )
  {
    writeStream.close( function( )
    {
      con.give( o.filePath );
    })
  });

  self.streamReadAct({ filePath : o.url })
  .got( function( err, response )
  {
    response.pipe( writeStream );

   response.on( 'error', onError );

  });

  return con;
}

var defaults = fileCopyToHardDriveAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );

defaults.url = null;

fileCopyToHardDriveAct.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,

}

//

function fileCopyToHardDrive( o )
{
  let self = this;

  if( _.strIs( o ) )
  {
    let filePath = self.path.join( self.path.realMainDir( ), self.path.name({ path : o, withExtension : 1 }) );
    o = { url : o, filePath : filePath };
  }
  else
  {
    _.assert( arguments.length === 1, 'Expects single argument' );
    _.assert( _.strIs( o.url ),'fileCopyToHardDrive :','Expects {-o.filePath-}' );
    _.assert( _.strIs( o.filePath ),'fileCopyToHardDrive :','Expects {-o.filePath-}' );

    let HardDrive = _.FileProvider.HardDrive();
    let dirPath = self.path.dir( o.filePath );
    let stat = HardDrive.fileStat({ filePath : dirPath, throwing : 0 });
    if( !stat )
    {
      try
      {
        HardDrive.directoryMake({ filePath : dirPath, recursive : 1})
      }
      catch ( err )
      {
      }
    }
  }

  return self.fileCopyToHardDriveAct( o );
}

var defaults = fileCopyToHardDrive.defaults = Object.create( Parent.prototype.fileReadAct.defaults );

defaults.url = null;

fileCopyToHardDrive.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,

}

// --
// encoders
// --

let WriteEncoders = {};

WriteEncoders[ 'buffer.raw' ] =
{

  onBegin : function( e )
  {
    e.operation.encoding = null;
  },

}

WriteEncoders[ 'buffer.node' ] =
{

  onBegin : function( e )
  {
    e.operation.encoding = null;
  },

}

WriteEncoders[ 'blob' ] =
{

  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.operation.encoding = 'blob';
  },

}

WriteEncoders[ 'document' ] =
{

  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.operation.encoding = 'document';
  },

}

WriteEncoders[ 'buffer.bytes' ] =
{

  responseType : 'arraybuffer',

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    let result = _.bufferBytesFrom( e.data );
    return result;
  },

}

fileReadAct.encoders = WriteEncoders;

// --
// relationship
// --

let Composes =
{

  safe : 0,
  protocols : _.define.own([ 'http' ]),

  resolvingSoftLink : 0,
  resolvingTextLink : 0,

}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
  Path : _.weburi.CloneExtending({ fileProvider : Self }),
}

// --
// declare
// --

let Proto =
{

  init : init,

  // read

  streamReadAct : streamReadAct,
  fileReadAct : fileReadAct,

  // special

  fileCopyToHardDriveAct : fileCopyToHardDriveAct,
  fileCopyToHardDrive : fileCopyToHardDrive,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

if( typeof module === 'undefined' )
if( !_.FileProvider.Default )
_.FileProvider.Default = Self;

_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
{ /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})( );
