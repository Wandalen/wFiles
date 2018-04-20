( function _HardDrive_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../FileMid.s' );

  var File = require( 'fs-extra' );

}

var _ = _global_.wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Partial;
var Self = function wFileProviderHardDrive( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'HardDrive';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

// --
// adapter
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

//

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

  if( 1 )
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
    return data;
    else
    return con.give( data );

  }

  /* error */

  function handleError( err )
  {
    debugger
    if( encoder && encoder.onError )
    try
    {
      err = _._err
      ({
        args : [ stack,'\nfileReadAct( ',o.filePath,' )\n',err ],
        usingSourceCode : 0,
        level : 0,
      });
      err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })
    }
    catch( err2 )
    {
      console.error( err2 );
      console.error( err );
    }

    if( o.sync )
    throw err;
    else
    return con.error( _.err( err ) );

  }

  /* exec */

  handleBegin();

  if( o.sync )
  {
    try
    {
      result = File.readFileSync( o.filePath,o.encoding === 'buffer-node' ? undefined : o.encoding );
    }
    catch( err )
    {
      return handleError( err );
    }

    return handleEnd( result );
  }
  else
  {
    con = new _.Consequence();

    File.readFile( o.filePath,o.encoding === 'buffer-node' ? undefined : o.encoding,function( err,data )
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

fileReadAct.having = {};
fileReadAct.having.__proto__ = Parent.prototype.fileReadAct.having;

//

function fileReadStreamAct( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( fileReadStreamAct, o );

  try
  {
    return File.createReadStream( o.filePath );
  }
  catch( err )
  {
    throw _.err( err );
  }
}

fileReadStreamAct.defaults = {}
fileReadStreamAct.defaults.__proto__ = Parent.prototype.fileReadStreamAct.defaults;

fileReadStreamAct.having = {};
fileReadStreamAct.having.__proto__ = Parent.prototype.fileReadStreamAct.having;


//

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  _.routineOptions( fileStatAct,o );
  self._providerOptions( o );

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
    var con = new _.Consequence();

    function handleEnd( err, stats )
    {
      if( err )
      {
        err = _.err( err );
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

fileStatAct.having = {};
fileStatAct.having.__proto__ = Parent.prototype.fileStatAct.having;

//

// var fileHashAct = ( function()
// {

//   var crypto;

//   return function fileHashAct( o )
//   {
//     var result = NaN;
//     var self = this;

//     if( _.strIs( o ) )
//     o = { filePath : o };

//     _.routineOptions( fileHashAct,o );
//     _.assert( _.strIs( o.filePath ) );
//     _.assert( arguments.length === 1 );

//     /* */

//     if( !crypto )
//     crypto = require( 'crypto' );
//     var md5sum = crypto.createHash( 'md5' );

//     /* */

//     if( o.sync )
//     {

//       try
//       {
//         var read = File.readFileSync( o.filePath );
//         md5sum.update( read );
//         result = md5sum.digest( 'hex' );
//       }
//       catch( err )
//       {
//         if( o.throwing )
//         throw err;
//         result = NaN;
//       }

//       return result;

//     }
//     else
//     {

//       var con = new _.Consequence();
//       var stream = File.ReadStream( o.filePath );

//       stream.on( 'data', function( d )
//       {
//         md5sum.update( d );
//       });

//       stream.on( 'end', function()
//       {
//         var hash = md5sum.digest( 'hex' );
//         con.give( hash );
//       });

//       stream.on( 'error', function( err )
//       {
//         if( o.throwing )
//         con.error( _.err( err ) );
//         else
//         con.give( NaN );
//       });

//       return con;
//     }

//   }

// })();

// fileHashAct.defaults = {};
// fileHashAct.defaults.__proto__ = Parent.prototype.fileHashAct.defaults;

//

function directoryReadAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( directoryReadAct,o );

  var result = null;

  /* sort */

  function handleEnd( result )
  {
    // for( var r = 0 ; r < result.length ; r++ )
    // result[ r ] = _.pathRefine( result[ r ] ); // output should be covered by test !!!
    // result.sort( function( a, b )
    // {
    //   a = a.toLowerCase();
    //   b = b.toLowerCase();
    //   if( a < b ) return -1;
    //   if( a > b ) return +1;
    //   return 0;
    // });
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
    var con = new _.Consequence();

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
        File.readdir( o.filePath, function( err, files )
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

directoryReadAct.having = {};
directoryReadAct.having.__proto__ = Parent.prototype.directoryReadAct.having;

// --
// write
// --

function fileWriteStreamAct( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( fileWriteStreamAct, o );

  try
  {
    return File.createWriteStream( o.filePath );
  }
  catch( err )
  {
    throw _.err( err );
  }
}

fileWriteStreamAct.defaults = {}
fileWriteStreamAct.defaults.__proto__ = Parent.prototype.fileWriteStreamAct.defaults;

fileWriteStreamAct.having = {};
fileWriteStreamAct.having.__proto__ = Parent.prototype.fileWriteStreamAct.having;

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

function fileWriteAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
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
        catch( err ){ }
        if( data )
        o.data = o.data.concat( data )
        File.writeFileSync( o.filePath, o.data );
      }
      else throw _.err( 'not implemented write mode',o.writeMode );

  }
  else
  {
    var con = _.Consequence();

    function handleEnd( err )
    {
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

fileWriteAct.having = {};
fileWriteAct.having.__proto__ = Parent.prototype.fileWriteAct.having;

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
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileDeleteAct,o );
  _.assert( _.strIs( o.filePath ) );

  // if( o.filePath === '/pro/web/Port/package/wProto/node_modules/.bin' )
  // debugger;

  var stat = self.fileStatAct
  ({
    filePath : o.filePath,
    resolvingSoftLink : 0
  });

  // if( stat && stat.isSymbolicLink() )
  // {
  //   debugger;
  //   //return handleError( _.err( 'not tested' ) );
  //   // return _.err( 'not tested' );
  // }

  if( o.sync )
  {

    if( stat && stat.isDirectory() )
    File.rmdirSync( o.filePath );
    else
    File.unlinkSync( o.filePath );

  }
  else
  {
    var con = new _.Consequence();

    if( stat && stat.isDirectory() )
    File.rmdir( o.filePath,function( err,data ){ con.give( err,data ) } );
    else
    File.unlink( o.filePath,function( err,data ){ con.give( err,data ) } );

    return con;
  }

}

fileDeleteAct.defaults = {};
fileDeleteAct.defaults.__proto__ = Parent.prototype.fileDeleteAct.defaults;

fileDeleteAct.having = {};
fileDeleteAct.having.__proto__ = Parent.prototype.fileDeleteAct.having;

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

// function fileDelete( o )
// {
//   var self = this;

//   if( _.pathLike( o ) )
//   o = { filePath : _.pathGet( o ) };

//   _.routineOptions( fileDelete,o );
//   self._providerOptions( o )
//   o.filePath = _.pathGet( o.filePath );
//   o.filePath = self.pathNativize( o.filePath );

//   var optionsAct = _.mapScreen( self.fileDeleteAct.defaults,o );
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.filePath ) );

//   // if( _.files.usingReadOnly )
//   // return o.sync ? undefined : con.give();

//   var stat;
//   if( o.sync )
//   {

//     if( !o.force )
//     {
//       return self.fileDeleteAct( optionsAct );
//     }
//     else
//     {
//       File.removeSync( o.filePath );
//     }

//   }
//   else
//   {
//     var con = new _.Consequence();

//     if( !o.force )
//     {
//       self.fileDeleteAct( optionsAct ).doThen( con );
//     }
//     else
//     {
//       File.remove( o.filePath,function( err ){ con.give( err,null ) } );
//     }

//     return con;
//   }

// }

// fileDelete.defaults = {}
// fileDelete.defaults.__proto__ = Parent.prototype.fileDelete.defaults;

// fileDelete.having = {};
// fileDelete.having.__proto__ = Parent.prototype.fileDelete.having;

//

function fileCopyAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileCopyAct,o );

  if( !self.fileIsTerminal( o.srcPath ) )
  {
    var err = _.err( o.srcPath,' is not a terminal file!' );
    if( o.sync )
    throw err;
    return new _.Consequence().error( err );
  }

  /* */

  if( o.sync )
  {
    File.copySync( o.srcPath, o.dstPath );
  }
  else
  {
    var con = new _.Consequence();
    File.copy( o.srcPath, o.dstPath, function( err, data )
    {
      con.give( err, data );
    });
    return con;
  }

}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;

fileCopyAct.having = {};
fileCopyAct.having.__proto__ = Parent.prototype.fileCopyAct.having;

//

function fileRenameAct( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( fileRenameAct,o );

  if( o.sync )
  {
    File.renameSync( o.srcPath, o.dstPath );
  }
  else
  {
    var con = new _.Consequence();
    File.rename( o.srcPath, o.dstPath, function( err,data )
    {
      con.give( err,data );
    });
    return con;
  }

}

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Parent.prototype.fileRenameAct.defaults;

fileRenameAct.having = {};
fileRenameAct.having.__proto__ = Parent.prototype.fileRenameAct.having;

//

function fileTimeSetAct( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( fileTimeSetAct,o );

  File.utimesSync( o.filePath, o.atime, o.mtime );
}

fileTimeSetAct.defaults = {};
fileTimeSetAct.defaults.__proto__ = Parent.prototype.fileTimeSetAct.defaults;

fileTimeSetAct.having = {};
fileTimeSetAct.having.__proto__ = Parent.prototype.fileTimeSetAct.having;

//

function directoryMakeAct( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( directoryMakeAct,o );

  // console.log( 'directoryMakeAct',o.filePath );

  if( o.sync )
  {

    try
    {
      File.mkdirsSync( o.filePath );
    }
    catch( err )
    {
      debugger;
      throw _.err( err );
    }

  }
  else
  {
    var con = new _.Consequence();

    File.mkdirs( o.filePath, function( err, data ){ con.give( err, data ); } );

    return con;
  }

}

directoryMakeAct.defaults = {};
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;

directoryMakeAct.having = {};
directoryMakeAct.having.__proto__ = Parent.prototype.directoryMakeAct.having;

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

// function directoryMake( o )
// {
//   var self = this;

//   if( _.pathLike( o ) )
//   o = { filePath : _.pathGet( o ) };

//   _.assert( arguments.length === 1 );
//   _.routineOptions( directoryMake,o );
//   self._providerOptions( o );

//   o.filePath = _.pathGet( o.filePath );
//   o.filePath = self.pathNativize( o.filePath );

//   if( o.rewritingTerminal )
//   if( self.fileIsTerminal( o.filePath ) )
//   {
//     // debugger;
//     self.fileDelete( o.filePath );
//   }

//   if( o.sync )
//   {

//     if( o.force )
//     File.mkdirsSync( o.filePath );
//     else
//     File.mkdirSync( o.filePath );

//   }
//   else
//   {
//     var con = new _.Consequence();

//     // throw _.err( 'not tested' );

//     if( o.force )
//     File.mkdirs( o.filePath, function( err, data )
//     {
//       con.give( err, data )
//     });
//     else
//     File.mkdir( o.filePath, function( err, data )
//     {
//       con.give( err, data );
//     });

//     return con;
//   }

// }

// directoryMake.defaults = {};
// directoryMake.defaults.__proto__ = Parent.prototype.directoryMake.defaults;

// directoryMake.having = {};
// directoryMake.having.__proto__ = Parent.prototype.directoryMake.having;

//

function linkSoftAct( o )
{
  var self = this;
  o = self._linkBegin( linkSoftAct,arguments );

  /* */

  if( o.sync )
  {
    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkSoftAct', o.dstPath,'already exists' );

    // qqq
    debugger;
    if( process.platform )
    {
      if( _.strBegins( o.srcPath, '.\\' ) )
      o.srcPath = _.strCutOffLeft( o.srcPath,'.\\' )[ 2 ];
      if( _.strBegins( o.srcPath, '..' ) )
      o.srcPath = '.' + _.strCutOffLeft( o.srcPath,'..' )[ 2 ];
    }

    // qqq
    File.symlinkSync( o.srcPath, o.dstPath, 'dir' );
  }
  else
  {
    // throw _.err( 'not tested' );
    var con = new _.Consequence();
    self.fileStat
    ({
      filePath : o.dstPath,
      sync : 0
    })
    .got( function( err, stat )
    {
      if( stat )
      return con.error ( _.err( 'linkSoftAct',o.dstPath,'already exists' ) );
      File.symlink( o.srcPath, o.dstPath, function( err )
      {
        return con.give( err, null )
      });
    });
    return con;
  }

}

linkSoftAct.defaults = {};
linkSoftAct.defaults.__proto__ = Parent.prototype.linkSoftAct.defaults;

linkSoftAct.having = {};
linkSoftAct.having.__proto__ = Parent.prototype.linkSoftAct.having;

//

/**
 * Creates new name (hard link) for existing file. If srcPath is not file or not exists method returns false.
    This method also can be invoked in next form : wTools.linkHardAct( dstPath, srcPath ). If `o.dstPath` is already
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
 * @param {string} o.dstPath link path
 * @param {string} o.srcPath file path
 * @param {boolean} [o.verbosity=false] enable logging.
 * @returns {boolean}
 * @throws {Error} if missed one of arguments or pass more then 2 arguments.
 * @throws {Error} if one of arguments is not string.
 * @throws {Error} if file `o.dstPath` is not exist.
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

    if( o.dstPath === o.srcPath )
    return true;

    try
    {

      self.fileStat
      ({
        filePath : o.srcPath,
        throwing : 1,
      });

      if( self.fileStat( o.dstPath ) )
      throw _.err( 'linkHardAct', o.dstPath,'already exists' );

      File.linkSync( o.srcPath, o.dstPath );

      return true;
    }
    catch ( err )
    {
      throw _.err( err );
    }

  }
  else
  {
    var con = new _.Consequence();

    if( o.dstPath === o.srcPath )
    return con.give( true );

    self.fileStat
    ({
      filePath : o.srcPath,
      sync : 0,
      throwing : 1
    })
    .ifNoErrorThen( function()
    {
      return self.fileStat
      ({
        filePath : o.dstPath,
        sync : 0,
        throwing : 0
      });
    })
    .got( function( err,stat )
    {
      if( err )
      return con.error( err );

      if( stat )
      return con.error( _.err( 'linkHardAct',o.dstPath,'already exists' ) );

      File.link( o.srcPath,o.dstPath, function( err )
      {
        return con.give( err,null );
      });
    })

    return con;
  }
}

linkHardAct.defaults = {};
linkHardAct.defaults.__proto__ = Parent.prototype.linkHardAct.defaults;

linkHardAct.having = {};
linkHardAct.having.__proto__ = Parent.prototype.linkHardAct.having;

//

function pathResolveSoftLinkAct( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( _.pathIsAbsolute( filePath ) );

  if( !self.resolvingSoftLink || !self.fileIsSoftLink( filePath ) )
  return filePath;

  return File.realpathSync( self.pathNativize( filePath ) );
}

//

function pathCurrentAct()
{
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  {
    var path = arguments[ 0 ];
    process.chdir( path );
  }

  var result = process.cwd();

  return result;
}

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

encoders[ 'buffer-raw' ] =
{

  onBegin : function( e )
  {
    _.assert( e.transaction.encoding === 'buffer-raw' );
    e.transaction.encoding = 'buffer-node';
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
  // protocols : [ 'file','hd' ],
  originPath : 'file://',
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
  protocols : [ 'file','hd' ],
}

// --
// prototype
// --

var Proto =
{

  // inter

  init : init,


  // adapter

  _pathNativizeWindows : _pathNativizeWindows,
  _pathNativizeUnix : _pathNativizeUnix,


  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : fileReadStreamAct,
  fileStatAct : fileStatAct,
  // fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,


  // write

  fileWriteStreamAct : fileWriteStreamAct,

  fileWriteAct : fileWriteAct,

  fileDeleteAct : fileDeleteAct,
  // fileDelete : fileDelete,

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMakeAct : directoryMakeAct,
  // directoryMake : directoryMake,

  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,


  // path

  pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  pathCurrentAct : pathCurrentAct,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

if( process.platform === 'win32' )
Proto.pathNativize = _pathNativizeWindows;
else
Proto.pathNativize = _pathNativizeUnix;

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );
_.FileProvider.Path.mixin( Self );

_.assert( Self.prototype.pathCurrent );

//

if( typeof module !== 'undefined' )
if( !_.FileProvider.Default )
{
  _.FileProvider.Default = Self;
  _.fileProvider = new Self();
}

_.FileProvider[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
