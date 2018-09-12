( function _HardDrive_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var _global = _global_;
  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

  var File = require( 'fs-extra' );
  var FileDefault = require( 'fs' );

}
var _global = _global_;
var _ = _global_.wTools;
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

// function _pathNativizeWindows( filePath )
// {
//   _.assert( _.strIs( filePath ) ) ;
//
//   var result = filePath.replace( /\//g,'\\' );
//
//   if( result[ 0 ] === '\\' )
//   if( result.length === 2 || result[ 2 ] === ':' || result[ 2 ] === '\\' )
//   {
//     result = result[ 1 ] + ':' + _.strPrependOnce( result.substring( 2 ), '\\' );
//   }
//
//   return result;
// }
//
// //
//
// function _pathNativizeUnix( filePath )
// {
//   _.assert( _.strIs( filePath ) );
//   return filePath;
// }

//

var pathNativizeAct = process.platform === 'win32' ? _.path._pathNativizeWindows : _.path._pathNativizeUnix;

_.assert( _.routineIs( pathNativizeAct ) );

//

function pathCurrentAct()
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  {
    var path = self.path.nativize( arguments[ 0 ] );
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
    var self = this;

    if( !buffer )
    buffer = Buffer.alloc( 512 );

    if( visited.indexOf( path ) !== -1 )
    throw _.err( 'cyclic text link :',path );
    visited.push( path );

    var regexp = /link ([^\n]+)\n?$/;

    path = self.path.normalize( path );
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

      var cpath = _.fileProvider.path.nativize( prefix + parts.slice( 0,p+1 ).join( '/' ) );

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
          buffer = Buffer.alloc( readSize );
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

        var path = self.path.join( m[ 1 ],parts.slice( p+1 ).join( '/' ) );

        if( path[ 0 ] === '.' )
        path = self.path.reroot( cpath , '..' , path );

        var result = self._pathResolveTextLinkAct( path, visited, hasLink, allowNotExisting );
        if( hasLink )
        {
          if( !result )
          {
            debugger;
            throw _.err
            (
              'Cant resolve : ' + visited[ 0 ] +
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

function pathResolveSoftLinkAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.path.isAbsolute( o.filePath ) );

  /* using self.resolvingSoftLink causes recursion problem in pathResolveLink */
  if( !self.fileIsSoftLink( o.filePath ) )
  return o.filePath;

  if( o.readLink )
  {
    let result = File.readlinkSync( self.path.nativize( o.filePath ) );

    if( !o.relativeToDir )
    if( !self.path.isAbsolute( self.path.normalize( result ) ) )
    {
      if( _.strBegins( result, '.\\' ) )
      result = _.strIsolateBeginOrNone( result, '.\\' )[ 2 ];

      result = '..\\' + result;
    }

    return result;
  }

  return File.realpathSync( self.path.nativize( o.filePath ) );
}

_.routineExtend( pathResolveSoftLinkAct, Parent.prototype.pathResolveSoftLinkAct );

//

// function linkSoftReadAct( o )
// {
//   let self = this;

//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( self.path.isAbsolute( o.filePath ) );

//   if( !self.fileIsSoftLink( o.filePath ) )
//   return o.filePath;

//   let result = File.readlinkSync( self.path.nativize( o.filePath ) );

//   if( !o.relativeToDir )
//   if( !self.path.isAbsolute( self.path.normalize( result ) ) )
//   {
//     if( _.strBegins( result, '.\\' ) )
//     result = _.strIsolateBeginOrNone( result, '.\\' )[ 2 ];

//     result = '..\\' + result;
//   }

//   return result;
// }

// _.routineExtend( linkSoftReadAct, Parent.prototype.linkSoftReadAct );


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
  _.assert( self.path.isNormalized( o.filePath ) );

  var filePath = self.path.nativize( o.filePath );

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

_.routineExtend( fileReadAct, Parent.prototype.fileReadAct );

//

function fileReadStreamAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileReadStreamAct,arguments );

  var filePath = o.filePath;
  o.filePath = self.path.nativize( o.filePath );

  try
  {
    return File.createReadStream( o.filePath,{ encoding : o.encoding } );
  }
  catch( err )
  {
    throw _.err( err );
  }

}

_.routineExtend( fileReadStreamAct, Parent.prototype.fileReadStreamAct );

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

  // /* xxx : temp fix of windows link chain problem */
  // if( process.platform === 'win32' )
  // {
  //   o.filePath = self.pathResolveLink({ filePath : o.filePath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  // }

  var fileNativePath = self.path.nativize( o.filePath );

  /* read dir */

  if( o.sync )
  {
    try
    {
      var stat = self.fileStatAct
      ({
        filePath : o.filePath,
        throwing : 1,
        sync : 1,
        resolvingSoftLink : 1,
      });
      if( stat.isDirectory() )
      {
        result = File.readdirSync( fileNativePath );
        return result
      }
      else
      {
        result = [ self.path.name({ path : o.filePath, withExtension : 1 }) ];
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
      filePath : o.filePath,
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
        File.readdir( fileNativePath, function( err, files )
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
            con.give( files || null );
          }
        });
      }
      else
      {
        result = [ self.path.name({ path : o.filePath, withExtension : 1 }) ];
        con.give( result );
      }
    });

    return con;
  }

}

_.routineExtend( directoryReadAct, Parent.prototype.directoryReadAct );

// --
// read stat
// --

function fileStatAct( o )
{
  var self = this;
  var result = null;

  _.assert( self.path.isAbsolute( o.filePath ),'expects absolute {-o.FilePath-}, but got', o.filePath );
  _.assertRoutineOptions( fileStatAct, arguments );

  // if( o.filePath === '/C/pro/web/Port/package/wMathSpace/node_modules/wmathspace/builder' && o.resolvingSoftLink )
  // debugger; // xxx

  // /* xxx : temp fix of windows link chain problem */
  // if( o.resolvingSoftLink && process.platform === 'win32' )
  // {
  //   o.filePath = self.pathResolveLink({ filePath : o.filePath, resolvingSoftLink : 1, resolvingTextLink : 0 });
  // }

  let fileNativePath = self.path.nativize( o.filePath );
  var args = [ fileNativePath ];

  if( self.UsingBigIntForStat )
  args.push( { bigint : true } );

  // if( o.resolvingSoftLink && self.fileIsSoftLink( o.filePath ) )
  // debugger;

  /* */

  if( o.sync )
  {

    // var resolve = self.pathResolveLink( o.filePath ); // xxx

    try
    {
      if( o.resolvingSoftLink )
      result = FileDefault.statSync.apply( FileDefault, args );
      else
      result = FileDefault.lstatSync.apply( FileDefault, args );
    }
    catch ( err )
    {
      if( o.resolvingSoftLink && self.fileIsSoftLink( o.filePath ) )
      debugger;
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

_.routineExtend( fileStatAct, Parent.prototype.fileStatAct );

//

function fileExistsAct( o )
{
  let self = this;
  let fileNativePath = self.path.nativize( o.filePath );
  try
  {
    File.accessSync( fileNativePath, File.constants.F_OK );
  }
  catch( err )
  {
    if( err.code === 'ENOENT' )
    { /*
        Used to check if symlink is present on Unix when referenced file doesn't exist.
        qqq: Check if same behavior can be obtained by using combination of File.constants in accessSync
      */
      if( process.platform != 'win32' )
      return !!self.fileStatAct({ filePath : o.filePath, sync : 1, throwing : 0, resolvingSoftLink : 0 });

      return false;
    }
    return true;
  }
  _.assert( arguments.length === 1 );
  return true;
}

_.routineExtend( fileExistsAct, Parent.prototype.fileExistsAct );

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

  _.assertRoutineOptions( fileWriteAct, arguments );
  _.assert( _.strIs( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  var encoder = fileWriteAct.encoders[ o.encoding ];

  if( encoder && encoder.onBegin )
  _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder, data : o.data } ) === undefined );

  /* data conversion */

  if( _.bufferTypedIs( o.data ) && !_.bufferBytesIs( o.data ) || _.bufferRawIs( o.data ) )
  o.data = _.bufferNodeFrom( o.data );

  /* qqq : is it possible to do it without conversion from raw buffer? */

  _.assert( _.strIs( o.data ) || _.bufferNodeIs( o.data ) || _.bufferBytesIs( o.data ), 'expects string or node buffer, but got',_.strTypeOf( o.data ) );

  let fileNativePath = self.path.nativize( o.filePath );

  /* write */

  if( o.sync )
  {

      // if( _.strHas( o.filePath, 'icons.woff2' ) )
      // debugger;

      if( o.writeMode === 'rewrite' )
      File.writeFileSync( fileNativePath, o.data, { encoding : self._encodingFor( o.encoding ) } );
      else if( o.writeMode === 'append' )
      File.appendFileSync( fileNativePath, o.data, { encoding : self._encodingFor( o.encoding ) } );
      else if( o.writeMode === 'prepend' )
      {
        var data;
        // qqq : this is not right. reasons of exception could be variuos.
        try
        {
          data = File.readFileSync( fileNativePath, { encoding : self._encodingFor( o.encoding ) } )
        }
        catch( err ){ }
        if( data )
        o.data = o.data.concat( data )
        File.writeFileSync( fileNativePath, o.data, { encoding : self._encodingFor( o.encoding ) } );
      }
      else throw _.err( 'Not implemented write mode',o.writeMode );

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
    File.writeFile( fileNativePath, o.data, { encoding : self._encodingFor( o.encoding ) }, handleEnd );
    else if( o.writeMode === 'append' )
    File.appendFile( fileNativePath, o.data, { encoding : self._encodingFor( o.encoding ) }, handleEnd );
    else if( o.writeMode === 'prepend' )
    {
      File.readFile( fileNativePath, { encoding : self._encodingFor( o.encoding ) }, function( err,data )
      {
        if( data )
        o.data = o.data.concat( data );
        File.writeFile( fileNativePath, o.data, { encoding : self._encodingFor( o.encoding ) }, handleEnd );
      });

    }
    else handleEnd( _.err( 'Not implemented write mode', o.writeMode ) );

    return con;
  }

}

_.routineExtend( fileWriteAct, Parent.prototype.fileWriteAct );

//

function fileWriteStreamAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileWriteStreamAct, arguments );

  var filePath = o.filePath;

  o.filePath = self.path.nativize( o.filePath );

  try
  {
    return File.createWriteStream( o.filePath );
  }
  catch( err )
  {
    throw _.err( err );
  }
}

_.routineExtend( fileWriteStreamAct, Parent.prototype.fileWriteStreamAct );

//

function fileTimeSetAct( o )
{
  let self = this;

  _.assertRoutineOptions( fileTimeSetAct, arguments );

  // File.utimesSync( o.filePath, o.atime, o.mtime );

  /*
    futimesSync atime/mtime precision:
    win32 up to seconds, throws error milliseconds
    unix up to nanoseconds, but stat.mtime works properly up to milliseconds otherwise returns "Invalid Date"
  */

  let fileNativePath = self.path.nativize( o.filePath );
  let flags = process.platform === 'win32' ? 'r+' : 'r';
  let descriptor = File.openSync( fileNativePath, flags );
  try
  {
    File.futimesSync( descriptor, o.atime, o.mtime );
    File.closeSync( descriptor );
  }
  catch( err )
  {
    File.closeSync( descriptor );
    throw _.err( err );
  }
}

_.routineExtend( fileTimeSetAct, Parent.prototype.fileTimeSetAct );

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
  _.assert( self.path.isAbsolute( o.filePath ) );

  var filePath = o.filePath;

  o.filePath = self.path.nativize( o.filePath );

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

_.routineExtend( fileDeleteAct, Parent.prototype.fileDeleteAct );

//

function directoryMakeAct( o )
{
  var self = this;
  var fileNativePath = self.path.nativize( o.filePath );

  _.assertRoutineOptions( directoryMakeAct,arguments );
  // _.assert( self.fileStatAct( self.path.dir( o.filePath ) ), 'Directory for directory does not exist :\n' + _.strQuote( o.filePath ) ); /* qqq */

  if( o.sync )
  {

    try
    {
      File.mkdirSync( fileNativePath );
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

    File.mkdir( fileNativePath, function( err, data ){ con.give( err, data ); } );

    return con;
  }

}

_.routineExtend( directoryMakeAct, Parent.prototype.directoryMakeAct );

//

function fileRenameAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileRenameAct,arguments );

  o.dstPath = self.path.nativize( o.dstPath );
  o.srcPath = self.path.nativize( o.srcPath );

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

_.routineExtend( fileRenameAct, Parent.prototype.fileRenameAct );
_.assert( fileRenameAct.defaults.originalDstPath !== undefined );

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

  o.dstPath = self.path.nativize( o.dstPath );
  o.srcPath = self.path.nativize( o.srcPath );

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

_.routineExtend( fileCopyAct, Parent.prototype.fileCopyAct );

//

function linkSoftAct( o )
{
  let self = this;

  _.assertMapHasAll( o,linkSoftAct.defaults );
  _.assert( self.path.isAbsolute( o.dstPath ) );
  _.assert( self.path.isNormalized( o.srcPath ) );
  _.assert( self.path.isNormalized( o.dstPath ) );

  let srcIsAbsolute = self.path.isAbsolute( o.originalSrcPath );

  if( !srcIsAbsolute )
  {
    o.srcPath = o.originalSrcPath;
    if( _.strBegins( o.srcPath, './' ) )
    o.srcPath = _.strIsolateBeginOrNone( o.srcPath, './' )[ 2 ];
    if( _.strBegins( o.srcPath, '..' ) )
    o.srcPath = '.' + _.strIsolateBeginOrNone( o.srcPath, '..' )[ 2 ];
  }

  let srcPath = o.srcPath;
  // var dstPath = o.dstPath;

  _.assert( !!o.dstPath );
  _.assert( !!o.srcPath );
  _.assert( o.type === null || o.type === 'dir' ||  o.type === 'file' );

  debugger;

  if( process.platform === 'win32' )
  {
    // var srcStat = self.fileStatAct({ filePath : o.srcPath });

    if( o.type === null )
    {
      /* not dir */
      if( !srcIsAbsolute )
      srcPath = self.path.resolve( self.path.dir( o.dstPath ), srcPath );
      // if( !self.path.isAbsolute( srcPath ) )
      // srcPath = self.path.resolve( dstPath, srcPath );

      let srcStat = self.fileStatAct
      ({
        filePath : srcPath,
        resolvingSoftLink : 1,
        sync : 1,
        throwing : 0,
      });

      if( srcStat )
      o.type = srcStat.isDirectory() ? 'dir' : 'file';

    }

    // debugger;
    // if( o.type === null )
    // o.type = 'dir';

    // if( _.strBegins( o.srcPath, '.\\' ) )
    // o.srcPath = _.strIsolateBeginOrNone( o.srcPath, '.\\' )[ 2 ];
    // if( _.strBegins( o.srcPath, '..' ) )
    // o.srcPath = '.' + _.strIsolateBeginOrNone( o.srcPath, '..' )[ 2 ];

/*
dstPath : /C/pro/web/Port/package/xxx/builder
srcPath : ./../../../app/builder

absolutePath : /C/pro/web/Port/app/builder
resolvedPath : /C/pro/web/Port/app/builder
gotPath : builder -> ../../../app/builder : /C/pro/web/app/builder
*/

  }

  o.dstPath = self.path.nativize( o.dstPath );
  o.srcPath = self.path.nativize( o.srcPath );

  /* */

  if( o.sync )
  {

    // if( self.fileStatAct({ filePath : dstPath, sync : 1, throwing : 0, resolvingSoftLink : 0 }) ) /* qqq */
    // throw _.err( 'linkSoftAct', dstPath,'already exists' );

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

_.routineExtend( linkSoftAct, Parent.prototype.linkSoftAct );

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

  o.dstPath = self.path.nativize( o.dstPath );
  o.srcPath = self.path.nativize( o.srcPath );

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

_.routineExtend( linkHardAct, Parent.prototype.linkHardAct );

// --
// etc
// --

function _encodingFor( encoding )
{
  var self = this;
  var result;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( encoding ) );

  if( encoding === 'buffer.node' || encoding === 'buffer.bytes' )
  // result = 'binary';
  result = undefined;
  else
  result = encoding;

  // if( result === 'binary' )
  // throw _.err( 'not tested' );

  _.assert( _.arrayHas( self.KnownNativeEncodings,result ), 'Unknown encoding:', result );

  return result;
}

// --
// encoders
// --

var encoders = {};

encoders[ 'buffer.raw' ] =
{

  onBegin : function( e )
  {
    debugger;
    _.assert( e.transaction.encoding === 'buffer.raw' );
    e.transaction.encoding = 'buffer.node';
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
    return require( _.fileProvider.path.nativize( e.transaction.filePath ) );
  },
}

encoders[ 'buffer.bytes' ] =
{

  onBegin : function( e )
  {
    _.assert( e.transaction.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    return _.bufferBytesFrom( e.data );
  },

}

//

encoders[ 'original.type' ] =
{

  onBegin : function( e )
  {
    _.assert( e.transaction.encoding === 'original.type' );
    e.transaction.encoding = 'buffer.bytes';
  },

  onEnd : function( e )
  {
    return _.bufferBytesFrom( e.data );
  },

}

fileReadAct.encoders = encoders;

//

var writeEncoders = Object.create( null );

writeEncoders[ 'original.type' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'original.type' );

    if( _.strIs( e.data ) )
    e.operation.encoding = 'utf8';
    else if( _.bufferBytesIs( e.data ) )
    e.operation.encoding = 'buffer.bytes';
    else
    e.operation.encoding = 'buffer.node';

  }

}

fileWriteAct.encoders = writeEncoders;

// --
// relationship
// --

var KnownNativeEncodings = [ undefined,'ascii','base64','binary','hex','ucs2','ucs-2','utf16le','utf-16le','utf8','latin1' ]
var UsingBigIntForStat = _.files.nodeJsIsSameOrNewer( [ 10,5,0 ] );

var Composes =
{
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
  // _pathNativizeWindows : _pathNativizeWindows,
  // _pathNativizeUnix : _pathNativizeUnix,
  pathNativizeAct : pathNativizeAct,
  KnownNativeEncodings : KnownNativeEncodings,
  UsingBigIntForStat : UsingBigIntForStat,
  Path : _.path.CloneExtending({ fileProvider : Self }),
}

// --
// declare
// --

var Proto =
{

  // inter

  init : init,

  // path

  // _pathNativizeWindows : _pathNativizeWindows,
  // _pathNativizeUnix : _pathNativizeUnix,
  pathNativizeAct : pathNativizeAct,

  pathCurrentAct : pathCurrentAct,

  _pathResolveTextLinkAct : _pathResolveTextLinkAct,

  // qqq
  pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  // linkSoftReadAct : linkSoftReadAct,

  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : fileReadStreamAct,

  directoryReadAct : directoryReadAct,

  // read stat

  fileStatAct : fileStatAct,
  fileExistsAct : fileExistsAct,

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

_.assert( _.routineIs( Self.prototype.pathCurrentAct ) );
_.assert( _.routineIs( Self.Path.current ) );

//

if( Config.platform === 'nodejs' )
if( !_.FileProvider.Default )
{
  _.FileProvider.Default = Self;
  if( !_.fileProvider )
  _.FileProvider.Default.MakeDefault();
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
