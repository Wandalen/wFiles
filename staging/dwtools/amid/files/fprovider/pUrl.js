( function _Url_js_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var _global = _global_;
  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

}

var _global = _global_;
var _ = _global_.wTools;
_.assert( !_.FileProvider.Url );

//
var _global = _global_;
var _ = _global_.wTools;
var Parent = _.FileProvider.Partial;
var Self = function wFileProviderUrl( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Url';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

function fileStatAct( o )
{
  var self = this;
  var result = new _.FileStat();
  var con;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileStatAct,arguments );

  /* */

  function errorGive( err )
  {
    result = null;
    if( o.throwing )
    {
      err = _.err( err );
      if( con )
      con.error( err );
      else
      throw err
    }
    return null;
  }

  /* */

  function fileSizeGet()
  {

    debugger;
    var request = new XMLHttpRequest();
    request.open( 'HEAD', o.filePath, !o.sync );
    request.onreadystatechange = function( e )
    {

      if( this.status !== 200 )
      {
        return errorGive( '#' + this.status + ' : ' + this.statusText );
      }

      if( this.readyState == this.DONE )
      {
        var size = parseInt( request.getResponseHeader( 'Content-Length' ) );
        result.size = size;
        if( con )
        con.give( result );
      }
    }
    request.send();
  }

  /* */

  function getFileStat()
  {
    result.isFile = function() { return true; };
    result.isDirectory = function() { return false; };
    try
    {
      fileSizeGet();
    }
    catch( err )
    {
      debugger;
      return errorGive( err );
    }
    return result;
  }

  /* */

  if( o.sync )
  {
    return getFileStat( o.filePath );
  }
  else
  {
    con = new _.Consequence();
    getFileStat( o.filePath );
    return con;
  }

}

fileStatAct.defaults = Object.create( Parent.prototype.fileStatAct.defaults );
fileStatAct.having = Object.create( Parent.prototype.fileStatAct.having );

//

function fileReadAct( o )
{
  var self = this;
  var con = _.Consequence();
  var Reqeust,request,total,result;

  // if( _.strIs( o ) )
  // o = { filePath : o };

  _.assertRoutineOptions( fileReadAct,arguments );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ),'fileReadAct :','expects {-o.filePath-}' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects {-o.encoding-}' );
  // _.assert( !o.sync,'fileReadAct :','synchronous version is not implemented' );

  o.encoding = o.encoding.toLowerCase();
  var encoder = fileReadAct.encoders[ o.encoding ];

  // advanced

  if( !o.advanced )
  o.advanced = {};

  _.mapComplement( o.advanced,fileReadAct.advanced );
  _.assertMapHasOnly( o.advanced,fileReadAct.advanced );

  o.advanced.method = o.advanced.method.toUpperCase();

  // http request

  if( typeof XMLHttpRequest !== 'undefined' )
  Reqeust = XMLHttpRequest;
  else if( typeof ActiveXObject !== 'undefined' )
  Reqeust = new ActiveXObject( 'Microsoft.XMLHTTP' );
  else
  {
    throw _.err( 'not implemented' );
  }

  /* handler */

  function getData( response )
  {
    if( request.responseType === 'text' )
    return response.responseText || response.response;
    if( request.responseType === 'document' )
    return response.responseXML || response.response;
    return response.response;
  }

  /* begin */

  function handleBegin()
  {

    // if( o.encoding !== 'utf8' )
    // debugger;

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,{ transaction : o, encoder : encoder });

    if( !o.sync )
    if( encoder && encoder.responseType )
    request.responseType = encoder.responseType;

  }

  /* end */

  function handleEnd( e )
  {

    if( o.ended )
    return;

    try
    {

      result = getData( request );

      if( encoder && encoder.onEnd )
      result = encoder.onEnd.call( self,{ data : result, transaction : o, encoder : encoder });

      o.ended = 1;

      con.give( result );
    }
    catch( err )
    {
      handleError( err );
    }

  }

  /* progress */

  function handleProgress( e )
  {
    console.debug( 'REMINDER : implement handleProgress' );
    // not implemented well
    if( e.lengthComputable )
    if( o.onProgress )
    _.Consequence.give( o.onProgress,
    {
      progress : e.loaded / e.total,
      options : o,
    });
  }

  /* error */

  function handleError( err )
  {

    o.ended = 1;

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

    con.error( err );
  }

  /* error event */

  function handleErrorEvent( e )
  {
    var err = _.err( 'Network error',e );
    return handleError( err );
  }

  /* state */

  function handleState( e )
  {

    if( o.ended )
    return;

    if( this.readyState === 2 )
    {

    }
    else if( this.readyState === 3 )
    {

      var data = getData( this );
      if( !data ) return;
      if( !total ) total = this.getResponseHeader( 'Content-Length' );
      total = Number( total ) || 1;
      if( isNaN( total ) ) return;
      handleProgress( data.length / total,o );

    }
    else if( this.readyState === 4 )
    {

      if( o.ended )
      return;

      /*if( this.status === 200 || this.status === 0 )*/
      if( this.status === 200 )
      {

        handleEnd( e );

      }
      else if( this.status === 0 )
      {
      }
      else
      {

        handleError( '#' + this.status );

      }

    }

  }

  /* set */

  request = o.request = new Reqeust();

  if( !o.sync )
  request.responseType = 'text';

  request.addEventListener( 'progress', handleProgress );
  request.addEventListener( 'load', handleEnd );
  request.addEventListener( 'error', handleErrorEvent );
  request.addEventListener( 'timeout', handleErrorEvent );
  request.addEventListener( 'readystatechange', handleState );
  request.open( o.advanced.method, o.filePath, !o.sync, o.advanced.user, o.advanced.password );
  /*request.setRequestHeader( 'Content-type','application/octet-stream' );*/

  handleBegin();

  try
  {
    if( o.advanced && o.advanced.send !== null )
    request.send( o.advanced.send );
    else
    request.send();
  }
  catch( err )
  {
    handleError( err );
  }

  if( o.sync )
  return result;
  else
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

// --
// encoders
// --

var encoders = {};

encoders[ 'utf8' ] =
{

  responseType : 'text',
  onBegin : function( e )
  {
    // e.transaction.encoding = 'text';
  },

}

encoders[ 'buffer-raw' ] =
{

  responseType : 'arraybuffer',
  onBegin : function( e )
  {
    // e.transaction.encoding = 'arraybuffer';
  },

}

encoders[ 'blob' ] =
{

  responseType : 'blob',
  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.transaction.encoding = 'blob';
  },

}

encoders[ 'document' ] =
{

  responseType : 'document',
  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.transaction.encoding = 'document';
  },

}

fileReadAct.encoders = encoders;

// --
// relationship
// --

var Composes =
{

  safe : 0,
  stating : 0,
  // originPath : 'http://',
  protocols : _.define.own([ 'http' ]),

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

  normalize : _.uri.uriNormalize.bind( _.uri ),
  pathsNormalize : _.uri.urisNormalize.bind( _.uri ),
  join : _.uri.uriJoin.bind( _.uri ),
  resolve : _.uri.uriResolve.bind( _.uri ),
  rebase : _.uri.uriRebase.bind( _.uri ),
  dir : _.uri.uriDir.bind( _.uri ),
  relative : _.uri.uriRelative.bind( _.uri ),
  isNormalized : _.uri.uriIsNormalized.bind( _.uri ),
  isAbsolute : _.uri.uriIsAbsolute.bind( _.uri ),
  common : _.uri.uriCommon.bind( _.uri ),

  // read

  fileStatAct : fileStatAct,
  fileReadAct : fileReadAct,

  //


  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

if( _.FileProvider.Find )
_.FileProvider.Find.mixin( Self );
if( _.FileProvider.Secondary )
_.FileProvider.Secondary.mixin( Self );

//

if( !_.FileProvider.Default )
{
  _.FileProvider.Default = Self;
  _.fileProvider = new Self();
}

// --
// export
// --

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
