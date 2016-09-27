( function _FileProviderAbstract_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );

}

//

var DefaultsFor = {};

DefaultsFor.fileDelete =
{
  pathFile : null,
  force : 1,
  sync : 1,
}

DefaultsFor.filesRead =
{

  sync : 1,
  wrap : 0,
  returnRead : 0,
  silent : 0,

  pathFile : null,
  name : null,
  encoding : 'utf8',

  onBegin : null,
  onEnd : null,
  onError : null,

  advanced : null,

}

//

var _ = wTools;
var Parent = null;
var Self = function wFileProviderAbstract( o )
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

  _.protoComplementInstance( self );

  if( o )
  self.copy( o );

  logger.log( 'new',_.strTypeOf( self ) );

}

//

/**
 * Reads the entire content of a file.
 * Can accepts `pathFile` as first parameters and options as second
 * Returns wConsequence instance. If `o` sync parameter is set to true (by default) and returnRead is set to true,
    method returns encoded content of a file.
 * There are several way to get read content : as argument for function passed to wConsequence.got(), as second argument
    for `o.onEnd` callback, and as direct method returns, if `o.returnRead` is set to true.
 *
 * @example
 * // content of tmp/json1.json : {"a" :1,"b" :"s","c" :[1,3,4]}
   var fileReadOptions =
   {
     sync : 0,
     pathFile : 'tmp/json1.json',
     encoding : 'json',

     onEnd : function( err, result )
     {
       console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
     }
   };

   var con = wTools.fileRead( fileReadOptions );

   // or
   fileReadOptions.onEnd = null;
   var con2 = wTools.fileRead( fileReadOptions );

   con2.got(function( err, result )
   {
     console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
   });

 * @example
   fileRead({ pathFile : file.absolute, encoding : 'buffer' })

 * @param {Object} o read options
 * @param {string} o.pathFile path to read file
 * @param {boolean} [o.sync=true] determines in which way will be read file. If this set to false, file will be read
    asynchronously, else synchronously
 * Note : if even o.sync sets to true, but o.returnRead if false, method will resolve read content through wConsequence
    anyway.
 * @param {boolean} [o.wrap=false] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
    into object with key 'options' and options as value.
 * @param {boolean} [o.returnRead=false] If sets to true, method will return encoded file content directly. Has effect
    only if o.sync is set to true.
 * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
    pass into o.onEnd as first parameter. Note : if sync is set to false, error will caught anyway.
 * @param {string} [o.name=null]
 * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are :
 *    'utf8' : default value, file content will be read as string.
 *    'json' : file content will be parsed as JSON.
 *    'arrayBuffer' : the file content will be return as raw ArrayBuffer.
 * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
 * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
 * @param {Function} [o.onError=null] @see [@link fileRead~onError]
 * @param {*} [o.advanced=null]
 * @returns {wConsequence|ArrayBuffer|string|Array|Object}
 * @throws {Error} if missed arguments
 * @throws {Error} if `o` has extra parameters
 * @method fileRead
 * @memberof wTools
 */

/**
 * This callback is run before fileRead starts read the file. Accepts error as first parameter.
 * If in fileRead passed 'o.wrap' that is set to true, callback accepts as second parameter object with key 'options'
    and value that is reference to options object passed into fileRead method, and user has ability to configure that
    before start reading file.
 * @callback fileRead~onBegin
 * @param {Error} err
 * @param {Object|*} options options argument passed into fileRead.
 */

/**
 * This callback invoked after file has been read, and accepts encoded file content data (by depend from
    options.encoding value), string by default ('utf8' encoding).
 * @callback fileRead~onEnd
 * @param {Error} err Error occurred during file read. If read success it's sets to null.
 * @param {ArrayBuffer|Object|Array|String} result Encoded content of read file.
 */

/**
 * Callback invoke if error occurred during file read.
 * @callback fileRead~onError
 * @param {Error} error
 */

var fileRead = function( o )
{
  var self = this;
  var result = null;
  var o = _._fileOptionsGet.apply( fileRead,arguments );

  _.mapComplement( o,fileRead.defaults );
  _.assert( !o.returnRead || o.sync,'cant return read for async read' );
  if( o.sync )
  _.assert( o.returnRead,'sync expects ( returnRead == 1 )' );

  var encodingProcessor = fileRead.encoders[ o.encoding ];

  /* begin */

  var handleBegin = function()
  {

    if( encodingProcessor && encodingProcessor.onBegin )
    encodingProcessor.onBegin( o );

    if( !o.onBegin )
    return;

    var r;
    if( o.wrap )
    r = { options : o };
    else
    r = o;

    debugger;
    wConsequence.give( o.onBegin,r );
  }

  /* end */

  var handleEnd = function( data )
  {

    if( encodingProcessor && encodingProcessor.onEnd )
    data = encodingProcessor.onEnd({ data : data, options : o });

    var r = null;
    if( o.wrap )
    r = { data : data, options : o };
    else
    r = data;

    debugger;
    if( o.onEnd )
    debugger;

    if( o.onEnd )
    wConsequence.give( o.onEnd,r );
    if( !o.sync )
    wConsequence.give( result,r );

    return result;
  }

  /* error */

  var handleError = function( err )
  {

    debugger;
    if( o.onEnd )
    wConsequence.error( o.onEnd,err );
    if( !o.sync )
    wConsequence.error( con,err );

    if( o.throwing )
    throw _.err( err );

  }

  /* exec */

  handleBegin();

  if( o.throwing )
  {

    result = self._fileRead( o );

  }
  else try
  {

    result = self._fileRead( o );

  }
  catch( err )
  {
    return handleError( err );
  }

  /* throwing */

  if( o.sync )
  {
    if( o.throwing )
    if( _.errorIs( result ) )
    return handleError( result );
  }

  /* return */

  return handleEnd( result );
}

fileRead.defaults =
{

  sync : 0,
  wrap : 0,
  returnRead : 0,
  throwing : 1,

  pathFile : null,
  //name : null,
  encoding : 'utf8',

  onBegin : null,
  onEnd : null,
  onError : null,

  advanced : null,

}

fileRead.isOriginalReader = 0;

//

/**
 * Reads the entire content of a file synchronously.
 * Method returns encoded content of a file.
 * Can accepts `pathFile` as first parameters and options as second
 *
 * @example
 * // content of tmp/json1.json : { "a" : 1, "b" : "s", "c" : [ 1,3,4 ]}
 var fileReadOptions =
 {
   pathFile : 'tmp/json1.json',
   encoding : 'json',

   onEnd : function( err, result )
   {
     console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
   }
 };

 var res = wTools.fileReadSync( fileReadOptions );
 // { a : 1, b : 's', c : [ 1, 3, 4 ] }

 * @param {Object} o read options
 * @param {string} o.pathFile path to read file
 * @param {boolean} [o.wrap=false] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
 into object with key 'options' and options as value.
 * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
 pass into o.onEnd as first parameter. Note : if sync is set to false, error will caught anyway.
 * @param {string} [o.name=null]
 * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are :
 *    'utf8' : default value, file content will be read as string.
 *    'json' : file content will be parsed as JSON.
 *    'arrayBuffer' : the file content will be return as raw ArrayBuffer.
 * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
 * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
 * @param {Function} [o.onError=null] @see [@link fileRead~onError]
 * @param {*} [o.advanced=null]
 * @returns {wConsequence|ArrayBuffer|string|Array|Object}
 * @throws {Error} if missed arguments
 * @throws {Error} if `o` has extra parameters
 * @method fileReadSync
 * @memberof wTools
 */

var fileReadSync = function()
{
  var o = _._fileOptionsGet.apply( fileReadSync,arguments );

  _.mapComplement( o,fileReadSync.defaults );
  o.sync = 1;

  //logger.log( 'fileReadSync.returnRead : ',o.returnRead );

  return self.fileRead( o );
}

fileReadSync.defaults =
{
  returnRead : 1,
  sync : 1,
  encoding : 'utf8',
}

fileReadSync.defaults.__proto__ = fileRead.defaults;
fileReadSync.isOriginalReader = 1;

//

var filesRead = function( o )
{

  logger.log( 'filesRead : ' + _.strTypeOf( this ) );

  // options

  var self = this;

  if( _.arrayIs( o ) )
  o = { paths : o };

  _.assert( arguments.length === 1 );
  _.routineOptions( filesRead,o );

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
    var readOptions = _.mapScreen( self.fileRead.defaults,o );
    readOptions.onEnd = o.onEach;
    if( _.objectIs( pathFile ) )
    _.mapExtend( readOptions,pathFile );
    else
    readOptions.pathFile = pathFile;

    wConsequence.from( self.fileRead( readOptions ) ).got( function filesReadFileEnd( err,read )
    {

      if( err || read === undefined )
      {
        errs[ p ] = _.err( 'cant read : ' + _.toStr( pathFile ) + '\n', ( err || 'unknown reason' ) );
      }
      else
      {
        result[ p ] = read;
      }

      con.give();

    });

  })( p );

  // end

  con.give().got( function filesReadEnd()
  {

    var err;

    if( errs.length )
    err = _.errLog( _.arrayLeft( errs ).element );

    if( o.map === 'name' )
    {
      var _result = {};
      for( var p = 0 ; p < o.paths.length ; p++ )
      _result[ o.paths[ p ].name ] = result[ p ];
      result = _result;
    }
    else if( o.map )
    throw _.err( 'unknown map : ' + o.map );

    var r = { options : o, data : result, errs : errs };

    if( onEnd )
    wConsequence.give( onEnd,err,r );
    con.give( err,r );
  });

  //

  return con;
}

filesRead.defaults =
{

  paths : null,
  onEach : null,

  map : '',
  //all : 0,

}

filesRead.defaults.__proto__ = DefaultsFor.filesRead;

filesRead.isOriginalReader = 0;

// --
// encoders
// --

var encoders = {};

encoders[ 'json' ] =
{

  onBegin : function( o )
  {
    throw _.err( 'not tested' );
    _.assert( o.encoding === 'json' );
    o.encoding = 'utf8';
  },

  onEnd : function( read )
  {
    throw _.err( 'not tested' );
    if( !_.strIs( read.data ) )
    throw _.err( '( fileRead.encoders.json ) expects string' );
    var result = JSON.parse( read.data );
    return result;
  },

}

fileRead.encoders = encoders;

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

var Static =
{
  DefaultsFor : DefaultsFor,
}

// --
// prototype
// --

var Proto =
{

  init : init,

  fileRead : fileRead,
  fileReadSync : fileReadSync,

  filesRead : filesRead,


  // var

  DefaultsFor : DefaultsFor,


  // ident

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Static : Static,

}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

wCopyable.mixin( Self );

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.Abstract = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
