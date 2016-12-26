( function _FileProviderUrl_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Abstract.s' );

}

if( wTools.FileProvider.Url )
return;

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

var init = function( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

var _encodingToRequestEncoding = function( encoding )
{

  _.assert( _.strIs( encoding ) );

  switch( encoding )
  {

    // case 'utf8' :
    //   return 'text';
    //
    // case 'arraybuffer' :
    //   return 'arraybuffer';
    //
    // // case 'json' :
    // //   return 'json';
    //
    // case 'blob' :
    //   return 'blob';
    //
    // case 'document' :
    //   return 'document';

    default :
      return encoding;

  }

}

//

// var readHookJson =
// {
//   encodingHigh : 'json',
//   encodingLow : 'text',
//   onEnd : function( e,data )
//   {
//     _.assert( _.strIs( data ),'expects string' );
//     data = JSON.parse( data );
//     return data;
//   }
// }
//
// //
//
// var readHookJs =
// {
//   encodingHigh : 'js',
//   encodingLow : 'text',
//   onEnd : function( e,data )
//   {
//     _.assert( _.strIs( data ),'expects string' );
//     debugger;
//     data = eval( data );
//     return data;
//   }
// }
//
// //
//
// var _readHooks = {};
// _readHooks[ readHookJson.encodingHigh ] = readHookJson;
// _readHooks[ readHookJs.encodingHigh ] = readHookJs;

//

var fileReadAct = function( o )
{
  var self = this;
  var con = wConsequence();
  var Reqeust,request,total;

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.routineOptions( fileReadAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ),'fileReadAct :','expects ( o.pathFile )' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects ( o.encoding )' );
  _.assert( !o.sync,'fileReadAct :','synchronous version is not implemented' );

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

  request = o.request = new Reqeust();
  request.open( o.advanced.method, o.pathFile, true, o.advanced.user, o.advanced.password );
  /*request.setRequestHeader( 'Content-type','application/octet-stream' );*/

  /* handler */

  var getData = function( response )
  {
    if( request.responseType === 'text' )
    return response.responseText || response.response;
    if( request.responseType === 'document' )
    return response.responseXML || response.response;
    return response.response;
  }

  /* begin */

  var handleBegin = function( e )
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,{ transaction : o, encoder : encoder });

  }

  /* end */

  var handleEnd = function( e )
  {

    if( o.ended )
    return;

    try
    {

      var data = getData( request );

      if( encoder && encoder.onEnd )
      data = encoder.onEnd.call( self,{ data : data, transaction : o, encoder : encoder });

      o.ended = 1;

      con.give( data );
    }
    catch( err )
    {
      handleError( err );
    }

  }

  /* progress */

  var handleProgress = function( e )
  {
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

  var handleError = function( err )
  {
    debugger;

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    var err = _.err( 'fileReadAct( ',o.pathFile,' )\n',err );
    o.ended = 1;

    con.error( err );
  }

  /* error e */

  var handleErrorEvent = function( e )
  {
    var err = _.err( 'Network error',e );
    return handleError( err );
  }

  /* state */

  var handleState = function( e )
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

  handleBegin();

  request.responseType = self._encodingToRequestEncoding( o.encoding );

  request.addEventListener( 'progress', handleProgress );
  request.addEventListener( 'load', handleEnd );
  request.addEventListener( 'error', handleErrorEvent );
  request.addEventListener( 'timeout', handleErrorEvent );
  request.addEventListener( 'readystatechange', handleState );

  if( o.advanced && o.advanced.send !== null )
  request.send( o.advanced.send );
  else
  request.send();

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

  onBegin : function( e )
  {
    e.transaction.encoding = 'text';
  },

}

encoders[ 'arraybuffer' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = 'arraybuffer';
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

  _encodingToRequestEncoding : _encodingToRequestEncoding,

  fileReadAct : fileReadAct,


  // var
  // _readHooks : _readHooks,

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
_.FileProvider.Url = Self;

if( typeof module === 'undefined' )
if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
