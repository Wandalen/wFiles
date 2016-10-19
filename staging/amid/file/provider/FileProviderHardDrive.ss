( function _FileProviderHardDrive_s_() {

'use strict';

// require( './AdvancedMixin.s' );
// require( './Abstract.s' );
// require( '../FileRecord.s' );

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );
  require( '../FilePath.ss' );

  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

  if( !wTools.FileProvider.Abstract )
  require( './Abstract.s' );

  if( !wTools.FileProvider.AdvancedMixin )
  require( './AdvancedMixin.s' );

  var Path = require( 'path' );
  var File = require( 'fs-extra' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

//

var Parent = _.FileProvider.Abstract;
//var DefaultsFor = Parent.DefaultsFor;
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

var init = function( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

// --
// read
// --

var fileReadAct = function( o )
{
  var self = this;
  var con;
  var result = null;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileReadAct,o );

  var encoder = fileReadAct.encoders[ o.encoding ];

  /* begin */

  var handleBegin = function()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,{ transaction : o, encoder : encoder })

  }

  /* end */

  var handleEnd = function( data )
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

  var handleError = function( err )
  {

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

    var err = _.err( err );
    if( o.sync )
    {
      return err;
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

    result = File.readFileSync( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding );

    return handleEnd( result );
  }
  else
  {
    con = new wConsequence();

    File.readFile( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding,function( err,data )
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

var fileStatAct = function( o )
{
  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( _.strIs( o.pathFile ) );
  var o = _.routineOptions( fileStatAct,o );

  var result = null;

  // _.assert( arguments.length === 1 );
  // _.assert( _.strIs( filePath ) );

  if( o.sync )
  {
    try
    {
      result = File.statSync( o.pathFile );
    }
    catch ( err ) { }
    return result;
  }
  else
  {
    var con = new wConsequence();
    File.stat( o.pathFile, function( err, stats )
    {
      if( err )
      con.give( null, null );
      else
      con.give( err, stats );
    });
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
    var result=null;
    var self = this;

    if( _.strIs( o ) )
    o = { pathFile : o };

    _.routineOptions( fileHashAct,o );
    _.assert( _.strIs( o.pathFile ) );
    _.assert( arguments.length === 1 );

    /* */

    if( !crypto )
    crypto = require( 'crypto' );
    var md5sum = crypto.createHash( 'md5' );

    /* */

    if( o.sync )
    {

      if( !self.fileIsTerminal( o.pathFile ) ) return result;
      try
      {
        var read = File.readFileSync( o.pathFile );
        md5sum.update( read );
        result = md5sum.digest( 'hex' );
      }
      catch( err )
      {
        return NaN;
      }

      return result;

    }
    else
    {

      // throw _.err( 'not tested' );

      var result = new wConsequence();
      var stream = File.ReadStream( o.pathFile );

      stream.on( 'data', function( d )
      {
        md5sum.update( d );
      });

      stream.on( 'end', function()
      {
        var hash = md5sum.digest( 'hex' );
        result.give( hash );
      });

      stream.on( 'error', function( err )
      {
        // result.error( _.err( err ) );
        result.give( null );
      });

      return result;
    }

  }

})();

fileHashAct.defaults = {};
fileHashAct.defaults.__proto__ = Parent.prototype.fileHashAct.defaults;

//

var directoryReadAct = function( o )
{

  if( _.strIs( o ) )
  o =
  {
    pathFile : arguments[ 0 ],
  }

  _.assert( arguments.length === 1 );
  _.routineOptions( directoryReadAct,o );

  var result;

  if( o.sync )
  {

    if( File.existsSync( o.pathFile ) )
    {
      var stat = File.statSync( o.pathFile );
      if( stat.isDirectory() )
      {
        result = File.readdirSync( o.pathFile );
        _.assert( _.arrayIs( result ),'readdirSync returned not array' );
      }
      else
      {
        result = [ _.pathName( o.pathFile, { withExtension : true } ) ];
        return result;
      }
    }
    else
    {
      result = [];
    }

    result.sort( function( a, b )
    {
      a = a.toLowerCase();
      b = b.toLowerCase();
      if( a < b ) return -1;
      if( a > b ) return +1;
      return 0;
    });

    return result;
  }
  else
  {
    // throw _.err( 'not implemented' );
    var con = new wConsequence();
    File.exists( o.pathFile,function ( exists )
    {
      if( exists )
      {
        File.stat( o.pathFile, function ( err, stat )
        {
          if( err )
          return con.error( _.err( err ) );

          if( stat.isDirectory() )
          {
            File.readdir( o.pathFile, function ( err, files )
            {
              if( err )
              return con.error( _.err( err ) );

              result = files;
              _.assert( _.arrayIs( result ),'readdirSync returned not array' );
              result.sort( function( a, b )
              {
                a = a.toLowerCase();
                b = b.toLowerCase();
                if( a < b ) return -1;
                if( a > b ) return +1;
                return 0;
              });
              con.give( result );
            });
          }
          else
          {
            result = [ _.pathName( o.pathFile, { withExtension : true } ) ];
            con.give( result );
          }
        });
      }
      else
      {
        result = [];
        con.give( result );
      }
    });

    return con;
  }

  // if( _.strIs( o ) )
  // o =
  // {
  //   pathFile : arguments[ 0 ],
  // }
  //
  // _.assert( arguments.length === 1 );
  // _.routineOptions( directoryReadAct,o );
  //
  // if( o.sync )
  // {
  //   var result = File.readdirSync( o.pathFile );
  //   return result
  // }
  // else
  // {
  //   throw _.err( 'not implemented' );
  // }
  //
  // return result;

}

directoryReadAct.defaults = {};
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

// //
//
//   /**
//    * Returns array of files names if `pathFile` is directory, or array with one pathFile element if `pathFile` is not
//    * directory, but exists. Otherwise returns empty array.
//    * @example
//    * wTools.filesList('sample/tmp');
//    * @param {string} pathFile path string
//    * @returns {string[]}
//    * @method filesList
//    * @memberof wTools
//    */
//
// var filesList = function filesList( o )
// {
//
//   if( _.strIs( o ) )
//   o =
//   {
//     pathFile : arguments[ 0 ],
//   }
//
//   _.assert( arguments.length === 1 );
//   _.routineOptions( directoryReadAct,o );
//
//   var result;
//
//   if( File.existsSync( o.pathFile ) )
//   {
//     var stat = File.statSync( o.pathFile );
//     if( stat.isDirectory() )
//     {
//       result = File.readdirSync( o.pathFile );
//     }
//     else
//     {
//       result = [ _.pathName( o.pathFile, { withExtension : true } ) ];
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

var fileWriteAct = function( o )
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

  _.routineOptions( fileWriteAct,o );
  _.assert( _.strIs( o.pathFile ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  /* o.data */

  if( _.bufferIs( o.data ) )
  {
    o.data = _.bufferToNodeBuffer( o.data );
  }

  _.assert( _.strIs( o.data ) || _.bufferNodeIs( o.data ),'expects string or node buffer, but got',_.strTypeOf( o.data ) );

  // /* rewriting */
  //
  // if( o.rewriting )
  // {
  //   debugger;
  //   throw _.err( 'not tested' );
  //   self.fileDelete( o.pathFile );
  //     //File.unlinkSync( o.pathFile );
  // }

  /* write */

  if( o.sync )
  {

    // log();

    // if( o.silentError ) try
    // {
    //   if( o.append )
    //   File.appendFileSync( o.pathFile, o.data );
    //   else
    //   File.writeFileSync( o.pathFile, o.data );
    // }
    // catch( err ){}
    // else
    // {
      if( o.writeMode === 'rewrite' )
      File.writeFileSync( o.pathFile, o.data );
      else if( o.writeMode === 'append' )
      File.appendFileSync( o.pathFile, o.data );
      else if( o.writeMode === 'prepend' )
      {
        var data;
        try
        {
          data = File.readFileSync( o.pathFile )
        }
        catch ( err ){ }

        if( data )
        o.data = o.data.concat( data )
        File.writeFileSync( o.pathFile, o.data );
      }
      else throw _.err( 'not implemented write mode',o.writeMode );
    // }

  }
  else
  {
    var con = wConsequence();

    var handleEnd = function( err )
    {
      // log();
      //if( err && !o.silentError )
      if( err )
      err = _.err( err );
      con.give( err,null );
    }

    if( o.writeMode === 'rewrite' )
    File.writeFile( o.pathFile, o.data, handleEnd );
    else if( o.writeMode === 'append' )
    File.appendFile( o.pathFile, o.data, handleEnd );
    else if( o.writeMode === 'prepend' )
    {
      File.readFile( o.pathFile, function( err,data )
      {
        if( err )
        return handleEnd( err );
        o.data = o.data.concat( data );
        File.writeFile( o.pathFile, o.data, handleEnd );
      });

    }
    else handleEnd( _.err( 'not implemented write mode',o.writeMode ) );

    // if( o.append )
    // File.appendFile( o.pathFile, o.data, handleEnd );
    // else
    // File.writeFile( o.pathFile, o.data, handleEnd );

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

  var fileProvider = _.FileProvider.def();

   var path = 'tmp/fileSize/data',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   delOptions =
  {
     pathFile : path,
     sync : 0
   };

   fileProvider.fileWrite( { pathFile : path, data : textData } ); // create test file

   console.log( fs.existsSync( path ) ); // true (file exists)
   var con = fileProvider.fileDelete( delOptions );

   con.got( function(err)
   {
     console.log( fs.existsSync( path ) ); // false (file does not exist)
   } );

 * @param {string|Object} o - options object.
 * @param {string} o.pathFile path to file/directory for deleting.
 * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
    content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
 * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 1.
 * @throws {Error} If pathFile is not string.
 * @throws {Error} If options object has unexpected property.
 * @method fileDeleteAct
 * @memberof wTools
 */

var fileDeleteAct = function( o )
{

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );
  var self = this;
  var stat;

  var handleError = function ( err )
  {
    var err = _.err( err );
    if( o.sync )
    {
      throw err;
    }
    var con = new wConsequence();
    return con.error( err );
  }
  var stat = self.fileStatAct( o.pathFile );

  // try
  // {
  //   var stat = self.fileStatAct( o.pathFile );
  // }
  // catch( err )
  // {
  //   return handleError( err );
  // }

  if( stat && stat.isSymbolicLink() )
  {
    debugger;
    return handleError( _.err( 'not tested' ) );
  }

  if( o.sync )
  {

    if( stat && stat.isDirectory() )
    File.rmdirSync( o.pathFile );
    else
    File.unlinkSync( o.pathFile );

  }
  else
  {
    var con = new wConsequence();

    if( stat && stat.isDirectory() )
    File.rmdir( o.pathFile,function( err,data ){ con.give( err,data ) } );
    else
    File.unlink( o.pathFile,function( err,data ){ con.give( err,data ) } );

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

  var fileProvider = _.FileProvider.def();

   var path = 'tmp/fileSize/data',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   delOptions =
  {
     pathFile : path,
     sync : 0
   };

   fileProvider.fileWrite( { pathFile : path, data : textData } ); // create test file

   console.log( fs.existsSync( path ) ); // true (file exists)
   var con = fileProvider.fileDelete( delOptions );

   con.got( function(err)
   {
     console.log( fs.existsSync( path ) ); // false (file does not exist)
   } );

 * @param {string|Object} o - options object.
 * @param {string} o.pathFile path to file/directory for deleting.
 * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
    content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
 * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 1.
 * @throws {Error} If pathFile is not string.
 * @throws {Error} If options object has unexpected property.
 * @method fileDelete
 * @memberof wTools
 */

var fileDelete = function( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( fileDelete,o );
  var optionsAct = _.mapScreen( self.fileDeleteAct.defaults,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

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
      File.removeSync( o.pathFile );
    }

  }
  else
  {
    var con = new wConsequence();

    if( !o.force )
    {
      self.fileDeleteAct( optionsAct ).thenDo( con );
    }
    else
    {
      File.remove( o.pathFile,function( err ){ con.give( err ) } );
    }

    return con;
  }

}

fileDelete.defaults = {}
fileDelete.defaults.__proto__ = Parent.prototype.fileDelete.defaults;

//

var fileCopyAct = function( o )
{

  if( arguments.length === 2 )
  o =
  {
    dst : arguments[ 0 ],
    src : arguments[ 1 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileCopyAct,o );

  if( o.sync )
  {
    File.copySync( o.src, o.dst );
  }
  else
  {
    var con = new wConsequence();
    File.copy( o.src, o.dst, function( err, data )
    {
      //if( err )
      con._giveWithError( err, data );
    });
    return con;
  }

}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;

//

var fileRenameAct = function( o )
{

  if( arguments.length === 2 )
  o =
  {
    dst : arguments[ 0 ],
    src : arguments[ 1 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( fileRenameAct,o );

  if( o.sync )
  {
    File.renameSync( o.src, o.dst );
  }
  else
  {
    var con = new wConsequence();
    File.rename( o.src, o.dst, function( err,data )
    {
      //if( err )
      con._giveWithError( err,data );
    } );
    return con;
  }

}

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Parent.prototype.fileRenameAct.defaults;

//

var fileTimeSetAct = function( o )
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

var directoryMakeAct = function( o )
{

  if( _.strIs( o ) )
  o =
  {
    pathFile : arguments[ 0 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( directoryMakeAct,o );

  var stat;

  if( o.sync )
  {

    // if( o.force )
    // {
    //   var stat = _.fileStatAct( o.pathFile );
    //   if( stat && !stat.isDirectory() )
    //   {
    //     File.unlinkSync( o.pathFile );
    //   }
    // }

    File.mkdirSync( o.pathFile );

  }
  else
  {
    // var con = new wConsequence().give();
    var con = new wConsequence();

    // throw _.err( 'not tested' );

    // if( o.force )
    // {
    //   var stat = _.fileStatAct( o.pathFile );
    //   if( stat && !stat.isDirectory() )
    //   {
    //     File.unlink( o.pathFile, function( err ) {
    //       con.give( err,null );
    //     });
    //   }
    // }

    // con.ifNoErrorThen( function( data ) {
    //
    //   File.mkdir( o.pathFile, function( err, data )
    //   {
    //     con.give( err, data );
    //   } );
    //
    // });
    File.mkdir( o.pathFile, function( err, data ){ con.give( err, data ); } );

    return con;
  }

}

directoryMakeAct.defaults = {};
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;

//

// !!! shout it rewrite files?

var directoryMake = function( o )
{

  if( _.strIs( o ) )
  o =
  {
    pathFile : arguments[ 0 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.routineOptions( directoryMake,o );

  var stat;

  if( o.sync )
  {

    if( o.force )
    File.mkdirsSync( o.pathFile );
    else
    File.mkdirSync( o.pathFile );

  }
  else
  {
    var con = new wConsequence().give();

    throw _.err( 'not tested' );

    if( o.force )
    con.ifNoErrorThen( function( data ) {

      File.mkdirs( o.pathFile, function( err, data )
      {
        con.give( err, data );
      });

    });

    else
    con.ifNoErrorThen( function( data ) {

      File.mkdir( o.pathFile, function( err, data )
      {
        con.give( err, data );
      });

    });


    return con;
  }

}

directoryMake.defaults = Parent.prototype.directoryMake.defaults;

//

var linkSoftAct = function linkSoftAct( o )
{
  var self = this;
  o = self._linkBegin( linkSoftAct,arguments );

  if( o.sync )
  {
    File.symlinkSync( o.pathSrc,o.pathDst );
  }
  else
  {
    // throw _.err( 'not implemented' );
    var con = new wConsequence();
    File.symlink( o.pathSrc, o.pathDst, function ( err )
    {
      if( err )
      return con.error( _.err( err ) );
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

 * var fileProvider = _.FileProvider.def();
 * var path = 'tmp/linkHardAct/data.txt',
   link = 'tmp/linkHardAct/h_link_for_data.txt',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   textData1 = ' Aenean non feugiat mauris';

   fileProvider.fileWrite( { pathFile : path, data : textData } );
   fileProvider.linkHardAct( link, path );

   var content = fileProvider.fileReadSync(link); // Lorem ipsum dolor sit amet, consectetur adipiscing elit.
   console.log(content);
   fileProvider.fileWrite( { pathFile : path, data : textData1, append : 1 } );

   fileProvider.fileDelete( path ); // delete original name

   content = fileProvider.fileReadSync( link );
   console.log( content );
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
 * @method linkHardAct
 * @memberof wTools
 */

var linkHardAct = function linkHardAct( o )
{
  var self = this;

  o = self._linkBegin( linkHardAct,arguments );

  if( o.pathDst === o.pathSrc )
  return true;

  if( !self.fileStat( o.pathSrc ) )
  throw _.err( 'file does not exist',o.pathSrc );

  if( o.sync )
  {

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
  else
  {

    throw _.err( 'not implemented' );

  }

}

linkHardAct.defaults = {};
linkHardAct.defaults.__proto__ = Parent.prototype.linkHardAct.defaults;

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

    _.assert( _.bufferNodeIs( e.data ) );
    _.assert( !_.bufferIs( e.data ) );
    _.assert( !_.bufferRawIs( e.data ) );

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


  // read

  fileReadAct : fileReadAct,
  fileStatAct : fileStatAct,
  fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,


  // write

  fileWriteAct : fileWriteAct,

  fileDeleteAct : fileDeleteAct,
  fileDelete : fileDelete,

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMakeAct : directoryMakeAct,
  directoryMake: directoryMake,

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

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.AdvancedMixin.mixin( Self );

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.HardDrive = Self;

if( typeof module !== 'undefined' )
if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
