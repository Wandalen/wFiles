( function _RemoteClient_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }
  var _global = _global_;
  var _ = _global_.wTools;

  _.include( 'wFiles' );
  _.include( 'wCommunicator' );

}
var _global = _global_;
var _ = _global_.wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Partial;
var Self = function wFileProviderRemote( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Remote';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

//

function form()
{
  var self = this;

  _.assert( self.serverUrl,'needs field { serverUrl }' );

  self.communicator = wCommunicator
  ({
    verbosity : 5,
    isMaster : 0,
    url : self.serverUrl,
  });

  self.communicator.form();

  return self;
}

//

function exec()
{
  var self = new Self
  ({
    serverUrl : 'tcp://127.0.0.1:61726',
  });

  self.form();

  return self;

  self.fileRead({ filePath : './builder/Clean', sync : 0 }).doThen( function( err,arg )
  {
    if( err )
    throw _.errLogOnce( err );
    logger.log( 'fileRead',arg );
  });

  return self;
}

// --
// adapter
// --

function localFromUri( url )
{
  var self = this;

  if( _.strIs( url ) )
  url = _.uri.parse( url );

  _.assert( _.mapIs( url ) ) ;
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( url.localPath );

  return url.localPath;
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

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( fileReadAct,o );
  _.assert( !o.sync );

  if( 0 )
  if( Config.debug )
  stack = _._err({ usingSourceCode : 0, args : [] });

  var encoder = fileReadAct.encoders[ o.encoding ];

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    _.sure( encoder.onBegin.call( self,{ operation : o, encoder : encoder }) === undefined );

  }

  /* end */

  function handleEnd( data )
  {

    if( encoder && encoder.onEnd )
    _.sure( encoder.onEnd.call( self,{ data : data, operation : o, encoder : encoder }) === undefined ); // xxx

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
      err = encoder.onError.call( self,{ error : err, operation : o, encoder : encoder })
    }
    catch( err2 )
    {
      console.error( err2 );
      console.error( err.toString() + '\n' + err.stack );
    }

    if( o.sync )
    throw err;
    else
    return con.error( err );

  }

  /* exec */

  handleBegin();

  o.sync = 0;

  var result = self.fileProvider.fileReadAct( o );

  return result;
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

//

function fileReadStreamAct( o )
{
  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ) );

  var o = _.routineOptions( fileReadStreamAct, o );
  var stream = null;

  if( o.sync )
  {
    try
    {
      stream = File.createReadStream( o.filePath );
    }
    catch( err )
    {
      throw _.err( err );
    }
    return stream;
  }
  else
  {
    var con = new _.Consequence();
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

fileReadStreamAct.defaults = {};
fileReadStreamAct.defaults.__proto__ = Parent.prototype.fileReadStreamAct.defaults;

//

function fileStatAct( o )
{

  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1, 'expects single argument' );
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
    var con = new _.Consequence();

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
    _.assert( arguments.length === 1, 'expects single argument' );

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

      var con = new _.Consequence();
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

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( directoryReadAct,o );

  var result = null;

  /* sort */

  function handleEnd( result )
  {
    // for( var r = 0 ; r < result.length ; r++ )
    // result[ r ] = self.path.refine( result[ r ] ); // output should be covered by test
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
        result = [ self.path.name({ path : self.path.refine( o.filePath ), withExtension : 1 }) ];
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
        result = [ self.path.name({ path : self.path.refine( o.filePath ), withExtension : 1 }) ];
        con.give( result );
      }
    });

    return con;
  }

}

directoryReadAct.defaults = {};
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

// --
// write
// --

function fileWriteStreamAct( o )
{
  if( _.strIs( o ) )
  o = { filePath : o };

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ) );

  var o = _.routineOptions( fileWriteStreamAct, o );
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
    var con = new _.Consequence();
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

fileWriteStreamAct.defaults = {};
fileWriteStreamAct.defaults.__proto__ = Parent.prototype.fileWriteStreamAct.defaults;

//

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
    _.assert( arguments.length === 1, 'expects single argument' );
  }

  _.routineOptions( fileWriteAct,o );
  _.assert( _.strIs( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  /* data conversion */

  if( _.bufferTypedIs( o.data ) || _.bufferRawIs( o.data ) )
  o.data = _.bufferNodeFrom( o.data );

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
    var con = _.Consequence();

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
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ) );
  var self = this;
  var stat;

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
  var optionsAct = _.mapOnly( o, self.fileDeleteAct.defaults );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ) );

  o.filePath = self.path.nativize( o.filePath );

  // if( _.files.usingReadOnly )
  // return o.sync ? undefined : con.give();

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
    var con = new _.Consequence();

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

  // if( arguments.length === 2 )
  // o =
  // {
  //   dstPath : arguments[ 0 ],
  //   srcPath : arguments[ 1 ],
  // }
  // else
  // {
  //   _.assert( arguments.length === 1, 'expects single argument' );
  // }

  _.assert( arguments.length === 1, 'expects single argument' );
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

//

function fileRenameAct( o )
{

  if( arguments.length === 2 )
  o =
  {
    dstPath : arguments[ 0 ],
    srcPath : arguments[ 1 ],
  }
  else
  {
    _.assert( arguments.length === 1, 'expects single argument' );
  }

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
    _.assert( arguments.length === 1, 'expects single argument' );
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
    _.assert( arguments.length === 1, 'expects single argument' );
  }

  _.routineOptions( directoryMakeAct,o );

  var stat;

  if( o.sync )
  {

    File.mkdirSync( o.filePath );

  }
  else
  {
    var con = new _.Consequence();

    File.mkdir( o.filePath, function( err, data ){ con.give( err, data ); } );

    return con;
  }

}

directoryMakeAct.defaults = {};
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;

//

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
    _.assert( arguments.length === 1, 'expects single argument' );
  }

  _.routineOptions( directoryMake,o );
  o.filePath = self.path.nativize( o.filePath );

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
    var con = new _.Consequence();

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
  o = self._linkPre( linkSoftAct,arguments );

  /* */

  if( o.sync )
  {
    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkSoftAct',o.dstPath,'already exists' );

    File.symlinkSync( o.srcPath,o.dstPath );
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

//

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
        throwing : 1
      });

      if( self.fileStat( o.dstPath ) )
      throw _.err( 'linkHardAct',o.dstPath,'already exists' );

      File.linkSync( o.srcPath,o.dstPath );
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

// --
// encoders
// --

var encoders = {};

encoders[ 'json' ] =
{

  onBegin : function( e )
  {
    throw _.err( 'not tested' );
    _.assert( e.operation.encoding === 'json' );
    e.operation.encoding = 'utf8';
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
    _.assert( e.operation.encoding === 'arraybuffer' );
    e.operation.encoding = 'buffer';
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
  // originPath : null,
  protocols : null,
  serverUrl : null,
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
  exec : exec,
}

// --
// declare
// --

var Proto =
{

  // inter

  init : init,
  form : form,
  exec : exec,


  // adapter

  localFromUri : localFromUri,


  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : fileReadStreamAct,
  fileStatAct : fileStatAct,
  fileHashAct : fileHashAct,

  directoryReadAct : directoryReadAct,


  // write

  fileWriteStreamAct : fileWriteStreamAct,

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
// if( _.FileProvider.Path )
// _.FileProvider.Path.mixin( Self );

//

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_.FileProvider.Remote.exec();

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
