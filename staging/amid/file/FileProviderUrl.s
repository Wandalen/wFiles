( function _FileProviderUrl_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileProviderAbstract.s' );

}

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

  switch( encoding )
  {

    case 'utf8' :
      return 'text';

    case 'arraybuffer' :
      return 'arraybuffer';

    case 'json' :
      return 'json';

    case 'blob' :
      return 'blob';

    case 'document' :
      return 'document';

    default :
      throw _.err( 'Unknown encoding :',encoding );

  }

}

//

var fileRead = function( o )
{
  var self = this;
  var con = wConsequence();
  var Reqeust,request,total;

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assertMapOnly( o,fileRead.defaults );
  _.mapComplement( o,fileRead.defaults );

  if( !_.strIs( o.pathFile ) )
  throw _.err( 'url.fileRead:','expects o.pathFile' );

  if( o.sync )
  throw _.err( 'url.fileRead:','synchronous version is not implemented' );

  if( !o.encoding )
  throw _.err( 'url.fileRead:','expects o.encoding' );
  o.encoding = o.encoding.toLowerCase();

  // advanced

  if( !o.advanced )
  o.advanced = {};
  _.assertMapOnly( o.advanced,fileRead.advanced );

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
  request.responseType = self._encodingToRequestEncoding( o.encoding );

  // handler

  var getData = function( response )
  {
    if( o.encoding === 'text' ) return response.responseText || response.response;
    if( o.encoding === 'document' ) return response.responseXML || response.response;
    return response.response;
  }

  var handleBegin = function( event )
  {
    if( o.onBegin )
    wConsequence.give( o.onBegin,o );
  }

  var handleEnd = function( event )
  {

    if( o.ended )
    return;

    var data = getData( request );
    var result = null;
    if( o.wrap )
    result = { data : data, options : o };
    else
    result = data;

    o.ended = 1;

    if( o.onEnd )
    wConsequence.give( o.onEnd,result );

    con.give( result );
  }

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

  var handleError = function( event )
  {
    debugger;
    var err = _.err( 'fileRead( ',o.pathFile,' ) ','Network error',event );
    o.ended = 1;

    var result = null;
    if( o.wrap )
    result = { err : err, options : o };
    else
    result = err;

    if( o.onEnd )
    wConsequence.error( o.onEnd,result );
    con.error( err );
    throw err;
  }

  //

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
  request.addEventListener( 'error', handleError );
  request.addEventListener( 'timeout', handleError );
  request.addEventListener( 'readystatechange', handleState );

  /*request.onreadystatechange = handleState;*/

  if( o.data !== undefined && o.data !== null )
  request.send( o.data );
  else
  request.send();

  return con;
}

fileRead.defaults =
{

  sync : 0,
  wrap : 0,

  encoding : 'utf8',
  pathFile : null,
  silent : null,
  name : null,

  advanced : null,

  onBegin : null,
  onEnd : null,
  onProgress : null,

}

fileRead.advanced =
{

  //url : null,

  method : 'GET',
  user : null,
  password : null,

  //responseType : 'arraybuffer',

}

fileRead.isOriginalReader = 1;

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

  fileRead : fileRead,


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

if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
