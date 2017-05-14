( function _HardDrive_ss_() {

'use strict';

// require( './AdvancedMixin.s' );
// require( './Abstract.s' );
// require( '../FileRecord.s' );

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );
  require( '../Path.ss' );

  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

  if( !wTools.FileProvider.Abstract )
  require( './Abstract.s' );

  if( !wTools.FileProvider.AdvancedMixin )
  require( './AdvancedMixin.s' );

  var Path = require( 'path' );
  var File = require( 'fs-extra' );

}

// if( wTools.FileProvider.HardDrive )
// return;

var _ = wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderHardDrive( o )
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

// --
// etc
// --

function _pathNativizeWindows( filePath )
{
  var self = this;
  _.assert( _.strIs( filePath ) ) ;
  var result = filePath.replace( /\//g,'\\' );

  if( result[ 0 ] === '\\' )
  if( result.length === 2 || result[ 2 ] === ':' || result[ 2 ] === '\\' )
  result = result[ 1 ] + ':' + result.substring( 2 );

  return result;
}

function _pathNativizeUnix( filePath )
{
  var self = this;
  _.assert( _.strIs( filePath ) );
  return filePath;
}

// --
// read
// --

function fileReadAct( o )
{
  var self = this;
  var con;
  var stack = '';
  var result = null;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileReadAct,o );

  if( Config.debug )
  stack = _._err({ usingSourceCode : 0, args : [] });

  var encoder = fileReadAct.encoders[ o.encoding ];

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,{ transaction : o, encoder : encoder })

  }

  /* end */

  function handleEnd( data )
  {

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,{ data : data, transaction : o, encoder : encoder })

    if( o.sync )
    {
      return data;
    }
    else
    {
      return con.give( data );
    }

  }

  /* error */

  function handleError( err )
  {

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    err = _.err( stack,err );
    // err = _.err( err );

    if( o.sync )
    {
      throw err;
    }
    else
    {
      return con.error( err );
    }

  }

  /* exec */

  handleBegin();

  if( o.sync )
  {

    result = File.readFileSync( o.filePath,o.encoding === 'buffer' ? undefined : o.encoding );

    return handleEnd( result );
  }
  else
  {
    con = new wConsequence();

    File.readFile( o.filePath,o.encoding === 'buffer' ? undefined : o.encoding,function( err,data )
    {

      if( err )
      return handleError( err );
      else
      return handleEnd( data );

    });

    return con;
  }

}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;
fileReadAct.isOriginalReader = 1;

//

function createReadStreamAct( o )
{
  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  var o = _.routineOptions( createReadStreamAct, o );

  var stream = null;

  if( o.sync )
  {
    try
    {
      stream = File.createReadStream( o.filePath );
    }
    catch( err )
    {
      throw err;
    }
    return stream;
  }
  else
  {
    var con = new wConsequence();
    try
    {
      stream = File.createReadStream( o.filePath );
      con.give( stream );
    }
    catch( err )
    {
      con.error( err );
    }
    return con;
  }
}
createReadStreamAct.defaults =
{
  filePath : null,
  sync : 1
};
//

function fileStatAct( o )
{

  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  var o = _.routineOptions( fileStatAct,o );
  var result = null;

  /* */

  if( o.sync )
  {
    try
    {
      if( o.resolvingSoftLink )
      result = File.statSync( o.filePath );
      else
      result = File.lstatSync( o.filePath );
    }
    catch ( err )
    {
      if( o.throwing )
      throw err;
    }
    return result;
  }
  else
  {
    var con = new wConsequence();

    function handleEnd( err, stats )
    {
      if( err )
      {
        if( o.throwing )
        con.error( err );
        else
        con.give( result );
      }
      else
      con.give( stats );
    }

    if( o.resolvingSoftLink )
    File.stat( o.filePath,handleEnd );
    else
    File.lstat( o.filePath,handleEnd );

    return con;
  }
}

fileStatAct.defaults = {};
fileStatAct.defaults.__proto__ = Parent.prototype.fileStatAct.defaults;

//

var fileHashAct = ( function()
{

  var crypto;

  return function fileHashAct( o )
  {
    var result = NaN;
    var self = this;

    if( _.strIs( o ) )
    o = { filePath : o };

    _.routineOptions( fileHashAct,o );
    _.assert( _.strIs( o.filePath ) );
    _.assert( arguments.length === 1 );

    /* */

    if( !crypto )
    crypto = require( 'crypto' );
    var md5sum = crypto.createHash( 'md5' );

    /* */

    if( o.sync )
    {

      try
      {
        var read = File.readFileSync( o.filePath );
        md5sum.update( read );
        result = md5sum.digest( 'hex' );
      }
      catch( err )
      {
        if( o.throwing )
        throw err;
        result = NaN;
      }

      return result;

    }
    else
    {

      var con = new wConsequence();
      var stream = File.ReadStream( o.filePath );

      stream.on( 'data', function( d )
      {
        md5sum.update( d );
      });

      stream.on( 'end', function()
      {
        var hash = md5sum.digest( 'hex' );
        con.give( hash );
      });

      stream.on( 'error', function( err )
      {
        if( o.throwing )
        con.error( _.err( err ) );
        else
        con.give( NaN );
      });

      return con;
    }

  }

})();

fileHashAct.defaults = {};
fileHashAct.defaults.__proto__ = Parent.prototype.fileHashAct.defaults;

//

function directoryReadAct( o )
{
  var self = this;

  if( _.strIs( o ) )
  o =
  {
    filePath : arguments[ 0 ],
  }

  _.assert( arguments.length === 1 );
  _.routineOptions( directoryReadAct,o );

  var result = null;

  /* sort */

  function handleEnd( result )
  {
    // for( var r = 0 ; r < result.length ; r++ )
    // result[ r ] = _.pathRefine( result[ r ] ); // output should be covered by test !!!
    result.sort( function( a, b )
    {
      a = a.toLowerCase();
      b = b.toLowerCase();
      if( a < b ) return -1;
      if( a > b ) return +1;
      return 0;
    });
  }

  /* read dir */

  if( o.sync )
  {
    try
    {
      var stat = self.fileStat
      ({
        filePath : o.filePath,
        throwing : 1
      });
      if( stat.isDirectory() )
      {
        result = File.readdirSync( o.filePath );
        handleEnd( result );
      }
      else
      {
        result = [ _.pathName({ path : _.pathRefine( o.filePath ), withExtension : 1 }) ];
      }
    }
    catch ( err )
    {
      if( o.throwing )
      throw _.err( err );
      result = null;
    }

    return result;
  }
  else
  {
    var con = new wConsequence(); // xxx

    self.fileStat
    ({
      filePath : o.filePath,
      sync : 0,
      throwing : 1,
    })
    .got( function( err, stat )
    {
      if( err )
      {
        if( o.throwing )
        con.error( _.err( err ) );
        else
        con.give( result );
      }
      else if( stat.isDirectory() )
      {
        File.readdir( o.filePath, function ( err, files )
        {
          if( err )
          {
            if( o.throwing )
            con.error( _.err( err ) );
            else
            con.give( result );
          }
          else
          {
            handleEnd( files );
            con.give( files || null );
          }
        });
      }
      else
      {
        result = [ _.pathName({ path : _.pathRefine( o.filePath ), withExtension : 1 }) ];
        con.give( result );
      }
    });

    return con;
  }

}

directoryReadAct.defaults = {};
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

// //
//
//   /**
//    * Returns array of files names if `filePath` is directory, or array with one filePath element if `filePath` is not
//    * directory, but exists. Otherwise returns empty array.
//    * @example
//    * wTools.filesList('sample/tmp');
//    * @param {string} filePath path string
//    * @returns {string[]}
//    * @method filesList
//    * @memberof wTools
//    */
//
// function filesList( o )
// {
//
//   if( _.strIs( o ) )
//   o =
//   {
//     filePath : arguments[ 0 ],
//   }
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( directoryReadAct,o );
//
//   var result;
//
//   if( File.existsSync( o.filePath ) )
//   {
//     var stat = File.statSync( o.filePath );
//     if( stat.isDirectory() )
//     {
//       result = File.readdirSync( o.filePath );
//     }
//     else
//     {
//       result = [ _.pathName({ path : o.filePath, withExtension : 1 }) ];
//       return result;
//     }
//   }
//
//   result.sort( function( a, b )
//   {
//     a = a.toLowerCase();
//     b = b.toLowerCase();
//     if( a < b ) return -1;
//     if( a > b ) return +1;
//     return 0;
//   });
//
//   return result;
// }

// --
// write
// --

function createWriteStreamAct( o )
{
  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  var o = _.routineOptions( createWriteStreamAct, o );
  var stream = null;

  if( o.sync )
  {
    try
    {
      stream = File.createWriteStream( o.filePath );
    }
    catch( err )
    {
      throw _.err( err );
    }
    return stream;
  }
  else
  {
    var con = new wConsequence();
    try
    {
      stream = File.createWriteStream( o.filePath );
      con.give( stream );
    }
    catch( err )
    {
      con.error( _.err( err ) );
    }
    return con;
  }
}

createWriteStreamAct.defaults =
{
  filePath : null,
  sync : 1
}

//

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

/* !!! need to test all 3 write modes : rewrite,append,prepend in sync and async modes */

function fileWriteAct( o )
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

  _.routineOptions( fileWriteAct,o );
  _.assert( _.strIs( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  /* data conversion */

  if( _.bufferTypedIs( o.data ) || _.bufferRawIs( o.data ) )
  o.data = _.bufferToNodeBuffer( o.data );

  _.assert( _.strIs( o.data ) || _.bufferNodeIs( o.data ),'expects string or node buffer, but got',_.strTypeOf( o.data ) );

  /* write */

  if( o.sync )
  {

      if( o.writeMode === 'rewrite' )
      File.writeFileSync( o.filePath, o.data );
      else if( o.writeMode === 'append' )
      File.appendFileSync( o.filePath, o.data );
      else if( o.writeMode === 'prepend' )
      {
        var data;
        try
        {
          data = File.readFileSync( o.filePath )
        }
        catch ( err ){ }

        if( data )
        o.data = o.data.concat( data )
        File.writeFileSync( o.filePath, o.data );
      }
      else throw _.err( 'not implemented write mode',o.writeMode );

  }
  else
  {
    var con = wConsequence();

    function handleEnd( err )
    {
      // log();
      //if( err && !o.silentError )
      if( err )
      return con.error(  _.err( err ) );
      return con.give();
    }

    if( o.writeMode === 'rewrite' )
    File.writeFile( o.filePath, o.data, handleEnd );
    else if( o.writeMode === 'append' )
    File.appendFile( o.filePath, o.data, handleEnd );
    else if( o.writeMode === 'prepend' )
    {
      File.readFile( o.filePath, function( err,data )
      {
        // throw _.err( 'not tested' );
        // if( err )
        // return handleEnd( err );
        if( data )
        o.data = o.data.concat( data );
        File.writeFile( o.filePath, o.data, handleEnd );
      });

    }
    else handleEnd( _.err( 'not implemented write mode',o.writeMode ) );

    return con;
  }

}

fileWriteAct.defaults = {};
fileWriteAct.defaults.__proto__ = Parent.prototype.fileWriteAct.defaults;

fileWriteAct.isWriter = 1;

//

/**
 * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
 * @example
 * var fs = require('fs');

  var fileProvider = _.FileProvider.Default();

   var path = 'tmp/fileSize/data',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   delOptions =
  {
     filePath : path,
     sync : 0
   };

   fileProvider.fileWrite( { filePath : path, data : textData } ); // create test file

   console.log( fs.existsSync( path ) ); // true (file exists)
   var con = fileProvider.fileDelete( delOptions );

   con.got( function(err)
   {
     console.log( fs.existsSync( path ) ); // false (file does not exist)
   } );

 * @param {string|Object} o - options object.
 * @param {string} o.filePath path to file/directory for deleting.
 * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
    content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
 * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 1.
 * @throws {Error} If filePath is not string.
 * @throws {Error} If options object has unexpected property.
 * @method fileDeleteAct
 * @memberof wTools
 */

function fileDeleteAct( o )
{

  if( _.strIs( o ) )
  o = { filePath : o };

  var o = _.routineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );
  var self = this;
  var stat;

  //  err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   {
  //     throw err;
  //   }
  //   var con = new wConsequence();
  //   return con.error( err );
  // }

  var stat = self.fileStatAct( o.filePath );
  if( stat && stat.isSymbolicLink() )
  {
    debugger;
    //return handleError( _.err( 'not tested' ) );
    return _.err( 'not tested' );
  }

  if( o.sync )
  {

    if( stat && stat.isDirectory() )
    File.rmdirSync( o.filePath );
    else
    File.unlinkSync( o.filePath );

  }
  else
  {
    var con = new wConsequence();

    if( stat && stat.isDirectory() )
    File.rmdir( o.filePath,function( err,data ){ con.give( err,data ) } );
    else
    File.unlink( o.filePath,function( err,data ){ con.give( err,data ) } );

    return con;
  }

}

fileDeleteAct.defaults = {};
fileDeleteAct.defaults.__proto__ = Parent.prototype.fileDeleteAct.defaults;

//

/**
 * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
 * @example
 * var fs = require('fs');

  var fileProvider = _.FileProvider.Default();

   var path = 'tmp/fileSize/data',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   delOptions =
  {
     filePath : path,
     sync : 0
   };

   fileProvider.fileWrite( { filePath : path, data : textData } ); // create test file

   console.log( fs.existsSync( path ) ); // true (file exists)
   var con = fileProvider.fileDelete( delOptions );

   con.got( function(err)
   {
     console.log( fs.existsSync( path ) ); // false (file does not exist)
   } );

 * @param {string|Object} o - options object.
 * @param {string} o.filePath path to file/directory for deleting.
 * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
    content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
 * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 1.
 * @throws {Error} If filePath is not string.
 * @throws {Error} If options object has unexpected property.
 * @method fileDelete
 * @memberof wTools
 */

function fileDelete( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var o = _.routineOptions( fileDelete,o );
  var optionsAct = _.mapScreen( self.fileDeleteAct.defaults,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  o.filePath = self.pathNativize( o.filePath );

  if( _.files.usingReadOnly )
  return o.sync ? undefined : con.give();

  var stat;
  if( o.sync )
  {

    if( !o.force )
    {
      return self.fileDeleteAct( optionsAct );
    }
    else
    {
      File.removeSync( o.filePath );
    }

  }
  else
  {
    var con = new wConsequence();

    if( !o.force )
    {
      self.fileDeleteAct( optionsAct ).doThen( con );
    }
    else
    {
      File.remove( o.filePath,function( err ){ con.give( err,null ) } );
    }

    return con;
  }

}

fileDelete.defaults = {}
fileDelete.defaults.__proto__ = Parent.prototype.fileDelete.defaults;

//

function fileCopyAct( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileCopyAct,o );

  if( !self.fileIsTerminal( o.pathSrc ) )
  {
    var err = _.err( o.pathSrc,' is not a terminal file!' );
    if( o.sync )
    throw err;
    return new wConsequence().error( err );
  }

  /* */

  if( o.sync )
  {
    File.copySync( o.pathSrc, o.pathDst );
  }
  else
  {
    var con = new wConsequence();
    File.copy( o.pathSrc, o.pathDst, function( err, data )
    {
      con.give( err, data );
    });
    return con;
  }

}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;

//

function fileRenameAct( o )
{

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileRenameAct,o );

  if( o.sync )
  {
    File.renameSync( o.pathSrc, o.pathDst );
  }
  else
  {
    var con = new wConsequence();
    File.rename( o.pathSrc, o.pathDst, function( err,data )
    {
      con.give( err,data );
    });
    return con;
  }

}

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Parent.prototype.fileRenameAct.defaults;

//

function fileTimeSetAct( o )
{

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

  _.routineOptions( fileTimeSetAct,o );

  File.utimesSync( o.filePath, o.atime, o.mtime );

}

fileTimeSetAct.defaults = {};
fileTimeSetAct.defaults.__proto__ = Parent.prototype.fileTimeSetAct.defaults;

//

function directoryMakeAct( o )
{

  if( _.strIs( o ) )
  o =
  {
    filePath : arguments[ 0 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( directoryMakeAct,o );

  var stat;

  if( o.sync )
  {

    File.mkdirSync( o.filePath );

  }
  else
  {
    var con = new wConsequence();

    File.mkdir( o.filePath, function( err, data ){ con.give( err, data ); } );

    return con;
  }

}

directoryMakeAct.defaults = {};
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;

//

// !!! introduce options rewriting
// rewriting : 1 which delete files prevents making dir
// rewriting : 0 throw error if any file prevents making dir
// force : 1 make parent directories or none directory if needed
// force : 0 make only one directory, throw error if not enough, throw error if already exists

/**
 * directoryMake options
 * @typedef { object } wTools~directoryMakeOptions
 * @property { string } [ o.filePath=null ] - Path to new directory.
 * @property { boolean } [ o.rewriting=false ] - Deletes files that prevents folder creation if they exists.
 * @property { boolean } [ o.force=true ] - Makes parent directories to complete path( o.filePath ) if they needed.
 * @property { boolean } [ o.sync=true ] - Runs method in synchronously. Otherwise asynchronously and returns wConsequence object.
 */

/**
 * Creates directory specified by path( o.filePath ).
 * If( o.rewritingTerminal ) mode is enabled method deletes any file that prevents dir creation. Otherwise throws an error.
 * If( o.force ) mode is enabled it creates folders filesTree to complete path( o.filePath ) if needed. Otherwise tries to make
 * dir and throws error if directory already exists or one dir is not enough to complete path( o.filePath ).
 * Can be called in two ways:
 *  - First by passing only destination directory path and use default options;
 *  - Second by passing options object( o ).
 *
 * @param { wTools~directoryMakeOptions } o - options { @link wTools~directoryMakeOptions }.
 *
 * @example
 * var fileProvider = _.FileProvider.Default();
 * fileProvider.directoryMake( 'directory' );
 * var stat = fileProvider.fileStatAct( 'directory' );
 * console.log( stat.isDirectory() ); // returns true
 *
 * @method directoryMake
 * @throws { exception } If no argument provided.
 * @throws { exception } If ( o.rewriting ) is false and any file prevents making dir.
 * @throws { exception } If ( o.force ) is false and one dir is not enough to complete folders structure or folder already exists.
 * @memberof wTools
 */

function directoryMake( o )
{
  var self = this;

  if( _.strIs( o ) )
  o =
  {
    filePath : arguments[ 0 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( directoryMake,o );
  o.filePath = self.pathNativize( o.filePath );

  if( o.rewritingTerminal )
  if( self.fileIsTerminal( o.filePath ) )
  {
    // debugger;
    self.fileDelete( o.filePath );
  }

  if( o.sync )
  {

    if( o.force )
    File.mkdirsSync( o.filePath );
    else
    File.mkdirSync( o.filePath );

  }
  else
  {
    var con = new wConsequence();

    // throw _.err( 'not tested' );

    if( o.force )
    File.mkdirs( o.filePath, function( err, data )
    {
      con.give( err, data )
    });
    else
    File.mkdir( o.filePath, function( err, data )
    {
      con.give( err, data );
    });

    return con;
  }

}

directoryMake.defaults = Parent.prototype.directoryMake.defaults;

//

function linkSoftAct( o )
{
  var self = this;
  o = self._linkBegin( linkSoftAct,arguments );

  /* */

  if( o.sync )
  {
    if( self.fileStat( o.pathDst ) )
    throw _.err( 'linkSoftAct',o.pathDst,'already exists' );

    File.symlinkSync( o.pathSrc,o.pathDst );
  }
  else
  {
    // throw _.err( 'not tested' );
    var con = new wConsequence();
    self.fileStat
    ({
      filePath : o.pathDst,
      sync : 0
    })
    .got( function( err, stat )
    {
      if( stat )
      return con.error ( _.err( 'linkSoftAct',o.pathDst,'already exists' ) );
      File.symlink( o.pathSrc, o.pathDst, function ( err )
      {
        return con.give( err, null )
      });
    });
    return con;
  }

}

linkSoftAct.defaults = {};
linkSoftAct.defaults.__proto__ = Parent.prototype.linkSoftAct.defaults;

//

/**
 * Creates new name (hard link) for existing file. If pathSrc is not file or not exists method returns false.
    This method also can be invoked in next form : wTools.linkHardAct( pathDst, pathSrc ). If `o.pathDst` is already
    exists and creating link finish successfully, method rewrite it, otherwise the file is kept intact.
    In success method returns true, otherwise - false.
 * @example

 * var fileProvider = _.FileProvider.Default();
 * var path = 'tmp/linkHardAct/data.txt',
   link = 'tmp/linkHardAct/h_link_for_data.txt',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   textData1 = ' Aenean non feugiat mauris';

   fileProvider.fileWrite( { filePath : path, data : textData } );
   fileProvider.linkHardAct( link, path );

   var content = fileProvider.fileReadSync(link); // Lorem ipsum dolor sit amet, consectetur adipiscing elit.
   console.log(content);
   fileProvider.fileWrite( { filePath : path, data : textData1, append : 1 } );

   fileProvider.fileDelete( path ); // delete original name

   content = fileProvider.fileReadSync( link );
   console.log( content );
   // Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non feugiat mauris
   // but file is still exists)
 * @param {Object} o options parameter
 * @param {string} o.pathDst link path
 * @param {string} o.pathSrc file path
 * @param {boolean} [o.verbosity=false] enable logging.
 * @returns {boolean}
 * @throws {Error} if missed one of arguments or pass more then 2 arguments.
 * @throws {Error} if one of arguments is not string.
 * @throws {Error} if file `o.pathDst` is not exist.
 * @method linkHardAct
 * @memberof wTools
 */

function linkHardAct( o )
{
  var self = this;

  o = self._linkBegin( linkHardAct,arguments );

  /* */

  if( o.sync )
  {

    if( o.pathDst === o.pathSrc )
    return true;

    try
    {

      self.fileStat
      ({
        filePath : o.pathSrc,
        throwing : 1
      });

      if( self.fileStat( o.pathDst ) )
      throw _.err( 'linkHardAct',o.pathDst,'already exists' );

      File.linkSync( o.pathSrc,o.pathDst );
      return true;
    }
    catch ( err )
    {
      throw _.err( err );
    }

  }
  else
  {
    var con = new wConsequence();

    if( o.pathDst === o.pathSrc )
    return con.give( true );

    self.fileStat
    ({
      filePath : o.pathSrc,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function()
    {
      return self.fileStat
      ({
        filePath : o.pathDst,
        sync : 0,
        throwing : 0
      });
    })
    .got( function( err,stat )
    {
      if( err )
      return con.error( err );

      if( stat )
      return con.error( _.err( 'linkHardAct',o.pathDst,'already exists' ) );

      File.link( o.pathSrc,o.pathDst, function ( err )
      {
        return con.give( err,null );
      });
    })

    return con;
  }
}

linkHardAct.defaults = {};
linkHardAct.defaults.__proto__ = Parent.prototype.linkHardAct.defaults;

//

// --
// encoders
// --

var encoders = {};

encoders[ 'json' ] =
{

  onBegin : function( e )
  {
    throw _.err( 'not tested' );
    _.assert( e.transaction.encoding === 'json' );
    e.transaction.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    throw _.err( 'not tested' );
    _.assert( _.strIs( e.data ) );
    var result = JSON.parse( e.data );
    return result;
  },

}

encoders[ 'arraybuffer' ] =
{

  onBegin : function( e )
  {
    debugger;
    _.assert( e.transaction.encoding === 'arraybuffer' );
    e.transaction.encoding = 'buffer';
  },

  onEnd : function( e )
  {

    _.assert( _.bufferNodeIs( e.data ) || _.bufferTypedIs( e.data ) || _.bufferRawIs( e.data ) );

    // _.assert( _.bufferNodeIs( e.data ) );
    // _.assert( !_.bufferTypedIs( e.data ) );
    // _.assert( !_.bufferRawIs( e.data ) );

    var result = _.bufferRawFrom( e.data );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    return result;
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


  // etc

  _pathNativizeWindows : _pathNativizeWindows,
  _pathNativizeUnix : _pathNativizeUnix,


  // read

  fileReadAct : fileReadAct,
  createReadStreamAct : createReadStreamAct,
  fileStatAct : fileStatAct,
  fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,


  // write

  createWriteStreamAct : createWriteStreamAct,

  fileWriteAct : fileWriteAct,

  fileDeleteAct : fileDeleteAct,
  fileDelete : fileDelete,

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMakeAct : directoryMakeAct,
  directoryMake : directoryMake,

  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

if( process.platform === 'win32' )
Proto.pathNativize = _pathNativizeWindows;
else
Proto.pathNativize = _pathNativizeUnix;

//

_.protoMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.AdvancedMixin.mixin( Self );

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.HardDrive = Self;

if( typeof module !== 'undefined' )
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
