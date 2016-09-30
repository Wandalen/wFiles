( function _FileProviderUrl_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Abstract.s' );

}

//

var _ = wTools;
var Parent = _.FileProvider.Abstract;
var DefaultsFor = Parent.prototype.DefaultsFor;
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

    case 'utf8' :
      return 'text';

    case 'arraybuffer' :
      return 'arraybuffer';

    // case 'json' :
    //   return 'json';

    case 'blob' :
      return 'blob';

    case 'document' :
      return 'document';

    default :
      return encoding;
      //throw _.err( 'Unknown encoding :',encoding );

  }

}

//

var readHookJson =
{
  encodingHigh : 'json',
  encodingLow : 'text',
  onEnd : function( event,data )
  {
    _.assert( _.strIs( data ),'expects string' );
    data = JSON.parse( data );
    return data;
  }
}

//

var readHookJs =
{
  encodingHigh : 'js',
  encodingLow : 'text',
  onEnd : function( event,data )
  {
    _.assert( _.strIs( data ),'expects string' );
    debugger;
    data = eval( data );
    return data;
  }
}

//

var _readHooks = {};
_readHooks[ readHookJson.encodingHigh ] = readHookJson;
_readHooks[ readHookJs.encodingHigh ] = readHookJs;

//

var fileReadAct = function( o )
{
  var self = this;
  var con = wConsequence();
  var Reqeust,request,total;

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assertMapHasOnly( o,fileReadAct.defaults );
  _.mapComplement( o,fileReadAct.defaults );

  if( !_.strIs( o.pathFile ) )
  throw _.err( 'fileReadAct:','expects o.pathFile' );

  if( o.sync )
  throw _.err( 'fileReadAct:','synchronous version is not implemented' );

  if( !o.encoding )
  throw _.err( 'fileReadAct:','expects o.encoding' );
  o.encoding = o.encoding.toLowerCase();

  // advanced

  if( !o.advanced )
  o.advanced = {};
  _.assertMapHasOnly( o.advanced,fileReadAct.advanced );

  if( !o.advanced.method ) o.advanced.method = 'GET';
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

  /* encoding */

  request.responseType = o.encoding;

  // var readHook = self._readHooks[ request.responseType ];
  // if( readHook )
  // request.responseType = readHook.encodingLow;

  if( self._encodingToRequestEncoding( request.responseType ) )
  request.responseType = self._encodingToRequestEncoding( request.responseType );
  else
  request.responseType = request.responseType;

  /* handler */

  var getData = function( response )
  {
    if( request.responseType === 'text' )
    return response.responseText || response.response;
    if( request.responseType === 'document' )
    return response.responseXML || response.response;
    return response.response;
  }

  /* */

  var handleBegin = function( event )
  {
    if( o.onBegin )
    wConsequence.give( o.onBegin,o );
  }

  /* */

  var handleEnd = function( event )
  {

    if( o.ended )
    return;

    try
    {

      var data = getData( request );

      // if( readHook )
      // data = readHook.onEnd( event,data );

      var result;
      // if( o.wrap )
      // result = { data : data, options : o };
      // else
      result = data;

      o.ended = 1;

      if( o.onEnd )
      wConsequence.give( o.onEnd,result );

      con.give( result );
    }
    catch( err )
    {
      handleError( err );
    }

  }

  /* */

  var handleProgress = function( event )
  {
    if( event.lengthComputable )
    if( o.onProgress )
    wConsequence.give( o.onProgress,
    {
      progress : event.loaded / event.total,
      options : o,
    });
  }

  /* */

  var handleError = function( err )
  {
    debugger;
    var err = _.err( 'fileReadAct( ',o.pathFile,' )\n',err );
    o.ended = 1;

    var result = null;
    // if( o.wrap )
    // result = { err : err, options : o };
    // else
    result = err;

    if( o.onEnd )
    wConsequence.error( o.onEnd,result );
    con.error( err );
    //throw err;
  }

  /* */

  var handleErrorEvent = function( event )
  {
    debugger;
    var err = _.err( 'Network error',event );
    return handleError( err );
  }

  /* */

  var handleState = function( event )
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

        handleEnd( event );

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

  request.addEventListener( 'progress', handleProgress );
  request.addEventListener( 'load', handleEnd );
  request.addEventListener( 'error', handleErrorEvent );
  request.addEventListener( 'timeout', handleErrorEvent );
  request.addEventListener( 'readystatechange', handleState );

  /*request.onreadystatechange = handleState;*/

  if( o.data !== undefined && o.data !== null )
  request.send( o.data );
  else
  request.send();

  return con;
}

fileReadAct.defaults = DefaultsFor.fileReadAct;

// fileReadAct.defaults =
// {
//
//   sync : 0,
//   wrap : 0,
//
//   encoding : 'utf8',
//   pathFile : null,
//   silent : null,
//   name : null,
//
//   advanced : null,
//
//   onBegin : null,
//   onEnd : null,
//   onProgress : null,
//
// }

// DefaultsFor.fileReadAct =
// {
//
//   sync : 0,
//   pathFile : null,
//   encoding : 'utf8',
//   advanced : null,
//
// }

fileReadAct.advanced =
{

  //url : null,

  method : 'GET',
  user : null,
  password : null,

  //responseType : 'arraybuffer',

}

fileReadAct.isOriginalReader = 1;

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

  _readHooks : _readHooks,

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
