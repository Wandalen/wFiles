(function(){

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( 'wTools' );
  }
  catch( err )
  {
    require( '../../abase/wTools.s' );
  }

  try
  {
    require( 'wProto' );
  }
  catch( err )
  {
    require( '../../abase/component/Proto.s' );
  }

  try
  {
    require( 'wConsequence' );
  }
  catch( err )
  {
    require( '../../abase/syn/Consequence.s' );
  }

  try
  {
    require( 'wPath' );
    //require( 'wId' );
  }
  catch( err )
  {
    require( '../../abase/component/Path.s' );
    require( '../../abase/component/Id.s' );
  }

}

var Self = wTools;
var _ = wTools;


if( _._included_file_common )
return;


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
  request.responseType = _encodingToRequestEncoding( o.encoding );

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

  sync : 1,
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

//

var filesRead_gen = function( fileRead )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( fileRead ) );

  var filesRead = function( o )
  {

    // options

    if( _.arrayIs( o ) )
    o = { paths : o };

    _.assert( arguments.length === 1 );
    _.assert( _.objectIs( o ) );

    if( _.objectIs( o.paths ) )
    {
      var _paths = [];
      for( var p in o.paths )
      _paths.push({ pathFile : o.paths[ p ], name : p });
      o.paths = _paths;
    }

    o.paths = _.arrayAs( o.paths );

    var con = new wConsequence();
    var result = [];
    var errs = [];

    if( o.sync )
    throw _.err( 'not implemented' );

  /*
    _.assert( !o.onBegin,'not implemented' );
    _.assert( !o.onEnd,'not implemented' );
  */

    _.assert( !o.onProgress,'not implemented' );

    var onBegin = o.onBegin;
    var onEnd = o.onEnd;
    var onProgress = o.onProgress;

    delete o.onBegin;
    delete o.onEnd;
    delete o.onProgress;

    // begin

    if( onBegin )
    wConsequence.give( onBegin,{ options : o } );

    // exec

    for( var p = 0 ; p < o.paths.length ; p++ ) ( function( p )
    {

      con.got();

      var pathFile = o.paths[ p ];
      var readOptions = _.mapScreen( fileRead.defaults,o );
      readOptions.onEnd = o.onEach;
      if( _.objectIs( pathFile ) )
      _.mapExtend( readOptions,pathFile );
      else
      readOptions.pathFile = pathFile;

      fileRead( readOptions ).got( function filesReadFileEnd( err,read )
      {

        if( err || read === undefined )
        {
          debugger;
          errs[ p ] = _.err( 'cant read : ' + _.toStr( pathFile ) + '\n',err );
        }
        else
        result[ p ] = read;

        con.give();

      });

    })( p );

    // end

    con.give().then_( function filesReadEnd()
    {
/*
      if( errs.length )
      return new wConsequence().error( errs[ 0 ] );
*/
      if( errs.length )
      throw _.err( errs[ 0 ] );

      if( o.map === 'name' )
      {
        var _result = {};
        for( var p = 0 ; p < o.paths.length ; p++ )
        _result[ o.paths[ p ].name ] = result[ p ];
        result = _result;
      }
      else if( o.map )
      throw _.err( 'unknown map : ' + o.map );

      var r = { options : o, data : result };

      if( onEnd )
      wConsequence.give( onEnd,r );

      return r;
    });

    //

    return con;
  }

  filesRead.defaults =
  {

    paths : null,
    onEach : null,

    map : '',

  }

  filesRead.defaults.__proto__ = fileRead.default;

  return filesRead;
}

// --
// file provider
// --

var fileProviderUrl = (function( o )
{

  var provider =
  {

    name : 'fileProviderUrl',

    fileRead : fileRead,
    filesRead : filesRead_gen( fileRead ),

    _encodingToRequestEncoding: _encodingToRequestEncoding,

  };

  return fileProviderUrl = function( o )
  {
    var o = o || {};

    _.assert( arguments.length === 0 || arguments.length === 1 );
    _.assertMapOnly( o,fileProviderUrl.defaults );

    _.assert( provider.fileRead.isOriginalReader );

    return provider;
  }

})();

fileProviderUrl.defaults = {};

//

var fileFilterCachingFile = function( provider )
{
  var provider = provider || {};

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assertMapOnly( provider,fileFilterCachingFile.defaults );

  provider.name = 'fileFilterCachingFile';
  provider._cache = {};

  provider.fileRead = function( o )
  {
    var result;
    var o = _._fileOptionsGet.apply( _.fileRead,arguments );
    var pathFile = _.pathResolve( o.pathFile );

    if( provider._cache[ pathFile ] )
    {
      if( o.onEnd )
      o.onEnd( null,provider._cache[ pathFile ] );
      return provider._cache[ pathFile ];
    }

    if( o.sync )
    {
      result = _.fileRead( o );
    }
    else
    {
      throw _.err( 'not tested' );
      var onEnd = o.onEnd;
      o.onEnd = function( err,data )
      {
        if( !err )
        provider._cache[ pathFile ] = data;
      }
      _.fileRead( o );
    }

    return result;
  }

  provider.fileRead.isOriginalReader = 1;

  return provider;
}

fileFilterCachingFile.defaults = {};

//

var fileFilterReroot = function( provider )
{
  var provider = provider || {};

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assertMapOnly( provider,fileFilterReroot.defaults );
  _.assert( _.strIs( provider.pathRoot ),'fileFilterReroot : expects string "pathRoot"' );

  provider.name = 'fileFilterReroot';

  if( !provider.provider )
  provider.provider = _.fileProvider.def();

  for( var f in provider.provider )
  {

    if( !_.routineIs( provider.provider[ f ] ) )
    continue;

    if( !provider.provider[ f ].isOriginalReader )
    continue;

    ( function( f ) {

      var original = provider.provider[ f ];
      provider[ f ] = function fileFilterRerootWrap( o )
      {
        var o = _._fileOptionsGet.apply( original,arguments );

        /* logger.log( 'reroot : ' + o.pathFile + ' -> ' + _.pathReroot( provider.pathRoot, o.pathFile ) ); */

        _.assert( _.strIs( o.pathFile ) );
        o.pathFile = _.pathReroot( provider.pathRoot, o.pathFile );

        return original( o );
      }
      provider[ f ].defaults = original.defaults;
      provider[ f ].isOriginalReader = original.isOriginalReader;

    })( f );

  }

  if( provider.fileRead )
  provider.filesRead = filesRead_gen( provider.fileRead );

  return provider;
}

fileFilterReroot.defaults =
{
  pathRoot : null,
  provider : null,
  filesRead : null,
}

// --
// var
// --

var fileProvider =
{

  url : fileProviderUrl,
  filterChachingFile : fileFilterCachingFile,
  filterReroot : fileFilterReroot,

  def : fileProviderUrl,

}

// --
// prototype
// --

var Proto =
{

  filesRead_gen : filesRead_gen,

  _included_file_common : 1,

}

if( _.filesRead_gen )
throw _.err( 'FileCommon.s included several times!' );

_.mapExtend( _,Proto );
Self.fileProvider = _.mapExtend( Self.fileProvider || {},fileProvider );

// export

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
