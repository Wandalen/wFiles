( function _Url_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Abstract.s' );

}

// if( wTools.FileProvider.Url )
// return;

//

var _ = wTools;
var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderUrl( o )
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

function fileReadAct( o )
{
  var self = this;
  var con = wConsequence();
  var Reqeust,request,total,result;

  if( _.strIs( o ) )
  o = { filePath : o };

  _.routineOptions( fileReadAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ),'fileReadAct :','expects ( o.filePath )' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects ( o.encoding )' );
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

  function handleBegin( e )
  {

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
    console.warn( 'REMINDER : implement handleProgress' );
    // !!! not implemented well
    if( e.lengthComputable )
    if( o.onProgress )
    wConsequence.give( o.onProgress,
    {
      progress : e.loaded / e.total,
      options : o,
    });
  }

  /* error */

  function handleError( err )
  {
    debugger;

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    var err = _.err( 'fileReadAct( ',o.filePath,' )\n',err );
    o.ended = 1;

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

    if ( this.readyState === 2 )
    {

    }
    else if ( this.readyState === 3 )
    {

      var data = getData( this );
      if( !data ) return;
      if( !total ) total = this.getResponseHeader( 'Content-Length' );
      total = Number( total ) || 1;
      if( isNaN( total ) ) return;
      handleProgress( data.length / total,o );

    }
    else if ( this.readyState === 4 )
    {

      if( o.ended )
      return;

      /*if ( this.status === 200 || this.status === 0 )*/
      if ( this.status === 200 )
      {

        handleEnd( e );

      }
      else if ( this.status === 0 )
      {
      }
      else
      {

        handleError( '#' + this.status );

      }

    }

  }

  // set

  request = o.request = new Reqeust();

  // request.responseType = self._encodingToRequestEncoding( o.encoding );
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

  if( o.advanced && o.advanced.send !== null )
  request.send( o.advanced.send );
  else
  request.send();

  if( o.sync )
  return result;
  else
  return con;
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

fileReadAct.advanced =
{

  send : null,
  method : 'GET',
  user : null,
  password : null,

}

fileReadAct.isOriginalReader = 1;

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

encoders[ 'arraybuffer' ] =
{

  responseType : 'arraybuffer',
  onBegin : function( e )
  {
    // e.transaction.encoding = 'arraybuffer';
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

  fileReadAct : fileReadAct,

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
_.FileProvider.Url = Self;

if( typeof module === 'undefined' )
if( !_.FileProvider.Default )
{
  _.FileProvider.Default = Self;
  _.fileProvider = new Self();
}

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
