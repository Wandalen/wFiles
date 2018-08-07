( function _HardDrive_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _global = _global_; var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

  var File = require( 'fs-extra' );
  var FileDefault = require( 'fs' );

}

var _global = _global_; var _ = _global_.wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Partial;
var Self = function wFileProviderHardDrive( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'HardDrive';

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
  {
    result = result[ 1 ] + ':' + _.strPrependOnce( result.substring( 2 ), '\\' );
  }

  return result;
}

//

function _pathNativizeUnix( filePath )
{
  _.assert( _.strIs( filePath ) );
  return filePath;
}

//

var nativize = process.platform === 'win32' ? _pathNativizeWindows : _pathNativizeUnix;

//

function currentAct()
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

    path = _.path.normalize( path );
    var exists = _.fileProvider.fileStat({ filePath : path, resolvingTextLink : 0 }); /*qqq*/

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

      var cpath = _.fileProvider.nativize( prefix + parts.slice( 0,p+1 ).join( '/' ) );

      var stat = _.fileProvider.fileStat({ filePath : cpath, resolvingTextLink : 0 }); /* qqq */
      if( !stat )
      {
        if( allowNotExisting )
        return path;
        else
        return false;
      }

      if( stat.isFile() )
      {

        var size = Number( stat.size );
        var readSize = _.bigIntIs( size ) ? BigInt( 256 ) : 256;
        var f = File.openSync( cpath, 'r' );
        do
        {

          readSize *= _.bigIntIs( size ) ? BigInt( 2 ) : 2;
          // console.log( 'size', _.bigIntIs( size ), size )
          // console.log( 'readSize', _.bigIntIs( readSize ), readSize )
          readSize = readSize < size ? readSize : size;
          if( buffer.length < readSize )
          buffer = new Buffer( readSize );
          File.readSync( f, buffer, 0, readSize, 0 );
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

        var path = _.path.join( m[ 1 ],parts.slice( p+1 ).join( '/' ) );

        if( path[ 0 ] === '.' )
        path = _.path.reroot( cpath , '..' , path );

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

function resolveSoftLinkAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.path.isAbsolute( o.filePath ) );

  /* using self.resolvingSoftLink causes recursion problem in resolveLink */
  if( !self.fileIsSoftLink( o.filePath ) )
  return o.filePath;

  return File.realpathSync( self.nativize( o.filePath ) );
}

var defaults = resolveSoftLinkAct.defaults = Object.create( Parent.prototype.resolveSoftLinkAct.defaults );
var paths = resolveSoftLinkAct.paths = Object.create( Parent.prototype.resolveSoftLinkAct.paths );
var having = resolveSoftLinkAct.having = Object.create( Parent.prototype.resolveSoftLinkAct.having );

// --
// read
// --

function fileReadAct( o )
{
  var self = this;
  var con;
  var stack = '';
  var result = null;

  _.assertRoutineOptions( fileReadAct,arguments );
  _.assert( self.isNormalized( o.filePath ) );

  var filePath = self.nativize( o.filePath );

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
      console.error( err.toString() + '\n' + err.stack );
    }

    if( o.sync )
    throw err;
    else
    return con.error( _.err( err ) );

  }

  /* exec */

  handleBegin();

  // if( _.strHas( o.filePath, 'icons.woff2' ) )
  // debugger;

  if( !o.resolvingSoftLink && self.fileIsSoftLink( o.filePath ) )
  {
    var err = _.err( 'fileReadAct: Reading from soft link is not allowed when "resolvingSoftLink" is disabled' );
    return handleError( err );
  }

  if( o.sync )
  {
    try
    {
      result = File.readFileSync( filePath,{ encoding : self._encodingFor( o.encoding ) } );
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

    File.readFile( filePath, { encoding : self._encodingFor( o.encoding ) }, function( err,data )
    {

      if( err )
      return handleError( err );
      else
      return handleEnd( data );

    });

    return con;
  }

}

var defaults = fileReadAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );
var paths = fileReadAct.paths = Object.create( Parent.prototype.fileReadAct.paths );
var having = fileReadAct.having = Object.create( Parent.prototype.fileReadAct.having );

//

function fileReadStreamAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileReadStreamAct,arguments );

  var filePath = o.filePath;
  o.filePath = self.nativize( o.filePath );

  try
  {
    return File.createReadStream( o.filePath,{ encoding : o.encoding } );
  }
  catch( err )
  {
    throw _.err( err );
  }

}

var defaults = fileReadStreamAct.defaults = Object.create( Parent.prototype.fileReadStreamAct.defaults );
var paths = fileReadStreamAct.paths = Object.create( Parent.prototype.fileReadStreamAct.paths );
var having = fileReadStreamAct.having = Object.create( Parent.prototype.fileReadStreamAct.having );

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

//     _.assertRoutineOptions( fileHashAct,o );
//     _.assert( _.strIs( o.filePath ) );
//     _.assert( arguments.length === 1, 'expects single argument' );

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
  var result = null;

  _.assertRoutineOptions( directoryReadAct,arguments );
  var filePath = o.filePath;
  o.filePath = self.nativize( o.filePath );

  /* sort */

  function handleEnd( result ) /* qqq */
  {
    // for( var r = 0 ; r < result.length ; r++ )
    // result[ r ] = _.path.refine( result[ r ] ); // output should be covered by test !!!
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
      var stat = self.fileStatAct
      ({
        filePath : filePath,
        throwing : 1,
        sync : 1,
        resolvingSoftLink : 1,
      });
      if( stat.isDirectory() )
      {
        result = File.readdirSync( o.filePath );
        handleEnd( result );
      }
      else
      {
        result = [ _.path.name({ path : filePath, withExtension : 1 }) ];
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

    self.fileStatAct
    ({
      filePath : filePath,
      sync : 0,
      resolvingSoftLink : 1,
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
        result = [ _.path.name({ path : filePath, withExtension : 1 }) ];
        con.give( result );
      }
    });

    return con;
  }

}

var defaults = directoryReadAct.defaults = Object.create( Parent.prototype.directoryReadAct.defaults );
var having = directoryReadAct.having = Object.create( Parent.prototype.directoryReadAct.having );

// --
// read stat
// --

function fileStatAct( o )
{
  var self = this;
  var result = null;

  _.assert( self.isAbsolute( o.filePath ),'expects absolute {-o.FilePath-}, but got', o.filePath );
  _.assertRoutineOptions( fileStatAct,arguments );

  o.filePath = self.nativize( o.filePath );

  var args = [ o.filePath ];

  if( self.usingBigIntForStat )
  args.push( { bigint : true } );

  /* */

  if( o.sync )
  {
    try
    {
      if( o.resolvingSoftLink )
      result = FileDefault.statSync.apply( FileDefault, args );
      else
      result = FileDefault.lstatSync.apply( FileDefault,args );
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

    args.push( handleEnd );

    if( o.resolvingSoftLink )
    FileDefault.stat.apply( FileDefault, args );
    else
    FileDefault.lstat.apply( FileDefault, args );

    return con;
  }

}

var defaults = fileStatAct.defaults = Object.create( Parent.prototype.fileStatAct.defaults );
var having = fileStatAct.having = Object.create( Parent.prototype.fileStatAct.having );


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

function fileWriteAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileWriteAct,arguments );
  _.assert( _.strIs( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  /* data conversion */

  if( _.bufferTypedIs( o.data ) || _.bufferRawIs( o.data ) )
  o.data = _.bufferToNodeBuffer( o.data );

  _.assert( _.strIs( o.data ) || _.bufferNodeIs( o.data ),'expects string or node buffer, but got',_.strTypeOf( o.data ) );

  /* write */

  if( o.sync )
  {

      // if( _.strHas( o.filePath, 'icons.woff2' ) )
      // debugger;

      if( o.writeMode === 'rewrite' )
      File.writeFileSync( o.filePath, o.data, { encoding : self._encodingFor( self.encoding ) } );
      else if( o.writeMode === 'append' )
      File.appendFileSync( o.filePath, o.data, { encoding : self._encodingFor( self.encoding ) } );
      else if( o.writeMode === 'prepend' )
      {
        var data;
        try
        {
          data = File.readFileSync( o.filePath, { encoding : self._encodingFor( self.encoding ) } )
        }
        catch( err ){ }
        if( data )
        o.data = o.data.concat( data )
        File.writeFileSync( o.filePath, o.data, { encoding : self._encodingFor( self.encoding ) } );
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
      return con.give( o );
    }

    if( o.writeMode === 'rewrite' )
    File.writeFile( o.filePath, o.data, { encoding : self._encodingFor( self.encoding ) }, handleEnd );
    else if( o.writeMode === 'append' )
    File.appendFile( o.filePath, o.data, { encoding : self._encodingFor( self.encoding ) }, handleEnd );
    else if( o.writeMode === 'prepend' )
    {
      File.readFile( o.filePath, { encoding : self._encodingFor( self.encoding ) }, function( err,data )
      {
        if( data )
        o.data = o.data.concat( data );
        File.writeFile( o.filePath, o.data, { encoding : self._encodingFor( self.encoding ) }, handleEnd );
      });

    }
    else handleEnd( _.err( 'not implemented write mode',o.writeMode ) );

    return con;
  }

}

var defaults = fileWriteAct.defaults = Object.create( Parent.prototype.fileWriteAct.defaults );
var having = fileWriteAct.having = Object.create( Parent.prototype.fileWriteAct.having );

//

function fileWriteStreamAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileWriteStreamAct, arguments );

  var filePath = o.filePath;

  o.filePath = self.nativize( o.filePath );

  try
  {
    return File.createWriteStream( o.filePath );
  }
  catch( err )
  {
    throw _.err( err );
  }
}

var defaults = fileWriteStreamAct.defaults = Object.create( Parent.prototype.fileWriteStreamAct.defaults );
var having = fileWriteStreamAct.having = Object.create( Parent.prototype.fileWriteStreamAct.having );

//

function fileTimeSetAct( o )
{
  _.assertRoutineOptions( fileTimeSetAct,arguments );

  // File.utimesSync( o.filePath, o.atime, o.mtime );

  var flags = process.platform === 'win32' ? 'r+' : 'r';
  var descriptor = File.openSync( o.filePath, flags );
  File.futimesSync( descriptor, o.atime, o.mtime );
  File.closeSync( descriptor );

}

var defaults = fileTimeSetAct.defaults = Object.create( Parent.prototype.fileTimeSetAct.defaults );
var having = fileTimeSetAct.having = Object.create( Parent.prototype.fileTimeSetAct.having );

//

/**
 * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
 * @example
 * var FileDefault = require( 'fs' );

  var fileProvider = _.FileProvider.Default();

   var path = 'tmp/fileSize/data',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   delOptions =
  {
     filePath : path,
     sync : 0
   };

   fileProvider.fileWrite( { filePath : path, data : textData } ); // create test file

   console.log( FileDefault.existsSync( path ) ); // true (file exists)
   var con = fileProvider.fileDelete( delOptions );

   con.got( function(err)
   {
     console.log( FileDefault.existsSync( path ) ); // false (file does not exist)
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

  _.assertRoutineOptions( fileDeleteAct,arguments );
  _.assert( _.path.isAbsolute( o.filePath ) );

  var filePath = o.filePath;

  o.filePath = self.nativize( o.filePath );

  /* qqq : sync is not accounted */
  /* qqq : is it needed */

  if( o.sync )
  {
    var stat = self.fileStatAct
    ({
      filePath : filePath,
      resolvingSoftLink : 0,
      sync : 1,
      throwing : 0,
    });

    if( stat && stat.isDirectory() )
    File.rmdirSync( o.filePath  );
    else
    File.unlinkSync( o.filePath  );

  }
  else
  {
    var con = self.fileStatAct
    ({
      filePath : filePath,
      resolvingSoftLink : 0,
      sync : 0,
      throwing : 0,
    });
    con.got( ( err, stat ) =>
    {
      if( err )
      return con.error( err );

      if( stat && stat.isDirectory() )
      File.rmdir( o.filePath,function( err,data ){ con.give( err,data ) } );
      else
      File.unlink( o.filePath,function( err,data ){ con.give( err,data ) } );
    })

    return con;
  }

}

var defaults = fileDeleteAct.defaults = Object.create( Parent.prototype.fileDeleteAct.defaults );
var having = fileDeleteAct.having = Object.create( Parent.prototype.fileDeleteAct.having );

//

function directoryMakeAct( o )
{
  var self = this;

  _.assertRoutineOptions( directoryMakeAct,arguments );
  // _.assert( self.fileStatAct( _.path.dir( o.filePath ) ), 'Directory for directory does not exist :\n' + _.strQuote( o.filePath ) ); /* qqq */

  if( o.sync )
  {

    try
    {
      File.mkdirSync( o.filePath );
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

    File.mkdir( o.filePath, function( err, data ){ con.give( err, data ); } );

    return con;
  }

}

var defaults = directoryMakeAct.defaults = Object.create( Parent.prototype.directoryMakeAct.defaults );
var having = directoryMakeAct.having = Object.create( Parent.prototype.directoryMakeAct.having );

//

function fileRenameAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileRenameAct,arguments );

  o.dstPath = self.nativize( o.dstPath );
  o.srcPath = self.nativize( o.srcPath );

  _.assert( !!o.dstPath );
  _.assert( !!o.srcPath );

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

var defaults = fileRenameAct.defaults = Object.create( Parent.prototype.fileRenameAct.defaults );
var paths = fileRenameAct.paths = Object.create( Parent.prototype.fileRenameAct.paths );
var having = fileRenameAct.having = Object.create( Parent.prototype.fileRenameAct.having );

_.assert( defaults.originalDstPath !== undefined );

//

function fileCopyAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileCopyAct,arguments );

  if( !self.fileIsTerminal( o.srcPath ) )
  {
    var err = _.err( o.srcPath,' is not a terminal file!' );
    if( o.sync )
    throw err;
    return new _.Consequence().error( err );
  }

  if( o.breakingDstHardLink && self.fileIsHardLink( o.dstPath ) )
  self.hardLinkBreak({ filePath : o.dstPath, sync : 1 });

  o.dstPath = self.nativize( o.dstPath );
  o.srcPath = self.nativize( o.srcPath );

  _.assert( !!o.dstPath );
  _.assert( !!o.srcPath );

  /* */

  if( o.sync )
  {
    // File.copySync( o.srcPath, o.dstPath );
    File.copyFileSync( o.srcPath, o.dstPath );
  }
  else
  {
    var con = new _.Consequence().give();
    var readCon = new _.Consequence();
    var writeCon = new _.Consequence();

    con.andThen( [ readCon, writeCon ] );

    con.ifNoErrorThen( ( got ) =>
    {
      var errs = got.filter( ( result ) => _.errIs( result ) );

      if( errs.length )
      throw _.err.apply( _, errs );
    })

    // File.copyFile( o.srcPath, o.dstPath, function( err, data )
    // {
    //   con.give( err, data );
    // });

    var readStream = self.fileReadStreamAct({ filePath : o.srcPath, encoding : self.encoding });

    readStream.on( 'error', ( err ) =>
    {
      readCon.give( _.err( err ) );
    })

    readStream.on( 'end', () =>
    {
      readCon.give();
    })

    var writeStream = self.fileWriteStreamAct({ filePath : o.dstPath });

    writeStream.on( 'error', ( err ) =>
    {
      writeCon.give( _.err( err ) );
    })

    writeStream.on( 'finish', () =>
    {
      writeCon.give();
    })

    readStream.pipe( writeStream );

    return con;
  }

}

var defaults = fileCopyAct.defaults = Object.create( Parent.prototype.fileCopyAct.defaults );
var having = fileCopyAct.having = Object.create( Parent.prototype.fileCopyAct.having );

//

function linkSoftAct( o )
{
  var self = this;

  _.assertMapHasAll( o,linkSoftAct.defaults );
  _.assert( _.path.isAbsolute( o.dstPath ) );
  _.assert( self.isNormalized( o.srcPath ) );
  _.assert( self.isNormalized( o.dstPath ) );

  var srcPath =  o.srcPath;
  var dstPath =  o.dstPath;

  o.dstPath = self.nativize( o.dstPath );
  o.srcPath = self.nativize( o.srcPath );

  _.assert( !!o.dstPath );
  _.assert( !!o.srcPath );
  _.assert( o.type === null || o.type === 'dir' ||  o.type === 'file' );

  if( process.platform === 'win32' )
  {
    // var srcStat = self.fileStatAct({ filePath : o.srcPath });

    if( o.type === null )
    {
      /* not dir */
      // if( !_.path.isAbsolute( srcPath ) )
      // srcPath = _.path.resolve( _.path.dir( dstPath ), srcPath );
      if( !_.path.isAbsolute( srcPath ) )
      srcPath = _.path.resolve( dstPath, srcPath );

      var srcStat = self.fileStatAct
      ({
        filePath : srcPath,
        resolvingSoftLink : 1,
        sync : 1,
        throwing : 0,
      });

      if( srcStat )
      o.type = srcStat.isDirectory() ? 'dir' : 'file';

    }

    // Object {dstPath: "C:\path\builder", srcPath: "..\..\..\app\builder", sync: 1, type: null}
    // if( o.type === null )
    // o.type = 'dir';

    if( _.strBegins( o.srcPath, '.\\' ) )
    o.srcPath = _.strIsolateBeginOrNone( o.srcPath,'.\\' )[ 2 ];
    if( _.strBegins( o.srcPath, '..' ) )
    o.srcPath = '.' + _.strIsolateBeginOrNone( o.srcPath,'..' )[ 2 ];

  }

  /* */

  if( o.sync )
  {

    // if( self.fileStatAct({ filePath : dstPath, sync : 1, throwing : 0, resolvingSoftLink : 0 }) ) /* qqq */
    // throw _.err( 'linkSoftAct', dstPath,'already exists' );

    // qqq
    debugger;
    if( process.platform === 'win32' )
    {
      File.symlinkSync( o.srcPath, o.dstPath, o.type );
    }
    else
    {
      File.symlinkSync( o.srcPath, o.dstPath );
    }

  }
  else
  {
    // throw _.err( 'not tested' );
    var con = new _.Consequence();
    /* self.fileStatAct
    ({
      filePath : dstPath,
      throwing : 0,
      resolvingSoftLink : 0,
      sync : 0
    })
    .got( function( err, stat )
    {
      if( stat )
      return con.error ( _.err( 'linkSoftAct',dstPath,'already exists' ) );

      function onSymlink( err )
      {
        con.give( err, undefined )
      }

      if( process.platform === 'win32' )
      File.symlink( o.srcPath, o.dstPath, o.type, onSymlink );
      else
      File.symlink( o.srcPath, o.dstPath, onSymlink );
    }) */

    function onSymlink( err )
    {
      con.give( err, undefined )
    }

    if( process.platform === 'win32' )
    File.symlink( o.srcPath, o.dstPath, o.type, onSymlink );
    else
    File.symlink( o.srcPath, o.dstPath, onSymlink );

    return con;
  }

}

var defaults = linkSoftAct.defaults = Object.create( Parent.prototype.linkSoftAct.defaults );
var having = linkSoftAct.having = Object.create( Parent.prototype.linkSoftAct.having );

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

  _.assertRoutineOptions( linkHardAct, arguments );

  var dstPath = o.dstPath;
  var srcPath = o.srcPath;

  o.dstPath = self.nativize( o.dstPath );
  o.srcPath = self.nativize( o.srcPath );

  _.assert( !!o.dstPath );
  _.assert( !!o.srcPath );

  /* */

  if( o.sync )
  {

    if( o.dstPath === o.srcPath )
    return true;

    try
    {

      /* qqq : is needed */
      self.fileStatAct
      ({
        filePath : srcPath,
        throwing : 1,
        sync : 1,
        resolvingSoftLink : 1,
      });

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

    self.fileStatAct
    ({
      filePath : srcPath,
      sync : 0,
      throwing : 1,
      resolvingSoftLink : 1,
    })
    .ifNoErrorThen( function()
    {
      return self.fileStatAct
      ({
        filePath : dstPath,
        sync : 0,
        throwing : 0,
        resolvingSoftLink : 1,
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
        return con.give( err,undefined );
      });
    })

    return con;
  }
}

var defaults = linkHardAct.defaults = Object.create( Parent.prototype.linkHardAct.defaults );
var having = linkHardAct.having = Object.create( Parent.prototype.linkHardAct.having );

// --
// etc
// --

function _encodingFor( encoding )
{
  var self = this;
  var result;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( encoding ) );

  if( encoding === 'buffer-node' )
  // result = 'binary';
  result = undefined;
  else
  result = encoding;

  // if( result === 'binary' )
  // throw _.err( 'not tested' );

  _.assert( _.arrayHas( self.KnownNativeEncodings,result ) );

  return result;
}

//

function _bufferEncodingGet()
{
  var self = this;
  var encoding = 'buffer-node';
  _.assert( self._encodingFor( encoding ) === undefined );
  return encoding;
}

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
    return require( _.fileProvider.nativize( e.transaction.filePath ) );
  },
}

fileReadAct.encoders = encoders;

// --
// relationship
// --

var KnownNativeEncodings = [ undefined,'ascii','base64','binary','hex','ucs2','ucs-2','utf16le','utf-16le','utf8','latin1' ]
var usingBigIntForStat = _.nodeJsIsSameOrNewer( [ 10,5,0 ] );

var Composes =
{
  // originPath : 'file://',
  protocols : _.define.own([ 'file' ]),
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
  nativize : nativize,
  KnownNativeEncodings : KnownNativeEncodings,
  usingBigIntForStat : usingBigIntForStat,
}

// --
// define class
// --

var Proto =
{

  // inter

  init : init,


  // path

  _pathNativizeWindows : _pathNativizeWindows,
  _pathNativizeUnix : _pathNativizeUnix,
  nativize : nativize,

  currentAct : currentAct,

  _pathResolveTextLinkAct : _pathResolveTextLinkAct,

  resolveSoftLinkAct : resolveSoftLinkAct,


  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : fileReadStreamAct,
  // fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,


  // read stat

  fileStatAct : fileStatAct,


  // write

  fileWriteAct : fileWriteAct,
  fileWriteStreamAct : fileWriteStreamAct,
  fileTimeSetAct : fileTimeSetAct,
  fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,


  // link act

  fileRenameAct : fileRenameAct,
  fileCopyAct : fileCopyAct,
  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,


  // etc

  _encodingFor : _encodingFor,
  _bufferEncodingGet : _bufferEncodingGet,


  //


  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );

_.assert( _.routineIs( Self.prototype.current ) );

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

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
