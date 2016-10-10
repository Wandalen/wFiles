(function _Files_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  require( './FilePath.ss' );
  require( './FileRecord.s' );

}

var Path = require( 'path' );
var File = require( 'fs-extra' );

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

//

/*

problems :

  !!! naming problem : fileStore / fileDirectory / fileAny

*/

// --
//
// --

// var directoryMakeAct = function( o )
// {
//
//   if( _.strIs( o ) )
//   o = { pathFile : o };
//
//   var o = _.routineOptions( directoryMakeAct,o );
//   _.assert( arguments.length === 1 );
//   _.assert( o.sync,'not implemented' );
//
//   File.mkdirsSync( o.pathFile );
//
// }
//
// directoryMakeAct.defaults =
// {
//   sync : 1,
//   pathFile : null,
// }

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
 * @memberof wTools
 */

var _fileOptionsGet = function( pathFile,o )
{
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

/*
  _.fileWrite
  ({
    pathFile : fileName,
    data : _.toStr( args,strOptions ) + '\n',
    append : true,
  });
*/

  /**
   * Writes data to a file. `data` can be a string or a buffer. Creating the file if it does not exist yet.
   * Returns wConsequence instance.
   * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
     exist, it's created. Method can accept two parameters : string `pathFile` and string\buffer `data`, or single
     argument : options object, with required 'pathFile' and 'data' parameters.
   * @example
   *  var fs = require('fs');
      var data = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        options =
        {
          pathFile : 'tmp/sample.txt',
          data : data,
          sync : false,
          force : true,
        };
      var con = wTools.fileWrite( options );
      con.got( function()
      {
          console.log('write finished');
          var fileContent = fs.readFileSync( 'tmp/sample.txt', { encoding : 'utf8' } );
          // 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
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
   * @method fileWrite
   * @memberof wTools
   */

var fileWrite = function( pathFile,data )
{
  var con = wConsequence();
  var o;

  if( _.strIs( pathFile ) )
  {
    o = { pathFile : pathFile, data : data };
    _.assert( arguments.length === 2 );
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  if( o.data === undefined )
  o.data = data;

  /* from buffer */

  if( _.bufferIs( o.data ) )
  {
    o.data = _.bufferToNodeBuffer( o.data );
  }

  /* log */

  if( o.usingLogging )
  logger.log( '+ writing',_.toStr( o.data,{ levels : 0 } ),'to',o.pathFile );

  /* verification */

  _.mapComplement( o,fileWrite.defaults );
  _.assertMapHasOnly( o,fileWrite.defaults );
  _.assert( _.strIs( o.pathFile ) );
  _.assert( _.strIs( o.data ) || _.bufferNodeIs( o.data ),'expects string or node buffer, but got',_.strTypeOf( o.data ) );

  /* force */

  if( o.force )
  {

    var pathFile = _.pathDir( o.pathFile );
    if( !File.existsSync( pathFile ) )
    File.mkdirsSync( pathFile );

  }

  /* clean */

  if( o.clean )
  {
    try
    {
      File.unlinkSync( o.pathFile );
    }
    catch( err )
    {
    }
  }

  /* write */

  if( o.sync )
  {

    if( o.silentError ) try
    {
      if( o.append )
      File.appendFileSync( o.pathFile, o.data );
      else
      File.writeFileSync( o.pathFile, o.data );
    }
    catch( err ){}
    else
    {
      if( o.append )
      File.appendFileSync( o.pathFile, o.data );
      else
      File.writeFileSync( o.pathFile, o.data );
    }
    con.give();

  }
  else
  {

    var handleEnd = function( err )
    {
      if( err && !o.silentError )
      _.errLog( '+ writing',_.toStr( o.data,{ levels : 0 } ),'to',o.pathFile,'\n',err );
      con._giveWithError( err,null );
    }

    if( o.append )
    File.appendFile( o.pathFile, o.data, handleEnd );
    else
    File.writeFile( o.pathFile, o.data, handleEnd );

  }

  /* done */

  return con;
}

fileWrite.defaults =
{
  pathFile : null,
  data : '',
  append : false,
  sync : true,
  force : true,
  silentError : false,
  usingLogging : false,
  clean : false,
}

fileWrite.isWriter = 1;

//

var fileAppend = function( pathFile,data )
{
  var o;

  if( _.strIs( pathFile ) )
  {
    o = { pathFile : pathFile, data : data };
    _.assert( arguments.length === 2 );
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileAppend,o );

  return _.fileWrite( o );
}

fileAppend.defaults =
{
  append : true,
}

fileAppend.defaults.__proto__ = fileWrite.defaults;

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
   *  var fs = require('fs');
   var data = { a : 'hello', b : 'world' },
   var con = wTools.fileWriteJson( 'tmp/sample.json', data );
   // file content : {"a" :"hello", "b" :"world"}

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

var fileWriteJson = function( pathFile,data )
{
  var o;

  if( _.strIs( pathFile ) )
  {
    o = { pathFile : pathFile, data : data };
    _.assert( arguments.length === 2 );
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.mapComplement( o,fileWriteJson.defaults );
  _.assertMapHasOnly( o,fileWriteJson.defaults );

  /**/

  if( _.stringify && o.pretty )
  o.data = _.stringify( o.data, null, DEBUG ? '  ' : null );
  else
  o.data = JSON.stringify( o.data );

  /**/

  if( Config.debug && o.pretty ) try {

    JSON.parse( o.data );

  } catch( err ) {

    debugger;
    logger.error( 'JSON:' );
    logger.error( o.data );
    throw _.err( 'Cant parse',err );

  }

  /**/

  delete o.pretty;

  return fileWrite( o );
}

fileWriteJson.defaults =
{
  pretty : 0,
  sync : 1,
}

fileWriteJson.defaults.__proto__ = fileWrite.defaults;

fileWriteJson.isWriter = 1;

//
//
// var fileReadAct = function( o )
// {
//   var con;
//   var result = null;
//
//   _.assert( arguments.length === 1 );
//   _.mapComplement( o,fileReadAct.defaults );
//
//   /* end */
//
//   var handleEnd = function( data )
//   {
//
//     if( o.sync )
//     {
//       return data;
//     }
//     else
//     {
//       return wConsequence.from( data );
//     }
//
//   }
//
//   /* error */
//
//   var handleError = function( err )
//   {
//
//     var err = _.err( err );
//     if( o.sync )
//     {
//       return err;
//     }
//     else
//     {
//       return wConsequence.from( err );
//     }
//
//   }
//
//   /* exec */
//
//   if( o.sync )
//   {
//
//     result = File.readFileSync( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding );
//
//     return handleEnd( result );
//   }
//   else
//   {
//
//     File.readFile( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding,function( err,data )
//     {
//
//       if( err )
//       return handleError( err );
//       else
//       return handleEnd( data );
//
//     });
//
//   }
//
//   /* done */
//
//   return con;
// }
//
// fileReadAct.defaults =
// {
//
//   sync : 0,
//
//   // wrap : 0,
//   // returnRead : 0,
//   // silent : 0,
//
//   pathFile : null,
//   //name : null,
//   encoding : 'utf8',
//
//   // onBegin : null,
//   // onEnd : null,
//   // onError : null,
//
//   advanced : null,
//
// }
//
// fileReadAct.isOriginalReader = 1;
//
// //
//
// /**
//  * Reads the entire content of a file.
//  * Can accepts `pathFile` as first parameters and options as second
//  * Returns wConsequence instance. If `o` sync parameter is set to true (by default) and returnRead is set to true,
//     method returns encoded content of a file.
//  * There are several way to get read content : as argument for function passed to wConsequence.got(), as second argument
//     for `o.onEnd` callback, and as direct method returns, if `o.returnRead` is set to true.
//  *
//  * @example
//  * // content of tmp/json1.json : {"a" :1,"b" :"s","c" :[1,3,4]}
//    var fileReadOptions =
//    {
//      sync : 0,
//      pathFile : 'tmp/json1.json',
//      encoding : 'json',
//
//      onEnd : function( err, result )
//      {
//        console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
//      }
//    };
//
//    var con = wTools.fileRead( fileReadOptions );
//
//    // or
//    fileReadOptions.onEnd = null;
//    var con2 = wTools.fileRead( fileReadOptions );
//
//    con2.got(function( err, result )
//    {
//      console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
//    });
//
//  * @example
//    fileRead({ pathFile : file.absolute, encoding : 'buffer' })
//
//  * @param {Object} o read options
//  * @param {string} o.pathFile path to read file
//  * @param {boolean} [o.sync=true] determines in which way will be read file. If this set to false, file will be read
//     asynchronously, else synchronously
//  * Note : if even o.sync sets to true, but o.returnRead if false, method will resolve read content through wConsequence
//     anyway.
//  * @param {boolean} [o.wrap=false] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
//     into object with key 'options' and options as value.
//  * @param {boolean} [o.returnRead=false] If sets to true, method will return encoded file content directly. Has effect
//     only if o.sync is set to true.
//  * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
//     pass into o.onEnd as first parameter. Note : if sync is set to false, error will caught anyway.
//  * @param {string} [o.name=null]
//  * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are :
//  *    'utf8' : default value, file content will be read as string.
//  *    'json' : file content will be parsed as JSON.
//  *    'arrayBuffer' : the file content will be return as raw ArrayBuffer.
//  * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
//  * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
//  * @param {Function} [o.onError=null] @see [@link fileRead~onError]
//  * @param {*} [o.advanced=null]
//  * @returns {wConsequence|ArrayBuffer|string|Array|Object}
//  * @throws {Error} if missed arguments
//  * @throws {Error} if `o` has extra parameters
//  * @method fileRead
//  * @memberof wTools
//  */
//
// /**
//  * This callback is run before fileRead starts read the file. Accepts error as first parameter.
//  * If in fileRead passed 'o.wrap' that is set to true, callback accepts as second parameter object with key 'options'
//     and value that is reference to options object passed into fileRead method, and user has ability to configure that
//     before start reading file.
//  * @callback fileRead~onBegin
//  * @param {Error} err
//  * @param {Object|*} options options argument passed into fileRead.
//  */
//
// /**
//  * This callback invoked after file has been read, and accepts encoded file content data (by depend from
//     options.encoding value), string by default ('utf8' encoding).
//  * @callback fileRead~onEnd
//  * @param {Error} err Error occurred during file read. If read success it's sets to null.
//  * @param {ArrayBuffer|Object|Array|String} result Encoded content of read file.
//  */
//
// /**
//  * Callback invoke if error occurred during file read.
//  * @callback fileRead~onError
//  * @param {Error} error
//  */
//
// var fileRead = function( o )
// {
//   //var con = new wConsequence();
//   var result = null;
//   var o = _fileOptionsGet.apply( fileRead,arguments );
//
//   _.mapComplement( o,fileRead.defaults );
//   _.assert( !o.returnRead || o.sync,'cant return read for async read' );
//   if( o.sync )
//   _.assert( o.returnRead,'sync expects ( returnRead == 1 )' );
//
//   var encodingProcessor = fileRead.encodings[ o.encoding ];
//
//   /* begin */
//
//   var handleBegin = function()
//   {
//
//     if( encodingProcessor && encodingProcessor.onBegin )
//     encodingProcessor.onBegin( o );
//
//     if( !o.onBegin )
//     return;
//
//     var r;
//     if( o.wrap )
//     r = { options : o };
//     else
//     r = o;
//
//     debugger;
//     wConsequence.give( o.onBegin,r );
//   }
//
//   /* end */
//
//   var handleEnd = function( data )
//   {
//
//     if( encodingProcessor && encodingProcessor.onEnd )
//     data = encodingProcessor.onEnd({ data : data, options : o });
//
//     var r = null;
//     if( o.wrap )
//     r = { data : data, options : o };
//     else
//     r = data;
//
//     debugger;
//     if( o.onEnd )
//     debugger;
//
//     if( o.onEnd )
//     wConsequence.give( o.onEnd,r );
//     if( !o.sync )
//     wConsequence.give( result,r );
//
//     return result;
//   }
//
//   /* error */
//
//   var handleError = function( err )
//   {
//
//     debugger;
//     if( o.onEnd )
//     wConsequence.error( o.onEnd,err );
//     if( !o.sync )
//     wConsequence.error( con,err );
//
//     if( o.throwing )
//     throw _.err( err );
//
//   }
//
//   /* exec */
//
//   handleBegin();
//
//   if( o.throwing )
//   {
//
//     result = fileReadAct( o );
//
//   }
//   else try
//   {
//
//     result = fileReadAct( o );
//
//   }
//   catch( err )
//   {
//     return handleError( err );
//   }
//
//   /* throwing */
//
//   if( o.sync )
//   {
//     if( o.throwing )
//     if( _.errorIs( result ) )
//     return handleError( result );
//   }
//
//   /* return */
//
//   return handleEnd( result );
// }
//
// fileRead.defaults =
// {
//
//   sync : 0,
//   wrap : 0,
//   returnRead : 0,
//   throwing : 1,
//
//   pathFile : null,
//   //name : null,
//   encoding : 'utf8',
//
//   onBegin : null,
//   onEnd : null,
//   onError : null,
//
//   advanced : null,
//
// }
//
// fileRead.isOriginalReader = 1;

//

// /**
//  * Reads the entire content of a file synchronously.
//  * Method returns encoded content of a file.
//  * Can accepts `pathFile` as first parameters and options as second
//  *
//  * @example
//  * // content of tmp/json1.json : { "a" : 1, "b" : "s", "c" : [ 1,3,4 ]}
//  var fileReadOptions =
//  {
//    pathFile : 'tmp/json1.json',
//    encoding : 'json',
//
//    onEnd : function( err, result )
//    {
//      console.log(result); // { a : 1, b : 's', c : [ 1, 3, 4 ] }
//    }
//  };
//
//  var res = wTools.fileReadSync( fileReadOptions );
//  // { a : 1, b : 's', c : [ 1, 3, 4 ] }
//
//  * @param {Object} o read options
//  * @param {string} o.pathFile path to read file
//  * @param {boolean} [o.wrap=false] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
//  into object with key 'options' and options as value.
//  * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
//  pass into o.onEnd as first parameter. Note : if sync is set to false, error will caught anyway.
//  * @param {string} [o.name=null]
//  * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are :
//  *    'utf8' : default value, file content will be read as string.
//  *    'json' : file content will be parsed as JSON.
//  *    'arrayBuffer' : the file content will be return as raw ArrayBuffer.
//  * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
//  * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
//  * @param {Function} [o.onError=null] @see [@link fileRead~onError]
//  * @param {*} [o.advanced=null]
//  * @returns {wConsequence|ArrayBuffer|string|Array|Object}
//  * @throws {Error} if missed arguments
//  * @throws {Error} if `o` has extra parameters
//  * @method fileReadSync
//  * @memberof wTools
//  */
//
// var fileReadSync = function()
// {
//   var o = _fileOptionsGet.apply( fileReadSync,arguments );
//
//   _.mapComplement( o,fileReadSync.defaults );
//   o.sync = 1;
//
//   //logger.log( 'fileReadSync.returnRead : ',o.returnRead );
//
//   return _.fileRead( o );
// }
//
// fileReadSync.defaults =
// {
//   returnRead : 1,
//   sync : 1,
//   encoding : 'utf8',
// }
//
// fileReadSync.defaults.__proto__ = fileRead.defaults;
// fileReadSync.isOriginalReader = 1;

//
/*
var filesRead = function( paths,o )
{

  throw _.err( 'not tested' );

  // options

  if( _.objectIs( paths ) )
  {
    o = paths;
    paths = o.paths;
    _.assert( arguments.length === 1 );
  }
  else
  {
    _.assert( arguments.length === 1 || arguments.length === 2 );
  }

  var o = o || {};
  paths = o.paths = paths || o.paths;
  paths = _.arrayAs( paths );

  var result = o.concat ? '' : [];

  if( !o.sync )
  throw _.err( 'not implemented' );

  // exec

  for( var p = 0 ; p < paths.length ; p++ )
  {

    var pathFile = paths[ p ];
    var readOptions = _.mapScreen( _.fileRead.defaults,o );

    readOptions.pathFile = pathFile;

    if( o.concat )
    {
      result += _.fileRead( pathFile,o );
      if( p < pathFile.length - 1 )
      result += o.delimeter;
    }
    else
    {
      result[ p ] = fileRead( pathFile,o );
    }

  }

  //

  return result;
}

filesRead.defaults =
{

  delimeter : '',
  concat : 0,

}

filesRead.defaults.__proto__ = fileRead.default;
*/

//

// /**
//  * Reads a JSON file and then parses it into an object.
//  *
//  * @example
//  * // content of tmp/json1.json : {"a" :1,"b" :"s","c" :[1,3,4]}
//  *
//  * var res = wTools.fileReadJson( 'tmp/json1.json' );
//  * // { a : 1, b : 's', c : [ 1, 3, 4 ] }
//  * @param {string} pathFile file path
//  * @returns {*}
//  * @throws {Error} If missed arguments, or passed more then one argument.
//  * @method fileReadJson
//  * @memberof wTools
//  */
//
// var fileReadJson = function( pathFile )
// {
//   var result = null;
//   var pathFile = _.pathGet( pathFile );
//
//   _.assert( arguments.length === 1 );
//
//   if( File.existsSync( pathFile ) )
//   {
//
//     try
//     {
//       var str = File.readFileSync( pathFile,'utf8' );
//       result = JSON.parse( str );
//     }
//     catch( err )
//     {
//       throw _.err( 'cant read json from',pathFile,'\n',err );
//     }
//
//   }
//
//   return result;
// }

// --
//
// --


//

  /**
   * Creates new name (hard link) for existing file. If pathSrc is not file or not exists method returns false.
      This method also can be invoked in next form : wTools.filesLink( pathDst, pathSrc ). If `o.pathDst` is already
      exists and creating link finish successfully, method rewrite it, otherwise the file is kept intact.
      In success method returns true, otherwise - false.
   * @example
   * var path = 'tmp/filesLink/data.txt',
     link = 'tmp/filesLink/h_link_for_data.txt',
     textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     textData1 = ' Aenean non feugiat mauris';


     wTools.fileWrite( { pathFile : path, data : textData } );
     wTools.filesLink( link, path );

     var content = wTools.fileReadSync(link); // Lorem ipsum dolor sit amet, consectetur adipiscing elit.
     console.log(content);
     wTools.fileWrite( { pathFile : path, data : textData1, append : 1 } );

     wTools.fileDeleteAct( path ); // delete original name

     content = wTools.fileReadSync(link);
     console.log(content);
     // Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non feugiat mauris
     // but file is still exists)
   * @param {Object} o options parameter
   * @param {string} o.pathDst link path
   * @param {string} o.pathSrc file path
   * @param {boolean} [o.usingLogging=false] enable logging.
   * @returns {boolean}
   * @throws {Error} if missed one of arguments or pass more then 2 arguments.
   * @throws {Error} if one of arguments is not string.
   * @throws {Error} if file `o.pathDst` is not exist.
   * @method filesLink
   * @memberof wTools
   */

var filesLink = function( o )
{

  if( arguments.length === 2 )
  {
    o =
    {
      pathDst : arguments[ 0 ],
      pathSrc : arguments[ 1 ],
    }
  }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapHasOnly( o,filesLink.defaults );

  o.pathDst = _.pathGet( o.pathDst );
  o.pathSrc = _.pathGet( o.pathSrc );

  if( o.usingLogging )
  logger.log( 'filesLink : ', o.pathDst + ' <- ' + o.pathSrc );

  if( o.pathDst === o.pathSrc )
  return true;

  if( !File.existsSync( o.pathSrc ) )
  return false;

  var temp;
  try
  {
    if( File.existsSync( o.pathDst ) )
    {
      temp = o.pathDst + '-' + _.idGenerateGuid();
      File.renameSync( o.pathDst,temp );
    }
    File.linkSync( o.pathSrc,o.pathDst );
    if( temp )
    File.unlinkSync( temp );
    return true;
  }
  catch( err )
  {
    if( temp )
    File.renameSync( temp,o.pathDst );
    return false;
  }

}

filesLink.defaults =
{
  pathDst : null,
  pathSrc : null,
  usingLogging : false,
}

//

  /**
   * Returns path/stats associated with file with newest modified time.
   * @example
   * var fs = require('fs');

     var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

     wTools.fileWrite( { pathFile : path1, data : buffer } );
     setTimeout( function()
     {
       wTools.fileWrite( { pathFile : path2, data : buffer } );


       var newer = wTools.filesNewer( path1, path2 );
       // 'tmp/sample/file2'
     }, 100);
   * @param {string|File.Stats} dst first file path/stat
   * @param {string|File.Stats} src second file path/stat
   * @returns {string|File.Stats}
   * @throws {Error} if type of one of arguments is not string/file.Stats
   * @method filesNewer
   * @memberof wTools
   */

var filesNewer = function( dst,src )
{
  var odst = dst;
  var osrc = src;

  _.assert( arguments.length === 2 );

  if( src instanceof File.Stats )
  src = { stat : src };
  else if( _.strIs( src ) )
  src = { stat : File.statSync( src ) };
  else if( !_.objectIs( src ) )
  throw _.err( 'unknown src type' );

  if( dst instanceof File.Stats )
  dst = { stat : dst };
  else if( _.strIs( dst ) )
  dst = { stat : File.statSync( dst ) };
  else if( !_.objectIs( dst ) )
  throw _.err( 'unknown dst type' );

  if( src.stat.mtime > dst.stat.mtime )
  return osrc;
  else if( src.stat.mtime < dst.stat.mtime )
  return odst;
  else
  return null;

}

  //

  /**
   * Returns path/stats associated with file with older modified time.
   * @example
   * var fs = require('fs');

   var path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { pathFile : path1, data : buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { pathFile : path2, data : buffer } );

     var newer = wTools.filesOlder( path1, path2 );
     // 'tmp/sample/file1'
   }, 100);
   * @param {string|File.Stats} dst first file path/stat
   * @param {string|File.Stats} src second file path/stat
   * @returns {string|File.Stats}
   * @throws {Error} if type of one of arguments is not string/file.Stats
   * @method filesOlder
   * @memberof wTools
   */

var filesOlder = function( dst,src )
{

  _.assert( arguments.length === 2 );

  var result = filesNewer( dst,src );

  if( result === dst )
  return src;
  else if( result === src )
  return dst;
  else
  return null;

}

//

  /**
   * Returns spectre of file content.
   * @example
   * var path = '/home/tmp/sample/file1',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

     wTools.fileWrite( { pathFile : path, data : textData1 } );
     var spectre = wTools.filesSpectre( path );
     //{
     //   L : 1,
     //   o : 4,
     //   r : 3,
     //   e : 5,
     //   m : 3,
     //   ' ' : 7,
     //   i : 6,
     //   p : 2,
     //   s : 4,
     //   u : 2,
     //   d : 2,
     //   l : 2,
     //   t : 5,
     //   a : 2,
     //   ',' : 1,
     //   c : 3,
     //   n : 2,
     //   g : 1,
     //   '.' : 1,
     //   length : 56
     // }
   * @param {string|wFileRecord} src absolute path or FileRecord instance
   * @returns {Object}
   * @throws {Error} If count of arguments are different from one.
   * @throws {Error} If `src` is not absolute path or FileRecord.
   * @method filesSpectre
   * @memberof wTools
   */

var filesSpectre = function( src )
{

  _.assert( arguments.length === 1, 'filesSpectre :','expect single argument' );

  src = FileRecord( src );
  var read = src.read;

  if( !read )
  read = _.FileProvider.HardDrive().fileRead
  ({
    pathFile : src.absolute,
    silent : 1,
    returnRead : 1,
  });

  return _.strLattersSpectre( read );
}

//

  /**
   * Compares specters of two files. Returns the rational number between 0 and 1. For the same specters returns 1. If
      specters do not have the same letters, method returns 0.
   * @example
   * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

     wTools.fileWrite( { pathFile : path1, data : textData1 } );
     wTools.fileWrite( { pathFile : path2, data : textData1 } );
     var similarity = wTools.filesSimilarity( path1, path2 ); // 1
   * @param {string} src1 path string 1
   * @param {string} src2 path string 2
   * @param {Object} [options]
   * @param {Function} [onReady]
   * @returns {number}
   * @method filesSimilarity
   * @memberof wTools
   */

var filesSimilarity = function filesSimilarity( o )
{

  _.assert( arguments.length === 1 );
  _.routineOptions( filesSimilarity,o );

  o.src1 = FileRecord( o.src1 );
  o.src2 = FileRecord( o.src2 );

  if( !o.src1.latters )
  o.src1.latters = _.filesSpectre( o.src1 );

  if( !o.src2.latters )
  o.src2.latters = _.filesSpectre( o.src2 );

  var result = _.lattersSpectreComparison( o.src1.latters,o.src2.latters );

  return result;
}

filesSimilarity.defaults =
{
  src1 : null,
  src2 : null,
}

//

  /**
   * Returns sum of sizes of files in `paths`.
   * @example
   * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     textData2 = 'Aenean non feugiat mauris';

     wTools.fileWrite( { pathFile : path1, data : textData1 } );
     wTools.fileWrite( { pathFile : path2, data : textData2 } );
     var size = wTools.filesSize( [ path1, path2 ] );
     console.log(size); // 81
   * @param {string|string[]} paths path to file or array of paths
   * @param {Object} [options] additional options
   * @param {Function} [options.onBegin] callback that invokes before calculation size.
   * @param {Function} [options.onEnd] callback.
   * @returns {number} size in bytes
   * @method filesSize
   * @memberof wTools
   */

var filesSize = function( paths,options )
{
  var result = 0;
  var options = options || {};
  var paths = _.arrayAs( paths );

  if( options.onBegin ) options.onBegin.call( this,null );

  if( options.onEnd ) throw 'Not implemented';

  for( var p = 0 ; p < paths.length ; p++ )
  {
    result += fileSize( paths[ p ] );
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

     wTools.fileWrite( { pathFile : path, data : bufferData1 } );

     var size1 = wTools.fileSize( path );
     console.log(size1); // 4

     var con = wTools.fileSize( {
       pathFile : path,
       onEnd : function( size )
       {
         console.log( size ); // 7
       }
     } );

     wTools.fileWrite( { pathFile : path, data : bufferData2, append : 1 } );

   * @param {string|Object} options options object or path string
   * @param {string} options.pathFile path to file
   * @param {Function} [options.onBegin] callback that invokes before calculation size.
   * @param {Function} options.onEnd this callback invoked in end of current js event loop and accepts file size as
      argument.
   * @returns {number|boolean|wConsequence}
   * @throws {Error} If passed less or more than one argument.
   * @throws {Error} If passed unexpected parameter in options.
   * @throws {Error} If pathFile is not string.
   * @method fileSize
   * @memberof wTools
   */

var fileSize = function( options )
{
  var options = options || {};

  if( _.strIs( options ) )
  options = { pathFile : options };

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( options,fileSize.defaults );
  _.mapComplement( options,fileSize.defaults );
  _.assert( _.strIs( options.pathFile ) );

  if( fileIsSoftLink( options.pathFile ) )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  // synchronization

  if( options.onEnd ) return _.timeOut( 0, function()
  {
    var onEnd = options.onEnd;
    delete options.onEnd;
    onEnd.call( this,fileSize.call( this,options ) );
  });

  if( options.onBegin ) options.onBegin.call( this,null );

  var stat = File.statSync( options.pathFile );

  return stat.size;
}

fileSize.defaults =
{
  pathFile : null,
  onBegin : null,
  onEnd : null,
}

//
//
//   /**
//    * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
//    * @example
//    * var fs = require('fs');
//
//      var path = 'tmp/fileSize/data',
//      textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//      delOptions = {
//        pathFile : path,
//        sync : 0
//      };
//
//      wTools.fileWrite( { pathFile : path, data : textData } ); // create test file
//
//      console.log( fs.existsSync( path ) ); // true (file exists)
//      var con = wTools.fileDeleteAct( delOptions );
//
//      con.got( function(err)
//      {
//        console.log( fs.existsSync( path ) ); // false (file does not exist)
//      } );
//    * @param {string|Object} o - options object.
//    * @param {string} o.pathFile path to file/directory for deleting.
//    * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
//       content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
//    * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
//    * @returns {wConsequence}
//    * @throws {Error} If missed argument, or pass more than 1.
//    * @throws {Error} If pathFile is not string.
//    * @throws {Error} If options object has unexpected property.
//    * @method fileDeleteAct
//    * @memberof wTools
//    */
//
// var fileDeleteAct = function( o )
// {
//   var con = new wConsequence();
//
//   if( _.strIs( o ) )
//   o = { pathFile : o };
//
//   var o = _.routineOptions( fileDeleteAct,o );
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.pathFile ) );
//
//   if( _.files.usingReadOnly )
//   return con.give();
//
//   var stat;
//   if( o.sync )
//   {
//
//     if( !o.force )
//     {
//       try
//       {
//         stat = File.lstatSync( o.pathFile );
//       }
//       catch( err ){};
//       if( !stat )
//       return con.error( _.err( 'cant read ' + o.pathFile ) );
//       if( stat.isSymbolicLink() )
//       {
//         debugger;
//         //throw _.err( 'not tested' );
//       }
//       if( stat.isDirectory() )
//       File.rmdirSync( o.pathFile );
//       else
//       File.unlinkSync( o.pathFile );
//     }
//     else
//     {
//       File.removeSync( o.pathFile );
//     }
//
//     con.give();
//
//   }
//   else
//   {
//
//     if( !o.force )
//     {
//       try
//       {
//         stat = File.lstatSync( o.pathFile );
//       }
//       catch( err ){};
//       if( !stat )
//       return con.error( _.err( 'cant read ' + o.pathFile ) );
//       if( stat.isSymbolicLink() )
//       throw _.err( 'not tested' );
//       if( stat.isDirectory() )
//       File.rmdir( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
//       else
//       File.unlink( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
//     }
//     else
//     {
//       File.remove( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
//     }
//
//   }
//
//   return con;
// }
//
// fileDeleteAct.defaults =
// {
//   pathFile : null,
//   force : 1,
//   sync : 1,
// }
//
// //
//
// var fileDeleteForce = function( o )
// {
//
//   if( _.strIs( o ) )
//   o = { pathFile : o };
//
//   var o = _.routineOptions( fileDeleteForce,o );
//   _.assert( arguments.length === 1 );
//
//   return _.fileDeleteAct( o );
// }
//
// fileDeleteForce.defaults =
// {
//   force : 1,
//   sync : 1,
// }
//
// fileDeleteForce.defaults.__proto__ = fileDeleteAct.defaults;

//

  /**
   * Returns array of files names if `pathFile` is directory, or array with one pathFile element if `pathFile` is not
   * directory, but exists. Otherwise returns empty array.
   * @example
   * wTools.filesList('sample/tmp');
   * @param {string} pathFile path string
   * @returns {string[]}
   * @method filesList
   * @memberof wTools
   */

var filesList = function filesList( pathFile )
{
  var files = [];

  if( File.existsSync( pathFile ) )
  {
    var stat = File.statSync( pathFile );
    if( stat.isDirectory() )
    files = File.readdirSync( pathFile );
    else
    {
      files = [ _.pathName( pathFile, { withExtension : true } ) ];
      return files;
    }
  }

  files.sort( function( a, b )
  {
    a = a.toLowerCase();
    b = b.toLowerCase();
    if( a < b ) return -1;
    if( a > b ) return +1;
    return 0;
  });

  return files;
}

//

  /**
   * Returns true if any file from o.dst is newer than other any from o.src.
   * @example :
   * wTools.filesIsUpToDate
   * ({
   *   src : [ 'foo/file1.txt', 'foo/file2.txt' ],
   *   dst : [ 'bar/file1.txt', 'bar/file2.txt' ],
   * });
   * @param {Object} o
   * @param {string[]} o.src array of paths
   * @param {Object} [o.srcOptions]
   * @param {string[]} o.dst array of paths
   * @param {Object} [o.dstOptions]
   * @param {boolean} [o.usingLogging=true] turns on/off logging
   * @returns {boolean}
   * @throws {Error} If passed object has unexpected parameter.
   * @method filesIsUpToDate
   * @memberof wTools
   */

var filesIsUpToDate = function( o )
{

  _.assert( arguments.length === 1 );
  _.assert( !o.newer || _.dateIs( o.newer ) );
  _.routineOptions( filesIsUpToDate,o );

  if( o.srcOptions || o.dstOptions )
  throw _.err( 'not tested' );

  var srcFiles = FileRecord.prototype.fileRecordsFiltered( o.src,o.srcOptions );

  if( !srcFiles.length )
  {
    if( o.usingLogging )
    logger.log( 'Nothing to parse' );
    return true;
  }

  var srcNewest = _.entityMax( srcFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /**/

  var dstFiles = FileRecord.prototype.fileRecordsFiltered( o.dst,o.dstOptions );

  if( !dstFiles.length )
  {
    return false;
  }

  var dstOldest = _.entityMin( dstFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /**/

  if( o.newer )
  {
    if( !( o.newer.getTime() <= dstOldest.stat.mtime.getTime() ) )
    return false;
  }

  if( srcNewest.stat.mtime.getTime() <= dstOldest.stat.mtime.getTime() )
  {

    if( o.usingLogging )
    logger.log( 'Up to date' );
    return true;

  }

  return false;
}

filesIsUpToDate.defaults =
{
  //path : null,
  //recursive : 1,
  src : null,
  srcOptions : null,
  dst : null,
  dstOptions : null,
  usingLogging : 1,
  newer : null,
}

//

var filesShadow = function( shadows,owners )
{

  for( var s = 0 ; s < shadows.length ; s++ )
  {
    var shadow = shadows[ s ];
    shadow = _.objectIs( shadow ) ? shadow.relative : shadow;

    for( var o = 0 ; o < owners.length ; o++ )
    {

      var owner = owners[ o ];

      owner = _.objectIs( owner ) ? owner.relative : owner;

      if( _.strBegins( shadow,_.pathPrefix( owner ) ) )
      {
        //logger.log( '?',shadow,'shadowed by',owner );
        shadows.splice( s,1 );
        s -= 1;
        break;
      }

    }

  }

}

//

var fileReport = function( file )
{
  var report = '';

  var file = _.FileRecord( file );

  var fileTypes = {};

  if( file.stat )
  {
    fileTypes.isFile = file.stat.isFile();
    fileTypes.isDirectory = file.stat.isDirectory();
    fileTypes.isBlockDevice = file.stat.isBlockDevice();
    fileTypes.isCharacterDevice = file.stat.isCharacterDevice();
    fileTypes.isSymbolicLink = file.stat.isSymbolicLink();
    fileTypes.isFIFO = file.stat.isFIFO();
    fileTypes.isSocket = file.stat.isSocket();
  }

  report += _.toStr( file,{ levels : 2, wrap : 0 } );
  report += '\n';
  report += _.toStr( file.stat,{ levels : 2, wrap : 0 } );
  report += '\n';
  report += _.toStr( fileTypes,{ levels : 2, wrap : 0 } );

  return report;
}

//

// var fileExists = function( filePath )
// {
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( filePath ) );
//
//   try
//   {
//     File.statSync( filePath );
//     return true;
//   }
//   catch( err )
//   {
//     return false;
//   }
//
// }

// //
//
// var fileStat = function( filePath )
// {
//   var result = null;
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( filePath ) );
//
//   try
//   {
//     result = File.statSync( filePath );
//   }
//   catch( err )
//   {
//   }
//
//   return result;
// }
//
// // --
// // encoding
// // --
//
// var encodings = {};
//
// encodings[ 'json' ] =
// {
//
//   onBegin : function( o )
//   {
//     _.assert( o.encoding === 'json' );
//     o.encoding = 'utf8';
//   },
//
//   onEnd : function( read )
//   {
//     _.assert( _.strIs( read.data ) );
//     var result = JSON.parse( read.data );
//     return result;
//   },
//
// }
//
// encodings[ 'arraybuffer' ] =
// {
//
//   onBegin : function( o )
//   {
//
//     //logger.log( '! debug : ' + Config.debug );
//
//     _.assert( o.encoding === 'arraybuffer' );
//     o.encoding = 'buffer';
//   },
//
//   onEnd : function( read )
//   {
//
//     _.assert( _.bufferNodeIs( read.data ) );
//     _.assert( !_.bufferIs( read.data ) );
//     _.assert( !_.bufferRawIs( read.data ) );
//
//     var result = _.bufferRawFrom( read.data );
//
//     _.assert( !_.bufferNodeIs( result ) );
//     _.assert( _.bufferRawIs( result ) );
//
//     return result;
//   },
//
// }
//
// fileRead.encodings = encodings;

// --
// file provider
// --
/*
var fileProviderFileSystem = (function( o )
{

  var provider =
  {

    name : 'fileProviderFileSystem',

    fileRead : fileRead,
    fileWrite : fileWrite,

    filesRead : _.filesRead_gen( fileRead ),

  };

  return fileProviderFileSystem = function( o )
  {
    var o = o || {};

    _.assert( arguments.length === 0 || arguments.length === 1 );
    _.assertMapHasOnly( o,fileProviderFileSystem.defaults );

    return provider;
  }

})();

fileProviderFileSystem.defaults = {};
*/
//

var FileProvider =
{

  //fileSystem : fileProviderFileSystem,
  //def : fileProviderFileSystem,

}

// --
// prototype
// --

var Proto =
{

  //directoryIs : directoryIs,
  //directoryMakeAct : directoryMakeAct,
  //directoryMakeForFile : directoryMakeForFile,

  //fileIsTerminal : fileIsTerminal,
  //fileIsSoftLink : fileIsSoftLink,

  _fileOptionsGet : _fileOptionsGet,

  fileWrite : fileWrite,
  fileAppend : fileAppend,
  fileWriteJson : fileWriteJson,

  // fileReadAct : fileReadAct,
  // fileRead : fileRead,
  //fileReadSync : fileReadSync,
  //fileReadJson : fileReadJson,

  //filesSame : filesSame,
  //filesLinked : filesLinked,
  filesLink : filesLink,

  filesNewer : filesNewer,
  filesOlder : filesOlder,

  filesSpectre : filesSpectre,
  filesSimilarity : filesSimilarity,

  filesSize : filesSize,
  fileSize : fileSize,

  //fileDeleteAct : fileDeleteAct,
  //fileDeleteForce : fileDeleteForce,

  filesList : filesList,
  filesIsUpToDate : filesIsUpToDate,

  //fileHash : fileHash,
  filesShadow : filesShadow,

  fileReport : fileReport,
  //fileExists : fileExists,
  //fileStat : fileStat,

}

_.mapExtend( Self,Proto );

Self.FileProvider = _.mapExtend( Self.FileProvider || {},FileProvider );
wTools.files = _.mapExtend( wTools.files || {},Proto );
wTools.files.usingReadOnly = 0;
wTools.files.pathCurrentAtBegin = _.pathCurrent();

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
