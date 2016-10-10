( function _FileProviderAbstract_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );

  if( !wTools.FileRecord )
  require( './FileRecord.s' );

}

//

/**
* Definitions :
*  Terminal file :: leaf of tree, contains series of bytes. Terminal file cant contain other files.
*  Directory :: non-leaf node of tree, contains other directories and terminal file(s).
*  File :: any node of tree, could be leaf( terminal file ) or non-leaf( directory ).
*  Only terminal files contains series of bytes, function of directory to organize logical space for terminal files.
*  self :: current object.
*  Self :: current class.
*  Parent :: parent class.
*  Static :: static fields.
*  extend :: extend destination with all properties from source.
*/

//

var DefaultsFor = {};

DefaultsFor.fileReadAct =
{

  sync : 0,
  pathFile : null,
  encoding : 'utf8',
  advanced : null,

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

DefaultsFor.fileDeleteAct =
{

  pathFile : null,
  force : 1,
  sync : 1,

}

DefaultsFor.fileTimeSet =
{

  filePath : null,
  atime : null,
  mtime : null,

}

DefaultsFor.fileCopyAct =
{
  dst : null,
  src : null,
  sync : 1,
}

DefaultsFor.fileRenameAct =
{
  dst : null,
  src : null,
  sync : 1,
}

DefaultsFor.directoryMakeAct =
{
  pathFile : null,
  sync : 1,
}

DefaultsFor.directoryReadAct =
{
  pathFile : null,
  sync : 1,
}

DefaultsFor.fileHashAct =
{
  pathFile : null,
  sync : 1,
  usingLogging : 1,
}

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

  _.protoComplementInstance( self );

  if( o )
  self.copy( o );

  logger.log( 'new',_.strTypeOf( self ) );

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
  throw _.err( 'Files.fileWrite :','"o.pathFile" is required' );

  _.assertMapHasOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
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

//

var fileHash = function fileHash( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  return self.fileHashAct( o );
}

//

// !!! shout it rewrite files?

var directoryMake = function directoryMake( o )
{

  throw _.err( 'not implemented' );

}

directoryMake.defaults =
{
  force : 1,
}

directoryMake.defaults.__proto__ = DefaultsFor.directoryMakeAct;

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

// --
// write
// --

var directoryMakeForFile = function( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { pathFile : o };

  debugger;
  var o = _.routineOptions( directoryMakeForFile,o );
  _.assert( arguments.length === 1 );

  o.pathFile = _.pathDir( o.pathFile );

  return self.directoryMake( o );
}

directoryMakeForFile.defaults = directoryMake.defaults;

// --
// stat
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

  _fileOptionsGet : _fileOptionsGet,


  // read

  fileRead : fileRead,
  fileReadSync : fileReadSync,

  filesRead : filesRead,
  fileHash : fileHash,

  directoryMake : directoryMake,

  filesSame : filesSame,
  filesLinked : filesLinked,



  // write

  directoryMakeForFile : directoryMakeForFile,


  // stat

  fileStat : fileStat,
  fileIsTerminal : fileIsTerminal,
  fileIsSoftLink : fileIsSoftLink,
  directoryIs : directoryIs,


  // var

  DefaultsFor : DefaultsFor,


  // relationships

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
