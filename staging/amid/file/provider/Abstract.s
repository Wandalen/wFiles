( function _FileProviderAbstract_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

}

if( wTools.FileProvider && wTools.FileProvider.Abstract )
return;

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
var FileRecord = _global_.wFileRecord;
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

  _.instanceInit( self );

  if( o )
  self.copy( o );

  if( self.usingLogging )
  logger.log( 'new',_.strTypeOf( self ) );
  //logger.log( _.diagnosticStack() );

}

//

/**
 * Return options for file red/write. If `pathFile is an object, method returns it. Method validate result option
    properties by default parameters from invocation context.
 * @param {string|Object} pathFile
 * @param {Object} [o] Object with default options parameters
 * @returns {Object} Result options
 * @private
 * @throws {Error} If arguments is missed
 * @throws {Error} If passed extra arguments
 * @throws {Error} If missed `PathFiile`
 * @method _fileOptionsGet
 * @memberof FileProvider.Abstract
 */

var _fileOptionsGet = function( pathFile,o )
{
  var self = this;
  var o = o || {};

  if( _.objectIs( pathFile ) )
  {
    o = pathFile;
  }
  else
  {
    o.pathFile = pathFile;
  }

  if( !o.pathFile )
  throw _.err( '_fileOptionsGet :','"o.pathFile" is required' );

  _.assertMapHasOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

//

var fileRecord = function fileRecord( o )
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( arguments.length === 2 )
  {
    o = arguments[ 1 ];
    o.pathFile = arguments[ 0 ];
  }

  if( _.strIs( o ) )
  {
    o = { pathFile : o };
  }

  if( !o.fileProvider )
  o.fileProvider = self;

  return FileRecord( o );
}

// --
// read act
// --

var fileReadAct = {};
fileReadAct.defaults =
{
  sync : 0,
  pathFile : null,
  encoding : 'utf8',
  advanced : null,
}

var fileStatAct = {};
fileStatAct.defaults =
{
  pathFile : null,
  sync : 1,
  throwing : 0
}

var fileHashAct = {};
fileHashAct.defaults =
{
  pathFile : null,
  sync : 1,
  throwing : 0
}

var directoryReadAct = {};
directoryReadAct.defaults =
{
  pathFile : null,
  sync : 1,
  throwing : 0
}

// --
// read
// --

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

var fileRead = function( o )
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

  var handleBegin = function()
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

    debugger;
    wConsequence.give( o.onBegin,r );
  }

  /* end */

  var handleEnd = function( data )
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
    if( !o.sync )
    wConsequence.give( result,r );

    return result;
  }

  /* error */

  var handleError = function( err )
  {
    debugger;

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    if( o.onEnd )
    wConsequence.error( o.onEnd,err );
    if( !o.sync )
    wConsequence.error( result,err );

    if( o.throwing )
    throw _.err( err );

  }

  /* exec */

  handleBegin();

  var optionsRead = _.mapScreen( self.fileReadAct.defaults,o );

  if( o.throwing )
  {

    result = self.fileReadAct( optionsRead );

  }
  else try
  {

    result = self.fileReadAct( optionsRead );

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
    return handleEnd( result );
  }
  else
  {

    result
    .ifErrorThen( handleError )
    .ifNoErrorThen( handleEnd )
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

  pathFile : null,
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
 * @param {string} pathFile file path
 * @returns {*}
 * @throws {Error} If missed arguments, or passed more then one argument.
 * @method fileReadJson
 * @memberof wTools
 */

var fileReadJson = function( o )
{
  var self = this;
  var result = null;

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( arguments.length === 1 );
  _.routineOptions( fileReadJson,o );

  o.pathFile = _.pathGet( o.pathFile );

  _.assert( arguments.length === 1 ); //debugger; xxx

  //if( File.existsSync( o.pathFile ) )
  if( self.fileStat( o.pathFile ) )
  {

    try
    {
      var str = self.fileRead( o );
      result = JSON.parse( str );
    }
    catch( err )
    {
      throw _.err( 'cant read json from',o.pathFile,'\n',err );
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

  // sync : 1,
  // wrap : 0,
  // returnRead : 0,
  // silent : 0,
  //
  // pathFile : null,
  // name : null,
  // encoding : 'utf8',
  //
  // onBegin : null,
  // onEnd : null,
  // onError : null,
  //
  // advanced : null,

}

filesRead.defaults.__proto__ = fileRead.defaults;

filesRead.isOriginalReader = 0;

//

var fileHash = function fileHash( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.routineOptions( fileHash,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

  if( o.usingLogging )
  logger.log( 'fileHash :',o.pathFile );

  delete o.usingLogging;
  return self.fileHashAct( o );
}

fileHash.defaults =
{
  usingLogging : 1,
}

fileHash.defaults.__proto__ = fileHashAct.defaults;

//

/**
 * Check if two paths, file stats or FileRecords are associated with the same file or files with same content.
 * @example
 * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     usingTime = true,
     buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { pathFile : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { pathFile : path2, data : buffer } );

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

var filesSame = function filesSame( o )
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

  o.ins1 = FileRecord( o.ins1 );
  o.ins2 = FileRecord( o.ins2 );

  /**/

/*
  if( o.ins1.absolute.indexOf( 'agent/Deck.s' ) !== -1 )
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

    o.ins1 = FileRecord( target1 );
    o.ins2 = FileRecord( target2 );

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

   wTools.fileWrite( { pathFile : path1, data : buffer } );
   fs.symlinkSync( path1, path2 );

   var linked = wTools.filesLinked( path1, path2 ); // true

 * @param {string|wFileRecord} ins1 path string/file record instance
 * @param {string|wFileRecord} ins2 path string/file record instance

 * @returns {boolean}
 * @throws {Error} if missed one of arguments or pass more then 2 arguments.
 * @method filesLinked
 * @memberof wTools
 */

var filesLinked = function( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o =
    {
      ins1 : FileRecord( arguments[ 0 ] ),
      ins2 : FileRecord( arguments[ 1 ] )
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

var directoryRead = function( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  return self.directoryReadAct( o );
}

// --
// read stat
// --

var fileStat = function( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );

  return self.fileStatAct( filePath );
}

//

/**
 * Returns true if file at ( pathFile ) is an existing regular terminal file.
 * @example
 * wTools.fileIsTerminal( './existingDir/test.txt' ); // true
 * @param {string} pathFile Path string
 * @returns {boolean}
 * @method fileIsTerminal
 * @memberof wTools
 */

var fileIsTerminal = function( pathFile )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat( pathFile );

  if( !stat )
  return false;

  if( stat.isSymbolicLink() )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  return stat.isFile();
}

//

/**
 * Return True if `pathFile` is a symbolic link.
 * @param pathFile
 * @returns {boolean}
 * @method fileIsSoftLink
 * @memberof wTools
 */

var fileIsSoftLink = function( pathFile )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat( pathFile );

  if( !stat )
  return false;

  return stat.isSymbolicLink();
}

//

/**
 * Return True if file at ( pathFile ) is an existing directory.
 * If file is symbolic link to file or directory return false.
 * @example
 * wTools.directoryIs( './existingDir/' ); // true
 * @param {string} pathFile Tested path string
 * @returns {boolean}
 * @method directoryIs
 * @memberof wTools
 */

var directoryIs = function( pathFile )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat( pathFile );

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
  pathFile : null,
  sync : 1,
  data : '',
  writeMode : 'rewrite',
}

var fileDeleteAct = {};
fileDeleteAct.defaults =
{

  pathFile : null,
  sync : 1,

}

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
  pathFile : null,
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
   exist, it's created. Method can accept two parameters : string `pathFile` and string\buffer `data`, or single
   argument : options object, with required 'pathFile' and 'data' parameters.
 * @example
 *
    var data = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      options =
      {
        pathFile : 'tmp/sample.txt',
        data : data,
        sync : false,
      };
    var con = wTools.fileWrite( options );
    con.got( function()
    {
        console.log('write finished');
    });
 * @param {Object} options write options
 * @param {string} options.pathFile path to file is written.
 * @param {string|Buffer} [options.data=''] data to write
 * @param {boolean} [options.append=false] if this options sets to true, method appends passed data to existing data
    in a file
 * @param {boolean} [options.sync=true] if this parameter sets to false, method writes file asynchronously.
 * @param {boolean} [options.force=true] if it's set to false, method throws exception if parents dir in `pathFile`
    path is not exists
 * @param {boolean} [options.silentError=false] if it's set to true, method will catch error, that occurs during
    file writes.
 * @param {boolean} [options.usingLogging=false] if sets to true, method logs write process.
 * @param {boolean} [options.clean=false] if sets to true, method removes file if exists before writing
 * @returns {wConsequence}
 * @throws {Error} If arguments are missed
 * @throws {Error} If passed more then 2 arguments.
 * @throws {Error} If `pathFile` argument or options.PathFile is not string.
 * @throws {Error} If `data` argument or options.data is not string or Buffer,
 * @throws {Error} If options has unexpected property.
 * @method fileWriteAct
 * @memberof wTools
 */

var fileWrite = function( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { pathFile : arguments[ 0 ], data : arguments[ 1 ] };
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileWrite,o );
  _.assert( _.strIs( o.pathFile ) );

  /* log */

  var log = function()
  {
    if( o.usingLogging )
    logger.log( '+ writing',_.toStr( o.data,{ levels : 0 } ),'to',o.pathFile );
  }

  log();

  /* makingDirectory */

  if( o.makingDirectory )
  {

    self.directoryMakeForFile( o.pathFile );
    // var pathFile = _.pathDir( o.pathFile );
    // if( !File.existsSync( pathFile ) )
    // File.mkdirsSync( pathFile );

  }

  /* purging */

  if( o.purging )
  {
    self.fileDelete( o.pathFile );
  }

  var optionsWrite = _.mapScreen( self.fileWriteAct.defaults,o );
  var result = self.fileWriteAct( optionsWrite );

  return result;
}

fileWrite.defaults =
{
  //silentError : 0,
  usingLogging : 0,
  makingDirectory : 1,
  purging : 0,
}

fileWrite.defaults.__proto__ = fileWriteAct.defaults;

fileWrite.isWriter = 1;

//

var fileAppend = function( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { pathFile : arguments[ 0 ], data : arguments[ 1 ] };
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileAppend,o );

  return self.fileWriteAct( o );
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
 exist, it's created. Method can accept two parameters : string `pathFile` and string\buffer `data`, or single
 argument : options object, with required 'pathFile' and 'data' parameters.
 * @example
 * var fileProvider = _.FileProvider.Default();
 * var fs = require('fs');
   var data = { a : 'hello', b : 'world' },
   var con = fileProvider.fileWriteJson( 'tmp/sample.json', data );
   // file content : { "a" : "hello", "b" : "world" }

 * @param {Object} o write options
 * @param {string} o.pathFile path to file is written.
 * @param {string|Buffer} [o.data=''] data to write
 * @param {boolean} [o.append=false] if this options sets to true, method appends passed data to existing data
 in a file
 * @param {boolean} [o.sync=true] if this parameter sets to false, method writes file asynchronously.
 * @param {boolean} [o.force=true] if it's set to false, method throws exception if parents dir in `pathFile`
 path is not exists
 * @param {boolean} [o.silentError=false] if it's set to true, method will catch error, that occurs during
 file writes.
 * @param {boolean} [o.usingLogging=false] if sets to true, method logs write process.
 * @param {boolean} [o.clean=false] if sets to true, method removes file if exists before writing
 * @param {string} [o.pretty=''] determines data stringify method.
 * @returns {wConsequence}
 * @throws {Error} If arguments are missed
 * @throws {Error} If passed more then 2 arguments.
 * @throws {Error} If `pathFile` argument or options.PathFile is not string.
 * @throws {Error} If options has unexpected property.
 * @method fileWriteJson
 * @memberof wTools
 */

var fileWriteJson = function fileWriteJson( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { pathFile : arguments[ 0 ], data : arguments[ 1 ] };
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileWriteJson,o );


  /* stringify */

  if( _.stringify && o.pretty )
  o.data = _.stringify( o.data, null, '  ' );
  else
  o.data = JSON.stringify( o.data );

  /* validate */

  if( Config.debug && o.pretty ) try
  {

    JSON.parse( o.data );

  }
  catch( err )
  {

    debugger;
    logger.error( 'JSON:' );
    logger.error( o.data );
    throw _.err( 'Cant parse',err );

  }

  /* write */

  delete o.pretty;
  return self.fileWrite( o );
}

fileWriteJson.defaults =
{
  pretty : 0,
  sync : 1,
}

fileWriteJson.defaults.__proto__ = fileWrite.defaults;

fileWriteJson.isWriter = 1;

//

var fileDelete = function()
{
  var self = this;

  throw _.err( 'not implemented' );

}

fileDelete.defaults =
{
  force : 1,
}

fileDelete.defaults.__proto__ = fileDeleteAct.defaults;

//

var fileDeleteForce = function fileDeleteForce( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { pathFile : o };

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

var directoryMake = function directoryMake( o )
{
  var self = this;

  _.routineOptions( directoryMake,o );

  debugger;
  if( o.force )
  throw _.err( 'not implemented' );

  if( o.rewritingTerminal )
  if( self.fileIsTerminal( o.pathFile ) )
  self.fileDelete( o.pathFile );

  return self.directoryMakeAct({ pathFile : o.pathFile, sync : o.sync });
}

directoryMake.defaults =
{
  force : 1,
  rewritingTerminal : 1,
}

directoryMake.defaults.__proto__ = directoryMakeAct.defaults;

//

var directoryMakeForFile = function( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( directoryMakeForFile,o );
  _.assert( arguments.length === 1 );

  o.pathFile = _.pathDir( o.pathFile );

  return self.directoryMake( o );
}

directoryMakeForFile.defaults =
{
  force : 1,
}

directoryMakeForFile.defaults.__proto__ = directoryMake.defaults;

//

var _linkBegin = function( routine,args )
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

  // if( o.usingLogging )
  // logger.log( routine.name,':', o.pathDst + ' <- ' + o.pathSrc );

  return o;
}

//

var _link_functor = function( gen )
{

  _.assert( arguments.length === 1 );
  _.routineOptions( _link_functor,gen );

  var nameOfMethod = gen.nameOfMethod;

  var link = function link( o )
  {

    var self = this;
    var linkAct = self[ nameOfMethod ];

    var o = self._linkBegin( link,arguments );
    var optionsAct = _.mapScreen( linkAct.defaults,o );

    if( o.pathDst === o.pathSrc )
    {
      if( o.sync )
      return;
      return new wConsequence().give();
    }

    if( !self.fileStat( o.pathSrc ) )
    {
      var err = _.err( 'file does not exist',o.pathSrc );
      if( o.sync )
      throw err;
      return new wConsequence().error( err );
    }

    /* */

    var log = function()
    {
      if( !o.usingLogging )
      return;
      var c = _.strCommonLeft( o.pathDst,o.pathSrc );
      logger.log( '+',nameOfMethod,':',c,':',o.pathDst.substring( c.length ),'<-',o.pathSrc.substring( c.length ) );
    }

    /* */

    if( o.sync )
    {

      var temp;
      try
      {
        if( self.fileStat( o.pathDst ) )
        {
          temp = o.pathDst + '-' + _.idGenerateGuid();
          self.fileRenameAct({ pathDst : temp, pathSrc : o.pathDst, sync : 1 });
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
          self.fileRenameAct({ pathDst : o.pathDst, pathSrc : temp, sync : 1 });
        }
        catch( err2 )
        {
        }
        if( o.throwing )
        throw _.err( 'cant',nameOfMethod,o.pathDst,'<-',o.pathSrc,'\n',err )
        return false;
      }

      return true;
    }
    else
    {

      debugger;
      throw _.err( 'not tested' );
      var temp;

      return self.fileStat({ pathFile : o.pathDst, sync : 0 })
      .ifNoErrorThen( function( err,exists )
      {

        if( exists )
        {
          throw _.err( 'not tested' );
          temp = o.pathDst + '-' + _.idGenerateGuid();
          return self.fileRenameAct({ pathDst : temp, pathSrc : o.pathDst, sync : 0 });
        }

      })
      .ifNoErrorThen( function()
      {

        return linkAct.call( self,optionsAct );

      })
      .ifNoErrorThen( function()
      {

        log();

        if( temp )
        return self.fileDelete({ pathFile : temp, sync : 0 });

      })
      .thenDo( function( err )
      {

        if( err )
        {
          if( temp )
          return self.fileRenameAct({ pathDst : o.pathDst, pathSrc : temp, sync : 0 })
          .thenDo( function()
          {
            if( o.throwing )
            throw err;
            return false;
          })
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

/**
 * link methods options
 * @typedef { object } wTools~linkOptions
 * @property { boolean } [ pathDst= ] - Target file.
 * @property { boolean } [ pathSrc= ] - Source file.
 * @property { boolean } [ o.sync=true ] - Runs method in synchronously. Otherwise asynchronously and returns wConsequence object.
 * @property { boolean } [ rewriting=true ] - Rewrites target( o.pathDst ).
 * @property { boolean } [ usingLogging=true ] - Logs working process.
 * @property { boolean } [ throwing=true ]- Enables error throwing. Otherwise returns true/false.
 */

/**
 * Creates soft link( symbolic ) to existing source( o.pathSrc ) named as ( o.pathDst ).
 * Rewrites target( o.pathDst ) by default if it exist. Logging of working process is controled by option( o.usingLogging ).
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
  usingLogging : 1,
  throwing : 1,
}

linkSoft.defaults.__proto__ = linkSoftAct.defaults;

//

/**
 * Creates hard link( new name ) to existing source( o.pathSrc ) named as ( o.pathDst ).
 * Rewrites target( o.pathDst ) by default if it exist. Logging of working process is controled by option( o.usingLogging ).
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
  usingLogging : 1,
  throwing : 1,
}

linkHard.defaults.__proto__ = linkHardAct.defaults;

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
  usingLogging : 0,
  WriteMode : WriteMode,
}

// --
// prototype
// --

var Proto =
{

  init : init,

  _fileOptionsGet : _fileOptionsGet,

  fileRecord : fileRecord,


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
  fileHash : fileHash,

  filesSame : filesSame,
  filesLinked : filesLinked,

  directoryRead : directoryRead,


  // read stat

  fileStat : fileStat,
  fileIsTerminal : fileIsTerminal,
  fileIsSoftLink : fileIsSoftLink,
  directoryIs : directoryIs,


  // write act

  fileWriteAct : fileWriteAct,
  fileTimeSetAct : fileTimeSetAct,
  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,
  fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,

  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,



  // write

  fileWrite : fileWrite,
  fileAppend : fileAppend,
  fileWriteJson : fileWriteJson,

  fileDelete : fileDelete,
  fileDeleteForce : fileDeleteForce,

  directoryMake : directoryMake,
  directoryMakeForFile : directoryMakeForFile,

  _linkBegin : _linkBegin,
  _link_functor : _link_functor,

  linkSoft : linkSoft,
  linkHard : linkHard,


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
