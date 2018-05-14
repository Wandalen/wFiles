( function _HardDrive_ss_() {

'use strict'; /*qqq*/

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
// path
// --

function _pathNativizeWindows( filePath )
{
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
  _.assert( _.strIs( filePath ) );
  return filePath;
}

//

var pathNativize = process.platform === 'win32' ? _pathNativizeWindows : _pathNativizeUnix;

//

var _pathResolveTextLinkAct = ( function()
{
  var buffer;

  return function _pathResolveTextLinkAct( path,visited,hasLink,allowNotExisting )
  {

    if( !buffer )
    buffer = new Buffer( 512 );

    if( visited.indexOf( path ) !== -1 )
    throw _.err( 'cyclic text link :',path );
    visited.push( path );

    var regexp = /link ([^\n]+)\n?$/;

    path = _.pathNormalize( path );
    var exists = _.fileProvider.fileStat({ filePath : path, resolvingTextLink : 0 });

    var prefix,parts;
    if( path[ 0 ] === '/' )
    {
      prefix = '/';
      parts = path.substr( 1 ).split( '/' );
    }
    else
    {
      prefix = '';
      parts = path.split( '/' );
    }

    for( var p = exists ? p = parts.length-1 : 0 ; p < parts.length ; p++ )
    {

      var cpath = _.fileProvider.pathNativize( prefix + parts.slice( 0,p+1 ).join( '/' ) );

      var stat = _.fileProvider.fileStat({ filePath : cpath, resolvingTextLink : 0 });
      if( !stat )
      {
        if( allowNotExisting )
        return path;
        else
        return false;
      }

      if( stat.isFile() )
      {

        var size = stat.size;
        var readSize = 256;
        var f = File.openSync( cpath, 'r' );
        do
        {

          readSize *= 2;
          readSize = Math.min( readSize,size );
          if( buffer.length < readSize )
          buffer = new Buffer( readSize );
          File.readSync( f,buffer,0,readSize,0 );
          var read = buffer.toString( 'utf8',0,readSize );
          var m = read.match( regexp );

        }
        while( m && readSize < size );
        File.close( f );

        if( m )
        hasLink = true;

        if( !m )
        if( p !== parts.length-1 )
        return false;
        else
        return hasLink ? path : false;

        var path = _.pathJoin( m[ 1 ],parts.slice( p+1 ).join( '/' ) );

        if( path[ 0 ] === '.' )
        path = _.pathReroot( cpath , '..' , path );

        var result = _pathResolveTextLinkAct( path,visited,hasLink,allowNotExisting );
        if( hasLink )
        {
          if( !result )
          {
            debugger;
            throw _.err
            (
              'cant resolve : ' + visited[ 0 ] +
              '\nnot found : ' + ( m ? m[ 1 ] : path ) +
              '\nlooked at :\n' + ( visited.join( '\n' ) )
            );
          }
          else
          return result;
        }
        else
        {
          throw _.err( 'not expected' );
          return result;
        }
      }

    }

    return hasLink ? path : false;
  }

})();

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
        throwing : 1,
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

// debugger;
// _.timeOut( 15000,function()
// {
//   debugger;
//   _.beep();
// });

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

  // if( _.strHas( o.filePath,'.eheader' ) )
  // debugger;

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
      // debugger;
      if( err )
      return con.error(  _.err( err ) );
      return con.give( o );
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

  var stat = self.fileStatAct
  ({
    filePath : o.filePath,
    resolvingSoftLink : 0
  });

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

function linkSoftAct( o )
{
  var self = this;

  o = self._linkPre( linkSoftAct,arguments );

  _.assert( _.pathIsAbsolute( _.pathNormalize( o.dstPath ) ) );

  _.assert( o.type === null || o.type === 'dir' ||  o.type === 'file' );

  var type;

  if( process.platform === 'win32' )
  {
    var srcStat = self.fileStatAct({ filePath : o.srcPath });

    if( srcStat )
    type = srcStat.isDirectory() ? 'dir' : 'file';

    if( !type && o.type )
    type = o.type;

    if( _.strBegins( o.srcPath, '.\\' ) )
    o.srcPath = _.strCutOffLeft( o.srcPath,'.\\' )[ 2 ];
    if( _.strBegins( o.srcPath, '..' ) )
    o.srcPath = '.' + _.strCutOffLeft( o.srcPath,'..' )[ 2 ];
  }

  /* */

  if( o.sync )
  {
    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkSoftAct', o.dstPath,'already exists' );

    // qqq
    if( process.platform === 'win32' )
    {
      File.symlinkSync( o.srcPath, o.dstPath, type );
    }
    else
    {
      File.symlinkSync( o.srcPath, o.dstPath );
    }

    // qqq
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

      function onSymlink( err )
      {
        con.give( err, null )
      }

      if( process.platform === 'win32' )
      File.symlink( o.srcPath, o.dstPath, type, onSymlink );
      else
      File.symlink( o.srcPath, o.dstPath, onSymlink );
    })

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

  o = self._linkPre( linkHardAct,arguments );

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

// --
// encoders
// --

var encoders = {};

encoders[ 'buffer-raw' ] =
{

  onBegin : function( e )
  {
    debugger;
    _.assert( e.transaction.encoding === 'buffer-raw' );
    e.transaction.encoding = 'buffer-node';
  },

  onEnd : function( e )
  {
    debugger;
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

//

encoders[ 'node.js' ] =
{

  exts : [ 'js','s','ss' ],

  onBegin : function( e )
  {
    e.transaction.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    return require( _.fileProvider.pathNativize( e.transaction.filePath ) );
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
  _pathNativizeWindows : _pathNativizeWindows,
  _pathNativizeUnix : _pathNativizeUnix,
  pathNativize : pathNativize,
  protocols : [ 'file','hd' ],
}

// --
// prototype
// --

var Proto =
{

  // inter

  init : init,


  // path

  _pathNativizeWindows : _pathNativizeWindows,
  _pathNativizeUnix : _pathNativizeUnix,
  pathNativize : pathNativize,

  _pathResolveTextLinkAct : _pathResolveTextLinkAct,

  pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  pathCurrentAct : pathCurrentAct,


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

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMakeAct : directoryMakeAct,

  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );

_.assert( Self.prototype.pathCurrent );

//

if( typeof module !== 'undefined' )
if( !_.FileProvider.Default )
{
  _.FileProvider.Default = Self;
  if( !_.fileProvider )
  _.fileProvider = new Self();
}

// --
// export
// --

_.FileProvider[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
