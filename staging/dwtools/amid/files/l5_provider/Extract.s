( function _Extract_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );

}

/*
qqq !!!

extract.linkSoft
({
  srcPath : '.',
  dstPath : file.absolute,
  allowMissing : 1,
});

link is not relative!

*/

var _global = _global_;
var _ = _global_.wTools;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var FileRecord = _.FileRecord;
var Find = _.FileProvider.Find;

_.assert( _.routineIs( _.FileRecord ) );
_.assert( _.routineIs( Abstract ) );
_.assert( _.routineIs( Partial ) );
_.assert( !!Find );
_.assert( !_.FileProvider.Extract );

//

var Parent = Partial;
var Self = function wFileProviderExtract( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Extract';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );

  if( self.filesTree === null )
  self.filesTree = Object.create( null );

}

// --
// path
// --

function pathCurrentAct()
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  {
    var path = arguments[ 0 ];
    _.assert( self.path.is( path ) );
    self._currentPath = path;
  }

  var result = self._currentPath;

  return result;
}

//

function pathResolveSoftLinkAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.path.isAbsolute( o.filePath ) );

  /* using self.resolvingSoftLink causes recursion problem in pathResolveLink */
  if( !self.fileIsSoftLink( o.filePath ) )
  return o.filePath;

  var descriptor = self._descriptorRead( o.filePath );
  var resolved = self._descriptorResolveSoftLinkPath( descriptor );

  _.assert( _.strIs( resolved ) )

  return resolved;
}

var defaults = pathResolveSoftLinkAct.defaults = Object.create( Parent.prototype.pathResolveSoftLinkAct.defaults );
var paths = pathResolveSoftLinkAct.paths = Object.create( Parent.prototype.pathResolveSoftLinkAct.paths );
var having = pathResolveSoftLinkAct.having = Object.create( Parent.prototype.pathResolveSoftLinkAct.having );

//

function pathResolveHardLinkAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.path.isAbsolute( o.filePath ) );

  if( /*!self.resolvingHardLink ||*/ !self.fileIsHardLink( o.filePath ) )
  return o.filePath;

  var descriptor = self._descriptorRead( o.filePath );
  var resolved = self._descriptorResolveHardLinkPath( descriptor );

  if( !self._descriptorRead( resolved ) )
  return o.filePath;

  _.assert( _.strIs( resolved ) )

  return resolved;
}

//

// function linkSoftReadAct( o )
// {
//   let self = this;

//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( self.path.isAbsolute( o.filePath ) );

//   if( !self.fileIsSoftLink( o.filePath ) )
//   return o.filePath;

//   let descriptor = self._descriptorRead( o.filePath );
//   let result = self._descriptorResolveSoftLinkPath( descriptor );

//   _.assert( _.strIs( result ) );

//   return result;
// }

// _.routineExtend( linkSoftReadAct, Parent.prototype.linkSoftReadAct );

// --
// read
// --

function fileReadAct( o )
{
  var self = this;
  var con = new _.Consequence();
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileReadAct,o );
  _.assert( _.strIs( o.encoding ) );

  var encoder = fileReadAct.encoders[ o.encoding ];

  if( o.encoding )
  if( !encoder )
  return handleError( _.err( 'Encoding: ' + o.encoding + ' is not supported!' ) )

  /* exec */

  handleBegin();

  // if( _.strHas( o.filePath, 'icons.woff2' ) )
  // debugger;

  o.filePath = self.pathResolveLink
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  if( self.hub && _.uri.isGlobal( o.filePath ) )
  {
    _.assert( self.hub !== self );
    return self.hub.fileReadAct( o );
  }

  var result = self._descriptorRead( o.filePath );

  // if( self._descriptorIsLink( result ) )
  // {
  //   result = self._descriptorResolve({ descriptor : result });
  //   if( result === undefined )
  //   return handleError( _.err( 'Cant resolve :', result ) );
  // }

  if( self._descriptorIsHardLink( result ) )
  {
    var resolved = self._descriptorResolve({ descriptor : result });
    if( resolved === undefined )
    return handleError( _.err( 'Cant resolve :', result ) );
    result = resolved;
  }

  if( result === undefined || result === null )
  {
    debugger;
    result = self._descriptorRead( o.filePath );
    return handleError( _.err( 'File at :', o.filePath, 'doesn`t exist!' ) );
  }

  if( self._descriptorIsDir( result ) )
  return handleError( _.err( 'Can`t read from dir : ' + _.strQuote( o.filePath ) + ' method expects file' ) );
  else if( self._descriptorIsLink( result ) )
  return handleError( _.err( 'Can`t read from link : ' + _.strQuote( o.filePath ) + ', without link resolving enabled' ) );
  else if( !self._descriptorIsTerminal( result ) )
  return handleError( _.err( 'Can`t read file : ' + _.strQuote( o.filePath ), result ) );

  if( self.usingTime )
  self._fileTimeSetAct({ filePath : o.filePath, atime : _.timeNow() });

  return handleEnd( result );

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder }) === undefined );

  }

  /* end */

  function handleEnd( data )
  {

    let context = { data : data, operation : o, encoder : encoder };
    if( encoder && encoder.onEnd )
    _.sure( encoder.onEnd.call( self, context ) === undefined );
    data = context.data;

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

    debugger;

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
    {
      throw err;
    }
    else
    {
      return con.error( err );
    }

  }

}

_.routineExtend( fileReadAct, Parent.prototype.fileReadAct );

// var defaults = fileReadAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );
// var having = fileReadAct.having = Object.create( Parent.prototype.fileReadAct.having );

//

// var fileHashAct = ( function()
// {

//   var crypto;

//   return function fileHashAct( o )
//   {
//     var result=NaN;
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
//     function makeHash()
//     {
//       try
//       {
//         var read = self.fileReadAct( { filePath : o.filePath, sync : 1 } );
//         md5sum.update( read );
//         result = md5sum.digest( 'hex' );
//       }
//       catch( err )
//       {
//         if( o.throwing )
//         {
//           throw _.err( err );
//         }
//       }
//     }

//    if( o.sync )
//    {
//      makeHash( );
//      return result;
//    }
//    else
//    {
//      return _.timeOut( 0, function()
//      {
//        makeHash();
//        return result;
//      })
//    }
//   }
// })();

// fileHashAct.defaults = {};
// fileHashAct.defaults.__proto__ = Parent.prototype.fileHashAct.defaults;

//

function directoryReadAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( directoryReadAct,o );

  var result;

  if( o.sync )
  {
    readDir();
    return result;
  }
  else
  {
    return _.timeOut( 0, function()
    {
      readDir();
      return result;
    });
  }

  /* */

  function readDir()
  {
    o.filePath = self.pathResolveLink({ filePath : o.filePath, resolvingSoftLink : 1 });

    var file = self._descriptorRead( o.filePath );

    // if( self._descriptorIsLink( file ) )
    // file = self._descriptorResolve({ descriptor : result, resolvingSoftLink : 1 });

    if( file !== undefined )
    {
      if( _.objectIs( file ) )
      {
        result = Object.keys( file );
        _.assert( _.arrayIs( result ),'readdirSync returned not array' );
      }
      else
      {
        result = [ self.path.name({ path : o.filePath, withExtension : 1 }) ];
      }
    }
    else
    {
      if( o.throwing )
      throw _.err( 'Path : ', o.filePath, 'doesn`t exist!' );;
      result = null;
    }
  }

}

var defaults = directoryReadAct.defaults = Object.create( Parent.prototype.directoryReadAct.defaults );
var having = directoryReadAct.having = Object.create( Parent.prototype.directoryReadAct.having );

// --
// read stat
// -

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileStatAct,o );

  /* */

  if( o.sync )
  {
    return _fileStatAct( o.filePath );
  }
  else
  {
    return _.timeOut( 0, function()
    {
      return _fileStatAct( o.filePath );
    })
  }

  /* */

  function _fileStatAct( filePath )
  {
    var result = null;

    // if( filePath === '/out/icons' )
    // debugger;

    filePath = self.pathResolveLink({ filePath : filePath, resolvingSoftLink : o.resolvingSoftLink });

    var file = self._descriptorRead( filePath );

    if( !_.definedIs( file ) )
    {
      // _.assert( !file );
      if( o.throwing )
      throw _.err( 'Path :', filePath, 'doesn`t exist!' );
      return result;
    }

    result = new _.FileStat();

    if( self.timeStats && self.timeStats[ filePath ] )
    {
      var timeStats = self.timeStats[ filePath ];
      for( var k in timeStats )
      result[ k ] = new Date( timeStats[ k ] );
    }

    result.isFile = function() { return false; };
    result.isDirectory = function() { return false; };
    result.isSymbolicLink = function() { return false; };

    if( self._descriptorIsDir( file ) )
    {
      result.isDirectory = function() { return true; };
    }
    else if( self._descriptorIsTerminal( file ) )
    {
      result.isFile = function() { return true; };
      if( _.strIs( file ) )
      result.size = file.length;
      else
      result.size = file.byteLength;
    }
    // else if( self._descriptorIsHardLink( file ) )
    // {
    //   file = file[ 0 ];

    //   // if( o.resolvingHardLink )
    //   {
    //     var r = _fileStatAct( file.hardLink );
    //     if( r ) /* qqq : really return? */
    //     return r;
    //   }

    // }
    else if( self._descriptorIsSoftLink( file ) )
    {
      // file = file[ 0 ];

      // if( o.resolvingSoftLink )
      // {
      //   var r = _fileStatAct( file.softLink );
      //   if( r )
      //   return r;
      // }

      result.isSymbolicLink = function() { return true; };

    }
    else if( self._descriptorIsScript( file ) )
    {
    }

    return result;
  }

}

fileStatAct.defaults = Object.create( Parent.prototype.fileStatAct.defaults );
fileStatAct.having = Object.create( Parent.prototype.fileStatAct.having );

//

function fileExistsAct( o )
{
  let self = this;
  _.assert( arguments.length === 1 );
  let file = self._descriptorRead( o.filePath );
  return !!file;
}

_.routineExtend( fileExistsAct, Parent.prototype.fileExistsAct );

//
//
// function fileIsTerminalAct( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//
//   var d = self._descriptorRead( o.filePath );
//
//   if( d === undefined )
//   return false;
//
//   var d = self._descriptorResolve
//   ({
//     descriptor : d,
//     resolvingSoftLink : o.resolvingSoftLink,
//     resolvingTextLink : o.resolvingTextLink,
//   });
//
//   if( self._descriptorIsLink( d ) )
//   return false;
//
//   if( self._descriptorIsDir( d ) )
//   return false;
//
//   return true;
// }
//
// var defaults = fileIsTerminalAct.defaults = Object.create( Parent.prototype.fileIsTerminalAct.defaults );
// var paths = fileIsTerminalAct.paths = Object.create( Parent.prototype.fileIsTerminalAct.paths );
// var having = fileIsTerminalAct.having = Object.create( Parent.prototype.fileIsTerminalAct.having );

//

/**
 * Return True if file at `filePath` is a hard link.
 * @param filePath
 * @returns {boolean}
 * @method fileIsHardLink
 * @memberof wFileProviderExtract
 */

function fileIsHardLink( filePath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var descriptor = self._descriptorRead( filePath )

  return self._descriptorIsHardLink( descriptor );
}

var having = fileIsHardLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

/**
 * Return True if file at `filePath` is a soft link.
 * @param filePath
 * @returns {boolean}
 * @method fileIsSoftLink
 * @memberof wFileProviderExtract
 */

function fileIsSoftLink( filePath )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var descriptor = self._descriptorRead( filePath );

  return self._descriptorIsSoftLink( descriptor );
}

var having = fileIsSoftLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function filesAreHardLinkedAct( ins1Path,ins2Path )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  var res1Path = self.pathResolveHardLinkAct({ filePath : ins1Path });
  var res2Path = self.pathResolveHardLinkAct({ filePath : ins2Path });

  if( res1Path === ins2Path )
  return true;

  if( ins1Path === res2Path )
  return true;

  if( res1Path === res2Path )
  return true;

  return false;
}

// --
// write
// --

function fileWriteAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileWriteAct,o );
  _.assert( _.strIs( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  var encoder = fileWriteAct.encoders[ o.encoding ];

  /* o.data */

  // if( _.bufferTypedIs( o.data ) )
  // {
  //   o.data = _.bufferNodeFrom( o.data );
  // }

  _.assert( self._descriptorIsTerminal( o.data ), 'expects string or Buffer, but got', _.strTypeOf( o.data ) );

  // if( _.bufferRawIs( o.data ) )
  // o.data = _.bufferToStr( o.data );

  /* write */

  function handleError( err )
  {
    var err = _.err( err );
    if( o.sync )
    throw err;
    return new _.Consequence().error( err );
  }

  /* */

  if( o.sync )
  {
    write();
  }
  else
  {
    return _.timeOut( 0, () => write() );
  }

  /* begin */

  function handleBegin( read )
  {
    if( !encoder )
    return o.data;

    _.assert( _.routineIs( encoder.onBegin ) )
    let context = { data : o.data, read : read, operation : o, encoder : encoder };
    _.sure( encoder.onBegin.call( self, context ) === undefined );

    return context.data;
  }

  /*  */

  function write()
  {

    let filePath =  o.filePath;
    let descriptor = self._descriptorRead( filePath );
    let read;

    if( self._descriptorIsLink( descriptor ) )
    {
      let resolvedPath = self.pathResolveLink( filePath );
      descriptor = self._descriptorRead( resolvedPath );

      if( !self._descriptorIsLink( descriptor ) )
      {
        filePath = resolvedPath;
        if( descriptor === undefined )
        throw _.err( 'Link refers to file ->', filePath, 'that doesn`t exist' );
      }
    }

    // var dstName = self.path.name({ path : filePath, withExtension : 1 });
    let dstDir = self.path.dir( filePath );

    if( !self._descriptorRead( dstDir ) )
    throw _.err( 'Directories structure :' , dstDir, 'doesn`t exist' );

    if( self._descriptorIsDir( descriptor ) )
    throw _.err( 'Incorrect path to file!\nCan`t rewrite dir :', filePath );

    let writeMode = o.writeMode;

    _.assert( _.arrayHas( self.WriteMode, writeMode ), 'Unknown write mode:' + writeMode );

    if( descriptor === undefined || self._descriptorIsLink( descriptor ) )
    {
      read = '';
      writeMode = 'rewrite';
    }
    else
    {
      read = descriptor;
    }

    let data = handleBegin( read );

    _.assert( self._descriptorIsTerminal( read ) );

    if( writeMode === 'append' || writeMode === 'prepend' )
    {
      if( !encoder )
      {
        //converts data from file to the type of o.data
        if( _.strIs( data ) )
        {
          if( !_.strIs( read ) )
          read = _.bufferToStr( read );
        }
        else
        {
          _.assert( 0, 'not tested' );

          if( _.bufferBytesIs( data ) )
          read = _.bufferBytesFrom( read )
          else if( _.bufferRawIs( data ) )
          read = _.bufferRawFrom( read )
          else
          _.assert( 0, 'not implemented for:', _.strTypeOf( data ) );
        }
      }

      if( _.strIs( read ) )
      {
        if( writeMode === 'append' )
        data = read + data;
        else
        data = data + read;
      }
      else
      {
        if( writeMode === 'append' )
        data = _.bufferJoin( read, data );
        else
        data = _.bufferJoin( data, read );
      }

      // _.assert( _.strIs( o.data ) && _.strIs( read ), 'not impelemented' ); // qqq
    }
    else
    {
      _.assert( writeMode === 'rewrite', 'Not implemented write mode:', writeMode );
    }

    self._descriptorWrite( filePath, data );

    /* what for is that needed ??? */
    /*self._descriptorRead({ query : dstDir, set : structure });*/
  }

}

var defaults = fileWriteAct.defaults = Object.create( Parent.prototype.fileWriteAct.defaults );
var having = fileWriteAct.having = Object.create( Parent.prototype.fileWriteAct.having );

//

function fileTimeSetAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertMapHasOnly( o,fileTimeSetAct.defaults );

  var file = self._descriptorRead( o.filePath );
  if( !file )
  throw _.err( 'File:', o.filePath, 'doesn\'t exist. Can\'t set time stats.' );

  self._fileTimeSetAct( o );

}

var defaults = fileTimeSetAct.defaults = Object.create( Parent.prototype.fileTimeSetAct.defaults );
var having = fileTimeSetAct.having = Object.create( Parent.prototype.fileTimeSetAct.having );

//

function fileDeleteAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ) );

  if( o.sync )
  {
    act();
  }
  else
  {
    return _.timeOut( 0, () => act() );
  }

  /* - */

  function act()
  {
    var stat = self.fileStatAct
    ({
      filePath : o.filePath,
      resolvingSoftLink : 0,
      sync : 1,
      throwing : 0,
    });

    // if( stat && stat.isSymbolicLink && stat.isSymbolicLink() )
    // {
    //   // debugger;
    //   // throw _.err( 'not tested' );
    // }

    if( !stat )
    throw _.err( 'Path : ', o.filePath, 'doesn`t exist!' );

    var file = self._descriptorRead( o.filePath );
    if( self._descriptorIsDir( file ) && Object.keys( file ).length )
    throw _.err( 'Directory not empty : ', o.filePath );

    let dirPath = self.path.dir( o.filePath );
    var dir = self._descriptorRead( dirPath );

    _.sure( !!dir, () => 'Cant delete root directory ' + _.strQuote( o.filePath ) );

    var fileName = self.path.name({ path : o.filePath, withExtension : 1 });
    delete dir[ fileName ];

    for( var k in self.timeStats[ o.filePath ] )
    self.timeStats[ o.filePath ][ k ] = null;

    // debugger;
    // self._descriptorWrite( dirPath, dir ); /* qqq : was that require? */
  }

}

var defaults = fileDeleteAct.defaults = Object.create( Parent.prototype.fileDeleteAct.defaults );
var having = fileDeleteAct.having = Object.create( Parent.prototype.fileDeleteAct.having );

//

function directoryMakeAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( directoryMakeAct, o );

  /* */

  if( o.sync )
  {
    __make();
  }
  else
  {
    return _.timeOut( 0, () => __make() );
  }

  /* - */

  function __make( )
  {
    if( self._descriptorRead( o.filePath ) )
    throw _.err( 'File ', _.strQuote( o.filePath ), 'already exists!' );

    _.assert( !!self._descriptorRead( self.path.dir( o.filePath ) ), 'Directory ', _.strQuote( o.filePath ), ' doesn\'t exist!' );

    self._descriptorWrite( o.filePath, Object.create( null ) );
  }

}

var defaults = directoryMakeAct.defaults = Object.create( Parent.prototype.directoryMakeAct.defaults );
var having = directoryMakeAct.having = Object.create( Parent.prototype.directoryMakeAct.having );

//

function fileRenameAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertMapHasOnly( o,fileRenameAct.defaults );

  /* rename */

  function rename( )
  {
    var dstName = self.path.name({ path : o.dstPath, withExtension : 1 });
    var srcName = self.path.name({ path : o.srcPath, withExtension : 1 });
    var srcDirPath = self.path.dir( o.srcPath );
    var dstDirPath = self.path.dir( o.dstPath );

    var srcDir = self._descriptorRead( srcDirPath );
    if( !srcDir || !srcDir[ srcName ] )
    throw _.err( 'Source path : ', o.srcPath, 'doesn`t exist!' );

    var dstDir = self._descriptorRead( dstDirPath );
    if( !dstDir )
    throw _.err( 'Destination folders structure : ' + dstDirPath + ' doesn`t exist' );
    if( dstDir[ dstName ] )
    throw _.err( 'Destination path : ', o.dstPath, 'already exist!' );

    if( dstDir=== srcDir )
    {
      dstDir[ dstName ] = dstDir[ srcName ];
      delete dstDir[ srcName ];
    }
    else
    {
      dstDir[ dstName ] = srcDir[ srcName ];
      delete srcDir[ srcName ];
      self._descriptorWrite( srcDirPath, srcDir );
    }

    for( var k in self.timeStats[ o.srcPath ] )
    self.timeStats[ o.srcPath ][ k ] = null;

    self._descriptorWrite( dstDirPath, dstDir );
  }

  if( o.sync )
  {
    rename( );
  }
  else
  {
    return _.timeOut( 0, () => rename() );
  }

}

var defaults = fileRenameAct.defaults = Object.create( Parent.prototype.fileRenameAct.defaults );

defaults.sync = 1;

var having = fileRenameAct.having = Object.create( Parent.prototype.fileRenameAct.having );

//

function fileCopyAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileCopyAct, arguments );

  var srcFile;

  function _copyPre( )
  {
    srcFile  = self._descriptorRead( o.srcPath );
    if( !srcFile )
    throw _.err( 'File/dir : ', o.srcPath, 'doesn`t exist!' );
    if( self._descriptorIsDir( srcFile ) )
    throw _.err( o.srcPath,' is not a terminal file!' );

    var dstDir = self._descriptorRead( self.path.dir( o.dstPath ) );
    if( !dstDir )
    throw _.err( 'fileCopyAct: directories structure before', o.dstPath, ' does not exist' );

    var dstPath = self._descriptorRead( o.dstPath );
    if( self._descriptorIsDir( dstPath ) )
    throw _.err( 'Can`t rewrite dir with file, method expects file : ', o.dstPath );
  }

  if( o.sync  )
  {
    _copyPre();

    if( o.breakingDstHardLink && self.fileIsHardLink( o.dstPath ) )
    self.hardLinkBreak({ filePath : o.dstPath, sync : 1 });

    self.fileWrite({ filePath : o.dstPath, data : srcFile, sync : 1 });
  }
  else
  {
    return _.timeOut( 0, () => _copyPre() )
    .ifNoErrorThen( () =>
    {
      if( o.breakingDstHardLink && self.fileIsHardLink( o.dstPath ) )
      return self.hardLinkBreak({ filePath : o.dstPath, sync : 0 });

    })
    .ifNoErrorThen( () =>
    {
      return self.fileWrite({ filePath : o.dstPath, data : srcFile, sync : 0 });
    })
  }
}

var defaults = fileCopyAct.defaults = Object.create( Parent.prototype.fileCopyAct.defaults );

defaults.sync = 0;

var having = fileCopyAct.having = Object.create( Parent.prototype.fileCopyAct.having );

//

function linkSoftAct( o )
{
  var self = this;

  _.assertMapHasOnly( o, linkSoftAct.defaults );

  _.assert( self.path.isAbsolute( o.dstPath ) );

  if( !self.path.isAbsolute( o.originalSrcPath ) )
  o.srcPath = o.originalSrcPath;

  if( o.sync )
  {
    // if( o.dstPath === o.srcPath )
    // return true;

    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkSoftAct',o.dstPath,'already exists' );

    self._descriptorWrite( o.dstPath, self._descriptorSoftLinkMake( o.srcPath ) );

    return true;
  }
  else
  {
    // if( o.dstPath === o.srcPath )
    // return new _.Consequence().give( true );

    return self.fileStat({ filePath : o.dstPath, sync : 0 })
    .doThen( ( err, stat ) =>
    {
      if( err )
      throw _.err( err );

      if( stat )
      throw _.err( 'linkSoftAct',o.dstPath,'already exists' );

      self._descriptorWrite( o.dstPath, self._descriptorSoftLinkMake( o.srcPath ) );

      return true;
    })
  }
}

var defaults = linkSoftAct.defaults = Object.create( Parent.prototype.linkSoftAct.defaults );
var having = linkSoftAct.having = Object.create( Parent.prototype.linkSoftAct.having );

//

function linkHardAct( o )
{
  var self = this;

  _.assertRoutineOptions( linkHardAct, arguments );

  if( o.sync )
  {
    if( o.dstPath === o.srcPath )
    return true;

    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkHardAct',o.dstPath,'already exists' );

    var file = self._descriptorRead( o.srcPath );

    if( !file )
    throw _.err( 'linkHardAct',o.srcPath,'does not exist' );

    if( !self._descriptorIsLink( file ) )
    if( !self.fileIsTerminal( o.srcPath ) )
    throw _.err( 'linkHardAct',o.srcPath,' is not a terminal file' );

    var dstDir = self._descriptorRead( self.path.dir( o.dstPath ) );
    if( !dstDir )
    throw _.err( 'linkHardAct: directories structure before', o.dstPath, ' does not exist' );

    self._descriptorWrite( o.dstPath, self._descriptorHardLinkMake( o.srcPath ) );

    return true;
  }
  else
  {
    if( o.dstPath === o.srcPath )
    return new _.Consequence().give( true );

    return self.fileStat({ filePath : o.dstPath, sync : 0 })
    .doThen( ( err, stat ) =>
    {
      if( err )
      throw _.err( err );

      if( stat )
      throw _.err( 'linkHardAct',o.dstPath,'already exists' );

      var file = self._descriptorRead( o.srcPath );

      if( !file )
      throw _.err( 'linkHardAct',o.srcPath,'does not exist' );

      if( !self._descriptorIsLink( file ) )
      if( !self.fileIsTerminal( o.srcPath ) )
      throw _.err( 'linkHardAct',o.srcPath,' is not a terminal file' );

      var dstDir = self._descriptorRead( self.path.dir( o.dstPath ) );
      if( !dstDir )
      throw _.err( 'linkHardAct: directories structure before', o.dstPath, ' does not exist' );

      self._descriptorWrite( o.dstPath, self._descriptorHardLinkMake( o.srcPath ) );

      return true;
    })
  }
}

var defaults = linkHardAct.defaults = Object.create( Parent.prototype.linkHardAct.defaults );
var having = linkHardAct.having = Object.create( Parent.prototype.linkHardAct.having );

//

function hardLinkBreakAct( o )
{
  var self = this;

  var descriptor = self._descriptorRead( o.filePath );

  _.assert( self._descriptorIsHardLink( descriptor ) );

  var read = self._descriptorResolve({ descriptor : descriptor });

  _.assert( self._descriptorIsTerminal( read ) );

  self._descriptorWrite( o.filePath, read );

  // descriptor = descriptor[ 0 ];
  //
  // var url = _.uri.parse( descriptor.hardLink );
  //
  // if( url.protocol )
  // {
  //   _.assert( url.protocol === 'file','can handle only "file" protocol, but got',url.protocol );
  //   var read = _.fileProvider.fileRead( url.localPath );
  //   _.assert( _.strIs( read ) );
  //   self._descriptorWrite( o.filePath, read );
  // }

  if( !o.sync )
  return new _.Consequence().give();
}

var defaults = hardLinkBreakAct.defaults = Object.create( Parent.prototype.hardLinkBreakAct.defaults );

// --
// etc
// --

function linksRebase( o )
{
  var self = this;

  _.routineOptions( linksRebase,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  function onUp( file )
  {
    var descriptor = self._descriptorRead( file.absolute );

    if( self._descriptorIsHardLink( descriptor ) )
    {
      debugger;
      descriptor = descriptor[ 0 ];
      var was = descriptor.hardLink;
      var url = _.uri.parseAtomic( descriptor.hardLink );
      url.localPath = self.path.rebase( url.localPath, o.oldPath, o.newPath );
      descriptor.hardLink = _.uri.str( url );
      logger.log( '* linksRebase :',descriptor.hardLink,'<-',was );
      debugger;
    }

    return file;
  }

  self.filesFind
  ({
    filePath : o.filePath,
    recursive : 1,
    onUp : onUp,
  });

}

linksRebase.defaults =
{
  filePath : '/',
  oldPath : '',
  newPath : '',
}

//

function _fileTimeSetAct( o )
{
  var self = this;

  if( !self.usingTime )
  return;

  if( _.strIs( arguments[ 0 ] ) )
  var o = { filePath : arguments[ 0 ] };

  _.assert( self.path.isAbsolute( o.filePath ), o.filePath );

  var timeStats = self.timeStats[ o.filePath ];

  if( !timeStats )
  {
    timeStats = self.timeStats[ o.filePath ] = Object.create( null );
    timeStats.atime = null;
    timeStats.mtime = null;
    timeStats.ctime = null;
    timeStats.birthtime = null;
  }

  if( o.atime )
  timeStats.atime = o.atime;

  if( o.mtime )
  timeStats.mtime = o.mtime;

  if( o.ctime )
  timeStats.ctime = o.ctime;

  if( o.birthtime )
  timeStats.birthtime = o.birthtime;

  if( o.updateParent )
  {
    var parentPath = self.path.dir( o.filePath );
    if( parentPath === '/' )
    return;

    timeStats.birthtime = null;

    _.assert( o.atime && o.mtime && o.ctime );
    _.assert( o.atime === o.mtime && o.mtime === o.ctime );

    o.filePath = parentPath;

    self._fileTimeSetAct( o );
  }

  return timeStats;
}

_fileTimeSetAct.defaults =
{
  filePath : null,
  atime : null,
  mtime : null,
  ctime : null,
  birthtime : null,
  updateParent : false
}

//

/** usage

    var treeWriten = _.filesTreeRead
    ({
      filePath : dir,
      readingTerminals : 0,
    });

    logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );

*/

function filesTreeRead( o )
{
  var self = this;
  var result = Object.create( null );
  var hereStr = '.';
  // var _srcPath = o.srcProvider ? o.srcProvider.path : _.path;

  if( _.strIs( o ) )
  o = { glob : o };

  _.routineOptions( filesTreeRead,o );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.glob ) || _.strsAre( o.glob ) || _.strIs( o.srcPath ) );
  _.assert( _.objectIs( o.srcProvider ) );
  _.assert( o.filePath === undefined );

  o.filePath = o.srcPath;
  delete o.srcPath;

  // o.outputFormat = 'record';

  if( self.verbosity >= 2 )
  logger.log( 'filesTreeRead at ' + ( o.glob || o.filePath ) );

  /* */

  o.onUp = _.arrayPrependElement( _.arrayAs( o.onUp ), function( record )
  {

    var element;
    _.assert( !!record.stat, 'file does not exists', record.absolute );
    var isDir = record.stat.isDirectory();

    /* */

    if( isDir )
    {
      element = Object.create( null );
    }
    else
    {
      if( o.readingTerminals === 'hardLink' )
      {
        element = [{ hardLink : record.full, absolute : 1 }];
        if( o.delayedLinksTermination )
        element[ 0 ].terminating = 1;
      }
      else if( o.readingTerminals === 'softLink' )
      {
        element = [{ softLink : record.full, absolute : 1 }];
        if( o.delayedLinksTermination )
        element[ 0 ].terminating = 1;
      }
      else if( o.readingTerminals )
      {
        // if( o.srcProvider.fileIsSoftLink
        // ({
        //   filePath : record.absolute,
        //   resolvingSoftLink : o.resolvingSoftLink,
        //   resolvingTextLink : o.resolvingTextLink,
        //   usingTextLink : o.usingTextLink,
        // }))
        // element = null;
        _.assert( _.boolLike( o.readingTerminals ),'unknown value of { o.readingTerminals }',_.strQuote( o.readingTerminals ) );
        if( element === undefined )
        element = o.srcProvider.fileReadSync( record.absolute );
      }
      else
      {
        element = null;
      }
    }

    if( !isDir && o.onFileTerminal )
    {
      element = o.onFileTerminal( element,record,o );
    }

    if( isDir && o.onFileDir )
    {
      element = o.onFileDir( element,record,o );
    }

    /* */

    var path = record.relative;

    /* removes leading './' characher */

    if( path.length > 2 )
    path = o.srcProvider.path.undot( path );

    if( o.asFlatMap )
    {
      result[ record.absolute ] = element;
    }
    else
    {
      if( path !== hereStr )
      _.entitySelectSet
      ({
        container : result,
        query : path,
        delimeter : o.delimeter,
        set : element,
      });
      else
      result = element;
    }

    return record;
  });

  /* */

  o.srcProvider.fieldSet( 'resolvingSoftLink',1 );
  var found = o.srcProvider.filesGlob( _.mapOnly( o, o.srcProvider.filesGlob.defaults ) );
  o.srcProvider.fieldReset( 'resolvingSoftLink',1 );

  return result;
}

// var defaults = filesTreeRead.defaults = Object.create( Find.prototype._filesFindMasksAdjust.defaults );
var defaults = filesTreeRead.defaults = Object.create( null );
var defaults2 =
{

  srcProvider : null,
  srcPath : null,
  basePath : null,

  recursive : 1,
  ignoringNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 1,
  includingTransients : 1,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,
  usingTextLink : 0,

  asFlatMap : 0,
  result : [],
  orderingExclusion : [],

  readingTerminals : 1,
  delayedLinksTermination : 0,
  delimeter : '/',

  onRecord : [],
  onUp : [],
  onDown : [],
  onFileTerminal : null,
  onFileDir : null,

  maskAll : _.files.regexpMakeSafe ? _.files.regexpMakeSafe() : null,

}

_.mapExtend( defaults, defaults2 );

var having = filesTreeRead.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function rewriteFromProvider( o )
{
  var self = this;

  if( arguments[ 1 ] !== undefined )
  {
    o = { srcProvider : arguments[ 0 ], srcPath : arguments[ 1 ] }
    _.assert( arguments.length === 2, 'expects exactly two arguments' );
  }
  else
  {
    _.assert( arguments.length === 1, 'expects single argument' );
  }

  var result = self.filesTreeRead( o );

  self.filesTree = result;

  return self;
}

rewriteFromProvider.defaults = Object.create( filesTreeRead.defaults );
rewriteFromProvider.having = Object.create( filesTreeRead.having );

//

function readToProvider( o )
{
  var self = this;
  var srcProvider = self;
  var _dstPath = o.dstProvider ? o.dstProvider.path : _.path;
  var _srcPath = _.instanceIs( srcProvider ) ? srcProvider.path : _.path;

  if( arguments[ 1 ] !== undefined )
  {
    o = { dstProvider : arguments[ 0 ], dstPath : arguments[ 1 ] }
    _.assert( arguments.length === 2, 'expects exactly two arguments' );
  }
  else
  {
    _.assert( arguments.length === 1, 'expects single argument' );
  }

  if( !o.filesTree )
  o.filesTree = self.filesTree;

  _.routineOptions( readToProvider,o );
  _.assert( _.strIs( o.dstPath ) );
  _.assert( _.objectIs( o.dstProvider ) );

  o.basePath = o.basePath || o.dstPath;
  o.basePath = _dstPath.relative( o.dstPath,o.basePath );

  if( self.verbosity > 1 )
  logger.log( 'readToProvider to ' + o.dstPath );

  var srcPath = '/';

  /* */

  var stat = null;
  function handleWritten( dstPath )
  {
    if( !o.allowWrite )
    return;
    if( !o.sameTime )
    return;
    if( !stat )
    stat = o.dstProvider.fileStat( dstPath );
    else
    {
      o.dstProvider.fileTimeSet( dstPath, stat.atime, stat.mtime );
      //creation of new file updates timestamps of the parent directory, calling fileTimeSet again to preserve same time
      o.dstProvider.fileTimeSet( _dstPath.dir( dstPath ), stat.atime, stat.mtime );
    }
  }

  /* */

  function writeSoftLink( dstPath,srcPath,descriptor,exists )
  {

    var defaults =
    {
      softLink : null,
      absolute : null,
      terminating : null,
    };

    _.assert( _.strIs( dstPath ) );
    _.assert( _.strIs( descriptor.softLink ) );
    _.assertMapHasOnly( descriptor,defaults );

    var terminating = descriptor.terminating || o.breakingSoftLink;

    if( o.allowWrite && !exists )
    {
      var contentPath = descriptor.softLink;
      contentPath = _srcPath.join( o.basePath, contentPath );
      if( o.absolutePathForLink || descriptor.absolute )
      contentPath = _.uri.resolve( dstPath,'..',descriptor.hardLink );
      dstPath = o.dstProvider.localFromUri( dstPath );
      if( terminating )
      {
        o.dstProvider.fileCopy( dstPath, contentPath );
      }
      else
      {
        debugger;
        var srcPathResolved = _srcPath.resolve( srcPath, contentPath );
        var srcStat = srcProvider.fileStat( srcPathResolved );
        var type = null;
        if( srcStat )
        type = srcStat.isDirectory() ? 'dir' : 'file';

        o.dstProvider.linkSoft
        ({
          dstPath : dstPath,
          srcPath : contentPath,
          allowMissing : 1,
          type : type
        });
      }
    }

    handleWritten( dstPath );
  }

  /* */

  function writeHardLink( dstPath,descriptor,exists )
  {

    var defaults =
    {
      hardLink : null,
      absolute : null,
      terminating : null,
    };

    _.assert( _.strIs( dstPath ) );
    _.assert( _.strIs( descriptor.hardLink ) );
    _.assertMapHasOnly( descriptor,defaults );

    var terminating = descriptor.terminating || o.terminatingHardLinks;

    if( o.allowWrite && !exists )
    {
      debugger;
      var contentPath = descriptor.hardLink;
      contentPath = _srcPath.join( o.basePath, contentPath );
      if( o.absolutePathForLink || descriptor.absolute )
      contentPath = _.uri.resolve( dstPath,'..',descriptor.hardLink );
      contentPath = o.dstProvider.localFromUri( contentPath );
      if( terminating )
      o.dstProvider.fileCopy( dstPath,contentPath );
      else
      o.dstProvider.linkHard( dstPath,contentPath );
    }

    handleWritten( dstPath );
  }

  /* */

  function write( dstPath,srcPath,descriptor )
  {

    _.assert( _.strIs( dstPath ) );
    _.assert( self._descriptorIsTerminal( descriptor ) || _.objectIs( descriptor ) || _.arrayIs( descriptor ) );

    var stat = o.dstProvider.fileStat( dstPath );
    if( stat )
    {
      if( o.allowDelete )
      {
        o.dstProvider.filesDelete( dstPath );
        stat = false;
      }
      else if( o.allowDeleteForRelinking )
      {
        var _isSoftLink = self._descriptorIsSoftLink( descriptor );
        if( _isSoftLink )
        {
          o.dstProvider.filesDelete( dstPath );
          stat = false;
        }
      }
    }

    /* */

    if( Self._descriptorIsTerminal( descriptor ) )
    {
      if( o.allowWrite && !stat )
      o.dstProvider.fileWrite( dstPath,descriptor );
      handleWritten( dstPath );
    }
    else if( Self._descriptorIsDir( descriptor ) )
    {
      if( o.allowWrite && !stat )
      o.dstProvider.directoryMake({ filePath : dstPath, force : 1 });
      handleWritten( dstPath );
      for( var t in descriptor )
      {
        write( _dstPath.join( dstPath,t ), _srcPath.join( srcPath, t ),descriptor[ t ]  );
      }
    }
    else if( _.arrayIs( descriptor ) )
    {
      _.assert( descriptor.length === 1,'Dont know how to interpret tree' );
      descriptor = descriptor[ 0 ];

      if( descriptor.softLink )
      writeSoftLink( dstPath,srcPath,descriptor,stat );
      else if( descriptor.hardLink )
      writeHardLink( dstPath,descriptor,stat );
      else throw _.err( 'unknown kind of file linking',descriptor );
    }

  }

  /* */

  o.dstProvider.fieldPush( 'resolvingSoftLink',0 );
  write( o.dstPath,srcPath,o.filesTree );
  o.dstProvider.fieldPop( 'resolvingSoftLink',0 );

  return self;
}

readToProvider.defaults =
{
  filesTree : null,
  dstProvider : null,
  dstPath : null,
  basePath : null,
  sameTime : 0,
  absolutePathForLink : 0,
  allowWrite : 1,
  allowDelete : 0,
  allowDeleteForRelinking : 0,
  verbosity : 0,

  breakingSoftLink : 0,
  terminatingHardLinks : 0,
}

var having = readToProvider.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.driving = 0;

// --
// descriptor read
// --

function _descriptorRead( o )
{
  var self = this;

  if( _.strIs( arguments[ 0 ] ) )
  var o = { filePath : arguments[ 0 ] };

  if( o.filePath === '.' )
  o.filePath = '';
  if( !o.filesTree )
  o.filesTree = self.filesTree;

  _.routineOptions( _descriptorRead,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  var optionsSelect = Object.create( null );

  optionsSelect.usingSet = 0;
  optionsSelect.query = o.filePath;
  optionsSelect.container = o.filesTree;
  optionsSelect.delimeter = o.delimeter;

  var result = _.entitySelect( optionsSelect );

  return result;
}

_descriptorRead.defaults =
{
  filePath : null,
  filesTree : null,
  delimeter : [ './', '/' ],
}

//

function _descriptorReadResolved( o )
{
  var self = this;

  if( _.strIs( arguments[ 0 ] ) )
  var o = { filePath : arguments[ 0 ] };

  var result = self._descriptorRead( o );

  if( self._descriptorIsLink( result ) )
  result = self._descriptorResolve({ descriptor : result });

  return result;
}

_descriptorReadResolved.defaults = Object.create( _descriptorRead.defaults );

//

function _descriptorResolve( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( o.descriptor );
  _.routineOptions( _descriptorResolve,o );
  self._providerOptions( o );
  _.assert( !o.resolvingTextLink );

  if( self._descriptorIsHardLink( o.descriptor ) /* && self.resolvingHardLink */ )
  {
    o.descriptor = self._descriptorResolveHardLink( o.descriptor );
    return self._descriptorResolve
    ({
      descriptor : o.descriptor,
      // resolvingHardLink : o.resolvingHardLink,
      resolvingSoftLink : o.resolvingSoftLink,
      resolvingTextLink : o.resolvingTextLink,
    });
  }

  if( self._descriptorIsSoftLink( o.descriptor ) && self.resolvingSoftLink )
  {
    o.descriptor = self._descriptorResolveSoftLink( o.descriptor );
    return self._descriptorResolve
    ({
      descriptor : o.descriptor,
      // resolvingHardLink : o.resolvingHardLink,
      resolvingSoftLink : o.resolvingSoftLink,
      resolvingTextLink : o.resolvingTextLink,
    });
  }

  return o.descriptor;
}

_descriptorResolve.defaults =
{
  descriptor : null,
  // resolvingHardLink : null,
  resolvingSoftLink : null,
  resolvingTextLink : null,
}

// function _descriptorResolvePath( o )
// {
//   var self = this;

//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( o.descriptor );
//   _.routineOptions( _descriptorResolve,o );
//   self._providerOptions( o );
//   _.assert( !o.resolvingTextLink );

//   var descriptor = self._descriptorRead( o.descriptor );

//   if( self._descriptorIsHardLink( descriptor ) && self.resolvingHardLink )
//   {
//     o.descriptor = self._descriptorResolveHardLinkPath( descriptor );
//     return self._descriptorResolvePath
//     ({
//       descriptor : o.descriptor,
//       resolvingHardLink : o.resolvingHardLink,
//       resolvingSoftLink : o.resolvingSoftLink,
//       resolvingTextLink : o.resolvingTextLink,
//     });
//   }

//   if( self._descriptorIsSoftLink( descriptor ) && self.resolvingSoftLink )
//   {
//     o.descriptor = self._descriptorResolveSoftLinkPath( descriptor );
//     return self._descriptorResolvePath
//     ({
//       descriptor : o.descriptor,
//       resolvingHardLink : o.resolvingHardLink,
//       resolvingSoftLink : o.resolvingSoftLink,
//       resolvingTextLink : o.resolvingTextLink,
//     });
//   }

//   return o.descriptor;
// }

// _descriptorResolvePath.defaults =
// {
//   descriptor : null,
//   resolvingHardLink : null,
//   resolvingSoftLink : null,
//   resolvingTextLink : null,
// }

//

function _descriptorResolveHardLinkPath( descriptor )
{
  var self = this;
  descriptor = descriptor[ 0 ];
  _.assert( !!descriptor.hardLink );
  return descriptor.hardLink;
}

//

function _descriptorResolveHardLink( descriptor )
{
  var self = this;
  var result;
  var filePath = self._descriptorResolveHardLinkPath( descriptor );
  var url = _.uri.parse( filePath );

  _.assert( arguments.length === 1 )

  if( url.protocol )
  {
    debugger;
    throw _.err( 'not implemented' );
    // _.assert( url.protocol === 'file','can handle only "file" protocol, but got',url.protocol );
    // result = _.fileProvider.fileRead( url.localPath );
    // _.assert( _.strIs( result ) );
  }
  else
  {
    debugger;
    result = self._descriptorRead( url.localPath );
  }

  return result;
}

//

function _descriptorResolveSoftLinkPath( descriptor, withPath )
{
  var self = this;
  descriptor = descriptor[ 0 ];
  _.assert( !!descriptor.softLink );
  return descriptor.softLink;
}

//

function _descriptorResolveSoftLink( descriptor )
{
  var self = this;
  var result;
  var filePath = self._descriptorResolveSoftLinkPath( descriptor );
  var url = _.uri.parse( filePath );

  _.assert( arguments.length === 1 )

  if( url.protocol )
  {
    debugger;
    throw _.err( 'not implemented' );
    // _.assert( url.protocol === 'file','can handle only "file" protocol, but got',url.protocol );
    // result = _.fileProvider.fileRead( url.localPath );
    // _.assert( _.strIs( result ) );
  }
  else
  {
    debugger;
    result = self._descriptorRead( url.localPath );
  }

  return result;
}

//

function _descriptorIsDir( file )
{
  return _.objectIs( file );
}

//

function _descriptorIsTerminal( file )
{
  return _.strIs( file ) || _.bufferRawIs( file ) || _.bufferTypedIs( file );
}

//

function _descriptorIsLink( file )
{
  if( !file )
  return false;
  if( _.arrayIs( file ) )
  {
    _.assert( file.length === 1 );
    file = file[ 0 ];
  }
  _.assert( !!file );
  return !!( file.hardLink || file.softLink );
}

//

function _descriptorIsSoftLink( file )
{
  if( !file )
  return false;
  if( _.arrayIs( file ) )
  {
    _.assert( file.length === 1 );
    file = file[ 0 ];
  }
  _.assert( !!file );
  return !!file.softLink;
}

//

function _descriptorIsHardLink( file )
{
  if( !file )
  return false;
  if( _.arrayIs( file ) )
  {
    _.assert( file.length === 1 );
    file = file[ 0 ];
  }
  _.assert( !!file );
  return !!file.hardLink;
}

//

function _descriptorIsScript( file )
{
  if( !file )
  return false;
  if( _.arrayIs( file ) )
  {
    _.assert( file.length === 1 );
    file = file[ 0 ];
  }
  _.assert( !!file );
  return !!file.code;
}

// --
// descriptor write
// --

function _descriptorWrite( o )
{
  var self = this;

  if( _.strIs( arguments[ 0 ] ) )
  o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };

  if( o.filePath === '.' )
  o.filePath = '';

  if( !o.filesTree )
  {
    _.assert( _.objectLike( self.filesTree ) );
    o.filesTree = self.filesTree;
  }

  _.routineOptions( _descriptorWrite,o );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var willBeCreated = self._descriptorRead( o.filePath ) === undefined;

  var optionsSelect = Object.create( null );

  optionsSelect.usingSet = 1;
  optionsSelect.set = o.data;
  optionsSelect.query = o.filePath;
  optionsSelect.container = o.filesTree;
  optionsSelect.delimeter = o.delimeter;

  var time = _.timeNow();
  var result = _.entitySelect( optionsSelect );

  o.filePath = self.path.join( '/', o.filePath );

  var timeOptions =
  {
    filePath : o.filePath,
    ctime : time,
    mtime : time
  }

  if( willBeCreated )
  {
    timeOptions.atime = time;
    timeOptions.birthtime = time;
    timeOptions.updateParent = 1;
  }

  self._fileTimeSetAct( timeOptions );

  return result;
}

_descriptorWrite.defaults =
{
  filePath : null,
  filesTree : null,
  data : null,
  delimeter : [ './', '/' ]
}

//

function _descriptorScriptMake( filePath, data )
{

  if( _.strIs( data ) )
  try
  {
    var data = _.routineMake({ code : data, prependingReturn : 0 });
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Cant make routine for file :\n' + filePath + '\n', err );
  }

  _.assert( _.routineIs( data ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  let d = Object.create( null );
  d.filePath = filePath;
  d.code = data;
  return [ d ];
}

//

function _descriptorSoftLinkMake( filePath )
{
  _.assert( arguments.length === 1, 'expects single argument' );
  let d = Object.create( null );
  d.softLink = filePath;
  return [ d ];
}

//

function _descriptorHardLinkMake( filePath )
{
  _.assert( arguments.length === 1, 'expects single argument' );
  let d = Object.create( null );
  d.hardLink = filePath;
  return [ d ];
}

// --
// encoders
// --

var readEncoders = Object.create( null );
var writeEncoders = Object.create( null );

fileReadAct.encoders = readEncoders;
fileWriteAct.encoders = writeEncoders;

//

readEncoders[ 'utf8' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'utf8' );
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    e.data = _.bufferToStr( e.data );
    _.assert( _.strIs( e.data ) );;
  },

}

//

readEncoders[ 'ascii' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'ascii' );
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    e.data = _.bufferToStr( e.data );
    _.assert( _.strIs( e.data ) );;
  },

}

//

readEncoders[ 'latin1' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'latin1' );
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    e.data = _.bufferToStr( e.data );
    _.assert( _.strIs( e.data ) );;
  },

}

//

readEncoders[ 'buffer.raw' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.raw' );
  },

  onEnd : function( e )
  {
    // _.assert( _.strIs( data ) );
    // qqq : use _.?someRoutine? please
    // var nodeBuffer = Buffer.from( data )
    // var result = _.bufferRawFrom( nodeBuffer );

    e.data = _.bufferRawFrom( e.data );

    _.assert( !_.bufferNodeIs( e.data ) );
    _.assert( _.bufferRawIs( e.data ) );

    // debugger;
    // var str = _.bufferToStr( result )
    // _.assert( str === data );
    // debugger;

    // return result;
  },

}

//

readEncoders[ 'buffer.bytes' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    e.data = _.bufferBytesFrom( e.data );
  },

}

readEncoders[ 'original.type' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'original.type' );
  },

  onEnd : function( e )
  {
    _.assert( _descriptorIsTerminal( e.data ) );
  },

}

//

if( Config.platform === 'nodejs' )
readEncoders[ 'buffer.node' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.node' );
  },

  onEnd : function( e )
  {
    e.data = _.bufferNodeFrom( e.data );
    // var result = Buffer.from( e.data );
    // _.assert( _.strIs( e.data ) );
    _.assert( _.bufferNodeIs( e.data ) );
    _.assert( !_.bufferRawIs( e.data ) );
    // return result;
  },

}

//

writeEncoders[ 'original.type' ] =
{
  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'original.type' );

    if( e.read === undefined || e.operation.writeMode === 'rewrite' )
    return;

    if( _.strIs( e.read ) )
    {
      if( !_.strIs( e.data ) )
      e.data = _.bufferToStr( e.data );
    }
    else
    {
      /* qqq : check */
      // _.assert( 0, 'not tested' );

      if( _.bufferBytesIs( e.read ) )
      e.data = _.bufferBytesFrom( e.data )
      else if( _.bufferRawIs( e.read ) )
      e.data = _.bufferRawFrom( e.data )
      else
      {
        _.assert( 0, 'not implemented for:', _.strTypeOf( e.read ) );
        // _.bufferFrom({ src : data, bufferConstructor : read.constructor });
      }
    }
  }
}

// --
// relationship
// --

var Composes =
{
  usingTime : null,
  protocols : _.define.own( [] ),
  _currentPath : '/',
  safe : 0,
}

var Aggregates =
{
}

var Associates =
{
  filesTree : null,
}

var Restricts =
{
  timeStats : _.define.own( {} ),
}

var Statics =
{

  filesTreeRead : filesTreeRead,

  readToProvider : readToProvider,

  _descriptorIsDir : _descriptorIsDir,
  _descriptorIsTerminal : _descriptorIsTerminal,
  _descriptorIsLink : _descriptorIsLink,
  _descriptorIsSoftLink : _descriptorIsSoftLink,
  _descriptorIsHardLink : _descriptorIsHardLink,

  _descriptorScriptMake : _descriptorScriptMake,
  _descriptorSoftLinkMake : _descriptorSoftLinkMake,
  _descriptorHardLinkMake : _descriptorHardLinkMake,

  Path : _.uri.CloneExtending({ fileProvider : Self }),

}

// --
// declare
// --

var Proto =
{

  init : init,

  //path

  pathCurrentAct : pathCurrentAct,
  pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  pathResolveHardLinkAct : pathResolveHardLinkAct,
  // linkSoftReadAct : linkSoftReadAct,

  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : null,
  directoryReadAct : directoryReadAct,

  // read stat

  fileStatAct : fileStatAct,
  fileExistsAct : fileExistsAct,

  // fileIsTerminalAct : fileIsTerminalAct,

  fileIsHardLink : fileIsHardLink,
  fileIsSoftLink : fileIsSoftLink,

  filesAreHardLinkedAct : filesAreHardLinkedAct,

  // write

  fileWriteAct : fileWriteAct,
  fileWriteStreamAct : null,
  fileTimeSetAct : fileTimeSetAct,
  fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,

  //link act

  fileRenameAct : fileRenameAct,
  fileCopyAct : fileCopyAct,
  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,

  hardLinkBreakAct : hardLinkBreakAct,

  // etc

  linksRebase : linksRebase,
  _fileTimeSetAct : _fileTimeSetAct,

  filesTreeRead : filesTreeRead,
  rewriteFromProvider : rewriteFromProvider,
  readToProvider : readToProvider,

  // descriptor read

  _descriptorRead : _descriptorRead,
  _descriptorReadResolved : _descriptorReadResolved,

  _descriptorResolve : _descriptorResolve,
  // _descriptorResolvePath : _descriptorResolvePath,

  _descriptorResolveHardLinkPath : _descriptorResolveHardLinkPath,
  _descriptorResolveHardLink : _descriptorResolveHardLink,
  _descriptorResolveSoftLinkPath : _descriptorResolveSoftLinkPath,
  _descriptorResolveSoftLink : _descriptorResolveSoftLink,

  _descriptorIsDir : _descriptorIsDir,
  _descriptorIsTerminal : _descriptorIsTerminal,
  _descriptorIsLink : _descriptorIsLink,
  _descriptorIsSoftLink : _descriptorIsSoftLink,
  _descriptorIsHardLink : _descriptorIsHardLink,
  _descriptorIsScript : _descriptorIsScript,

  // descriptor write

  _descriptorWrite : _descriptorWrite,

  _descriptorScriptMake : _descriptorScriptMake,
  _descriptorSoftLinkMake : _descriptorSoftLinkMake,
  _descriptorHardLinkMake : _descriptorHardLinkMake,

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
