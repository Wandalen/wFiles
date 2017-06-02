( function _Abstract_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

}

/* ttt temp workaround, redo later */
// if( wTools.FileProvider && wTools.FileProvider.Abstract )
// return;

//

/**
  * Definitions :
  *  Terminal file :: leaf of filesTree, contains series of bytes. Terminal file cant contain other files.
  *  Directory :: non-leaf node of filesTree, contains other directories and terminal file(s).
  *  File :: any node of filesTree, could be leaf( terminal file ) or non-leaf( directory ).
  *  Only terminal files contains series of bytes, function of directory to organize logical space for terminal files.
  *  self :: current object.
  *  Self :: current class.
  *  Parent :: parent class.
  *  Statics :: static fields.
  *  extend :: extend destination with all properties from source.
  */

//

var WriteMode = [ 'rewrite','prepend','append' ];

//

var _ = wTools;
var Parent = null;
// var FileRecord = _global_.wFileRecord;
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

function init( o )
{
  var self = this;

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( self.verbosity )
  logger.log( 'new',_.strTypeOf( self ) );

}

//

/**
 * Return options for file red/write. If `filePath is an object, method returns it. Method validate result option
    properties by default parameters from invocation context.
 * @param {string|Object} filePath
 * @param {Object} [o] Object with default options parameters
 * @returns {Object} Result options
 * @private
 * @throws {Error} If arguments is missed
 * @throws {Error} If passed extra arguments
 * @throws {Error} If missed `PathFiile`
 * @method _fileOptionsGet
 * @memberof FileProvider.Abstract
 */

function _fileOptionsGet( filePath,o )
{
  var self = this;
  var o = o || {};

  if( _.objectIs( filePath ) )
  {
    o = filePath;
  }
  else
  {
    o.filePath = filePath;
  }

  if( !o.filePath )
  throw _.err( '_fileOptionsGet :','"o.filePath" is required' );

  _.assertMapHasOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

//

function fileRecord( filePath,o )
{
  var self = this;

  if( filePath instanceof _.FileRecord && arguments[ 1 ] === undefined && filePath.fileProvider === self )
  return filePath

  _.assert( _.strIs( filePath ),'expects string ( filePath ), but got',_.strTypeOf( filePath ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  // if( arguments.length === 2 )
  // {
  //   o = arguments[ 1 ];
  //   o.filePath = arguments[ 0 ];
  // }
  //
  // if( _.strIs( o ) )
  // {
  //   o = { filePath : o };
  // }

  if( o === undefined )
  o = Object.create( null );

  if( !( o instanceof _.FileRecordOptions ) )
  o.fileProvider = self;

  _.assert( o.fileProvider === self );

  return _.FileRecord( filePath,o );
}

//

function fileRecords( filePaths,o )
{
  var self = this;

  if( _.strIs( filePaths ) || filePaths instanceof _.FileRecord )
  filePaths = [ filePaths ];

  _.assert( _.arrayIs( filePaths ),'expects array ( filePaths ), but got',_.strTypeOf( filePaths ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var result = [];

  for( var r = 0 ; r < filePaths.length ; r++ )
  result[ r ] = self.fileRecord( filePaths[ r ],o );

  return result;
}

//

function fileRecordsFiltered( filePaths,o )
{
  var self = this;
  var result = self.fileRecords( filePaths,o );

  for( var r = result.length-1 ; r >= 0 ; r-- )
  if( !result[ r ].inclusion )
  result.splice( r,1 );

  return result;
}

//

function pathNativize( filePath )
{
  var self = this;
  _.assert( _.strIs( filePath ) ) ;
  return filePath;
}

var pathsNativize = _.routineInputMultiplicator_functor( 'pathNativize' );

// --
// read act
// --

var fileReadAct = {};
fileReadAct.defaults =
{
  sync : 0,
  filePath : null,
  encoding : 'utf8',
  advanced : null,
}

var fileStatAct = {};
fileStatAct.defaults =
{
  filePath : null,
  sync : 1,
  throwing : 0,
  resolvingSoftLink : 1,
}

var fileHashAct = {};
fileHashAct.defaults =
{
  filePath : null,
  sync : 1,
  throwing : 0
}

var directoryReadAct = {};
directoryReadAct.defaults =
{
  filePath : null,
  sync : 1,
  throwing : 0
}

// --
// read
// --

/**
 * Reads the entire content of a file.
 * Can accepts `filePath` as first parameters and options as second
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
     filePath : 'tmp/json1.json',
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
   fileRead({ filePath : file.absolute, encoding : 'buffer' })

 * @param {Object} o read options
 * @param {string} o.filePath path to read file
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
 * @memberof FileProvider.Abstract
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

function fileRead( o )
{
  var self = this;
  var result = null;
  var o = self._fileOptionsGet.apply( fileRead,arguments );

  if( o.returnRead === undefined )
  o.returnRead = o.sync !== undefined ? o.sync : fileRead.defaults.sync;

  _.mapComplement( o,fileRead.defaults );
  _.assert( !o.returnRead || o.sync,'cant return read for async read' );
  if( o.sync )
  _.assert( o.returnRead,'sync expects ( returnRead == 1 )' );

  var encoder = fileRead.encoders[ o.encoding ];

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,{ transaction : o, encoder : encoder });

    if( !o.onBegin )
    return;

    var r;
    if( o.wrap )
    r = { options : o };
    else
    r = o;

    // debugger;
    wConsequence.give( o.onBegin,r );
  }

  /* end */

  function handleEnd( data )
  {

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,{ data : data, transaction : o, encoder : encoder });

    var r;
    if( o.wrap )
    r = { data : data, options : o };
    else
    r = data;

    if( o.onEnd )
    wConsequence.give( o.onEnd,r );
    // if( !o.sync )
    // wConsequence.give( result,r );

    return r;
  }

  /* error */

  function handleError( err )
  {
    // debugger;

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    if( o.onError )
    wConsequence.error( o.onError,err );

    // debugger; // xxx !!!
    // if( !o.sync )
    // wConsequence.error( result,err );

    if( o.throwing )
    throw _.err( err );

  }

  /* exec */

  handleBegin();

  var optionsRead = _.mapScreen( self.fileReadAct.defaults,o );
  optionsRead.filePath = self.pathNativize( optionsRead.filePath );

  try
  {
    result = self.fileReadAct( optionsRead );
  }
  catch( err )
  {
    if( o.sync )
    result = err;
    else
    result = new wConsequence().error( err );
  }

  /* throwing */

  if( o.sync )
  {
    if( _.errIs( result ) )
    return handleError( result );
    return handleEnd( result );
  }
  else
  {

    result
    .ifNoErrorThen( handleEnd )
    .ifErrorThen( handleError )
    ;

    return result;
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

  filePath : null,
  name : null,
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
 * Can accepts `filePath` as first parameters and options as second
 *
 * @example
 * // content of tmp/json1.json : { "a" : 1, "b" : "s", "c" : [ 1,3,4 ]}
 var fileReadOptions =
 {
   filePath : 'tmp/json1.json',
   encoding : 'json',

   onEnd : function( err, result )
   {
     console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
   }
 };

 var res = wTools.fileReadSync( fileReadOptions );
 // { a : 1, b : 's', c : [ 1, 3, 4 ] }

 * @param {Object} o read options
 * @param {string} o.filePath path to read file
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

function fileReadSync()
{
  var self = this;
  var o = self._fileOptionsGet.apply( fileReadSync,arguments );

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
fileReadSync.isOriginalReader = 0;

//

/**
 * Reads a JSON file and then parses it into an object.
 *
 * @example
 * // content of tmp/json1.json : {"a" :1,"b" :"s","c" :[1,3,4]}
 *
 * var res = wTools.fileReadJson( 'tmp/json1.json' );
 * // { a : 1, b : 's', c : [ 1, 3, 4 ] }
 * @param {string} filePath file path
 * @returns {*}
 * @throws {Error} If missed arguments, or passed more then one argument.
 * @method fileReadJson
 * @memberof wTools
 */

function fileReadJson( o )
{
  var self = this;
  var result = null;

  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1 );
  _.routineOptions( fileReadJson,o );

  o.filePath = _.pathGet( o.filePath );

  _.assert( arguments.length === 1 );

  if( self.fileStat( o.filePath ) )
  {

    try
    {
      var str = self.fileRead( o );
      result = JSON.parse( str );
    }
    catch( err )
    {
      throw _.err( 'cant read json from',o.filePath,'\n',err );
    }

  }

  return result;
}

fileReadJson.defaults =
{
  encoding : 'utf8',
  sync : 1,
  returnRead : 1,
}

fileReadJson.defaults.__proto__ = fileRead.defaults;

//

function filesRead( o )
{
  // logger.log( 'filesRead : ' + _.strTypeOf( this ) );
  // options

  var self = this;

  if( _.arrayIs( o ) )
  o = { paths : o };

  _.routineOptions( filesRead,o );
  _.assert( arguments.length === 1 );
  _.assert( _.arrayIs( o.paths ) || _.objectIs( o.paths ) || _.strIs( o.paths ) );

  if( _.objectIs( o.paths ) )
  {
    var _paths = [];
    for( var p in o.paths )
    _paths.push({ filePath : o.paths[ p ], name : p });
    o.paths = _paths;
  }

  function _filesReadEnd( errs, result )
  {
    var err;
    if( errs.length )
    {
      debugger;
      err = _.errLog.apply( _,errs );
      debugger;
    }

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

    return { result : r, err : err };

  }

  //

  function _fileReadOptions( filePath )
  {
    // var filePath = o.paths[ p ];
    var readOptions = _.mapScreen( self.fileRead.defaults,o );
    readOptions.onEnd = o.onEach;
    if( _.objectIs( filePath ) )
    _.mapExtend( readOptions,filePath );
    else
    readOptions.filePath = filePath;

    if( o.sync )
    readOptions.returnRead = true;

    return readOptions;
  }

  o._filesReadEnd = _filesReadEnd;
  o._fileReadOptions = _fileReadOptions;

  //

  o.paths = _.arrayAs( o.paths );

  if( o.sync )
  {
    return self._filesReadSync( o );
  }
  else
  {
    return self._filesReadAsync( o );
  }

}

filesRead.defaults =
{

  paths : null,
  onEach : null,

  map : '',
  sync : 1,

}

filesRead.defaults.__proto__ = fileRead.defaults;

filesRead.isOriginalReader = 0;

//

function _filesReadSync( o )
{
  var self = this;

  _.assert( !o.onProgress,'not implemented' );

  var result = [];
  var errs = [];

  var _filesReadEnd = o._filesReadEnd;
  delete o._filesReadEnd;

  var _fileReadOptions = o._fileReadOptions;
  delete o._fileReadOptions;

  var onBegin = o.onBegin;
  var onEnd = o.onEnd;
  var onProgress = o.onProgress;

  delete o.onBegin;
  delete o.onEnd;
  delete o.onProgress;


  // begin

  if( onBegin )
  onBegin({ options : o });

  // exec

  for( var p = 0 ; p < o.paths.length ; p++ )
  {
    var readOptions = _fileReadOptions( o.paths[ p ] );

    var read;

    try
    {
      read = self.fileRead( readOptions );
      result[ p ] = read;
    }
    catch( err )
    {
      if( err || read === undefined )
      {
        errs[ p ] = _.err( 'Cant read : ' + _.toStr( readOptions.filePath ) + '\n', ( err || 'unknown reason' ) );
      }
    }
  }

  // end

  var resultEnd = _filesReadEnd( errs, result );

  var r = resultEnd.result;
  var err = resultEnd.err;

  if( onEnd )
  onEnd( err, r );

  //

  return r;
}

//

function _filesReadAsync( o )
{
  var self = this;
  var con = new wConsequence();

  /*
    _.assert( !o.onBegin,'not implemented' );
    _.assert( !o.onEnd,'not implemented' );
  */
  _.assert( !o.onProgress,'not implemented' );

  var result = [];
  var errs = [];

  var _filesReadEnd = o._filesReadEnd;
  delete o._filesReadEnd;

  var _fileReadOptions = o._fileReadOptions;
  delete o._filesReadEnd;

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

    var readOptions = _fileReadOptions( o.paths[ p ] );

    wConsequence.from( self.fileRead( readOptions ) ).got( function filesReadFileEnd( err,read )
    {

      if( err || read === undefined )
      {
        errs[ p ] = _.err( 'Cant read : ' + _.toStr( readOptions.filePath ) + '\n', ( err || 'unknown reason' ) );
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

    var resultEnd = _filesReadEnd( errs, result );

    var r = resultEnd.result;
    var err = resultEnd.err;

    if( onEnd )
    wConsequence.give( onEnd,err,r );
    con.give( err,r );
  });

  //

  return con;
}

//

function fileHash( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  o.filePath = self.pathNativize( o.filePath );

  _.routineOptions( fileHash,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  if( o.verbosity )
  logger.log( 'fileHash :',o.filePath );

  delete o.verbosity;
  return self.fileHashAct( o );
}

fileHash.defaults =
{
  verbosity : 1,
}

fileHash.defaults.__proto__ = fileHashAct.defaults;

//

function filesFingerprints( files )
{
  var self = this;

  if( _.strIs( files ) || files instanceof _.FileRecord )
  files = [ files ];

  _.assert( _.arrayIs( files ) || _.mapIs( files ) );

  var result = Object.create( null );

  for( var f = 0 ; f < files.length ; f++ )
  {
    var record = self.fileRecord( files[ f ] );
    var fingerprint = Object.create( null );

    if( !record.inclusion )
    continue;

    fingerprint.size = record.stat.size;
    fingerprint.hash = record.hashGet();

    result[ record.relative ] = fingerprint;
  }

  return result;
}

//

/**
 * Check if two paths, file stats or FileRecords are associated with the same file or files with same content.
 * @example
 * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     usingTime = true,
     buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { filePath : path2, data : buffer } );

     var sameWithoutTime = wTools.filesSame( path1, path2 ); // true

     var sameWithTime = wTools.filesSame( path1, path2, usingTime ); // false
   }, 100);
 * @param {string|wFileRecord} ins1 first file to compare
 * @param {string|wFileRecord} ins2 second file to compare
 * @param {boolean} usingTime if this argument sets to true method will additionally check modified time of files, and
    if they are different, method returns false.
 * @returns {boolean}
 * @method filesSame
 * @memberof wTools
 */

function filesSame( o )
{
  var self = this;

  if( arguments.length === 2 || arguments.length === 3 )
  {
    o =
    {
      ins1 : arguments[ 0 ],
      ins2 : arguments[ 1 ],
      usingTime : arguments[ 2 ],
    }
  }

  _.assert( arguments.length === 1 || arguments.length === 2 || arguments.length === 3 );
  _.assertMapHasOnly( o,filesSame.defaults );
  _.mapSupplement( o,filesSame.defaults );

  //debugger;

  o.ins1 = self.fileRecord( o.ins1 );
  o.ins2 = self.fileRecord( o.ins2 );

  /**/

/*
  if( o.ins1.absolute.indexOf( 'x/x.s' ) !== -1 )
  {
    logger.log( '? filesSame : ' + o.ins1.absolute );
    //debugger;
  }
*/

  /**/

  if( o.ins1.stat.isDirectory() )
  throw _.err( o.ins1.absolute,'is directory' );

  if( o.ins2.stat.isDirectory() )
  throw _.err( o.ins2.absolute,'is directory' );

  if( !o.ins1.stat || !o.ins2.stat )
  return false;

  /* symlink */

  if( o.usingSymlink )
  if( o.ins1.stat.isSymbolicLink() || o.ins2.stat.isSymbolicLink() )
  {

    debugger;
    //console.warn( 'filesSame : not tested' );

    return false;
  // return false;

    var target1 = o.ins1.stat.isSymbolicLink() ? File.readlinkSync( o.ins1.absolute ) : o.ins1.absolute;
    var target2 = o.ins2.stat.isSymbolicLink() ? File.readlinkSync( o.ins2.absolute ) : o.ins2.absolute;

    if( target2 === target1 )
    return true;

    o.ins1 = self.fileRecord( target1 );
    o.ins2 = self.fileRecord( target2 );

  }

  /* hard linked */

  _.assert( !( o.ins1.stat.ino < -1 ) );
  if( o.ins1.stat.ino > 0 )
  if( o.ins1.stat.ino === o.ins2.stat.ino )
  return true;

  /* false for empty files */

  if( !o.ins1.stat.size || !o.ins2.stat.size )
  return false;

  /* size */

  if( o.ins1.stat.size !== o.ins2.stat.size )
  return false;

  /* hash */

  if( o.usingHash )
  {

    // logger.log( 'o.ins1 :',o.ins1 );

    if( o.ins1.hash === undefined || o.ins1.hash === null )
    o.ins1.hash = self.fileHash( o.ins1.absolute );
    if( o.ins2.hash === undefined || o.ins2.hash === null )
    o.ins2.hash = self.fileHash( o.ins2.absolute );

    if( ( _.numberIs( o.ins1.hash ) && isNaN( o.ins1.hash ) ) || ( _.numberIs( o.ins2.hash ) && isNaN( o.ins2.hash ) ) )
    return o.uncertainty;

    return o.ins1.hash === o.ins2.hash;
  }
  else
  {
    debugger;
    return o.uncertainty;
  }

}

filesSame.defaults =
{
  ins1 : null,
  ins2 : null,
  usingTime : false,
  usingSymlink : false,
  usingHash : true,
  uncertainty : false,
}

//

/**
 * Check if one of paths is hard link to other.
 * @example
   var fs = require('fs');

   var path1 = '/home/tmp/sample/file1',
   path2 = '/home/tmp/sample/file2',
   buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { filePath : path1, data : buffer } );
   fs.symlinkSync( path1, path2 );

   var linked = wTools.filesLinked( path1, path2 ); // true

 * @param {string|wFileRecord} ins1 path string/file record instance
 * @param {string|wFileRecord} ins2 path string/file record instance

 * @returns {boolean}
 * @throws {Error} if missed one of arguments or pass more then 2 arguments.
 * @method filesLinked
 * @memberof wTools
 */

function filesLinked( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o =
    {
      ins1 : self.fileRecord( arguments[ 0 ] ),
      ins2 : self.fileRecord( arguments[ 1 ] ),
    }
  }
  else
  {
    _.assert( arguments.length === 1 );
    _.assertMapHasOnly( o, filesLinked.defaults );
  }

  if( o.ins1.stat.isSymbolicLink() || o.ins2.stat.isSymbolicLink() )
  {

    // !!!

    // +++ check links targets
    // +++ use case needed, solution will go into FileRecord, probably

    return false;
    debugger;
    throw _.err( 'not tested' );

/*
    var target1 = ins1.stat.isSymbolicLink() ? File.readlinkSync( ins1.absolute ) : Path.resolve( ins1.absolute ),
      target2 =  ins2.stat.isSymbolicLink() ? File.readlinkSync( ins2.absolute ) : Path.resolve( ins2.absolute );
    return target2 === target1;
*/

  }

  /* ino comparison reliable test if ino present */
  if( o.ins1.stat.ino !== o.ins2.stat.ino ) return false;

  _.assert( !( o.ins1.stat.ino < -1 ) );

  if( o.ins1.stat.ino > 0 )
  return o.ins1.stat.ino === o.ins2.stat.ino;

  /* try to guess otherwise */
  if( o.ins1.stat.nlink !== o.ins2.stat.nlink ) return false;
  if( o.ins1.stat.mode !== o.ins2.stat.mode ) return false;
  if( o.ins1.stat.mtime.getTime() !== o.ins2.stat.mtime.getTime() ) return false;
  if( o.ins1.stat.ctime.getTime() !== o.ins2.stat.ctime.getTime() ) return false;

  return true;
}

filesLinked.defaults =
{
  ins1 : null,
  ins2 : null,
}

//

function directoryRead( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  o = { filePath : o };

  var optionsRead = _.mapExtend( null,o );
  optionsRead.filePath = self.pathNativize( optionsRead.filePath );

  return self.directoryReadAct( optionsRead );
}

directoryRead.defaults = {};
directoryRead.defaults.__proto__ = directoryReadAct.defaults;

// --
// read stat
// --

function fileStat( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1 );
  // _.routineOptions( fileStat,o );
  _.assert( _.strIs( o.filePath ) );

  var optionsStat = _.mapExtend( Object.create( null ), o );
  optionsStat.filePath = self.pathNativize( optionsStat.filePath );

  // logger.log( 'fileStat' );
  // logger.log( o );

  return self.fileStatAct( optionsStat );
}

fileStat.defaults = {};
fileStat.defaults.__proto__ = fileStatAct.defaults;

//

/**
 * Returns true if file at ( filePath ) is an existing regular terminal file.
 * @example
 * wTools.fileIsTerminal( './existingDir/test.txt' ); // true
 * @param {string} filePath Path string
 * @returns {boolean}
 * @method fileIsTerminal
 * @memberof wTools
 */

function fileIsTerminal( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat( filePath );

  if( !stat )
  return false;

  if( stat.isSymbolicLink() )
  {
    console.log( 'fileIsTerminal',filePath );
    throw _.err( 'not tested' );
    return false;
  }

  return stat.isFile();
}

//

/**
 * Return True if `filePath` is a symbolic link.
 * @param filePath
 * @returns {boolean}
 * @method fileIsSoftLink
 * @memberof wTools
 */

function fileIsSoftLink( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat
  ({
    filePath : filePath,
    resolvingSoftLink : 0
  });

  if( !stat )
  return false;

  return stat.isSymbolicLink();
}

//

/**
 * Returns sum of sizes of files in `paths`.
 * @example
 * var path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   textData2 = 'Aenean non feugiat mauris';

   wTools.fileWrite( { filePath : path1, data : textData1 } );
   wTools.fileWrite( { filePath : path2, data : textData2 } );
   var size = wTools.filesSize( [ path1, path2 ] );
   console.log(size); // 81
 * @param {string|string[]} paths path to file or array of paths
 * @param {Object} [o] additional o
 * @param {Function} [o.onBegin] callback that invokes before calculation size.
 * @param {Function} [o.onEnd] callback.
 * @returns {number} size in bytes
 * @method filesSize
 * @memberof wTools
 */

function filesSize( o )
{
  var self = this;
  var o = o || Object.create( null );

  if( _.strIs( o ) || _.arrayIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1 );

  // throw _.err( 'not tested' );

  var result = 0;
  var o = o || Object.create( null );
  o.filePath = _.arrayAs( o.filePath );

  // if( o.onBegin ) o.onBegin.call( this,null );
  //
  // if( o.onEnd ) throw 'Not implemented';

  for( var p = 0 ; p < o.filePath.length ; p++ )
  {
    var optionsForSize = _.mapExtend( Object.create( null ),o );
    optionsForSize.filePath = o.filePath[ p ];
    result += self.fileSize( optionsForSize );
  }

  return result;
}

//

/**
 * Return file size in bytes. For symbolic links return false. If onEnd callback is defined, method returns instance
    of wConsequence.
 * @example
 * var path = 'tmp/fileSize/data4',
     bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ), // size 4
     bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ); // size 3

   wTools.fileWrite( { filePath : path, data : bufferData1 } );

   var size1 = wTools.fileSize( path );
   console.log(size1); // 4

   var con = wTools.fileSize( {
     filePath : path,
     onEnd : function( size )
     {
       console.log( size ); // 7
     }
   } );

   wTools.fileWrite( { filePath : path, data : bufferData2, append : 1 } );

 * @param {string|Object} o o object or path string
 * @param {string} o.filePath path to file
 * @param {Function} [o.onBegin] callback that invokes before calculation size.
 * @param {Function} o.onEnd this callback invoked in end of current js event loop and accepts file size as
    argument.
 * @returns {number|boolean|wConsequence}
 * @throws {Error} If passed less or more than one argument.
 * @throws {Error} If passed unexpected parameter in o.
 * @throws {Error} If filePath is not string.
 * @method fileSize
 * @memberof wTools
 */

function fileSize( o )
{
  var self = this;
  var o = o || Object.create( null );

  // throw _.err( 'not tested' );

  if( _.strIs( o ) )
  o = { filePath : o };

  _.routineOptions( fileSize,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ),'expects string ( o.filePath ), but got',_.strTypeOf( o.filePath ) );

  if( self.fileIsSoftLink( o.filePath ) )
  {
    throw _.err( 'not tested' );
    return false;
  }

  // synchronization

  // if( o.onEnd ) return _.timeOut( 0, function()
  // {
  //   var onEnd = o.onEnd;
  //   delete o.onEnd;
  //   onEnd.call( this,fileSize.call( this,o ) );
  // });
  //
  // if( o.onBegin ) o.onBegin.call( this,null );

  // var stat = File.statSync( o.filePath );
  var stat = self.fileStat( o );

  return stat.size;
}

fileSize.defaults =
{
  filePath : null,
  // onBegin : null,
  // onEnd : null,
}

fileSize.defaults.__proto__ = fileStat.defaults;

//

/**
 * Return True if file at ( filePath ) is an existing directory.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.directoryIs( './existingDir/' ); // true
 * @param {string} filePath Tested path string
 * @returns {boolean}
 * @method directoryIs
 * @memberof wTools
 */

function directoryIs( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat( filePath );

  if( !stat )
  return false;

  if( stat.isSymbolicLink() )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  return stat.isDirectory();
}

// --
// write act
// --

var fileWriteAct = {};
fileWriteAct.defaults =
{
  filePath : null,
  sync : 1,
  data : '',
  writeMode : 'rewrite',
}

var fileDeleteAct = {};
fileDeleteAct.defaults =
{

  filePath : null,
  sync : 1,

}

var fileTimeSetAct = {};
fileTimeSetAct.defaults =
{

  filePath : null,
  atime : null,
  mtime : null,

}

var directoryMakeAct = {};
directoryMakeAct.defaults =
{
  filePath : null,
  // force : 0,
  // rewritingTerminal : 0,
  sync : 1,
}

// !!! act version should not have advanced options

var fileCopyAct = {};
fileCopyAct.defaults =
{
  pathDst : null,
  pathSrc : null,
  sync : 1,
}

var fileRenameAct = {};
fileRenameAct.defaults =
{
  pathDst : null,
  pathSrc : null,
  sync : 1,
}

var linkSoftAct = {};
linkSoftAct.defaults =
{
  pathDst : null,
  pathSrc : null,
  sync : 1,
}

var linkHardAct = {};
linkHardAct.defaults =
{
  pathDst : null,
  pathSrc : null,
  sync : 1,
}

// --
// write
// --

/**
 * Writes data to a file. `data` can be a string or a buffer. Creating the file if it does not exist yet.
 * Returns wConsequence instance.
 * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
   exist, it's created. Method can accept two parameters : string `filePath` and string\buffer `data`, or single
   argument : options object, with required 'filePath' and 'data' parameters.
 * @example
 *
    var data = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      options =
      {
        filePath : 'tmp/sample.txt',
        data : data,
        sync : false,
      };
    var con = wTools.fileWrite( options );
    con.got( function()
    {
        console.log('write finished');
    });
 * @param {Object} options write options
 * @param {string} options.filePath path to file is written.
 * @param {string|Buffer} [options.data=''] data to write
 * @param {boolean} [options.append=false] if this options sets to true, method appends passed data to existing data
    in a file
 * @param {boolean} [options.sync=true] if this parameter sets to false, method writes file asynchronously.
 * @param {boolean} [options.force=true] if it's set to false, method throws exception if parents dir in `filePath`
    path is not exists
 * @param {boolean} [options.silentError=false] if it's set to true, method will catch error, that occurs during
    file writes.
 * @param {boolean} [options.verbosity=false] if sets to true, method logs write process.
 * @param {boolean} [options.clean=false] if sets to true, method removes file if exists before writing
 * @returns {wConsequence}
 * @throws {Error} If arguments are missed
 * @throws {Error} If passed more then 2 arguments.
 * @throws {Error} If `filePath` argument or options.PathFile is not string.
 * @throws {Error} If `data` argument or options.data is not string or Buffer,
 * @throws {Error} If options has unexpected property.
 * @method fileWriteAct
 * @memberof wTools
 */

function fileWrite( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileWrite,o );
  _.assert( _.strIs( o.filePath ) );

  var optionsWrite = _.mapScreen( self.fileWriteAct.defaults,o );
  optionsWrite.filePath = self.pathNativize( optionsWrite.filePath );

  /* log */

  function log()
  {
    if( o.verbosity )
    logger.log( '+ writing',_.toStr( o.data,{ levels : 0 } ),'to',optionsWrite.filePath );
  }

  log();

  /* makingDirectory */

  if( o.makingDirectory )
  {
    self.directoryMakeForFile( optionsWrite.filePath );
  }

  /* purging */

  if( o.purging )
  {
    self.fileDelete( optionsWrite.filePath );
  }

  var result = self.fileWriteAct( optionsWrite );

  if( !o.sync )
  {
    self.done.got();
    result.doThen( self.done );
    // logger.log( 'self.done',self.done );
    // logger.log( 'self.nickName',self.nickName );
  }

  return result;
}

fileWrite.defaults =
{
  verbosity : 0,
  makingDirectory : 1,
  purging : 0,
}

fileWrite.defaults.__proto__ = fileWriteAct.defaults;

fileWrite.isWriter = 1;

//

function fileAppend( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileAppend,o );

  var optionsWrite = _.mapScreen( self.fileWriteAct.defaults,o );
  optionsWrite.filePath = self.pathNativize( optionsWrite.filePath );

  return self.fileWriteAct( optionsWrite );
}

fileAppend.defaults =
{
  writeMode : 'append',
}

fileAppend.defaults.__proto__ = fileWriteAct.defaults;

fileAppend.isWriter = 1;

//

/**
 * Writes data as json string to a file. `data` can be a any primitive type, object, array, array like. Method can
    accept options similar to fileWrite method, and have similar behavior.
 * Returns wConsequence instance.
 * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
 exist, it's created. Method can accept two parameters : string `filePath` and string\buffer `data`, or single
 argument : options object, with required 'filePath' and 'data' parameters.
 * @example
 * var fileProvider = _.FileProvider.Default();
 * var fs = require('fs');
   var data = { a : 'hello', b : 'world' },
   var con = fileProvider.fileWriteJson( 'tmp/sample.json', data );
   // file content : { "a" : "hello", "b" : "world" }

 * @param {Object} o write options
 * @param {string} o.filePath path to file is written.
 * @param {string|Buffer} [o.data=''] data to write
 * @param {boolean} [o.append=false] if this options sets to true, method appends passed data to existing data
 in a file
 * @param {boolean} [o.sync=true] if this parameter sets to false, method writes file asynchronously.
 * @param {boolean} [o.force=true] if it's set to false, method throws exception if parents dir in `filePath`
 path is not exists
 * @param {boolean} [o.silentError=false] if it's set to true, method will catch error, that occurs during
 file writes.
 * @param {boolean} [o.verbosity=false] if sets to true, method logs write process.
 * @param {boolean} [o.clean=false] if sets to true, method removes file if exists before writing
 * @param {string} [o.pretty=''] determines data stringify method.
 * @returns {wConsequence}
 * @throws {Error} If arguments are missed
 * @throws {Error} If passed more then 2 arguments.
 * @throws {Error} If `filePath` argument or options.PathFile is not string.
 * @throws {Error} If options has unexpected property.
 * @method fileWriteJson
 * @memberof wTools
 */

function fileWriteJson( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileWriteJson,o );


  /* stringify */

  var originalData = o.data;
  // if( _.stringify && o.pretty )
  if( o.js )
  o.data = _.strJsonFrom( o.data );
  // o.data = _.stringify( o.data, null, '  ' );
  else
  o.data = JSON.stringify( o.data );

  /* validate */

  if( Config.debug && o.pretty ) try
  {

    var parsedData = o.js ? _.exec( o.data ) : JSON.parse( o.data );
    _.assert( _.entityEquivalent( parsedData,originalData ),'not identical' );

  }
  catch( err )
  {

    debugger;
    logger.log( '-' );
    logger.error( 'JSON:' );
    logger.error( _.toStr( o.data,{ levels : 999 } ) );
    logger.log( '-' );
    throw _.err( 'Cant convert JSON\n',err );
    logger.log( '-' );

  }

  /* write */

  delete o.pretty;
  delete o.js;
  return self.fileWrite( o );
}

fileWriteJson.defaults =
{
  js : 0,
  pretty : 0,
  sync : 1,
}

fileWriteJson.defaults.__proto__ = fileWrite.defaults;

fileWriteJson.isWriter = 1;

//

// function filesWrite( o )
// {
//   var self = this;
//
//   if( _.strIs( o.filePath ) || o.filePath instanceof _.FileRecord )
//   o.filePath = [ o.filePath ];
//
//   _.routineOptions( filesWrite,o );
//   _.assert( o.sync,'async is not implemented' );
//   _.assert( _.arrayIs( o.filePath ) || _.objectIs( o.filePath ) );
//
//   var result = _.entityMap( o.filePath,function( e,k )
//   {
//
//     var filePath = _.pathGet( e );
//     var optionsForWrite = _.mapExtend( null,o );
//     optionsForWrite.filePath = filePath;
//
//     return self.fileWrite( optionsForWrite );
//   });
//
//   return result;
// }
//
// filesWrite.defaults =
// {
// }
//
// filesWrite.defaults.__proto__ = fileWrite.defaults;

//

function fileTimeSet( o )
{
  var self = this;

  if( arguments.length === 3 )
  o =
  {
    filePath : arguments[ 0 ],
    atime : arguments[ 1 ],
    mtime : arguments[ 2 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileTimeSet,o );
  o.filePath = self.pathNativize( o.filePath );

  return self.fileTimeSetAct( o );
}

fileTimeSet.defaults = {};
fileTimeSet.defaults.__proto__ = fileTimeSetAct.defaults;

//

function fileDelete()
{
  var self = this;

  // optionsWrite.filePath = self.pathNativize( optionsWrite.filePath );

  throw _.err( 'not implemented' );

}

fileDelete.defaults =
{
  force : 1,
}

fileDelete.defaults.__proto__ = fileDeleteAct.defaults;

//

function fileDeleteForce( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var o = _.routineOptions( fileDeleteForce,o );
  _.assert( arguments.length === 1 );

  return self.fileDelete( o );
}

fileDeleteForce.defaults =
{
  force : 1,
  sync : 1,
}

fileDeleteForce.defaults.__proto__ = fileDelete.defaults;

//

function directoryMake( o )
{
  var self = this;

  _.routineOptions( directoryMake,o );

  // debugger;
  if( o.force )
  throw _.err( 'not implemented' );
  // !!! need this, probably

  if( o.rewritingTerminal )
  if( self.fileIsTerminal( o.filePath ) )
  self.fileDelete( o.filePath );

  if( _.strIs( o.filePath ) )
  o.filePath = self.pathNativize( o.filePath );

  return self.directoryMakeAct( o );
}

directoryMake.defaults =
{
  force : 1,
  rewritingTerminal : 1,
}

directoryMake.defaults.__proto__ = directoryMakeAct.defaults;

//

function directoryMakeForFile( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var o = _.routineOptions( directoryMakeForFile,o );
  _.assert( arguments.length === 1 );

  o.filePath = _.pathDir( o.filePath );

  return self.directoryMake( o );
}

directoryMakeForFile.defaults =
{
  force : 1,
}

directoryMakeForFile.defaults.__proto__ = directoryMake.defaults;

//

function _linkBegin( routine,args )
{
  var self = this;
  var o;

  if( args.length === 2 )
  {
    o =
    {
      pathDst : args[ 0 ],
      pathSrc : args[ 1 ],
    }
    _.assert( args.length === 2 );
  }
  else
  {
    o = args[ 0 ];
    _.assert( args.length === 1 );
  }

  _.routineOptions( routine,o );

  o.pathDst = _.pathGet( o.pathDst );
  o.pathSrc = _.pathGet( o.pathSrc );

  // if( o.verbosity )
  // logger.log( routine.name,':', o.pathDst + ' <- ' + o.pathSrc );

  return o;
}

//

function _link_functor( gen )
{

  _.assert( arguments.length === 1 );
  _.routineOptions( _link_functor,gen );

  var nameOfMethod = gen.nameOfMethod;
  var nameOfMethodPure = _.strRemoveEnd( gen.nameOfMethod,'Act' );

  function link( o )
  {

    var self = this;
    var linkAct = self[ nameOfMethod ];

    var o = self._linkBegin( link,arguments );
    var optionsAct = _.mapScreen( linkAct.defaults,o );

    optionsAct.pathDst = self.pathNativize( optionsAct.pathDst );
    optionsAct.pathSrc = self.pathNativize( optionsAct.pathSrc );

    // if( optionsAct.pathSrc.indexOf( 'Config.s' ) !== -1 )
    // debugger;

    if( optionsAct.pathDst === optionsAct.pathSrc )
    {
      if( o.sync )
      return true;
      return new wConsequence().give( true );
    }

    if( !self.fileStat( optionsAct.pathSrc ) )
    {

      if( o.throwing )
      {
        var err = _.err( 'src file does not exist',optionsAct.pathSrc );
        if( o.sync )
        throw err;
        return new wConsequence().error( err );
      }
      else
      {
        if( o.sync )
        return false;
        return new wConsequence().give( false );
      }

    }

    if( nameOfMethod === 'fileCopyAct' )
    if( !self.fileIsTerminal( optionsAct.pathSrc ) )
    {
      var err = _.err( optionsAct.pathSrc,' is not a terminal file!' );
      if( o.sync )
      throw err;
      return new wConsequence().error( err );
    }

    /* */

    function log()
    {
      if( !o.verbosity )
      return;
      var c = _.strCommonLeft( optionsAct.pathDst,optionsAct.pathSrc );
      logger.log( '+',nameOfMethodPure,':',c,':',optionsAct.pathDst.substring( c.length ),'<-',optionsAct.pathSrc.substring( c.length ) );
    }

    /* */

    function tempNameMake()
    {
      return optionsAct.pathDst + '-' + _.idGenerateGuid() + '.tmp';
    }

    /* */

    if( o.sync )
    {

      var temp;
      try
      {
        if( self.fileStatAct( optionsAct.pathDst ) )
        {
          if( !o.rewriting )
          throw _.err( 'dst file exist and rewriting is forbidden :',optionsAct.pathDst );
          temp = tempNameMake();
          if( self.fileStatAct( temp ) )
          {
            temp = null;
            self.fileDelete( optionsAct.pathDst );
          }
          if( temp )
          self.fileRenameAct({ pathDst : temp, pathSrc : optionsAct.pathDst, sync : 1 });
        }
        linkAct.call( self,optionsAct );
        log();
        if( temp )
        self.fileDelete( temp );
      }
      catch( err )
      {
        if( temp ) try
        {
          self.fileRenameAct({ pathDst : optionsAct.pathDst, pathSrc : temp, sync : 1 });
        }
        catch( err2 )
        {
        }
        if( o.throwing )
        throw _.err( 'cant',nameOfMethod,optionsAct.pathDst,'<-',optionsAct.pathSrc,'\n',err )
        return false;
      }

      return true;
    }
    else
    {

      // debugger;
      // throw _.err( 'not tested' );

      var temp = '';
      var dstExists,tempExists;

      return self.fileStatAct({ filePath : optionsAct.pathDst, sync : 0 })
      .ifNoErrorThen( function( exists )
      {

        dstExists = exists;
        if( dstExists )
        {
          if( !o.rewriting )
          throw _.err( 'dst file exist and rewriting is forbidden :',optionsAct.pathDst );
          // throw _.err( 'not tested' );
          return self.fileStatAct({ filePath : temp, sync : 0 });
        }

      })
      .ifNoErrorThen( function( exists )
      {

        if( !dstExists )
        return;

        tempExists = exists;
        if( !tempExists )
        {
          temp = tempNameMake();
          return self.fileRenameAct({ pathDst : temp, pathSrc : optionsAct.pathDst, sync : 0 });
        }
        else
        {
          return self.fileDelete({ filePath : optionsAct.pathDst , sync : 0 });
        }

      })
      .ifNoErrorThen( function()
      {

        log();

        return linkAct.call( self,optionsAct );

      })
      .ifNoErrorThen( function()
      {

        if( temp )
        return self.fileDelete({ filePath : temp, sync : 0 });

      })
      .doThen( function( err )
      {

        if( err )
        {
          var con = new wConsequence().give();
          if( temp )
          {
            con.doThen( _.routineSeal( self,self.fileRenameAct,
            [{
              pathDst : optionsAct.pathDst,
              pathSrc : temp,
              sync : 0,
              verbosity : 0,
            }]));
          }

          return con.doThen( function()
          {
            if( o.throwing )
            throw _.errLogOnce( err );
            return false;
          });
        }

        return true;
      })
      ;

    }

  }

  return link;
}

_link_functor.defaults =
{
  nameOfMethod : null,
}

//

var fileRename = _link_functor({ nameOfMethod : 'fileRenameAct' });

fileRename.defaults =
{
  rewriting : 0,
  throwing : 1,
  verbosity : 1,
}

fileRename.defaults.__proto__ = fileRenameAct.defaults;

//

/**
 * Creates copy of a file. Accepts two arguments: ( pathSrc ),( pathDst ) or options object.
 * Returns true if operation is finished successfully or if source and destination pathes are equal.
 * Otherwise throws error with corresponding message or returns false, it depends on ( o.throwing ) property.
 * In asynchronously mode returns wConsequence instance.
 * @example
   var fileProvider = _.FileProvider.Default();
   var result = fileProvider.fileCopy( 'src.txt','dst.txt' );
   console.log( result );// true
   var stats = fileProvider.fileStat( 'dst.txt' );
   console.log( stats ); // returns Stats object
 * @example
   var fileProvider = _.FileProvider.Default();
   var consequence = fileProvider.fileCopy
   ({
     pathSrc : 'src.txt',
     pathDst : 'dst.txt',
     sync : 0
   });
   consequence.got( function( err, got )
   {
     if( err )
     throw err;
     console.log( got ); // true
     var stats = fileProvider.fileStat( 'dst.txt' );
     console.log( stats ); // returns Stats object
   });

 * @param {Object} o - options object.
 * @param {string} o.pathSrc path to source file.
 * @param {string} o.pathDst path where to copy source file.
 * @param {boolean} [o.sync=true] If set to false, method will copy file asynchronously.
 * @param {boolean} [o.rewriting=true] Enables rewriting of destination path if it exists.
 * @param {boolean} [o.throwing=true] Enables error throwing.
 * @param {boolean} [o.verbosity=true] Enables logging of copy process.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 2.
 * @throws {Error} If pathDst or pathDst is not string.
 * @throws {Error} If options object has unexpected property.
 * @throws {Error} If ( o.rewriting ) is false and destination path exists.
 * @throws {Error} If path to source file( pathSrc ) not exists and ( o.throwing ) is enabled, otherwise returns false.
 * @method fileCopy
 * @memberof wTools
 */

var fileCopy = _link_functor({ nameOfMethod : 'fileCopyAct' });

fileCopy.defaults =
{
  rewriting : 1,
  throwing : 1,
  verbosity : 1,
}

fileCopy.defaults.__proto__ = fileCopyAct.defaults;

//

/**
 * link methods options
 * @typedef { object } wTools~linkOptions
 * @property { boolean } [ pathDst= ] - Target file.
 * @property { boolean } [ pathSrc= ] - Source file.
 * @property { boolean } [ o.sync=true ] - Runs method in synchronously. Otherwise asynchronously and returns wConsequence object.
 * @property { boolean } [ rewriting=true ] - Rewrites target( o.pathDst ).
 * @property { boolean } [ verbosity=true ] - Logs working process.
 * @property { boolean } [ throwing=true ]- Enables error throwing. Otherwise returns true/false.
 */

/**
 * Creates soft link( symbolic ) to existing source( o.pathSrc ) named as ( o.pathDst ).
 * Rewrites target( o.pathDst ) by default if it exist. Logging of working process is controled by option( o.verbosity ).
 * Returns true if link is successfully created. If some error occurs during execution method uses option( o.throwing ) to
 * determine what to do - throw error or return false.
 *
 * @param { wTools~linkOptions } o - options { @link wTools~linkOptions  }
 *
 * @method linkSoft
 * @throws { exception } If( o.pathSrc ) doesn`t exist.
 * @throws { exception } If cant link ( o.pathSrc ) with ( o.pathDst ).
 * @memberof wTools
 */

var linkSoft = _link_functor({ nameOfMethod : 'linkSoftAct' });

linkSoft.defaults =
{
  rewriting : 1,
  verbosity : 1,
  throwing : 1,
}

linkSoft.defaults.__proto__ = linkSoftAct.defaults;

//

/**
 * Creates hard link( new name ) to existing source( o.pathSrc ) named as ( o.pathDst ).
 * Rewrites target( o.pathDst ) by default if it exist. Logging of working process is controled by option( o.verbosity ).
 * Returns true if link is successfully created. If some error occurs during execution method uses option( o.throwing ) to
 * determine what to do - throw error or return false.
 *
 * @param { wTools~linkOptions } o - options { @link wTools~linkOptions  }
 *
 * @method linkSoft
 * @throws { exception } If( o.pathSrc ) doesn`t exist.
 * @throws { exception } If cant link ( o.pathSrc ) with ( o.pathDst ).
 * @memberof wTools
 */

var linkHard = _link_functor({ nameOfMethod : 'linkHardAct' });

linkHard.defaults =
{
  rewriting : 1,
  verbosity : 1,
  throwing : 1,
}

linkHard.defaults.__proto__ = linkHardAct.defaults;

//

function fileExchange( o )
{
  var self  = this;

  _.assert( arguments.length === 1 || arguments.length === 2 )

  if( arguments.length === 2 )
  {
    _.assert( _.strIs( arguments[ 0 ] ) && _.strIs( arguments[ 1 ] ) );
    o = { pathDst : arguments[ 0 ], pathSrc : arguments[ 1 ] };
  }

  _.routineOptions( fileExchange,o );

  var pathDst = o.pathDst;
  var pathSrc = o.pathSrc;

  var allowMissing = o.allowMissing;
  delete o.allowMissing;

  var src = self.fileStat({ filePath : o.pathSrc, throwing : 0 });
  var dst = self.fileStat({ filePath : o.pathDst, throwing : 0 });

  function _returnNull()
  {
    if( o.sync )
    return null;
    else
    return new wConsequence().give( null );
  }

  if( !src || !dst )
  {
    if( allowMissing )
    {
      if( !src && dst )
      {
        o.pathSrc = o.pathDst;
        o.pathDst = pathSrc;
      }
      if( !src && !dst )
      return _returnNull();

      return self.fileRename( o );
    }
    else if( o.throwing )
    {
      var err;

      if( !src && !dst )
      {
        err = _.err( 'pathSrc and pathDst not exist! pathSrc: ', o.pathSrc, ' pathDst: ', o.pathDst )
      }
      else if( !src )
      {
        err = _.err( 'pathSrc not exist! pathSrc: ', o.pathSrc );
      }
      else
      {
        err = _.err( 'pathDst not exist! pathDst: ', o.pathDst );
      }

      if( o.sync )
      throw err;
      else
      return new wConsequence().error( err );
    }
    else
    return _returnNull();
  }

  var temp = o.pathSrc + '-' + _.idGenerateGuid() + '.tmp';

  o.pathDst = temp;

  if( o.sync )
  {
    self.fileRename( o );
    o.pathDst = o.pathSrc;
    o.pathSrc = pathDst;
    self.fileRename( o );
    o.pathDst = pathDst;
    o.pathSrc = temp;
    return self.fileRename( o );
  }
  else
  {
    var con = new wConsequence().give();

    con.ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) )
    .ifNoErrorThen( function()
    {
      o.pathDst = o.pathSrc;
      o.pathSrc = pathDst;
    })
    .ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) )
    .ifNoErrorThen( function()
    {
      o.pathDst = pathDst;
      o.pathSrc = temp;
    })
    .ifNoErrorThen( _.routineSeal( self, self.fileRename, [ o ] ) );

    return con;
  }
}

fileExchange.defaults =
{
  pathSrc : null,
  pathDst : null,
  sync : 1,
  allowMissing : 1,
  throwing : 1,
  verbosity : 1
}

// --
// encoders
// --

var encoders = {};

encoders[ 'json' ] =
{

  onBegin : function( e )
  {
    _.assert( e.transaction.encoding === 'json' );
    e.transaction.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( '( fileRead.encoders.json.onEnd ) expects string' );
    var result = JSON.parse( e.data );
    return result;
  },

}

encoders[ 'js' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( '( fileRead.encoders.js.onEnd ) expects string' );
    var result = _.exec( e.data );
    return result;
  },

}

fileRead.encoders = encoders;

// --
// relationship
// --

var Composes =
{
  done : new wConsequence().give(),
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

var Statics =
{
  verbosity : 0,
  WriteMode : WriteMode,
}

// --
// prototype
// --

var Proto =
{

  init : init,


  // etc

  _fileOptionsGet : _fileOptionsGet,
  fileRecord : fileRecord,
  fileRecords : fileRecords,
  fileRecordsFiltered : fileRecordsFiltered,
  pathNativize : pathNativize,
  pathsNativize : pathsNativize,


  // read act

  fileReadAct : fileReadAct,
  fileStatAct : fileStatAct,
  fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,


  // read

  fileRead : fileRead,
  fileReadSync : fileReadSync,
  fileReadJson : fileReadJson,

  filesRead : filesRead,
  _filesReadAsync : _filesReadAsync,
  _filesReadSync : _filesReadSync,

  fileHash : fileHash,
  filesFingerprints : filesFingerprints,

  filesSame : filesSame,
  filesLinked : filesLinked,

  directoryRead : directoryRead,


  // read stat

  fileStat : fileStat,
  fileIsTerminal : fileIsTerminal,
  fileIsSoftLink : fileIsSoftLink,

  filesSize : filesSize,
  fileSize : fileSize,

  directoryIs : directoryIs,


  // write act

  fileWriteAct : fileWriteAct,
  fileTimeSetAct : fileTimeSetAct,
  fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,

  fileRenameAct : fileRenameAct,
  fileCopyAct : fileCopyAct,
  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,


  // write

  fileWrite : fileWrite,
  fileAppend : fileAppend,
  fileWriteJson : fileWriteJson,

  fileTimeSet : fileTimeSet,

  fileDelete : fileDelete,
  fileDeleteForce : fileDeleteForce,

  directoryMake : directoryMake,
  directoryMakeForFile : directoryMakeForFile,

  _linkBegin : _linkBegin,
  _link_functor : _link_functor,

  fileRename : fileRename,
  fileCopy : fileCopy,
  linkSoft : linkSoft,
  linkHard : linkHard,

  fileExchange : fileExchange,


  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.protoMake
({
  cls : Self,
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
