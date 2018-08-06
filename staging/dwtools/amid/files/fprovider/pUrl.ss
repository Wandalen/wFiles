( function _Url_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  var _global = _global_; var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

}

var _global = _global_;
var _global = _global_; var _ = _global_.wTools;
_.assert( !_.FileProvider.UrlBack );

//

var _global = _global_; var _ = _global_.wTools;
var Parent = _.FileProvider.Partial;
var Self = function wFileProviderUrlBack( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'UrlBack';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

function fileReadStreamAct( o )
{
  var self = this;

  // if( _.strIs( o ) )
  // {
  //   o = { filePath : o };
  // }

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ),'fileReadStreamAct :','expects {-o.filePath-}' );

  var con = new wConsequence( );
  var Request = null;

  function get( url )
  {
    var info = _.uri.uriParse( url );
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

fileReadStreamAct.defaults = Object.create( Parent.prototype.fileReadStreamAct.defaults );
fileReadStreamAct.having = Object.create( Parent.prototype.fileReadStreamAct.having );


//

function fileReadAct( o )
{
  var self = this;
  var con = new wConsequence( );

  // if( _.strIs( o ) )
  // {
  //   o = { filePath : o };
  // }

  _.assertRoutineOptions( fileReadAct,arguments );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ),'fileReadAct :','expects {-o.filePath-}' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects {-o.encoding-}' );
  _.assert( !o.sync,'sync version is not implemented' );

  o.encoding = o.encoding.toLowerCase();
  var encoder = fileReadAct.encoders[ o.encoding ];

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
      err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })
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

  self.fileReadStreamAct({ filePath :  o.filePath })
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

encoders[ 'buffer-raw' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = null;
  },

}

encoders[ 'buffer-node' ] =
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

  // if( _.strIs( o ) )
  // {
  //   var filePath = _.path.pathJoin( _.path.pathRealMainDir( ), _.path.pathName({ path : o, withExtension : 1 }) );
  //   o = { url : o, filePath : filePath };
  // }

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.url ),'fileCopyToHardDriveAct :','expects {-o.filePath-}' );
  _.assert( _.strIs( o.filePath ),'fileCopyToHardDriveAct :','expects {-o.filePath-}' );

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

  writeStream = fileProvider.fileWriteStream({ filePath : filePath });

  writeStream.on( 'error', onError );

  writeStream.on( 'finish', function( )
  {
    writeStream.close( function( )
    {
      con.give( o.filePath );
    })
  });

  self.fileReadStreamAct({ filePath : o.url })
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
  var self = this;

  if( _.strIs( o ) )
  {
    var filePath = _.path.pathJoin( _.path.pathRealMainDir( ), _.path.pathName({ path : o, withExtension : 1 }) );
    o = { url : o, filePath : filePath };
  }
  else
  {
    _.assert( arguments.length === 1, 'expects single argument' );
    _.assert( _.strIs( o.url ),'fileCopyToHardDrive :','expects {-o.filePath-}' );
    _.assert( _.strIs( o.filePath ),'fileCopyToHardDrive :','expects {-o.filePath-}' );

    var HardDrive = _.FileProvider.HardDrive();
    var dirPath = _.path.pathDir( o.filePath );
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
// relationship
// --

var Composes =
{

  safe : 0,
  // originPath : 'http://',
  protocols : [ 'http' ],

  resolvingHardLink : 0,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

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
// define class
// --

var Proto =
{

  init : init,

  // path

  pathNormalize : _.uri.uriNormalize,
  pathsNormalize : _.uri.urisNormalize,
  pathJoin : _.uri.uriJoin,
  pathResolve : _.uri.uriResolve,
  pathRebase : _.uri.uriRebase,
  pathDir : _.uri.uriDir,
  pathRelative : _.uri.uriRelative,
  pathIsNormalized : _.uri.uriIsNormalized,
  pathIsAbsolute : _.uri.uriIsAbsolute,
  pathCommon : _.uri.uriCommon,

  // read

  fileReadStreamAct : fileReadStreamAct,
  fileReadAct : fileReadAct,

  // special

  fileCopyToHardDriveAct : fileCopyToHardDriveAct,
  fileCopyToHardDrive : fileCopyToHardDrive,


  //

  
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || {};

if( typeof module === 'undefined' )
if( !_.FileProvider.Default )
_.FileProvider.Default = Self;

_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})( );
